/obj/machinery/r_n_d/server
	name = "R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	/// Current health (heat deteriorates it)
	var/heat_health = 100
	/// Is the server working?
	var/working = TRUE
	/// Base point income
	var/base_income = 2
	/// Heat generation
	var/heat_gen = 100
	/// Heat power
	var/heating_power = 40000
	/// Lowest temperature tolerance (Absolute zero)
	var/temp_tolerance_low = 0
	/// Highest temperature tolerance (Room temperature)
	var/temp_tolerance_high = T20C
	/// Temperature penalty | 1 = -1 points per degree above high tolerance. 0.5 = -0.5 points per degree above high tolerance
	var/temp_penalty_coefficient = 0.5
	/// Do we play ambient noise?
	var/plays_sound = TRUE

/obj/machinery/r_n_d/server/New()
	. = ..()
	SSresearch.servers |= src
	desc += "Its ID screen reads: [UID()]" // fluff
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)

/obj/machinery/r_n_d/server/Destroy()
	SSresearch.servers -= src
	return ..()

/obj/machinery/r_n_d/server/proc/refresh_working()
	if(stat & EMPED)
		working = FALSE
	else
		working = TRUE

/obj/machinery/r_n_d/server/emp_act()
	stat |= EMPED
	addtimer(CALLBACK(src, .proc/unemp), 600)
	refresh_working()
	return ..()

/obj/machinery/r_n_d/server/proc/unemp()
	stat &= ~EMPED
	refresh_working()

/obj/machinery/r_n_d/server/proc/mine()
	. = base_income
	var/penalty = max((get_env_temp() - temp_tolerance_low), 0) / temp_penalty_coefficient
	. = max(. - penalty, 0)

/obj/machinery/r_n_d/server/proc/get_env_temp()
	var/datum/gas_mixture/environment = loc.return_air()
	return environment.temperature

/obj/machinery/computer/rdservercontrol
	name = "\improper R&D server controller"
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_FADEDPURPLE
	circuit = /obj/item/circuitboard/rdservercontrol
	/// List of all R&D servers the controller can manage
	var/list/obj/machinery/r_n_d/server/servers = list()
	/// Currently selected server
	var/obj/machinery/r_n_d/server/selected_server
	/// List of all R&D consoles the controller can manage
	var/list/obj/machinery/computer/rdconsole/consoles = list()


/obj/machinery/computer/rdservercontrol/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/computer/rdservercontrol/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RndServerController", name, 600, 300, master_ui, state)
		ui.open()

/obj/machinery/computer/rdservercontrol/tgui_data(mob/user)
	var/list/data = list()

	if(QDELETED(selected_server))
		selected_server = null

	data["active_server_data"] = null

	if(selected_server)
		var/list/active_server_data = list(
			"ref" = "[selected_server.UID()]",
			"working" = selected_server.working,
			"location" = get_area_name(selected_server.loc),
			"health" = selected_server.heat_health
		)

		data["active_server_data"] = active_server_data

	var/list/_servers = list()
	for(var/obj/machinery/r_n_d/server/S in servers)
		_servers += list(list(
			"location" = get_area_name(S.loc),
			"working" = S.working,
			"ref" = S.UID()
		))
	data["servers"] = _servers

	var/list/_consoles = list()
	for(var/obj/machinery/computer/rdconsole/C in consoles)
		_consoles += list(list(
			"name" = C.name,
			"location" = get_area_name(C.loc),
			"writeaccess" = C.id,
			"ref" = C.UID()
		))
	data["consoles"] = _consoles

	return data

/obj/machinery/computer/rdservercontrol/tgui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("refresh")
			servers.Cut()
			for(var/obj/machinery/r_n_d/server/S in SSresearch.servers)
				servers |= S

			consoles.Cut()
			for(var/obj/machinery/computer/rdconsole/C in SSresearch.science_tech.consoles_accessing)
				consoles |= C

		if("back")
			selected_server = null

		if("select_server")
			selected_server = locateUID(params["suid"])

		if("toggle_server_active")
			if(selected_server)
				selected_server.working = !selected_server.working

		if("toggle_console_access")
			var/obj/machinery/computer/rdconsole/C = locateUID(params["cuid"])
			if(istype(C))
				C.id = !C.id
