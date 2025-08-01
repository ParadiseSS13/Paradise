#define IMPLANT_WARN_COOLDOWN (30 SECONDS)

/obj/machinery/computer/prisoner
	name = "labor camp points manager"
	icon_keyboard = "security_key"
	icon_screen = "explosive"
	req_access = list(ACCESS_BRIG)
	circuit = /obj/item/circuitboard/prisoner

	var/authenticated = FALSE // FALSE - No Access Denied, TRUE - Access allowed
	var/inserted_id_uid

	light_color = LIGHT_COLOR_DARKRED

/obj/machinery/computer/prisoner/Initialize(mapload)
	. = ..()
	GLOB.prisoncomputer_list += src

/obj/machinery/computer/prisoner/Destroy()
	GLOB.prisoncomputer_list -= src
	return ..()

/obj/machinery/computer/prisoner/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	var/datum/ui_login/state = ui_login_get()
	if(state.logged_in)
		var/obj/item/card/id/prisoner/I = used
		if(istype(I) && user.drop_item())
			I.forceMove(src)
			inserted_id_uid = I.UID()
			return ITEM_INTERACT_COMPLETE
	if(ui_login_attackby(used, user))
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/computer/prisoner/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/computer/prisoner/attack_hand(mob/user)
	if(..())
		return TRUE
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/prisoner/proc/check_implant(obj/item/bio_chip/I)
	var/turf/implant_location = get_turf(I)
	if(!implant_location || implant_location.z != z)
		return FALSE
	if(!I.implanted)
		return FALSE
	return TRUE

/obj/machinery/computer/prisoner/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/prisoner/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PrisonerImplantManager", name)
		ui.open()

/obj/machinery/computer/prisoner/ui_data(mob/user)
	var/list/data = list()
	ui_login_data(data, user)
	var/obj/item/card/id/prisoner/inserted_id = locateUID(inserted_id_uid)
	data["prisonerInfo"] = list(
		"name" = inserted_id?.name,
		"points" = inserted_id?.mining_points,
		"goal" = inserted_id?.goal,
	)

	data["chemicalInfo"] = list()
	for(var/obj/item/bio_chip/chem/C in GLOB.tracked_implants)
		if(!check_implant(C))
			continue
		var/list/implant_info = list(
			"name" = C.imp_in.name,
			"volume" = C.reagents.total_volume,
			"uid" = C.UID(),
		)
		data["chemicalInfo"] += list(implant_info)

	data["trackingInfo"] = list()
	for(var/obj/item/bio_chip/tracking/T in GLOB.tracked_implants)
		if(!check_implant(T))
			continue
		var/mob/living/carbon/M = T.imp_in
		var/loc_display = "Unknown"
		var/health_display = "OK"
		var/total_loss = (M.maxHealth - M.health)
		if(M.stat == DEAD)
			health_display = "DEAD"
		else if(total_loss)
			health_display = "HURT ([total_loss])"
		var/turf/implant_location = get_turf(T)
		if(!isspaceturf(implant_location))
			loc_display = "[get_area(implant_location)]"

		var/list/implant_info = list(
			"subject" = M.name,
			"location" = loc_display,
			"health" = health_display,
			"uid" = T.UID()
		)
		data["trackingInfo"] += list(implant_info)

	data["modal"] = ui_modal_data(src)

	return data

/obj/machinery/computer/prisoner/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	add_fingerprint(ui.user)

	if(ui_act_modal(action, params, ui))
		return
	if(ui_login_act(action, params))
		return

	var/mob/living/user = ui.user
	var/obj/item/card/id/prisoner/inserted_id = locateUID(inserted_id_uid)
	switch(action)
		if("id_card")
			if(inserted_id)
				if(!ui.user.put_in_hands(inserted_id))
					inserted_id.forceMove(get_turf(src))
				inserted_id_uid = null
				return
			var/obj/item/card/id/prisoner/I = user.get_active_hand()
			if(istype(I) && user.drop_item())
				I.forceMove(src)
				inserted_id_uid = I.UID()
			else
				to_chat(user, "<span class='warning'>No valid ID.</span>")
		if("inject")
			var/obj/item/bio_chip/chem/implant = locateUID(params["uid"])
			if(!implant)
				return
			implant.activate(text2num(params["amount"]))
		if("reset_points")
			if(inserted_id)
				inserted_id.mining_points = 0

/obj/machinery/computer/prisoner/proc/ui_act_modal(action, list/params, datum/tgui/ui)
	if(!ui_login_get().logged_in)
		return
	. = TRUE
	var/id = params["id"]
	var/mob/living/user = ui.user
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]

	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("warn")
					ui_modal_input(src, id, "Please enter your message:", null, arguments = list(
						"uid" = arguments["uid"],
					))
				if("set_points")
					ui_modal_input(src, id, "Please enter the new point goal:", null, arguments)

		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("warn")
					var/obj/item/bio_chip/tracking/implant = locateUID(arguments["uid"])
					if(!implant)
						return
					if(implant.warn_cooldown >= world.time)
						to_chat(user, "<span class='warning'>The warning system for that bio-chip is still cooling down.</span>")
						return
					implant.warn_cooldown = world.time + IMPLANT_WARN_COOLDOWN
					if(implant.imp_in)
						var/mob/living/carbon/implantee = implant.imp_in
						var/warning = copytext(sanitize(answer), 1, MAX_MESSAGE_LEN)
						to_chat(implantee, "<span class='boldnotice'>Your skull vibrates violently as a loud announcement is broadcasted to you: '[warning]'</span>")

				if("set_points")
					if(isnull(text2num(answer)))
						return
					var/obj/item/card/id/prisoner/inserted_id = locateUID(inserted_id_uid)
					inserted_id?.goal = max(text2num(answer), 0)

	return FALSE

#undef IMPLANT_WARN_COOLDOWN
