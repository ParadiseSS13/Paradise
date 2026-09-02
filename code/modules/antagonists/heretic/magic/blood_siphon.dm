/datum/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "A targeted spell that heals your wounds while damaging the enemy. \
		It has a chance to transfer wounds between you and your enemy."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "blood_siphon"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 15 SECONDS

	invocation = "FL'MS O'ET'RN'ITY."
	invocation_type = INVOCATION_WHISPER

	cast_range = 6

/datum/spell/pointed/blood_siphon/valid_target(target, user)
	if(!isliving(target))
		return FALSE
	return TRUE

/datum/spell/pointed/blood_siphon/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/cast_on = targets[1]
	playsound(user, 'sound/misc/demon_attack1.ogg', 75, TRUE)
	if(cast_on.can_block_magic())
		cast_on.visible_message(
			SPAN_DANGER("The spell bounces off of [cast_on]!"),
			SPAN_DANGER("The spell bounces off of you!"),
		)
		return FALSE

	cast_on.visible_message(
		SPAN_DANGER("[cast_on] turns pale as a red glow envelops [cast_on.p_them()]!"),
		SPAN_DANGER("You pale as a red glow enevelops you!"),
	)

	var/mob/living/living_owner = user
	cast_on.adjustBruteLoss(20)
	living_owner.adjustBruteLoss(-20)

	if(!cast_on.blood_volume || !living_owner.blood_volume)
		return TRUE

	cast_on.blood_volume -= 20
	if(living_owner.blood_volume < BLOOD_VOLUME_MAXIMUM) // we dont want to explode from casting
		living_owner.blood_volume += 20

	if(!ishuman(cast_on) || !ishuman(living_owner))
		return TRUE

	var/mob/living/carbon/human/carbon_target = cast_on
	var/mob/living/carbon/human/carbon_user = living_owner
	for(var/obj/item/organ/external/E in carbon_user.bodyparts)
		if(E.status & ORGAN_INT_BLEEDING)
			if(prob(50))
				var/obj/item/organ/external/target_bodypart = locate(E.type) in carbon_target.bodyparts
				if(!target_bodypart)
					continue
				E.fix_internal_bleeding()
				target_bodypart.cause_internal_bleeding()
		if(E.status & ORGAN_BROKEN)
			if(prob(50))
				var/obj/item/organ/external/target_bodypart = locate(E.type) in carbon_target.bodyparts
				if(!target_bodypart)
					continue
				E.mend_fracture()
				target_bodypart.fracture()
		if(E.status & ORGAN_BURNT)
			if(prob(50))
				var/obj/item/organ/external/target_bodypart = locate(E.type) in carbon_target.bodyparts
				if(!target_bodypart)
					continue
				E.fix_burn_wound()
				target_bodypart.cause_burn_wound()

	return TRUE
