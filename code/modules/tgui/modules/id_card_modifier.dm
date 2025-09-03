RESTRICT_TYPE(/datum/ui_module/id_card_modifier)

/datum/ui_module/id_card_modifier
	name = "ID Card Modifier"
	var/obj/item/card/id/card

/datum/ui_module/id_card_modifier/New(datum/_host, obj/item/card/id/target)
	..()
	if(!istype(target))
		stack_trace("Attempted to create an access modifier on a non-/obj")
		qdel(src)
		return

	card = target

/datum/ui_module/id_card_modifier/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/id_card_modifier/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IdCardModifier", name)
		ui.autoupdate = FALSE
		ui.open()

/datum/ui_module/id_card_modifier/ui_data(mob/user)
	. = list()
	.["card"] = card.to_tgui()
	.["card_skins"] = format_card_skins(get_station_card_skins())
	.["all_centcom_skins"] = format_card_skins(get_centcom_card_skins())

/datum/ui_module/id_card_modifier/ui_static_data(mob/user)
	. = list()
	.["regions"] = get_accesslist_static_data(REGION_GENERAL, REGION_MISC)

/datum/ui_module/id_card_modifier/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("reg")
			var/temp_name = reject_bad_name(input(usr, "Who is this ID for?", "ID Card Renaming", card.registered_name), TRUE)
			if(!temp_name)
				to_chat(usr, "<span class='warning'>Rejecting invalid name `[temp_name]`.</span>")
				return
			card.registered_name = temp_name
			card.regenerate_name()
		if("set_card_skin")
			card.icon_state = params["skin_target"]
			card.update_appearance(UPDATE_ICON_STATE)
		if("set_card_account_number") // card account number
			var/account_num = tgui_input_number(usr, "Account Number", "Input Number", card.associated_account_number, 9999999, 1000000)
			if(isnull(account_num))
				return
			card.associated_account_number = account_num
		if("set_job_name")
			var/job_name = tgui_input_text(
				usr,
				"Please input a job name. Note that this does not perform any security record or data core updates.",
				"Job Name",
				card.rank)
			if(isnull(job_name))
				return
			card.rank = job_name
			card.assignment = job_name
			card.regenerate_name()

		// shamelessly copy-pasted from id_card_console.dm
		// Changing card access
		if("set") // add/remove a single access number
			var/access = text2num(params["access"])
			if(access in card.access)
				card.access -= access
			else
				card.access += access
		if("grant_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < REGION_GENERAL)
				to_chat(usr, "<span class='warning'>Rejecting invalid region `[region]`.</span>")
				return
			card.access |= get_region_accesses(region)
		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < REGION_GENERAL)
				to_chat(usr, "<span class='warning'>Rejecting invalid region `[region]`.</span>")
				return
			card.access -= get_region_accesses(region)
		if("clear_all")
			card.access = list()
		if("grant_all")
			card.access |= get_all_accesses()

	return TRUE
