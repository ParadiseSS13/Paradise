/obj/item/storage/box/syndicate
	var/static/list/spy = list( // 37TC + one 0TC
		/obj/item/clothing/under/chameleon, // 2TC
		/obj/item/clothing/mask/chameleon, // 0TC
		/obj/item/card/id/syndicate, // 2TC
		/obj/item/clothing/shoes/chameleon/noslip, // 2TC
		/obj/item/camera_bug, // 1TC
		/obj/item/multitool/ai_detect, // 1TC
		/obj/item/encryptionkey/syndicate, // 2TC
		/obj/item/twohanded/garrote, // 10TC
		/obj/item/pinpointer/advpinpointer, // 4TC
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate, // 2TC
		/obj/item/flashlight/emp, // 2TC
		/obj/item/clothing/glasses/hud/security/chameleon, // 2TC
		/obj/item/chameleon) // 7TC

	var/static/list/thief = list( // 39TC
		/obj/item/gun/energy/kinetic_accelerator/crossbow, // 12TC
		/obj/item/chameleon, // 7TC
		/obj/item/clothing/glasses/chameleon/thermal, // 6TC
		/obj/item/clothing/gloves/color/black/thief, // 6TC
		/obj/item/card/id/syndicate, // 2TC
		/obj/item/clothing/shoes/chameleon/noslip, // 2TC
		/obj/item/storage/backpack/satchel_flat, // 2TC
		/obj/item/encryptionkey/syndicate) // 2TC

	var/static/list/bond = list( // 33TC + three 0TC
		/obj/item/gun/projectile/automatic/pistol, // 4TC
		/obj/item/suppressor, // 1TC
		/obj/item/ammo_box/magazine/m10mm/hp,  // 3TC
		/obj/item/ammo_box/magazine/m10mm/ap, // 2TC
		/obj/item/clothing/under/suit_jacket/really_black, // 0TC
		/obj/item/card/id/syndicate, // 2TC
		/obj/item/clothing/suit/storage/lawyer/blackjacket/armored, // 0TC
		/obj/item/encryptionkey/syndicate, // 2TC
		/obj/item/reagent_containers/food/drinks/drinkingglass/alliescocktail,	// 0TC
		/obj/item/dnascrambler, // 4TC
		/obj/item/storage/box/syndie_kit/emp, // 2TC
		/obj/item/CQC_manual) // 13TC

	var/static/list/sabotage = list( // 41TC + two 0TC
		/obj/item/grenade/plastic/c4, // 1TC
		/obj/item/grenade/plastic/c4, // 1TC
		/obj/item/camera_bug, // 1TC
		/obj/item/powersink, // 10TC
		/obj/item/cartridge/syndicate, // 6TC
		/obj/item/rcd/preloaded, // 0TC
		/obj/item/card/emag, // 6TC
		/obj/item/clothing/gloves/color/yellow, // 0TC
		/obj/item/grenade/syndieminibomb, // 6TC
		/obj/item/grenade/clusterbuster/n2o, // 4TC
		/obj/item/storage/box/syndie_kit/space, // 4TC
		/obj/item/encryptionkey/syndicate) // 2TC

	var/static/list/payday = list( // 35TC + four 0TC
		/obj/item/gun/projectile/revolver, // 13TC
		/obj/item/ammo_box/a357, // 3TC
		/obj/item/ammo_box/a357, // 3TC
		/obj/item/card/emag, // 6TC
		/obj/item/jammer, // 5TC
		/obj/item/card/id/syndicate, // 2TC
		/obj/item/clothing/under/suit_jacket/really_black, //0TC
		/obj/item/clothing/suit/storage/lawyer/blackjacket/armored, //0TC
		/obj/item/clothing/gloves/color/latex/nitrile, //0 TC
		/obj/item/clothing/mask/gas/clown_hat, // 0TC
		/obj/item/thermal_drill/diamond_drill, // 1TC
		/obj/item/encryptionkey/syndicate) // 2TC

	var/static/list/implant = list( // 39TC + ten free TC
		/obj/item/implanter/freedom, // 5TC
		/obj/item/implanter/uplink, // 14TC (ten free TC)
		/obj/item/implanter/emp, // 0TC
		/obj/item/implanter/adrenalin, // 8TC
		/obj/item/implanter/explosive, // 2TC
		/obj/item/implanter/storage, // 8TC
		/obj/item/encryptionkey/syndicate) // 2TC

	var/static/list/hacker = list( // 37TC + two 0TC
		/obj/item/aiModule/syndicate, // 12TC
		/obj/item/card/emag, // 6TC
		/obj/item/encryptionkey/syndicate, // 2TC
		/obj/item/encryptionkey/binary, // 5TC
		/obj/item/aiModule/toyAI, // 0TC
		/obj/item/clothing/glasses/chameleon/thermal, // 6TC
		/obj/item/storage/belt/military/traitor/hacker, // 3TC
		/obj/item/clothing/gloves/combat, // 0TC
		/obj/item/multitool/ai_detect, // 1TC
		/obj/item/flashlight/emp) // 2TC

	var/static/list/darklord = list( // 24TC + two 0TC
		/obj/item/melee/energy/sword/saber/red, // 8TC
		/obj/item/melee/energy/sword/saber/red, // 8TC
		/obj/item/dnainjector/telemut/darkbundle, // 0TC
		/obj/item/clothing/suit/hooded/chaplain_hoodie, // 0TC
		/obj/item/card/id/syndicate, // 2TC
		/obj/item/clothing/shoes/chameleon/noslip, // 2TC
		/obj/item/clothing/mask/chameleon, // 2TC
		/obj/item/encryptionkey/syndicate) // 2TC

	var/static/list/professional = list( // 34TC + two 0TC
		/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator, // 16TC
		/obj/item/ammo_box/magazine/sniper_rounds/compact/penetrator, // 5TC
		/obj/item/ammo_box/magazine/sniper_rounds/compact/soporific, // 3TC
		/obj/item/clothing/glasses/chameleon/thermal, // 6TC
		/obj/item/clothing/gloves/combat, // 0 TC
		/obj/item/clothing/under/suit_jacket/really_black, // 0 TC
		/obj/item/clothing/suit/storage/lawyer/blackjacket/armored, // 0TC
		/obj/item/pen/edagger, // 2TC
		/obj/item/encryptionkey/syndicate) // 2TC

	var/static/list/secoff = list( // 20 TC + many non-uplink items
		/obj/item/encryptionkey/syndicate, // 2 TC
		/obj/item/card/id/syndicate, // 2 TC
		/obj/item/clothing/glasses/hud/security/chameleon, // 2 TC
		/obj/item/clothing/mask/chameleon,  // In 2 TC bundle (chameleon)
		/obj/item/clothing/accessory/holster,  // 0 TC
		/obj/item/storage/belt/military/traitor/sec,  // 0 TC
		/obj/item/pinpointer/advpinpointer,  // 4 TC
		/obj/item/gun/projectile/automatic/pistol,  // 4 TC
		/obj/item/ammo_box/magazine/m10mm, // 1 TC
		/obj/item/ammo_box/magazine/m10mm/ap,  // 1 TC
		/obj/item/ammo_box/magazine/m10mm/fire,  // 1 TC
		/obj/item/ammo_box/magazine/m10mm/hp,  // 1 TC
		/obj/item/storage/box/sec,  // 0 TC
		/obj/item/restraints/handcuffs,  // 0 TC
		/obj/item/flash) // 0 TC


/obj/item/storage/box/syndicate/populate_contents()
	var/list/bundle = pick(spy, thief, bond, sabotage, payday, implant, hacker, darklord, professional, secoff)
	for(var/item in bundle)
		new item(src)

/obj/item/storage/box/syndie_kit
	name = "Box"
	desc = "A sleek, sturdy box"
	icon_state = "box_of_doom"

/obj/item/storage/box/syndie_kit/mantisblade
	name = "Horlex Mantis blade set"
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/mantisblade/populate_contents()
	new /obj/item/autoimplanter/oneuse/mantisblade(src)
	new /obj/item/autoimplanter/oneuse/mantisblade/l(src)

/obj/item/storage/box/syndie_kit/space
	name = "Boxed Space Suit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/syndicate/black/red, /obj/item/clothing/head/helmet/space/syndicate/black/red, /obj/item/tank/internals/emergency_oxygen/engi/syndi, /obj/item/clothing/mask/gas/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/space/populate_contents()
	new /obj/item/clothing/suit/space/syndicate/black/red(src)
	new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)

/obj/item/storage/box/syndie_kit/hardsuit
	name = "Boxed Blood Red Suit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/hardsuit/syndi, /obj/item/tank/internals/emergency_oxygen/engi/syndi, /obj/item/clothing/mask/gas/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/hardsuit/populate_contents()
	new /obj/item/clothing/suit/space/hardsuit/syndi(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)

/obj/item/storage/box/syndie_kit/conversion
	name = "box (CK)"

/obj/item/storage/box/syndie_kit/conversion/populate_contents()
	new /obj/item/conversion_kit(src)
	new /obj/item/ammo_box/a357(src)

/obj/item/storage/box/syndie_kit/boolets
	name = "Shotgun shells"

/obj/item/storage/box/syndie_kit/boolets/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)

/obj/item/storage/box/syndie_kit/emp
	name = "boxed EMP kit"

/obj/item/storage/box/syndie_kit/emp/populate_contents()
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/implanter/emp/(src)

/obj/item/storage/box/syndie_kit/c4
	name = "Pack of C-4 Explosives"

/obj/item/storage/box/syndie_kit/c4/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/plastic/c4(src)

/obj/item/storage/box/syndie_kit/t4
	name = "Pack of T-4 Explosives"
	desc = "Contains five T4 breaching charges."

/obj/item/storage/box/syndie_kit/t4/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/plastic/x4/thermite(src)

/obj/item/storage/box/syndie_kit/t4P
	name = "Small pack of T-4 Explosives"
	desc = "Contains three T4 breaching charges."

/obj/item/storage/box/syndie_kit/t4P/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/grenade/plastic/x4/thermite(src)

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
	name = "Sarin Gas Grenades"

/obj/item/storage/box/syndie_kit/sarin/populate_contents()
	for(var/I in 1 to 4)
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

/obj/item/storage/box/syndie_kit/fake_revolver
	name = "trick revolver kit"

/obj/item/storage/box/syndie_kit/fake_revolver/populate_contents()
	new /obj/item/toy/russian_revolver/trick_revolver(src)

/obj/item/storage/box/syndie_kit/mimery
	name = "advanced mimery kit"

/obj/item/storage/box/syndie_kit/mimery/populate_contents()
	new /obj/item/spellbook/oneuse/mime/greaterwall(src)
	new	/obj/item/spellbook/oneuse/mime/fingergun(src)
	new /obj/item/mimejutsu_scroll(src)


/obj/item/storage/box/syndie_kit/atmosn2ogrenades
	name = "Atmos N2O Grenades"

/obj/item/storage/box/syndie_kit/atmosn2ogrenades/populate_contents()
	new /obj/item/grenade/clusterbuster/n2o(src)
	new /obj/item/grenade/clusterbuster/n2o(src)


/obj/item/storage/box/syndie_kit/atmosfiregrenades
	name = "Plasma Fire Grenades"

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

/obj/item/storage/box/syndie_kit/bonerepair
	name = "emergency nanite kit"
	desc = "A box containing one prototype nanite repair system."

/obj/item/storage/box/syndie_kit/bonerepair/populate_contents()
	new /obj/item/reagent_containers/hypospray/autoinjector/nanocalcium(src)
	var/obj/item/paper/P = new /obj/item/paper(src)
	P.name = "Prototype nanite repair guide"
	P.desc = "For when you want to safely get off Mr Bones' Wild Ride."
	P.info = {"
<font face="Verdana" color=black></font><font face="Verdana" color=black><center><B>Prototype Emergency Repair Nanites</B><HR></center><BR><BR>

<B>Usage:</B> <BR><BR><BR>

<font size = "1">This is a highly experimental prototype chemical designed to repair damaged bones, organs, and treat interenal bleeding of soldiers in the field, use only as a last resort. The autoinjector contains prototype nanites bearing a classifed payload. The nanites will simultaneously shut down body systems whilst aiding in repair.<BR><BR><BR>Warning: Side effects can cause temporary paralysis, loss of co-ordination and sickness. <B>Do not use with any kind of stimulant or drugs. Serious damage can occur!</B><BR><BR><BR>

To apply, hold the injector a short distance away from the outer thigh before applying firmly to the skin surface. The process of repairing should begin repair after a short time, during which you are advised to remain still. <BR><BR><BR><BR>After use you are advised to see a doctor at the next available opportunity. Mild scarring and tissue damage may occur after use. This is a prototype. We are not liable for any bone spurs, cancers, extra limbs, or creation of new viruses from use of the product.</font><BR><HR></font>
	"}

/obj/item/storage/box/syndie_kit/safecracking
	name = "Safe-cracking Kit"
	desc = "Everything you need to quietly open a mechanical combination safe."

/obj/item/storage/box/syndie_kit/safecracking/populate_contents()
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/mask/balaclava(src)
	new /obj/item/clothing/accessory/stethoscope(src)
	new /obj/item/book/manual/engineering_hacking(src)

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
	new /obj/item/pen/fakesign(src)

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

/obj/item/storage/box/syndie_kit/genes
	name = "Genetic superiority bundle"
	desc = "Fun for the whole family"

/obj/item/storage/box/syndie_kit/genes/populate_contents()
	new /obj/item/dnainjector/hulkmut(src)
	new /obj/item/dnainjector/xraymut(src)
	new /obj/item/dnainjector/telemut(src)
	new /obj/item/dnainjector/runfast(src)
	new /obj/item/dnainjector/insulation(src)

/obj/item/storage/box/syndie_kit/stungloves
	name = "Stungloves"

/obj/item/storage/box/syndie_kit/stungloves/populate_contents()
	new /obj/item/clothing/gloves/color/yellow/stun(src)
	new /obj/item/stock_parts/cell/high/plus(src)
	new /obj/item/toy/crayon/white(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/rainbow(src)

/obj/item/storage/box/syndie_kit/cyborg_maint
	name = "cyborg repair kit"
	desc = "For people who wants to repair their robots."

/obj/item/storage/box/syndie_kit/cyborg_maint/populate_contents()
	new /obj/item/robot_parts/robot_component/armour(src)
	new /obj/item/robot_parts/robot_component/actuator(src)
	new /obj/item/robot_parts/robot_component/radio(src)
	new /obj/item/robot_parts/robot_component/binary_communication_device(src)
	new /obj/item/robot_parts/robot_component/camera(src)
	new /obj/item/robot_parts/robot_component/diagnosis_unit(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/encryptionkey/syndicate(src)
	new /obj/item/robotanalyzer(src)
	var/obj/item/paper/P = new (src)
	P.name = "Cyborg Repair Instruction"
	P.info = {"
<font face="Verdana" color=black></font><font face="Verdana" color=black><center><B>Краткая инструкция по пончинке роботов</B><HR></center><BR><BR>

<font size = "4">1. Возьмите Cyborg Analyzer, проведите им по юниту.<BR>
2. Запомните сломанные компоненты, которые вывел Cyborg Analyzer.<BR>
3. Если юнит закрыт(будет визуально заметно), то попросите его открыться. Если он уничтожен - проведите ЕМАГом для открытия.<BR>
4. Монтировкой откройте крышку юнита.<BR>
5. Руками вытащите батарейку у юнита.<BR>
6. Монтировкой снимите сломанные компоненты из пункта 2.<BR>
7. Вставьте новые компоненты в юнита.<BR>
8. Вставьте батарейку в юнита.<BR>
9. Закройте крышку юнита монтировкой.<BR>
10. Залейте нанопастой поврежденные части юнита.<BR>
11. Готово. Юнит снова функционирует.<BR>
<BR><BR><BR>
	"}
/obj/item/storage/box/syndie_kit/chameleon_counter
	name = "chameleon counterfeiter kit"

/obj/item/storage/box/syndie_kit/chameleon_counter/populate_contents()
	new /obj/item/chameleon_counterfeiter(src)
	new /obj/item/chameleon_counterfeiter(src)
	new /obj/item/chameleon_counterfeiter(src)

/obj/item/storage/box/syndie_kit/pistol_ammo
	name = "additional 10mm ammunition kit"

/obj/item/storage/box/syndie_kit/pistol_ammo/populate_contents()
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)

/obj/item/storage/box/syndie_kit/revolver_ammo
	name = "additional .357 ammunition kit"

/obj/item/storage/box/syndie_kit/revolver_ammo/populate_contents()
	new /obj/item/ammo_box/a357(src)
	new /obj/item/ammo_box/a357(src)

/obj/item/storage/box/syndie_kit/dangertray
	name = "Danger Tray pack"
	desc = "Normal size box with compartments for trays."
	can_hold = list(/obj/item/storage/bag/dangertray)
	max_combined_w_class = 3
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/dangertray/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/storage/bag/dangertray(src)

/obj/item/storage/box/syndie_kit/mr_chang_technique
	name = "Mr. Chang's Aggressive Marketing Technique"
	desc = "Special delivery package that contains a set of items dedicated to maximize the income. Sell me that pen."
	icon_state = "box_mr_chang"

/obj/item/storage/box/syndie_kit/mr_chang_technique/populate_contents()
	new /obj/item/mr_chang_technique(src)
	new /obj/item/clothing/suit/mr_chang_coat(src)
	new /obj/item/clothing/shoes/mr_chang_sandals(src)
	new /obj/item/clothing/head/mr_chang_band(src)
