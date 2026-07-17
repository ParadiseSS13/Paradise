/obj/item/scissors
	name = "Scissors"
	desc = "Those are scissors. Don't run with them!"
	icon_state = "scissor"
	inhand_icon_state = "scissor"
	force = 5
	sharp = TRUE
	w_class = WEIGHT_CLASS_SMALL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slices", "cuts", "stabs", "jabs")
	new_attack_chain = TRUE

/obj/item/scissors/barber
	name = "Barber's Scissors"
	desc = "A pair of scissors used by a barber."
	icon_state = "bscissor"
	attack_verb = list("beautifully sliced", "artistically cut", "smoothly stabbed", "quickly jabbed")
	toolspeed = 0.75

/obj/item/scissors/interact_with_atom(mob/living/carbon/human/target, mob/living/user, list/modifiers)
	if(user.a_intent != INTENT_HELP)
		return

	if(!ishuman(target))
		return

	var/obj/item/organ/external/head/head_organ = target.get_organ("head")
	if(!head_organ)
		to_chat(user, SPAN_WARNING("[target] doesn't have a head!"))
		return ITEM_INTERACT_COMPLETE

	// Facial hair.
	var/f_new_style = tgui_input_list(user, "Select a facial hair style", "Grooming", target.generate_valid_facial_hairstyles())
	// Hair atop head.
	var/h_new_style = tgui_input_list(user, "Select a hair style", "Grooming", target.generate_valid_hairstyles())
	user.visible_message(
		SPAN_NOTICE("[user] starts cutting [target]'s hair!"),
		SPAN_NOTICE("You start cutting [target]'s hair!"),
		SPAN_HEAR("You hear the snip snip of scissors.")
	)
	playsound(loc, 'sound/goonstation/misc/scissor.ogg', 100, 1)

	if(!do_after(user, 5 SECONDS * toolspeed, target = target))
		user.visible_message(
			SPAN_NOTICE("[user] stops cutting [target]'s hair."),
			SPAN_NOTICE("You stop cutting [target]'s hair."),
			SPAN_HEAR("The snipping stops.")
		)
		return ITEM_INTERACT_COMPLETE

	if(f_new_style)
		head_organ.f_style = f_new_style
	if(h_new_style)
		head_organ.h_style = h_new_style

	target.update_hair()
	target.update_fhair()
	user.visible_message(
		SPAN_NOTICE("[user] finishes cutting [target]'s hair!"),
		SPAN_NOTICE("You finish cutting [target]'s hair."),
		SPAN_HEAR("The snipping stops.")
	)
	return ITEM_INTERACT_COMPLETE
