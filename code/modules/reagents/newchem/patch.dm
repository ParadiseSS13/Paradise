/obj/item/weapon/reagent_containers/food/pill/patch
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

/obj/item/weapon/reagent_containers/food/pill/patch/afterattack(obj/target, mob/user , proximity)
	return // thanks inheritance again

/obj/item/weapon/reagent_containers/food/pill/patch/styptic
	name = "healing patch"
	desc = "Helps with brute injuries."
	icon_state = "bandaid_brute"
	instant_application = 1

/obj/item/weapon/reagent_containers/food/pill/patch/styptic/New()
	..()
	reagents.add_reagent("styptic_powder", 40)

/obj/item/weapon/reagent_containers/food/pill/patch/silver_sulf
	name = "burn patch"
	desc = "Helps with burn injuries."
	icon_state = "bandaid_burn"
	instant_application = 1

/obj/item/weapon/reagent_containers/food/pill/patch/silver_sulf/New()
	..()
	reagents.add_reagent("silver_sulfadiazine", 40)

/obj/item/weapon/reagent_containers/food/pill/patch/synthflesh
	name = "syntheflesh patch"
	desc = "Helps with burn injuries."
	instant_application = 1

/obj/item/weapon/reagent_containers/food/pill/patch/synthflesh/New()
	..()
	reagents.add_reagent("synthflesh", 20)

/obj/item/weapon/reagent_containers/food/pill/patch/nicotine
	name = "nicotine patch"
	desc = "Helps temporarily curb the cravings of nicotine dependency."

/obj/item/weapon/reagent_containers/food/pill/patch/nicotine/New()
	..()
	reagents.add_reagent("nicotine", 20)