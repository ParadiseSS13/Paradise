/**********************Prisoners' Console**************************/

/obj/machinery/mineral/labor_claim_console
	name = "point claim console"
	desc = "A stacking console with an electromagnetic writer, used to track ore mined by prisoners."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = FALSE
	var/obj/machinery/mineral/stacking_machine/laborstacker/stacking_machine = null
	var/machinedir = SOUTH
	var/obj/item/card/id/prisoner/inserted_id
	var/obj/machinery/door/airlock/release_door
	var/door_tag = "prisonshuttle"
	var/obj/item/radio/intercom/announcer
	var/static/list/sheet_values

/obj/machinery/mineral/labor_claim_console/Initialize()
	. = ..()
	announcer = new /obj/item/radio/intercom(null)
	announcer.config(list("Security" = 0))

	if(!sheet_values)
		for(var/sheet_type in subtypesof(/obj/item/stack/sheet))
			var/obj/item/stack/sheet/sheet = sheet_type
			if(!initial(sheet.point_value) || (initial(sheet.merge_type) && initial(sheet.merge_type) != sheet_type)) //ignore no-value sheets and x/fifty subtypes
				continue
			sheet_values += list(list("ore" = initial(sheet.name), "value" = initial(sheet.point_value)))
		sheet_values = sortTim(sheet_values, /proc/cmp_sheet_list)

/obj/machinery/mineral/labor_claim_console/Destroy()
	. = ..()
	QDEL_NULL(announcer)

/proc/cmp_sheet_list(list/a, list/b)
	return a["value"] - b["value"]

/obj/machinery/mineral/labor_claim_console/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id/prisoner))
		if(!inserted_id)
			if(!user.unEquip(I))
				return
			I.forceMove(src)
			inserted_id = I
			to_chat(user, "<span class='notice'>You insert [I].</span>")
			SStgui.update_uis(src)
			return
		else
			to_chat(user, "<span class='notice'>There's an ID inserted already.</span>")
		return
	return ..()

/obj/machinery/mineral/labor_claim_console/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/mineral/labor_claim_console/attack_ghost(mob/user)
	attack_hand(user)

/obj/machinery/mineral/labor_claim_console/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "LaborClaimConsole", name, 315, 470, master_ui, state)
		ui.open()

/obj/machinery/mineral/labor_claim_console/ui_data(mob/user)
	var/list/data = list()
	var/can_go_home = FALSE

	data["emagged"] = emagged
	data["id_inserted"] = inserted_id != null
	if(inserted_id)
		data["id_name"] = inserted_id.registered_name
		data["id_points"] = inserted_id.mining_points
		data["id_goal"] = inserted_id.goal
	if(check_auth())
		can_go_home = TRUE

	if(stacking_machine)
		data["unclaimed_points"] = stacking_machine.points

	data["ores"] = sheet_values
	data["can_go_home"] = can_go_home

	return data

/obj/machinery/mineral/labor_claim_console/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("handle_id")
			if(inserted_id)
				if(!usr.put_in_hands(inserted_id))
					inserted_id.forceMove(get_turf(src))
				inserted_id = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/card/id/prisoner))
					if(!usr.unEquip(I))
						return
					I.forceMove(src)
					inserted_id = I
		if("claim_points")
			if(!inserted_id)
				return
			inserted_id.mining_points += stacking_machine.points
			stacking_machine.points = 0
			to_chat(usr, "Points transferred.")
		if("move_shuttle")
			if(!alone_in_area(get_area(src), usr))
				to_chat(usr, "<span class='warning'>Prisoners are only allowed to be released while alone.</span>")
			else
				switch(SSshuttle.moveShuttle("laborcamp", "laborcamp_home", TRUE, usr))
					if(1)
						to_chat(usr, "<span class='notice'>Shuttle not found.</span>")
					if(2)
						to_chat(usr, "<span class='notice'>Shuttle already at station.</span>")
					if(3)
						to_chat(usr, "<span class='notice'>No permission to dock could be granted.</span>")
					else
						if(!emagged)
							var/message = "[inserted_id.registered_name] has returned to the station. Minerals and Prisoner ID card ready for retrieval."
							announcer.autosay(message, "Labor Camp Controller", "Security")
						to_chat(usr, "<span class='notice'>Shuttle received message and will be sent shortly.</span>")
						usr.create_log(MISC_LOG, "used [src] to call the laborcamp shuttle")

	return TRUE

/obj/machinery/mineral/labor_claim_console/proc/check_auth()
	if(emagged)
		return TRUE //Shuttle is emagged, let any ol' person through
	return (istype(inserted_id) && inserted_id.mining_points >= inserted_id.goal) //Otherwise, only let them out if the prisoner's reached his quota.

/obj/machinery/mineral/labor_claim_console/emag_act(mob/user)
	if(!(emagged))
		emagged = TRUE
		to_chat(user, "<span class='warning'>PZZTTPFFFT</span>")


/**********************Prisoner Collection Unit**************************/
/obj/machinery/mineral/stacking_machine/laborstacker
	damage_deflection = 21
	var/points = 0 //The unclaimed value of ore stacked.

/obj/machinery/mineral/stacking_machine/laborstacker/process_sheet(obj/item/stack/sheet/inp)
	points += inp.point_value * inp.amount
	..()

/obj/machinery/mineral/stacking_machine/laborstacker/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/stack/sheet) && user.canUnEquip(I))
		var/obj/item/stack/sheet/inp = I
		points += inp.point_value * inp.amount
		return
	return ..()

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
	if(istype(I, /obj/item/card/id))
		if(istype(I, /obj/item/card/id/prisoner))
			var/obj/item/card/id/prisoner/prisoner_id = I
			to_chat(user, "<span class='notice'><B>ID: [prisoner_id.registered_name]</B></span>")
			to_chat(user, "<span class='notice'>Points Collected:[prisoner_id.mining_points]</span>")
			to_chat(user, "<span class='notice'>Point Quota: [prisoner_id.goal]</span>")
			to_chat(user, "<span class='notice'>Collect points by bringing smelted minerals to the Labor Shuttle stacking machine. Reach your quota to earn your release.</span>")
		else
			to_chat(user, "<span class='warning'>Error: Invalid ID</span>")
		return
	return ..()
