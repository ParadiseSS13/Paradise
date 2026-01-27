/datum/spell/pointed/apetra_vulnera
	name = "Apetra Vulnera"
	desc = "Causes severe bleeding and opens every limb of a target which has more than 15 brute damage. \
		Opens a random limb if no limb is sufficiently damaged."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "apetra_vulnera"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 45 SECONDS

	invocation = "AP'TRA VULN'RA!"
	invocation_type = INVOCATION_WHISPER

	cast_range = 4

/datum/spell/pointed/apetra_vulnera/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.selection_type = SPELL_SELECTION_RANGE
	C.use_turf_of_user = TRUE
	C.allowed_type = /mob/living/carbon/human
	C.range = cast_range
	C.try_auto_target = FALSE
	return C


/datum/spell/pointed/apetra_vulnera/valid_target(target, user)
	return ..() && ishuman(target)

/datum/spell/pointed/apetra_vulnera/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/carbon/human/cast_on = targets[1]
	if(IS_HERETIC_OR_MONSTER(cast_on))
		return FALSE

	if(!cast_on.blood_volume)
		return FALSE

	if(cast_on.can_block_magic(antimagic_flags))
		cast_on.visible_message(
			SPAN_DANGER("[cast_on]'s bruises briefly glow, but repels the effect!"),
			SPAN_DANGER("Your bruises sting a little, but you are protected!")
		)
		return FALSE

	var/a_limb_got_damaged = FALSE
	for(var/obj/item/organ/external/bodypart in cast_on.bodyparts)
		if(bodypart.brute_dam < 15)
			continue
		a_limb_got_damaged = TRUE
		bodypart.open = ORGAN_ORGANIC_VIOLENT_OPEN

	if(!a_limb_got_damaged)
		var/obj/item/organ/external/other_bodypart = (pick(cast_on.bodyparts))
		other_bodypart.open = ORGAN_ORGANIC_VIOLENT_OPEN

	cast_on.visible_message(
		SPAN_DANGER("[cast_on]'s scratches and bruises are torn open by an unholy force!"),
		SPAN_DANGER("Your scratches and bruises are torn open by some horrible unholy force!")
	)

	new /obj/effect/temp_visual/cleave(get_turf(cast_on))

	return TRUE
