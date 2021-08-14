/turf/simulated/floor/transparent/glass
	name = "glass floor"
	desc = "Don't jump on it... Or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "unsmooth"
	baseturf = /turf/space
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/simulated/floor/transparent/glass, /turf/simulated/floor/transparent/glass/reinforced, /turf/simulated/floor/transparent/glass/plasma, /turf/simulated/floor/transparent/glass/reinforced/plasma)
	footstep = FOOTSTEP_GLASS
	barefootstep = FOOTSTEP_GLASS_BAREFOOT
	clawfootstep = FOOTSTEP_GLASS_BAREFOOT
	heavyfootstep = FOOTSTEP_GLASS_BAREFOOT
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
	dir = SOUTH //dirs that are not 2/south cause smoothing jank
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
				to_chat(user, "<span class='notice'>You begin replacing [src]...</span>")
				playsound(src, C.usesound, 80, TRUE)
				if(do_after(user, 3 SECONDS * C.toolspeed, target = src))
					if(R.get_amount() >= 2 && !istype(src, /turf/simulated/floor/plating))
						if(!transparent_floor)
							return
		switch(type) //What material is returned? Depends on the turf
			if(/turf/simulated/floor/transparent/glass/reinforced)
				new /obj/item/stack/sheet/rglass(src, 2)
			if(/turf/simulated/floor/transparent/glass)
				new /obj/item/stack/sheet/glass(src, 2)
			if(/turf/simulated/floor/transparent/glass/plasma)
				new /obj/item/stack/sheet/plasmaglass(src, 2)
			if(/turf/simulated/floor/transparent/glass/reinforced/plasma)
				new /obj/item/stack/sheet/plasmarglass(src, 2)
			if(/turf/simulated/floor/transparent/glass/titanium)
				new /obj/item/stack/sheet/titaniumglass(src, 2)
			if(/turf/simulated/floor/transparent/glass/titanium/plastic)
				new /obj/item/stack/sheet/plastitaniumglass(src, 2)
			R.use(2)
			playsound(src, 'sound/items/deconstruct.ogg', 80, TRUE)
			ChangeTurf(/turf/simulated/floor/plating)
		else //not holding metal at all
			to_chat(user, "<span class='danger'>You also need to hold two sheets of metal to dismantle \the [src]!</span>")
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

/turf/simulated/floor/transparent/glass/plasma
	name = "plasma glass floor"
	desc = "Wait, was space always that color?"
	icon = 'icons/turf/floors/plasmaglass.dmi'
	thermal_conductivity = 0.030
	heat_capacity = 75000

/turf/simulated/floor/transparent/glass/reinforced/plasma
	name = "reinforced plasma glass floor"
	desc = "For when you REALLY don't want your floor choice to suffocate everyone."
	icon = 'icons/turf/floors/reinf_plasmaglass.dmi'
	thermal_conductivity = 0.025
	heat_capacity = 325000

/turf/simulated/floor/transparent/glass/titanium
	name = "titanium glass floor"
	desc = "Stylish AND strong!"
	icon = 'icons/turf/floors/titaniumglass.dmi'
	canSmoothWith = list(/turf/simulated/floor/transparent/glass/titanium, /turf/simulated/floor/transparent/glass/titanium/plastic)
	thermal_conductivity = 0.025
	heat_capacity = 325000

/turf/simulated/floor/transparent/glass/titanium/plastic
	name = "plastitanium glass floor"
	icon = 'icons/turf/floors/plastitaniumglass.dmi'
