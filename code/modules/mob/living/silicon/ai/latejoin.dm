GLOBAL_LIST_EMPTY(empty_playable_ai_cores)

/mob/living/silicon/ai/verb/wipe_core()
	set name = "Очистка ядра"
	set category = "OOC"
	set desc = "Очищает ваше ядро. функционально такое же, как робо и криохранилище, освобождая слот работы."

	// Guard against misclicks, this isn't the sort of thing we want happening accidentally
	if(tgui_alert(usr, "ВНИМАНИЕ: Это действие незамедлительно очистит ваше ядро и превратит вас в призрака, удаляя вашего персонажа из раунда (похоже на крио и робохранилище). Вы уверены, что хотите это сделать?", "Очистка ядра", list("Нет", "Да")) != "Да")
		return
	cryo_AI()

/mob/living/silicon/ai/proc/cryo_AI()
	var/dead_aicore = new /obj/structure/ai_core/deactivated(loc)
	GLOB.empty_playable_ai_cores += dead_aicore
	GLOB.global_announcer.autosay("[src] был перемещён в хранилище ИИ.", "Система Надзора за ИИ", follow_target_override = dead_aicore)

	//Handle job slot/tater cleanup.
	var/job = mind.assigned_role

	SSjobs.FreeRole(job)

	if(mind.objective_holder.clear())
		mind.special_role = null
	else
		if(SSticker.mode.name == "AutoTraitor")
			var/datum/game_mode/traitor/autotraitor/current_mode = SSticker.mode
			current_mode.possible_traitors.Remove(src)

	for(var/datum/objective/destroy/O in GLOB.all_objectives)
		if(O.target != mind)
			continue
		O.on_target_cryo()

	view_core()
	// Ghost the current player and disallow them to return to the body
	if(TOO_EARLY_TO_GHOST)
		ghostize(FALSE)
	else
		ghostize(TRUE)
	// Delete the old AI shell
	qdel(src)

/mob/living/silicon/ai/proc/moveToAILandmark()
	var/obj/loc_landmark
	for(var/obj/effect/landmark/start/ai/A in GLOB.landmarks_list)
		if(locate(/mob/living) in get_turf(A))
			continue
		loc_landmark = A
	if(!loc_landmark)
		for(var/obj/effect/landmark/tripai in GLOB.landmarks_list)
			if(tripai.name == "tripai")
				if(locate(/mob/living) in get_turf(tripai))
					continue
				loc_landmark = tripai
	if(!loc_landmark)
		to_chat(src, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.") //lol what is this message
		for(var/obj/effect/landmark/start/ai/A in GLOB.landmarks_list)
			loc_landmark = A

	forceMove(get_turf(loc_landmark))
	view_core()

// Before calling this, make sure an empty core exists, or this will no-op
/mob/living/silicon/ai/proc/moveToEmptyCore()
	if(!length(GLOB.empty_playable_ai_cores))
		CRASH("moveToEmptyCore called without any available cores")

	// IsJobAvailable for AI checks that there is an empty core available in this list
	var/obj/structure/ai_core/deactivated/C = GLOB.empty_playable_ai_cores[1]
	GLOB.empty_playable_ai_cores -= C

	forceMove(C.loc)
	view_core()

	qdel(C)
