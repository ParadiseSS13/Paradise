/turf/simulated/floor/transparent/glass
	name = "glass floor"
	desc = "Don't jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "unsmooth"
	baseturf = /turf/space
	broken_states = list("damaged1", "damaged2", "damaged3")
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/simulated/floor/transparent)
	footstep = FOOTSTEP_PLATING
	light_power = 0.75
	light_range = 2
	layer = TRANSPARENT_TURF_LAYER
	keep_dir = FALSE
	intact = FALSE
	transparent_floor = TRUE

/turf/simulated/floor/transparent/glass/Initialize(mapload)
	. = ..()
	var/image/I = image('icons/turf/space.dmi', src, SPACE_ICON_STATE)
	I.plane = PLANE_SPACE
	underlays += I
	dir = 2
	icon_state = "" //Prevents default icon appearing behind the glass

/turf/simulated/floor/transparent/attackby(obj/item/C as obj, mob/user as mob, params)
	if(!C || !user)
		return
	if(istype(C, /obj/item/crowbar))
		to_chat(user, "<span class='notice'>You begin removing the glass...</span>")
		playsound(src, C.usesound, 80, 1)
		if(do_after(user, 30 * C.toolspeed, target = src))
			if(!istype(src, /turf/simulated/floor/transparent))
				return
			if(istype(src, /turf/simulated/floor/transparent/glass/reinforced))
				new /obj/item/stack/sheet/rglass(src, 2)
			else
				new /obj/item/stack/sheet/glass(src, 2)
			ChangeTurf(/turf/simulated/floor/plating)


/turf/simulated/floor/transparent/glass/reinforced
	name = "reinforced glass floor"
	desc = "Do jump on it, it can take it. Promise..."
	icon = 'icons/turf/floors/reinf_glass.dmi'
