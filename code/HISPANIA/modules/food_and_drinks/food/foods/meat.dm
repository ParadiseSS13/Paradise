//Drake meat//

/obj/item/reagent_containers/food/snacks/drakemeat
	name = "drake meat"
	desc = "A steak of an ash drake. It's melting only with the heat of your fingers."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "drake_meat"

	list_reagents = list("protein" = 5)
	tastes = list("tender meat, like butter" = 1)
 /////////////
//Cooked Meat//
 /////////////

///Drake steak///
/obj/item/reagent_containers/food/snacks/drakesteak
	name = "drake steak"
	desc = "It look very disgusting, but smells so sweet and delicious."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "drake_steak"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "miracledrops" = 2)
	tastes = list("HEAVEN" = 1)