// MARK: Food
/obj/effect/spawner/random/ccfood


/obj/effect/spawner/random/ccfood/dessert
	spawn_loot_count = 3
	loot = list(
		/obj/item/food/baguette,
		/obj/item/food/applepie,
		/obj/item/food/sliced/banana_bread,
		/obj/item/food/sliced/banana_cake,
		/obj/item/food/sliced/carrot_cake,
		/obj/item/food/croissant,
		/obj/item/reagent_containers/drinks/cans/cola,
		)

/obj/effect/spawner/random/ccfood/meat
	spawn_loot_count = 3
	loot = list(
		/obj/item/food/lasagna,
		/obj/item/food/burger/bigbite,
		/obj/item/food/fishandchips,
		/obj/item/food/fishburger,
		/obj/item/food/hotdog,
		/obj/item/food/meatpie,
		/obj/item/reagent_containers/drinks/cans/cola,
		)

/obj/effect/spawner/random/ccfood/alcohol
	spawn_loot_count = 1
	loot = list(
		/obj/item/reagent_containers/drinks/flask/detflask,
		/obj/item/reagent_containers/drinks/cans/tonic,
		/obj/item/reagent_containers/drinks/cans/thirteenloko,
		/obj/item/reagent_containers/drinks/cans/synthanol,
		/obj/item/reagent_containers/drinks/cans/space_mountain_wind,
		/obj/item/reagent_containers/drinks/cans/lemon_lime,
		)

// MARK: Loot
/obj/effect/spawner/random/loot
	icon = 'icons/effects/random_spawners.dmi'

/obj/effect/spawner/random/loot/modkit
	name = "random modkit"
	icon_state = "donkpocket_single" // i'm not gonna sprite this!
	loot = list(
		/obj/item/borg/upgrade/modkit/range,
		/obj/item/borg/upgrade/modkit/damage,
		/obj/item/borg/upgrade/modkit/tracer,
		/obj/item/borg/upgrade/modkit/tracer/adjustable,
		/obj/item/borg/upgrade/modkit/lifesteal,
		/obj/item/borg/upgrade/modkit/cooldown,
		/obj/item/borg/upgrade/modkit/chassis_mod,
		/obj/item/borg/upgrade/modkit/chassis_mod/orange,
		/obj/item/borg/upgrade/modkit/aoe/turfs,
	)

/obj/effect/spawner/random/loot/mining_tool
	name = "random mining tool"
	loot = list(
		// total of 21
		/obj/item/pickaxe = 7,
		/obj/item/pickaxe/safety = 7,
		/obj/item/pickaxe/mini = 7,

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
	)

/obj/effect/spawner/random/loot/laser
	name = "laser 60pc"
	icon_state = "stetchkin"
	spawn_loot_chance = 60
	loot = list(/obj/item/gun/energy/laser)

/obj/effect/spawner/random/loot/laser/retro
	loot = list(/obj/item/gun/energy/laser/retro)

/obj/effect/spawner/random/loot/laser/advanced
	loot = list(
		/obj/item/gun/energy/laser,
		/obj/item/gun/energy/lasercannon,
	)

/obj/effect/spawner/random/loot/docs
	icon_state = "folder"

/obj/effect/spawner/random/loot/docs/syndie
	name = "syndie documents"
	loot = list(
		/obj/item/folder/syndicate,
		/obj/item/folder/syndicate/red,
		/obj/item/folder/syndicate/blue,
		/obj/item/folder/syndicate/yellow,
		/obj/item/folder/syndicate/mining,
	)

/obj/effect/spawner/random/loot/ussp_minor
	spawn_scatter_radius = 1
	spawn_loot_count = 6
	spawn_loot_double = FALSE
	loot = list(
		/obj/item/clothing/under/new_soviet = 50,
		/obj/item/clothing/suit/sovietcoat = 50,
		/obj/item/clothing/head/ushanka = 50,
		/obj/item/food/grown/potato = 50,
		/obj/item/reagent_containers/drinks/bottle/vodka/badminka = 50,
		/obj/item/clothing/head/sovietsidecap = 50,
		/obj/item/flag/ussp = 30,
		/obj/item/ammo_box/a762,
	)

/obj/effect/spawner/random/loot/bluespace_tap/food_mixed
	loot = list(
		/obj/effect/spawner/random/bluespace_tap/food_common = 6,
		/obj/effect/spawner/random/bluespace_tap/food_uncommon = 3,
		/obj/effect/spawner/random/bluespace_tap/food_rare,
	)

/obj/effect/spawner/random/loot/gateway_chainsaw
	spawn_loot_chance = 20
	loot = list(/obj/item/butcher_chainsaw/gateway)

/obj/effect/spawner/random/syndie_mob_loot/ranged
	spawn_loot_chance = 1
	loot = list(
		/obj/item/gun/projectile/automatic/pistol = 8,
		/obj/item/gun/projectile/revolver/fake,

		/obj/item/gun/projectile/revolver, // 0.1%
	)

/obj/effect/spawner/random/maintenance
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'

// MARK: Office toys spawners
/obj/effect/spawner/random/officetoys
	name = "office desk toy spawner"
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "officetoy"
	loot = list(
		/obj/item/toy/desk/officetoy,
		/obj/item/toy/desk/dippingbird,
		/obj/item/toy/desk/newtoncradle,
		/obj/item/toy/desk/fan,
		/obj/item/hourglass
	)

// MARK: Random spawners
/obj/effect/spawner/random/mod
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "mod"

/obj/item/reagent_containers/pill/random_drugs
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "pills"

/obj/item/reagent_containers/pill/random_drugs/Initialize(mapload)
	icon = 'icons/obj/chemical.dmi'
	. = ..()

/obj/item/reagent_containers/drinks/bottle/random_drink
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "drinks"

/obj/item/reagent_containers/drinks/bottle/random_drink/Initialize(mapload)
	icon = 'icons/obj/drinks.dmi'
	. = ..()

/obj/effect/spawner/random/hostile_fauna
	name = "hostile fauna spawner"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "Carp"
	spawn_loot_chance = 65
	loot = list(
		/mob/living/simple_animal/hostile/faithless = 30,
		/mob/living/simple_animal/hostile/creature = 20,
		/mob/living/simple_animal/hostile/netherworld = 10,
		/mob/living/simple_animal/hostile/netherworld/migo = 10,
		/mob/living/simple_animal/hostile/hellhound = 5,

		/mob/living/simple_animal/hostile/hellhound/tear,
	)

/obj/effect/spawner/random/hostile_fauna/wildwest
	loot = list(
		/mob/living/simple_animal/hostile/faithless{faction = list("wildwest")} = 30,
		/mob/living/simple_animal/hostile/creature{faction = list("wildwest")} = 20,
		/mob/living/simple_animal/hostile/netherworld{faction = list("wildwest")} = 10,
		/mob/living/simple_animal/hostile/netherworld/migo{faction = list("wildwest")} = 10,
		/mob/living/simple_animal/hostile/hellhound{faction = list("wildwest")} = 5,

		/mob/living/simple_animal/hostile/hellhound/tear{faction = list("wildwest")},
	)

/obj/effect/spawner/random/hostile_fauna/caves
	loot = list(
		/mob/living/simple_animal/hostile/faithless{maxbodytemp = 1500} = 30,
		/mob/living/simple_animal/hostile/creature{maxbodytemp = 1500} = 20,
		/mob/living/simple_animal/hostile/netherworld{maxbodytemp = 1500} = 10,
		/mob/living/simple_animal/hostile/netherworld/migo{maxbodytemp = 1500} = 10,
		/mob/living/simple_animal/hostile/hellhound{maxbodytemp = 1500} = 5,

		/mob/living/simple_animal/hostile/hellhound/tear{maxbodytemp = 1500},
	)

/obj/effect/spawner/random/hostile_fauna/spider
	name = "hostile spider spawner"
	loot = list(
		/mob/living/simple_animal/hostile/poison/giant_spider = 6,
		/mob/living/simple_animal/hostile/poison/giant_spider/hunter = 3,
		/mob/living/simple_animal/hostile/poison/giant_spider/nurse,
	)

/obj/effect/spawner/random/hostile_fauna/spider/caves
	loot = list(
		/mob/living/simple_animal/hostile/poison/giant_spider{maxbodytemp = 1500} = 6,
		/mob/living/simple_animal/hostile/poison/giant_spider/hunter{maxbodytemp = 1500} = 3,
		/mob/living/simple_animal/hostile/poison/giant_spider/nurse{maxbodytemp = 1500},
	)

// MARK: Misc
/obj/effect/spawner/random/trash
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'

/obj/effect/spawner/random/trash/Initialize(mapload)
	. = ..()
	loot += list(
		list(
			/obj/item/trash/bowl,
			/obj/item/trash/can,
			/obj/item/trash/candle,
			/obj/item/trash/candy,
			/obj/item/trash/cheesie,
			/obj/item/trash/chips,
			/obj/item/trash/fried_vox,
			/obj/item/trash/gum,
			/obj/item/trash/liquidfood,
			/obj/item/trash/pistachios,
			/obj/item/trash/plate,
			/obj/item/trash/popcorn,
			/obj/item/trash/raisins,
			/obj/item/trash/semki,
			/obj/item/trash/snack_bowl,
			/obj/item/trash/sosjerky,
			/obj/item/trash/spacetwinkie,
			/obj/item/trash/spentcasing,
			/obj/item/trash/syndi_cakes,
			/obj/item/trash/tapetrash,
			/obj/item/trash/tastybread,
			/obj/item/trash/tray,
			/obj/item/trash/waffles,
			/obj/item/trash/vulpix_chips,
			/obj/item/trash/foodtray,
		) = 5,
	)
