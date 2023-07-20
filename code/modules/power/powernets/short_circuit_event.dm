
/datum/short_circuit_event
	var/event_name = "Short Circuit Event"

	var/datum/regional_powernet/src_powernet

	var/datum/regional_powernet/trgt_powernet

	// Duration in process cycles
	var/duration = 0

/datum/short_circuit_event/New(datum/_src_powernet, datum/_trgt_powernet)
	if(!istype(_src_powernet, /datum/regional_powernet))
		stack_trace("Short Circuit Event started with bad arguments _src_powernet = [isnull(_src_powernet) ? "NULL" : _src_powernet.type]")
		log_debug("Short Circuit Event Cancelled: bad arguments passed")
		end_short_circuit()
		return FALSE
	src_powernet = _src_powernet
	trgt_powernet = _trgt_powernet
	return TRUE

/datum/short_circuit_event/proc/process_short_circuit()
	duration++

/datum/short_circuit_event/proc/end_short_circuit()
	src_powernet.short_circuit_events -= src
	src_powernet = null
	trgt_powernet = null
	qdel(src)

#define SC_MACHINE_EXPLODE	2
#define SC_MACHINE_SPARK	20
#define SC_LIGHT_GLOW		50
#define SC_LIGHT_POP		20
#define SC_BREAKER_TRIP		10

/datum/short_circuit_event/machine
	event_name = "Machine Short Circuit Event"
	var/obj/machinery/affected_machine

/datum/short_circuit_event/machine/New(datum/_src_powernet, datum/_trgt_powernet, _affected_machine, magnitude)
	. = ..()
	if(!.)
		return
	if(!_affected_machine)
		stack_trace("Powernet [src_powernet.UID()] ([length(src_powernet.cables)] Cables) ([length(src_powernet.nodes)] Nodes) Machine Short Circuit Event started without an _affected_machine")
		end_short_circuit()
		return
	affected_machine = _affected_machine

#warn implement machine explodey thing here
/datum/short_circuit_event/machine/process_short_circuit()
	return ..()

#define SC_MW_LIMIT 100000
#define SC_WIRE_LIMIT 8

/datum/short_circuit_event/wire
	event_name = "Cable Short Circuit Event"

	var/obj/structure/cable/initial_cable

	var/list/affected_cables = list()

/datum/short_circuit_event/wire/New(datum/_src_powernet, datum/_trgt_powernet, _initial_cable, magnitude)
	. = ..()
	if(!.)
		return
	if(!_initial_cable)
		stack_trace("Powernet [src_powernet.UID()] ([length(src_powernet.cables)] Cables) ([length(src_powernet.nodes)] Nodes) Wire Short Circuit Event started without an _initial_cable")
		end_short_circuit()
		return
	initial_cable = _initial_cable
	get_connected_cables(initial_cable, count = magnitude)


/datum/short_circuit_event/wire/proc/get_connected_cables(obj/structure/cable/root_cable, count = 1)
	// A full list of cables that we are iterating through, contains visited and unvisited objects
	var/list/worklist = list(root_cable)
	// The current index we are at in our worklist
	var/index = 1
	// The object we're current working with -> worklist[index]
	var/obj/structure/cable/current_object = null

	var/index_cap = count

	while(index <= length(worklist))
		current_object = worklist[index] // get the next power object found and increment index
		index++
		affected_cables |= current_object
		worklist |= current_object.get_connections(current_object.power_voltage_type) //get adjacents power objects, with or without a powernet
		if(index > index_cap)
			break

#warn implement wire melting thingy here
/datum/short_circuit_event/wire/process_short_circuit()
	return ..()
