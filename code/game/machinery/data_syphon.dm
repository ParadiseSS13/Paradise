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
	/// The interval (in seconds) between siphon rate increases
	var/siphon_rate_increase_interval = 60
	/// The amount by which the siphon rate increases at each interval
	var/siphon_rate_increase = 1

/obj/machinery/data_syphon/Destroy()
	SSshuttle.supply.active_syphon = null
	deactivate_syphon()
	return ..()

/obj/machinery/data_syphon/interact(mob/user)
	if(active)
		drop_loot(user)
		return

	if(alert(user, "!!Placeholder!!", "Data Syphon", "Yes", "Cancel") != "Yes")
		return
	if(active || !user.default_can_use_topic(src))
		return

	activate_syphon(user)
	update_appearance()
	send_notification()

/obj/machinery/data_syphon/proc/activate_syphon(mob/user)
	to_chat(user, "<span class='notice'>You enable [src].</span>")
	active = TRUE
	SSshuttle.supply.active_syphon = src
	START_PROCESSING(SSmachines, src)

	// Find the research server and set data_syphon_active to TRUE
	var/obj/machinery/r_n_d/server/server = find_research_server()
	if(server)
		server.data_syphon_active = TRUE
		addtimer(CALLBACK(src, PROC_REF(sap_tech_levels), server), 3 MINUTES, TIMER_LOOP)

	// Set the pirated flag on all accounts
	var/list/combined_accounts = GLOB.station_money_database.user_accounts + GLOB.station_money_database.department_accounts
	for(var/datum/money_account/account in combined_accounts)
		account.pirated = TRUE

/obj/machinery/data_syphon/proc/deactivate_syphon()
	var/list/combined_accounts = GLOB.station_money_database.user_accounts + GLOB.station_money_database.department_accounts
	for(var/datum/money_account/account in combined_accounts)
		account.pirated = FALSE

/obj/machinery/data_syphon/proc/find_research_server()
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		if(!istype(S, /obj/machinery/r_n_d/server/centcom) && S.z == z)
			return S

/obj/machinery/data_syphon/process()
	if(!active || !is_station_level(z))
		STOP_PROCESSING(SSmachines, src)
		return

	steal_credits_from_accounts()
	interrupt_research()

/obj/machinery/data_syphon/proc/steal_credits_from_accounts()
	var/total_credits_to_siphon = 0

	// Combine user accounts and department accounts into a single list
	var/list/combined_accounts = GLOB.station_money_database.user_accounts + GLOB.station_money_database.department_accounts

	// Steal from both crew and department accounts
	for(var/datum/money_account/account in combined_accounts)
		var/siphoned_from_account = min(account.credit_balance, siphon_per_tick)
		account.try_withdraw_credits(siphoned_from_account)
		total_credits_to_siphon += siphoned_from_account

	// Add stolen credits to data syphon
	credits_stored += total_credits_to_siphon

	// Increase the siphon rate over time
	if(world.time % (siphon_rate_increase_interval * 10) == 0)
		siphon_per_tick += siphon_rate_increase

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

/// Reduces all tech levels in the RnD server by 1.
/obj/machinery/data_syphon/proc/sap_tech_levels()
	var/obj/machinery/r_n_d/server/server = find_research_server()
	for(var/datum/tech/T in server.files.known_tech)
		if(T.level > 1)
			T.level -= 1
		else if(server && !QDELETED(server))
			explosion(get_turf(server), 0,1,1,0)
			if(server) //to check if the explosion killed it before we try to delete it
				qdel(server)

/obj/machinery/data_syphon/proc/send_notification()
	// TODO: Make sure this is working and update it.
	GLOB.minor_announcement.Announce("Data theft detected.")
