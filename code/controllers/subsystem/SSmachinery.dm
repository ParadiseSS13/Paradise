#define SSMACHINES_DEFERREDPOWERNETS 1
#define SSMACHINES_POWERNETS 2
#define SSMACHINES_PREMACHINERY 3
#define SSMACHINES_MACHINERY 4
SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = INIT_ORDER_MACHINES
	flags = SS_KEEP_TIMING
	offline_implications = "Machinery will no longer process. Shuttle call recommended."
	cpu_display = SS_CPUDISPLAY_HIGH

	/// Associative list of all machines that exist.
	VAR_PRIVATE/list/machines_by_type = list()

	/// All machines, not just those that are processing.
	VAR_PRIVATE/list/all_machines = list()

	var/list/processing = list()
	var/list/currentrun = list()
	/// All regional powernets (/datum/regional_powernet) in the world
	var/list/powernets = list()
	var/list/deferred_powernet_rebuilds = list()

	var/currentpart = SSMACHINES_DEFERREDPOWERNETS

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()

/// Registers a machine with the machine subsystem; should only be called by the machine itself during its creation.
/datum/controller/subsystem/machines/proc/register_machine(obj/machinery/machine)
	LAZYADD(machines_by_type[machine.type], machine)
	all_machines |= machine

/// Removes a machine from the machine subsystem; should only be called by the machine itself inside Destroy.
/datum/controller/subsystem/machines/proc/unregister_machine(obj/machinery/machine)
	var/list/existing = machines_by_type[machine.type]
	existing -= machine
	if(!length(existing))
		machines_by_type -= machine.type
	all_machines -= machine

/// Gets a list of all machines that are either the passed type or a subtype.
/datum/controller/subsystem/machines/proc/get_by_type(obj/machinery/machine_type, subtypes = TRUE)
	if(!ispath(machine_type))
		machine_type = machine_type.type
	if(!ispath(machine_type, /obj/machinery))
		CRASH("called SSmachines.get_by_type with a non-machine type [machine_type]")
	. = list()
	if(machine_type in machines_by_type)
		. |= machines_by_type[machine_type]

	if(!subtypes)
		return

	for(var/next_type in subtypesof(machine_type))
		var/list/found_machines = machines_by_type[next_type]
		if(found_machines)
			. |= found_machines

/datum/controller/subsystem/machines/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing"] = length(processing)
	.["custom"] = cust

/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/regional_powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in GLOB.cable_list)
		if(!PC.powernet)
			var/datum/regional_powernet/new_pn = new()
			new_pn.add_cable(PC)
			propagate_network(PC, PC.powernet)

/datum/controller/subsystem/machines/get_stat_details()
	return "Machines: [length(all_machines)] | Powernets: [length(powernets)] | Deferred: [length(deferred_powernet_rebuilds)]"

/datum/controller/subsystem/machines/proc/process_defered_powernets(resumed = 0)
	if(!resumed)
		src.currentrun = deferred_powernet_rebuilds.Copy()
	//cache for sanid speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/obj/O = currentrun[length(currentrun)]
		currentrun.len--
		if(O && !QDELETED(O))
			var/datum/regional_powernet/newPN = new() // create a new powernet...
			propagate_network(O, newPN)//... and propagate it to the other side of the cable

		deferred_powernet_rebuilds.Remove(O)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/proc/process_powernets(resumed = 0)
	if(!resumed)
		src.currentrun = powernets.Copy()
	//cache for sanid speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/datum/regional_powernet/P = currentrun[length(currentrun)]
		currentrun.len--
		if(P)
			P.process_power() // reset the power state
		else
			powernets.Remove(P)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/proc/process_machines(resumed = 0)
	var/seconds = wait * 0.1
	if(!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/obj/machinery/thing = currentrun[length(currentrun)]
		currentrun.len--
		if(!QDELETED(thing) && thing.process(seconds) != PROCESS_KILL)
			if(prob(MACHINE_FLICKER_CHANCE))
				thing.flicker()
		else
			processing -= thing
			if(!QDELETED(thing))
				thing.isprocessing = FALSE
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/fire(resumed = 0)
	if(currentpart == SSMACHINES_DEFERREDPOWERNETS || !resumed)
		process_defered_powernets(resumed)
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSMACHINES_POWERNETS

	if(currentpart == SSMACHINES_POWERNETS || !resumed)
		process_powernets(resumed)
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSMACHINES_MACHINERY

	if(currentpart == SSMACHINES_MACHINERY || !resumed)
		process_machines(resumed)
		if(state != SS_RUNNING)
			return
		resumed = 0
	currentpart = SSMACHINES_DEFERREDPOWERNETS


/datum/controller/subsystem/machines/proc/setup_template_powernets(list/cables)
	for(var/A in cables)
		var/obj/structure/cable/PC = A
		if(!PC.powernet)
			var/datum/regional_powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/controller/subsystem/machines/Recover()
	if(istype(SSmachines.processing))
		processing = SSmachines.processing
	if(istype(SSmachines.powernets))
		powernets = SSmachines.powernets

#undef SSMACHINES_DEFERREDPOWERNETS
#undef SSMACHINES_POWERNETS
#undef SSMACHINES_PREMACHINERY
#undef SSMACHINES_MACHINERY
