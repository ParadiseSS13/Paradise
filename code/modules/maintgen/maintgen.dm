/proc/generate_maintenance()
	var/list/maint_area_types = typesof(/area/maintenance) - /area/maintenance/turbine - /area/maintenance/incinerator - /area/maintenance/disposal - /area/maintenance - /area/maintenance/auxsolarport - /area/maintenance/starboardsolar - /area/maintenance/portsolar - /area/maintenance/auxsolarstarboard
	var/list/maint_areas = list()
	for(var/maint_type in maint_area_types)
		var/area/A = locate(maint_type)
		if(A != null)
			maint_areas += A

	for(var/i = 1 to 100)
		var/area/A = pick(maint_areas)
		var/list/valid_turfs = list()
		// Find valid turfs
		// Criteria that it has to be a wall, there needs to be exactly one adjacent space turf, and the opposite turf needs to have nothing blocking it.
		for(var/turf/simulated/wall/T in A)
			var/is_valid = 0
			for(var/cdir in cardinal)
				if(istype(get_step(T, cdir), /turf/space))
					if(is_valid != 0)
						is_valid = -1
					else
						is_valid = cdir
			if(is_valid <= 0)
				continue
			if(!istype(get_area(get_step(T, is_valid)), /area/space/maintgen))
				continue
			var/turf/IN = get_step(T, turn(is_valid, 180))
			if(IN.density)
				continue
			if(locate(/obj/effect/spawner/window) in IN.contents)
				continue
			for(var/atom/movable/AM in IN.contents)
				if(AM.density)
					is_valid = 0
					break
			if(is_valid <= 0)
				continue
			valid_turfs[T] = is_valid
		
		var/sanity = 100
		while(sanity > 0)
			if(!valid_turfs.len)
				break
			sanity--
			var/turf/T = pick(valid_turfs)
			var/space_dir = valid_turfs[T]
			valid_turfs -= T
			var/turf/door_turf = T
			T = get_step(T, space_dir)
			var/desired_width = 3 + ((rand(0, 100)/100) ** 2)*2 // Bias to lower numbers
			var/desired_height = 2 + ((rand(0, 100)/100) ** 2)*3
			var/width = 1
			var/x_offset = 0
			var/height = 1
			while(width < desired_width)
				var/success = 0
				if(check_maint_room_bounds(space_dir, T, x_offset+1, 0, 1, height))
					success = 1
					x_offset++
					width++
				if(width >= desired_width)
					break
				if(check_maint_room_bounds(space_dir, T, x_offset-width, 0, 1, height))
					success = 1
					width++
				if(!success)
					break
			while(height < desired_height)
				if(!check_maint_room_bounds(space_dir, T, x_offset, -height, width, 1))
					break
				height++
			/*var/X1
			var/Y1
			var/X2
			var/Y2
			switch(space_dir)
				if(NORTH)
					X1 = T.x-x_offset
					Y1 = T.y-y_offset
					X2 = T.x-x_offset+width-1
					Y2 = T.y-y_offset+height-1
				if(SOUTH)
					X2 = T.x+x_offset
					Y2 = T.y+y_offset
					X1 = T.x+x_offset-width+1
					Y1 = T.y+y_offset-width+1
				if(EAST)
					X1 = T.x-y_offset
					Y2 = T.y+x_offset
					X2 = T.x-y_offset+width-1
					Y1 = T.y+x_offset-width+1
				if(WEST)
					X2 = T.x+y_offset
					Y1 = T.y-x_offset
					X1 = T.x+y_offset-width+1
					Y2 = T.y-x_offset+width-1*/
			to_chat(world, "Found [width]x[height] area at [T.x],[T.y]")
			if(width < 3 || height < 2)
				continue
			var/list/turfs = get_turfs_in_maint_room_bounds(space_dir, T, x_offset, 0, width, height)
			var/list/wall_turfs = get_turfs_in_maint_room_bounds(space_dir, T, x_offset+1, 1, width+2, height+2) - turfs
			for(var/turf/T2 in turfs)
				T2.ChangeTurf(/turf/simulated/floor/plating)
				var/turf/simulated/T2S = T2
				T2S.air = new
				T2S.air.oxygen = T2S.oxygen
				T2S.air.nitrogen = T2S.nitrogen
				A.contents += T2
			for(var/turf/T2 in wall_turfs)
				if(!istype(T2, /turf/simulated/wall) && !(locate(/obj/structure/window) in T2.contents) && !(locate(/obj/effect/spawner/window) in T2.contents))
					T2.ChangeTurf(/turf/simulated/wall)
					smooth_icon(T2)
					smooth_icon_neighbors(T2)
					if(istype(T2.loc, /area/space/maintgen))
						A.contents += T2
			var/rn = rand(1,10)
			if(rn < 10)
				door_turf.ChangeTurf(/turf/simulated/floor/plating)
				var/turf/simulated/DTS = door_turf
				DTS.air = new
				DTS.air.oxygen = DTS.oxygen
				DTS.air.nitrogen = DTS.nitrogen
				smooth_icon_neighbors(door_turf)
			switch(rn)
				if(1 to 7)
					new /obj/machinery/door/airlock/maintenance{req_access_txt="12"}(door_turf) // door
				if(8 to 9)
					var/obj/structure/falsewall/F = new(door_turf)
					smooth_icon_neighbors(F)
					smooth_icon(F)
			to_chat(world, "Successfully generated maintenance room at ([T.x],[T.y],[T.z])")
			break

/proc/get_turfs_in_maint_room_bounds(space_dir, turf/T, x_offset, y_offset, width, height)
	switch(space_dir)
		if(NORTH)
			return block(locate(T.x-x_offset, T.y-y_offset, T.z), locate(T.x-x_offset+width-1, T.y-y_offset+height-1, T.z))
		if(SOUTH)
			return block(locate(T.x+x_offset, T.y+y_offset, T.z), locate(T.x+x_offset-width+1, T.y+y_offset-height+1, T.z))
		if(EAST)
			return block(locate(T.x-y_offset, T.y+x_offset, T.z), locate(T.x-y_offset+height-1, T.y+x_offset-width+1, T.z))
		else
			return block(locate(T.x+y_offset, T.y-x_offset, T.z), locate(T.x+y_offset-height+1, T.y-x_offset+width-1, T.z))

/proc/check_maint_room_bounds(space_dir, turf/base, x_offset, y_offset, width, height)
	for(var/turf/T in get_turfs_in_maint_room_bounds(space_dir, base, x_offset, y_offset, width, height))
		if(T.loc.type != /area/space/maintgen)
			return 0
	return 1