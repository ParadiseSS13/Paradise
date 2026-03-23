/obj/item/reagent_containers/drinks/carton
	name = "Generic Drink Carton"
	desc = ABSTRACT_TYPE_DESC
	possible_transfer_amounts = list(5,10,15,20,25,30)
	volume = 30
	icon = 'icons/obj/juice_box.dmi'
	icon_state = null

/obj/item/reagent_containers/drinks/carton/Initialize(mapload)
	if(!length(list_reagents))
		return ..()

	desc = "A carton of pending drink."
	. = ..()

	var/datum/reagent/drink_reagent = reagents.get_master_reagent()
	name = "Stationside [drink_reagent.name] Box"
	desc = "A carton of Stationside brand [lowertext(drink_reagent.name)]."

/obj/item/reagent_containers/drinks/carton/apple
	icon_state = "apple_box"
	list_reagents = list("applejuice" = 30)

/obj/item/reagent_containers/drinks/carton/banana
	icon_state = "banana_box"
	list_reagents = list("banana" = 30)

/obj/item/reagent_containers/drinks/carton/berry
	icon_state = "berry_box"
	list_reagents = list("berryjuice" = 30)

/obj/item/reagent_containers/drinks/carton/carrot
	icon_state = "carrot_box"
	list_reagents = list("carrotjuice" = 30)

/obj/item/reagent_containers/drinks/carton/grape
	icon_state = "grape_box"
	list_reagents = list("grapejuice" = 30)

/obj/item/reagent_containers/drinks/carton/lemonade
	icon_state = "lemonade_box"
	list_reagents = list("lemonade" = 30)

/obj/item/reagent_containers/drinks/carton/orange
	icon_state = "orange_box"
	list_reagents = list("orangejuice" = 30)

/obj/item/reagent_containers/drinks/carton/pineapple
	icon_state = "pineapple_box"
	list_reagents = list("pineapplejuice" = 30)

/obj/item/reagent_containers/drinks/carton/plum
	icon_state = "plum_box"
	list_reagents = list("plumjuice" = 30)

/obj/item/reagent_containers/drinks/carton/tomato
	icon_state = "tomato_box"
	list_reagents = list("tomatojuice" = 30)

/obj/item/reagent_containers/drinks/carton/vegetable
	icon_state = "vegetable_box"
	list_reagents = list("vegjuice" = 30)

/obj/item/reagent_containers/drinks/carton/watermelon
	icon_state = "watermelon_box"
	list_reagents = list("watermelonjuice" = 30)
