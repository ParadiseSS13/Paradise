/obj/machinery/computer/aiupload/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || drain_act_protected)
		return INVALID_DRAIN
	if(src.stat & NOPOWER)
		to_chat(usr, "The upload computer has no power!")
		return
	if(src.stat & BROKEN)
		to_chat(usr, "The upload computer is broken!")
		return

	var/datum/mind/ninja_mind = ninja.mind
	if(!ninja_mind)
		return INVALID_DRAIN

	var/datum/objective/ai_corrupt/objective = locate() in ninja_mind.objectives
	if(!objective)
		return INVALID_DRAIN
	if(objective.completed)
		to_chat(ninja, span_warning("Вы уже заразили их системы вирусом. Повторная установка ничего не даст!"))
		return INVALID_DRAIN
	if(!istype(get_area(src), /area/turret_protected/ai_upload))
		to_chat(usr, span_warning("Консоль в этой зоне не подключена к необходимому бэкдору. Вирус не возымеет эффекта!"))
		return INVALID_DRAIN

	. = DRAIN_RD_HACK_FAILED

	to_chat(ninja, span_notice("Заготовленный бэкдор обнаружен. Установка вируса..."))
	AI_notify_hack()
	if(do_after(ninja, 30 SECONDS, target = src))
		if(src.stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return
		if(src.stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return
		for(var/mob/living/silicon/ai/currentAI in GLOB.alive_mob_list)
			if(currentAI.stat != DEAD && currentAI.see_in_dark != FALSE)
				currentAI.laws.clear_inherent_laws()

		add_attack_logs(ninja, null, "hacked AI upload, causing Ion storms!", ATKLOG_FEW)
		new /datum/event/ion_storm(0, 1)
		new /datum/event/ion_storm(0, -1)
		new /datum/event/ion_storm(0, -1)

		to_chat(ninja, span_notice("Искусственный интеллект станции успешно взломан!"))
		objective.completed = TRUE
