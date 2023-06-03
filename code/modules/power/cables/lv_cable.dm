/obj/structure/cable/low_voltage
	name = "low-voltage power cable"
	desc = "A flexible superconducting cable for light regional power transfer."
	icon = 'icons/obj/power_cond/power_cond_white.dmi'
	icon_state = "0-1"
	level = 1
	anchored = TRUE
	on_blueprints = TRUE
	color = COLOR_RED

	power_voltage_type = VOLTAGE_LOW

	//The following vars are set here for the benefit of mapping - they are reset when the cable is spawned
	alpha = 128	//is set to 255 when spawned
	plane = GAME_PLANE //is set to FLOOR_PLANE when spawned
	layer = LOW_OBJ_LAYER //isset to WIRE_LAYER when spawned


// Items usable on a cable :
//   - Wirecutters : cut it duh !
//   - Cable coil : merge cables
//   - Multitool : get the power currently passing through the cable
//
/obj/structure/cable/low_voltage/attackby(obj/item/W, mob/user)
	var/turf/T = get_turf(src)
	if(T.transparent_floor || T.intact)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return

	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		if(coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>Not enough cable!</span>")
			return
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/twohanded/rcl))
		var/obj/item/twohanded/rcl/R = W
		if(R.loaded)
			R.loaded.cable_join(src, user)
			R.is_empty(user)

	else if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		cable_color(C.colourName)

	else
		if(W.flags & CONDUCT)
			shock(user, 50, 0.7)

	add_fingerprint(user)

/obj/structure/cable/low_voltage/multitool_act(mob/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(T.intact)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(powernet && (powernet.available_power > 0))		// is it powered?
		to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.available_power)]\nLoad: [DisplayPower(powernet.power_demand)]\nExcess power: [DisplayPower(get_surplus())]</span>")
	else
		to_chat(user, "<span class='danger'>The cable is not powered.</span>")
	shock(user, 5, 0.2)

/obj/structure/cable/low_voltage/wirecutter_act(mob/user, obj/item/I)
	. = ..()
	if(!.)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(shock(user, 50))
		return
	var/turf/T = get_turf(src)
	user.visible_message("[user] cuts the cable.", "<span class='notice'>You cut the cable.</span>")
	investigate_log("was cut by [key_name(usr, 1)] in [get_area(user)]([T.x], [T.y], [T.z] - [ADMIN_JMP(T)])","wires")
	deconstruct()

/obj/structure/cable/low_voltage/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	if(!(flags & NODECONSTRUCT))
		if(d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new cable_coil_type(T, 2, paramcolor = color)
		else
			new cable_coil_type(T, 1, paramcolor = color)
	return ..()

/obj/structure/cable/low_voltage/proc/cable_color(colorC)
	if(!colorC)
		color = COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = COLOR_ORANGE
	else
		color = colorC

/obj/structure/cable/low_voltage/proc/color_rainbow()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	return color

/obj/structure/cable/low_voltage/yellow
	color = COLOR_YELLOW

/obj/structure/cable/low_voltage/green
	color = COLOR_GREEN

/obj/structure/cable/low_voltage/blue
	color = COLOR_BLUE

/obj/structure/cable/low_voltage/pink
	color = COLOR_PINK

/obj/structure/cable/low_voltage/orange
	color = COLOR_ORANGE

/obj/structure/cable/low_voltage/cyan
	color = COLOR_CYAN

/obj/structure/cable/low_voltage/white
	color = COLOR_WHITE
