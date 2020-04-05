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
    ui_interact(user)

/obj/machinery/computer/brigcells/attack_hand(mob/user)
    add_fingerprint(user)
    if(stat & (BROKEN|NOPOWER))
        return
    if(!allowed(user))
        to_chat(user, "<span class='warning'>Access denied.</span>")
        return
    ui_interact(user)

/obj/machinery/computer/brigcells/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
    ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
    if(!ui)
        ui = new(user, src, ui_key, "brig_cells.tmpl", "Brig Cell Management", 1000, 400)
        ui.open()
        ui.set_auto_update(1)

/obj/machinery/computer/brigcells/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
    var/data[0]
    var/list/timers = list()
    for(var/obj/machinery/door_timer/T in GLOB.celltimers_list)
        var/timer = list()
        timer["cell_id"] = T.name
        timer["occupant"] = T.occupant
        timer["crimes"] = T.crimes
        timer["brigged_by"] = T.officer
        if(T.time == 0)
            timer["background"] = "'background-color:#007f47'"
        else
            timer["background"] = "'background-color:#890E26'"
        timer["time_set"] = seconds_to_clock(T.time / 10)
        timer["time_left"] = seconds_to_clock(T.timeleft())
        timer["ref"] = "\ref[T]"
        timers[++timers.len] += timer
    timers = sortByKey(timers, "cell_id")
    data["cells"] = timers
    return data

/obj/machinery/computer/brigcells/Topic(href, href_list)
    if(href_list["release"])
        var/obj/machinery/door_timer/T = locate(href_list["release"])
        T.timer_end()
        T.Radio.autosay("Timer stopped manually from a cell management console.", T.name, "Security", list(z))
