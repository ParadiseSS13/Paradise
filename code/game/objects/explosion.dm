//TODO: Flash range does nothing currently

//A very crude linear approximatiaon of pythagoras theorem.
/proc/cheap_pythag(var/dx, var/dy)
	dx = abs(dx); dy = abs(dy);
	if(dx>=dy)	return dx + (0.5*dy)	//The longest side add half the shortest side approximates the hypotenuse
	else		return dy + (0.5*dx)

proc/trange(var/Dist=0,var/turf/Center=null)//alternative to range (ONLY processes turfs and thus less intensive)
	if(Center==null) return

	//var/x1=((Center.x-Dist)<1 ? 1 : Center.x-Dist)
	//var/y1=((Center.y-Dist)<1 ? 1 : Center.y-Dist)
	//var/x2=((Center.x+Dist)>world.maxx ? world.maxx : Center.x+Dist)
	//var/y2=((Center.y+Dist)>world.maxy ? world.maxy : Center.y+Dist)

	var/turf/x1y1 = locate(((Center.x-Dist)<1 ? 1 : Center.x-Dist),((Center.y-Dist)<1 ? 1 : Center.y-Dist),Center.z)
	var/turf/x2y2 = locate(((Center.x+Dist)>world.maxx ? world.maxx : Center.x+Dist),((Center.y+Dist)>world.maxy ? world.maxy : Center.y+Dist),Center.z)
	return block(x1y1,x2y2)


proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, adminlog = 1)
	src = null	//so we don't abort once src is deleted
	spawn(0)
		var/start = world.timeofday
		epicenter = get_turf(epicenter)
		if(!epicenter) return

		var/max_range = max(devastation_range, heavy_impact_range, light_impact_range)

		// Play sounds; since playsound uses range() for each use, we'll try doing it through the player list.
		// Playsound_local will also have an extra bonus of panning the sound, depending on the source. So stereo users will hear the direction of the explosion
		for(var/mob/M in player_list)
			// Double check for client
			if(M && M.client)
				var/turf/M_turf = get_turf(M)
				if(M_turf.z == epicenter.z)
					var/dist = get_dist(M_turf, epicenter)
					// If inside the blast radius + world.view - 2
					if(dist <= round(max_range + world.view - 2, 1))
						M.playsound_local(epicenter, "explosion", 100, 1)
					// You hear a far explosion if you're outside the blast radius (*5) Small bombs shouldn't be heard all over the station.
					else if(dist <= round(max_range * 10, 1))
						var/far_volume = Clamp(max_range * 10, 30, 60) // Volume is based on explosion size and dist
						far_volume += (dist > max_range * 2 ? 0 : 40) // add 40 volume if the mob is pretty close to the explosion
						M.playsound_local(epicenter, 'sound/effects/explosionfar.ogg', far_volume, 1)


		var/close = range(world.view+round(devastation_range,1), epicenter)
		// to all distanced mobs play a different sound
		for(var/mob/M in world) if(M.z == epicenter.z) if(!(M in close))
			// check if the mob can hear
			if(M.ear_deaf <= 0 || !M.ear_deaf) if(!istype(M.loc,/turf/space))
				M << 'sound/effects/explosionfar.ogg'
		if(adminlog)
			msg_admin_attack("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>JMP</a>)")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")

		//var/lighting_controller_was_processing = lighting_controller.processing	//Pause the lighting updates for a bit
		//lighting_controller.processing = 0
		var/powernet_rebuild_was_deferred_already = defer_powernet_rebuild
		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 1

		if(heavy_impact_range > 1)
			var/datum/effect/system/explosion/E = new/datum/effect/system/explosion()
			E.set_up(epicenter)
			E.start()

		var/x0 = epicenter.x
		var/y0 = epicenter.y
		var/z0 = epicenter.z

		for(var/turf/T in trange(max_range, epicenter))
			var/dist = sqrt((T.x - x0)**2 + (T.y - y0)**2)

			if(config.reactionary_explosions)
				var/turf/Trajectory = T
				while(Trajectory != epicenter)
					Trajectory = get_step_towards(Trajectory, epicenter)
					if(Trajectory.density && Trajectory.explosion_block)
						dist += Trajectory.explosion_block

					for(var/obj/machinery/door/D in Trajectory)
						if(D.density && D.explosion_block)
							dist += D.explosion_block

			var/throw_dist = dist

			if(dist < devastation_range)		dist = 1
			else if(dist < heavy_impact_range)	dist = 2
			else if(dist < light_impact_range)	dist = 3
			else								dist = 0

			if(T)
				for(var/atom_movable in T.contents)	//bypass type checking since only atom/movable can be contained by turfs anyway
					var/atom/movable/AM = atom_movable
					if(AM && AM.simulated)	AM.ex_act(dist)
//				if(flame_dist && prob(40) && !istype(T, /turf/space) && !T.density)
//					PoolOrNew(/obj/effect/hotspot, T) //Mostly for ambience!
				if(dist > 0)
					T.ex_act(dist)

			//--- THROW ITEMS AROUND ---

			var/throw_dir = get_dir(epicenter,T)
			for(var/obj/item/I in T)
				spawn(0) //Simultaneously not one at a time
					if(I)
						var/throw_range = rand(throw_dist, max_range)
						var/turf/throw_at = get_ranged_target_turf(I, throw_dir, throw_range)
						I.throw_speed = 4 //Temporarily change their throw_speed for embedding purposes (Reset when it finishes throwing, regardless of hitting anything)
						I.throw_at(throw_at, throw_range, 2)//Throw it at 2 speed, this is purely visual anyway.

		var/took = (world.timeofday-start)/10
		//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
		if(Debug2)	world.log << "## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds."

		//Machines which report explosions.
		for(var/i,i<=doppler_arrays.len,i++)
			var/obj/machinery/doppler_array/Array = doppler_arrays[i]
			if(Array)
				Array.sense_explosion(x0,y0,z0,devastation_range,heavy_impact_range,light_impact_range,took)

		sleep(8)

		//if(!lighting_controller.processing)	lighting_controller.processing = lighting_controller_was_processing
		if(!powernet_rebuild_was_deferred_already)
			if(defer_powernet_rebuild != 2)
				defer_powernet_rebuild = 0

	return 1



proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in trange(range, epicenter))
		tile.ex_act(2)

/client/proc/check_bomb_impacts()
	set name = "Check Bomb Impact"
	set category = "Debug"

	var/newmode = alert("Use reactionary explosions?","Check Bomb Impact", "Yes", "No")

	var/turf/epicenter = get_turf(usr)
	var/dev = 0
	var/heavy = 0
	var/light = 0
	var/list/choices = list("Small Bomb","Medium Bomb","Big Bomb","Custom Bomb")
	var/choice = input("Bomb Size?") in choices
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			dev = 1
			heavy = 2
			light = 3
		if("Medium Bomb")
			dev = 2
			heavy = 3
			light = 4
		if("Big Bomb")
			dev = 3
			heavy = 5
			light = 7
		if("Custom Bomb")
			dev = input("Devestation range (Tiles):") as num
			heavy = input("Heavy impact range (Tiles):") as num
			light = input("Light impact range (Tiles):") as num

	var/max_range = max(dev, heavy, light)
	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/list/wipe_colours = list()
	for(var/turf/T in trange(max_range, epicenter))
		wipe_colours += T
		var/dist = cheap_pythag(T.x - x0, T.y - y0)

		if(newmode == "Yes")
			var/turf/TT = T
			while(TT != epicenter)
				TT = get_step_towards(TT,epicenter)
				if(TT.density && TT.explosion_block)
					dist += TT.explosion_block

				for(var/obj/machinery/door/D in TT)
					if(D.density && D.explosion_block)
						dist += D.explosion_block

		if(dist < dev)
			T.color = "red"
			T.maptext = "Dev"
		else if (dist < heavy)
			T.color = "yellow"
			T.maptext = "Heavy"
		else if (dist < light)
			T.color = "blue"
			T.maptext = "Light"
		else
			continue

	sleep(100)
	for(var/turf/T in wipe_colours)
		T.color = null
		T.maptext = ""
