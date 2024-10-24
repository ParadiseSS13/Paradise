/// Spawners for the Syndicate depot ruin.
/obj/effect/spawner/random/syndicate
	name = "Syndicate Area Spawner"
	icon = 'icons/effects/random_spawners.dmi'

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
	icon_state = "syndie_depot"
	loot = list(/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot)
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
	spawn_inside = /obj/structure/closet/secure_closet/syndicate/depot
	loot = list(
		/obj/item/documents/syndicate/yellow,
		/obj/item/documents/syndicate/yellow/trapped,
	)

// Loot
/obj/effect/spawner/random/syndicate/loot
	spawn_inside = /obj/structure/closet/secure_closet/syndicate/depot

/obj/effect/spawner/random/syndicate/loot/common
	name = "syndicate depot loot, common"
	icon_state = "loot"
	spawn_loot_chance = 50
	// Loot schema: costumes, toys, useless gimmick items
	loot = list(
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/clothing/shoes/magboots/syndie,
		/obj/item/clothing/under/syndicate,
		/obj/item/coin/antagtoken/syndicate,
		/obj/item/deck/cards/syndicate,
		/obj/item/soap/syndie,
		/obj/item/storage/box/syndie_kit/space,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/storage/secure/briefcase/syndie,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/suppressor,
		/obj/item/toy/syndicateballoon,
	)

/obj/effect/spawner/random/syndicate/loot/stetchkin
	name = "syndicate depot loot, 20pct stetchkin"
	icon_state = "stetchkin"
	spawn_inside = null
	spawn_loot_chance = 80
	loot = list(
		/obj/item/gun/projectile/automatic/pistol,
		/obj/item/coin/antagtoken/syndicate,
		/obj/item/food/syndicake,
		/obj/item/wrench,
	)

/obj/effect/spawner/random/syndicate/loot/rare
	name = "syndicate depot loot, rare"
	icon_state = "doubleloot"
	spawn_loot_chance = 50
	// Basic stealth, utility and environmental gear.
	loot = list(
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/clothing/gloves/color/black/thief,
		/obj/item/clothing/shoes/chameleon/noslip,
		/obj/item/clothing/suit/jacket/bomber/syndicate,
		/obj/item/clothing/suit/storage/iaa/blackjacket/armored,
		/obj/item/clothing/under/chameleon,
		/obj/item/clothing/under/syndicate/silicon_cham,
		/obj/item/flash/cameraflash,
		/obj/item/gun/projectile/automatic/toy/pistol/riot,
		/obj/item/lighter/zippo/gonzofist,
		/obj/item/mod/control/pre_equipped/traitor,
		/obj/item/mod/module/chameleon,
		/obj/item/mod/module/holster/hidden,
		/obj/item/mod/module/noslip,
		/obj/item/mod/module/visor/night,
		/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium,
		/obj/item/stack/sheet/mineral/gold{amount = 20},
		/obj/item/stack/sheet/mineral/plasma{amount = 20},
		/obj/item/stack/sheet/mineral/silver{amount = 20},
		/obj/item/stack/sheet/mineral/uranium{amount = 20},
		/obj/item/stamp/chameleon,
		/obj/item/storage/backpack/duffel/syndie/med/surgery,
		/obj/item/storage/backpack/satchel_flat,
		/obj/item/storage/belt/military,
		/obj/item/storage/box/syndie_kit/camera_bug,
		/obj/item/storage/firstaid/tactical,
	)

/obj/effect/spawner/random/syndicate/loot/officer
	name = "syndicate depot loot, officer"
	spawn_loot_chance = 40
	// Primarily utility items with occasional low damage weaponry.
	loot = list(
		/obj/item/borg/upgrade/selfrepair,
		/obj/item/borg/upgrade/syndicate,
		/obj/item/clothing/glasses/hud/security/chameleon,
		/obj/item/clothing/glasses/thermal,
		/obj/item/clothing/shoes/magboots/elite,
		/obj/item/door_remote/omni/access_tuner,
		/obj/item/encryptionkey/binary,
		/obj/item/jammer,
		/obj/item/mod/module/power_kick,
		/obj/item/mod/module/stealth,
		/obj/item/mod/module/visor/thermal,
		/obj/item/pen/edagger,
		/obj/item/pinpointer/advpinpointer,
		/obj/item/stack/sheet/mineral/diamond{amount = 10},
		/obj/item/stack/sheet/mineral/uranium{amount = 10},
		/obj/item/storage/box/syndidonkpockets,
		/obj/item/storage/box/syndie_kit/stechkin,
	)

/obj/effect/spawner/random/syndicate/loot/armory
	name = "syndicate depot loot, armory"
	spawn_inside = /obj/structure/closet/secure_closet/syndicate/depot/armory
	// Combat orientated items that could give the player an advantage if an antag messes with them.
	loot = list(
		/obj/item/autosurgeon/organ/syndicate/oneuse/razorwire,
		/obj/item/chameleon,
		/obj/item/clothing/gloves/fingerless/rapid,
		/obj/item/CQC_manual,
		/obj/item/gun/medbeam,
		/obj/item/melee/energy/sword/saber,
		/obj/item/reagent_containers/hypospray/autoinjector/stimulants,
		/obj/item/shield/energy,
		/obj/item/storage/box/syndie_kit/teleporter,
		/obj/item/weaponcrafting/gunkit/universal_gun_kit,
		/obj/item/mod/control/pre_equipped/traitor_elite
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
