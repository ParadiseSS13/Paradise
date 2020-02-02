/obj/item/reagent_containers/food/snacks/plazmiteleg
	name = "plazmite leg"
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
	desc = "A delicious, lava cooked leg."
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	icon_state = "plazmite_leg"
	trash = null
	list_reagents = list("protein" = 2, "charcoal" = 10)
	tastes = list("meat" = 1)