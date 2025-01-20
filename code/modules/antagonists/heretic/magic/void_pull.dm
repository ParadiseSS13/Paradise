/datum/spell/aoe/void_pull
	name = "Void Pull"
	desc = "Calls the void, damaging, knocking down, and stunning people nearby. \
		Distant foes are also pulled closer to you (but not damaged)."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "voidpull"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = 'sound/magic/voidblink.ogg'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "BR'NG F'RTH TH'M T' M'."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	aoe_range = 7
	/// The radius of the actual damage circle done before cast
	var/damage_radius = 1
	/// The radius of the stun applied to nearby people on cast
	var/stun_radius = 4

//qwertodo: unfuck this, first half on before cast, second on after?

// Before the cast, we do some small AOE damage around the caster
/datum/spell/aoe/void_pull/valid_target(target, user)
	new /obj/effect/temp_visual/voidin(get_turf(user))

	// Before we cast the actual effects, deal AOE damage to anyone adjacent to us
	for(var/mob/living/nearby_living as anything in get_things_to_cast_on(user, damage_radius))
		nearby_living.apply_damage(30, BRUTE)
		nearby_living.apply_status_effect(/datum/status_effect/void_chill, 1)
		if(get_dist(nearby_living, user) < stun_radius)
			nearby_living.KnockDown(3 SECONDS)
			nearby_living.AdjustWeakened(0.5 SECONDS)

		// Otherwise, they take a few steps closer
		for(var/i in 1 to 3)
			nearby_living.forceMove(get_step_towards(nearby_living, user))
	return TRUE

/datum/spell/aoe/void_pull/proc/get_things_to_cast_on(atom/center, radius_override = 1)
	var/list/things = list()
	for(var/mob/living/nearby_mob in view(radius_override || aoe_range, center))
		if(nearby_mob == center)
			continue
		// Don't grab people who are tucked away or something
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		things += nearby_mob

	return things
