-- Generated from LandSandBoat conquest.lua (option ids) + bg-wiki (placement/citizen rules).
-- Item ids resolved against Windower res/items.lua. Do not hand-edit option ids without
-- testing: ConquestFarm verifies the item id the server echoes back before confirming.
-- place: 1 = nation must be 1st in conquest, 2 = nation must be 1st or 2nd.
return {
    common = {
        {option=32928, id=4182, cp=7}, -- scroll of Instant Reraise
        {option=32929, id=4181, cp=10}, -- scroll of Instant Warp
        {option=32930, id=15542, cp=2500}, -- return ring
        {option=32931, id=15541, cp=9000}, -- homing ring
        {option=32933, id=15761, cp=500, citizen=true}, -- Chariot band
        {option=32934, id=15762, cp=1000, citizen=true}, -- Empress band
        {option=32935, id=15763, cp=2000}, -- Emperor band
        {option=32936, id=28540, cp=5000}, -- warp ring
        {option=32937, id=10114, cp=1000}, -- cipher of Tenzen's alter ego
        {option=32938, id=10139, cp=1000}, -- cipher of Rahal's alter ego
        {option=32939, id=10146, cp=1000}, -- cipher of Kukki's alter ego
        {option=32941, id=6380, cp=20000, rank=10}, -- refined chair set
        {option=32942, id=10180, cp=1000}, -- cipher of Makki's alter ego
    },
    [0] = { -- Sandoria
        {option=32768, id=17167, cp=1000, rank=1}, -- Royal Archer's longbow
        {option=32769, id=16544, cp=1000, rank=1}, -- Royal Archer's sword
        {option=32770, id=12510, cp=1000, rank=1}, -- Royal Footman's bandana
        {option=32771, id=12753, cp=1000, rank=1}, -- Royal Footman's gloves
        {option=32772, id=13004, cp=1000, rank=1}, -- Royal Footman's boots
        {option=32773, id=16691, cp=1000, rank=1, place=2}, -- Royal Archer's cesti
        {option=32774, id=13718, cp=1000, rank=1, place=1}, -- Royal Footman's tunic
        {option=32784, id=16852, cp=2000, rank=2}, -- Royal Spearman's spear
        {option=32785, id=12630, cp=2000, rank=2}, -- Royal Footman's vest
        {option=32786, id=12882, cp=2000, rank=2}, -- Royal Footman's trousers
        {option=32787, id=17367, cp=2000, rank=2, place=2}, -- Royal Spearman's horn
        {option=32788, id=13045, cp=2000, rank=2, place=1}, -- Royal Footman's clogs
        {option=32800, id=16844, cp=4000, rank=3}, -- Royal Squire's halberd
        {option=32801, id=13104, cp=4000, rank=3}, -- Royal Squire's collar
        {option=32802, id=12431, cp=4000, rank=3}, -- Royal Squire's helm
        {option=32803, id=12687, cp=4000, rank=3}, -- Royal Squire's mufflers
        {option=32804, id=12943, cp=4000, rank=3}, -- Royal Squire's sollerets
        {option=32805, id=16744, cp=4000, rank=3, place=2}, -- Royal Squire's dagger
        {option=32806, id=17150, cp=4000, rank=3, place=1}, -- Royal Squire's mace
        {option=32807, id=13495, cp=4000, rank=3, place=1}, -- San d'Orian ring
        {option=32816, id=16601, cp=8000, rank=4}, -- Royal Swordsman's blade
        {option=32817, id=12559, cp=8000, rank=4}, -- Royal Squire's chainmail
        {option=32818, id=12815, cp=8000, rank=4}, -- Royal Squire's breeches
        {option=32819, id=13719, cp=8000, rank=4, place=2}, -- Royal Squire's robe
        {option=32820, id=12336, cp=8000, rank=4, place=1}, -- Royal Squire's shield
        {option=32832, id=16851, cp=16000, rank=5}, -- Royal Knight Army lance
        {option=32833, id=16571, cp=16000, rank=5}, -- Temple Knight Army sword
        {option=32834, id=12312, cp=16000, rank=5}, -- Royal Knight Army shield
        {option=32835, id=12313, cp=16000, rank=5}, -- Temple Knight Army shield
        {option=32836, id=13107, cp=16000, rank=5}, -- Royal Knight Army collar
        {option=32837, id=13105, cp=16000, rank=5}, -- Temple Knight Army collar
        {option=32838, id=12686, cp=16000, rank=5}, -- Royal Knight's mufflers
        {option=32839, id=12942, cp=16000, rank=5}, -- Royal Knight's sollerets
        {option=32840, id=13220, cp=16000, rank=5, place=2}, -- Royal Knight's belt
        {option=32841, id=13720, cp=16000, rank=5, place=1}, -- Royal Knight's cloak
        {option=32848, id=13580, cp=24000, rank=6}, -- Royal Army mantle
        {option=32849, id=13106, cp=24000, rank=6}, -- Royal Guard's collar
        {option=32850, id=12430, cp=24000, rank=6}, -- Royal Knight's bascinet
        {option=32851, id=13722, cp=24000, rank=6}, -- Royal Knight's aketon
        {option=32852, id=12558, cp=24000, rank=6, place=2}, -- Royal Knight's chainmail
        {option=32853, id=12814, cp=24000, rank=6, place=2}, -- Royal Knight's breeches
        {option=32854, id=12321, cp=24000, rank=6, place=2}, -- Royal Guard's shield
        {option=32855, id=17067, cp=24000, rank=6, place=1}, -- Royal Guard's rod
        {option=32856, id=16599, cp=24000, rank=6, place=1}, -- Royal Guard's sword
        {option=32857, id=16805, cp=24000, rank=6, place=1}, -- Royal Guard's fleuret
        {option=32864, id=15956, cp=32000, rank=7}, -- Temple Knight's quiver
        {option=32865, id=16886, cp=32000, rank=7, place=2}, -- Grand Knight's lance
        {option=32866, id=13557, cp=32000, rank=7, place=1}, -- Grand Knight's ring
        {option=32880, id=14013, cp=40000, rank=8}, -- Grand Temple Knight's gauntlets
        {option=32881, id=14014, cp=40000, rank=8, place=2}, -- Grand Temple Knight's bangles
        {option=32882, id=13140, cp=40000, rank=8, place=1}, -- Grand Temple Knight's collar
        {option=32896, id=16953, cp=48000, rank=9}, -- Reserve Captain's great sword
        {option=32897, id=17934, cp=48000, rank=9}, -- Reserve Captain's pick
        {option=32898, id=17458, cp=48000, rank=9, place=2}, -- Reserve Captain's mace
        {option=32899, id=16893, cp=48000, rank=9, place=1}, -- Reserve Captain's lance
        {option=32912, id=14428, cp=56000, rank=10, place=1}, -- Kingdom aketon
        {option=32932, id=17583, cp=5000, rank=10, citizen=true}, -- Kingdom Signet staff
        {option=32940, id=6377, cp=10000, rank=10, citizen=true}, -- imperial chair set
        {option=32943, id=181, cp=90000, rank=10, citizen=true, guess=true}, -- San d'Orian flag (not in LSB; option guessed)
    },
    [1] = { -- Bastok
        {option=32768, id=16433, cp=1000, rank=1}, -- Legionnaire's knuckles
        {option=32769, id=17223, cp=1000, rank=1}, -- Legionnaire's crossbow
        {option=32770, id=16648, cp=1000, rank=1}, -- Legionnaire's axe
        {option=32771, id=12509, cp=1000, rank=1}, -- Legionnaire's cap
        {option=32772, id=12752, cp=1000, rank=1}, -- Legionnaire's mittens
        {option=32773, id=13003, cp=1000, rank=1}, -- Legionnaire's leggings
        {option=32774, id=17128, cp=1000, rank=1, place=2}, -- Legionnaire's staff
        {option=32775, id=16780, cp=1000, rank=1, place=1}, -- Legionnaire's scythe
        {option=32784, id=17048, cp=2000, rank=2}, -- Decurion's hammer
        {option=32785, id=12629, cp=2000, rank=2}, -- Legionnaire's harness
        {option=32786, id=12881, cp=2000, rank=2}, -- Legionnaire's subligar
        {option=32787, id=16745, cp=2000, rank=2, place=2}, -- Decurion's dagger
        {option=32788, id=12337, cp=2000, rank=2, place=1}, -- Decurion's shield
        {option=32800, id=16712, cp=4000, rank=3}, -- Centurion's axe
        {option=32801, id=13098, cp=4000, rank=3}, -- Republican Bronze Medal
        {option=32802, id=12438, cp=4000, rank=3}, -- Centurion's visor
        {option=32803, id=12566, cp=4000, rank=3}, -- Centurion's scale mail
        {option=32804, id=12694, cp=4000, rank=3}, -- Centurion's finger gauntlets
        {option=32805, id=12822, cp=4000, rank=3}, -- Centurion's cuisses
        {option=32806, id=12950, cp=4000, rank=3}, -- Centurion's greaves
        {option=32807, id=16806, cp=4000, rank=3, place=2}, -- Centurion's sword
        {option=32808, id=13830, cp=4000, rank=3, place=1}, -- Legionnaire's circlet
        {option=32809, id=13497, cp=4000, rank=3, place=1}, -- Bastokan ring
        {option=32816, id=16516, cp=8000, rank=4}, -- Junior Musketeer's tuck
        {option=32817, id=12422, cp=8000, rank=4}, -- Iron Musketeer's armet
        {option=32818, id=12678, cp=8000, rank=4}, -- Iron Musketeer's gauntlets
        {option=32819, id=12934, cp=8000, rank=4}, -- Iron Musketeer's sabatons
        {option=32820, id=13721, cp=8000, rank=4, place=2}, -- Iron Musketeer's gambison
        {option=32821, id=17283, cp=8000, rank=4, place=1}, -- Junior Musketeer's chakram
        {option=32832, id=16529, cp=16000, rank=5}, -- Musketeer's sword
        {option=32833, id=13099, cp=16000, rank=5}, -- Republican Iron Medal
        {option=32834, id=12550, cp=16000, rank=5}, -- Iron Musketeer's cuirass
        {option=32835, id=12806, cp=16000, rank=5}, -- Iron Musketeer's cuisses
        {option=32836, id=17129, cp=16000, rank=5, place=2}, -- Musketeer's pole
        {option=32837, id=17253, cp=16000, rank=5, place=1}, -- Musketeer gun
        {option=32848, id=13100, cp=24000, rank=6}, -- Republican Mythril Medal
        {option=32849, id=13582, cp=24000, rank=6}, -- Republican Army mantle
        {option=32850, id=16557, cp=24000, rank=6, place=2}, -- Musketeer Commander's falchion
        {option=32851, id=12304, cp=24000, rank=6, place=2}, -- Musketeer Commander's shield
        {option=32852, id=17151, cp=24000, rank=6, place=1}, -- Musketeer Commander's rod
        {option=32853, id=13064, cp=24000, rank=6, place=1}, -- Iron Musketeer's gorget
        {option=32864, id=15957, cp=32000, rank=7}, -- Iron Musketeer's quiver
        {option=32865, id=17807, cp=32000, rank=7, place=2}, -- Gold Musketeer's uchigatana
        {option=32866, id=13558, cp=32000, rank=7, place=1}, -- Gold Musketeer's ring
        {option=32880, id=14015, cp=40000, rank=8}, -- Praefectus's gloves
        {option=32881, id=13880, cp=40000, rank=8, place=2}, -- Presidential hairpin
        {option=32882, id=13141, cp=40000, rank=8, place=1}, -- Republican Gold Medal
        {option=32896, id=16799, cp=48000, rank=9}, -- Senior Gold Musketeer's scythe
        {option=32897, id=17457, cp=48000, rank=9}, -- Senior Gold Musketeer's rod
        {option=32898, id=18196, cp=48000, rank=9, place=2}, -- Senior Gold Musketeer's axe
        {option=32899, id=17655, cp=48000, rank=9, place=1}, -- Senior Gold Musketeer's scimitar
        {option=32912, id=14429, cp=56000, rank=10, place=1}, -- Republic aketon
        {option=32932, id=17584, cp=5000, rank=10, citizen=true}, -- Republic Signet staff
        {option=32940, id=6378, cp=10000, rank=10, citizen=true}, -- decorative chair set
        {option=32943, id=182, cp=90000, rank=10, citizen=true, guess=true}, -- Bastokan flag (not in LSB; option guessed)
    },
    [2] = { -- Windurst
        {option=32768, id=17159, cp=1000, rank=1}, -- Freesword's bow
        {option=32769, id=17028, cp=1000, rank=1}, -- Freesword's club
        {option=32770, id=16442, cp=1000, rank=1}, -- Freesword's baghnakhs
        {option=32771, id=12915, cp=1000, rank=1, place=2}, -- Freesword's slops
        {option=32772, id=17130, cp=1000, rank=1, place=1}, -- Freesword's staff
        {option=32784, id=17103, cp=2000, rank=2}, -- Mercenary's pole
        {option=32785, id=12484, cp=2000, rank=2}, -- Mercenary's hachimaki
        {option=32786, id=12653, cp=2000, rank=2}, -- Mercenary's gi
        {option=32787, id=12719, cp=2000, rank=2}, -- mercenary's tekko
        {option=32788, id=12855, cp=2000, rank=2}, -- Mercenary's sitabaki
        {option=32789, id=12975, cp=2000, rank=2}, -- Mercenary's kyahan
        {option=32790, id=16746, cp=2000, rank=2, place=2}, -- Mercenary's knife
        {option=32791, id=16930, cp=2000, rank=2, place=1}, -- Mercenary's great sword
        {option=32800, id=16776, cp=4000, rank=3}, -- Mercenary Captain's scythe
        {option=32801, id=12470, cp=4000, rank=3}, -- Mercenary Captain's headgear
        {option=32802, id=12598, cp=4000, rank=3}, -- Mercenary Captain's doublet
        {option=32803, id=12726, cp=4000, rank=3}, -- Mercenary Captain's gloves
        {option=32804, id=12854, cp=4000, rank=3}, -- Mercenary Captain's hose
        {option=32805, id=12982, cp=4000, rank=3}, -- Mercenary Captain's gaiters
        {option=32806, id=16747, cp=4000, rank=3, place=2}, -- Mercenary Captain's kukri
        {option=32807, id=13221, cp=4000, rank=3, place=1}, -- Mercenary Captain's belt
        {option=32808, id=13496, cp=4000, rank=3, place=1}, -- Windurstian ring
        {option=32816, id=16463, cp=8000, rank=4}, -- Combat Caster's dagger
        {option=32817, id=17282, cp=8000, rank=4}, -- Combat Caster's boomerang
        {option=32818, id=13101, cp=8000, rank=4}, -- green scarf
        {option=32819, id=12614, cp=8000, rank=4}, -- Combat Caster's cloak
        {option=32820, id=12743, cp=8000, rank=4}, -- Combat Caster's mitts
        {option=32821, id=12870, cp=8000, rank=4}, -- Combat Caster's slacks
        {option=32822, id=12998, cp=8000, rank=4}, -- Combat Caster's shoes
        {option=32823, id=16807, cp=8000, rank=4, place=2}, -- Combat Caster's scimitar
        {option=32824, id=16669, cp=8000, rank=4, place=1}, -- Combat Caster's axe
        {option=32832, id=17082, cp=16000, rank=5}, -- Tactician Magician's wand
        {option=32833, id=13102, cp=16000, rank=5}, -- paisley scarf
        {option=32834, id=12478, cp=16000, rank=5}, -- Tactician Magician's hat
        {option=32835, id=12606, cp=16000, rank=5}, -- Tactician Magician's coat
        {option=32836, id=12734, cp=16000, rank=5}, -- Tactician Magician's cuffs
        {option=32837, id=12862, cp=16000, rank=5}, -- Tactician Magician's slops
        {option=32838, id=12990, cp=16000, rank=5}, -- Tactician Magician's pigaches
        {option=32839, id=16810, cp=16000, rank=5, place=2}, -- Tactician Magician's espadon
        {option=32840, id=16694, cp=16000, rank=5, place=1}, -- Tactician Magician's hooks
        {option=32848, id=13103, cp=24000, rank=6}, -- checkered scarf
        {option=32849, id=13581, cp=24000, rank=6}, -- Federal Army mantle
        {option=32850, id=17094, cp=24000, rank=6, place=2}, -- Wise Wizard's staff
        {option=32851, id=16808, cp=24000, rank=6, place=2}, -- Wise Wizard's bilbo
        {option=32852, id=16809, cp=24000, rank=6, place=1}, -- Wise Wizard's anelace
        {option=32864, id=15958, cp=32000, rank=7}, -- Combat Caster's quiver
        {option=32865, id=12363, cp=32000, rank=7, place=2}, -- Patriarch Protector's shield
        {option=32866, id=13559, cp=32000, rank=7, place=1}, -- Patriarch Protector's ring
        {option=32880, id=14016, cp=40000, rank=8}, -- Master Caster's mitts
        {option=32881, id=14017, cp=40000, rank=8, place=2}, -- Master Caster's bracelets
        {option=32882, id=13142, cp=40000, rank=8, place=1}, -- Windurstian scarf
        {option=32896, id=18145, cp=48000, rank=9}, -- Master Caster's bow
        {option=32897, id=17530, cp=48000, rank=9}, -- Master Caster's pole
        {option=32898, id=17508, cp=48000, rank=9, place=2}, -- Master Caster's baghnakhs
        {option=32899, id=17617, cp=48000, rank=9, place=1}, -- Master Caster's knife
        {option=32912, id=14430, cp=56000, rank=10, place=1}, -- Federation aketon
        {option=32932, id=17585, cp=5000, rank=10, citizen=true}, -- Federation Signet staff
        {option=32940, id=6379, cp=10000, rank=10, citizen=true}, -- ornate stool set
        {option=32943, id=183, cp=90000, rank=10, citizen=true, guess=true}, -- Windurstian flag (not in LSB; option guessed)
    },
}
