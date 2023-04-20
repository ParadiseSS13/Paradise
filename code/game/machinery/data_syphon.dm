/obj/machinery/data_syphon
	name = "data syphon"
	desc = "!!Placeholder!!"
	anchored = TRUE
	density = TRUE

	/// Has the syphon been activated?
	var/active = FALSE
	/// The number of stolen credits currently stored in the machine.
	var/credits_stored = 0
	/// The number of credits which should be syphoned per tick.
	var/siphon_per_tick = 5

/obj/machinery/data_syphon/Destroy()
	SSshuttle.supply.active_syphon = null
	return ..()

/obj/machinery/data_syphon/interact(mob/user)
	if(active)
		drop_loot(user)
		return

	if(alert(user, "!!Placeholder!!", "Data Syphon", "Yes", "Cancel") != "Yes")
		return
	if(active || !user.default_can_use_topic(src))
		return

	enable(user)
	update_appearance()
	send_notification()

/**
  * Activates the data syphon.
  *
  * This prevents the cargo shuttle from moving, and starts the process of 'blockading' the station (See `/obj/machinery/data_syphon/process()`).
  */
/obj/machinery/data_syphon/proc/activate_syphon(mob/user)
	to_chat(user, "<span class='notice'>You enable [src].</span>")
	active = TRUE
	SSshuttle.supply.active_syphon = src
	START_PROCESSING(SSmachines, src)

	// Find the research server and set data_syphon_active to TRUE
	var/datum/research_server/server = find_research_server()
	if(server)
		server.data_syphon_active = TRUE
		addtimer(CALLBACK(src, .proc/sap_tech_levels, server), 3 MINUTES, TIMER_LOOP)

/// Returns the first non-centcom `/obj/machinery/r_n_d/server` on the z level.
/obj/machinery/data_syphon/proc/find_research_server()
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		if(!istype(S, /obj/machinery/r_n_d/server/centcom) && S.z == z)
			return S

/obj/machinery/data_syphon/process()
	if(!active || !is_station_level(z))
		STOP_PROCESSING(SSmachines, src)
		return

	var/datum/money_account/cargo_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SUPPLY)
	var/siphoned = min(cargo_account.credit_balance, siphon_per_tick)
	cargo_account.try_withdraw_credits(siphoned)
	credits_stored += siphoned
	interrupt_research()

/// Drops all stored credits on the floor as a stack of `/obj/item/stack/spacecash`.
/obj/machinery/data_syphon/proc/drop_loot(mob/user)
	if(credits_stored)
		new /obj/item/stack/spacecash(get_turf(src)) // TODO: Make this actually work. (/obj/machinery/economy/proc/dispense_space_cash()?)
		to_chat(user, "<span class='notice'>You retrieve the siphoned credits!</span>")
		credits_stored = 0
	else
		to_chat(user, "<span class='notice'>There's nothing to withdraw.</span>")

/// Calls `emp_act()` on the RnD server to temporarily disable it.
/obj/machinery/data_syphon/proc/interrupt_research()
	var/obj/machinery/r_n_d/server/server = find_research_server()
	if(!(server.stat & (BROKEN | NOPOWER)))
		server.emp_act()
		new /obj/effect/temp_visual/emp(get_turf(server))

		S.emp_act()
		new /obj/effect/temp_visual/emp(get_turf(S))

/// Reduces all tech levels in the RnD server by 1.
/obj/machinery/data_syphon/proc/sap_tech_levels()
	var/obj/machinery/r_n_d/server/server = find_research_server()
	for(var/datum/tech/T in server.files.known_tech)
		if(T.level > 1)
			T.level -= 1
		else(server && !QDELETED(/obj/machinery/r_n_d/server))
			explosion(get_turf(/obj/machinery/r_n_d/server), 0,1,1,0)
			if(server) //to check if the explosion killed it before we try to delete it
				qdel(/obj/machinery/r_n_d/server)

/obj/machinery/data_syphon/proc/send_notification()
	// TODO: Make sure this is working and update it.
	GLOB.minor_announcement.Announce("Data theft detected.")
