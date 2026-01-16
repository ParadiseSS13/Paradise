/datum/spell/pointed/burglar_finesse
	name = "Burglar's Finesse"
	desc = "Steal a random item from the victim's backpack."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "burglarsfinesse"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 40 SECONDS

	invocation = "Y'O'K!"
	invocation_type = INVOCATION_WHISPER

	cast_range = 6


/datum/spell/pointed/burglar_finesse/valid_target(target, user)
	if(!ishuman(target))
		return FALSE
	if(!get_dist(target, user >= 10)) // no yoinking through cams or scopes.
		return FALSE
	var/mob/living/carbon/human/human_target = target
	if(locate(/obj/item/storage/backpack) in human_target.contents)
		return TRUE
	if(locate(/obj/item/mod/control) in human_target.contents)
		return TRUE
	return FALSE

/datum/spell/pointed/burglar_finesse/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/carbon/cast_on = targets[1]
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, SPAN_DANGER("You feel a light tug, but are otherwise fine, you were protected by magical forces!</span>"))
		to_chat(user, SPAN_DANGER("[cast_on] is protected by magical forces!</span>"))
		return FALSE

	var/obj/storage_item = locate(/obj/item/storage/backpack) in cast_on.contents

	if(isnull(storage_item))
		if(locate(/obj/item/mod/control) in cast_on.contents)
			var/obj/item/mod/control/temp_item = locate(/obj/item/mod/control) in cast_on.contents
			if(temp_item.bag)
				storage_item = temp_item.bag

	if(isnull(storage_item))
		return FALSE
	if(isnull(storage_item.contents))
		return FALSE
	var/item = pick(storage_item.contents)
	if(isnull(item))
		return FALSE
	to_chat(cast_on, SPAN_WARNING("Your [storage_item.name] feels lighter...</span>"))
	to_chat(user, SPAN_NOTICE("With a blink, you pull [item] out of [cast_on][p_s()] [storage_item.name].</span>"))
	user.put_in_active_hand(item)
