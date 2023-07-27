/obj/effect/proc_holder/spell/turf_teleport
	name = "Turf Teleport"
	desc = "This spell teleports the target to the turf in range."
	nonabstract_req = TRUE

	var/inner_tele_radius = 1
	var/outer_tele_radius = 2

	/// Whether it includes space tiles in possible teleport locations.
	var/include_space = FALSE
	/// Whether it includes dense tiles in possible teleport locations.
	var/include_dense = FALSE
	/// Whether the spell can teleport to light locations.
	var/include_light_turfs = TRUE

	var/sound_in = 'sound/weapons/zapbang.ogg'
	var/sound_out = 'sound/weapons/zapbang.ogg'


/obj/effect/proc_holder/spell/turf_teleport/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/turf_teleport/cast(list/targets,mob/living/user = usr)
	if(sound_in)
		playsound(get_turf(user), sound_in, 50, TRUE)

	for(var/mob/living/target in targets)
		var/list/turfs = new/list()
		for(var/turf/T in range(target,outer_tele_radius))
			if(T in range(target,inner_tele_radius))
				continue

			if(isspaceturf(T) && !include_space)
				continue

			if(T.density && !include_dense)
				continue

			if(T.x>world.maxx-outer_tele_radius || T.x<outer_tele_radius)
				continue	//putting them at the edge is dumb

			if(T.y>world.maxy-outer_tele_radius || T.y<outer_tele_radius)
				continue

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
		if(sound_out)
			playsound(get_turf(user), sound_out, 50, TRUE)

