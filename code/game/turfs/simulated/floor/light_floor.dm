/turf/simulated/floor/light
	name = "light floor"
	icon_state = "light_off"
	floor_tile = /obj/item/stack/tile/light
	/// Are we on
	var/on = FALSE
	/// Can we modify a colour
	var/can_modify_colour = TRUE
	/// Are we draining power
	var/using_power = FALSE

/turf/simulated/floor/light/Initialize(mapload)
	. = ..()
	update_icon()
	var/area/current_area = get_area(src)
	var/obj/machinery/power/apc/current_apc = current_area.get_apc()
	if(current_apc)
		RegisterSignal(current_area.powernet, COMSIG_POWERNET_POWER_CHANGE, PROC_REF(power_update), override = TRUE)
	toggle_light(TRUE)

/turf/simulated/floor/light/update_icon_state()
	if(on)
		icon_state = "light_on"
		set_light(5, null, color)
	else
		icon_state = "light_off"
		set_light(0)

/turf/simulated/floor/light/BeforeChange()
	toggle_light(FALSE)
	..()

/turf/simulated/floor/light/proc/power_update()
	SIGNAL_HANDLER
	if(power_check() || !on)
		return
	toggle_light(FALSE)

/turf/simulated/floor/light/proc/power_check()
	var/area/A = get_area(src)
	return A.powernet.has_power(PW_CHANNEL_LIGHTING)

/turf/simulated/floor/light/attack_hand(mob/user)
	if(!can_modify_colour)
		return
	if(user.a_intent != INTENT_HELP)
		return
	toggle_light(!on)

/turf/simulated/floor/light/attack_ai(mob/user)
	return attack_hand(user)

/turf/simulated/floor/light/attack_robot(mob/user)
	return attack_hand(user)

/turf/simulated/floor/light/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!can_modify_colour)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	var/new_color = tgui_input_color(user, "Select a bulb color", "Select a bulb color", color)
	if(isnull(new_color))
		return

	// Cancel if they walked away
	if(!Adjacent(user, src))
		return

	// Now lets make sure it cant go fully black. Yes I know this is more dense than my skull.
	var/list/hsl = rgb2hsl(hex2num(copytext(new_color, 2, 4)), hex2num(copytext(new_color, 4, 6)), hex2num(copytext(new_color, 6, 8)))
	hsl[3] = max(hsl[3], 0.4)
	var/list/rgb = hsl2rgb(arglist(hsl))
	color = "#[num2hex(rgb[1], 2)][num2hex(rgb[2], 2)][num2hex(rgb[3], 2)]"

	to_chat(user, "<span class='notice'>You change [src]'s light bulb color.</span>")
	update_icon()

/turf/simulated/floor/light/proc/toggle_light(light)
	if(!on && !power_check())
		visible_message("<span class='danger'>[src] doesn't react, it seems to be out of power.</span>")
		return
	var/area/A = get_area(src)
	// 0 = OFF
	// 1 = ON
	on = light
	if(!on && using_power)
		A.powernet.adjust_static_power(PW_CHANNEL_LIGHTING, -100)
		using_power = FALSE
	if(on && !using_power)
		using_power = TRUE
		A.powernet.adjust_static_power(PW_CHANNEL_LIGHTING, 100)
	update_icon()

/turf/simulated/floor/light/extinguish_light(force = FALSE)
	toggle_light(FALSE)
	visible_message("<span class='danger'>[src] flickers and falls dark.</span>")

/turf/simulated/floor/light/clean(floor_only)
	var/color_save = color
	..()
	color = color_save

/turf/simulated/floor/light/get_broken_states()
	return list("light_off")

// These tiles change color every now and then
/turf/simulated/floor/light/disco
	floor_tile = /obj/item/stack/tile/disco_light
	/// Cannot change its color with a multitool
	can_modify_colour = FALSE
	/// The tile can change into these colors
	var/list/available_colors = list("#d41e3c", "#ed7b39", "#fff540", "#77b02a", "#488bd4", "#b0fff1", "#94007a", "#ff417d")
	/// This is our current color, don't pick it again
	var/current_color

// We pick a random color when we are spawned
/turf/simulated/floor/light/disco/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

// The animation happens in this proc
/turf/simulated/floor/light/disco/proc/change_color()
	current_color = pick_excluding(available_colors, current_color)
	animate_fade_to_color_fill(src, current_color, 2)

// We change colors every now and then
/turf/simulated/floor/light/disco/process()
	if(on)
		change_color()

// Admins can toggle its color with advanced admin interaction
/turf/simulated/floor/light/disco/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		change_color()

// One is able to restart it, if power runs out. However, it cannot be turned off!
/turf/simulated/floor/light/disco/attack_hand(mob/user)
	if(!on)
		toggle_light(TRUE)

/turf/simulated/floor/light/disco/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/turf/simulated/floor/light/lavaland_air
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

