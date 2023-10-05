/obj/item/reagent_containers/food/snacks/patty
	name = "patty"
	desc = "The nanotrasen patty is the patty for you and me!"
	icon_state = "patty"
	list_reagents = list("protein" = 2)
	tastes = list("meat" = 1)
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE

	///Exists purely for the crafting recipe (because itll take subtypes)
/obj/item/reagent_containers/food/snacks/patty/plain

/obj/item/reagent_containers/food/snacks/patty/bear
	name = "bear patty"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/patty/human
	name = "strange patty"

/obj/item/reagent_containers/food/snacks/patty/xeno
	name = "xenomorph patty"
	tastes = list("meat" = 1, "acid" = 1)