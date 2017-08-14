/obj/item/weapon/storage/box/syndicate/
	New()
		..()
		switch(pickweight(list("bloodyspai" = 1, "thief" = 1, "bond" = 1, "sabotage" = 1, "payday" = 1, "implant" = 1, "hacker" = 1, "darklord" = 1, "gadgets" = 1)))
			if("bloodyspai")
				new /obj/item/weapon/twohanded/garrote(src)
				new /obj/item/weapon/pinpointer/advpinpointer(src)
				new /obj/item/clothing/mask/gas/voice(src)
				new /obj/item/clothing/under/chameleon(src)
				new /obj/item/weapon/card/id/syndicate(src)
				new /obj/item/weapon/storage/box/syndie_kit/emp(src)
				new /obj/item/device/camera_bug(src)
				return

			if("thief")
				new /obj/item/weapon/gun/energy/kinetic_accelerator/crossbow(src)
				new /obj/item/device/chameleon(src)
				new /obj/item/clothing/gloves/color/black/thief(src)
				new /obj/item/weapon/card/id/syndicate(src)
				return

			if("bond")
				new /obj/item/weapon/gun/projectile/automatic/pistol(src)
				new /obj/item/weapon/suppressor(src)
				new /obj/item/ammo_box/magazine/m10mm/hp(src)
				new /obj/item/device/encryptionkey/syndicate(src)
				new /obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate(src)
				new /obj/item/weapon/implanter/krav_maga(src)
				new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass/alliescocktail(src)
				return

			if("sabotage")
				new /obj/item/device/powersink(src)
				new /obj/item/weapon/grenade/syndieminibomb(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/weapon/grenade/clusterbuster/n2o(src)
				new /obj/item/weapon/storage/box/syndie_kit/space(src)
				new /obj/item/clothing/gloves/color/yellow(src)
				new /obj/item/weapon/rcd/preloaded(src)
				return

			if("payday")
				new /obj/item/weapon/gun/projectile/revolver(src)
				new /obj/item/ammo_box/a357(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/weapon/grenade/plastic/x4(src)
				new /obj/item/weapon/card/id/syndicate(src)
				new /obj/item/clothing/gloves/color/latex/nitrile(src)
				new /obj/item/clothing/mask/gas/clown_hat(src)
				return

			if("implant")
				new /obj/item/weapon/implanter/uplink(src)
				new /obj/item/weapon/implanter/adrenalin(src)
				new /obj/item/weapon/implanter/storage(src)
				new /obj/item/weapon/implanter/freedom(src)
				return

			if("hacker")
				new /obj/item/weapon/aiModule/syndicate(src)
				new /obj/item/device/encryptionkey/binary(src)
				new /obj/item/weapon/aiModule/toyAI(src)
				return

			if("darklord")
				new /obj/item/weapon/melee/energy/sword/saber/red(src)
				new /obj/item/weapon/melee/energy/sword/saber/red(src)
				new /obj/item/weapon/dnainjector/telemut/darkbundle(src)
				new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
				new /obj/item/weapon/card/id/syndicate(src)
				return

			if("gadgets")
				new /obj/item/clothing/gloves/color/yellow/power(src)
				new /obj/item/weapon/pen/sleepy(src)
				new /obj/item/clothing/glasses/thermal/syndi(src)
				new /obj/item/device/flashlight/emp(src)
				new /obj/item/clothing/shoes/syndigaloshes(src)
				new /obj/item/weapon/stamp/chameleon(src)
				new /obj/item/device/multitool/ai_detect(src)
				return

/obj/item/weapon/storage/box/syndie_kit
	name = "Box"
	desc = "A sleek, sturdy box"
	icon_state = "box_of_doom"

/obj/item/weapon/storage/box/syndie_kit/space
	name = "Boxed Space Suit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/syndicate/black/red, /obj/item/clothing/head/helmet/space/syndicate/black/red)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/storage/box/syndie_kit/space/New()
	..()
	new /obj/item/clothing/suit/space/syndicate/black/red(src)
	new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
	return

/obj/item/weapon/storage/box/syndie_kit/hardsuit
	name = "Boxed Blood Red Suit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/hardsuit/syndi, /obj/item/clothing/head/helmet/space/hardsuit/syndi)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/storage/box/syndie_kit/hardsuit/New()
	..()
	new /obj/item/clothing/suit/space/hardsuit/syndi(src)
	new /obj/item/clothing/head/helmet/space/hardsuit/syndi(src)
	return

/obj/item/weapon/storage/box/syndie_kit/elite_hardsuit
	name = "Boxed Elite Syndicate Hardsuit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/hardsuit/syndi/elite, /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/storage/box/syndie_kit/elite_hardsuit/New()
	..()
	new /obj/item/clothing/suit/space/hardsuit/syndi/elite(src)
	new /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite(src)

/obj/item/weapon/storage/box/syndie_kit/shielded_hardsuit
	name = "Boxed Shielded Syndicate Hardsuit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/hardsuit/shielded/syndi, /obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi)
	max_w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/storage/box/syndie_kit/shielded_hardsuit/New()
	..()
	new /obj/item/clothing/suit/space/hardsuit/shielded/syndi(src)
	new /obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi(src)

/obj/item/weapon/storage/box/syndie_kit/conversion
	name = "box (CK)"

/obj/item/weapon/storage/box/syndie_kit/conversion/New()
	..()
	new /obj/item/weapon/conversion_kit(src)
	new /obj/item/ammo_box/a357(src)
	return

/obj/item/weapon/storage/box/syndie_kit/boolets
	name = "Shotgun shells"

	New()
		..()
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)

/obj/item/weapon/storage/box/syndie_kit/emp
	name = "boxed EMP kit"

/obj/item/weapon/storage/box/syndie_kit/emp/New()
	..()
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/implanter/emp/(src)

/obj/item/weapon/storage/box/syndie_kit/throwing_weapons
	name = "boxed throwing kit"
	can_hold = list(/obj/item/weapon/throwing_star, /obj/item/weapon/restraints/legcuffs/bola/tactical)
	max_combined_w_class = 16
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/storage/box/syndie_kit/throwing_weapons/New()
	..()
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/restraints/legcuffs/bola/tactical(src)
	new /obj/item/weapon/restraints/legcuffs/bola/tactical(src)

/obj/item/weapon/storage/box/syndie_kit/sarin
	name = "Sarin Gas Grenades"

	New()
		..()
		new /obj/item/weapon/grenade/chem_grenade/saringas(src)
		new /obj/item/weapon/grenade/chem_grenade/saringas(src)
		new /obj/item/weapon/grenade/chem_grenade/saringas(src)
		new /obj/item/weapon/grenade/chem_grenade/saringas(src)

/obj/item/weapon/storage/box/syndie_kit/bioterror
	name = "bioterror syringe box"

	New()
		..()
		new /obj/item/weapon/reagent_containers/syringe/bioterror(src)
		new /obj/item/weapon/reagent_containers/syringe/bioterror(src)
		new /obj/item/weapon/reagent_containers/syringe/bioterror(src)
		new /obj/item/weapon/reagent_containers/syringe/bioterror(src)
		new /obj/item/weapon/reagent_containers/syringe/bioterror(src)
		new /obj/item/weapon/reagent_containers/syringe/bioterror(src)
		new /obj/item/weapon/reagent_containers/syringe/bioterror(src)
		return

/obj/item/weapon/storage/box/syndie_kit/caneshotgun
	name = "cane gun kit"


/obj/item/weapon/storage/box/syndie_kit/caneshotgun/New()
	..()
	new /obj/item/ammo_casing/shotgun/dart/assassination(src)
	new /obj/item/ammo_casing/shotgun/dart/assassination(src)
	new /obj/item/ammo_casing/shotgun/dart/assassination(src)
	new /obj/item/ammo_casing/shotgun/dart/assassination(src)
	new /obj/item/ammo_casing/shotgun/dart/assassination(src)
	new /obj/item/ammo_casing/shotgun/dart/assassination(src)
	new /obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/cane(src)


/obj/item/weapon/storage/box/syndie_kit/atmosgasgrenades
	name = "Atmos Grenades"

/obj/item/weapon/storage/box/syndie_kit/atmosgasgrenades/New()
	..()
	new /obj/item/weapon/grenade/clusterbuster/plasma(src)
	new /obj/item/weapon/grenade/clusterbuster/n2o(src)

/obj/item/weapon/storage/box/syndie_kit/missionary_set
	name = "Missionary Starter Kit"

/obj/item/weapon/storage/box/syndie_kit/missionary_set/New()
	..()
	new /obj/item/weapon/nullrod/missionary_staff(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe(src)
	var/obj/item/weapon/storage/bible/B = new /obj/item/weapon/storage/bible(src)
	if(prob(25))	//an omen of success to come?
		B.deity_name = "Success"
		B.icon_state = "greentext"
		B.item_state = "greentext"


/obj/item/weapon/storage/box/syndie_kit/cutouts
	name = "Fortified Artistic Box"

/obj/item/weapon/storage/box/syndie_kit/cutouts/New()
	..()
	for(var/i in 1 to 3)
		new/obj/item/cardboard_cutout/adaptive(src)
	new/obj/item/toy/crayon/spraycan(src)