/obj/item/reagent_containers/food/snacks/raw_patty
	name = "raw patty"
	desc = "I'm.....NOT REAAADDYY."
	icon_state = "raw_patty"
	list_reagents = list("protein" = 2)
	tastes = list("meat" = 1)
	w_class = WEIGHT_CLASS_SMALL
	var/patty_type = /obj/item/reagent_containers/food/snacks/patty/plain



/obj/item/reagent_containers/food/snacks/raw_patty/bear
	name = "raw bear patty"
	tastes = list("meat" = 1, "salmon" = 1)
	patty_type = /obj/item/reagent_containers/food/snacks/patty/bear

/obj/item/reagent_containers/food/snacks/raw_patty/human
	name = "strange raw patty"
	patty_type = /obj/item/reagent_containers/food/snacks/patty/human

/obj/item/reagent_containers/food/snacks/raw_patty/xeno
	name = "raw xenomorph patty"
	patty_type = /obj/item/reagent_containers/food/snacks/patty/xeno
	tastes = list("meat" = 1, "acid" = 1)



