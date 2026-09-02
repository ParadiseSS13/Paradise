/datum/spell/aoe/wave_of_desperation
	name = "Wave Of Desperation"
	desc = "Removes your restraints, repels and knocks down adjacent people, and applies certain effects of the Mansus Grasp upon everything nearby. \
		Cannot be cast unless you are restrained, and the stress renders you unconscious 12 seconds later!"


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "uncuff"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = 'sound/magic/swap.ogg'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 5 MINUTES

	invocation = "F'K 'FF."
	invocation_type = INVOCATION_WHISPER

	aoe_range = 3

/datum/spell/aoe/wave_of_desperation/create_new_targeting()
	var/datum/spell_targeting/aoe/targeting = new()
	targeting.range = aoe_range
	return targeting


// Before the cast, we do some small AOE damage around the caster
/datum/spell/aoe/wave_of_desperation/valid_target(target, user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_user = user
	if(!(human_user.handcuffed || human_user.legcuffed))
		return FALSE
	return TRUE

/datum/spell/aoe/wave_of_desperation/cast(list/targets, mob/user)
	var/mob/living/carbon/human/human_user = user
	if(human_user.handcuffed)
		human_user.visible_message(SPAN_DANGER("[human_user.handcuffed] on [human_user] shatter!"))
		QDEL_NULL(human_user.handcuffed)
	if(human_user.legcuffed)
		user.visible_message(SPAN_DANGER("[human_user.legcuffed] on [human_user] shatters!"))
		QDEL_NULL(human_user.legcuffed)

	human_user.apply_status_effect(/datum/status_effect/heretic_lastresort)
	new /obj/effect/temp_visual/knockblast(get_turf(human_user))

	for(var/mob/living/victim in get_things_to_cast_on(human_user))
		victim.KnockDown(3 SECONDS)
		victim.AdjustWeakened(0.5 SECONDS)
		var/our_turf = get_turf(user)
		var/throwtarget = get_edge_target_turf(our_turf, get_dir(our_turf, get_step_away(victim, our_turf)))
		victim.throw_at(throwtarget, 3, 1)
		SEND_SIGNAL(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, victim)

/datum/spell/aoe/wave_of_desperation/proc/get_things_to_cast_on(atom/center, radius_override)
	. = list()
	for(var/atom/nearby in orange(center, radius_override ? radius_override : aoe_range))
		if(nearby == center)
			continue
		if(!ismob(nearby))
			SEND_SIGNAL(center, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, nearby)
			continue
		var/mob/living/nearby_mob = nearby
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		. += nearby_mob



/obj/effect/temp_visual/knockblast
	icon_state = "shield-flash"
	alpha = 180
