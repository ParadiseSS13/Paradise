/datum/wires/particle_acc/control_box
	wire_count = 5
	holder_type = /obj/machinery/particle_accelerator/control_box

#define PARTICLE_TOGGLE_WIRE 1 // Toggles whether the PA is on or not.
#define PARTICLE_STRENGTH_WIRE 2 // Determines the strength of the PA.
#define PARTICLE_INTERFACE_WIRE 4 // Determines the interface showing up.
#define PARTICLE_LIMIT_POWER_WIRE 8 // Determines how strong the PA can be.

/datum/wires/particle_acc/control_box/GetWireName(index)
	switch(index)
		if(PARTICLE_TOGGLE_WIRE)
			return "Power Toggle"
		
		if(PARTICLE_STRENGTH_WIRE)
			return "Strength"
		
		if(PARTICLE_INTERFACE_WIRE)
			return "Interface"
			
		if(PARTICLE_LIMIT_POWER_WIRE)
			return "Maximum Power"

/datum/wires/particle_acc/control_box/CanUse(mob/living/L)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	if(C.construction_state == 2)
		return 1
	return 0

/datum/wires/particle_acc/control_box/UpdatePulsed(index)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	switch(index)

		if(PARTICLE_TOGGLE_WIRE)
			C.toggle_power()

		if(PARTICLE_STRENGTH_WIRE)
			C.add_strength()

		if(PARTICLE_INTERFACE_WIRE)
			C.interface_control = !C.interface_control

		if(PARTICLE_LIMIT_POWER_WIRE)
			C.visible_message("[bicon(C)]<b>[C]</b> makes a large whirring noise.")
	..()

/datum/wires/particle_acc/control_box/UpdateCut(index, mended)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	switch(index)

		if(PARTICLE_TOGGLE_WIRE)
			if(C.active == !mended)
				C.toggle_power()

		if(PARTICLE_STRENGTH_WIRE)

			for(var/i = 1; i < 3; i++)
				C.remove_strength()

		if(PARTICLE_INTERFACE_WIRE)
			C.interface_control = mended

		if(PARTICLE_LIMIT_POWER_WIRE)
			C.strength_upper_limit = (mended ? 2 : 3)
			if(C.strength_upper_limit < C.strength)
				C.remove_strength()
	..()
