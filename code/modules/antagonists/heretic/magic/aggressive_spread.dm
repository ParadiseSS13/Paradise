/datum/spell/aoe/rust_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust onto nearby surfaces."

	overlay_icon_state = "bg_heretic_border"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "corrode"
	sound = 'sound/items/welder.ogg'

	is_a_heretic_spell = TRUE
	base_cooldown = 30 SECONDS

	invocation = "A'GRSV SPR'D"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	aoe_range = 2


/datum/spell/aoe/rust_conversion/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/targeting = new()
	targeting.range = aoe_range
	return targeting

/datum/spell/aoe/rust_conversion/cast(list/targets, mob/living/user = usr)
	for(var/atom/victim in targets)
		// We have less chance of rusting stuff that's further
		var/distance_to_caster = get_dist(victim, user)
		var/chance_of_not_rusting = (max(distance_to_caster, 1) - 1) * 100 / (aoe_range + 1)

		if(prob(chance_of_not_rusting))
			return

		if(isliving(user))
			user.do_rust_heretic_act(victim)
		else
			victim.rust_heretic_act()

/datum/spell/aoe/rust_conversion/construct
	name = "Construct Spread"
	base_cooldown = 15 SECONDS
