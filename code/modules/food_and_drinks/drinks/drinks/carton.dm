/obj/item/reagent_containers/drinks/carton
	name = "Generic Drink Carton"
	desc = ABSTRACT_TYPE_DESC
	possible_transfer_amounts = list(5,10,15,20,25,30)
	volume = 30
	icon_state = null

/obj/item/reagent_containers/drinks/carton/Initialize(mapload)
	if(!length(list_reagents))
		return ..()

	desc = "A carton of pending drink."
	. = ..()

	var/reagent_name = reagents.get_master_reagent().name
	name = "[reagent_name] Box"
	desc = "A carton of [lowertext(reagent_name)]."

/obj/item/reagent_containers/drinks/carton/apple
	icon_state = "applebox"
	list_reagents = list("applejuice" = 30)

/obj/item/reagent_containers/drinks/carton/banana
	icon_state = "bananabox"
	list_reagents = list("banana" = 30)

/obj/item/reagent_containers/drinks/carton/berry
	icon_state = "berrybox"
	list_reagents = list("berryjuice" = 30)

/obj/item/reagent_containers/drinks/carton/carrot
	icon_state = "carrotbox"
	list_reagents = list("carrotjuice" = 30)

/obj/item/reagent_containers/drinks/carton/grape
	icon_state = "grapebox"
	list_reagents = list("grapejuice" = 30)

/obj/item/reagent_containers/drinks/carton/lemonade
	icon_state = "lemonadebox"
	list_reagents = list("lemonade" = 30)

/obj/item/reagent_containers/drinks/carton/orange
	icon_state = "orangebox"
	list_reagents = list("orangejuice" = 30)

/obj/item/reagent_containers/drinks/carton/pineapple
	icon_state = "pineapplebox"
	list_reagents = list("pineapplejuice" = 30)

/obj/item/reagent_containers/drinks/carton/plum
	icon_state = "plumbox"
	list_reagents = list("plumjuice" = 30)

/obj/item/reagent_containers/drinks/carton/tomato
	icon_state = "tomatobox"
	list_reagents = list("tomatojuice" = 30)

/obj/item/reagent_containers/drinks/carton/vegetable
	icon_state = "vegetablebox"
	list_reagents = list("vegjuice" = 30)

/obj/item/reagent_containers/drinks/carton/watermelon
	icon_state = "watermelonbox"
	list_reagents = list("watermelonjuice" = 30)
