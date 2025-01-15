/datum/spell/pointed/burglar_finesse
	name = "Burglar's Finesse"
	desc = "Steal a random item from the victim's backpack."

	overlay_icon_state = "bg_heretic_border"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "burglarsfinesse"

	is_a_heretic_spell = TRUE
	base_cooldown = 40 SECONDS

	invocation = "Y'O'K!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 6

/datum/spell/pointed/burglar_finesse/is_valid_target(mob/living/carbon/human/cast_on)
	if(!istype(cast_on))
		return FALSE
	var/obj/item/back_item = cast_on.get_item_by_slot(ITEM_SLOT_BACK)
	return ..() && back_item?.atom_storage

/datum/spell/pointed/burglar_finesse/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, "<span class='danger'>You feel a light tug, but are otherwise fine, you were protected by holiness!</span>")
		to_chat(owner, "<span class='danger'>[cast_on] is protected by holy forces!</span>")
		return FALSE

	var/obj/storage_item = cast_on.get_item_by_slot(ITEM_SLOT_BACK)

	if(isnull(storage_item))
		return FALSE

	var/item = pick(storage_item.atom_storage.return_inv(recursive = FALSE))
	if(isnull(item))
		return FALSE

	to_chat(cast_on, "<span class='warning'>Your [storage_item] feels lighter...</span>")
	to_chat(owner, "<span class='notice'>With a blink, you pull [item] out of [cast_on][p_s()] [storage_item].</span>")
	owner.put_in_active_hand(item)
