/obj/item/reagent_containers/food/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bandaid"
	item_state = "bandaid"
	possible_transfer_amounts = null
	volume = 40
	apply_type = TOUCH
	apply_method = "apply"
	transfer_efficiency = 0.5 //patches aren't as effective at getting chemicals into the bloodstream.

/obj/item/reagent_containers/food/pill/patch/afterattack(obj/target, mob/user , proximity)
	return // thanks inheritance again

/obj/item/reagent_containers/food/pill/patch/styptic
	name = "healing patch"
	desc = "Helps with brute injuries."
	icon_state = "bandaid_brute"
	instant_application = 1
	list_reagents = list("styptic_powder" = 40)

/obj/item/reagent_containers/food/pill/patch/silver_sulf
	name = "burn patch"
	desc = "Helps with burn injuries."
	icon_state = "bandaid_burn"
	instant_application = 1
	list_reagents = list("silver_sulfadiazine" = 40)

/obj/item/reagent_containers/food/pill/patch/synthflesh
	name = "syntheflesh patch"
	desc = "Helps with burn injuries."
	icon_state = "bandaid_med"
	instant_application = 1
	list_reagents = list("synthflesh" = 20)

/obj/item/reagent_containers/food/pill/patch/nicotine
	name = "nicotine patch"
	desc = "Helps temporarily curb the cravings of nicotine dependency."
	list_reagents = list("nicotine" = 20)

/obj/item/reagent_containers/food/pill/patch/jestosterone
	name = "jestosterone patch"
	desc = "Helps with brute injuries if the affected person is a clown, otherwise inflicts various annoying effects."
	icon_state = "bandaid_clown"
	list_reagents = list("jestosterone" = 30)
