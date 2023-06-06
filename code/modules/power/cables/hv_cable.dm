

/obj/structure/cable/high_voltage
	name = "high-voltage power cable"
	desc = "A flexible superconducting cable for heavy-duty station-wide power transfer."
	icon = 'icons/obj/power_cond/hv_power_cond.dmi'
	icon_state = "0-1"
	level = 1
	anchored = TRUE
	on_blueprints = TRUE

	//The following vars are set here for the benefit of mapping - they are reset when the cable is spawned
	alpha = 128	//is set to 255 when spawned
	plane = GAME_PLANE //is set to FLOOR_PLANE when spawned
	layer = LOW_OBJ_LAYER //isset to WIRE_LAYER when spawned

	power_voltage_type = VOLTAGE_HIGH
	cable_coil_type = /obj/item/stack/cable_coil/high_voltage

#warn DECONSTRUCTION_SPECIAL BEHAVIOUR
/obj/structure/cable/high_voltage/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	if(!(flags & NODECONSTRUCT))
		if(d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new cable_coil_type(T, 2, paramcolor = color)
		else
			new cable_coil_type(T, 1, paramcolor = color)
	return ..()
