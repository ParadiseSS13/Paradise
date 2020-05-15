/**
  * # Telecommunications Relay
  *
  * Extends the reach of telecomms to the z-level it is built on
  *
  * Relays themselves dont do any processing, they just tell the core that this z-level is available in the tcomms network.
  */
/obj/machinery/tcomms/relay
	name = "Telecommunications Relay"
	desc = "A large device with several radio antennas on it."
	icon_state = "relay"
	/// The host core for this relay
	var/obj/machinery/tcomms/core/linked_core
	/// ID of the hub to auto link to
	var/autolink_id
	/// Is this linked to anything at all
	var/linked = FALSE
	/// Is this link invisible on the hub?
	var/hidden_link = FALSE

/**
  * Initializer for the relay.
  *
  * Calls parent to ensure its added to the GLOB of tcomms machines, before checking if there is an autolink that needs to be added.
  */
/obj/machinery/tcomms/relay/Initialize(mapload)
	. = ..()
	if(mapload && autolink_id)
		return INITIALIZE_HINT_LATELOAD

/**
  * Descrutor for the relay.
  *
  * Ensures that the machine is taken out of the global list when destroyed, and also removes the link to the core.
  */
/obj/machinery/tcomms/relay/Destroy()
	. = ..()
	Reset()

/**
  * Late Initialize for the relay.
  *
  * Calls parent, then adds links to the cores. This is a LateInitialize because the core MUST be initialized first
  */
/obj/machinery/tcomms/relay/LateInitialize()
	. = ..()
	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		if(C.network_id == autolink_id)
			AddLink(C)
			// Only ONE of these with one ID should exist per world
			break

/**
  * Proc to link the relay to the core.
  *
  * Sets the linked core to the target (argument below), before adding it to the list of linked relays, then re-freshing the zlevel list
  * The relay is then marked as linked
  * Arguments:
  * * target - The telecomms core that this relay should be linked to
  */
/obj/machinery/tcomms/relay/proc/AddLink(obj/machinery/tcomms/core/target)
	linked_core = target
	target.linked_relays |= src
	target.refresh_zlevels()
	linked = TRUE

/**
  * Proc to rest the relay.
  *
  * Resets the relay, removing its linkage status, and refreshing the core's list of z-levels
  */
/obj/machinery/tcomms/relay/proc/Reset()
	linked_core.linked_relays -= src
	linked_core.refresh_zlevels()
	linked_core = null
	linked = FALSE

/**
  * Relay Enabler
  *
  * Modification to the standard one so that the links get updated
  */
/obj/machinery/tcomms/relay/enable_machine()
	..()
	if(linked_core)
		linked_core.refresh_zlevels()

/**
  * Relay Disabler
  *
  * Modification to the standard one so that the links get updated
  */
/obj/machinery/tcomms/relay/disable_machine()
	..()
	if(linked_core)
		linked_core.refresh_zlevels()
