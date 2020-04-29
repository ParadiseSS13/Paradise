/obj/item/reagent_containers/food/snacks/tinychocolate
	name = "chocolate"
	desc = "A tiny and sweet chocolate."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "tiny_chocolate"
	list_reagents = list("nutriment" = 1, "candy" = 1, "cocoa" = 1)
	filling_color = "#A0522D"
	tastes = list("chocolate" = 1)

/obj/item/reagent_containers/food/snacks/proteinbar
	name = "protein bar"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "proteinbar"
	bitesize = 5
	desc = "A nutrition bar that contain a high proportion of protein to carbohydrates and fats made by a NT Medical Branch"
	trash = /obj/item/trash/proteinbar
	filling_color = "#631212"
	list_reagents = list("protein" = 5, "sugar" = 2, "nutriment" = 5)
	tastes = list("protein" = 1)
