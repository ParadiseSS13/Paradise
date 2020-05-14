/*
	The core of the entire telecomms operation
*/

/obj/machinery/tcomms/core
	name = "Telecommunications Core"
	desc = "A large rack full of communications equipment. Looks important."
	icon_state = "core"
	// The NTTC config for this device
	var/datum/nttc_configuration/nttc = new()
	// List of all reachable devices
	var/list/reachable_zlevels = list()
	// List of all linked relays
	var/list/linked_relays = list()
	// Password for linking stuff together
	var/link_password

/obj/machinery/tcomms/core/Initialize(mapload)
	. = ..()
	link_password = GenerateKey()
	reachable_zlevels |= loc.z

// Helper to see if a Z-level is reachable
/obj/machinery/tcomms/core/proc/zlevel_reachable(zlevel)
	if(zlevel in reachable_zlevels)
		return TRUE
	else
		return FALSE

// This handles taking in the message then broadcasting it out
/obj/machinery/tcomms/core/proc/handle_message(datum/tcomms_message/tcm)
	// Don't do anything with rejected signals, or if were offline
	if(tcm.reject || !active)
		return FALSE
	// Kill the signal if its on a z-level that isnt reachable
	if(!(tcm.source_level in reachable_zlevels))
		return FALSE

	// Now we generate the list of where that signal should go to
	tcm.zlevels = reachable_zlevels
	tcm.zlevels |= tcm.source_level

	// Now check if they actually have pieces, if so, broadcast
	if(tcm.message_pieces)
		broadcast_message(tcm)
		return TRUE

	return FALSE

// This remakes the list of reachable zlevels. Call this if you add or remove a relay
/obj/machinery/tcomms/core/proc/refresh_zlevels()
	// Refresh the list
	reachable_zlevels = list()
	for(var/obj/machinery/tcomms/relay/R in GLOB.tcomms_machines)
		reachable_zlevels |= R.loc.z

