/obj/item/lipstick
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon_state = "lipstick"
	w_class = WEIGHT_CLASS_TINY
	var/colour = "red"
	var/open = FALSE
	var/static/list/lipstick_colors
	new_attack_chain = TRUE

/obj/item/lipstick/Initialize(mapload)
	. = ..()
	if(!lipstick_colors)
		lipstick_colors = list(
			"black" = "#000000",
			"white" = "#FFFFFF",
			"red" = "#FF0000",
			"green" = "#00C000",
			"blue" = "#0000FF",
			"purple" = "#D55CD0",
			"jade" = "#216F43",
			"lime" = "#00FF00",
		)

/obj/item/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/lipstick/jade
	name = "jade lipstick"
	colour = "jade"

/obj/item/lipstick/lime
	name = "lime lipstick"
	colour = "lime"

/obj/item/lipstick/black
	name = "black lipstick"
	colour = "black"

/obj/item/lipstick/green
	name = "green lipstick"
	colour = "green"

/obj/item/lipstick/blue
	name = "blue lipstick"
	colour = "blue"

/obj/item/lipstick/white
	name = "white lipstick"
	colour = "white"

/obj/item/lipstick/random
	name = "lipstick"

/obj/item/lipstick/random/Initialize(mapload)
	. = ..()
	colour = pick(lipstick_colors)
	name = "[colour] lipstick"

/obj/item/lipstick/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE
	cut_overlays()
	to_chat(user, SPAN_NOTICE("You twist [src] [open ? "closed" : "open"]."))
	open = !open
	if(!open)
		icon_state = "lipstick"
		return ITEM_INTERACT_COMPLETE
	var/mutable_appearance/colored = mutable_appearance('icons/obj/items.dmi', "lipstick_uncap_color")
	colored.color = lipstick_colors[colour]
	icon_state = "lipstick_uncap"
	add_overlay(colored)
	add_fingerprint(user)

/obj/item/lipstick/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!open || !ismob(target))
		return ..()

	if(!ishuman(target))
		to_chat(user, SPAN_WARNING("Where are the lips on that?"))
		return ITEM_INTERACT_COMPLETE

	var/mob/living/carbon/human/human_target = target
	if(human_target.lip_style) // If they already have lipstick on...
		to_chat(user, SPAN_WARNING("You need to wipe off the old lipstick first!"))
		return ITEM_INTERACT_COMPLETE

	if(human_target == user)
		user.visible_message(
			SPAN_NOTICE("[user] does [user.p_their()] lips with [src]."),
			SPAN_NOTICE("You take a moment to apply [src]. Perfect!")
		)
		human_target.lip_style = "lipstick"
		human_target.lip_color = lipstick_colors[colour]
		human_target.update_body()
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

	user.visible_message(
		SPAN_WARNING("[user] begins to do [human_target]'s lips with [src]."),
		SPAN_NOTICE("You begin to apply [src].")
	)
	if(!do_after(user, 20, target = human_target))
		return ITEM_INTERACT_COMPLETE
	user.visible_message(
		SPAN_NOTICE("[user] does [human_target]'s lips with [src]."),
		SPAN_NOTICE("You apply [src].")
	)
	human_target.lip_style = "lipstick"
	human_target.lip_color = lipstick_colors[colour]
	human_target.update_body()
	add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon_state = "razor"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	usesound = 'sound/items/welder2.ogg'
	new_attack_chain = TRUE

/obj/item/razor/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!ishuman(target))
		return ..()

	if(!(user.zone_selected in list("head", "mouth")))
		return ..()

	var/mob/living/carbon/human/human_target = target
	var/obj/item/organ/external/head/human_head = human_target.get_organ("head")
	if(!istype(human_head))
		to_chat(user, SPAN_WARNING("There's nothing to cut, [target] [target.p_are()] missing [target.p_their()] head!"))
		return ITEM_INTERACT_COMPLETE

	var/datum/robolimb/robohead = GLOB.all_robolimbs[human_head.model]

	if((human_head.dna.species.bodyflags & ALL_RPARTS) && robohead.is_monitor)
		// If the target is of a species that can have prosthetic heads, but the head doesn't support human hair 'wigs'...
		to_chat(user, SPAN_WARNING("You find yourself disappointed at the appalling lack of hair."))
		return ITEM_INTERACT_COMPLETE

	if(isskrell(target))
		to_chat(user, SPAN_WARNING("Your razor isn't going to cut through tentacles."))
		return ITEM_INTERACT_COMPLETE

	if(user.zone_selected == "mouth")
		shave_face(target, user)
		return ITEM_INTERACT_COMPLETE

	shave_head(target, user)
	return ITEM_INTERACT_COMPLETE

/obj/item/razor/proc/shave_head(mob/living/carbon/human/target, mob/living/user)
	var/obj/item/organ/external/head/human_head = target.get_organ("head")
	if(!get_location_accessible(target, "head"))
		to_chat(user, SPAN_WARNING("The headgear is in the way!"))
		return FALSE

	if(human_head.h_style == "Bald" || human_head.h_style == "Balding Hair" || human_head.h_style == "Skinhead")
		to_chat(user, SPAN_WARNING("There is not enough hair left to shave..."))
		return FALSE

	if(target == user) // Shaving yourself.
		user.visible_message(
			SPAN_NOTICE("[user] starts to shave [user.p_their()] head with [src]."),
			SPAN_NOTICE("You start to shave your head with [src].")
		)
	else
		user.visible_message(
			SPAN_DANGER("[user] tries to shave [target]'s head with [src]!"),
			SPAN_NOTICE("You start shaving [target]'s head.")
		)

	var/turf/user_loc = user.loc
	var/turf/target_loc = target.loc
	if(!do_after(user, 50 * toolspeed, target = target))
		return FALSE
	if(!(user_loc == user.loc && target_loc == target.loc))
		return FALSE

	if(target == user)
		user.visible_message(
			SPAN_NOTICE("[user] shaves [user.p_their()] head with [src]."),
			SPAN_NOTICE("You finish shaving with [src]."),
			SPAN_NOTICE("You hear an electric razor shaving.")
		)
	else
		user.visible_message(
			SPAN_DANGER("[user] shaves [target]'s head bald with [src]!"),
			SPAN_NOTICE("You shave [target]'s head bald."),
			SPAN_HEAR("You hear an electric razor shaving.")
		)
	human_head.h_style = "Skinhead"
	target.update_hair()
	playsound(src.loc, usesound, 40, 1)
	add_fingerprint(user)
	return TRUE

/obj/item/razor/proc/shave_face(mob/living/carbon/human/target, mob/living/user)
	var/obj/item/organ/external/head/human_head = target.get_organ("head")
	if(!get_location_accessible(target, "mouth"))
		to_chat(user, SPAN_WARNING("The mask is in the way!"))
		return FALSE

	if(human_head.f_style == "Shaved")
		to_chat(user, SPAN_WARNING("Already clean-shaven!"))
		return FALSE

	if(target == user) // Shaving yourself.
		user.visible_message(
			SPAN_NOTICE("[user] starts to shave [user.p_their()] facial hair with [src]."),
			SPAN_NOTICE("You take a moment shave your facial hair with [src]."),
			SPAN_HEAR("You hear an electric razor shaving.")
		)
	else
		user.visible_message(
			SPAN_DANGER("[user] tries to shave [target]'s facial hair with [src]!"),
			SPAN_NOTICE("You start shaving [target]'s facial hair.")
		)

	var/turf/user_loc = user.loc
	var/turf/target_loc = target.loc
	if(!do_after(user, 50 * toolspeed, target = target))
		return FALSE
	if(!(user_loc == user.loc && target_loc == target.loc))
		return FALSE

	if(target == user)
		user.visible_message(
			SPAN_NOTICE("[user] shaves [user.p_their()] facial hair clean with [src]."),
			SPAN_NOTICE("You finish shaving with [src]. Fast and clean!"),
			SPAN_HEAR("You hear an electric razor shaving.")
		)
	else
		user.visible_message(
			SPAN_DANGER("[user] shaves off [target]'s facial hair with [src]."),
			SPAN_NOTICE("You shave [target]'s facial hair clean off."),
			SPAN_HEAR("You hear an electric razor shaving.")
		)

	human_head.f_style = "Shaved"
	target.update_fhair()
	playsound(src.loc, usesound, 20, 1)
	add_fingerprint(user)
	return TRUE
