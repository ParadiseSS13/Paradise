/obj/item/storage/box/syndie_kit
	desc = "A sleek, sturdy box."
	icon_state = "doom_box"

/obj/item/storage/box/syndie_kit/bundle // Traitor bundles
	var/list/items = list()

/obj/item/storage/box/syndie_kit/bundle/spy // 172TC
	name = "Spy Bundle"
	desc = "Complete your objectives quietly with this compilation of stealthy items."
	items = list(
		/obj/item/storage/box/syndie_kit/chameleon, // 20 TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/clothing/shoes/chameleon/noslip, // 10TC
		/obj/item/clothing/glasses/hud/security/chameleon, // 10TC
		/obj/item/bio_chip_implanter/storage, // 40TC
		/obj/item/pen/edagger, // 10TC
		/obj/item/pinpointer/advpinpointer, // 20TC
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate, // 7TC
		/obj/item/flashlight/emp, // 20TC
		/obj/item/chameleon, // 25TC
		/obj/item/garrote, // 30 TC
		/obj/item/door_remote/omni/access_tuner, // 30 TC
		/obj/item/encryptionkey/syndicate) // 10TC

/obj/item/storage/box/syndie_kit/bundle/agent13 // 159
	name = "Agent 13 Bundle"
	desc = "Find and eliminate your targets quietly and effectively with this kit."
	items = list(
		/obj/item/clothing/under/chameleon, // 5TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/storage/box/syndie_kit/stechkin, // 20TC
		/obj/item/suppressor, // 5TC
		/obj/item/ammo_box/magazine/m10mm,  // 3TC
		/obj/item/ammo_box/magazine/m10mm/hp, // 6TC
		/obj/item/garrote, // 30TC
		/obj/item/door_remote/omni/access_tuner, // 30TC
		/obj/item/clothing/glasses/chameleon/thermal, // 15TC
		/obj/item/storage/briefcase/false_bottomed, // 10 TC
		/obj/item/bio_chip_implanter/freedom, // 25TC
		/obj/item/coin/gold, // 0TC
		/obj/item/encryptionkey/syndicate) // 10TC

/obj/item/storage/box/syndie_kit/bundle/thief // 160TC
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

/obj/item/storage/box/syndie_kit/bundle/bond // 137TC
	name = "Agent 007 Bundle"
	desc = "Shake your Martini and stir up trouble with this bundle of lethal equipment mixed with a spritz of gadgetry to keep things interesting."
	items = list(
		/obj/item/storage/briefcase/false_bottomed, // 20TC
		/obj/item/suppressor, // 5TC
		/obj/item/storage/box/syndie_kit/stechkin, // 20TC
		/obj/item/ammo_box/magazine/m10mm/ap, // 6TC
		/obj/item/ammo_box/magazine/m10mm/ap, // 6TC
		/obj/item/clothing/under/suit/really_black, // 0TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/clothing/suit/storage/iaa/blackjacket/armored, // 3TC
		/obj/item/storage/box/syndie_kit/emp, // 10TC
		/obj/item/clothing/glasses/hud/security/chameleon, // 10TC
		/obj/item/encryptionkey/syndicate, // 10TC
		/obj/item/reagent_containers/drinks/drinkingglass/alliescocktail,	// 0TC
		/obj/item/storage/box/syndie_kit/pen_bomb, // 30 TC
		/obj/item/CQC_manual) // 13TC

/obj/item/storage/box/syndie_kit/bundle/infiltrator // 155TC + RCD & Mesons Autoimplanter
	name = "Infiltration Bundle"
	desc = "Use your teleporter, krav maga and other support tools to jump right into your desired location, quickly leaving as though you were never there."
	items = list(
		/obj/item/storage/box/syndie_kit/teleporter, // 8TC
		/obj/item/clothing/gloves/color/black/krav_maga, // 10TC
		/obj/item/clothing/glasses/chameleon/thermal, // 6TC
		/obj/item/pinpointer/advpinpointer, // 4TC
		/obj/item/rcd/preloaded, // 0TC
		/obj/item/storage/box/syndie_kit/space, // 4TC
		/obj/item/autosurgeon/organ/syndicate/meson_eyes, // 0TC
		/obj/item/encryptionkey/syndicate) // 2TC

/obj/item/storage/box/syndie_kit/bundle/payday // 175TC
	name = "Heist Bundle"
	desc = "Alright guys, today we're performing a heist on a space station owned by a greedy corporation. Drain the vault of all its worth so we can get that pay dirt!11"
	items = list(
		/obj/item/gun/projectile/revolver, // 13TC
		/obj/item/ammo_box/a357, // 3TC
		/obj/item/ammo_box/a357, // 3TC
		/obj/item/card/emag, // 6TC
		/obj/item/jammer, // 4TC
		/obj/item/card/id/syndicate, // 2TC
		/obj/item/clothing/under/suit/really_black, // 0TC
		/obj/item/clothing/suit/storage/iaa/blackjacket/armored, // 0TC
		/obj/item/clothing/gloves/color/latex/nitrile, // 0 TC
		/obj/item/clothing/mask/gas/clown_hat, // 0TC
		/obj/item/grenade/plastic/c4, // 1TC
		/obj/item/thermal_drill/diamond_drill/syndicate, // 1TC
		/obj/item/bio_chip_implanter/freedom/prototype, // 10 TC
		/obj/item/encryptionkey/syndicate) // 10TC

/obj/item/storage/box/syndie_kit/bundle/implant // 200TC
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

/obj/item/storage/box/syndie_kit/bundle/hacker // 180TC
	name = "Hacker Bundle"
	desc = "A kit with everything you need to hack into and disrupt the Station, AI, its cyborgs and the Security team. HACK THE PLANET!"
	items = list(
		/obj/item/melee/energy/sword/saber/blue, // 40TC
		/obj/item/card/emag, // 30TC
		/obj/item/door_remote/omni/access_tuner, // 30 TC, HACK EVERYTHING
		/obj/item/encryptionkey/syndicate, // 10TC
		/obj/item/encryptionkey/binary, // 25TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/storage/box/syndie_kit/emp, // 10TC
		/obj/item/aiModule/toyAI, // 0TC
		/obj/item/aiModule/syndicate, // 15 TC
		/obj/item/storage/box/syndie_kit/camera_bug, // 5 TC
		/obj/item/bio_chip_implanter/freedom/prototype, // 10 TC
		/obj/item/storage/belt/military/traitor/hacker, // 15TC + AI detector for 5 TC
		/obj/item/clothing/gloves/combat, // accounted in belt + toolbox
		/obj/item/flashlight/emp) // 4TC

/obj/item/storage/box/syndie_kit/bundle/darklord // 168TC + Telekinesis
	name = "Dark Lord Bundle"
	desc = "Turn your anger into hate and your hate into suffering with a mix of energy swords and magical powers. DO IT."
	items = list(
		/obj/item/melee/energy/sword/saber/red, // 40TC
		/obj/item/melee/energy/sword/saber/red, // 40TC
		/obj/item/bio_chip_implanter/shock, // 50TC
		/obj/item/dnainjector/telemut/darkbundle, // ?TC
		/obj/item/clothing/suit/hooded/chaplain_hoodie, // 0TC
		/obj/item/clothing/glasses/meson/engine/tray, // 0TC
		/obj/item/clothing/mask/chameleon, // 8TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/clothing/shoes/chameleon/noslip, // 10TC
		/obj/item/encryptionkey/syndicate) // 10TC

/obj/item/storage/box/syndie_kit/bundle/professional // 164TC
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
		/obj/item/encryptionkey/syndicate) // 15TC

/obj/item/storage/box/syndie_kit/bundle/grenadier // 133TC + Tactical Grenadier Belt
	name = "Grenade Bundle"
	desc = "A variety of grenades and pyrotechnics to ensure you can blast your way through any situation. "
	items = list(
		/obj/item/storage/belt/grenade/tactical, // Contains 2 Frag and EMP grenades, 5 C4 Explosives, 5 Smoke and Gluon grenades and 1 Minibomb grenade ~20TC Estimate
		/obj/item/storage/box/syndie_kit/stechkin, // 20TC
		/obj/item/ammo_box/magazine/m10mm/fire, // 6TC
		/obj/item/ammo_box/magazine/m10mm/fire, // 6TC
		/obj/item/mod/control/pre_equipped/traitor, // 30TC
		/obj/item/clothing/gloves/combat, // ~1TC
		/obj/item/card/id/syndicate, // 10TC
		/obj/item/clothing/shoes/chameleon/noslip, // 10TC
		/obj/item/storage/box/syndidonkpockets, // 10 TC
		/obj/item/storage/box/syndie_kit/frag_grenades, // One box, as a treat
		/obj/item/encryptionkey/syndicate) // 10TC

/obj/item/storage/box/syndie_kit/bundle/metroid // 115TC + modules + laser gun
	name = "Modsuit Bundle"
	desc = "Don the equipment of an intergalactic bounty hunter and blast your way through the station!"
	items = list(
		/obj/item/mod/control/pre_equipped/traitor_elite, // 45TC
		/obj/item/mod/module/visor/thermal, // 15TC
		/obj/item/mod/module/stealth, // ?TC
		/obj/item/mod/module/power_kick, // ?TC
		/obj/item/mod/module/sphere_transform, // ?TC
		/obj/item/autosurgeon/organ/syndicate/laser_arm, // ?TC
		/obj/item/pinpointer/advpinpointer, // 20TC
		/obj/item/bio_chip_implanter/adrenalin, // 40TC
		/obj/item/storage/belt/utility/full/multitool, // 15TC
		/obj/item/clothing/head/collectable/slime,  // 0TC priceless
		/obj/item/encryptionkey/syndicate) // 10TC

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
	new /obj/item/food/snacks/baguette/combat(src)
	for(var/i in 1 to 2)
		new /obj/item/food/snacks/croissant/throwing(src)
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
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe(src)
	var/obj/item/storage/bible/B = new /obj/item/storage/bible(src)
	if(prob(25))	//an omen of success to come?
		B.deity_name = "Success"
		B.icon_state = "greentext"
		B.item_state = "greentext"


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
	new /obj/item/clothing/accessory/stethoscope(src)
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
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/storage/backpack/chameleon(src)
	new /obj/item/radio/headset/chameleon(src)
	new /obj/item/stamp/chameleon(src)
	new /obj/item/pda/chameleon(src)

/obj/item/storage/box/syndie_kit/dart_gun
	name = "dart gun kit"

/obj/item/storage/box/syndie_kit/dart_gun/populate_contents()
	new /obj/item/gun/syringe/syndicate(src)
	new /obj/item/reagent_containers/syringe/capulettium_plus(src)
	new /obj/item/reagent_containers/syringe/sarin(src)
	new /obj/item/reagent_containers/syringe/pancuronium(src)

/obj/item/storage/box/syndie_kit/nuke
	name = "box"  //Bit of stealth, since you spawn with it
	desc = "It's just an ordinary box."
	icon_state = "box"

/obj/item/storage/box/syndie_kit/nuke/populate_contents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/nuke_core_container(src)
	new /obj/item/paper/guides/antag/nuke_instructions(src)

/obj/item/storage/box/syndie_kit/supermatter
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"

/obj/item/storage/box/syndie_kit/supermatter/populate_contents()
	new /obj/item/scalpel/supermatter(src)
	new /obj/item/retractor/supermatter(src)
	new /obj/item/nuke_core_container/supermatter(src)
	new /obj/item/paper/guides/antag/supermatter_sliver(src)

/obj/item/storage/box/syndie_kit/revolver
	name = "\improper .357 revolver kit"

/obj/item/storage/box/syndie_kit/revolver/populate_contents()
	new /obj/item/gun/projectile/revolver(src)
	new /obj/item/ammo_box/a357(src)

/obj/item/storage/box/syndie_kit/stechkin
	name = "\improper FK-69 Stechkin kit"
	desc = "A box marked with Neo-Russkiyan characters. It appears to contain a 10mm pistol and two magazines."

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
	new /obj/item/radio/beacon/syndicate/bomb/grey_autocloner(src)

/obj/item/storage/box/syndie_kit/pen_bomb
	name = "\improper Pen bomb"

/obj/item/storage/box/syndie_kit/pen_bomb/populate_contents()
	new /obj/item/grenade/syndieminibomb/pen(src)
