/// HISPANIA DRINKS
/obj/item/reagent_containers/food/drinks/hispania
	icon = 'icons/hispania/obj/drinks.dmi'

/obj/item/reagent_containers/food/drinks/hispania/minimilk
	name = "small milk carton"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "mini-milk"
	item_state = "mini-milk"
	volume = 30
	list_reagents = list("milk" = 30)

/obj/item/reagent_containers/food/drinks/hispania/minimilk/minimilk_chocolate
	name = "small chocolate milk carton"
	desc = "It's milk! This one is in delicious chocolate flavour."
	icon_state = "mini_milk_choco"
	item_state = "mini_milk_choco"
	list_reagents = list("chocolate_milk" = 30)

/obj/item/reagent_containers/glass/beaker/waterbottle/fitnessshaker
	name = "black fitness shaker"
	desc = "Big enough to contain enough protein to get perfectly swole. Don't mind the bits."
	icon = 'icons/hispania/obj/drinks.dmi'
	icon_state = "fitness_cup_black"
	item_state = "fitness_cup_black"
	materials = list(MAT_PLASTIC = 500)
	volume = 50
	list_reagents = list("nutriment" = 5, "iron" = 15, "protein" = 5, "water" = 30)

/obj/item/reagent_containers/glass/beaker/waterbottle/fitnessshaker/red
	name = "red fitness shaker"
	icon_state = "fitness_cup_red"
	item_state = "fitness_cup_red"

/obj/item/reagent_containers/glass/beaker/waterbottle/fitnessshaker/blue
	name = "blue fitness shaker"
	icon_state = "fitness_cup_blue"
	item_state = "fitness_cup_blue"
