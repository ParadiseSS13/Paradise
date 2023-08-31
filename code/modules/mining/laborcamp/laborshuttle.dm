/obj/machinery/computer/shuttle/labor
	name = "labor shuttle console"
	desc = "Used to call and send the labor camp shuttle."
	circuit = /obj/item/circuitboard/labor_shuttle
	shuttleId = "laborcamp"
	possible_destinations = "laborcamp_home;laborcamp_away"
	req_access = list(ACCESS_BRIG)

/obj/machinery/computer/shuttle/labor/one_way
	name = "prisoner shuttle console"
	desc = "A one-way shuttle console, used to summon the shuttle to the labor camp."
	possible_destinations = "laborcamp_away"
	circuit = /obj/item/circuitboard/labor_shuttle/one_way

/obj/machinery/computer/shuttle/labor/one_way/allowed(mob/M)
	if(..())
		return TRUE

	for(var/obj/item/card/id/prisoner/prisoner_id in M)
		if(!prisoner_id.goal)
			continue //no goal? no shuttle

		if(prisoner_id.mining_points >= prisoner_id.goal)
			return TRUE //completed goal? call it

	return FALSE //if we didn't match above, no shuttle call

/**********************Prisoners' Console**************************/

/obj/machinery/mineral/labor_prisoner_shuttle_console
	name = "prisoner shuttle controller"
	desc = "A console used by released prisoners to move the shuttle."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = FALSE
	var/inserted_id_uid
	var/obj/item/radio/intercom/announcer

/obj/machinery/mineral/labor_prisoner_shuttle_console/Initialize()
	. = ..()
	announcer = new /obj/item/radio/intercom(null)
	announcer.follow_target = src
	announcer.config(list("Security" = 0))

/obj/machinery/mineral/labor_prisoner_shuttle_console/Destroy()
	QDEL_NULL(announcer)
	return ..()

/obj/machinery/mineral/labor_prisoner_shuttle_console/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id/prisoner))
		if(inserted_id_uid)
			to_chat(user, "<span class='notice'>There's an ID inserted already.</span>")
			return

		if(!user.unEquip(I))
			return

		I.forceMove(src)
		inserted_id_uid = I.UID()
		to_chat(user, "<span class='notice'>You insert [I].</span>")
		SStgui.update_uis(src)
		return

	return ..()

/obj/machinery/mineral/labor_prisoner_shuttle_console/attack_hand(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/mineral/labor_prisoner_shuttle_console/attack_ghost(mob/user)
	attack_hand(user)

/obj/machinery/mineral/labor_prisoner_shuttle_console/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PrisonerShuttleConsole", name, 315, 150, master_ui, state)
		ui.open()

/obj/machinery/mineral/labor_prisoner_shuttle_console/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/card/id/prisoner/inserted_id = locateUID(inserted_id_uid)

	data["emagged"] = emagged
	data["id_inserted"] = !isnull(inserted_id)
	if(inserted_id)
		data["id_name"] = inserted_id.registered_name
		data["id_points"] = inserted_id.mining_points
		data["id_goal"] = inserted_id.goal

	data["can_go_home"] = check_auth()

	return data

/obj/machinery/mineral/labor_prisoner_shuttle_console/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	var/obj/item/card/id/prisoner/inserted_id = locateUID(inserted_id_uid)
	switch(action)
		if("handle_id")
			if(inserted_id)
				if(!ui.user.put_in_hands(inserted_id))
					inserted_id.forceMove(get_turf(src))
				inserted_id_uid = null
				return TRUE

			var/obj/item/I = ui.user.get_active_hand()
			if(istype(I, /obj/item/card/id/prisoner))
				if(!ui.user.unEquip(I))
					return
				I.forceMove(src)
				inserted_id_uid = I.UID()

		if("move_shuttle")
			if(!alone_in_area(get_area(src), ui.user))
				to_chat(ui.user, "<span class='warning'>Prisoners are only allowed to be released while alone.</span>")
				return TRUE

			switch(SSshuttle.moveShuttle("laborcamp", "laborcamp_home", TRUE, ui.user))
				if(1)
					to_chat(ui.user, "<span class='notice'>Shuttle not found.</span>")
				if(2)
					to_chat(ui.user, "<span class='notice'>Shuttle already at station.</span>")
				if(3)
					to_chat(ui.user, "<span class='notice'>No permission to dock could be granted.</span>")
				else
					if(!emagged)
						var/message = "[inserted_id.registered_name] has returned to the station. Minerals and Prisoner ID card ready for retrieval."
						announcer.autosay(message, "Labor Camp Controller", "Security")
						sec_record_release(ui.user)
					to_chat(ui.user, "<span class='notice'>Shuttle received message and will be sent shortly.</span>")
					ui.user.create_log(MISC_LOG, "used [src] to call the laborcamp shuttle")

	return TRUE

/obj/machinery/mineral/labor_prisoner_shuttle_console/proc/sec_record_release(mob/living/carbon/human/target)
	var/target_name = target?.get_visible_name(TRUE)
	if(!target_name || target_name == "Unknown")
		return //Do you have the slightest idea how little that narrows it down?
	var/datum/data/record/R = find_record("name", target_name, GLOB.data_core.security)
	if(!(R?.fields["criminal"] in list(SEC_RECORD_STATUS_INCARCERATED)))
		return //stops cheese
	set_criminal_status(target, R, SEC_RECORD_STATUS_RELEASED, "Automatically released upon reaching labor points quota", "Labor Camp Controller", user_name = "Automated System")

/obj/machinery/mineral/labor_prisoner_shuttle_console/proc/check_auth()
	if(emagged)
		return TRUE //Shuttle is emagged, let any ol' person through
	var/obj/item/card/id/prisoner/inserted_id = locateUID(inserted_id_uid)
	if(!inserted_id?.goal)
		return FALSE //ID not properly set up or not present, abort!
	return (inserted_id.mining_points >= inserted_id.goal) //Otherwise, only let them out if the prisoner's reached his quota.

/obj/machinery/mineral/labor_prisoner_shuttle_console/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "<span class='warning'>PZZTTPFFFT</span>")

/**********************Point Lookup Console**************************/
/obj/machinery/mineral/labor_points_checker
	name = "points checking console"
	desc = "A console used by prisoners to check the progress on their quotas. Simply swipe a prisoner ID."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = FALSE

/obj/machinery/mineral/labor_points_checker/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.examinate(src)

/obj/machinery/mineral/labor_points_checker/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id/prisoner))
		var/obj/item/card/id/prisoner/prisoner_id = I
		if(!prisoner_id.goal)
			to_chat(user, "<span class='warning'>Error: No point quota assigned by security, exiting.</span>")
			return
		to_chat(user, "<span class='notice'><b>ID: [prisoner_id.registered_name]</b></span>")
		to_chat(user, "<span class='notice'>Points Collected:[prisoner_id.mining_points]</span>")
		to_chat(user, "<span class='notice'>Point Quota: [prisoner_id.goal]</span>")
		to_chat(user, "<span class='notice'>Collect points by bringing ore to the labor camp ore redemption machine. Reach your quota to earn your release.</span>")
		return
	if(istype(I, /obj/item/card/id))
		to_chat(user, "<span class='warning'>Error: Invalid ID</span>")
		return
	return ..()
