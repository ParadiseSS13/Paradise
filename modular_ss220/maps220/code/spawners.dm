/* Lootdrop food spawners */
/obj/effect/spawner/lootdrop/CCfood

/obj/effect/spawner/lootdrop/CCfood/desert
	lootcount = 5
	loot = list(
		/obj/item/reagent_containers/food/snacks/baguette=10,
		/obj/item/reagent_containers/food/snacks/applepie=10,
		/obj/item/reagent_containers/food/snacks/bananabreadslice=10,
		/obj/item/reagent_containers/food/snacks/bananacakeslice=10,
		/obj/item/reagent_containers/food/snacks/carrotcakeslice=10,
		/obj/item/reagent_containers/food/snacks/croissant=10,
		/obj/item/reagent_containers/food/drinks/cans/cola=10,""=70)

/obj/effect/spawner/lootdrop/CCfood/meat
	lootcount = 5
	loot = list(
		/obj/item/reagent_containers/food/snacks/lasagna=10,
		/obj/item/reagent_containers/food/snacks/burger/bigbite=10,
		/obj/item/reagent_containers/food/snacks/fishandchips=10,
		/obj/item/reagent_containers/food/snacks/fishburger=10,
		/obj/item/reagent_containers/food/snacks/hotdog=10,
		/obj/item/reagent_containers/food/snacks/meatpie=10,
		/obj/item/reagent_containers/food/drinks/cans/cola=10,""=70)

/obj/effect/spawner/lootdrop/CCfood/alcohol
	lootcount = 1
	loot = list(
		/obj/item/reagent_containers/food/drinks/flask/detflask=10,
		/obj/item/reagent_containers/food/drinks/cans/tonic=10,
		/obj/item/reagent_containers/food/drinks/cans/thirteenloko=10,
		/obj/item/reagent_containers/food/drinks/cans/synthanol=10,
		/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind=10,
		/obj/item/reagent_containers/food/drinks/cans/lemon_lime=10,""=70)

/* Lootdrop */
/obj/effect/spawner/lootdrop/maintenance
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'

/obj/effect/spawner/lootdrop/maintenance/three
	icon_state = "trippleloot"

/obj/effect/spawner/lootdrop/maintenance/five
	name = "maintenance loot spawner (5 items)"
	icon_state = "moreloot"
	lootcount = 5

/obj/effect/spawner/lootdrop/trash
	name = "trash spawner"
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "trash"
	loot = list(
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
		""=20
		)

/* Random spawners */
/obj/effect/spawner/random_spawners/mod
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "mod"

/obj/effect/spawner/random_spawners/syndicate/loot
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "common"

/obj/effect/spawner/random_spawners/syndicate/loot/level2
	icon_state = "rare"

/obj/effect/spawner/random_spawners/syndicate/loot/level3
	icon_state = "officer"

/obj/effect/spawner/random_spawners/syndicate/loot/level4
	icon_state = "armory"

/obj/effect/spawner/random_spawners/syndicate/loot/stetchkin
	icon_state = "stetchkin"

/obj/item/reagent_containers/pill/random_drugs
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "pills"

/obj/item/reagent_containers/pill/random_drugs/Initialize(mapload)
	icon = 'icons/obj/chemical.dmi'
	. = ..()

/obj/item/reagent_containers/food/drinks/bottle/random_drink
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "drinks"

/obj/item/reagent_containers/food/drinks/bottle/random_drink/Initialize(mapload)
	icon = 'icons/obj/drinks.dmi'
	. = ..()
