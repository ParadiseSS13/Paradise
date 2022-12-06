/datum/ui_module/destination_tagger
	name = "Destination Tagger"
	var/myTag = 1

/datum/ui_module/destination_tagger/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "DestinationTagger", name, 395, 350, master_ui, state)
		ui.open()

/datum/ui_module/destination_tagger/ui_data(mob/user)
	var/list/data = list()
	data["selected_destination_id"] = clamp(myTag, 1, length(GLOB.TAGGERLOCATIONS))
	return data

/datum/ui_module/destination_tagger/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["destinations"] = list()
	for(var/destination_index in 1 to length(GLOB.TAGGERLOCATIONS))
		var/list/destination_data = list(
			"name" = GLOB.TAGGERLOCATIONS[destination_index],
			"id"   = destination_index,
		)
		static_data["destinations"] += list(destination_data)
	return static_data

/datum/ui_module/destination_tagger/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(action == "select_destination")
		var/destination_id = clamp(text2num(params["destination"]), 1, length(GLOB.TAGGERLOCATIONS))
		if(myTag != destination_id)
			myTag = destination_id
			playsound(host, 'sound/machines/terminal_select.ogg', 15, TRUE)

			// Handle setting tags (and flushing for drones)
			if(istype(host, /obj/item/destTagger))
				var/obj/item/destTagger/O = host
				O.currTag = myTag
			else if (isrobot(host))
				var/mob/living/silicon/robot/R = host
				R.mail_destination = myTag

				//Auto flush if we use this verb inside a disposal chute.
				if(istype(R.loc, /obj/machinery/disposal))
					var/obj/machinery/disposal/D = R.loc
					to_chat(R, "<span class='notice'>[D] acknowledges your signal.</span>")
					D.flush_count = D.flush_every_ticks
