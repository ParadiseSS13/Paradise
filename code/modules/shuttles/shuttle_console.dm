/obj/machinery/computer/shuttle_control
	name = "shuttle control console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	circuit = null

	var/shuttle_tag  // Used to coordinate data in shuttle controller.
	var/hacked = 0   // Has been emagged, no access restrictions.


/obj/machinery/computer/shuttle_control/attack_hand(user as mob)
	if(..(user))
		return
	//src.add_fingerprint(user)	//shouldn't need fingerprints just for looking at it.
	if(!allowed(user))
		user << "\red Access Denied."
		return 1
	
	ui_interact(user)

/obj/machinery/computer/shuttle_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return

	var/shuttle_state
	switch(shuttle.moving_status)
		if(SHUTTLE_IDLE) shuttle_state = "idle"
		if(SHUTTLE_WARMUP) shuttle_state = "warmup"
		if(SHUTTLE_INTRANSIT) shuttle_state = "in_transit"

	var/shuttle_status
	switch (shuttle.process_state)
		if(IDLE_STATE)
			if (shuttle.in_use)
				shuttle_status = "Busy."
			else if (!shuttle.location)
				shuttle_status = "Standing-by at station."
			else
				shuttle_status = "Standing-by at offsite location."
		if(WAIT_LAUNCH)
			shuttle_status = "Shuttle has recieved command and will depart shortly."
		if(WAIT_ARRIVE)
			shuttle_status = "Proceeding to destination."
		if(WAIT_FINISH)
			shuttle_status = "Arriving at destination now."

	data = list(
		"shuttle_status" = shuttle_status,
		"shuttle_state" = shuttle_state,
		"has_docking" = shuttle.docking_controller? 1 : 0,
		"docking_status" = shuttle.docking_controller? shuttle.docking_controller.get_docking_status() : null,
		"docking_override" = shuttle.docking_controller? shuttle.docking_controller.override_enabled : null,
		"can_launch" = shuttle.can_launch(),
		"can_cancel" = shuttle.can_cancel(),
		"can_force" = shuttle.can_force(),
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "shuttle_control_console.tmpl", "[shuttle_tag] Shuttle Control", 470, 310)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/shuttle_control/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	src.add_fingerprint(usr)

	if(href_list["move"])
		launch()
	if(href_list["force"])
		force_launch()
	else if(href_list["cancel"])
		cancel_launch()

/obj/machinery/computer/shuttle_control/proc/launch()
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return
	shuttle.launch(src)
	
/obj/machinery/computer/shuttle_control/proc/force_launch()
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return
	shuttle.force_launch(src)

/obj/machinery/computer/shuttle_control/proc/cancel_launch()
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return
	shuttle.cancel_launch(src)

/obj/machinery/computer/shuttle_control/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/card/emag))
		src.req_access = list()
		src.req_one_access = list()
		hacked = 1
		usr << "You short out the console's ID checking system. It's now available to everyone!"
	else
		..()

/obj/machinery/computer/shuttle_control/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")
