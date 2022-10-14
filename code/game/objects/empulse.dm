/proc/empulse(turf/epicenter, heavy_range, light_range, log = FALSE, cause = null)
	if(!epicenter) return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	if(log)
		message_admins("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])": ""] [ADMIN_COORDJMP(epicenter)]</a>")
		add_game_logs("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])" : ""] [COORD(epicenter)]")

	if(heavy_range > 1)
		if(cause == "cult")
			new /obj/effect/temp_visual/emp/pulse/cult(epicenter)
		else if(cause == "clock")
			new /obj/effect/temp_visual/emp/pulse/clock(epicenter)
		else
			new /obj/effect/temp_visual/emp/pulse(epicenter)

	if(heavy_range > light_range)
		light_range = heavy_range

	for(var/mob/M in range(heavy_range, epicenter))
		M << 'sound/effects/empulse.ogg'
	for(var/atom/T in range(light_range, epicenter))
		if(cause == "cult" && iscultist(T))
			continue
		if(cause == "clock" && isclocker(T))
			continue
		var/distance = get_dist(epicenter, T)
		var/will_affect = FALSE

		if(distance < 0)
			distance = 0
		if(distance < heavy_range)
			will_affect = T.emp_act(1)

		else if(heavy_range && distance == heavy_range)
			if(prob(50))
				will_affect = T.emp_act(1)
			else
				will_affect = T.emp_act(2)

		else if(distance <= light_range)
			will_affect = T.emp_act(2)

		if(will_affect)
			if(cause == "cult")
				new /obj/effect/temp_visual/emp/cult(T.loc)
			else if(cause == "clock")
				new /obj/effect/temp_visual/emp/clock(T.loc)
			else
				new /obj/effect/temp_visual/emp(T.loc)
	return TRUE
