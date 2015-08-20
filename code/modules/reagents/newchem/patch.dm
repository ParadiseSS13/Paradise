/obj/item/weapon/reagent_containers/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bandaid"
	item_state = "bandaid"
	possible_transfer_amounts = null
	volume = 50
	apply_type = TOUCH
	apply_method = "apply"

/obj/item/weapon/reagent_containers/pill/patch/New()
	..()
	icon_state = "bandaid"

/obj/item/weapon/reagent_containers/pill/patch/afterattack(obj/target, mob/user , proximity)
	return // thanks inheritance again

/obj/item/weapon/reagent_containers/pill/patch/styptic
	name = "healing patch"
	desc = "Helps with brute injuries."
	New()
		..()
		reagents.add_reagent("styptic_powder", 40)

/obj/item/weapon/reagent_containers/pill/patch/silver_sulf
	name = "burn patch"
	desc = "Helps with burn injuries."
	New()
		..()
		reagents.add_reagent("silver_sulfadiazine", 40)

/obj/item/weapon/reagent_containers/pill/patch/synthflesh
	name = "syntheflesh patch"
	desc = "Helps with burn injuries."
	New()
		..()
		reagents.add_reagent("synthflesh", 20)