/obj/machinery/computer/brigcells
    name = "cell management computer"
    desc = "Used to manage prison cells."
    icon_keyboard = "security_key"
    icon_screen = "cell_monitor"
    use_power = IDLE_POWER_USE
    idle_power_usage = 250
    active_power_usage = 500
    circuit = /obj/item/circuitboard/brigcells
    light_color = LIGHT_COLOR_DARKRED
    req_access = list(ACCESS_BRIG)

/obj/machinery/computer/brigcells/attack_ai(mob/user)
    attack_hand(user)
    tgui_interact(user)

/obj/machinery/computer/brigcells/attack_hand(mob/user)
    add_fingerprint(user)
    if(stat & (BROKEN|NOPOWER))
        return
    if(!allowed(user))
        to_chat(user, "<span class='warning'>Access denied.</span>")
        return
    tgui_interact(user)

/obj/machinery/computer/brigcells/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BrigCells", "Brig Cell Management", 1000, 400, master_ui, state)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/brigcells/tgui_data(mob/user)
	var/list/data = list()
	var/list/timers = list()
	for(var/obj/machinery/door_timer/T in GLOB.celltimers_list)
		var/timer = list()
		timer["cell_id"] = T.name
		timer["occupant"] = T.occupant
		timer["crimes"] = T.crimes
		timer["brigged_by"] = T.officer
		timer["time_set_seconds"] = round(T.timetoset / 10, 1)
		timer["time_left_seconds"] = round(T.timeleft(), 1)
		timer["ref"] = "\ref[T]"
		timers[++timers.len] += timer
	timers = sortByKey(timers, "cell_id")
	data["cells"] = timers
	return data

/obj/machinery/computer/brigcells/tgui_act(action, params)
	if (..())
		return FALSE

	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return FALSE

	if (action == "release")
		var/ref = params["ref"]
		var/obj/machinery/door_timer/T = locate(ref)
		if (T)
			T.timer_end()
			T.Radio.autosay("Timer stopped manually from a cell management console.", T.name, "Security", list(z))
		return TRUE

	return FALSE
