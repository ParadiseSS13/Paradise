// TGUI Vial slot's scan state's
#define NINJA_BLOODSCAN_FAILED 0
#define NINJA_BLOODSCAN_SUCCESSFULL 1
#define NINJA_BLOODSCAN_NOT_DONE 2

// Animation icon_state's defines
#define BSM_ACTIVATION_STATE "Activation"
#define BSM_DEACTIVATION_STATE "Deactivation"
#define BSM_LOADING_STATE "Loading"
#define BSM_WRONG_STATE "Wrong"
#define BSM_CORRECT_STATE "Correct"
/obj/machinery/ninja_bloodscan_machine
	anchored = TRUE
	density = TRUE
	name = "Blood-Scan Machine"
	desc = "A very complex machine designed to scan blood samples on the smallest level. Created by the Spider-Clan to scan the blood of the most otherworldly beasts and creatures."
	tts_seed = "Sorceress"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "BSM_0"
	pixel_x = 4
	pixel_y = 10
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | NO_MALF_EFFECT
	layer = ABOVE_MOB_LAYER
	var/list/blood_samples = list()
	var/list/vials = list()
	// Registered ninja that has the required objective
	var/mob/living/carbon/human/ninja
	// Our "collect blood" objective
	var/datum/objective/collect_blood/objective
	// Mind's from the sample's for the checks
	var/list/samples_mind_list = list()
	// Blocks TGUI buttons
	var/TGUI_blocked = FALSE
	// Self-Explanatory. goes from 0 to 100
	// If 0 no progress bar can be seen in TGUI
	var/TGUI_progress_bar = 0
	// Info about our vial slots scan state. Affects TGUI.
	var/list/scan_state = list(
		NINJA_BLOODSCAN_NOT_DONE,
		NINJA_BLOODSCAN_NOT_DONE,
		NINJA_BLOODSCAN_NOT_DONE)
	// atom_say spam prevention
	var/antispam_cd = 2 SECONDS
	var/last_say = null

/obj/machinery/ninja_bloodscan_machine/Initialize()
	. = ..()
	last_say = world.time

/obj/machinery/ninja_bloodscan_machine/Destroy()
	clear_important_vars(hard_clear = TRUE)
	. = ..()

/obj/machinery/ninja_bloodscan_machine/attack_hand(mob/user)
	if(..(user))
		return
	add_fingerprint(user)
	if(!isninja(user))
		to_chat(user, span_boldwarning("ERROR!!! UNAUTORISED USER!!!"))
		return
	if(!objective || user != ninja)
		var/temp_objective = locate(/datum/objective/collect_blood) in user.mind.objectives
		if(!temp_objective)
			to_chat(user, span_boldwarning("Your clan does not need you to collect and scan any samples right now."))
			return
		objective = temp_objective
		ninja = user
		to_chat(user, span_boldwarning("User: [ninja.real_name] registered. Ready to scan."))
	if(objective.completed)
		to_chat(user, span_info("Your mission is over, you don't need to use this machine anymore"))
		return
	ui_interact(user)

/obj/machinery/ninja_bloodscan_machine/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!isninja(user))
		to_chat(user, span_boldwarning("ERROR!!! UNAUTORISED USER!!!"))
		return
	if(!objective || user != ninja)
		to_chat(user, span_boldwarning("The machine won't accept any samples without a registered user. Please touch the machine's hand-scan terminal, to proceed forward."))
		return
	if(objective.completed)
		to_chat(user, span_info("Your mission is over, you don't need to use this machine anymore"))
		return
	if(istype(I, /obj/item/reagent_containers/glass/beaker))
		if(!istype(I, /obj/item/reagent_containers/glass/beaker/vial))
			to_chat(user, span_boldwarning("This machine only accept's small vial's. Beaker's won't fit."))
			return
		var/obj/item/reagent_containers/glass/beaker/vial/blood_vial = I
		if(!length(blood_vial.reagents.reagent_list))
			to_chat(user, span_info("Vial is empty..."))
			return
		var/datum/reagent/blood/blood_sample = locate(/datum/reagent/blood) in blood_vial.reagents.reagent_list
		if(!istype(blood_sample) || length(blood_vial.reagents.reagent_list) > 1)
			to_chat(user, span_boldwarning("The machine won't accept any other reagent's than the one prescribed by the clan. Which in your case is [span_redtext("BLOOD")]!"))
			return
		user.drop_item()
		blood_vial.forceMove(src)
		vials += blood_vial
		blood_samples += blood_sample
		update_state_icon()
		to_chat(user, span_info("You place [blood_vial] in the machine."))
		return

/obj/machinery/ninja_bloodscan_machine/proc/start_scan()
	if(!blood_samples || !vials)
		handle_say("Ошибка! В устройстве нет образцов!")
		return
	if(length(blood_samples) != 3 || length(vials) != 3)
		handle_say("Ошибка! Недостаточно образцов!")
		return
	TGUI_blocked = TRUE
	update_state_icon(BSM_ACTIVATION_STATE)
	addtimer(CALLBACK(src, .proc/update_state_icon, BSM_LOADING_STATE), 3 SECONDS)
	addtimer(CALLBACK(src, .proc/scan_blood_sample_recursive), 3 SECONDS)

/obj/machinery/ninja_bloodscan_machine/proc/scan_blood_sample_recursive(iterator = 1)
	var/obj/item/reagent_containers/glass/beaker/vial/blood_vial = vials[iterator]
	var/datum/reagent/blood/sample_blood = blood_samples[iterator]
	var/datum/mind/sample_mind = sample_blood.data["mind"]
	if(sample_mind in samples_mind_list)
		scan_state[iterator] = NINJA_BLOODSCAN_FAILED
		handle_say("Ошибка! Два или более одинаковых образца! Замените образец номер [iterator] на уникальный!")
		clear_important_vars()
		update_state_icon(BSM_WRONG_STATE)
		addtimer(CALLBACK(src, .proc/update_state_icon, BSM_DEACTIVATION_STATE), 3 SECONDS)
		addtimer(CALLBACK(src, .proc/update_state_icon), 6 SECONDS)
		return
	//vial naming, for in game convenience
	blood_vial.name = "[initial(blood_vial.name)] Образец: [sample_blood.data["real_name"]]"
	TGUI_progress_bar = clamp(TGUI_progress_bar + rand(0, 30), 0, 90)
	samples_mind_list += sample_blood.data["mind"]
	if(!sample_mind)
		scan_state[iterator] = NINJA_BLOODSCAN_FAILED
		handle_say("Ошибка! Образец [iterator] принадлежит слишком примитивному или лишённому самосознания существу!")
		clear_important_vars()
		update_state_icon(BSM_WRONG_STATE)
		addtimer(CALLBACK(src, .proc/update_state_icon, BSM_DEACTIVATION_STATE), 3 SECONDS)
		addtimer(CALLBACK(src, .proc/update_state_icon), 6 SECONDS)
		return
	if(istype(sample_mind.vampire))
		scan_state[iterator] = NINJA_BLOODSCAN_SUCCESSFULL
	else
		scan_state[iterator] = NINJA_BLOODSCAN_FAILED
		handle_say("Оповещение! Образец номер [iterator] не принадлежит вампиру!")
	if(iterator != 3)
		addtimer(CALLBACK(src, .proc/scan_blood_sample_recursive, iterator+1), 5 SECONDS)
	else
		TGUI_progress_bar = 99
		addtimer(CALLBACK(src, .proc/end_samples_scan), 5 SECONDS)

/obj/machinery/ninja_bloodscan_machine/proc/end_samples_scan()
	if(length(samples_mind_list) == 3)
		for(var/datum/mind/vamp_mind in samples_mind_list)
			if(!istype(vamp_mind.vampire))
				handle_say("Сканирование окончено! Некоторые образцы не подходят. Продолжайте поиск.")
				clear_important_vars()
				update_state_icon(BSM_WRONG_STATE)
				addtimer(CALLBACK(src, .proc/update_state_icon, BSM_DEACTIVATION_STATE), 3 SECONDS)
				addtimer(CALLBACK(src, .proc/update_state_icon), 6 SECONDS)
				return
		objective.completed = TRUE
		scan_state = list(
		NINJA_BLOODSCAN_NOT_DONE,
		NINJA_BLOODSCAN_NOT_DONE,
		NINJA_BLOODSCAN_NOT_DONE) // initial() for some reason fully clears the list
		update_state_icon(BSM_CORRECT_STATE)
		addtimer(CALLBACK(src, .proc/update_state_icon, BSM_DEACTIVATION_STATE), 3 SECONDS)
		addtimer(CALLBACK(src, .proc/clear_important_vars, FALSE, TRUE), 8 SECONDS)
		addtimer(CALLBACK(src, .proc/update_state_icon), 9 SECONDS)
		addtimer(CALLBACK(src, .proc/handle_powerUps), 9 SECONDS)
		addtimer(CALLBACK(src, .proc/handle_say, "Сканирование успешно! Задача выполнена. Реагенты извлечены..."), 10 SECONDS)

/obj/machinery/ninja_bloodscan_machine/proc/clear_important_vars(hard_clear = FALSE, clear_vials = FALSE)
	TGUI_progress_bar = 0
	TGUI_blocked = FALSE
	samples_mind_list.Cut()
	if(clear_vials || hard_clear)
		for(var/obj/item/reagent_containers/glass/beaker/vial/vial in vials)
			vial.forceMove(get_turf(src))
		vials.Cut()
		blood_samples.Cut()
		update_state_icon()
	if(hard_clear)
		ninja = null
		objective = null

// Turns on the suit anti-vampire power up's
/obj/machinery/ninja_bloodscan_machine/proc/handle_powerUps()
	var/obj/item/clothing/glasses/ninja/ninja_visor = ninja.glasses
	var/obj/item/clothing/suit/space/space_ninja/ninja_suit = ninja.wear_suit
	if(istype(ninja_visor))
		to_chat(ninja, span_info("<B>На вашем визоре внезапно появляется новая инструкция... \
		Кажется теперь защита от света так же защитит вас и от взгляда вампира!</B>"))
		ninja_visor.vamp_protection_active = TRUE
	if(istype(ninja_suit))
		to_chat(ninja, span_info("<B>В ваш костюм были загружены новые скрипты... \
		Судя по их описанию они содержат инструкции благодаря которым костюм сможет \
		частично защитить вас от некоторых способностей вампиров!</B>"))
		ninja_suit.vamp_protection_active = TRUE
	return

/obj/machinery/ninja_bloodscan_machine/proc/handle_eject_vial(vial_num)
	var/obj/item/reagent_containers/glass/beaker/vial/blood_vial = vials[vial_num]
	if(!istype(blood_vial))
		return
	vials -= blood_vial
	var/datum/reagent/blood/sample_blood = blood_samples[vial_num]
	blood_samples -= sample_blood
	blood_vial.forceMove(get_turf(src))
	scan_state[vial_num] = NINJA_BLOODSCAN_NOT_DONE
	update_state_icon()

/obj/machinery/ninja_bloodscan_machine/proc/handle_say(text)
	if(world.time > last_say + antispam_cd)
		atom_say(text)
		last_say = world.time

//Animations and states
/obj/machinery/ninja_bloodscan_machine/proc/update_state_icon(state = null)
	if(!blood_samples || !vials)
		icon_state = initial(icon_state)
		return
	if(!state)
		icon_state = "BSM_[clamp(length(vials), 0, 3)]"
	else
		icon_state = "BSM_[state]"

/obj/machinery/ninja_bloodscan_machine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "NinjaBloodScan", name, 500, 400, master_ui, state)
		ui.open()

/obj/machinery/ninja_bloodscan_machine/ui_data(mob/user)
	var/list/data = list()
	//Иконки виалов
	var/list/vial_icons = list()
	for(var/obj/item/reagent_containers/glass/beaker/vial/blood_vial in vials)
		var/icon/vial_icon = getFlatIcon(blood_vial, no_anim = TRUE)
		vial_icons += icon2base64(vial_icon)
	var/icon/no_vial_icon = icon('icons/obj/chemical.dmi', "vial", SOUTH, frame = 1)
	data["vialIcons"] = vial_icons
	data["noVialIcon"] = icon2base64(no_vial_icon)
	//Имена обладателей крови
	var/list/blood_owner_names = list()
	var/list/blood_owner_species = list()
	var/list/blood_owner_types = list()
	if(blood_samples)
		for(var/datum/reagent/blood/sample_blood in blood_samples)
			if(sample_blood.data)
				blood_owner_names += sample_blood.data["real_name"]
				blood_owner_species += sample_blood.data["blood_species"]
				blood_owner_types += sample_blood.data["blood_type"]
			else
				blood_owner_names += "Bad Sample"
				blood_owner_species += "Bad Sample"
				blood_owner_types += "Bad Sample"
	data["bloodOwnerNames"] = blood_owner_names
	data["bloodOwnerSpecies"] = blood_owner_species
	data["bloodOwnerTypes"] = blood_owner_types
	data["blockButtons"] = TGUI_blocked
	data["scanStates"] = scan_state
	data["progressBar"] = TGUI_progress_bar
	return data

/obj/machinery/ninja_bloodscan_machine/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("vial_out")
			var/vial_num = text2num(params["button_num"])
			var/obj/item/reagent_containers/glass/beaker/vial/blood_vial
			if(length(vials) >= vial_num)
				blood_vial = vials[vial_num]
			if(istype(blood_vial))
				handle_eject_vial(vial_num)
				return
			else
				var/mob/living/carbon/human/ninja = usr
				if(!istype(ninja))
					return
				var/obj/item/I = ninja.get_active_hand()
				if(!I)
					return
				attackby(I, ninja)
			return
		if("scan_blood")
			start_scan()
			return

#undef NINJA_BLOODSCAN_FAILED
#undef NINJA_BLOODSCAN_SUCCESSFULL
#undef NINJA_BLOODSCAN_NOT_DONE

#undef BSM_ACTIVATION_STATE
#undef BSM_DEACTIVATION_STATE
#undef BSM_LOADING_STATE
#undef BSM_WRONG_STATE
#undef BSM_CORRECT_STATE
