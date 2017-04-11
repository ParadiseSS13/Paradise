/turf/simulated/floor/plating/smatter
	name = "supermatter floor"
	icon_state = "smatter"
	light_color = "#8A8A00"

/turf/simulated/floor/plating/smatter/New()
	..()

	var/r = rand( 0, 3 )
	icon_state = "smatter[r]"

	spawn(2)
		var/list/step_overlays = list("s" = NORTH, "n" = SOUTH, "w" = EAST, "e" = WEST)
		for(var/direction in step_overlays)
			var/turf/turf_to_check = get_step(src,step_overlays[direction])
			if((istype(turf_to_check,/turf/space) || istype(turf_to_check,/turf/simulated/floor)) && !istype(turf_to_check,/turf/simulated/floor/plating/smatter))
				turf_to_check.overlays += image('icons/turf/floors.dmi', "smatter_side_[direction]")


/turf/simulated/floor/plating/smatter/Destroy()
	. = ..()

	var/list/step_overlays = list("n" = NORTH, "s" = SOUTH, "e" = EAST, "w" = WEST)
	// Kill and update the space overlays around us.
	for(var/direction in step_overlays)
		var/turf/space/T = get_step(src, step_overlays[direction])
		if(istype(T))
			for(var/next_direction in step_overlays)
				if(istype(get_step(T, step_overlays[next_direction]),/turf/simulated/floor/plating/smatter))
					T.overlays += image('icons/turf/floors.dmi', "smatter_side_[next_direction]")

/turf/simulated/wall/smatter
	name = "supermatter"
	desc = "thats a wall of supermatter"
	icon = 'icons/turf/walls.dmi'
	icon_state = "smatter"
	temperature = T20C+80
	density = 1
	opacity = 1
	blocks_air = 1


/turf/simulated/smatter/New()
	..()

	name = "supermatter"
	desc = "thats a wall of supermatter"
	icon = 'icons/turf/walls.dmi'
	icon_state = "smatter"
	temperature = T20C+80
	density = 1
	set_opacity(1)
	blocks_air = 1

	spawn(2)
		var/list/step_overlays = list("s" = NORTH, "n" = SOUTH, "w" = EAST, "e" = WEST)
		for(var/direction in step_overlays)
			var/turf/turf_to_check = get_step(src,step_overlays[direction])
			if(istype(turf_to_check,/turf/space) || istype(turf_to_check,/turf/simulated/floor))
				turf_to_check.overlays += image('icons/turf/walls.dmi', "smatter_side_[direction]")

/turf/simulated/smatter/Destroy()
	. = ..()

	var/list/step_overlays = list("n" = NORTH, "s" = SOUTH, "e" = EAST, "w" = WEST)
	// Kill and update the space overlays around us.
	for(var/direction in step_overlays)
		var/turf/space/T = get_step(src, step_overlays[direction])
		if(istype(T))
			T.overlays.Cut()
			for(var/next_direction in step_overlays)
				if(istype(get_step(T, step_overlays[next_direction]),/turf/simulated/wall/smatter))
					T.overlays += image('icons/turf/walls.dmi', "smatter_side_[next_direction]")

