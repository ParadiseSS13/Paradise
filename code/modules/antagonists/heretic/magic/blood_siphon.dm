/datum/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "A targeted spell that heals your wounds while damaging the enemy. \
		It has a chance to transfer wounds between you and your enemy."

	overlay_icon_state = "bg_heretic_border"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	is_a_heretic_spell = TRUE
	base_cooldown = 15 SECONDS

	invocation = "FL'MS O'ET'RN'ITY."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONEe

	cast_range = 6

/datum/spell/pointed/blood_siphon/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/spell/pointed/blood_siphon/valid_target(target, user)
	return ..() && isliving(target)

/datum/spell/pointed/blood_siphon/cast(mob/living/cast_on)
	. = ..()
	playsound(owner, 'sound/effects/magic/demon_attack1.ogg', 75, TRUE)
	if(cast_on.can_block_magic())
		owner.balloon_alert(owner, "spell blocked!")
		cast_on.visible_message(
			"<span class='danger'>The spell bounces off of [cast_on]!</span>",
			"<span class='danger'>The spell bounces off of you!</span>",
		)
		return FALSE

	cast_on.visible_message(
		"<span class='danger'>[cast_on] turns pale as a red glow envelops [cast_on.p_them()]!</span>",
		"<span class='danger'>You pale as a red glow enevelops you!</span>",
	)

	var/mob/living/living_owner = owner
	cast_on.adjustBruteLoss(20)
	living_owner.adjustBruteLoss(-20)

	if(!cast_on.blood_volume || !living_owner.blood_volume)
		return TRUE

	cast_on.blood_volume -= 20
	if(living_owner.blood_volume < BLOOD_VOLUME_MAXIMUM) // we dont want to explode from casting
		living_owner.blood_volume += 20

	if(!iscarbon(cast_on) || !iscarbon(owner))
		return TRUE

	var/mob/living/carbon/carbon_target = cast_on
	var/mob/living/carbon/carbon_user = owner
	for(var/obj/item/bodypart/bodypart as anything in carbon_user.bodyparts)
		for(var/datum/wound/iter_wound as anything in bodypart.wounds)
			if(prob(50))
				continue
			var/obj/item/bodypart/target_bodypart = locate(bodypart.type) in carbon_target.bodyparts
			if(!target_bodypart)
				continue
			iter_wound.remove_wound()
			iter_wound.apply_wound(target_bodypart)

	return TRUE
