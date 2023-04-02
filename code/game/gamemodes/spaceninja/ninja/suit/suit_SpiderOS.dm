/*
 * Здесь всё что связано с TGUI интерфейсом костюма.
 */

//Кнопка для вызова интерфейса
/datum/action/item_action/advanced/ninja/SpiderOS
	name = "SpiderOS"
	desc = "Your personal integrated suit AI that will help you configure yourself for the upcoming mission!"
	check_flags = NONE
	charge_type = ADV_ACTION_TYPE_TOGGLE
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon_state = "spider_green"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"

/obj/item/clothing/suit/space/space_ninja/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SpiderOS", name, 700, 700, master_ui, state)
		ui.open()

/obj/item/clothing/suit/space/space_ninja/ui_data(mob/user)
	var/list/data = list()

	data["designs"] = designs
	data["design_choice"] = design_choice
	data["scarf_design_choice"] = scarf_design_choice
	data["colors"] = colors
	data["color_choice"] = color_choice
	data["genders"] = genders
	data["preferred_clothes_gender"] = preferred_clothes_gender
	data["preferred_scarf_over_hood"] = preferred_scarf_over_hood
	data["style_preview_icon_state"] = style_preview_icon_state
	data["show_charge_UI"] = show_charge_UI
	data["has_martial_art"] = user.mind.martial_art ? TRUE : FALSE
	data["show_concentration_UI"] = show_concentration_UI

	data["blocked_TGUI_rows"] = blocked_TGUI_rows

	data["suit_state"] = s_initialized
	data["suit_energy"] = cell.charge
	data["suit_energy_max"] = cell.maxcharge
	data["suit_tgui_state"] = suit_tgui_state

	data["current_load_text"] = current_initialisation_text
	data["current_initialisation_phase"] = current_initialisation_phase
	data["end_terminal"] = s_TGUI_initialized

	var/obj/docking_port/mobile/ninja_shuttle_port = SSshuttle.getShuttle(shuttle_controller.shuttleId)
	var/shuttle_status = ninja_shuttle_port ? ninja_shuttle_port.getStatusText() : null
	shuttle_status += ": [ninja_shuttle_port.x], [ninja_shuttle_port.y], [ninja_shuttle_port.z]"
	data["status"] = shuttle_status
	if(user.lastarea)	//Сейф чек. Вызывает рантаймы если только заспавнился и открыл интерфейс, ни сделав ни шага
		data["player_pos"] = "[user.lastarea.name]: [user.x], [user.y], [user.z]"
	if(ninja_shuttle_port)
		data["shuttle"] = TRUE	//this should just be boolean, right?
		var/list/docking_ports = list()
		data["docking_ports"] = docking_ports
		var/list/options = params2list(shuttle_controller.possible_destinations)
		for(var/obj/docking_port/stationary/ninja_stationary_shuttle_port in SSshuttle.stationary)
			if(!options.Find(ninja_stationary_shuttle_port.id))
				continue
			if(!ninja_shuttle_port.check_dock(ninja_stationary_shuttle_port))
				continue
			docking_ports[++docking_ports.len] = list("name" = ninja_stationary_shuttle_port.name, "id" = ninja_stationary_shuttle_port.id)
		data["docking_ports_len"] = docking_ports.len
		data["admin_controlled"] = shuttle_controller.admin_controlled

	if(suit_tgui_state == NINJA_TGUI_LOADING_STATE)
		data["randomPercent"] = pick(rand(1,100), 100)

	return data

/obj/item/clothing/suit/space/space_ninja/ui_static_data(mob/user)
	var/list/data = list()

	//Превью абилок
	data["allActionsPreview"] = list()
	for (var/style in allowed_states)
		var/icon/action_icon = icon('icons/mob/actions/actions_ninja.dmi', style, SOUTH, frame = 1)
		data["allActionsPreview"][style] = icon2base64(action_icon)

	//Превью костюмов
	data["allStylesPreview"] = list()
	for (var/style in allowed_preview_states)
		var/icon/costume_icon = icon('icons/mob/ninja_previews.dmi', style, SOUTH, frame = 1)
		data["allStylesPreview"][style] = icon2base64(costume_icon)

	return data

/obj/item/clothing/suit/space/space_ninja/ui_act(action, list/params)
	if(..())
		return
	var/list/options = params2list(shuttle_controller.possible_destinations)
	var/mob/living/carbon/human/ninja = usr
	switch(action)
		if("initialise_suit")
			if(ninja.get_item_by_slot(slot_wear_suit) == src)
				toggle_on_off()
				suit_tgui_state = NINJA_TGUI_LOADING_STATE
			else
				to_chat(usr, span_boldwarning("Наденьте костюм!"))
				return
		if("set_UI_state")
			suit_tgui_state = text2num(params["suit_tgui_state"])
		if("set_design")
			design_choice = params["design_choice"]
			update_TGUI_style_preview()
		if("set_scarf_design")
			scarf_design_choice = params["scarf_design_choice"]
			update_TGUI_style_preview()
		if("set_color")
			color_choice = params["color_choice"]
			update_TGUI_style_preview()
		if("set_gender")
			preferred_clothes_gender = params["preferred_clothes_gender"]
			update_TGUI_style_preview()
		if("toggle_scarf")
			preferred_scarf_over_hood = !preferred_scarf_over_hood
			update_TGUI_style_preview()
		if("toggle_ui_charge")
			show_charge_UI = !show_charge_UI
		if("toggle_ui_concentration")
			show_concentration_UI = !show_concentration_UI
		if("give_ability")
			if(s_initialized)
				to_chat(usr, span_notice("Нельзя приобрести способности с включённым костюмом!"))
				return
			if(bying_ability)
				to_chat(usr, span_warning("Вы уже выбираете модуль!"))
				return
			toggle_ability_buy_block()
			if(alert(usr, "Вы уверены, что хотите приобрести эту способность?",,"Да","Нет") == "Нет")
				addtimer(CALLBACK(src, .proc/toggle_ability_buy_block), 2 SECONDS)
				return
			var/ability = params["style"]
			var/row_to_block = text2num(params["row"])
			blocked_TGUI_rows[row_to_block] = TRUE
			var/icon/ability_icon = icon('icons/mob/actions/actions_ninja.dmi', ability, SOUTH, frame = 1)
			if(ability == "spider_red")
				var/datum/martial_art/ninja_martial_art/creeping_widow = new
				ninja_martial = TRUE
				creeping_widow.teach(usr)
				creeping_widow.my_suit = src
				creeping_widow.my_energy_katana = energyKatana
				ninja.mind.ninja.purchased_abilities += "<BIG>[bicon(ability_icon)]</BIG>"
				addtimer(CALLBACK(src, .proc/toggle_ability_buy_block), 2 SECONDS)
				return
			if(ability == "cloning")
				ninja_clonable = TRUE
				to_chat(usr, span_notice("Вы внесены в список устройства для воскрешения на своей базе."))
				ninja.mind.ninja.purchased_abilities += "<BIG>[bicon(ability_icon)]</BIG>"
				addtimer(CALLBACK(src, .proc/toggle_ability_buy_block), 2 SECONDS)
				return
			var/action_path = get_suit_ability(ability)
			actions_types += action_path
			var/datum/action/ninja_action = new action_path(src, action_icon[action_path], action_icon_state[action_path])
			ninja_action.Grant(usr)
			if(istype(ninja_action, /datum/action/item_action/advanced/ninja/ninja_smoke_bomb))
				actions_types += /datum/action/item_action/advanced/ninja/ninja_smoke_bomb_toggle_auto
				var/datum/action/item_action/advanced/ninja/ninja_smoke_bomb_toggle_auto/smoke_toggle = new(src)
				smoke_toggle.Grant(usr)
				smoke_toggle.action_ready = FALSE
				smoke_toggle.toggle_button_on_off()
				auto_smoke = TRUE
			if(istype(ninja_action, /datum/action/item_action/advanced/ninja/ninjaboost))
				a_boost = ninja_action
			if(istype(ninja_action, /datum/action/item_action/advanced/ninja/ninjaheal))
				heal_chems = ninja_action
			ninja.mind.ninja.purchased_abilities += "<BIG>[bicon(ability_icon)]</BIG>"
			addtimer(CALLBACK(src, .proc/toggle_ability_buy_block), 2 SECONDS)
		if("move")
			var/destination = params["move"]
			if(!options.Find(destination))
				message_admins("[span_boldannounce("EXPLOIT: [ADMIN_LOOKUPFLW(usr)]")] attempted to move [shuttle_controller.shuttleId] to an invalid location! [ADMIN_COORDJMP(src)]")
				return
			switch(SSshuttle.moveShuttle(shuttle_controller.shuttleId, destination, TRUE, usr))
				if(0)
					atom_say("Шаттл отправляется!")
					usr.create_log(MISC_LOG, "remotedly used [shuttle_controller] to call the [shuttle_controller.shuttleId] shuttle")
					if(!shuttle_controller.moved)
						shuttle_controller.moved = TRUE
					add_fingerprint(usr)
					return TRUE
				if(1)
					to_chat(usr, span_warning("Invalid shuttle requested."))
				else
					to_chat(usr, span_notice("Unable to comply."))

/obj/item/clothing/suit/space/space_ninja/proc/toggle_ability_buy_block()
	return bying_ability = bying_ability ? FALSE : TRUE

//Обновляет отправляемый в TGUI спрайт для превью костюма
/obj/item/clothing/suit/space/space_ninja/proc/update_TGUI_style_preview()
	var/scarf_or_hood = preferred_scarf_over_hood ? "scarf" : "hood"
	if(preferred_clothes_gender == "female")
		style_preview_icon_state = "ninja_preview_[design_choice]_[scarf_or_hood]_[scarf_or_hood == "scarf" ? "[scarf_design_choice]_" : "" ][color_choice]_f"
	else
		style_preview_icon_state = "ninja_preview_[design_choice]_[scarf_or_hood]_[scarf_or_hood == "scarf" ? "[scarf_design_choice]_" : "" ][color_choice]"

/obj/item/clothing/suit/space/space_ninja/proc/get_suit_ability(var/ability)
	if(!ability)
		return
	var/return_ability_type
	switch(ability)
		if("ninja_cloak")
			return_ability_type = /datum/action/item_action/advanced/ninja/ninja_stealth
		if("shuriken")
			return_ability_type = /datum/action/item_action/advanced/ninja/toggle_shuriken_fire_mode
		if("ninja_spirit_form")
			return_ability_type = /datum/action/item_action/advanced/ninja/ninja_spirit_form
		if("chameleon")
			return_ability_type = /datum/action/item_action/advanced/ninja/ninja_chameleon
		if("kunai")
			return_ability_type = /datum/action/item_action/advanced/ninja/johyo
		if("smoke")
			return_ability_type = /datum/action/item_action/advanced/ninja/ninja_smoke_bomb
		if("adrenal")
			return_ability_type = /datum/action/item_action/advanced/ninja/ninjaboost
		if("energynet")
			return_ability_type = /datum/action/item_action/advanced/ninja/ninjanet
		if("emergency_blink")
			return_ability_type = /datum/action/item_action/advanced/ninja/ninja_emergency_blink
		if("ninja_clones")
			return_ability_type = /datum/action/item_action/advanced/ninja/ninja_clones
		if("emp")
			return_ability_type = /datum/action/item_action/advanced/ninja/ninjapulse
		if("chem_injector")
			return_ability_type = /datum/action/item_action/advanced/ninja/ninjaheal
		if("caltrop")
			return_ability_type = /datum/action/item_action/advanced/ninja/ninja_caltrops
	return return_ability_type

