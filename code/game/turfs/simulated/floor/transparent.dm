/turf/simulated/floor/transparent/glass
	name = "glass floor"
	desc = "Don't jump on it... Or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "glass-0"
	base_icon_state = "glass"
	baseturf = /turf/space
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_SIMULATED_TURFS, SMOOTH_GROUP_GLASS_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_GLASS_FLOOR)
	footstep = FOOTSTEP_GLASS
	barefootstep = FOOTSTEP_GLASS_BAREFOOT
	clawfootstep = FOOTSTEP_GLASS_BAREFOOT
	heavyfootstep = FOOTSTEP_GLASS_BAREFOOT
	light_power = 0.25
	light_range = 2
	keep_dir = FALSE
	intact = FALSE
	transparent_floor = TRUE
	heat_capacity = 800
	/// Amount of SSobj ticks (Roughly 2 seconds) that a extinguished glass floor tile has been lit up
	var/light_process = 0

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

	if(!istype(R, /obj/item/stack/sheet/metal) || R.get_amount() < 2)
		to_chat(user, "<span class='danger'>You also need to hold two sheets of metal to dismantle \the [src]!</span>")
		return

	to_chat(user, "<span class='notice'>You begin replacing [src]...</span>")
	playsound(src, I.usesound, 80, TRUE)

	if(do_after(user, 3 SECONDS * I.toolspeed, target = src))
		if(R.get_amount() < 2 || !transparent_floor)
			return
	else
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

/turf/simulated/floor/transparent/glass/extinguish_light(force)
	light_power = 0
	light_range = 0
	update_light()
	name = "dimmed glass flooring"
	desc = "Something shadowy moves to cover the glass. Perhaps shining a light will force it to clear?"
	START_PROCESSING(SSobj, src)

/turf/simulated/floor/transparent/glass/process()
	if(get_lumcount() > 0.2)
		light_process++
		if(light_process > 3)
			reset_light()
		return
	light_process = 0

/turf/simulated/floor/transparent/glass/proc/reset_light()
	light_process = 0
	light_power = initial(light_power)
	light_range = initial(light_range)
	update_light()
	name = initial(name)
	desc = initial(desc)
	STOP_PROCESSING(SSobj, src)

/turf/simulated/floor/transparent/glass/Destroy()
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	return ..()


/turf/simulated/floor/transparent/glass/can_lay_cable()
	return FALSE // this turf isn't "intact" but you also can't lay cable on it

/turf/simulated/floor/transparent/glass/reinforced
	name = "reinforced glass floor"
	desc = "Jump on it, it can cope. Promise..."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	base_icon_state = "reinf_glass"
	thermal_conductivity = 0.035
	heat_capacity = 1600

/turf/simulated/floor/transparent/glass/reinforced/acid_act(acidpwr, acid_volume)
	acidpwr = min(acidpwr, 50)
	. = ..()

/turf/simulated/floor/transparent/glass/plasma
	name = "plasma glass floor"
	desc = "Wait, was space always that color?"
	icon = 'icons/turf/floors/plasmaglass.dmi'
	icon_state = "plasmaglass-0"
	base_icon_state = "plasmaglass"
	thermal_conductivity = 0.030
	heat_capacity = 32000

/turf/simulated/floor/transparent/glass/reinforced/plasma
	name = "reinforced plasma glass floor"
	desc = "For when you REALLY don't want your floor choice to suffocate everyone."
	icon = 'icons/turf/floors/reinf_plasmaglass.dmi'
	icon_state = "reinf_plasmaglass-0"
	base_icon_state = "reinf_plasmaglass"
	thermal_conductivity = 0.025
	heat_capacity = 325000

/turf/simulated/floor/transparent/glass/titanium
	name = "titanium glass floor"
	desc = "Stylish AND strong!"
	icon = 'icons/turf/floors/titaniumglass.dmi'
	icon_state = "titaniumglass-0"
	base_icon_state = "titaniumglass"
	smoothing_groups = list(SMOOTH_GROUP_SIMULATED_TURFS, SMOOTH_GROUP_GLASS_FLOOR_TITANIUM)
	canSmoothWith = list(SMOOTH_GROUP_GLASS_FLOOR_TITANIUM)
	thermal_conductivity = 0.025
	heat_capacity = 1600

/turf/simulated/floor/transparent/glass/titanium/plasma
	name = "plastitanium glass floor"
	icon = 'icons/turf/floors/plastitaniumglass.dmi'
	icon_state = "plastitaniumglass-0"
	base_icon_state = "plastitaniumglass"
