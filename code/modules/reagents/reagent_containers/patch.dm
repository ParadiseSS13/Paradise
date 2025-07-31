/obj/item/reagent_containers/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon_state = "bandaid1"
	possible_transfer_amounts = null
	visible_transfer_rate = FALSE
	temperature_min = 270
	temperature_max = 350
	var/instant_application = FALSE
	var/needs_to_apply_reagents = TRUE

/obj/item/reagent_containers/patch/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(isnull(target.reagents))
		return

	return ..()

/obj/item/reagent_containers/patch/mob_act(mob/target, mob/living/user)
	apply(target, user)
	return ITEM_INTERACT_COMPLETE

/obj/item/reagent_containers/patch/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	apply(user, user)

/obj/item/reagent_containers/patch/proc/apply(mob/living/carbon/C, mob/user)
	if(!istype(C))
		return

	if(ismachineperson(C))
		to_chat(user, "<span class='warning'>[user == C ? "You" : C] can't use [src]!</span>")
		return

	if(user == C)
		to_chat(user, "<span class='notice'>You apply [src].</span>")
	else
		if(!instant_application)
			C.visible_message("<span class='warning'>[user] attempts to force [C] to apply [src].</span>")
			if(!do_after(user, 3 SECONDS, TRUE, C, TRUE))
				return

		C.forceFedAttackLog(src, user)
		C.visible_message("<span class='warning'>[user] forces [C] to apply [src].</span>")

	if(user.get_active_hand() == src)
		user.drop_item() // Only drop if they're holding the patch directly
	forceMove(C)
	LAZYADD(C.processing_patches, src)
	return

/obj/item/reagent_containers/patch/styptic
	name = "brute patch"
	desc = "Helps with brute injuries."
	icon_state = "bandaid2"
	instant_application = TRUE
	list_reagents = list("styptic_powder" = 30)

/obj/item/reagent_containers/patch/styptic/small
	name = "brute mini-patch"
	icon_state = "bandaid3"
	list_reagents = list("styptic_powder" = 15)

/obj/item/reagent_containers/patch/silver_sulf
	name = "burn patch"
	desc = "Helps with burn injuries."
	icon_state = "bandaid4"
	instant_application = TRUE
	list_reagents = list("silver_sulfadiazine" = 30)

/obj/item/reagent_containers/patch/silver_sulf/small
	name = "burn mini-patch"
	icon_state = "bandaid5"
	list_reagents = list("silver_sulfadiazine" = 15)

/obj/item/reagent_containers/patch/synthflesh
	name = "synthflesh patch"
	desc = "Helps with brute and burn injuries."
	icon_state = "bandaid20"
	instant_application = TRUE
	list_reagents = list("synthflesh" = 10)

/obj/item/reagent_containers/patch/nicotine
	name = "nicotine patch"
	desc = "Helps temporarily curb the cravings of nicotine dependency."
	icon_state = "bandaid15"
	list_reagents = list("nicotine" = 10)

/obj/item/reagent_containers/patch/jestosterone
	name = "jestosterone patch"
	desc = "Helps with brute injuries if the affected person is a clown, otherwise inflicts various annoying effects."
	icon_state = "bandaid21"
	list_reagents = list("jestosterone" = 20)

/obj/item/reagent_containers/patch/perfluorodecalin
	name = "perfluorodecalin patch"
	desc = "Incredibly potent respiratory aid drug, may cause shortness of breath if used in large amounts."
	icon_state = "bandaid12"
	list_reagents = list("perfluorodecalin" = 10)
