
/datum/wires/mech
	holder_type = /obj/mecha
	wire_count = 12 // 8 actual, 4 duds
	proper_name = "Mecha wiring"

/datum/wires/mech/New(atom/_holder)
	wires = list(WIRE_MECH_DIRECTION, WIRE_MECH_POWER , WIRE_MECH_SELECT_MODULE, WIRE_MECH_STRAFE, WIRE_MECH_USE_MODULE, WIRE_MECH_WALK, WIRE_MECH_RADIO , WIRE_MECH_VISUALDATA)
	return ..()

/datum/wires/mech/interactable(mob/user)
	var/obj/mecha/A = holder
	if(A.state == MECHA_OPEN_HATCH)
		return TRUE
	return FALSE

/datum/wires/mech/get_status()
	. = ..()
	var/obj/mecha/A = holder
	. += "The high-voltage power indicator blinks [is_cut(WIRE_MECH_POWER) ? "red" : "green"]"
	. += "The module selection data-bus indicator is [is_cut(WIRE_MECH_SELECT_MODULE) ? "off" : "on"]"
	. += "The strafe CPU data-bus light is [is_cut(WIRE_MECH_STRAFE) ? "not blinking" : "blinking"]"
	. += "The module data-transfer data-bus light is [is_cut(WIRE_MECH_USE_MODULE) ? "not blinking" : "blinking"]"
	. += "The internal radio wire is [is_cut(WIRE_MECH_RADIO) ? "cut" : "intact"]"
	. += "The internal gyroscope-direction assembly wire is [is_cut(WIRE_MECH_DIRECTION) ? "cut" : "intact"]"
	. += "The wire leading to the mech actuators is [is_cut(WIRE_MECH_WALK) ? "cut" : "intact"]"
	. += "The wire leading to the internal display screens is [is_cut(WIRE_MECH_VISUALDATA) ? "cut" : "intact"]"
	// DNA wire is special.
	. += "The DNA lock light is [A.dna_cut ? "blinking red" : "showing green"]"

/datum/wires/mech/on_cut(wire, mend)
	var/obj/mecha/A = holder
	switch(wire)
		if(WIRE_MECH_DIRECTION)
			return
		if(WIRE_MECH_POWER)
			return
		if(WIRE_MECH_SELECT_MODULE)
			return
		if(WIRE_MECH_STRAFE)
			return
		if(WIRE_MECH_USE_MODULE)
			return
		if(WIRE_MECH_WALK)
			return
		if(WIRE_MECH_RADIO)
			if(mend)
				A.radio.broadcasting = TRUE
				A.radio.listening = FALSE
			else
				A.radio.broadcasting = FALSE
				A.radio.listening = FALSE
			return
		if(WIRE_MECH_VISUALDATA)
			if(mend)
				A.grant_vision()
			else
				A.remove_vision()
			return

	. = ..()

/datum/wires/mech/on_pulse(wire)
	var/obj/mecha/A = holder
	switch(wire)
		if(WIRE_MECH_DIRECTION)
			A.mechturn(pick(NORTH, SOUTH , EAST, WEST, SOUTHEAST , SOUTHWEST, NORTHEAST, NORTHWEST))
			return
		if(WIRE_MECH_POWER)
			return
		if(WIRE_MECH_SELECT_MODULE)
			var/obj/item/mecha_parts/mecha_equipment/thing = pick(A.equipment)
			if(!thing.selectable)
				thing = null
			A.selected = thing
			return
		if(WIRE_MECH_STRAFE)
			if(A.strafing_flags)
				A.strafing_action.Activate(force = TRUE)
			return
		if(WIRE_MECH_USE_MODULE)
			if(!A.selected)
				return
			var/list/targets = list()
			var/turf/real_target
			var/x = A.dir & NORTH - A.dir & SOUTH
			var/y = A.dir & EAST - A.dir & WEST
			if(A.selected.range & MECHA_RANGED)
				real_target = locate(A.x + round(rand(1,5)*x), A.y + round(rand(1,5)*y), A.z)
				// why shoot map edge..
				if(!real_target)
					return
				targets = block(real_target.x-1, real_target.y-1, A.z, real_target.x+1, real_target.y+1, A.z)
				while(targets.Find(null))
					targets.Remove(null)
			else
				real_target = locate(A.x + x, A.y + y, A.z)
				if(!real_target)
					return
				targets = list(real_target)
			A.selected.action(pick(targets))
			return
		if(WIRE_MECH_WALK)
			A.mechstep(A.dir)
			return
		if(WIRE_MECH_RADIO)
			A.radio.broadcasting = !A.radio.broadcasting
			A.radio.listening = !A.radio.listening
			return
		if(WIRE_MECH_VISUALDATA)
			return

	. = ..()

