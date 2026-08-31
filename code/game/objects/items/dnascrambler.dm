/obj/item/dnascrambler
	name = "dna scrambler"
	desc = "An illegal genetic serum designed to randomize the user's identity."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "lepopen"
	inhand_icon_state = "syringe_0"
	new_attack_chain = TRUE
	var/used = FALSE

/obj/item/dnascrambler/update_icon_state()
	if(used)
		icon_state = "lepopen0"
	else
		icon_state = "lepopen"

/obj/item/dnascrambler/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!target || !user)
		return ITEM_INTERACT_COMPLETE

	if(!ishuman(target))
		if(ismob(target))
			to_chat(user, SPAN_WARNING("This only works on advanced humanoids!"))
			return ITEM_INTERACT_COMPLETE
		return NONE

	if(!ishuman(user))
		to_chat(user, SPAN_WARNING("You can't figure out how to use this!"))
		return ITEM_INTERACT_COMPLETE

	if(used)
		to_chat(user, SPAN_WARNING("[src] is empty!"))
		return ITEM_INTERACT_COMPLETE

	var/mob/living/carbon/human/human_target = target
	if(HAS_TRAIT(target, TRAIT_GENELESS))
		to_chat(user, SPAN_WARNING("You failed to inject [human_target], as [human_target.p_they()] [human_target.p_have()] no DNA to scramble, nor flesh to inject."))
		return ITEM_INTERACT_COMPLETE

	if(target == user)
		user.visible_message(SPAN_DANGER("[user] injects [human_target.p_themselves()] with [src]!"))
		injected(user, user)
		return ITEM_INTERACT_COMPLETE

	user.visible_message(SPAN_DANGER("[user] is trying to inject [target] with [src]!"))
	if(do_mob(user, target, 30))
		user.visible_message(SPAN_DANGER("[user] injects [target] with [src]."))
		injected(target, user)
	else
		to_chat(user, SPAN_WARNING("You failed to inject [target]."))
	return ITEM_INTERACT_COMPLETE

/obj/item/dnascrambler/proc/injected(mob/living/carbon/human/target, mob/living/carbon/user)
	if(istype(target))
		var/mob/living/carbon/human/H = target
		H.get_dna_scrambled()
	target.update_icons()

	add_attack_logs(user, target, "injected with [src]")
	used = TRUE
	update_icon(UPDATE_ICON_STATE)
	name = "used " + name
