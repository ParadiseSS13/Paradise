#define UI_TAB_CONFIG "CONFIG"
#define UI_TAB_LINKS "LINKS"
#define UI_TAB_FILTER "FILTER"

/**
  * # Telecommunications Core
  *
  * The core of the entire telecomms operation
  *
  * This thing basically handles the main broadcasting of the data, as well as NTTC configs
  * The relays dont do any actual processing, they are just objects which can bring tcomms to another zlevel
  */
/obj/machinery/tcomms/core
	name = "Telecommunications Core"
	desc = "A large rack full of communications equipment. Looks important."
	icon_state = "core"
	// This starts as off so you cant make cores as hot spares
	active = FALSE
	/// The NTTC config for this device
	var/datum/nttc_configuration/nttc = new()
	/// List of all reachable devices
	var/list/reachable_zlevels = list()
	/// List of all linked relays
	var/list/linked_relays = list()
	/// Password for linking stuff together
	var/link_password
	/// What tab of the UI were currently on
	var/ui_tab = UI_TAB_CONFIG

/**
  * Initializer for the core.
  *
  * Calls parent to ensure its added to the GLOB of tcomms machines, before generating a link password and adding itself to the list of reachable Zs.
  */
/obj/machinery/tcomms/core/Initialize(mapload)
	. = ..()
	link_password = GenerateKey()
	reachable_zlevels |= loc.z
	component_parts += new /obj/item/circuitboard/tcomms/core(null)
	if(check_power_on())
		active = TRUE
	else
		visible_message("<span class='warning'>Error: Another core is already active in this sector. Power-up cancelled due to radio interference.</span>")
	update_icon()

	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_Z, PROC_REF(on_new_z))

	if(mapload) //Automatically links new midround tcomms cores to the cc relay
		return
	var/obj/machinery/tcomms/relay/cc/cc_relay = locateUID(GLOB.cc_tcomms_relay_uid)
	if(cc_relay?.linked_core) //if we are already linked, ignore!
		return
	cc_relay.AddLink(src)

/**
  * Destructor for the core.
  *
  * Ensures that the machine is taken out of the global list when destroyed, and also unlinks all connected relays
  */
/obj/machinery/tcomms/core/Destroy()
	for(var/obj/machinery/tcomms/relay/R in linked_relays)
		R.Reset()
	QDEL_NULL(nttc) // Delete the NTTC datum
	linked_relays.Cut() // Just to be sure
	return ..()

/**
  * Helper to see if a zlevel is reachable
  *
  * This is a simple check to see if the input z-level is in the list of reachable ones
  * Returns TRUE if it can, FALSE if it cant
  *
  * Arguments:
  * * zlevel - The input z level to test
  */
/obj/machinery/tcomms/core/proc/zlevel_reachable(zlevel)
	// Nothing is reachable if the core is offline, unpowered, or ion'd
	if(!active || (stat & NOPOWER) || ion)
		return FALSE
	if(zlevel in reachable_zlevels)
		return TRUE
	else
		return FALSE

/**
  * Proc which takes in the message datum
  *
  * Some checks are ran on the signal, and NTTC is applied
  * After that, it is broadcasted out to the required Z-levels
  *
  * Arguments:
  * * tcm - The tcomms message datum
  */
/obj/machinery/tcomms/core/proc/handle_message(datum/tcomms_message/tcm)
	// Don't do anything with rejected signals, if were offline, if we are ion'd, or if we have no power
	if(tcm.reject || !active || (stat & NOPOWER) || ion)
		return FALSE
	// Kill the signal if its on a z-level that isnt reachable
	if(!zlevel_reachable(tcm.source_level))
		return FALSE

	// Now we can run NTTC
	tcm = nttc.modify_message(tcm)

	// If the signal shouldnt be broadcast, dont broadcast it
	if(!tcm.pass)
		// We still return TRUE here because the signal was handled, even though we didnt broadcast
		return TRUE

	// Now we generate the list of where that signal should go to
	tcm.zlevels = reachable_zlevels.Copy()
	tcm.zlevels |= tcm.source_level

	// Now check if they actually have pieces, if so, broadcast
	if(tcm.message_pieces)
		broadcast_message(tcm)
		return TRUE

	return FALSE

/**
  * Proc to remake the list of available zlevels
  *
  * Loops through the list of connected relays and adds their zlevels in.
  * This is called if a relay is added or removed
  *
  */
/obj/machinery/tcomms/core/proc/refresh_zlevels()
	// Refresh the list
	reachable_zlevels = list()
	// Add itself as a reachable Z-level
	reachable_zlevels |= loc.z
	// Add all the linked relays in
	for(var/obj/machinery/tcomms/relay/R in linked_relays)
		// Only if the relay is active
		if(R.active && !(R.stat & NOPOWER))
			reachable_zlevels |= R.loc.z
	for(var/zlevel in GLOB.space_manager.z_list)
		if(check_level_trait(zlevel, TCOMM_RELAY_ALWAYS))
			reachable_zlevels |= zlevel


/**
  * Z-Level transit change helper
  *
  * Handles parent call of disabling the machine if it changes Z-level, but also rebuilds the list of reachable levels
  */
/obj/machinery/tcomms/core/on_changed_z_level(turf/old_turf, turf/new_turf)
	. = ..()
	refresh_zlevels()

/**
  * Power-on checker
  *
  * Checks the z-level to see if an existing core is already powered on, and deny this one turning on if there is one. Returns TRUE if it can power on, or FALSE if it cannot
  */
/obj/machinery/tcomms/core/proc/check_power_on()
	// Cancel if we are already on
	if(active)
		return TRUE

	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		// Make sure we dont check ourselves
		if(C == src)
			continue
		// We dont care about ones on other zlevels
		if(!atoms_share_level(C, src))
			continue
		// If another core is active, return FALSE
		if(C.active)
			if(C.stat & NOPOWER)	// If another core has no power but is supposed to be on, we shut it down so we can continue.
				C.active = FALSE	// Since only one active core is allowed per z level, give priority to the one actually working.
				C.update_icon()
			else
				return FALSE
	// If we got here there isnt an active core on this Z-level. So return true
	return TRUE

//////////////
// UI STUFF //
//////////////

/obj/machinery/tcomms/core/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/tcomms/core/ui_interact(mob/user, datum/tgui/ui = null)
	// This needs to happen here because of how late the language datum initializes. I dont like it
	if(length(nttc.valid_languages) == 1)
		nttc.update_languages()

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TcommsCore", name)
		ui.open()

/obj/machinery/tcomms/core/ui_data(mob/user)
	var/list/data = list()
	data["ion"] = ion

	// Z-level list. Note that this will also show sectors with hidden relay links, but you cant see the relays themselves
	// This allows the crew to realise that sectors have hidden relays
	data["sectors_available"] = "Count: [length(reachable_zlevels)] | List: [jointext(reachable_zlevels, " ")]"
	// Toggles
	data["active"] = active
	data["nttc_toggle_jobs"] = nttc.toggle_jobs
	data["nttc_toggle_job_color"] = nttc.toggle_job_color
	data["nttc_toggle_name_color"] = nttc.toggle_name_color
	data["nttc_toggle_command_bold"] = nttc.toggle_command_bold
	// Strings
	data["nttc_setting_language"] = nttc.setting_language
	data["nttc_job_indicator_type"] = nttc.job_indicator_type
	// Network ID
	data["network_id"] = network_id

	data["link_password"] = link_password

	// You ready to see some awful shit?
	var/list/relays = list()
	for(var/obj/machinery/tcomms/relay/R in linked_relays)
		// Dont show relays with a hidden link
		if(R.hidden_link)
			continue
		// Assume false
		var/status = FALSE
		if(R.active && !(R.stat & NOPOWER))
			status = TRUE

		relays += list(list("addr" = "\ref[R]", "net_id" = R.network_id, "sector" = R.loc.z, "status" = status))

	data["relay_entries"] = relays
	// End the shit

	data["filtered_users"] = nttc.filtering

	return data

/obj/machinery/tcomms/core/ui_act(action, list/params)
	// Check against href exploits
	if(..())
		return

	. = TRUE

	switch(action)
		// All the toggle on/offs go here
		if("toggle_active")
			if(check_power_on())
				active = !active
				update_icon()
			else
				to_chat(usr, "<span class='warning'>Error: Another core is already active in this sector. Power-up cancelled due to radio interference.</span>")

		// NTTC Toggles
		if("nttc_toggle_jobs")
			nttc.toggle_jobs = !nttc.toggle_jobs
			log_action(usr, "toggled job tags (Now [nttc.toggle_jobs])")
		if("nttc_toggle_job_color")
			nttc.toggle_job_color = !nttc.toggle_job_color
			log_action(usr, "toggled job colors (Now [nttc.toggle_job_color])")
		if("nttc_toggle_name_color")
			nttc.toggle_name_color = !nttc.toggle_name_color
			log_action(usr, "toggled name colors (Now [nttc.toggle_name_color])")
		if("nttc_toggle_command_bold")
			nttc.toggle_command_bold = !nttc.toggle_command_bold
			log_action(usr, "toggled command bold (Now [nttc.toggle_command_bold])")
		// We need to be a little more fancy for the others

		// Job Format
		if("nttc_job_indicator_type")
			var/card_style = tgui_input_list(usr, "Pick a job card format", "Job Card Format", nttc.job_card_styles)
			if(!card_style)
				return
			nttc.job_indicator_type = card_style
			to_chat(usr, "<span class='notice'>Jobs will now have the style of [card_style].</span>")
			log_action(usr, "has set NTTC job card format to [card_style]")

		// Language Settings
		if("nttc_setting_language")
			var/new_language = tgui_input_list(usr, "Pick a language to convert messages to", "Language Conversion", nttc.valid_languages)
			if(!new_language)
				return
			if(new_language == "--DISABLE--")
				nttc.setting_language = null
				to_chat(usr, "<span class='notice'>Language conversion disabled.</span>")
			else
				nttc.setting_language = new_language
				to_chat(usr, "<span class='notice'>Messages will now be converted to [new_language].</span>")

			log_action(usr, new_language == "--DISABLE--" ? "disabled NTTC language conversion" : "set NTTC language conversion to [new_language]", TRUE)

		// Imports and exports
		if("import")
			var/json = tgui_input_text(usr, "Provide configuration JSON below.", "Load Config", nttc.nttc_serialize(), multiline = TRUE, encode = FALSE)
			if(isnull(json))
				return
			if(nttc.nttc_deserialize(json, usr.ckey))
				log_action(usr, "has uploaded a NTTC JSON configuration: [ADMIN_SHOWDETAILS("Show", json)]", TRUE)

		if("export")
			usr << browse(nttc.nttc_serialize(), "window=save_nttc")

		// Set network ID
		if("network_id")
			var/new_id = tgui_input_text(usr, "Please enter a new network ID", "Network ID", network_id)
			if(!new_id)
				return
			log_action(usr, "renamed core with ID [network_id] to [new_id]")
			to_chat(usr, "<span class='notice'>Device ID changed from <b>[network_id]</b> to <b>[new_id]</b>.</span>")
			network_id = new_id

		if("unlink")
			var/obj/machinery/tcomms/relay/R = locate(params["addr"])
			if(istype(R, /obj/machinery/tcomms/relay))
				var/confirm = tgui_alert(usr, "Are you sure you want to unlink this relay?\nID: [R.network_id]\nADDR: \ref[R]", "Relay Unlink", list("Yes", "No"))
				if(confirm == "Yes")
					log_action(usr, "has unlinked tcomms relay with ID [R.network_id] from tcomms core with ID [network_id]", TRUE)
					R.Reset()
			else
				to_chat(usr, "<span class='alert'><b>ERROR:</b> Relay not found. Please file an issue report.</span>")

		if("change_password")
			var/new_password = tgui_input_text(usr, "Please enter a new password", "New Password", link_password)
			if(!new_password)
				return
			log_action(usr, "has changed the password on core with ID [network_id] from [link_password] to [new_password]")
			to_chat(usr, "<span class='notice'>Successfully changed password from <b>[link_password]</b> to <b>[new_password]</b>.</span>")
			link_password = new_password

		if("add_filter")
			// This is a stripped input because I did NOT come this far for this system to be abused by HTML injection
			var/name_to_add = tgui_input_text(usr, "Enter a name to add to the filtering list", "Name Entry", encode = FALSE)
			if(!name_to_add)
				return
			if(name_to_add in nttc.filtering)
				to_chat(usr, "<span class='alert'><b>ERROR:</b> User already in filtering list.</span>")
			else
				nttc.filtering |= name_to_add
				log_action(usr, "has added [name_to_add] to the NTTC filter list on core with ID [network_id]", TRUE)
				to_chat(usr, "<span class='notice'>Successfully added <b>[name_to_add]</b> to the NTTC filtering list.</span>")

		if("remove_filter")
			var/name_to_remove = params["user"]
			if(!(name_to_remove in nttc.filtering))
				to_chat(usr, "<span class='alert'><b>ERROR:</b> Name does not exist in filter list. Please file an issue report.</span>")
			else
				var/confirm = tgui_alert(usr, "Are you sure you want to remove [name_to_remove] from the filtering list?", "Confirm Removal", list("Yes", "No"))
				if(confirm == "Yes")
					nttc.filtering -= name_to_remove
					log_action(usr, "has removed [name_to_remove] from the NTTC filter list on core with ID [network_id]", TRUE)
					to_chat(usr, "<span class='notice'>Successfully removed <b>[name_to_remove]</b> from the NTTC filtering list.</span>")

/obj/machinery/tcomms/core/proc/on_new_z(datum/source, name, linkage, list/traits, transition_tag, level_type, z_level)
	SIGNAL_HANDLER // COMSIG_GLOB_NEW_Z

	if(islist(traits) && (TCOMM_RELAY_ALWAYS in traits))
		reachable_zlevels |= z_level

#undef UI_TAB_CONFIG
#undef UI_TAB_LINKS
#undef UI_TAB_FILTER
