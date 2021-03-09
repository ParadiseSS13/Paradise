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
	// This starts as off so you cant make cores as hot spares
	active = FALSE
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
	component_parts += new /obj/item/circuitboard/tcomms/relay(null)
	if(check_power_on())
		active = TRUE
	else
		visible_message("<span class='warning'>Error: Another relay is already active in this sector. Power-up cancelled due to radio interference.</span>")
	update_icon()
	if(mapload && autolink_id)
		return INITIALIZE_HINT_LATELOAD

/**
  * Descrutor for the relay.
  *
  * Ensures that the machine is taken out of the global list when destroyed, and also removes the link to the core.
  */
/obj/machinery/tcomms/relay/Destroy()
	Reset()
	return ..()

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
  * Z-Level transit change helper
  *
  * Handles parent call of disabling the machine if it changes Z-level, but also rebuilds the list of reachable levels on the linked core
  */
/obj/machinery/tcomms/relay/onTransitZ(old_z, new_z)
	. = ..()
	if(linked_core)
		linked_core.refresh_zlevels()


/**
  * Power-on checker
  *
  * Checks the z-level to see if an existing relay is already powered on, and deny this one turning on if there is one. Returns TRUE if it can power on, or FALSE if it cannot
  */
/obj/machinery/tcomms/relay/proc/check_power_on()
	// Cancel if we are already on
	if(active)
		return TRUE

	for(var/obj/machinery/tcomms/relay/R in GLOB.tcomms_machines)
		// Make sure we dont check ourselves
		if(R == src)
			continue
		// We dont care about ones on other zlevels
		if(!atoms_share_level(R, src))
			continue
		// If another relay is active, return FALSE
		if(R.active)
			if(R.stat & NOPOWER)	// If another relay has no power but is supposed to be on, we shut it down so we can continue.
				R.active = FALSE	// Since only one active relay is allowed per z level, give priority to the one that's actually working.
				R.update_icon()
			else
				return FALSE
	// If we got here there isnt an active relay on this Z-level. So return TRUE
	return TRUE

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
	if(linked_core)
		linked_core.linked_relays -= src
		linked_core.refresh_zlevels()
		linked_core = null
		linked = FALSE

/**
  * Power Change Handler
  *
  * Proc which ensures the host core has its zlevels updated (icons are updated by parent call)
  */
/obj/machinery/tcomms/relay/power_change()
	..()
	if(linked_core)
		linked_core.refresh_zlevels()

//////////////
// UI STUFF //
//////////////

/obj/machinery/tcomms/relay/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "TcommsRelay", name, 600, 400, master_ui, state)
		ui.open()

/obj/machinery/tcomms/relay/ui_data(mob/user)
	var/list/data = list()
	// Are we on or not
	data["active"] = active
	// What is our network ID
	data["network_id"] = network_id
	// Are we linked
	data["linked"] = linked
	// Is the link hidden
	data["hidden_link"] = hidden_link

	// Only send linked tab stuff if we are linked. This saves on sending overhead.
	if(linked)
		data["linked_core_id"] = linked_core.network_id
		data["linked_core_addr"] = "\ref[linked_core]"
	else
		var/list/cores = list()
		for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
			cores += list(list("addr" = "\ref[C]", "net_id" = C.network_id, "sector" = C.loc.z))
		data["cores"] = cores

	return data

/obj/machinery/tcomms/relay/ui_act(action, list/params)
	// Check against href exploits
	if(..())
		return

	. = TRUE

	switch(action)
		if("toggle_active")
			if(check_power_on())
				active = !active
				update_icon()
				if(linked_core)
					linked_core.refresh_zlevels()
			else
				to_chat(usr, "<span class='warning'>Error: Another relay is already active in this sector. Power-up cancelled due to radio interference.</span>")

		// Set network ID
		if("network_id")
			var/new_id = input(usr, "Please enter a new network ID", "Network ID", network_id)
			log_action(usr, "renamed core with ID [network_id] to [new_id]")
			to_chat(usr, "<span class='notice'>Device ID changed from <b>[network_id]</b> to <b>[new_id]</b>.</span>")
			network_id = new_id

		// Only do these hrefs if we are linked to prevent bugs/exploits
		if("toggle_hidden_link")
			if(!linked)
				return
			hidden_link = !hidden_link
			log_action(usr, "Modified hidden link for [network_id] (Now [hidden_link])")

		if("unlink")
			if(!linked)
				return
			var/choice = alert(usr, "Are you SURE you want to unlink this relay?\nYou wont be able to re-link without the core password", "Unlink","Yes","No")
			if(choice == "Yes")
				log_action(usr, "Unlinked [network_id] from [linked_core.network_id]")
				Reset()

		// You should only be able to link if its not linked, to prevent weirdness
		if("link")
			if(linked)
				return
			var/obj/machinery/tcomms/core/C = locate(params["addr"])
			if(istype(C, /obj/machinery/tcomms/core))
				var/user_pass = input(usr, "Please enter core password","Password Entry")
				// Check the password
				if(user_pass == C.link_password)
					AddLink(C)
					to_chat(usr, "<span class='notice'>Successfully linked to <b>[C.network_id]</b>.</span>")
				else
					to_chat(usr, "<span class='alert'><b>ERROR:</b> Password incorrect.</span>")
			else
				to_chat(usr, "<span class='alert'><b>ERROR:</b> Core not found. Please file an issue report.</span>")


