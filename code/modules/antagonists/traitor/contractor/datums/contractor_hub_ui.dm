
#define PAGE_CONTRACTS 1
#define PAGE_HUB 2

/datum/tgui_module/contractor_uplink
	name = "Syndicate Contractor Uplink"
	/// The Contractor Hub associated to this UI.
	var/datum/contractor_hub/hub = null
	/// Current page index.
	var/page = PAGE_CONTRACTS

/datum/tgui_module/contractor_uplink/tgui_act(action, list/params)
	if(..())
		return

	. = TRUE
	if(!hub.contracts)
		if(action == "complete_load_animation")
			hub.first_login(usr)
	else
		switch(action)
			if("page")
				var/newpage = text2num(params["page"])
				if(!(newpage in list(PAGE_CONTRACTS, PAGE_HUB)))
					return
				page = newpage
			if("extract")
				var/error_message = hub.current_contract?.start_extraction_process(tgui_host(), usr)
				if(length(error_message))
					to_chat(usr, "<span class='warning'>[error_message]</span>")
			if("claim")
				hub.claim_tc(usr)
			if("activate")
				var/datum/syndicate_contract/C = locateUID(params["uid"])
				var/difficulty = text2num(params["difficulty"])
				if(!istype(C) || !(C in hub.contracts) || !(difficulty in list(EXTRACTION_DIFFICULTY_EASY, EXTRACTION_DIFFICULTY_MEDIUM, EXTRACTION_DIFFICULTY_HARD)))
					return
				C.initiate(usr, difficulty)
			if("abort")
				hub.current_contract?.fail("Aborted by agent.")
			if("purchase")
				var/datum/rep_purchase/P = locateUID(params["uid"])
				if(!istype(P) || !(P in hub.purchases) || hub.rep < P.cost)
					return
				P.buy(hub, usr)
			else
				return FALSE

	var/obj/item/U = tgui_host()
	U?.add_fingerprint(usr)

/datum/tgui_module/contractor_uplink/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Contractor", name, 500, 600, master_ui, state)
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/tgui_module/contractor_uplink/tgui_data(mob/user)
	var/list/data = list()

	if(!hub.contracts)
		if(!hub.is_user_authorized(user))
			data["unauthorized"] = TRUE
			return data
		data["load_animation_completed"] = FALSE
		return data
	else
		data["load_animation_completed"] = TRUE

	data["page"] = page
	data["tc_available"] = hub.reward_tc_available
	data["tc_paid_out"] = hub.reward_tc_paid_out
	data["completed_contracts"] = hub.completed_contracts
	data["contract_active"] = !isnull(hub.current_contract)
	data["rep"] = hub.rep

	switch(page)
		if(PAGE_CONTRACTS)
			var/list/contracts = list()
			data["contracts"] = contracts
			for(var/c in hub.contracts)
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
					contract_data["objective"] = list(
						extraction_zone = C.contract.extraction_zone.map_name,
						reward_tc = C.reward_tc[C.chosen_difficulty],
						reward_credits = C.reward_credits,
					)
				contracts += list(contract_data)

			data["can_extract"] = hub.current_contract?.contract.can_start_extraction_process(tgui_host(), usr) || FALSE
		if(PAGE_HUB)
			var/list/buyables = list()
			for(var/p in hub.purchases)
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

#undef PAGE_CONTRACTS
#undef PAGE_HUB
