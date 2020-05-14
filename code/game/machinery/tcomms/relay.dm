/*
	Relays just expand transmitting and recieving to other Z-levels.
*/

/obj/machinery/tcomms/relay
	name = "Telecommunications Relay"
	desc = "A large device with several radio antennas on it."
	icon_state = "relay"
	// The host core for this relay
	var/obj/machinery/tcomms/core/linked_core
	// ID of the hub to auto link to
	var/autolink_id
	// Is this linked to anything at all
	var/linked = FALSE
	// Is this link invisible on the hub?
	var/hidden_link = FALSE

/obj/machinery/tcomms/relay/Initialize(mapload)
	. = ..()
	if(mapload && autolink_id)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/tcomms/relay/Destroy()
	Reset()
	. = ..()

/obj/machinery/tcomms/relay/LateInitialize()
	. = ..()
	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		if(C.network_id == autolink_id)
			AddLink(C)
			// Only ONE of these with one ID should exist per world
			break

/obj/machinery/tcomms/relay/proc/AddLink(obj/machinery/tcomms/core/target)
	linked_core = target
	target.linked_relays |= src
	target.refresh_zlevels()
	linked = TRUE

/obj/machinery/tcomms/relay/proc/Reset()
	linked_core.linked_relays -= src
	linked_core.refresh_zlevels()
	linked_core = null
	linked = FALSE
