/turf/simulated/floor/light
	name = "\improper light floor"
	light_range = 5
	icon_state = "light_on"
	floor_tile = /obj/item/stack/tile/light
	broken_states = list("light_off")
	/// Are we on
	var/on = TRUE
	/// Are we broken
	var/light_broken = FALSE
	/// Can we modify a colour
	var/can_modify_colour = TRUE

/turf/simulated/floor/light/Initialize(mapload)
	. = ..()
	update_icon()

/turf/simulated/floor/light/update_icon()
	..()
	if(on)
		icon_state = "light_on"
		set_light(5, null, color)
	else
		icon_state = "light_off"
		set_light(0)

/turf/simulated/floor/light/BeforeChange()
	set_light(0)
	..()

/turf/simulated/floor/light/attack_hand(mob/user)
	if(!can_modify_colour)
		return
	toggle_light(!on)

/turf/simulated/floor/light/attackby(obj/item/C, mob/user, params)
	if(istype(C, /obj/item/light/bulb)) //only for light tiles
		if(!light_broken)
			qdel(C)
			light_broken = FALSE
			update_icon()
			to_chat(user, "<span class='notice'>You replace the light bulb.</span>")
		else
			to_chat(user, "<span class='notice'>The light bulb seems fine, no need to replace it.</span>")
	else
		return ..()

/turf/simulated/floor/light/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!can_modify_colour)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!light_broken)
		var/new_color = input(user, "Select a bulb color", "Select a bulb color", color) as color|null
		if(!new_color)
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
	else
		to_chat(user, "<span class='warning'>[src]'s light bulb appears to have burned out.</span>")

/turf/simulated/floor/light/proc/toggle_light(light)
	// 0 = OFF
	// 1 = ON
	on = light
	update_icon()

/turf/simulated/floor/light/extinguish_light()
	toggle_light(FALSE)
	visible_message("<span class='danger'>[src] flickers and falls dark.</span>")
