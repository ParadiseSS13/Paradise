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

//////////////
// UI STUFF //
//////////////

/obj/machinery/tcomms/relay/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "tcomms_relay.tmpl", "Telecommunications Relay", 600, 400)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/tcomms/relay/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
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
		for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
			data["entries"] += list(list("addr" = "\ref[C]", "net_id" = C.network_id, "sector" = C.loc.z))

	return data

/obj/machinery/tcomms/relay/Topic(href, href_list)
	// Check against href exploits
	if(..())
		return

	// All the toggle on/offs go here
	if(href_list["toggle_active"])
		active = !active
		update_icon()
		if(linked_core)
			linked_core.refresh_zlevels()

	// Set network ID
	if(href_list["network_id"])
		var/new_id = input(usr, "Please enter a new network ID", "Network ID", network_id)
		log_action(usr, "renamed core with ID [network_id] to [new_id]")
		to_chat(usr, "<span class='notice'>Device ID changed from <b>[network_id]</b> to <b>[new_id]</b>.</span>")
		network_id = new_id

	if(linked)
		// Only do these hrefs if we are linked to prevent bugs/exploits
		if(href_list["toggle_hidden_link"])
			hidden_link = !hidden_link
			log_action(usr, "Modified hidden link for [network_id] (Now [hidden_link])")

		if(href_list["unlink"])
			var/choice = alert(usr, "Are you SURE you want to unlink this relay?\nYou wont be able to re-link without the core password", "Unlink","Yes","No")
			if(choice == "Yes")
				log_action(usr, "Unlinked [network_id] from [linked_core.network_id]")
				Reset()
	else
		// You should only be able to link if its not linked, to prevent weirdness
		if(href_list["link"])
			var/obj/machinery/tcomms/core/C = locate(href_list["link"])
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


	// Hack to speed update the nanoUI
	SSnanoui.update_uis(src)
