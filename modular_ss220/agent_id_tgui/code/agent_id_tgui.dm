/obj/item/card/id/syndicate
	dna_hash = null
	blood_type = null
	fingerprint_hash = null
	var/mob/living/carbon/human/registered_human
	var/static/list/appearances
	var/static/list/departments = list(
				"Assistant" = null,
				"Service" = GLOB.service_positions,
				"Supply" = GLOB.supply_positions,
				"Engineering" = GLOB.engineering_positions,
				"Medical" = GLOB.medical_positions,
				"Science" = GLOB.science_positions,
				"Security" = GLOB.security_positions,
				"Command" = GLOB.command_positions,
				"Special" = (get_all_solgov_jobs() + get_all_soviet_jobs() + get_all_centcom_jobs()),
				"Custom" = null,
			)

/obj/item/card/id/syndicate/New()
	. = ..()
	var/static/list/final_appearances = list()

	if(length(final_appearances) == 0)
		var/static/list/restricted_skins = list("admin", "deathsquad", "clownsquad", "data", "ERT_empty", "silver", "gold", "TDred", "TDgreen")
		var/static/list/raw_appearances = GLOB.card_skins_ss220 + GLOB.card_skins_special_ss220 + GLOB.card_skins_donor_ss220 - restricted_skins
		for(var/skin in raw_appearances)
			final_appearances[skin] = "[icon2base64(icon(initial(icon), skin, SOUTH, 1))]"

	appearances = final_appearances

/obj/item/card/id/syndicate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..() || !registered_human)
		return
	. = TRUE

	switch(action)
		if("change_name")
			var/new_name
			if(params["option"] == "Primary")
				new_name = ishuman(registered_human) ? registered_human.real_name : registered_human.name

			else if(params["option"] == "Secondary")
				new_name = tgui_input_list(registered_human, "Чьё имя вы хотите взять?", "Карта Агента - Имя", GLOB.human_list)
				if(isnull(new_name))
					return

			else
				new_name = params["name"]

			registered_name = reject_bad_name(new_name, TRUE)
			UpdateName()
			to_chat(registered_human, span_notice("Имя изменено на: [new_name]."))

		if("change_sex")
			var/new_sex = params["sex"]
			sex = new_sex
			to_chat(registered_human, span_notice("Пол изменён на: [sex]."))

		if("change_age")
			var/new_age = params["age"]
			age = clamp(new_age, 17, 300)
			to_chat(registered_human, span_notice("Возраст изменён на: [new_age]."))

		if("change_occupation")
			change_occupation()

		if("change_fingerprints")
			if(params["option"] == "Primary")
				fingerprint_hash = md5(registered_human.dna.uni_identity)
			else
				var/fingerprints_param  = params["new_fingerprints"]
				if(fingerprints_param)
					fingerprint_hash = fingerprints_param

			to_chat(registered_human, span_notice("Отпечатки изменёны на: [fingerprint_hash]."))

		if("change_blood_type")
			if(params["option"] == "Primary")
				blood_type = registered_human.dna.blood_type
			else
				var/blood_param = params["new_type"]
				if(blood_param)
					blood_type = blood_param

			to_chat(registered_human, span_notice("Тип крови изменён на: [blood_type]."))

		if("change_dna_hash")
			if(params["option"] == "Primary")
				dna_hash = registered_human.dna.unique_enzymes
			else
				var/dna_param = params["new_dna"]
				if(dna_param)
					dna_hash = dna_param

			to_chat(registered_human, span_notice("ДНК изменён на: [dna_hash]."))

		if("change_money_account")
			var/new_account
			if(params["option"] == "Primary")
				new_account = rand(1000, 9999) * 1000 + rand(1000, 9999)
			else
				new_account = params["new_account"]
				if(!isnum(new_account))
					to_chat(registered_human, span_warning("Номер аккаунта должен состоять только из цифр!"))
					return

			associated_account_number = clamp(new_account, 1000000, 9999999)
			to_chat(registered_human, span_notice("Привязанный счёт изменён на: [new_account]."))

		if("change_photo")
			change_photo()
		if("change_appearance")
			change_appearance(params)
		if("delete_info")
			delete_info()
		if("clear_access")
			clear_access()
		if("change_ai_tracking")
			change_ai_tracking()
	RebuildHTML()

/obj/item/card/id/syndicate/ui_data(mob/user)
	var/list/data = list()
	data["registered_name"] = registered_name
	data["sex"] = sex
	data["age"] = age
	data["assignment"] = assignment
	data["associated_account_number"] = associated_account_number
	data["blood_type"] = blood_type
	data["dna_hash"] = dna_hash
	data["fingerprint_hash"] = fingerprint_hash
	data["photo"] = photo
	data["ai_tracking"] = untrackable
	return data

/obj/item/card/id/syndicate/ui_static_data(mob/user)
	var/list/data = list()
	data["appearances"] = appearances
	return data

/obj/item/card/id/syndicate/ui_state(mob/user)
	return GLOB.default_state

/obj/item/card/id/syndicate/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AgentCard", name)
		ui.open()

/obj/item/card/id/syndicate/proc/check_registered_human(mob/user)
	if(!ishuman(user))
		return FALSE
	if(!registered_human)
		registered_human = user
	if(registered_human != user)
		return FALSE
	return TRUE

/obj/item/card/id/syndicate/attack_self(mob/user)
	flash_card(user)
	return

/obj/item/card/id/syndicate/CtrlClick(mob/user)
	if(!check_registered_human(user))
		return
	ui_interact(user)

/obj/item/card/id/syndicate/examine(mob/user)
	. = ..()
	if(check_registered_human(user))
		. += span_info("<b>Ctrl-Click</b> для открытия интерфейса.")

/obj/item/card/id/proc/flash_card(mob/user)
	user.visible_message(
		span_notice("[user] показывает тебе: [bicon(src)] [src.name]. Должность на карте: [src.assignment]."),
		span_notice("Ты показываешь свою ID карту: [bicon(src)] [src.name]. Должность на карте: [src.assignment]."))
	if(mining_points)
		to_chat(user, "На ней <b>[mining_points] шахтёрских очков</b>. Всего было получено за смену <b>[total_mining_points] шахтёрских очков</b>!")
	src.add_fingerprint(user)

/obj/item/card/id/syndicate/proc/delete_info()
	name = null
	registered_name = null
	icon_state = null
	sex = null
	age = null
	assignment = null
	associated_account_number = null
	blood_type = null
	dna_hash = null
	fingerprint_hash = null
	photo = null
	registered_user = null
	SStgui.close_uis(src)
	to_chat(registered_human, span_notice("Вся информация с карты агента была удалена."))

/obj/item/card/id/syndicate/proc/clear_access()
	access = initial_access.Copy()
	to_chat(registered_human, span_notice("Выполнен сброс доступов."))

/obj/item/card/id/syndicate/proc/change_ai_tracking()
	untrackable = !untrackable
	to_chat(registered_human, span_notice("Эта ID карта[untrackable ? " не" : ""] может быть отслежена ИИ."))

/obj/item/card/id/syndicate/proc/change_photo()
	if(!Adjacent(registered_human))
		return

	var/job_clothes = null
	if(assignment)
		job_clothes = assignment

	var/icon/newphoto = get_id_photo(registered_human, job_clothes)
	if(!newphoto)
		return

	photo = newphoto
	to_chat(registered_human, span_notice("Фото изменено. Если хотите другую одежду, то выберите другую должность и измените снова."))

/obj/item/card/id/syndicate/proc/change_appearance(list/params)
	var/choice = params["new_appearance"]
	if(!(choice in appearances))
		message_admins("Warning: AgentID href exploit attempted by [key_name(usr)]! Impossible icon_state: [choice].")
		return

	icon_state = choice
	to_chat(usr, span_notice("Внешний вид изменён на: [choice]."))

/obj/item/card/id/syndicate/proc/change_occupation()
	var/title = "Карта Агента - Должность"
	var/department_icon_text = "Какая должность будет показываться с этой картой на ХУДах?"
	var/department_selection_text = "Какую должность вы хотите присвоить этой карте? Выберите департамент, или можете вписать собственную должность."
	var/selected_department = tgui_input_list(registered_human, department_selection_text, title, departments)
	if(isnull(selected_department))
		return

	var/new_rank
	var/new_job
	if(selected_department == "Assistant")
		new_job = selected_department
		new_rank = selected_department

	else if(selected_department == "Custom")
		new_job = sanitize(tgui_input_text(registered_human, "Введите название своей должности:", title, "Assistant", MAX_MESSAGE_LEN))
		var/department_icon = tgui_input_list(registered_human, department_icon_text, title, departments - list("Assistant", "Custom"))
		if(isnull(department_icon))
			to_chat(registered_human, span_warning("Вы должны выбрать департамент!"))
			return
		new_rank = tgui_input_list(registered_human, department_icon_text, title, departments[department_icon])

	else
		new_job = tgui_input_list(registered_human, "Какую должность вы хотите?", title, departments[selected_department])
		if(isnull(new_job))
			new_job = "Assistant"
		new_rank = new_job

	if(!Adjacent(registered_human))
		return

	assignment = new_job
	rank = new_rank
	UpdateName()
	registered_human.sec_hud_set_ID()
	to_chat(registered_human, span_notice("Должность сменена на [new_job]."))
