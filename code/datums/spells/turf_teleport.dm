/datum/spell/turf_teleport
	name = "Turf Teleport"
	desc = "This spell teleports the target to the turf in range."
	nonabstract_req = TRUE

	var/inner_tele_radius = 1
	var/outer_tele_radius = 2

	var/include_space = FALSE //whether it includes space tiles in possible teleport locations
	var/include_dense = FALSE //whether it includes dense tiles in possible teleport locations
	/// Whether the spell can teleport to light locations
	var/include_light_turfs = TRUE

	var/sound1 = 'sound/weapons/zapbang.ogg'
	var/sound2 = 'sound/weapons/zapbang.ogg'

/datum/spell/turf_teleport/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/turf_teleport/cast(list/targets,mob/living/user = usr)
	if(sound1)
		playsound(get_turf(user), sound1, 50, TRUE)

	for(var/mob/living/target in targets)
		if(SEND_SIGNAL(target, COMSIG_MOVABLE_TELEPORTING, get_turf(target)) & COMPONENT_BLOCK_TELEPORT)
			continue
		var/list/turfs = list()
		for(var/turf/T in range(target,outer_tele_radius))
			if(T in range(target,inner_tele_radius)) continue
			if(isspaceturf(T) && !include_space) continue
			if(T.density && !include_dense) continue
			if(T.x>world.maxx-outer_tele_radius || T.x<outer_tele_radius)	continue	//putting them at the edge is dumb
			if(T.y>world.maxy-outer_tele_radius || T.y<outer_tele_radius)	continue
			if(!include_light_turfs)
				var/lightingcount = T.get_lumcount() * 10
				if(lightingcount > 2)
					continue
			turfs += T

		if(!length(turfs))
			var/list/turfs_to_pick_from = list()
			for(var/turf/T in orange(target,outer_tele_radius))
				if(!(T in orange(target,inner_tele_radius)))
					turfs_to_pick_from += T
			turfs += pick(/turf in turfs_to_pick_from)

		var/turf/picked = pick(turfs)

		if(!picked || !isturf(picked))
			return

		target.forceMove(picked)
		if(sound2)
			playsound(get_turf(user), sound2, 50,1)
