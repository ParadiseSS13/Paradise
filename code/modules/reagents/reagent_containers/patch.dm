/obj/item/reagent_containers/food/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bandaid"
	item_state = "bandaid"
	possible_transfer_amounts = null
	volume = 20
	container_type = 0 //nooo my insta-kill patch!!!
	apply_type = REAGENT_TOUCH
	apply_method = "apply"
	transfer_efficiency = 0.5 //patches aren't as effective at getting chemicals into the bloodstream.
	temperature_min = 270
	temperature_max = 350
	var/needs_to_apply_reagents = TRUE

/obj/item/reagent_containers/food/pill/patch/attack(mob/living/carbon/M, mob/user, def_zone)
	if(!istype(M))
		return FALSE
	bitesize = 0
	if(M.eat(src, user))
		user.drop_item()
		forceMove(M)
		LAZYADD(M.processing_patches, src)
		return TRUE
	return FALSE

/obj/item/reagent_containers/food/pill/patch/afterattack(obj/target, mob/user , proximity)
	return // thanks inheritance again

/obj/item/reagent_containers/food/pill/patch/styptic
	name = "healing patch"
	desc = "Helps with brute injuries."
	icon_state = "bandaid_brute"
	instant_application = 1
	list_reagents = list("styptic_powder" = 20)

/obj/item/reagent_containers/food/pill/patch/styptic/small
	name = "healing mini-patch"
	list_reagents = list("styptic_powder" = 10)

/obj/item/reagent_containers/food/pill/patch/silver_sulf
	name = "burn patch"
	desc = "Helps with burn injuries."
	icon_state = "bandaid_burn"
	instant_application = 1
	list_reagents = list("silver_sulfadiazine" = 20)

/obj/item/reagent_containers/food/pill/patch/silver_sulf/small
	name = "burn mini-patch"
	list_reagents = list("silver_sulfadiazine" = 10)

/obj/item/reagent_containers/food/pill/patch/synthflesh
	name = "synthflesh patch"
	desc = "Helps with brute and burn injuries."
	icon_state = "bandaid_med"
	instant_application = 1
	list_reagents = list("synthflesh" = 10)

/obj/item/reagent_containers/food/pill/patch/nicotine
	name = "nicotine patch"
	desc = "Helps temporarily curb the cravings of nicotine dependency."
	list_reagents = list("nicotine" = 10)

/obj/item/reagent_containers/food/pill/patch/jestosterone
	name = "jestosterone patch"
	desc = "Helps with brute injuries if the affected person is a clown, otherwise inflicts various annoying effects."
	icon_state = "bandaid_clown"
	list_reagents = list("jestosterone" = 20)
