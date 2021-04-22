/turf/simulated/floor/transparent/glass
	name = "glass floor"
	desc = "Don't jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "unsmooth"
	baseturf = /turf/space
	broken_states = list("damaged1", "damaged2", "damaged3")
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/simulated/floor/transparent/glass)
	footstep = FOOTSTEP_PLATING
	light_power = 0.25
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
	dir = SOUTH //dirs that are not 2 cause smoothing jank
	icon_state = "" //Prevents default icon appearing behind the glass

/turf/simulated/floor/transparent/glass/attackby(obj/item/C, mob/user, params)
	if(!C || !user)
		return
	if(istype(C, /obj/item/crowbar))
		var/obj/item/stack/R = user.get_inactive_hand()
		if(istype(R, /obj/item/stack/sheet/metal))
			if(R.get_amount() < 2) //not enough metal in the stack
				to_chat(user, "<span class='danger'>You also need to hold two sheets of metal to dismantle [src]!</span>")
				return
			else
				to_chat(user, "<span class='notice'>You begin replacing the glass...</span>")
				playsound(src, C.usesound, 80, TRUE)
				if(do_after(user, 3 SECONDS * C.toolspeed, target = src))
					if(R.get_amount() >= 2 && !istype(src, /turf/simulated/floor/plating))
						if(!transparent_floor)
							return
						if(istype(src, /turf/simulated/floor/transparent/glass/reinforced))
							new /obj/item/stack/sheet/rglass(src, 2)
						else
							new /obj/item/stack/sheet/glass(src, 2)
						R.use(2)
						ChangeTurf(/turf/simulated/floor/plating)

		else //not holding metal at all
			to_chat(user, "<span class='danger'>You also need to hold two sheets of metal to dismantle [src]!</span>")
			return


/turf/simulated/floor/transparent/glass/reinforced
	name = "reinforced glass floor"
	desc = "Jump on it, it can cope. Promise..."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	thermal_conductivity = 0.035
	heat_capacity = 50000

/turf/simulated/floor/transparent/glass/reinforced/acid_act(acidpwr, acid_volume)
	acidpwr = min(acidpwr, 50)
	. = ..()
