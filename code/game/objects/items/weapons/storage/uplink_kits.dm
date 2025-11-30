/obj/item/storage/box/syndie_kit
	desc = "A sleek, sturdy box."
	icon_state = "doom_box"

/// Traitor bundles
/obj/item/storage/box/syndie_kit/bundle
	var/list/items = list()

/// 222TC
/obj/item/storage/box/syndie_kit/bundle/spy
	name = "Spy Bundle"
	desc = "Complete your objectives quietly with this compilation of stealthy items."
	items = list(
		/obj/item/storage/box/syndie_kit/chameleon, // 10TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/clothing/shoes/chameleon/noslip, // 10TC
		/obj/item/clothing/glasses/hud/security/chameleon, //10TC
		/obj/item/bio_chip_implanter/storage, // 40TC
		/obj/item/pen/edagger, // 10TC
		/obj/item/pinpointer/advpinpointer, // 10TC
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate, // 7TC
		/obj/item/flashlight/emp, // 20TC
		/obj/item/chameleon, // 25TC
		/obj/item/garrote, // 30 TC
		/obj/item/door_remote/omni/access_tuner, // 30TC
		/obj/item/encryptionkey/syndicate) // 10TC

/// 142TC
/obj/item/storage/box/syndie_kit/bundle/agent13
	name = "Agent 13 Bundle"
	desc = "Find and eliminate your targets quietly and effectively with this kit."
	items = list(
		/obj/item/clothing/under/chameleon, // 1TC. 10TC divided over 10 items from the chameleon kit.
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/storage/box/syndie_kit/stechkin, // 26TC. 20TC for stechkin, plus the 2 mags at 3TC
		/obj/item/suppressor, // 5TC
		/obj/item/ammo_box/magazine/m10mm,  // 3TC
		/obj/item/ammo_box/magazine/m10mm/hp, // 7TC
		/obj/item/garrote, // 30TC
		/obj/item/door_remote/omni/access_tuner, // 30TC
		/obj/item/clothing/glasses/chameleon/thermal, // 15TC
		/obj/item/storage/briefcase/false_bottomed, // 10TC
		/obj/item/bio_chip_implanter/freedom, // 25TC
		/obj/item/coin/gold, // 0TC
		/obj/item/encryptionkey/syndicate) // 10TC

/// 160TC
/obj/item/storage/box/syndie_kit/bundle/thief
	name = "Thief Bundle"
	desc = "Steal from friends, enemies, and interstellar megacorporations alike!"
	items = list(
		/obj/item/gun/energy/kinetic_accelerator/crossbow, // 60TC
		/obj/item/chameleon, // 25TC
		/obj/item/clothing/glasses/chameleon/thermal, // 15TC
		/obj/item/clothing/gloves/color/black/thief, // 30TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/storage/backpack/satchel_flat, // 10TC
		/obj/item/encryptionkey/syndicate) // 10TC

/// 176TC
/obj/item/storage/box/syndie_kit/bundle/bond
	name = "Agent 007 Bundle"
	desc = "Shake your Martini and stir up trouble with this bundle of lethal equipment mixed with a spritz of gadgetry to keep things interesting."
	items = list(
		/obj/item/storage/briefcase/false_bottomed, // 10TC
		/obj/item/suppressor, // 5TC
		/obj/item/storage/box/syndie_kit/stechkin, // 26TC. 20TC for stechkin, plus the 2 mags at 3TC
		/obj/item/ammo_box/magazine/m10mm/ap, // 6TC
		/obj/item/ammo_box/magazine/m10mm/ap, // 6TC
		/obj/item/clothing/under/suit/really_black, // 0TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/clothing/suit/storage/iaa/blackjacket/armored, // 3TC
		/obj/item/storage/box/syndie_kit/emp, // 10TC
		/obj/item/clothing/glasses/hud/security/chameleon, // 10TC
		/obj/item/encryptionkey/syndicate, // 10TC
		/obj/item/reagent_containers/drinks/drinkingglass/alliescocktail, // 0TC
		/obj/item/storage/box/syndie_kit/pen_bomb, // 30 TC
		/obj/item/cqc_manual) // 50tc

/// 145TC + RCD & Mesons Autoimplanter
/obj/item/storage/box/syndie_kit/bundle/infiltrator
	name = "Infiltration Bundle"
	desc = "Use your teleporter, krav maga and other support tools to jump right into your desired location, quickly leaving as though you were never there."
	items = list(
		/obj/item/storage/box/syndie_kit/teleporter, // 40TC
		/obj/item/clothing/gloves/color/black/krav_maga, // 50TC
		/obj/item/clothing/glasses/chameleon/thermal, // 15TC
		/obj/item/pinpointer/advpinpointer, // 10TC
		/obj/item/rcd/preloaded, // 0TC
		/obj/item/storage/box/syndie_kit/space, // 20TC
		/obj/item/autosurgeon/organ/syndicate/oneuse/meson_eyes, // 0TC
		/obj/item/encryptionkey/syndicate) // 10TC

/// 188TC
/obj/item/storage/box/syndie_kit/bundle/payday
	name = "Heist Bundle"
	desc = "Alright guys, today we're performing a heist on a space station owned by a greedy corporation. Drain the vault of all its worth so we can get that pay dirt!11"
	items = list(
		/obj/item/gun/projectile/revolver, // 65 TC
		/obj/item/ammo_box/a357, // 15 TC
		/obj/item/ammo_box/a357, // 15 TC
		/obj/item/card/emag, // 30 TC
		/obj/item/jammer, // 20 TC
		/obj/item/card/id/syndicate, // 10 TC
		/obj/item/clothing/under/suit/really_black, // 0TC
		/obj/item/clothing/suit/storage/iaa/blackjacket/armored, // 3TC
		/obj/item/clothing/gloves/color/latex/nitrile, // 0TC
		/obj/item/clothing/mask/gas/clown_hat, // 0TC
		/obj/item/grenade/plastic/c4, // 5 TC
		/obj/item/thermal_drill/diamond_drill/syndicate, // 5 TC
		/obj/item/bio_chip_implanter/freedom/prototype, // 10 TC
		/obj/item/encryptionkey/syndicate) // 10TC

/// 175TC
/obj/item/storage/box/syndie_kit/bundle/implant
	name = "Bio-chip Bundle"
	desc = "A few useful bio-chips to give you some options for when you inevitably get captured by the Security."
	items = list(
		/obj/item/bio_chip_implanter/freedom, // 25TC
		/obj/item/bio_chip_implanter/stealth, // 45 TC
		/obj/item/bio_chip_implanter/emp, // 5TC (half of EMP kit)
		/obj/item/bio_chip_implanter/adrenalin, // 40TC
		/obj/item/bio_chip_implanter/explosive, // 10TC
		/obj/item/bio_chip_implanter/storage, // 40TC
		/obj/item/encryptionkey/syndicate) // 10TC

/// 200TC
/obj/item/storage/box/syndie_kit/bundle/hacker
	name = "Hacker Bundle"
	desc = "A kit with everything you need to hack into and disrupt the Station, AI, its cyborgs and the Security team. HACK THE PLANET!"
	items = list(
		/obj/item/autosurgeon/organ/syndicate/oneuse/razorwire, // 20TC
		/obj/item/autosurgeon/organ/syndicate/oneuse/hackerman_deck, // 30TC
		/obj/item/door_remote/omni/access_tuner, // 30TC, HACK EVERYTHING
		/obj/item/encryptionkey/syndicate, // 10TC
		/obj/item/encryptionkey/binary, // 25TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/storage/box/syndie_kit/emp, // 10TC
		/obj/item/ai_module/toy_ai, // 0TC
		/obj/item/ai_module/syndicate, // 15TC
		/obj/item/storage/box/syndie_kit/camera_bug, // 5TC
		/obj/item/bio_chip_implanter/freedom/prototype, // 10TC
		/obj/item/storage/belt/military/traitor/hacker, // 15TC + AI detector for 5 TC
		/obj/item/clothing/gloves/combat, // accounted in belt + toolbox
		/obj/item/flashlight/emp) // 20TC

/// 170TC + Telekinesis
/obj/item/storage/box/syndie_kit/bundle/darklord
	name = "Dark Lord Bundle"
	desc = "Turn your anger into hate and your hate into suffering with a mix of energy swords and magical powers. DO IT."
	items = list(
		/obj/item/melee/energy/sword/saber/red, // 40TC
		/obj/item/melee/energy/sword/saber/red, // 40TC
		/obj/item/bio_chip_implanter/shock, // 50TC
		/obj/item/dnainjector/telemut/darkbundle, // 0TC
		/obj/item/clothing/suit/hooded/chaplain_cassock, // 0TC
		/obj/item/clothing/glasses/meson/engine/atmos, // 0TC
		/obj/item/clothing/mask/chameleon/voice_change, // 10TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/clothing/shoes/chameleon/noslip, // 10TC
		/obj/item/encryptionkey/syndicate) // 10TC

/// 164TC
/obj/item/storage/box/syndie_kit/bundle/professional
	name = "Sniper Bundle"
	desc = "Suit up and handle yourself like a professional with a long-distance sniper rifle, additional .50 standard and penetrator rounds and thermal glasses to easily scope out your target."
	items = list(
		/obj/item/gun/projectile/automatic/sniper_rifle/syndicate, // 80TC
		/obj/item/ammo_box/magazine/sniper_rounds, // 15TC
		/obj/item/ammo_box/magazine/sniper_rounds/penetrator, // 20TC
		/obj/item/ammo_box/magazine/sniper_rounds/penetrator, // 20TC
		/obj/item/clothing/glasses/chameleon/thermal, // 15TC
		/obj/item/clothing/gloves/combat, // ~1TC
		/obj/item/clothing/under/suit/really_black, // 0TC
		/obj/item/clothing/suit/storage/iaa/blackjacket/armored, // 3TC
		/obj/item/encryptionkey/syndicate) // 10TC

/// 215TC + Tactical Grenadier Belt
/obj/item/storage/box/syndie_kit/bundle/grenadier
	name = "Grenade Bundle"
	desc = "A variety of grenades and pyrotechnics to ensure you can blast your way through any situation."
	items = list(
		/obj/item/storage/belt/grenade/tactical, // ~60TC Contains 2 Frag and EMP grenades, 5 C4 Explosives, 5 Smoke and Gluon grenades and 1 Minibomb grenade
		/obj/item/storage/box/syndie_kit/stechkin, // 26TC. 20TC for stechkin, plus the 2 mags at 3TC
		/obj/item/ammo_box/magazine/m10mm/fire, // 9TC
		/obj/item/ammo_box/magazine/m10mm/fire, // 9TC
		/obj/item/mod/control/pre_equipped/traitor, // 30TC
		/obj/item/clothing/gloves/combat, // ~1TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/clothing/shoes/chameleon/noslip, // 10TC
		/obj/item/storage/box/syndidonkpockets, // 10 TC
		/obj/item/storage/box/syndie_kit/frag_grenades, // 40tc
		/obj/item/encryptionkey/syndicate) // 10TC

/// 80TC + modules + laser gun
/obj/item/storage/box/syndie_kit/bundle/metroid
	name = "Modsuit Bundle"
	desc = "Don the equipment of an interstellar bounty hunter and blast your way through the station!"
	items = list(
		/obj/item/mod/control/pre_equipped/traitor_elite, // 45TC
		/obj/item/mod/module/visor/thermal, // 15TC
		/obj/item/mod/module/stealth, // 0TC
		/obj/item/mod/module/power_kick, // 0TC
		/obj/item/mod/module/sphere_transform, // 0TC
		/obj/item/autosurgeon/organ/syndicate/oneuse/laser_arm, // 0TC
		/obj/item/pinpointer/advpinpointer, // 10TC
		/obj/item/autosurgeon/organ/syndicate/oneuse/hardened_heart, // 0TC decent stamina regen, but no speed/healing.
		/obj/item/storage/belt/utility/full/multitool, // 0TC
		/obj/item/clothing/head/collectable/slime,  // 0TC priceless
		/obj/item/encryptionkey/syndicate) // 10TC

// 170 TC + combat knife + outfit
/obj/item/storage/box/syndie_kit/bundle/ocelot
	name = "Ocelot Bundle"
	desc = "Get pretty good with two revolvers, two speedloaders, and a backup combat knife."
	items = list(
		/obj/item/kitchen/knife/combat, // 0TC but very robust
		/obj/item/gun/projectile/revolver,  // 65TC
		/obj/item/gun/projectile/revolver,  // 65TC
		/obj/item/ammo_box/a357, // 15TC
		/obj/item/ammo_box/a357, // 15TC
		/obj/item/encryptionkey/syndicate, // 10TC
		/obj/item/clothing/under/syndicate/combat, //0TC
		/obj/item/clothing/accessory/holster, // 0TC
		/obj/item/clothing/neck/scarf/red, //0TC
		/obj/item/clothing/head/beret, // 0TC
		/obj/item/clothing/gloves/combat, // 0TC
		/obj/item/clothing/shoes/combat) // 0TC

// 147 TC
/obj/item/storage/box/syndie_kit/bundle/operative
	name = "\"Operative\" Bundle"
	desc = "Glory to the Syndicate! Only the essentials for destroying Nanotrasen in this important kit."
	items = list(
		/obj/item/mod/control/pre_equipped/traitor, // 30TC
		/obj/item/card/id/syndi_scan_only, // ~2TC?
		/obj/item/encryptionkey/syndicate, // 10tc
		/obj/item/melee/energy/sword/saber/red, // 40TC
		/obj/item/shield/energy, // 40TC
		/obj/item/pinpointer/advpinpointer, // 10TC, get dat fuckin disk
		/obj/item/storage/belt/military, // 10TC
		/obj/item/grenade/plastic/c4, // 5TC
		/obj/item/bio_chip_implanter/proto_adrenalin, // 10TC
		/obj/item/toy/figure/crew/syndie, // 0TC
		/obj/item/clothing/under/syndicate // 0TC
	)

// 250 TC worth of credits
/obj/item/storage/box/syndie_kit/bundle/rich
	name = "Big Spender Bundle"
	desc = "It's money. I don't need to explain more."
	items = list(
		/obj/item/clothing/under/suit/really_black, // 0TC
		/obj/item/clothing/shoes/laceup, // 0TC
		/obj/item/clothing/glasses/monocle, // 0TC
		/obj/item/clothing/gloves/color/white, // 0TC
		/obj/item/clothing/head/that, // 0TC
		/obj/item/storage/secure/briefcase, // 0TC
		// syndie briefcase has 600 credits for 5 TC.
		/obj/item/stack/spacecash/c10000,
		/obj/item/stack/spacecash/c10000,
		/obj/item/stack/spacecash/c10000
	)

// 209 TC of maint loot, higher than other bundles because it doesn't combo well
/obj/item/storage/box/syndie_kit/bundle/maint_loot
	name = "Maintenance Loot Bundle"
	desc = "One of our interns found all of this lying in a Nanotrasen Maintenance tunnels. Reduce, Reuse, Recycle!"
	items = list(
		/obj/item/storage/bag/plasticbag, // 1TC
		/obj/item/grenade/clown_grenade, // 15TC
		/obj/item/seeds/ambrosia/cruciatus, // 5TC
		/obj/item/gun/projectile/automatic/pistol, // 20TC
		/obj/item/ammo_box/magazine/m10mm, // 3TC
		/obj/item/soap/syndie, // 5TC
		/obj/item/suppressor, // 5TC
		/obj/item/clothing/under/chameleon, // 1TC. 10TC divided over 10 items.
		/obj/item/clothing/shoes/chameleon/noslip, // 10TC
		/obj/item/clothing/mask/chameleon/voice_change, // 10TC
		/obj/item/dnascrambler, // 7TC
		/obj/item/storage/backpack/satchel_flat, // 10TC
		/obj/item/storage/toolbox/syndicate, // 5TC
		/obj/item/storage/backpack/duffel/syndie/med/surgery, // 10TC
		/obj/item/storage/belt/military/traitor, // 10TC
		/obj/item/storage/box/syndie_kit/space, // 20TC
		/obj/item/multitool/ai_detect, // 5TC
		/obj/item/bio_chip_implanter/storage, // 40TC
		/obj/item/deck/cards/syndicate, // 2TC
		/obj/item/storage/secure/briefcase/syndie, // 5TC
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate, // 7TC
		/obj/item/clothing/suit/jacket/bomber/syndicate, // 3TC
		/obj/item/melee/knuckleduster/syndie, // 10TC
	)

/obj/item/storage/box/syndie_kit/bundle/populate_contents()
	for(var/obj/item/item as anything in items)
		new item(src)

/obj/item/storage/box/syndie_kit/space
	name = "Boxed Space Suit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/syndicate/black/red, /obj/item/clothing/head/helmet/space/syndicate/black/red, /obj/item/tank/internals/emergency_oxygen/engi/syndi, /obj/item/clothing/mask/gas/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/space/populate_contents()
	new /obj/item/clothing/suit/space/syndicate/black/red(src)
	new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)

/obj/item/storage/box/syndie_kit/conversion
	name = "box (CK)"

/obj/item/storage/box/syndie_kit/boolets
	name = "shotgun shells"

/obj/item/storage/box/syndie_kit/boolets/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)

/obj/item/storage/box/syndie_kit/emp
	name = "boxed EMP kit"

/obj/item/storage/box/syndie_kit/emp/populate_contents()
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/bio_chip_implanter/emp/(src)

/obj/item/storage/box/syndie_kit/poisoner
	name = "poisoner's kit"

/obj/item/storage/box/syndie_kit/poisoner/populate_contents()
	new /obj/item/pen/multi/poison(src)
	new /obj/item/clothing/gloves/color/black/poisoner(src)

/obj/item/storage/box/syndie_kit/c4
	name = "pack of C-4 explosives"

/obj/item/storage/box/syndie_kit/c4/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/plastic/c4(src)

/obj/item/storage/box/syndie_kit/frag_grenades
	name = "pack of fragmentation grenades"

/obj/item/storage/box/syndie_kit/frag_grenades/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/frag(src)

/obj/item/storage/box/syndie_kit/throwing_weapons
	name = "boxed throwing kit"
	can_hold = list(/obj/item/throwing_star, /obj/item/restraints/legcuffs/bola/tactical)
	max_combined_w_class = 16
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/throwing_weapons/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/throwing_star(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)

/obj/item/storage/box/syndie_kit/sarin
	name = "sarin gas grenades"

/obj/item/storage/box/syndie_kit/sarin/populate_contents()
	new /obj/item/grenade/chem_grenade/saringas(src)
	new /obj/item/grenade/chem_grenade/saringas(src)
	new /obj/item/grenade/chem_grenade/saringas(src)
	new /obj/item/grenade/chem_grenade/saringas(src)

/obj/item/storage/box/syndie_kit/bioterror
	name = "bioterror syringe box"

/obj/item/storage/box/syndie_kit/bioterror/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/syringe/bioterror(src)

/obj/item/storage/box/syndie_kit/caneshotgun
	name = "cane gun kit"


/obj/item/storage/box/syndie_kit/caneshotgun/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/ammo_casing/shotgun/assassination(src)
	new /obj/item/gun/projectile/revolver/doublebarrel/improvised/cane(src)

/obj/item/storage/box/syndie_kit/fake_minibomb
	name = "trick minibomb kit"

/obj/item/storage/box/syndie_kit/fake_minibomb/populate_contents()
	new /obj/item/grenade/syndieminibomb/fake(src)

/obj/item/storage/box/syndie_kit/fake_revolver
	name = "trick revolver kit"

/obj/item/storage/box/syndie_kit/fake_revolver/populate_contents()
	new /obj/item/gun/projectile/revolver/fake(src)

/obj/item/storage/box/syndie_kit/mimery
	name = "advanced mimery kit"

/obj/item/storage/box/syndie_kit/mimery/populate_contents()
	new /obj/item/spellbook/oneuse/mime/greaterwall(src)
	new	/obj/item/spellbook/oneuse/mime/fingergun(src)

/obj/item/storage/box/syndie_kit/combat_baking
	name = "combat bakery kit"

/obj/item/storage/box/syndie_kit/combat_baking/populate_contents()
	new /obj/item/food/baguette/combat(src)
	for(var/i in 1 to 2)
		new /obj/item/food/croissant/throwing(src)
	new /obj/item/book/granter/crafting_recipe/combat_baking(src)

/obj/item/storage/box/syndie_kit/atmosn2ogrenades
	name = "atmos N2O grenades"

/obj/item/storage/box/syndie_kit/atmosn2ogrenades/populate_contents()
	new /obj/item/grenade/clusterbuster/n2o(src)
	new /obj/item/grenade/clusterbuster/n2o(src)


/obj/item/storage/box/syndie_kit/atmosfiregrenades
	name = "plasma fire grenades"

/obj/item/storage/box/syndie_kit/atmosfiregrenades/populate_contents()
	new /obj/item/grenade/clusterbuster/plasma(src)
	new /obj/item/grenade/clusterbuster/plasma(src)


/obj/item/storage/box/syndie_kit/missionary_set
	name = "Missionary Starter Kit"

/obj/item/storage/box/syndie_kit/missionary_set/populate_contents()
	new /obj/item/nullrod/missionary_staff(src)
	new /obj/item/clothing/suit/hooded/chaplain_cassock/missionary_robe(src)
	var/obj/item/storage/bible/B = new /obj/item/storage/bible(src)
	if(prob(25))	//an omen of success to come?
		B.deity_name = "Success"
		B.icon_state = "greentext"
		B.inhand_icon_state = "greentext"

/obj/item/storage/box/syndie_kit/cutouts
	name = "Fortified Artistic Box"

/obj/item/storage/box/syndie_kit/cutouts/populate_contents()
	for(var/i in 1 to 3)
		new/obj/item/cardboard_cutout/adaptive(src)
	new/obj/item/toy/crayon/spraycan(src)

/obj/item/storage/box/syndie_kit/safecracking
	name = "Safe-cracking Kit"
	desc = "Everything you need to quietly open a mechanical combination safe."

/obj/item/storage/box/syndie_kit/safecracking/populate_contents()
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/mask/balaclava(src)
	new /obj/item/clothing/neck/stethoscope(src)
	new /obj/item/book/manual/wiki/hacking(src)

/obj/item/storage/box/syndie_kit/chameleon
	name = "chameleon kit"

/obj/item/storage/box/syndie_kit/chameleon/populate_contents()
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/clothing/head/chameleon(src)
	new /obj/item/storage/backpack/chameleon(src)
	new /obj/item/radio/headset/chameleon(src)
	new /obj/item/pda/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/clothing/neck/chameleon(src)

/obj/item/storage/box/syndie_kit/chameleon/nuke
	name = "operative's chameleon kit"

/obj/item/storage/box/syndie_kit/chameleon/nuke/populate_contents()
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/clothing/head/chameleon(src)
	new /obj/item/storage/backpack/chameleon(src)
	new /obj/item/radio/headset/chameleon(src)
	new /obj/item/pda/chameleon(src)
	new /obj/item/stamp/chameleon(src)
	new /obj/item/clothing/mask/chameleon/voice_change(src)
	new /obj/item/clothing/neck/chameleon(src)

/obj/item/storage/box/syndie_kit/dart_gun
	name = "dart gun kit"

/obj/item/storage/box/syndie_kit/dart_gun/populate_contents()
	new /obj/item/gun/syringe/syndicate(src)
	new /obj/item/reagent_containers/syringe/capulettium_plus(src)
	new /obj/item/reagent_containers/syringe/sarin(src)
	new /obj/item/reagent_containers/syringe/pancuronium(src)

/obj/item/storage/box/syndie_kit/nuke
	desc = "It's just an ordinary box."
	icon_state = "box"

/obj/item/storage/box/syndie_kit/nuke/populate_contents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/nuke_core_container(src)
	new /obj/item/paper/guides/antag/nuke_instructions(src)

/obj/item/storage/box/syndie_kit/supermatter
	desc = "It's just an ordinary box."
	icon_state = "box"

/obj/item/storage/box/syndie_kit/supermatter/populate_contents()
	new /obj/item/scalpel/supermatter(src)
	new /obj/item/retractor/supermatter(src)
	new /obj/item/nuke_core_container/supermatter(src)
	new /obj/item/paper/guides/antag/supermatter_sliver(src)

/obj/item/storage/box/syndie_kit/anomalous_particulate

	desc = "It's just an ordinary box."
	icon_state = "box"

/obj/item/storage/box/syndie_kit/anomalous_particulate/populate_contents()
	new /obj/item/ppp_processor(src)
	new /obj/item/clothing/glasses/hud/anomalous(src)
	new /obj/item/paper/guides/antag/anomalous_particulate(src)

/obj/item/storage/box/syndie_kit/revolver
	name = "\improper .357 revolver kit"

/obj/item/storage/box/syndie_kit/revolver/populate_contents()
	new /obj/item/gun/projectile/revolver(src)
	new /obj/item/ammo_box/a357(src)

/obj/item/storage/box/syndie_kit/stechkin
	name = "\improper FK-69 Stechkin kit"
	desc = "A box marked with Cygni Standard characters. It appears to contain a 10mm pistol and two magazines."

/obj/item/storage/box/syndie_kit/stechkin/populate_contents()
	new /obj/item/gun/projectile/automatic/pistol(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)

/obj/item/storage/box/syndie_kit/camera_bug
	name = "\improper Camera Bug kit"

/obj/item/storage/box/syndie_kit/camera_bug/populate_contents()
	var/camera = new /obj/item/camera_bug(src)
	new /obj/item/paper/camera_bug(src)
	for(var/i in 1 to 5)
		new /obj/item/wall_bug(src, camera)

/obj/item/storage/box/syndie_kit/prescan
	name = "\improper Technocracy Advanced Cloning System Kit"

/obj/item/storage/box/syndie_kit/prescan/populate_contents()
	new /obj/item/bio_chip_implanter/grey_autocloner(src)
	new /obj/item/beacon/syndicate/bomb/grey_autocloner(src)

/obj/item/storage/box/syndie_kit/pen_bomb
	name = "\improper Pen bomb"

/obj/item/storage/box/syndie_kit/pen_bomb/populate_contents()
	new /obj/item/grenade/syndieminibomb/pen(src)

/obj/item/storage/box/syndie_kit/chemical_canister
	name = "\improper Chemical flamethrower canisters"

/obj/item/storage/box/syndie_kit/chemical_canister/populate_contents()
	new /obj/item/chemical_canister/extended/nuclear(src)
	new /obj/item/chemical_canister/extended/nuclear(src)

/obj/item/storage/box/syndie_kit/decoy
	name = "\improper Decoy Grenade kit"

/obj/item/storage/box/syndie_kit/decoy/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/firecracker/decoy(src)

/obj/item/storage/box/syndie_kit/forgers_kit
	name = "\improper Forger's kit"

/obj/item/storage/box/syndie_kit/forgers_kit/populate_contents()
	new /obj/item/stamp/chameleon(src)
	new /obj/item/pen/chameleon(src)

/obj/item/storage/box/syndie_kit/syndie_mantis
	name = "\improper Mantis Blades kit"
	desc = "A sleek box marked with a Cybersun logo. The label says it contains a pair of CX-12 'Naginata' mantis blades and accompanying autosurgeons."

/obj/item/storage/box/syndie_kit/syndie_mantis/populate_contents()
	new /obj/item/autosurgeon/organ/syndicate/oneuse/syndie_mantis(src)
	new /obj/item/autosurgeon/organ/syndicate/oneuse/syndie_mantis/l(src)

