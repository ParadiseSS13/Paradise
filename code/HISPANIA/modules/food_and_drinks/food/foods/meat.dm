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

/obj/item/reagent_containers/food/snacks/plazmiteleg
	name = "plazmite leg"
	icon = 'icons/hispania/obj/food/food.dmi'
	desc = "A plazmite leg. It's not very edible now, but it cooks great in lava, rumors says its great for digestion."
	icon_state = "plazmite_leg_raw"
	list_reagents = list("protein" = 3, "plazmitevenom" = 5)
	tastes = list("tough meat" = 1)

/obj/item/reagent_containers/food/snacks/plazmiteleg/burn()
	visible_message("[src] finishes cooking!")
	new /obj/item/reagent_containers/food/snacks/plazmite_fingers(loc)
	qdel(src)

/obj/item/reagent_containers/food/snacks/plazmite_fingers
	name = "Plazmite Fingers"
	icon = 'icons/hispania/obj/food/food.dmi'
	desc = "A delicious, lava cooked leg."
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	icon_state = "plazmite_leg"
	trash = null
	list_reagents = list("protein" = 2, "charcoal" = 10)
	tastes = list("meat" = 1)