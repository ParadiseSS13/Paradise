/datum/wires/particle_accelerator
	wire_count = 5
	holder_type = /obj/machinery/particle_accelerator/control_box
	proper_name = "Particle accelerator control"

/datum/wires/particle_accelerator/New(atom/_holder)
	wires = list(WIRE_PARTICLE_POWER, WIRE_PARTICLE_STRENGTH, WIRE_PARTICLE_INTERFACE, WIRE_PARTICLE_POWER_LIMIT)
	return ..()

/datum/wires/particle_accelerator/interactable(mob/user)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	if(C.construction_state == 2)
		return TRUE
	return FALSE

/datum/wires/particle_accelerator/on_pulse(wire)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	switch(wire)
		if(WIRE_PARTICLE_POWER)
			C.toggle_power()

		if(WIRE_PARTICLE_STRENGTH)
			C.add_strength()

		if(WIRE_PARTICLE_INTERFACE)
			C.interface_control = !C.interface_control

		if(WIRE_PARTICLE_POWER_LIMIT)
			C.visible_message("[bicon(C)]<b>[C]</b> makes a large whirring noise.")
	..()

/datum/wires/particle_accelerator/on_cut(wire, mend)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	switch(wire)
		if(WIRE_PARTICLE_POWER)
			if(C.active == !mend)
				C.toggle_power()

		if(WIRE_PARTICLE_STRENGTH)
			for(var/i in 1 to 2)
				C.remove_strength()

		if(WIRE_PARTICLE_INTERFACE)
			C.interface_control = mend

		if(WIRE_PARTICLE_POWER_LIMIT)
			C.strength_upper_limit = (mend ? 2 : 3)
			if(C.strength_upper_limit < C.strength)
				C.remove_strength()
	..()
