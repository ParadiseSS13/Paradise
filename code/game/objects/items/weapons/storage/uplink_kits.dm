/obj/item/storage/box/syndicate/New()
	..()
	switch(pickweight(list("bloodyspai" = 1, "thief" = 1, "bond" = 1, "sabotage" = 1, "payday" = 1, "implant" = 1, "hacker" = 1, "darklord" = 1, "professional" = 1)))
		if("bloodyspai") // 35TC + one 0TC
			new /obj/item/clothing/under/chameleon(src) // 2TC
			new /obj/item/clothing/mask/chameleon(src) // 0TC
			new /obj/item/card/id/syndicate(src) // 2TC
			new /obj/item/clothing/shoes/chameleon/noslip(src) // 2TC
			new /obj/item/camera_bug(src) // 1TC
			new /obj/item/multitool/ai_detect(src) // 1TC
			new /obj/item/encryptionkey/syndicate(src) // 2TC
			new /obj/item/twohanded/garrote(src) // 10TC
			new /obj/item/pinpointer/advpinpointer(src) // 4TC
			new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(src) // 2TC
			new /obj/item/flashlight/emp(src) // 2TC
			new /obj/item/clothing/glasses/hud/security/chameleon(src) // 2TC
			new /obj/item/chameleon(src) // 8TC
			return

		if("thief")	// 40TC
			new /obj/item/gun/energy/kinetic_accelerator/crossbow(src) // 12TC
			new /obj/item/chameleon(src) // 8TC
			new /obj/item/clothing/glasses/chameleon/thermal(src) // 6TC
			new /obj/item/clothing/gloves/color/black/thief(src) // 6TC
			new /obj/item/card/id/syndicate(src) // 2TC
			new /obj/item/clothing/shoes/chameleon/noslip(src) // 2TC
			new /obj/item/storage/backpack/satchel_flat(src) // 2TC
			new /obj/item/encryptionkey/syndicate(src) // 2TC
			return

		if("bond") // 33TC + three 0TC
			new /obj/item/gun/projectile/automatic/pistol(src) // 4TC
			new /obj/item/suppressor(src) // 1TC
			new /obj/item/ammo_box/magazine/m10mm/hp(src)  // 3TC
			new /obj/item/ammo_box/magazine/m10mm/ap(src) // 2TC
			new /obj/item/clothing/under/suit_jacket/really_black(src) // 0TC
			new /obj/item/card/id/syndicate(src) // 2TC
			new /obj/item/clothing/suit/storage/lawyer/blackjacket/armored(src) // 0TC
			new /obj/item/encryptionkey/syndicate(src) // 2TC
			new /obj/item/reagent_containers/food/drinks/drinkingglass/alliescocktail(src)	// 0TC
			new /obj/item/dnascrambler(src) // 4TC
			new /obj/item/storage/box/syndie_kit/emp(src) // 2TC
			new /obj/item/CQC_manual(src) // 13TC
			return

		if("sabotage") // 47TC + three 0TC
			new /obj/item/grenade/plastic/c4(src) // 1TC
			new /obj/item/grenade/plastic/c4(src) // 1TC
			new /obj/item/camera_bug(src) // 1TC
			new /obj/item/powersink(src) // 10TC
			new /obj/item/cartridge/syndicate(src) // 6TC
			new /obj/item/rcd/preloaded(src) // 0TC
			new /obj/item/card/emag(src) // 6TC
			new /obj/item/clothing/gloves/color/yellow(src) // 0TC
			new /obj/item/grenade/syndieminibomb(src) // 6TC
			new /obj/item/grenade/clusterbuster/n2o(src) // 0TC
			new /obj/item/storage/box/syndie_kit/space(src) // 4TC
			new /obj/item/encryptionkey/syndicate(src) // 2TC
			return

		if("payday") // 33TC + four 0TC
			new /obj/item/gun/projectile/revolver(src) // 13TC
			new /obj/item/ammo_box/a357(src) // 3TC
			new /obj/item/ammo_box/a357(src) // 3TC
			new /obj/item/card/emag(src) // 6TC
			new /obj/item/grenade/plastic/c4(src) // 1TC
			new /obj/item/card/id/syndicate(src) // 2TC
			new /obj/item/clothing/under/suit_jacket/really_black(src) //0TC
			new /obj/item/clothing/suit/storage/lawyer/blackjacket/armored(src) //0TC
			new /obj/item/clothing/gloves/color/latex/nitrile(src) //0 TC
			new /obj/item/clothing/mask/gas/clown_hat(src) // 0TC
			new /obj/item/thermal_drill(src) // 3TC
			new /obj/item/encryptionkey/syndicate(src) // 2TC
			return

		if("implant") // 39TC + ten free TC
			new /obj/item/implanter/freedom(src) // 5TC
			new /obj/item/implanter/uplink(src) // 14TC (ten free TC)
			new /obj/item/implanter/emp(src) // 0TC
			new /obj/item/implanter/adrenalin(src) // 8TC
			new /obj/item/implanter/explosive(src) // 2TC
			new /obj/item/implanter/storage(src) // 8TC
			new /obj/item/encryptionkey/syndicate(src) // 2TC
			return

		if("hacker") // 30TC + one 0TC
			new /obj/item/aiModule/syndicate(src) // 12TC
			new /obj/item/card/emag(src) // 6TC
			new /obj/item/encryptionkey/syndicate(src) // 2TC
			new /obj/item/encryptionkey/binary(src) // 5TC
			new /obj/item/aiModule/toyAI(src) // 0TC
			new /obj/item/multitool/ai_detect(src) // 1TC
			new /obj/item/storage/box/syndie_kit/c4 // 4TC
			return

		if("darklord") // 22TC + two 0TC
			new /obj/item/melee/energy/sword/saber/red(src) // 8TC
			new /obj/item/melee/energy/sword/saber/red(src) // 8TC
			new /obj/item/dnainjector/telemut/darkbundle(src) // 0TC
			new /obj/item/clothing/suit/hooded/chaplain_hoodie(src) // 0TC
			new /obj/item/card/id/syndicate(src) // 2TC
			new /obj/item/clothing/shoes/chameleon/noslip(src) // 2TC
			new /obj/item/clothing/mask/chameleon(src) // 2TC
			new /obj/item/encryptionkey/syndicate(src) // 2TC
			return

		if("professional") // 32 TC + two 0TC
			new /obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator(src) // 16TC
			new /obj/item/ammo_box/magazine/sniper_rounds/penetrator(src) // 5TC
			new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src) // 3TC
			new /obj/item/clothing/glasses/chameleon/thermal(src) // 6TC
			new /obj/item/clothing/gloves/combat(src) // 0 TC
			new /obj/item/clothing/under/suit_jacket/really_black(src) // 0 TC
			new /obj/item/clothing/suit/storage/lawyer/blackjacket/armored(src) // 0TC
			new /obj/item/pen/edagger(src) // 2TC
			new /obj/item/encryptionkey/syndicate(src) // 2TC
			return

/obj/item/storage/box/syndie_kit
	name = "Box"
	desc = "A sleek, sturdy box"
	icon_state = "box_of_doom"

/obj/item/storage/box/syndie_kit/romerol
	name = "Romerol Kit"
	desc = "A box containing a deadly virus capable of reanimating dead as zombies."
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/reagent_containers/glass/bottle/romerol,/obj/item/reagent_containers/syringe,/obj/item/reagent_containers/dropper)

/obj/item/storage/box/syndie_kit/romerol/New()
	..()
	new /obj/item/reagent_containers/glass/bottle/romerol(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/dropper(src)
	return

/obj/item/storage/box/syndie_kit/space
	name = "Boxed Space Suit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/syndicate/black/red, /obj/item/clothing/head/helmet/space/syndicate/black/red, /obj/item/tank/emergency_oxygen/syndi, /obj/item/clothing/mask/gas/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/space/New()
	..()
	new /obj/item/clothing/suit/space/syndicate/black/red(src)
	new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/emergency_oxygen/syndi(src)
	return

/obj/item/storage/box/syndie_kit/hardsuit
	name = "Boxed Blood Red Suit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/hardsuit/syndi, /obj/item/tank/emergency_oxygen/syndi, /obj/item/clothing/mask/gas/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/hardsuit/New()
	..()
	new /obj/item/clothing/suit/space/hardsuit/syndi(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/emergency_oxygen/syndi(src)

/obj/item/storage/box/syndie_kit/conversion
	name = "box (CK)"

/obj/item/storage/box/syndie_kit/conversion/New()
	..()
	new /obj/item/conversion_kit(src)
	new /obj/item/ammo_box/a357(src)
	return

/obj/item/storage/box/syndie_kit/boolets
	name = "Shotgun shells"

	New()
		..()
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)

/obj/item/storage/box/syndie_kit/emp
	name = "boxed EMP kit"

/obj/item/storage/box/syndie_kit/emp/New()
	..()
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/implanter/emp/(src)

/obj/item/storage/box/syndie_kit/c4
	name = "Pack of C-4 Explosives"

/obj/item/storage/box/syndie_kit/c4/New()
	..()
	new /obj/item/grenade/plastic/c4(src)
	new /obj/item/grenade/plastic/c4(src)
	new /obj/item/grenade/plastic/c4(src)
	new /obj/item/grenade/plastic/c4(src)
	new /obj/item/grenade/plastic/c4(src)

/obj/item/storage/box/syndie_kit/throwing_weapons
	name = "boxed throwing kit"
	can_hold = list(/obj/item/throwing_star, /obj/item/restraints/legcuffs/bola/tactical)
	max_combined_w_class = 16
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/throwing_weapons/New()
	..()
	new /obj/item/throwing_star(src)
	new /obj/item/throwing_star(src)
	new /obj/item/throwing_star(src)
	new /obj/item/throwing_star(src)
	new /obj/item/throwing_star(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)

/obj/item/storage/box/syndie_kit/sarin
	name = "Sarin Gas Grenades"

	New()
		..()
		new /obj/item/grenade/chem_grenade/saringas(src)
		new /obj/item/grenade/chem_grenade/saringas(src)
		new /obj/item/grenade/chem_grenade/saringas(src)
		new /obj/item/grenade/chem_grenade/saringas(src)

/obj/item/storage/box/syndie_kit/bioterror
	name = "bioterror syringe box"

	New()
		..()
		new /obj/item/reagent_containers/syringe/bioterror(src)
		new /obj/item/reagent_containers/syringe/bioterror(src)
		new /obj/item/reagent_containers/syringe/bioterror(src)
		new /obj/item/reagent_containers/syringe/bioterror(src)
		new /obj/item/reagent_containers/syringe/bioterror(src)
		new /obj/item/reagent_containers/syringe/bioterror(src)
		new /obj/item/reagent_containers/syringe/bioterror(src)
		return

/obj/item/storage/box/syndie_kit/caneshotgun
	name = "cane gun kit"


/obj/item/storage/box/syndie_kit/caneshotgun/New()
	..()
	new /obj/item/ammo_casing/shotgun/assassination(src)
	new /obj/item/ammo_casing/shotgun/assassination(src)
	new /obj/item/ammo_casing/shotgun/assassination(src)
	new /obj/item/ammo_casing/shotgun/assassination(src)
	new /obj/item/ammo_casing/shotgun/assassination(src)
	new /obj/item/ammo_casing/shotgun/assassination(src)
	new /obj/item/gun/projectile/revolver/doublebarrel/improvised/cane(src)

/obj/item/storage/box/syndie_kit/fake_revolver
	name = "trick revolver kit"

/obj/item/storage/box/syndie_kit/fake_revolver/New()
	..()
	new /obj/item/toy/russian_revolver/trick_revolver(src)

/obj/item/storage/box/syndie_kit/mimery
	name = "advanced mimery kit"

/obj/item/storage/box/syndie_kit/mimery/New()
	..()
	new /obj/item/spellbook/oneuse/mime/greaterwall(src)
	new	/obj/item/spellbook/oneuse/mime/fingergun(src)


/obj/item/storage/box/syndie_kit/atmosn2ogrenades
	name = "Atmos N2O Grenades"

/obj/item/storage/box/syndie_kit/atmosn2ogrenades/New()
	..()
	new /obj/item/grenade/clusterbuster/n2o(src)
	new /obj/item/grenade/clusterbuster/n2o(src)


/obj/item/storage/box/syndie_kit/atmosfiregrenades
	name = "Plasma Fire Grenades"

/obj/item/storage/box/syndie_kit/atmosfiregrenades/New()
	..()
	new /obj/item/grenade/clusterbuster/plasma(src)
	new /obj/item/grenade/clusterbuster/plasma(src)


/obj/item/storage/box/syndie_kit/missionary_set
	name = "Missionary Starter Kit"

/obj/item/storage/box/syndie_kit/missionary_set/New()
	..()
	new /obj/item/nullrod/missionary_staff(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe(src)
	var/obj/item/storage/bible/B = new /obj/item/storage/bible(src)
	if(prob(25))	//an omen of success to come?
		B.deity_name = "Success"
		B.icon_state = "greentext"
		B.item_state = "greentext"


/obj/item/storage/box/syndie_kit/cutouts
	name = "Fortified Artistic Box"

/obj/item/storage/box/syndie_kit/cutouts/New()
	..()
	for(var/i in 1 to 3)
		new/obj/item/cardboard_cutout/adaptive(src)
	new/obj/item/toy/crayon/spraycan(src)

/obj/item/storage/box/syndie_kit/bonerepair
	name = "bone repair kit"
	desc = "A box containing one prototype field bone repair kit."

/obj/item/storage/box/syndie_kit/bonerepair/New()
	..()
	new /obj/item/reagent_containers/hypospray/autoinjector/nanocalcium(src)
	var/obj/item/paper/P = new /obj/item/paper(src)
	P.name = "Bone repair guide"
	P.desc = "For when you want to safely get off Mr Bones' Wild Ride."
	P.info = {"
<font face="Verdana" color=black></font><font face="Verdana" color=black><center><B>Prototype Bone Repair Nanites</B><HR></center><BR><BR>

<B>Usage:</B> <BR><BR><BR>

<font size = "1">This is a highly experimental prototype chemical designed to repair damaged bones of soldiers in the field, use only as a last resort. The autoinjector contains prototype nanites bearing a calcium based payload. The nanites will simultaneously shut down body systems whilst aiding bone repair.<BR><BR><BR>Warning: Side effects can cause temporary paralysis, loss of co-ordination and sickness. <B>Do not use with any kind of stimulant or drugs. Serious damage can occur!</B><BR><BR><BR>

To apply, hold the injector a short distance away from the outer thigh before applying firmly to the skin surface. Bones should begin repair after a short time, during which you are advised to remain still. <BR><BR><BR><BR>After use you are advised to see a doctor at the next available opportunity. Mild scarring and tissue damage may occur after use. This is a prototype.</font><BR><HR></font>
	"}

/obj/item/storage/box/syndie_kit/safecracking
	name = "Safe-cracking Kit"
	desc = "Everything you need to quietly open a mechanical combination safe."

/obj/item/storage/box/syndie_kit/safecracking/New()
	..()
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/mask/balaclava(src)
	new /obj/item/clothing/accessory/stethoscope(src)
	new /obj/item/book/manual/engineering_hacking(src)

/obj/item/storage/box/syndie_kit/chameleon
	name = "chameleon kit"

/obj/item/storage/box/syndie_kit/chameleon/New()
	..()
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

/obj/item/storage/box/syndie_kit/dart_gun/New()
	..()
	new /obj/item/gun/syringe/syndicate(src)
	new /obj/item/reagent_containers/syringe/capulettium_plus(src)
	new /obj/item/reagent_containers/syringe/sarin(src)
	new /obj/item/reagent_containers/syringe/pancuronium(src)

