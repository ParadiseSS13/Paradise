/turf/simulated/floor/transparent/glass
	name = "glass floor"
	desc = "Don't jump on it... Or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "unsmooth"
	baseturf = /turf/space
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/simulated/floor/transparent/glass, /turf/simulated/floor/transparent/glass/reinforced, /turf/simulated/floor/transparent/glass/plasma, /turf/simulated/floor/transparent/glass/reinforced/plasma)
	light_power = 0.25
	light_range = 2
	layer = TRANSPARENT_TURF_LAYER
	keep_dir = FALSE
	intact = FALSE
	transparent_floor = TRUE
	heat_capacity = 800
	footstep = FOOTSTEP_GLASS
	barefootstep = FOOTSTEP_GLASS
	clawfootstep = FOOTSTEP_GLASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/transparent/glass/Initialize(mapload)
	. = ..()
	var/image/I = image('icons/turf/space.dmi', src, SPACE_ICON_STATE)
	I.plane = PLANE_SPACE
	underlays += I
	dir = SOUTH //dirs that are not 2/south cause smoothing jank
	icon_state = "" //Prevents default icon appearing behind the glass

/turf/simulated/floor/transparent/glass/welder_act(mob/user, obj/item/I)
	if(!broken && !burnt)
		return
	if(!I.tool_use_check(user, 0))
		return
	if(I.use_tool(src, user, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You fix some cracks in the glass.</span>")
		overlays -= current_overlay
		current_overlay = null
		burnt = FALSE
		broken = FALSE
		update_icon()

/turf/simulated/floor/transparent/glass/crowbar_act(mob/user, obj/item/I)
	if(!I || !user)
		return
	var/obj/item/stack/R
	if(ishuman(user))
		R = user.get_inactive_hand()
	else if(isrobot(user))
		var/mob/living/silicon/robot/robouser = user
		if(istype(robouser.module_state_1, /obj/item/stack/sheet/metal))
			R = robouser.module_state_1
		else if(istype(robouser.module_state_2, /obj/item/stack/sheet/metal))
			R = robouser.module_state_2
		else if(istype(robouser.module_state_3, /obj/item/stack/sheet/metal))
			R = robouser.module_state_3

	if(istype(R, /obj/item/stack/sheet/metal))
		if(R.get_amount() < 2) //not enough metal in the stack
			to_chat(user, "<span class='danger'>You also need to hold two sheets of metal to dismantle [src]!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You begin replacing [src]...</span>")
			playsound(src, I.usesound, 80, TRUE)
			if(do_after(user, 3 SECONDS * I.toolspeed * gettoolspeedmod(user), target = src))
				if(R.get_amount() < 2 || !transparent_floor)
					return
			else
				return
	else //not holding metal at all
		to_chat(user, "<span class='danger'>You also need to hold two sheets of metal to dismantle \the [src]!</span>")
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
		if(/turf/simulated/floor/transparent/glass/titanium/plasma)
			new /obj/item/stack/sheet/plastitaniumglass(src, 2)
	R.use(2)
	playsound(src, 'sound/items/deconstruct.ogg', 80, TRUE)
	ChangeTurf(/turf/simulated/floor/plating)


/turf/simulated/floor/transparent/glass/reinforced
	name = "reinforced glass floor"
	desc = "Jump on it, it can cope. Promise..."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	thermal_conductivity = 0.035
	heat_capacity = 1600

/turf/simulated/floor/transparent/glass/reinforced/acid_act(acidpwr, acid_volume)
	acidpwr = min(acidpwr, 50)
	. = ..()

/turf/simulated/floor/transparent/glass/plasma
	name = "plasma glass floor"
	desc = "Wait, was space always that color?"
	icon = 'icons/turf/floors/plasmaglass.dmi'
	thermal_conductivity = 0.030
	heat_capacity = 32000

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
	canSmoothWith = list(/turf/simulated/floor/transparent/glass/titanium, /turf/simulated/floor/transparent/glass/titanium/plasma)
	thermal_conductivity = 0.025
	heat_capacity = 1600

/turf/simulated/floor/transparent/glass/titanium/plasma
	name = "plastitanium glass floor"
	icon = 'icons/turf/floors/plastitaniumglass.dmi'
