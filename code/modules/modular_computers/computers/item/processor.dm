// Held by /obj/machinery/modular_computer to reduce amount of copy-pasted code.
/obj/item/modular_computer/processor
	name = "processing unit"
	desc = "You shouldn't see this. If you do, report it."
	icon = null
	icon_state = null
	icon_state_unpowered = null
	icon_state_menu = null
	hardware_flag = 0

	var/obj/machinery/modular_computer/machinery_computer = null

/obj/item/modular_computer/processor/Destroy()
	. = ..()
	if(machinery_computer && (machinery_computer.cpu == src))
		machinery_computer.cpu = null
	machinery_computer = null

/obj/item/modular_computer/processor/New(comp)
	if(!comp || !istype(comp, /obj/machinery/modular_computer))
		CRASH("Inapropriate type passed to obj/item/modular_computer/processor/New()! Aborting.")
		return
	// Obtain reference to machinery computer
	all_components = list()
	idle_threads = list()
	machinery_computer = comp
	machinery_computer.cpu = src
	hardware_flag = machinery_computer.hardware_flag
	max_hardware_size = machinery_computer.max_hardware_size
	steel_sheet_cost = machinery_computer.steel_sheet_cost
	obj_integrity = machinery_computer.obj_integrity
	max_integrity = machinery_computer.max_integrity
	integrity_failure = machinery_computer.integrity_failure
	base_active_power_usage = machinery_computer.base_active_power_usage
	base_idle_power_usage = machinery_computer.base_idle_power_usage

/obj/item/modular_computer/processor/relay_qdel()
	qdel(machinery_computer)

/obj/item/modular_computer/processor/update_icon()
	if(machinery_computer)
		return machinery_computer.update_icon()

// This thing is not meant to be used on it's own, get topic data from our machinery owner.
//obj/item/modular_computer/processor/canUseTopic(user, state)
//	if(!machinery_computer)
//		return 0

//	return machinery_computer.canUseTopic(user, state)

/obj/item/modular_computer/processor/shutdown_computer()
	if(!machinery_computer)
		return
	..()
	machinery_computer.update_icon()
	return

/obj/item/modular_computer/processor/add_verb(path)
	switch(path)
		if(MC_CARD)
			machinery_computer.verbs += /obj/machinery/modular_computer/proc/eject_id
		if(MC_SDD)
			machinery_computer.verbs += /obj/machinery/modular_computer/proc/eject_disk
		if(MC_AI)
			machinery_computer.verbs += /obj/machinery/modular_computer/proc/eject_card

/obj/item/modular_computer/processor/remove_verb(path)
	switch(path)
		if(MC_CARD)
			machinery_computer.verbs -= /obj/machinery/modular_computer/proc/eject_id
		if(MC_SDD)
			machinery_computer.verbs -= /obj/machinery/modular_computer/proc/eject_disk
		if(MC_AI)
			machinery_computer.verbs -= /obj/machinery/modular_computer/proc/eject_card
