/obj/machinery/r_n_d/server/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || drain_act_protected)
		return INVALID_DRAIN
	if(stat & NOPOWER)
		to_chat(usr, "The server has no power!")
		return
	if(stat & BROKEN)
		to_chat(usr, "The server is broken!")
		return
	var/datum/mind/ninja_mind = ninja.mind
	if(!ninja_mind)
		return INVALID_DRAIN
	var/datum/objective/research_corrupt/objective = locate() in ninja_mind.objectives
	if(!objective)
		return INVALID_DRAIN
	if(objective.completed)
		to_chat(ninja, span_warning("Вы уже заразили их системы вирусом. Повторная установка ничего не даст!"))
		return INVALID_DRAIN
	if(!istype(get_area(src), /area/toxins/server))
		to_chat(usr, span_warning("Этот сервер, не используется станцией для хранения данных. Вирус не возымеет эффекта!"))
		return INVALID_DRAIN

	. = DRAIN_RD_HACK_FAILED

	to_chat(ninja, span_notice("Данные об исследованиях обнаружены. Установка вируса..."))
	AI_notify_hack()
	if(do_after(ninja, 60 SECONDS, target = src))
		if(stat & NOPOWER)
			to_chat(usr, "The server has no power!")
			return
		if(stat & BROKEN)
			to_chat(usr, "The server is broken!")
			return

		ninja_suit.spark_system.start()
		playsound(loc, "sparks", 50, TRUE, 5)
		var/datum/tech/current_tech
		var/datum/design/current_design
		//Удаление данных у серверов
		for(var/obj/machinery/r_n_d/server/rnd_server in GLOB.machines)
			if(!is_station_level(rnd_server.z))
				continue
			if(rnd_server.disabled)
				continue
			if(rnd_server.syndicate)
				continue
			for(var/i in rnd_server.files.known_tech)
				current_tech = rnd_server.files.known_tech[i]
				current_tech.level = 1
			for(var/j in rnd_server.files.known_designs)
				current_design = rnd_server.files.known_designs[j]
				rnd_server.files.known_designs -= current_design.id
			investigate_log("[key_name_log(ninja)] deleted all technology on this server.", INVESTIGATE_RESEARCH)

		//Удаление данных у консолей
		for(var/obj/machinery/computer/rdconsole/rnd_console in GLOB.machines)
			if(!is_station_level(rnd_console.z))
				continue
			for(var/i in rnd_console.files.known_tech)
				current_tech = rnd_console.files.known_tech[i]
				current_tech.level = 1
			for(var/j in rnd_console.files.known_designs)
				current_design = rnd_console.files.known_designs[j]
				rnd_console.files.known_designs -= current_design.id
			investigate_log("[key_name_log(ninja)] deleted all technology on this console.", INVESTIGATE_RESEARCH)
		//Фабрикаторы
		for(var/obj/machinery/mecha_part_fabricator/rnd_mechfab in GLOB.machines)
			if(!is_station_level(rnd_mechfab.z))
				continue
			for(var/i in rnd_mechfab.local_designs.known_tech)
				current_tech = rnd_mechfab.local_designs.known_tech[i]
				current_tech.level = 1
			for(var/j in rnd_mechfab.local_designs.known_designs)
				current_design = rnd_mechfab.local_designs.known_designs[j]
				rnd_mechfab.local_designs.known_designs -= current_design.id
			investigate_log("[key_name_log(ninja)] deleted all technology on this fabricator.", INVESTIGATE_RESEARCH)
		to_chat(ninja, span_notice("Установка успешна! Все исследования станции были стёрты."))
		objective.completed = TRUE
