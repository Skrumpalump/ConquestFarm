_addon.name = 'ConquestFarm'
_addon.author = 'Skrump'
_addon.version = '1.0.0-beta'
_addon.command = 'cf'
_addon.commands = {'cf','conquestfarm'}

require('tables')
local packets = require('packets')
local resources = require('resources')
local stock = require('cp_stock')

-- How a conquest purchase works (one item per menu visit):
--   0x01A  talk to the guard               -> server opens menu 0x034 (params: placements, rank, CP)
--   0x05B  option, Automated=true          -> server replies 0x05C {u1=equip flag, u2=1 if short on CP, u3=item id}
--   0x05B  option, Automated=false         -> server hands over the item and closes the menu
-- The final packet is only sent when u3 is the item we asked for, so a wrong option id
-- in cp_stock.lua can never buy the wrong thing. The client never sees the menu.

local NATIONS={[0]="San d'Oria",[1]='Bastok',[2]='Windurst'}

-- The only NPCs ConquestFarm will ever talk to: conquest guards inside the three nation
-- cities (from LandSandBoat zone scripts). Value = the nation whose stock the guard sells.
-- Outpost/border overseers are deliberately excluded.
local NATION_GUARDS={
    -- San d'Oria
    ['Aravoge, T.K.']=0,['Arpevion, T.K.']=0,['Achantere, T.K.']=0,
    ['Chapal-Afal, W.W.']=2,['Yevgeny, I.M.']=1,
    -- Bastok
    ['Rabid Wolf, I.M.']=1,['Crying Wind, I.M.']=1,['Flying Axe, I.M.']=1,
    ['Glarociquet, T.K.']=0,['Lexun-Marixun, W.W.']=2,
    -- Windurst
    ['Harara, W.W.']=2,['Milma-Hapilma, W.W.']=2,['Puroiko-Maiko, W.W.']=2,
    ['Panoquieur, T.K.']=0,['Sachetan, I.M.']=1,
}

local NPC_RANGE=6               -- yalms; guard and shop vendor must stay closer than this
local BUY_INTERVAL=1.6          -- seconds between guard interactions
local NPC_TIMEOUT=4             -- seconds to wait for a menu or item reply
local BUY_CONFIRM_TIMEOUT=3.0   -- seconds for a bought item to appear in inventory
local SELL_DELAY=2.0            -- seconds between stack sales
local SELL_CONFIRM_TIMEOUT=3.0  -- seconds for a sold stack to leave inventory
local MANUAL_TALK_WINDOW=5      -- seconds between talking to a vendor and its shop opening

-- Buy state: queue of purchases, the one in progress (active), and the one waiting
-- for its item to land (buy_confirm). operation tracks the whole //cf buy request.
local queue=T{}
local active=nil
local operation=nil
local buy_confirm=nil
local local_timer=os.clock()
local last_menu=nil -- last guard menu we opened, for //cf reset
local orphan=nil    -- {obj,deadline}: we talked to a guard but stopped before the menu arrived

-- Sell state.
local sell_state=nil
local shop_open=false
local last_manual_npc=nil

-- What we know about the player. nil = not seen yet; the server still has the final say.
local me={nation=nil,rank=nil,cp=nil,placement={}}

local log_file
local print_info -- defined with the other info commands; used by the guard menu handler

-- Logging -----------------------------------------------------------------------
local function logfile()
    if log_file then return log_file end
    windower.create_dir(windower.addon_path..'data')
    log_file=io.open(windower.addon_path..'data\\ConquestFarm_'..os.date('%Y%m%d')..'.log','a')
    return log_file
end
local function echo(level,s)
    local f=logfile(); if f then f:write(('[%s] [%s] %s\n'):format(os.date('%H:%M:%S'),level,s)); f:flush() end
    windower.add_to_chat(level=='ERROR' and 167 or level=='WARN' and 123 or 207,'CF: '..s)
end
local function dbg(s)
    local f=logfile(); if f then f:write(('[%s] [DEBUG] %s\n'):format(os.date('%H:%M:%S'),s)); f:flush() end
end

-- Player state ------------------------------------------------------------------
local function menu_params(raw)
    local t={}
    for i=0,7 do
        local a,b,c,d=raw:byte(i*4+1,i*4+4)
        t[i+1]=(a or 0)+(b or 0)*256+(c or 0)*65536+(d or 0)*16777216
    end
    return t
end
-- 2 bits per nation: San d'Oria, Bastok, Windurst. 1 = 1st place ... 3 = 3rd.
local function set_placement(bits)
    local s,b,w=bits%4,math.floor(bits/4)%4,math.floor(bits/16)%4
    if s>0 and b>0 and w>0 then me.placement={[0]=s,[1]=b,[2]=w} end
end
local CP_FIELD={[0]="Conquest Points (San d'Oria)",[1]='Conquest Points (Bastok)',[2]='Conquest Points (Windurst)'}
local function read_packet(id,data)
    local ok,p=pcall(packets.parse,'incoming',data)
    if not ok or not p then return end
    if id==0x061 then
        me.rank=p['Nation rank']; me.nation=p.Nation
    elseif id==0x113 and me.nation and p[CP_FIELD[me.nation]] then
        me.cp=p[CP_FIELD[me.nation]]
    end
end
-- Guard menu params: a3 = nation placements, a6 = rank + nation*32, a7 = CP.
local function read_guard_menu(params)
    set_placement(params[3])
    local rank,nation=params[6]%32,math.floor(params[6]/32)
    if rank>=1 and rank<=10 and NATIONS[nation] then me.rank=rank; me.nation=nation end
    if params[7]>0 then me.cp=params[7] end
end
-- Same request the client makes when opening the Currencies menu (reply: 0x113).
local function request_cp()
    packets.inject(packets.new('outgoing',0x10F))
end
local function init_state()
    local pl=windower.ffxi.get_player()
    if pl and pl.nation then me.nation=pl.nation end
    for _,id in ipairs({0x061,0x113}) do
        local data=windower.packets.last_incoming(id)
        if data then read_packet(id,data) end
    end
    if not me.cp then request_cp() end
end

-- Inventory -----------------------------------------------------------------------
local function free_slots()
    local inv=windower.ffxi.get_items().inventory
    return inv and (inv.max-inv.count) or 0
end
local function inventory_count(id)
    local total=0
    for i=1,80 do
        local x=windower.ffxi.get_items(0,i)
        if x and x.id==id then total=total+(x.count or 1) end
    end
    return total
end
local function find_inv_item(id)
    for i=1,80 do
        local x=windower.ffxi.get_items(0,i)
        if x and x.id==id and x.status==0 then return i,x end
    end
end

-- Item lookup ---------------------------------------------------------------------
local function norm(s) return (s or ''):lower():gsub('[^%w]','') end
local function item_name(id)
    local r=resources.items[id]
    return r and r.enl or ('item '..id)
end
local function item_matches(entry,want)
    local r=resources.items[entry.id]
    return r and (norm(r.en)==want or norm(r.enl)==want)
end
-- Accepts typed names and auto-translate tags (e.g. {Mst.Cst. Mitts}).
local function arg_name(args)
    return windower.from_shift_jis(windower.convert_auto_trans(table.concat(args,' '))):match('^%s*(.-)%s*$')
end

-- Finds an item in the stock of a guard selling guard_nation's goods.
local function find_item(name,guard_nation)
    local want=norm(name)
    for _,e in ipairs(stock.common) do
        if item_matches(e,want) then return e end
    end
    for _,e in ipairs(stock[guard_nation]) do
        if item_matches(e,want) then return e end
    end
    for n=0,2 do
        for _,e in ipairs(stock[n]) do
            if item_matches(e,want) then
                return nil,('%s is sold by %s guards, not %s'):format(item_name(e.id),NATIONS[n],NATIONS[guard_nation])
            end
        end
    end
    return nil,'not a conquest point item'
end

-- Ranked items cost more from another nation's guard (doubled up to 8000, else +8000).
local function price_for(entry,guard_nation)
    if entry.rank and me.nation and guard_nation~=me.nation then
        return entry.cp<=8000 and entry.cp*2 or entry.cp+8000
    end
    return entry.cp
end

-- Returns nil if buyable as far as we know, otherwise a short reason.
local function lock_reason(entry,guard_nation)
    local foreign=me.nation~=nil and guard_nation~=me.nation
    local mine=me.nation and me.placement[me.nation]
    if entry.rank and me.rank and me.rank<entry.rank then
        return ('needs rank %u (you are rank %u)'):format(entry.rank,me.rank)
    end
    if entry.citizen and foreign then
        return ('%s citizens only'):format(NATIONS[guard_nation])
    end
    if entry.place and foreign then
        return 'placement item: own nation only'
    end
    if foreign and mine and me.placement[guard_nation] and me.placement[guard_nation]>=mine then
        return ('%s must be ranked above %s'):format(NATIONS[guard_nation],NATIONS[me.nation])
    end
    if entry.place and mine and mine>entry.place then
        return ('needs %s %s in conquest (currently %u)'):format(NATIONS[guard_nation],entry.place==1 and '1st' or '1st/2nd',mine)
    end
end

-- Guards --------------------------------------------------------------------------
-- Only NATION_GUARDS, never arbitrary NPCs: the menu option we send would be
-- meaningless (or worse) to any other NPC's event.
local function is_guard(mob)
    return mob and mob.is_npc and NATION_GUARDS[mob.name]~=nil
end
local function distance(mob) return math.sqrt(mob.distance or math.huge) end

-- Returns the targeted guard if in range, else the nearest one: mob, nation it sells.
local function conquest_npc()
    local t=windower.ffxi.get_mob_by_target('t')
    if is_guard(t) and distance(t)<NPC_RANGE then return t,NATION_GUARDS[t.name] end
    local best,best_d
    for _,mob in pairs(windower.ffxi.get_mob_array()) do
        if is_guard(mob) then
            local d=distance(mob)
            if not best_d or d<best_d then best,best_d=mob,d end
        end
    end
    if not best then return nil,'no nation city conquest guard nearby' end
    if best_d>=NPC_RANGE then return nil,('%s out of range (%.1f yalms)'):format(best.name,best_d) end
    return best,NATION_GUARDS[best.name]
end

-- Packets ---------------------------------------------------------------------------
-- obj needs Target, Target Index, Zone (and menu_id once the menu is open).
local function talk_to(obj)
    packets.inject(packets.new('outgoing',0x01A,{
        Target=obj.Target,['Target Index']=obj['Target Index'],
        Category=0,Param=0,_unknown1=0
    }))
end
local function send_menu(obj,option,unknown1,automated)
    packets.inject(packets.new('outgoing',0x05B,{
        Target=obj.Target,['Target Index']=obj['Target Index'],
        ['Option Index']=option,_unknown1=unknown1,
        ['Automated Message']=automated,_unknown2=0,
        Zone=obj.Zone,['Menu ID']=obj.menu_id,
    }))
end
local function close_menu(obj) send_menu(obj,0,16384,false) end

-- Buying ------------------------------------------------------------------------------
local function busy() return operation or active or #queue>0 or buy_confirm or sell_state or orphan end

-- Drops the in-progress guard interaction. If its menu is open, close it; if we already
-- talked to the guard but the menu hasn't arrived yet, catch it when it does (see
-- on_orphan_menu) so it never pops up on the client.
local function abandon_active()
    if not active then return end
    if active.obj.menu_id then
        close_menu(active.obj)
    else
        orphan={obj=active.obj,deadline=os.clock()+NPC_TIMEOUT}
    end
    active=nil
end

-- Stops the whole buy request. menu_gone=true when the menu no longer exists (zone change).
local function cancel_buy(reason,level,menu_gone)
    local completed=operation and operation.completed or 0
    local requested=operation and operation.requested or (#queue+(active and 1 or 0))
    dbg(('buy stopped completed=%u requested=%u reason=%s'):format(completed,requested,reason))
    if menu_gone then active=nil else abandon_active() end
    queue=T{}; buy_confirm=nil; operation=nil
    echo(level or 'WARN',('Buy stopped: %u/%u - %s.'):format(completed,requested,reason))
end

local function build_purchase(name)
    local mob,guard_nation=conquest_npc()
    if not mob then return nil,guard_nation end
    local entry,err=find_item(name,guard_nation)
    if not entry then return nil,err end
    local why=lock_reason(entry,guard_nation)
    if why then return nil,why end
    return {
        id=entry.id,name=item_name(entry.id),option=entry.option,guess=entry.guess,
        price=price_for(entry,guard_nation),
        Target=mob.id,['Target Index']=mob.index,npc=mob.name,
        Zone=windower.ffxi.get_info().zone,
    }
end

-- count=nil means "as many as possible" (buyall).
local function start_buy(name,count)
    local obj,err=build_purchase(name)
    if not obj then echo('ERROR',('Cannot buy %s: %s.'):format(name,err)); return end
    local slots=free_slots()
    local affordable=me.cp and math.floor(me.cp/obj.price)
    local limit=math.min(slots,affordable or slots)
    local kind=count and 'Buy' or 'Buyall'
    if not count then
        count=limit
    elseif count>limit then
        echo('WARN',('Requested %u but %s; capping to %u.'):format(count,
            limit==slots and ('only %u slots free'):format(slots) or ('%u CP buys %u'):format(me.cp,affordable),limit))
        count=limit
    end
    if count<1 then
        echo('ERROR',('Cannot buy %s: %s.'):format(obj.name,slots<1 and 'inventory full'
            or ('%u CP, costs %u'):format(me.cp,obj.price)))
        return
    end
    operation={kind=kind,requested=count,completed=0}
    for _=1,count do queue:append(obj) end
    echo('INFO',('Buying %u %s from %s (%u CP each%s).'):format(count,obj.name,obj.npc,obj.price,
        me.cp and (', %u CP held'):format(me.cp) or ', CP total unknown'))
    if obj.guess then echo('WARN','Menu option for this item is unconfirmed; it will be verified before buying.') end
end

local function check_buy_confirmation()
    local now_count=inventory_count(buy_confirm.item_id)
    if now_count>buy_confirm.before then
        local gained=now_count-buy_confirm.before
        operation.completed=operation.completed+gained
        if me.cp then me.cp=math.max(0,me.cp-buy_confirm.price*gained) end
        dbg(('buy confirmed item=%s inventory=%u->%u completed=%u/%u cp=%s'):format(
            buy_confirm.item_name,buy_confirm.before,now_count,operation.completed,operation.requested,tostring(me.cp)))
        buy_confirm=nil
        if #queue==0 and not active then
            echo('INFO',('%s complete: %u/%u.%s'):format(operation.kind,operation.completed,operation.requested,
                me.cp and (' %u CP left.'):format(me.cp) or ''))
            operation=nil
        end
    elseif os.clock()>=buy_confirm.deadline then
        cancel_buy('purchase rejected','ERROR')
    end
end

-- Starts the next queued purchase once the previous one is confirmed.
local function buy_tick()
    if buy_confirm then check_buy_confirmation(); return end
    local now=os.clock()
    if active then
        if now-local_timer<NPC_TIMEOUT then return end
        if active.stage=='peek' then
            abandon_active()
            echo('WARN','Guard did not answer.')
        else
            cancel_buy(active.stage=='update' and 'no reply to item selection' or 'NPC timeout','ERROR')
        end
        local_timer=now
        return
    end
    if #queue==0 or now-local_timer<BUY_INTERVAL then return end
    local obj=queue[1]
    local mob=windower.ffxi.get_mob_by_id(obj.Target)
    local_timer=now
    if not mob then cancel_buy('NPC no longer available','ERROR'); return end
    if distance(mob)>=NPC_RANGE then cancel_buy(('NPC out of range (%.1f yalms)'):format(distance(mob)),'ERROR'); return end
    if free_slots()<1 then cancel_buy('inventory full','ERROR'); return end
    if me.cp and me.cp<obj.price then cancel_buy(('out of CP (%u left)'):format(me.cp),'WARN'); return end
    active={obj=obj,stage='talk'}
    dbg(('talking to %s for %s; %u queued'):format(obj.npc,obj.name,#queue))
    talk_to(obj)
end

-- Guard menu opened (0x034/0x032) for our talk_to. Returns true to hide it from the client.
local function on_guard_menu(id,data)
    local obj=active.obj
    local ok,p=pcall(packets.parse,'incoming',data)
    if not ok or not p or p.NPC~=obj.Target then return end
    obj.menu_id=p['Menu ID']
    last_menu={Target=obj.Target,['Target Index']=obj['Target Index'],Zone=obj.Zone,menu_id=obj.menu_id}
    if id==0x034 then
        local params=menu_params(p['Menu Parameters'])
        dbg(('menu %u params %s'):format(obj.menu_id,table.concat(params,',')))
        read_guard_menu(params)
    end
    if active.stage=='peek' then
        close_menu(obj)
        active=nil
        print_info()
        return true
    end
    if me.cp and me.cp<obj.price then
        cancel_buy(('out of CP (%u left)'):format(me.cp),'WARN')
        return true
    end
    send_menu(obj,obj.option,0,true)
    active.stage='update'
    local_timer=os.clock()
    return true
end

-- A late menu from a guard interaction we already abandoned: hide and close it.
local function on_orphan_menu(data)
    local ok,p=pcall(packets.parse,'incoming',data)
    if not ok or not p or p.NPC~=orphan.obj.Target then return end
    orphan.obj.menu_id=p['Menu ID']
    close_menu(orphan.obj)
    dbg(('closed late menu %u from %s'):format(orphan.obj.menu_id,orphan.obj.npc or 'guard'))
    orphan=nil
    return true
end

-- Guard's reply to our item selection (0x05C). Confirms only if it is the right item.
local function on_item_reply(data)
    local obj=active.obj
    local ok,p=pcall(packets.parse,'incoming',data)
    if not ok or not p then return end
    local r=menu_params(p['Menu Parameters'])
    dbg(('item reply %s'):format(table.concat(r,',')))
    if r[3]~=obj.id then
        cancel_buy(('guard offered %s for option %u, expected %s - nothing bought'):format(
            r[3]>0 and item_name(r[3]) or 'nothing',obj.option,obj.name),'ERROR')
        return true
    end
    if r[2]~=0 then
        cancel_buy('not enough CP','WARN')
        return true
    end
    local before=inventory_count(obj.id)
    send_menu(obj,obj.option,0,false)
    table.remove(queue,1)
    active=nil
    local_timer=os.clock()
    buy_confirm={item_id=obj.id,item_name=obj.name,price=obj.price,before=before,
        deadline=os.clock()+BUY_CONFIRM_TIMEOUT}
    dbg(('purchase sent item=%s option=%u before=%u remaining=%u'):format(obj.name,obj.option,before,#queue))
    return true
end

-- Selling -----------------------------------------------------------------------------
-- //cf sell arms the seller; the player then opens a normal NPC shop by hand.
local function find_res(name)
    local want=norm(name)
    for id,v in pairs(resources.items) do
        if norm(v.en)==want or norm(v.enl)==want then return id,v end
    end
end

local function start_sell(name)
    local id,res=find_res(name)
    if not id then echo('ERROR',('Cannot sell %s: unknown item.'):format(name)); return end
    if res.flags and res.flags['No NPC Sale'] then
        echo('ERROR',('Cannot sell %s: item cannot be sold to NPCs.'):format(res.en))
        return
    end
    local count=inventory_count(id)
    if count<1 then echo('ERROR',('Cannot sell %s: none found in inventory.'):format(res.en)); return end
    sell_state={id=id,name=res.en,initial=count,sold=0,next=os.clock(),waiting=false}
    shop_open=false -- a shop left open from before //cf sell must never be sold into
    echo('INFO',('Selling %u %s. Open a shop.'):format(count,res.en))
end

local function end_sale(level,msg)
    echo(level,('%s: %u/%u.'):format(msg,sell_state.sold,sell_state.initial))
    sell_state=nil
    shop_open=false
end
local function cancel_sale(reason,level)
    dbg(('sell stopped completed=%u requested=%u reason=%s'):format(sell_state.sold,sell_state.initial,reason))
    end_sale(level or 'ERROR','Sell stopped - '..reason)
end

local function sell_one()
    local before=inventory_count(sell_state.id)
    if before<1 then end_sale('INFO','Sell complete'); return end
    local index,item=find_inv_item(sell_state.id)
    if not index then cancel_sale('matching item is no longer available for sale'); return end

    -- 0x084 = offer the stack to the shop, 0x085 = confirm the sale.
    windower.packets.inject_outgoing(0x084,string.char(
        0x084,0x06,0,0,
        item.count,0,0,0,
        sell_state.id%256,math.floor(sell_state.id/256)%256,
        index,0))
    windower.packets.inject_outgoing(0x085,string.char(0x085,0x04,0,0,1,0,0,0))
    dbg(('sell sent item=%s slot=%u count=%u vendor=%s'):format(sell_state.name,index,item.count,sell_state.vendor_name))

    -- Do NOT count the sale yet. Wait for inventory to actually decrease.
    sell_state.waiting=true
    sell_state.before_count=before
    sell_state.confirm_deadline=os.clock()+SELL_CONFIRM_TIMEOUT
end

local function check_sale_confirmation()
    local now_count=inventory_count(sell_state.id)
    if now_count<sell_state.before_count then
        sell_state.sold=sell_state.sold+(sell_state.before_count-now_count)
        sell_state.waiting=false
        if now_count<1 then end_sale('INFO','Sell complete') else sell_state.next=os.clock()+SELL_DELAY end
    elseif os.clock()>=sell_state.confirm_deadline then
        cancel_sale('transaction was not accepted (vendor may not buy the item)')
    end
end

-- Outgoing 0x01A typed by the player (not injected): remember who they talked to.
local function remember_manual_talk(data)
    local ok,p=pcall(packets.parse,'outgoing',data)
    if ok and p and p.Category==0 and p.Target~=0 then
        last_manual_npc={id=p.Target,time=os.clock()}
    end
end

-- Shop window opened (0x03C). Only counts while a sale is armed and the player just
-- talked to the vendor by hand.
local function on_shop_open()
    if not sell_state then return end
    if not last_manual_npc or os.clock()-last_manual_npc.time>MANUAL_TALK_WINDOW then
        cancel_sale('could not associate the shop with the NPC interaction')
        return
    end
    local mob=windower.ffxi.get_mob_by_id(last_manual_npc.id)
    shop_open=true
    sell_state.vendor_id=last_manual_npc.id
    sell_state.vendor_name=mob and mob.name or 'NPC vendor'
    echo('INFO',('Selling to %s.'):format(sell_state.vendor_name))
    if mob then dbg(('vendor associated id=%u distance=%.1f'):format(mob.id,distance(mob))) end
end

local function sell_tick()
    if not shop_open then return end
    local mob=windower.ffxi.get_mob_by_id(sell_state.vendor_id)
    if not mob then cancel_sale('vendor is no longer available'); return end
    if distance(mob)>=NPC_RANGE then cancel_sale(('vendor out of range (%.1f yalms)'):format(distance(mob))); return end
    if sell_state.waiting then
        check_sale_confirmation()
    elseif os.clock()>=sell_state.next then
        sell_one()
    end
end

-- Info / list -------------------------------------------------------------------------
print_info=function()
    local function place(n) return me.placement[n] and ({'1st','2nd','3rd'})[me.placement[n]] or '?' end
    echo('INFO',('%s, rank %s, %s CP | Standings: San d\'Oria %s, Bastok %s, Windurst %s'):format(
        me.nation and NATIONS[me.nation] or '?',tostring(me.rank or '?'),tostring(me.cp or '?'),
        place(0),place(1),place(2)))
    if not me.placement[0] then echo('INFO','Standings fill in when you run //cf info next to a guard.') end
end

local function start_info()
    local mob=conquest_npc()
    if not mob then
        request_cp()
        coroutine.schedule(print_info,1)
        return
    end
    -- Open the guard's menu just to read rank/CP/standings, then close it.
    active={obj={Target=mob.id,['Target Index']=mob.index,Zone=windower.ffxi.get_info().zone},stage='peek'}
    local_timer=os.clock()
    talk_to(active.obj)
end

local function print_list(show_all)
    local _,guard_nation=conquest_npc()
    local n=guard_nation or me.nation
    if n==nil then echo('ERROR','Nation unknown yet; stand near a guard or zone once.'); return end
    echo('INFO',('%s guard stock%s:'):format(NATIONS[n],show_all and '' or ' you can buy now'))
    local shown=0
    for _,list in ipairs({stock.common,stock[n]}) do
        for _,e in ipairs(list) do
            local why=lock_reason(e,n)
            if show_all or not why then
                shown=shown+1
                windower.add_to_chat(207,('  %s%s - %u CP%s'):format(e.rank and ('R%u '):format(e.rank) or '',
                    item_name(e.id),price_for(e,n),why and (' [%s]'):format(why) or ''))
            end
        end
    end
    if shown==0 then echo('INFO','Nothing available. //cf list all shows locked items.') end
end

-- Reset ---------------------------------------------------------------------------------
-- For when the character is menu-locked or ConquestFarm is wedged. Same approach as
-- Superwarp's //sw reset: drop all state, close the last guard menu we used on the
-- server, and tell the client its event is over (0x052 release).
local function reset()
    queue=T{}; active=nil; operation=nil; buy_confirm=nil; orphan=nil
    sell_state=nil; shop_open=false
    windower.packets.inject_incoming(0x052,string.char(0,0,0,0,0,0,0,0))
    windower.packets.inject_incoming(0x052,string.char(0,0,0,0,1,0,0,0))
    if last_menu and last_menu.Zone==windower.ffxi.get_info().zone then
        local m=last_menu.menu_id
        windower.packets.inject_incoming(0x052,string.char(0,0,0,0,2,m%256,math.floor(m/256),0))
        close_menu(last_menu)
    end
    last_menu=nil
    dbg('reset')
    echo('INFO','Reset: all operations cleared and menu lock released.')
end

-- Commands ------------------------------------------------------------------------------
local HELP='//cf buy [qty] <item> | buyall <item> | sell <item> | list [all] | info | cancel | reset | status'

windower.register_event('addon command',function(command,...)
    command=command and command:lower() or 'help'
    local args=T{...}
    if command=='cancel' then
        if sell_state then cancel_sale('cancelled by user','WARN')
        elseif operation or active or buy_confirm then cancel_buy('cancelled by user','WARN')
        else echo('INFO','Nothing to cancel.') end
        return
    elseif command=='reset' then
        reset()
        return
    elseif command=='status' then
        echo('INFO',('v%s | buying: %s (%u queued) | selling: %s'):format(_addon.version,
            operation and (buy_confirm and buy_confirm.item_name or queue[1] and queue[1].name) or 'no',#queue,
            sell_state and sell_state.name or 'no'))
        return
    elseif command=='list' then
        print_list(args[1] and args[1]:lower()=='all')
        return
    elseif command~='buy' and command~='buyall' and command~='sell' and command~='info' then
        echo('INFO',HELP)
        return
    end

    if busy() then echo('WARN','ConquestFarm is busy. Use //cf cancel.'); return end
    if command=='info' then start_info(); return end
    local qty
    if command=='buy' then
        qty=tonumber(args[1]); if qty then args:remove(1) else qty=1 end
        qty=math.max(1,math.floor(qty))
    end
    local name=arg_name(args)
    if name=='' then echo('ERROR','Usage: '..HELP); return end
    if command=='sell' then start_sell(name) else start_buy(name,qty) end
end)

-- Events --------------------------------------------------------------------------------
windower.register_event('prerender',function()
    if orphan and os.clock()>=orphan.deadline then orphan=nil end
    if operation or active then buy_tick() end
    if sell_state then sell_tick() end
end)

windower.register_event('incoming chunk',function(id,data)
    if id==0x061 or id==0x113 then read_packet(id,data)
    elseif id==0x03C then on_shop_open() end

    if orphan and (id==0x034 or id==0x032) then return on_orphan_menu(data) end
    if not active then return end
    if (id==0x034 or id==0x032) and (active.stage=='talk' or active.stage=='peek') then
        return on_guard_menu(id,data)
    elseif id==0x05C and active.stage=='update' then
        return on_item_reply(data)
    end
end)

windower.register_event('outgoing chunk',function(id,data,modified,injected)
    -- Only the player's own NPC interactions; our injected guard talks must never
    -- become the shop vendor.
    if id==0x01A and not injected then remember_manual_talk(data) end
end)

windower.register_event('zone change',function()
    if sell_state then cancel_sale('zone changed') end
    orphan=nil
    if busy() then cancel_buy('zone changed','ERROR',true) end
    shop_open=false
end)

windower.register_event('unload',function()
    if log_file then log_file:close() end
end)

init_state()
echo('INFO','Loaded ConquestFarm v'.._addon.version..' - //cf list to see what you can buy.')
