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

	/// List of all machines that exist in world
	VAR_PRIVATE/list/all_machinery = list()

	/// List of all machines that exist in world by type, as `machine_type => list_of_machinery_of_type
	VAR_PRIVATE/list/machinery_by_type = list()

	var/list/processing = list()
	var/list/currentrun = list()
	/// All regional powernets (/datum/regional_powernet) in the world
	var/list/powernets = list()
	var/list/deferred_powernet_rebuilds = list()

	var/currentpart = SSMACHINES_DEFERREDPOWERNETS

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()

/datum/controller/subsystem/machines/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing"] = length(processing)
	.["custom"] = cust

/datum/controller/subsystem/machines/proc/register_machine(obj/machinery/machine)
	if(!machine)
		CRASH("Non existing machinery was tried to be registered")

	LAZYADD(machinery_by_type[machine.type], machine)
	all_machinery |= machine

/datum/controller/subsystem/machines/proc/unregister_machine(obj/machinery/machine)
	if(!machine)
		CRASH("Non existing machinery was tried to be unregistered")

	var/list/existing = machinery_by_type[machine.type]
	existing -= machine
	if(!length(existing))
		machinery_by_type -= machine.type
	all_machinery -= machine

/datum/controller/subsystem/machines/proc/get_machinery_of_type(obj/machinery/machinery_type)
	if(!machinery_type)
		return list()

	if(!ispath(machinery_type))
		machinery_type = machinery_type.type

	if(!ispath(machinery_type, /obj/machinery))
		CRASH("Non-machinery type passed in `/datum/controller/subsystem/machines/proc/get_machinery_of_type`")

	if(machinery_type == /obj/machinery)
		return get_all_machinery()

	var/list/machinery = list()
	for(var/type in typesof(machinery_type))
		var/list/machinery_of_type = machinery_by_type[type]
		if(machinery_of_type)
			machinery += machinery_of_type

	return machinery

/datum/controller/subsystem/machines/proc/get_all_machinery()
	return all_machinery.Copy()

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
	return "Machines: [length(processing)] | Powernets: [length(powernets)] | Deferred: [length(deferred_powernet_rebuilds)]"

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
	if(istype(SSmachines.all_machinery))
		all_machinery = SSmachines.all_machinery
	if(istype(SSmachines.machinery_by_type))
		machinery_by_type = SSmachines.machinery_by_type
