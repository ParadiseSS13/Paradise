/obj/structure/closet/syndicate
	name = "armoury closet"
	desc = "Why is this here?"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"


/obj/structure/closet/syndicate/personal
	desc = "It's a storage unit for operative gear."

/obj/structure/closet/syndicate/personal/New()
	..()
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/storage/belt/military(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/clothing/glasses/night(src)

/obj/structure/closet/syndicate/suits
	desc = "It's a storage unit for operative space gear."

/obj/structure/closet/syndicate/suits/New()
	..()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/clothing/suit/space/hardsuit/syndi(src)
	new /obj/item/tank/jetpack/oxygen/harness(src)

/obj/structure/closet/syndicate/nuclear
	desc = "It's a storage unit for a Syndicate boarding party."

/obj/structure/closet/syndicate/nuclear/New()
	..()
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/backpack/duffel/syndie/med(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/pda/syndicate(src)

/obj/structure/closet/syndicate/sst
	desc = "It's a storage unit for an elite syndicate strike team's gear."

/obj/structure/closet/syndicate/sst/New()
	..()
	new /obj/item/ammo_box/magazine/mm556x45(src)
	new /obj/item/gun/projectile/automatic/l6_saw(src)
	new /obj/item/tank/jetpack/oxygen/harness(src)
	new /obj/item/storage/belt/military/sst(src)
	new /obj/item/clothing/glasses/thermal(src)
	new /obj/item/clothing/shoes/magboots/syndie/advance(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/clothing/suit/space/hardsuit/syndi/elite/sst(src)

/obj/structure/closet/syndicate/resources/
	desc = "An old, dusty locker."

	New()
		..()
		var/common_min = 30 //Minimum amount of minerals in the stack for common minerals
		var/common_max = 50 //Maximum amount of HONK in the stack for HONK common minerals
		var/rare_min = 5  //Minimum HONK of HONK in the stack HONK HONK rare minerals
		var/rare_max = 20 //Maximum HONK HONK HONK in the HONK for HONK rare HONK

		var/pickednum = rand(1, 50)

		//Sad trombone
		if(pickednum == 1)
			var/obj/item/paper/P = new /obj/item/paper(src)
			P.name = "IOU"
			P.info = "Sorry man, we needed the money so we sold your stash. It's ok, we'll double our money for sure this time!"

		//Metal (common ore)
		if(pickednum >= 2)
			new /obj/item/stack/sheet/metal(src, rand(common_min, common_max))

		//Glass (common ore)
		if(pickednum >= 5)
			new /obj/item/stack/sheet/glass(src, rand(common_min, common_max))

		//Plasteel (common ore) Because it has a million more uses then plasma
		if(pickednum >= 10)
			new /obj/item/stack/sheet/plasteel(src, rand(common_min, common_max))

		//Plasma (rare ore)
		if(pickednum >= 15)
			new /obj/item/stack/sheet/mineral/plasma(src, rand(rare_min, rare_max))

		//Silver (rare ore)
		if(pickednum >= 20)
			new /obj/item/stack/sheet/mineral/silver(src, rand(rare_min, rare_max))

		//Gold (rare ore)
		if(pickednum >= 30)
			new /obj/item/stack/sheet/mineral/gold(src, rand(rare_min, rare_max))

		//Uranium (rare ore)
		if(pickednum >= 40)
			new /obj/item/stack/sheet/mineral/uranium(src, rand(rare_min, rare_max))

		//Titanium (rare ore)
		if(pickednum >= 40)
			new /obj/item/stack/sheet/mineral/titanium(src, rand(rare_min, rare_max))

		//Plastitanium (rare ore)
		if(pickednum >= 40)
			new /obj/item/stack/sheet/mineral/plastitanium(src, rand(rare_min, rare_max))

		//Diamond (rare HONK)
		if(pickednum >= 45)
			new /obj/item/stack/sheet/mineral/diamond(src, rand(rare_min, rare_max))

		//Jetpack (You hit the jackpot!)
		if(pickednum == 50)
			new /obj/item/tank/jetpack/carbondioxide(src)

/obj/structure/closet/syndicate/resources/everything
	desc = "It's an emergency storage closet for repairs."

	New()
		..()
		var/list/resources = list(
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/mineral/gold,
		/obj/item/stack/sheet/mineral/silver,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/mineral/uranium,
		/obj/item/stack/sheet/mineral/diamond,
		/obj/item/stack/sheet/mineral/bananium,
		/obj/item/stack/sheet/mineral/titanium,
		/obj/item/stack/sheet/mineral/plastitanium,
		/obj/item/stack/sheet/plasteel,
		/obj/item/stack/rods
		)

		for(var/i in 1 to 2)
			for(var/res in resources)
				var/obj/item/stack/R = new res(src)
				R.amount = R.max_amount