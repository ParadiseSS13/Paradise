/datum/controller/subsystem/ticker/declare_completion()
	. = ..()
	var/list/end_of_round_info = list()
	end_of_round_info += mode.get_extra_end_of_round_antagonist_statistics()
	if(!length(end_of_round_info))
		return
	to_chat(world, chat_box_purple(end_of_round_info.Join("<br>")))

/datum/game_mode/proc/get_extra_end_of_round_antagonist_statistics()
	. = list()
	. += auto_declare_completion_vox_raiders()
	listclearnulls(.)

/datum/game_mode/proc/auto_declare_completion_vox_raiders()
	if(!length(vox_raiders))
		return

	var/list/text = list("<br><font size=3><b>Прогресс Вокс'ов:</b></font>")
	var/obj/machinery/vox_trader/trader = locate() in GLOB.machines
	if(!trader)
		text += "<br>"
		return text.Join("")
	trader.synchronize_traders_stats()

	text += "<br><br><b>Всего заработано Кикиридитов:</b> [trader.all_values_sum]"

	var/precious_count = 0
	var/biggest_index
	for(var/I in trader.precious_collected_dict)
		var/value = trader.precious_collected_dict[I]["value"]
		var/count = trader.precious_collected_dict[I]["count"]
		precious_count += count
		if(!biggest_index || trader.precious_collected_dict[biggest_index]["value"] <= value)
			biggest_index = I
	text += "<br><b>Самый дорогой проданный товар:</b> \
		<br>[biggest_index] ([trader.precious_collected_dict[biggest_index]["value"]]), \
		всего продано [trader.precious_collected_dict[biggest_index]["count"]] штук."

	text += "<br><br><b>Собраны доступы:<br></b>"
	var/list/checked_accesses = list()
	var/list/region_codes = list(
		REGION_GENERAL, REGION_SECURITY, REGION_MEDBAY, REGION_RESEARCH,
		REGION_ENGINEERING, REGION_SUPPLY, REGION_COMMAND, REGION_CENTCOMM
		)
	for(var/code in region_codes)
		var/list/region_accesses
		if(code != REGION_CENTCOMM)
			region_accesses = get_region_accesses(code)
		else
			region_accesses = list(ACCESS_CENT_GENERAL)
		for(var/access in trader.collected_access_list)
			if(access in region_accesses)
				region_accesses.Remove(access)
		checked_accesses["[code]"] = region_accesses
	var/access_count = 0
	for(var/code in region_codes)
		if(length(checked_accesses["[code]"]) > 0)
			continue
		switch(code)
			if(REGION_GENERAL)
				text += "Собраны все общественные и сервисные доступы!"
			if(REGION_SECURITY)
				text += "<br><font color='red'>Собраны все доступы службы безопасности!</font>"
			if(REGION_MEDBAY)
				text += "<br><font color='teal'>Собраны все доступы медицинского отдела!</font>"
			if(REGION_RESEARCH)
				text += "<br><font color='purple'>Собраны все доступы научного отдела!</font>"
			if(REGION_ENGINEERING)
				text += "<br><font color='orange'>Собраны все инженерные доступы!</font>"
			if(REGION_SUPPLY)
				text += "<br><font color='brown'>Собраны все доступы отдела снабжения!</font>"
			if(REGION_COMMAND)
				text += "<br><font color='blue'>Собраны все командные доступы!</font>"
			if(REGION_CENTCOMM)
				text += "<br><font color='green'><B>Получен особый доступ к Центральному Командованию!</B></font>"
		access_count++
	if(!access_count)
		text += "<br>Ни одного полного отдела доступов!"

	text += "<br><br><b>Собраны технологии:</b>"
	for(var/i in trader.collected_tech_dict)
		text += "<br>[i]: [trader.collected_tech_dict[i]]"

	text += "<br>"
	return text.Join("")
