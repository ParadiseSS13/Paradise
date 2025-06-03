/obj/effect/spawner/random/snacks
	name = "snacks spawner"
	icon_state = "donkpocket_single"
	loot = list(
		list(
			/obj/item/food/candy/candybar,
			/obj/item/reagent_containers/drinks/dry_ramen,
			/obj/item/food/chips,
			/obj/item/food/twimsts,
			/obj/item/food/sosjerky,
			/obj/item/food/no_raisin,
			/obj/item/food/pistachios,
			/obj/item/food/spacetwinkie,
			/obj/item/food/cheesiehonkers,
			/obj/item/food/tastybread,
		) = 5,

		/obj/item/food/stroopwafel = 1,
	)
	record_spawn = TRUE

/obj/effect/spawner/random/food_or_drink
	icon_state = "soup"

/obj/effect/spawner/random/food_or_drink/soup
	name = "soup spawner"
	loot_subtype_path = /obj/item/food/soup

/obj/effect/spawner/random/food_or_drink/salad
	name = "salad spawner"
	loot_subtype_path = /obj/item/food/salad

/obj/effect/spawner/random/food_or_drink/dinner
	name = "dinner spawner"
	loot = list(
		/obj/item/food/burger/bigbite,
		/obj/item/food/burger/fivealarm,
		/obj/item/food/burger/superbite,
		/obj/item/food/enchiladas,
		/obj/item/food/philly_cheesesteak,
		/obj/item/food/sandwich,
		/obj/item/food/stewedsoymeat,
	)

/obj/effect/spawner/random/food_or_drink/three_course_meal
	name = "three course meal spawner"
	spawn_all_loot = TRUE
	loot = list(
		/obj/effect/spawner/random/food_or_drink/soup,
		/obj/effect/spawner/random/food_or_drink/salad,
		/obj/effect/spawner/random/food_or_drink/dinner,
	)
