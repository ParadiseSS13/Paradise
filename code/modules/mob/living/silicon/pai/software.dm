var/list/pai_emotions = list(
		"Happy" = 1,
		"Cat" = 2,
		"Extremely Happy" = 3,
		"Face" = 4,
		"Laugh" = 5,
		"Off" = 6,
		"Sad" = 7,
		"Angry" = 8,
		"What" = 9
	)


var/global/list/pai_software_by_key = list()
var/global/list/default_pai_software = list()
/hook/startup/proc/populate_pai_software_list()
	var/r = 1 // I would use ., but it'd sacrifice runtime detection
	for(var/type in subtypesof(/datum/pai_software))
		var/datum/pai_software/P = new type()
		if(pai_software_by_key[P.id])
			var/datum/pai_software/O = pai_software_by_key[P.id]
			to_chat(world, "<span class='warning'>pAI software module [P.name] has the same key as [O.name]!</span>")
			r = 0
			continue
		pai_software_by_key[P.id] = P
		if(P.default)
			default_pai_software[P.id] = P
	return r

/mob/living/silicon/pai/New()
	..()
	software = default_pai_software.Copy()

/mob/living/silicon/pai/verb/paiInterface()
	set category = "pAI Commands"
	set name = "Software Interface"

	ui_interact(src)

/mob/living/silicon/pai/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = self_state)
	if(ui_key != "main")
		var/datum/pai_software/S = software[ui_key]
		if(S && !S.toggle)
			ui = SSnanoui.try_update_ui(user, src, S.id, ui, force_open)
			if(!ui)
				ui = new(user, src, S.id, S.template_file, S.ui_title, S.ui_width, S.ui_height, state = state)
				ui.open()
				if(S.autoupdate)
					ui.set_auto_update(1)
		else
			if(ui)
				ui.set_status(STATUS_CLOSE, 0)
		return

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "pai_interface.tmpl", "pAI Software Interface", 450, 600, state = state)
		ui.open()
		ui.set_auto_update(1)

/mob/living/silicon/pai/ui_data(mob/user, ui_key = "main", datum/topic_state/state = self_state)
	var/data[0]

	if(ui_key != "main")
		var/datum/pai_software/S = software[ui_key]
		if(S && !S.toggle)
			return S.on_ui_data(user, state)
		log_runtime(EXCEPTION("Unrecognized/invalid pAI UI state '[ui_key]'"), src)
		return
	// Software we have bought
	var/bought_software[0]
	// Software we have not bought
	var/not_bought_software[0]

	for(var/key in pai_software_by_key)
		var/datum/pai_software/S = pai_software_by_key[key]
		var/software_data[0]
		software_data["name"] = S.name
		software_data["id"] = S.id
		if(key in software)
			software_data["on"] = S.is_active(src)
			bought_software[++bought_software.len] = software_data
		else
			software_data["ram"] = S.ram_cost
			not_bought_software[++not_bought_software.len] = software_data

	data["bought"] = bought_software
	data["not_bought"] = not_bought_software
	data["available_ram"] = ram

	// Emotions
	var/emotions[0]
	for(var/name in pai_emotions)
		var/emote[0]
		emote["name"] = name
		emote["id"] = pai_emotions[name]
		emotions[++emotions.len] = emote

	data["emotions"] = emotions
	data["current_emotion"] = card.current_emotion

	return data

/mob/living/silicon/pai/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["software"])
		var/soft = href_list["software"]
		var/datum/pai_software/S = software[soft]
		if(S.toggle)
			S.toggle(src)
		else
			ui_interact(src, ui_key = soft)
		return 1

	else if(href_list["stopic"])
		var/soft = href_list["stopic"]
		var/datum/pai_software/S = software[soft]
		if(S)
			return S.Topic(href, href_list)

	else if(href_list["purchase"])
		var/soft = href_list["purchase"]
		var/datum/pai_software/S = pai_software_by_key[soft]
		if(S && (ram >= S.ram_cost))
			ram -= S.ram_cost
			software[S.id] = S
		return 1

	else if(href_list["image"])
		var/img = text2num(href_list["image"])
		if(1 <= img && img <= 9)
			card.setEmotion(img)
		return 1
