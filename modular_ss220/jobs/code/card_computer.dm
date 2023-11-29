/obj/machinery/computer/card/ui_data(mob/user)
	var/list/data = ..()

	if(mode == IDCOMPUTER_SCREEN_TRANSFER) // JOB TRANSFER
		if(modify && scan && !target_dept)
			data["card_skins"] |= format_card_skins(GLOB.card_skins_ss220)

	return data

/obj/machinery/computer/card/ui_act(action, params)
	. = ..()
	switch(action)
		if("skin")
			if(!modify)
				return FALSE
			var/skin = params["skin_target"]
			if(!skin || !(skin in GLOB.card_skins_ss220))
				return FALSE

			modify.icon_state = skin//get_card_skins_ss220(skin)
			return TRUE
