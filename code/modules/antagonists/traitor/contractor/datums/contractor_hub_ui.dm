/datum/contractor_hub/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	if(!contracts)
		if(action == "complete_load_animation")
			first_login(usr)
	else
		switch(action)
			if("page")
				var/newpage = text2num(params["page"])
				if(!(newpage in list(HUB_PAGE_CONTRACTS, HUB_PAGE_SHOP)))
					return
				page = newpage
			if("extract")
				var/error_message = current_contract?.start_extraction_process(ui_host(), usr)
				if(length(error_message))
					to_chat(usr, "<span class='warning'>[error_message]</span>")
			if("claim")
				claim_tc(usr)
			if("activate")
				var/datum/syndicate_contract/C = locateUID(params["uid"])
				var/difficulty = text2num(params["difficulty"])
				if(!istype(C) || !(C in contracts) || !(difficulty in list(EXTRACTION_DIFFICULTY_EASY, EXTRACTION_DIFFICULTY_MEDIUM, EXTRACTION_DIFFICULTY_HARD)))
					return
				C.initiate(usr, difficulty)
			if("abort")
				current_contract?.fail("Aborted by agent.")
			if("purchase")
				var/datum/rep_purchase/P = locateUID(params["uid"])
				if(!istype(P) || !(P in purchases) || rep < P.cost)
					return
				P.buy(src, usr)
			else
				return FALSE

	var/obj/item/U = ui_host()
	U?.add_fingerprint(usr)

/datum/contractor_hub/ui_state(mob/user)
	return GLOB.default_state

/datum/contractor_hub/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Contractor", "Syndicate Contractor Uplink")
		ui.open()

/datum/contractor_hub/ui_data(mob/user)
	var/list/data = list()

	if(!contracts)
		if(!is_user_authorized(user))
			data["unauthorized"] = TRUE
			return data
		data["load_animation_completed"] = FALSE
		return data
	else
		data["load_animation_completed"] = TRUE

	data["page"] = page
	data["tc_available"] = reward_tc_available
	data["tc_paid_out"] = reward_tc_paid_out
	data["completed_contracts"] = completed_contracts
	data["contract_active"] = !isnull(current_contract)
	data["rep"] = rep

	switch(page)
		if(HUB_PAGE_CONTRACTS)
			var/list/contracts_out = list()
			data["contracts"] = contracts_out
			for(var/c in contracts)
				var/datum/syndicate_contract/C = c
				if(C.status == CONTRACT_STATUS_INVALID)
					continue

				var/list/contract_data = list(
					uid = C.UID(),
					status = C.status,
					target_name = C.target_name,
					fluff_message = C.fluff_message,
					has_photo = !isnull(C.target_photo),
				)

				if(C.target_photo)
					usr << browse_rsc(C.target_photo, "target_photo_[C.UID()].png")

				switch(C.status)
					if(CONTRACT_STATUS_INACTIVE)
						var/list/difficulties = list(null, null, null)
						contract_data["difficulties"] = difficulties
						for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
							difficulties[difficulty] = list(name = C.contract.candidate_zones[difficulty].map_name, reward = C.reward_tc[difficulty])
					if(CONTRACT_STATUS_ACTIVE)
						contract_data["world_time"] = world.time
						contract_data["time_left"] = C.extraction_deadline - world.time
					if(CONTRACT_STATUS_COMPLETED)
						contract_data["completed_time"] = C.completed_time
						contract_data["dead_extraction"] = C.dead_extraction
					if(CONTRACT_STATUS_FAILED)
						contract_data["fail_reason"] = C.fail_reason

				if(C.contract.extraction_zone)
					var/area/A = get_area(user)
					contract_data["objective"] = list(
						extraction_name = C.contract.extraction_zone.map_name,
						locs = list(
							user_area_id = A.uid,
							user_coords = ATOM_COORDS(user),
							target_area_id = C.contract.extraction_zone.uid,
							target_coords = ATOM_COORDS(C.contract.extraction_zone),
						),
						rewards = list(tc = C.reward_tc[C.chosen_difficulty], credits = C.reward_credits)
					)
				contracts_out += list(contract_data)

			data["can_extract"] = current_contract?.contract.can_start_extraction_process(user) || FALSE

		if(HUB_PAGE_SHOP)
			var/list/buyables = list()
			for(var/p in purchases)
				var/datum/rep_purchase/P = p
				buyables += list(list(
					uid = P.UID(),
					name = P.name,
					description = P.description,
					cost = P.cost,
					stock = P.stock,
				))
			data["buyables"] = buyables

	return data
