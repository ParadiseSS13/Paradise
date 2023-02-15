//Для тестов. Ибо ждать включения костюма - достало.
/obj/item/clothing/suit/space/space_ninja/proc/admin_on()
	var/mob/living/carbon/human/ninja = loc
	affecting = ninja
	//Блокировка костюма
	lock_suit(ninja)
	//Боевое искусство
	var/datum/martial_art/ninja_martial_art/creeping_widow = new
	ninja_martial = TRUE
	creeping_widow.teach(usr)
	creeping_widow.my_suit = src
	creeping_widow.my_energy_katana = energyKatana
	//Клонёрка
	ninja_clonable = TRUE
	cloning_ref.scan_mob(ninja)
	//Всё остальное
	var/list/ninja_abilities = list(
		"shuriken", "ninja_cloak", "ninja_spirit_form", "chameleon",
		"kunai", "smoke", "adrenal", "energynet", "emergency_blink",
		"ninja_clones", "emp", "chem_injector", "caltrop")
	for(var/ability in ninja_abilities)
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
	//Блокировка покупки в костюме
	for(var/count in 1 to 5)
		blocked_TGUI_rows[count] = TRUE
	//Скин иконок абилок и костюма
	lockIcons(ninja)//Check for icons.
	if(preferred_scarf_over_hood)
		if(!toggle_scarf())
			unlock_suit()
			return
	ninja.regenerate_icons()
	toggle_emp_proof(ninja.bodyparts, TRUE)
	toggle_emp_proof(ninja.internal_organs, TRUE)
	start()
	cell.self_recharge = TRUE
	cell.maxcharge = 50000
	START_PROCESSING(SSobj, cell)
	for(var/datum/action/item_action/advanced/ninja/SpiderOS/ninja_action in actions)
		ninja_action.action_ready = TRUE
		ninja_action.use_action()
		break
/**
 * Toggles the ninja suit on/off
 *
 * Attempts to initialize or deinitialize the ninja suit
 */
/obj/item/clothing/suit/space/space_ninja/proc/toggle_on_off()
	. = TRUE
	if(s_busy)
		to_chat(loc, "[span_warning("ERROR")]: You cannot use this function at this time.")
		return FALSE
	s_busy = TRUE

	if(s_initialized)
		deinitialize()
	else
		s_TGUI_initialized = FALSE
		ninitialize()

/**
 * Initializes the ninja suit
 *
 * Initializes the ninja suit through declared in _ninjaDefines phases, each of which calls this proc with an incremented phase
 * Arguments:
 * * delay - The delay between each phase of initialization
 * * ninja - The human who is being affected by the suit
 * * phase - The phase of initialization
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninitialize(delay = s_delay, mob/living/carbon/human/ninja = loc, phase = 0)
	if(!ninja || !ninja.mind)
		s_busy = FALSE
		return
	if (phase > NINJA_INIT_LOCK_PHASE && (ninja.stat == DEAD || ninja.health <= 0))
		to_chat(ninja, span_danger("<B>FÄAL ï¿½Rrï¿½R</B>: 344--93#ï¿½&&21 BRï¿½ï¿½N |/|/aVï¿½ PATT$RN <B>RED</B>\nA-A-aBï¿½rTï¿½NG..."))
		unlock_suit()
		s_busy = FALSE
		return
	var/message = ninja_initialize_messages[phase + 1]
	current_initialisation_phase = phase + 1
	switch(phase)
		if (NINJA_INIT_LOCK_PHASE)
			if(!lock_suit(ninja))//To lock the suit onto wearer.
				s_busy = FALSE
				suit_tgui_state = NINJA_TGUI_MAIN_SCREEN_STATE
				return
			affecting = ninja
		if (NINJA_INIT_ICON_GENERATE_PHASE)
			lockIcons(ninja)//Check for icons.
			if(preferred_scarf_over_hood)
				if(!toggle_scarf())
					unlock_suit()
					s_busy = FALSE
					suit_tgui_state = NINJA_TGUI_MAIN_SCREEN_STATE
					return
			ninja.regenerate_icons()
		if (NINJA_INIT_MODULES_PHASE)
			var/datum/action/item_action/action
			for(action in ninja.actions)
				if(action.action_initialisation_text)
					message = "Модуль: [action.action_initialisation_text]... ONLINE"
					current_initialisation_text = message
					sleep(10)
			if(ninja_clonable)
				cloning_ref.scan_mob(ninja)
				message = "User has successfully been added to the Revive Machine Database."
		if (NINJA_INIT_COMPLETE_PHASE - 1)
			message += "[cell.charge]"
		if (NINJA_INIT_COMPLETE_PHASE)
			message += "[ninja.real_name]."
			toggle_emp_proof(ninja.bodyparts, TRUE)
			toggle_emp_proof(ninja.internal_organs, TRUE)
			start()
			for(var/datum/action/item_action/advanced/ninja/SpiderOS/ninja_action in actions)
				ninja_action.action_ready = TRUE
				ninja_action.use_action()
				break
			s_busy = FALSE
//	to_chat(ninja, span_notice("[message]"))
	current_initialisation_text = message
	if(phase == NINJA_INIT_COMPLETE_PHASE)
		sleep(10)
		s_TGUI_initialized = TRUE
	playsound(ninja, 'sound/effects/sparks1.ogg', 10, TRUE)
	if (phase < NINJA_INIT_COMPLETE_PHASE)
		addtimer(CALLBACK(src, .proc/ninitialize, delay, ninja, phase + 1), delay)

/**
 * Deinitializes the ninja suit
 *
 * Deinitializes the ninja suit through eight phases, each of which calls this proc with an incremented phase
 * Arguments:
 * * delay - The delay between each phase of deinitialization
 * * ninja - The human who is being affected by the suit
 * * phase - The phase of deinitialization
 */
/obj/item/clothing/suit/space/space_ninja/proc/deinitialize(delay = s_delay, mob/living/carbon/human/ninja = affecting == loc ? affecting : null, phase = 0)
	if (!ninja || !ninja.mind)
		s_busy = FALSE
		return
	if (phase == 0)
		if(alert(usr, "Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No") == "No")
			s_busy = FALSE
			return
		s_TGUI_initialized = FALSE

	var/message = ninja_deinitialize_messages[phase + 1]
	current_initialisation_phase = phase + 1
	switch(phase)
		if(NINJA_DEINIT_LOGOFF_PHASE)
			message = "Выход из системы, [ninja.real_name]. " + message
		if(NINJA_DEINIT_MODULES_PHASE)
			stop()
			if(stealth)
				cancel_stealth()		//Get rid of it.
			if(disguise_active)
				restore_form()			//This count's too
			if(spirited)
				cancel_spirit_form() 	//And another one!
			var/datum/action/item_action/action
			for(action in ninja.actions)
				if(action.action_initialisation_text)
					message = "Модуль: [action.action_initialisation_text]... OFFLINE"
					current_initialisation_text = message
					sleep(10)
			if(ninja_clonable)
				var/ninja_record = cloning_ref.find_record(ckey(ninja.mind.key))
				var/ninja_suit_data = cloning_ref.find_suit_data(ckey(ninja.mind.key))
				cloning_ref.records.Remove(ninja_record)
				cloning_ref.suits_data.Remove(ninja_suit_data)
				message = "User has been successfully deleted from Revive Machine Database. Activate suit to re-add your entry."
		if (NINJA_DEINIT_ICON_REGENERATE_PHASE)
			if(preferred_scarf_over_hood)
				toggle_scarf()
			unlockIcons()
			ninja.regenerate_icons()
		if (NINJA_DEINIT_UNLOCK_PHASE)
			unlock_suit()
		if	(NINJA_DEINIT_COMPLETE_PHASE)
			toggle_emp_proof(ninja.bodyparts, FALSE)
			toggle_emp_proof(ninja.internal_organs, FALSE)
			for(var/datum/action/item_action/advanced/ninja/SpiderOS/ninja_action in actions)
				ninja_action.action_ready = FALSE
				ninja_action.use_action()
				break
			s_busy = FALSE
			affecting = null

//	to_chat(ninja, span_notice("[message]"))
	current_initialisation_text = message

	playsound(ninja, 'sound/items/deconstruct.ogg', 10, TRUE)
	if (phase == NINJA_DEINIT_COMPLETE_PHASE)
		sleep(10)
		s_TGUI_initialized = TRUE
	if (phase < NINJA_DEINIT_COMPLETE_PHASE)
		addtimer(CALLBACK(src, .proc/deinitialize, delay, ninja, phase + 1), delay)

