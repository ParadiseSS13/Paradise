// CC loot pool
/datum/spawn_pool/centcommloot
	id = "central_command_spawn_pool"
	available_points = INFINITY

/obj/effect/spawner/random/pool/centcommloot
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "giftbox"
	spawn_pool_id = "central_command_spawn_pool"

/obj/effect/spawner/random/pool/spaceloot/syndicate/common/depot/centcomm
	spawn_inside = null
	spawn_pool_id = "central_command_spawn_pool"

/obj/effect/spawner/random/pool/spaceloot/syndicate/rare/depot/centcomm
	spawn_inside = null
	spawn_pool_id = "central_command_spawn_pool"

/obj/effect/spawner/random/pool/spaceloot/syndicate/officer/depot/centcomm
	spawn_inside = null
	spawn_pool_id = "central_command_spawn_pool"

/obj/effect/spawner/random/pool/spaceloot/syndicate/armory/depot/centcomm
	spawn_inside = null
	spawn_pool_id = "central_command_spawn_pool"

/obj/effect/spawner/random/pool/centcommloot/syndicate/mixed
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/syndicate/common/depot/centcomm = 30,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/rare/depot/centcomm = 20,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/officer/depot/centcomm = 5,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/armory/depot/centcomm = 1,
	)

// space loot pool
/datum/spawn_pool/spaceloot
	available_points = 2200 // tweak available points considering centcomm and away mission

/obj/effect/spawner/random/pool/spaceloot/mechtransport_new/mecha
	point_value = 100
	loot = list(/obj/mecha/combat/durand/old/mechtransport_new)

/obj/effect/spawner/random/pool/spaceloot/mechtransport_new/mecha_equipment
	point_value = 40
	spawn_all_loot = TRUE
	loot = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/honker,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
		)

/obj/effect/spawner/random/pool/spaceloot/modsuit_syndie/nuclear
	point_value = 110
	spawn_loot_chance = 30
	loot = list(/obj/machinery/suit_storage_unit/syndicate)

/obj/effect/spawner/random/pool/spaceloot/modsuit_syndie/corpse
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatecommando)

/obj/effect/spawner/random/pool/spaceloot/syndicate/common_rare
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/syndicate/common = 3,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/rare = 2,
	)

/obj/effect/spawner/random/pool/spaceloot/laser
	point_value = 30
	spawn_loot_chance = 40
	loot = list(
		/obj/item/gun/energy/laser,
		/obj/item/gun/energy/laser/retro,
	)

/obj/effect/spawner/random/pool/spaceloot/mining_tool
	point_value = 15
	loot = list(
		/obj/item/pickaxe = 50,
		/obj/item/pickaxe/safety = 30,
		/obj/item/pickaxe/mini = 20,
		/obj/item/pickaxe/silver = 10,
		/obj/item/pickaxe/gold = 9,
		/obj/item/pickaxe/diamond = 7,
		/obj/item/pickaxe/drill = 15,
		/obj/item/pickaxe/drill/diamonddrill = 5,
		/obj/item/pickaxe/drill/jackhammer = 3,
		/obj/item/gun/energy/plasmacutter = 5,
		/obj/item/gun/energy/plasmacutter/adv = 3,
		/obj/item/kinetic_crusher = 3,
		/obj/item/gun/energy/kinetic_accelerator = 3,
		/obj/item/gun/energy/kinetic_accelerator/pistol = 3,
		/obj/item/gun/energy/kinetic_accelerator/experimental,
	)

/obj/effect/spawner/random/pool/spaceloot/security/modsuit
	point_value = 75
	spawn_loot_chance = 45
	loot = list(
		/obj/machinery/suit_storage_unit/security/space = 9,
		/obj/machinery/suit_storage_unit/security/space/safeguard,
	)
