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

/obj/item/reagent_containers/food/snacks/sliceable/cake/slimecake
	name = "Slime cake"
	desc = "A cake made of slimes. Probably not electrified."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "slimecake"
	slice_path = /obj/item/reagent_containers/food/snacks/cakeslice/slimecake
	slices_num = 5
	bitesize = 3
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "slime" = 1)

/obj/item/reagent_containers/food/snacks/cakeslice/slimecake
	name = "slime cake slice"
	desc = "A slice of slime cake."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "slimecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#00FFFF"
	tastes = list("cake" = 5, "sweetness" = 1, "slime" = 1)
