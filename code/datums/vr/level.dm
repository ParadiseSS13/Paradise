//death types VR_DROP_NONE, VR_DROP_ALL, VR_DROP_BLACKLIST, VR_DROP_WHITELIST


/datum/map_template/vr/level
	prefix = "_maps/map_files/vr/"

/datum/map_template/vr/level/lobby
	id = "lobby"
	suffix = "lobby.dmm"
	name = "Virtual Hub Facility"
	description = "This is the lobby. The hub for all things VR."
	death_type = VR_DROP_NONE
	outfit = /datum/outfit/vr/vr_basic

/datum/map_template/vr/level/roman
	id = "roman"
	suffix = "blood_and_sand.dmm"
	name = "Blood and Sand Arena"
	description = "To the Death!"
	death_type = VR_DROP_BLACKLIST
	drop_blacklist = list(/obj/item/clothing/under/roman, /obj/item/clothing/shoes/roman, /obj/item/weapon/shield/riot/roman, /obj/item/clothing/head/helmet/roman)
	loot_common = list(/obj/item/weapon/twohanded/spear, /obj/item/weapon/kitchen/knife/ritual, /obj/item/weapon/restraints/legcuffs/bola, /obj/item/weapon/twohanded/bostaff,
						/obj/item/weapon/storage/backpack/quiver/full, /obj/item/weapon/gun/projectile/bow, /obj/item/weapon/grenade/plastic/c4)
	loot_rare = list(/obj/item/weapon/claymore, /obj/item/weapon/gun/energy/taser, /obj/item/weapon/twohanded/energizedfireaxe, /obj/item/weapon/grenade/syndieminibomb,
						/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised, /obj/item/weapon/twohanded/mjollnir, /obj/item/weapon/twohanded/singularityhammer,
						/obj/item/weapon/twohanded/knighthammer)
	outfit = /datum/outfit/vr/roman