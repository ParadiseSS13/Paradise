/// Spawners for the Syndicate depot ruin.
/obj/effect/spawner/random/syndicate
	name = "Syndicate Area Spawner"

// Turrets

/obj/effect/spawner/random/syndicate/turret
	name = "50pc interior turret"
	icon_state = "turret"
	loot = list(/obj/machinery/porta_turret/syndicate/interior)
	spawn_loot_chance = 50

/obj/effect/spawner/random/syndicate/turret/external
	name = "50pc exterior turret"
	loot = list(/obj/machinery/porta_turret/syndicate/exterior)

// Mobs

/obj/effect/spawner/random/syndicate/mob
	name = "50pc melee syndimob"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "syndicate"
	loot = list(/mob/living/simple_animal/hostile/syndicate/depot)
	spawn_loot_chance = 50

/obj/effect/spawner/random/syndicate/medbot
	name = "50pc trap medibot"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "syndie_medbot"
	loot = list(/mob/living/simple_animal/bot/medbot/syndicate/emagged)
	spawn_loot_chance = 50

// Traps

/obj/effect/spawner/random/syndicate/pizzabomb
	name = "33pc trap pizza"
	icon_state = "pizzabox"
	loot = list(
		/obj/item/pizzabox/pizza_bomb/autoarm = 4,
		/obj/item/pizzabox/firecracker = 1,
		/obj/item/pizzabox/garlic = 1,
		/obj/item/pizzabox/hawaiian = 1,
		/obj/item/pizzabox/margherita = 1,
		/obj/item/pizzabox/meat = 1,
		/obj/item/pizzabox/mushroom = 1,
		/obj/item/pizzabox/pepperoni = 1,
		/obj/item/pizzabox/vegetable = 1,
	)

/obj/effect/spawner/random/syndicate/mine
	name = "50pc landmine"
	icon_state = "mine"
	loot = list(/obj/effect/mine/depot)
	spawn_loot_chance = 50
	layer = POINT_LAYER

/obj/effect/spawner/random/syndicate/trapped_documents
	name = "50pc trapped documents"
	icon_state = "folder"
	spawn_inside = /obj/structure/closet/secure_closet/depot
	loot = list(
		/obj/item/documents/syndicate/yellow,
		/obj/item/documents/syndicate/yellow/trapped,
	)

// Loot
/obj/effect/spawner/random/syndicate/stetchkin
	name = "syndicate depot loot, 20pct stetchkin"
	icon_state = "stetchkin"
	spawn_loot_chance = 80
	loot = list(
		/obj/item/gun/projectile/automatic/pistol,
		/obj/item/coin/antagtoken/syndicate,
		/obj/item/food/syndicake,
		/obj/item/wrench,
	)

// Layout-affecting spawns

/obj/effect/spawner/random/syndicate/walldoor
	name = "50pc door 25pc falsewall 25pc wall"
	icon_state = "walldoor"
	loot = list(
		/obj/machinery/door/airlock/hatch/syndicate = 6,
		/turf/simulated/wall/mineral/plastitanium/nodiagonal = 2,
		/obj/structure/falsewall/plastitanium = 2,
	)

/obj/effect/spawner/random/syndicate/wallvault
	name = "80pc vaultdoor 20pc wall"
	icon_state = "wallvault"
	loot = list(
		/obj/machinery/door/airlock/hatch/syndicate/vault = 4,
		/turf/simulated/wall/mineral/plastitanium/nodiagonal = 1,
	)
