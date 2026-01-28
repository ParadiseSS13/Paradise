/datum/spell/aoe/conjure/cosmic_expansion
	name = "Cosmic Expansion"
	desc = "This spell generates a 3x3 domain of cosmic fields. \
		Creatures up to 7 tiles away will also receive a star mark."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "cosmic_domain"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	sound = 'sound/magic/cosmic_expansion.ogg'
	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 45 SECONDS

	invocation = "C'SM'S 'XP'ND"
	invocation_type = INVOCATION_SHOUT

	summon_amt = 9
	summon_type = list(/obj/effect/forcefield/cosmic_field)
	summon_ignore_density = TRUE
	summon_ignore_prev_spawn_points = TRUE
	aoe_range = 1
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 7
	/// Effect for when the spell triggers
	var/obj/effect/expansion_effect = /obj/effect/temp_visual/cosmic_domain
	/// If the heretic is ascended or not
	var/ascended = FALSE

/datum/spell/aoe/conjure/cosmic_expansion/cast(list/targets, mob/user)
	new expansion_effect(get_turf(user))
	for(var/mob/living/nearby_mob in range(star_mark_range, user))
		if(user == nearby_mob || user.buckled == nearby_mob)
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, user)
	if(ascended)
		for(var/turf/cast_turf as anything in RANGE_TURFS(7, user))
			new /obj/effect/forcefield/cosmic_field(cast_turf)
	return ..()

/datum/spell/aoe/conjure/cosmic_expansion/proc/get_turfs(turf/target_turf)
	var/list/target_turfs = list()
	for(var/direction as anything in GLOB.cardinal)
		target_turfs += get_ranged_target_turf(target_turf, direction, 2)
		target_turfs += get_ranged_target_turf(target_turf, direction, 3)
	return target_turfs
