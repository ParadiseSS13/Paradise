/proc/empulse(turf/epicenter, heavy_range, light_range, log=0, cause = null)
	if(!epicenter) return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	if(log)
		message_admins("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])": ""] [ADMIN_COORDJMP(epicenter)]</a>")
		log_game("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])" : ""] [COORD(epicenter)]")

	if(heavy_range > 1)
		new/obj/effect/temp_visual/emp/pulse(epicenter)

	if(heavy_range > light_range)
		light_range = heavy_range

	for(var/mob/M in range(heavy_range, epicenter))
		M << 'sound/effects/empulse.ogg'
	for(var/atom/T in range(light_range, epicenter))
		var/distance = get_dist(epicenter, T)
		var/willaffect = FALSE
		if(distance < 0)
			distance = 0
		if(distance < heavy_range)
			willaffect = T.emp_act(1)
		else if(distance == heavy_range)
			if(prob(50))
				willaffect = T.emp_act(1)
			else
				willaffect = T.emp_act(2)
		else if(distance <= light_range)
			willaffect = T.emp_act(2)
		if(willaffect)
			new /obj/effect/temp_visual/emp(T.loc)
	return 1

/proc/cultempulse(turf/epicenter, heavy_range, light_range, log=0, cause = null)
	if(!epicenter) return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	if(log)
		message_admins("Cult EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])": ""] [ADMIN_COORDJMP(epicenter)]</a>")
		log_game("Cult EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])" : ""] [COORD(epicenter)]")

	if(heavy_range > 1)
		new/obj/effect/temp_visual/cultemp/pulse(epicenter)

	if(heavy_range > light_range)
		light_range = heavy_range

	for(var/mob/M in range(heavy_range, epicenter))
		M << 'sound/effects/empulse.ogg'
	for(var/atom/T in range(light_range, epicenter))
		var/distance = get_dist(epicenter, T)
		if(iscultist(T) && ismachineperson(T)) //checks if atom in range is a cultist, and if they are IPC
			new/obj/effect/temp_visual/cultshield(T.loc)
			to_chat(T, "You are shielded from the pulse by dark powers.")
		else
			var/willaffect = FALSE
			if(distance < 0)
				distance = 0
			if(distance < heavy_range)
				willaffect = T.emp_act(1)
			else if(distance == heavy_range)
				if(prob(50))
					willaffect = T.emp_act(1)
				else
					willaffect = T.emp_act(2)
			else if(distance <= light_range)
				willaffect = T.emp_act(2)
			if(willaffect)
				new /obj/effect/temp_visual/cultemp(T.loc)
	return 1
