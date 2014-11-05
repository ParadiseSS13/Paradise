/obj/machinery/manufacturer/security
	name = "Security Fabricator"
	desc = "A manufacturing unit calibrated to produce security and military related equipment."
	acceptdisk = 1

	New()
		..()
		src.available += new /datum/manufacture/beret(src)
		src.available += new /datum/manufacture/helmet1(src)
		src.available += new /datum/manufacture/sunglasses(src)
		src.available += new /datum/manufacture/sechud(src)
		src.available += new /datum/manufacture/secpants(src)
		src.available += new /datum/manufacture/secbelt(src)
		src.available += new /datum/manufacture/armor1(src)
		src.available += new /datum/manufacture/taser(src)
		src.available += new /datum/manufacture/baton(src)

// Security Gear Tier-0. AKA Clothing and basic as shit gear.
/datum/manufacture/beret
	name = "Beret"
	item = /obj/item/clothing/head/beret/sec
	cost1 = /obj/item/weapon/ore/fabric
	cname1 = "Fabric"
	amount1 = 2
	time = 3
	create = 1

/datum/manufacture/helmet1
	name = "Helmet"
	item = /obj/item/clothing/head/helmet
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/fabric
	cname2 = "Fabric"
	amount2 = 10
	time = 10
	create = 1

/datum/manufacture/sunglasses
	name = "Sunglasses"
	item = /obj/item/clothing/glasses/sunglasses
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 5
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 10
	time = 8
	create = 1

/datum/manufacture/sechud
	name = "Security HUD"
	item = /obj/item/clothing/glasses/hud/security
	cost1 = /obj/item/weapon/ore/osmium
	cname1 = "Platinum"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 15
	time = 12
	create = 1

/datum/manufacture/secpants
	name = "Security Uniform"
	item = /obj/item/clothing/under/rank/security
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/fabric
	cname2 = "Fabric"
	amount2 = 1
	time = 10
	create = 1

/datum/manufacture/secbelt
	name = "Security Belt"
	item = /obj/item/weapon/storage/belt/security
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/fabric
	cname2 = "Fabric"
	amount2 = 5
	time = 15
	create = 1

/datum/manufacture/armor1
	name = "Armored Vest"
	item = /obj/item/clothing/suit/armor/vest
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 15
	cost2 = /obj/item/weapon/ore/fabric
	cname2 = "Fabric"
	amount2 = 15
	time = 20
	create = 1

/datum/manufacture/taser
	name = "Taser"
	item = /obj/item/weapon/gun/energy/taser
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 15
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 10
	cost3 = /obj/item/weapon/ore/osmium
	cname3 = "Platinum"
	amount3 = 20
	time = 25
	create = 1

/datum/manufacture/baton
	name = "Stun Baton"
	item = /obj/item/weapon/melee/baton
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 10
	cost3 = /obj/item/weapon/ore/osmium
	cname3 = "Platinum"
	amount3 = 15
	time = 20
	create = 1