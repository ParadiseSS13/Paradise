/datum/quirk/meal_prepper
	name = "Meal Prepper"
	desc = "You thought ahead and pre-packed a meal for the day."
	cost = 0
	item_to_give = /obj/item/storage/box/papersack/prepped_meal

/obj/item/storage/box/papersack/prepped_meal
	name = "packed meal"
	var/list/entree_options = list(
		/obj/item/food/sandwich,
		/obj/item/food/toastedsandwich,
		/obj/item/food/jellysandwich/cherry,
		/obj/item/food/grilledcheese,
		/obj/item/food/burger/cheese,
		/obj/item/food/blt,
		/obj/item/food/philly_cheesesteak,
		/obj/item/food/sliced/hawaiian_pizza,
		/obj/item/food/sliced/pepperoni_pizza,
		/obj/item/food/meatkebab,
		/obj/item/food/salmonsteak, // If anyone microwaves their leftover fish in the workplace it should be on sight
		/obj/item/food/shrimp_skewer,
		/obj/item/food/omelette,
	)
	var/list/snack_options = list(
		/obj/item/food/chips,
		/obj/item/food/sosjerky,
		/obj/item/food/pistachios,
		/obj/item/food/no_raisin,
		/obj/item/food/stroopwafel,
		/obj/item/food/candy/toffee,
		/obj/item/food/candy/chocolate_orange,
		/obj/item/food/sliced/mothmallow,
		/obj/item/food/sliced/apple_cake,
		/obj/item/food/sliced/banarnarbread,
	)
	var/list/drink_options = list(
		/obj/item/reagent_containers/drinks/h_chocolate,
		/obj/item/reagent_containers/drinks/tea,
		/obj/item/reagent_containers/drinks/cans/cola,
		/obj/item/reagent_containers/drinks/cans/space_mountain_wind,
		/obj/item/reagent_containers/drinks/cans/dr_gibb,
		/obj/item/reagent_containers/drinks/cans/space_up,
		/obj/item/reagent_containers/drinks/cans/iced_tea,
		/obj/item/reagent_containers/drinks/cans/starkist,
		/obj/item/reagent_containers/drinks/bottle/beer, // Don't tell your boss
		/obj/item/reagent_containers/drinks/carton/apple,
		/obj/item/reagent_containers/drinks/carton/banana,
		/obj/item/reagent_containers/drinks/carton/berry,
		/obj/item/reagent_containers/drinks/carton/carrot,
		/obj/item/reagent_containers/drinks/carton/grape,
		/obj/item/reagent_containers/drinks/carton/lemonade,
		/obj/item/reagent_containers/drinks/carton/orange,
		/obj/item/reagent_containers/drinks/carton/pineapple,
		/obj/item/reagent_containers/drinks/carton/plum,
		/obj/item/reagent_containers/drinks/carton/tomato,
		/obj/item/reagent_containers/drinks/carton/vegetable,
		/obj/item/reagent_containers/drinks/carton/watermelon,
	)

/obj/item/storage/box/papersack/prepped_meal/populate_contents()
	var/entree = pick(entree_options)
	var/snack = pick(snack_options)
	var/drink = pick(drink_options)
	new entree (src)
	new snack (src)
	new drink (src)
