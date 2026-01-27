/datum/spell/aoe/rust_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust onto nearby surfaces."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "corrode"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = 'sound/items/welder.ogg'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "A'GRSV SPR'D"
	invocation_type = INVOCATION_WHISPER
	aoe_range = 3


/datum/spell/aoe/rust_conversion/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/targeting = new()
	targeting.range = aoe_range
	targeting.use_turf_of_user = TRUE
	return targeting

/datum/spell/aoe/rust_conversion/cast(list/targets, mob/living/user = usr)
	for(var/turf/target_turfs in targets)
		// We have less chance of rusting stuff that's further
		var/distance_to_caster = get_dist(target_turfs, user)
		var/chance_of_not_rusting = (max(distance_to_caster, 1) - 1) * 100 / (aoe_range + 1)

		if(prob(chance_of_not_rusting))
			continue
		for(var/atom/victim in target_turfs)
			if(isliving(user))
				user.do_rust_heretic_act(victim)
			else
				victim.rust_heretic_act()
		if(isliving(user))
			user.do_rust_heretic_act(target_turfs)
		else
			target_turfs.rust_heretic_act()


/datum/spell/aoe/rust_conversion/construct
	name = "Construct Spread"
	base_cooldown = 15 SECONDS
