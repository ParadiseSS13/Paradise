/obj/machinery/power/ptc
    name = "power transfer crystal"
    desc = "A device capable of sending massive amounts of power across huge tracts of space."
    icon = 'icons/obj/machines/ptc.dmi'
    icon_state = "idle"
    bound_height = 64
    bound_width = 32
    density = 1
    anchored = 1
    emagged = 0
    idle_power_usage = 0
    active_power_usage = 0
    use_power = NO_POWER_USE // Power will be from the cable not the grid
    var/power_level = 0 // How strong has it been set
    var/grid_power_usage = 0 // Pulls power from grid, fuck APCs
    var/obj/item/radio/Radio // Radio for sending out alerts
    var/points_to_give = 0 // Cargo points to award
    var/last_award = 0 // When points where last awarded
    var/award_delay = 600 // Delay in which points are added (1 minute, deciseconds)

// TODO
// Overlays
// Make the PR

/*
1KW = 1 Point Per Minute
10KW = 5 Points Per Minute
100KW = 10 Points Per Minute
1MW = 15 Points Per Minute
10MW = 25 Point Per Minute
*/

// INTERACTION
/obj/machinery/power/ptc/emag_act(mob/user)
    if(!emagged)
        emagged = 1
        to_chat(user, "<span class='warning'>You overload the safety, allowing the crystal to draw ludicrous amounts of power!")
        message_admins("[user.ckey] has emagged a power transfer crystal, possible grid draining incoming")
    else
        to_chat(user, "<span class='warning'>The safety is already overloaded!")

/obj/machinery/power/ptc/attack_hand(mob/user)
    add_fingerprint(user)
    ui_interact(user)
    powernet = find_powernet() // Update powernet

/obj/machinery/power/ptc/attack_ai(mob/user)
    attack_hand(user)
    ui_interact(user)

/obj/machinery/power/ptc/Initialize()
    powernet = find_powernet()
    Radio = new /obj/item/radio(src)
    Radio.listening = 0
    Radio.config(list("Engineering" = 0))
    Radio.follow_target = src
    ..()

// UI CRAP
/obj/machinery/power/ptc/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
    ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
    if(!ui)
        ui = new(user, src, ui_key, "ptc.tmpl", "Power Transfer Crystal", 500, 400)
        ui.open()
        ui.set_auto_update(1)

/obj/machinery/power/ptc/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
    var/list/data = list()
    data["powerlevel"] = power_level
    data["emagged"] = emagged
    data["supplypoints"] = SSshuttle.points
    return data

/obj/machinery/power/ptc/Topic(href, href_list)
    switch(href_list["power"]) // This hurts me to write but I dont know any other way to do this
        if("0")
            power_level = 0
            grid_power_usage = 0
            points_to_give = 0
        if("1")
            power_level = 1
            grid_power_usage = 1000
            points_to_give = 1
        if("2")
            power_level = 2
            grid_power_usage = 10000
            points_to_give = 5
        if("3")
            power_level = 3
            grid_power_usage = 100000
            points_to_give = 10
        if("4")
            power_level = 4
            grid_power_usage = 1000000
            points_to_give = 15
        if("5")
            if(emagged)
                power_level = 5
                grid_power_usage = 10000000
                points_to_give = 25
            else
                message_admins("[usr.ckey] attempted to force a power transfer crystal to emagged mode")

// OPERATION
/obj/machinery/power/ptc/process()
    update_icon()
    if(power_level == 0) // If its off, do not process
        return
    if(!powernet)
        if(power_level > 0)
            power_level = 0 // If there aint a powernet, dont switch on
            Radio.autosay("Crystal has shutdown due to grid disconnection.", name, "Engineering", list(z))
            return
    if(power_level > 0 && (active_power_usage > surplus())) // Shut down if theres a lack of power
        if(!emagged) // Only if it aint emagged
            power_level = 0
            Radio.autosay("Crystal has shutdown due to lack of available power.", name, "Engineering", list(z))
            return
    else // Draw the power
        draw_power(grid_power_usage)
        if((last_award + award_delay) <= world.time) // 1 minute has passed
            add_cargo_points()
    if(power_level == 5) // Designed to become a powersink if emagged and set properly
        for(var/obj/machinery/power/terminal/T in powernet.nodes)
            if(istype(T.master, /obj/machinery/power/apc))
                var/obj/machinery/power/apc/A = T.master
                if(A.operating && A.cell)
                    A.cell.charge = max(0, A.cell.charge - 50) // APC drain rate
                    if(A.charging == 2) // If the cell was full
                        A.charging = 1 // It's no longer full

/obj/machinery/power/ptc/update_icon()
    if(power_level == 0)
        icon_state = "idle"
        overlays = list()
    else
        icon_state = "transmitting"
        overlays += image('icons/obj/machines/ptc.dmi', "o_[power_level]")

/obj/machinery/power/ptc/proc/find_powernet()
    var/obj/structure/cable/attached = null
    var/turf/T = loc
    if(isturf(T))
        attached = locate() in T
    if(attached)
        return attached.get_powernet()

/obj/machinery/power/ptc/proc/add_cargo_points()
    last_award = world.time
    switch(power_level)
        if(0)
            points_to_give = 0
        if(1)
            points_to_give = 1
        if(2)
            points_to_give = 5
        if(3)
            points_to_give = 10
        if(4)
            points_to_give = 15
        if(5)
            points_to_give = 25
    SSshuttle.points += points_to_give