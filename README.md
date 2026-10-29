# ConquestFarm (beta)

**Author:** Skrump · **Version:** 1.0.0-beta · **Command:** `//cf`

Buy Conquest Point items from your nation's gate guards in bulk, then sell them to an NPC shop, without clicking through menus.

> **Beta.** Buying from your own nation's guards in Windurst has been tested in game. San d'Oria and Bastok stock, and buying from another nation's guard, have not been tested yet. Check the log before you buy anything expensive.

---

## Install

1. Copy the whole `ConquestFarm` folder into `Windower/addons/`. It must contain both `ConquestFarm.lua` and `cp_stock.lua`.
2. In game: `//lua load conquestfarm`
3. Optional: to load it every time, add `lua load conquestfarm` to `Windower/scripts/init.txt`.

## Quick start

Stand next to a conquest guard in your nation's city, for example Harara, W.W. in Windurst Woods.

```
//cf info                              your rank, CP, and the current conquest standings
//cf list                              what you can buy right now
//cf buy 1 instant warp                buy one cheap item to check everything works
//cf buyall mercenary captains scythe  fill your inventory
//cf sell {Mrc.Cpt. Scythe}            then talk to a shop NPC and open its sell menu
```

## Commands

| Command | What it does |
|---|---|
| `//cf buy [qty] <item>` | Buy `qty` of an item (default 1). Capped by free slots and CP. |
| `//cf buyall <item>` | Buy as many as your CP and free inventory slots allow. |
| `//cf sell <item>` | Arm the seller, then open any NPC shop by hand. Sells every stack you have. |
| `//cf list` | Items you can buy right now from the nearby guard. |
| `//cf list all` | Every item, with the reason each locked one is locked. |
| `//cf info` | Your nation, rank, CP and the conquest standings. Next to a guard it briefly opens their menu to read them. |
| `//cf cancel` | Stop the current buy or sell. |
| `//cf reset` | **Unstick everything.** Clears all state and releases a menu lock. Use it if you can't move or ConquestFarm stops responding. |
| `//cf status` | What ConquestFarm is doing right now. |

**Item names:** use the short name, the long name, or an auto-translate tag. Case and punctuation don't matter, so these are all the same:
`mrc.cpt. scythe` · `mercenary captains scythe` · `{Mrc.Cpt. Scythe}`

## Which guards it uses

ConquestFarm **only** talks to the conquest guards inside the three nation cities. It ignores every other NPC, including outpost and border guards, even if you target them.

| City | Own-nation guards | Other nations' guards posted there |
|---|---|---|
| San d'Oria | Aravoge, Arpevion, Achantere (T.K.) | Chapal-Afal (W.W.), Yevgeny (I.M.) |
| Bastok | Rabid Wolf, Crying Wind, Flying Axe (I.M.) | Glarociquet (T.K.), Lexun-Marixun (W.W.) |
| Windurst | Harara, Milma-Hapilma, Puroiko-Maiko (W.W.) | Panoquieur (T.K.), Sachetan (I.M.) |

Each guard sells **their own** nation's stock. Stand within 6 yalms. If you have a guard targeted it uses that one; otherwise it uses the nearest.

## What it checks before buying

- **Rank:** you need at least the item's rank. A rank 3 player can't buy rank 4+ items.
- **Citizen-only items:** Chariot/Empress bands, signet staves, furniture and flags.
- **Conquest standing:** "1st" items need your nation in 1st place. "2nd or higher" items need 1st or 2nd.
- **Another nation's guard:** that nation must be ranked above yours. Ranked items cost double, or +8,000 CP above 8,000. Standing-restricted items can't be bought there.
- **CP and inventory space:** quantities are capped to what you can afford and carry.

Your rank, CP and the standings come from the game itself, mostly from the guard's menu. If something isn't known yet, the server decides.

## Safety

- **Never buys the wrong item.** After you pick an item, the guard replies with the item ID it's about to sell. ConquestFarm only confirms if it matches. Otherwise it backs out and says `guard offered X ... nothing bought`.
- **Counts only what you actually got.** A purchase counts once the item lands in your inventory, and a sale once it leaves. The next one waits for that.
- **Selling only uses a shop you open after `//cf sell`,** tied to the NPC you just talked to. If you walk 6 yalms or more away, it stops.
- **Stops on anything unexpected:** rejected purchase, out of CP, inventory full, out of range, NPC timeout, zone change, `//cf cancel`.
- **If you get menu-locked,** run `//cf reset`.

## Good items for gil

From your own nation's guards, roughly in gil per CP. NPC prices vary a little with your fame.

| Nation | Item | CP | NPC price |
|---|---|---|---|
| Windurst | Mercenary Captain's Scythe (R3) | 4,000 | ~4,457 |
| Windurst | Mercenary's Gi (R2) | 2,000 | ~1,564 |
| Windurst | Mercenary Captain's Doublet (R3) | 4,000 | ~3,023 |

Rare/Ex items can't be sold to NPCs, and `//cf sell` refuses them.

## Troubleshooting

- **`no nation city conquest guard nearby`**: you're not near one of the guards in the table above.
- **`guard offered X ... nothing bought`**: the item's menu ID in `cp_stock.lua` is wrong for that guard. Nothing was bought. Send Skrump the log.
- **`purchase rejected`**: the server refused, for example a rank or standing rule, or a once-only item.
- **Stuck in a menu / can't move**: `//cf reset`.
- **Logs:** `ConquestFarm/data/ConquestFarm_YYYYMMDD.log`. Every guard reply is logged. Include it when reporting a problem.

## Data sources

- **Menu IDs:** LandSandBoat server scripts (`conquest.lua`). Verified in game for Windurst.
- **Rank, cost, standing and citizen rules:** bg-wiki Conquest Points pages.
- **The three national flags (90,000 CP):** not in LandSandBoat, so their menu ID is a guess. The item check makes a wrong guess harmless.

## Support

ConquestFarm is free. If it saved you some clicking and you'd like to say thanks, you can [buy me a coffee on Ko-fi](https://ko-fi.com/skrumpalump). It's completely optional.

## Disclaimer

ConquestFarm sends game packets directly, like SparksFarm and Superwarp. That is against the FFXI Terms of Service. Use it at your own risk.
