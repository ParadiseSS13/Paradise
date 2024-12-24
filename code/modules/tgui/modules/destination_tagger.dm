/datum/ui_module/destination_tagger
	name = "Destination Tagger"
	var/my_tag = 1

/datum/ui_module/destination_tagger/ui_state(mob/user)
	return GLOB.default_state

/datum/ui_module/destination_tagger/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DestinationTagger", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/ui_module/destination_tagger/ui_data(mob/user)
	var/list/data = list()
	data["selected_destination_id"] = clamp(my_tag, 1, length(GLOB.TAGGERLOCATIONS))
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
		if(my_tag == destination_id)
			return

		my_tag = destination_id
		playsound(host, 'sound/machines/terminal_select.ogg', 15, TRUE)
		. = TRUE
		// Handle setting tags (and flushing for drones)
		if(istype(host, /obj/item/dest_tagger))
			var/obj/item/dest_tagger/O = host
			O.currTag = my_tag
		else if(isrobot(host))
			var/mob/living/silicon/robot/R = host
			R.mail_destination = my_tag

			//Auto flush if we use this verb inside a disposal chute.
			if(istype(R.loc, /obj/machinery/disposal))
				var/obj/machinery/disposal/D = R.loc
				to_chat(R, "<span class='notice'>[D] acknowledges your signal.</span>")
				D.flush_count = D.flush_every_ticks
