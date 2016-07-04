/obj/item/weapon/rig/unathi
	name = "NT breacher chassis control module"
	desc = "A cheap NT knock-off of an Unathi battle-rig. Looks like a fish, moves like a fish, steers like a cow."
	suit_type = "NT breacher"
	icon_state = "breacher_rig_cheap"
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 30, bomb = 45, bio = 100, rad = 50)
	emp_protection = -20
	slowdown = 6
	offline_slowdown = 10
	vision_restriction = 1
	offline_vision_restriction = 2

	chest_type = /obj/item/clothing/suit/space/new_rig
	helm_type = /obj/item/clothing/head/helmet/space/new_rig/unathi
	boot_type = /obj/item/clothing/shoes/magboots/rig/unathi

/obj/item/weapon/rig/unathi/fancy
	name = "breacher chassis control module"
	desc = "An authentic Unathi breacher chassis. Huge, bulky and absurdly heavy. It must be like wearing a tank."
	suit_type = "breacher chassis"
	icon_state = "breacher_rig"
	armor = list(melee = 45, bullet = 45, laser = 45, energy = 45, bomb = 45, bio = 100, rad = 75) //Takes TEN TIMES as much damage to stop someone in a breacher. In exchange, it's slow. //Whoever made this was on meth
	vision_restriction = 0

/obj/item/clothing/head/helmet/space/new_rig/unathi
	species_restricted = list("Unathi")

/obj/item/clothing/suit/space/new_rig/unathi
	species_restricted = list("Unathi")

/obj/item/clothing/shoes/magboots/rig/unathi
	species_restricted = list("Unathi")