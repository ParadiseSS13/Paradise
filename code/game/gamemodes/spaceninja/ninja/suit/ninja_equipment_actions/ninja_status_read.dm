/datum/action/item_action/ninjastatus
	check_flags = NONE
	name = "Status Readout"
	desc = "Gives a detailed readout about your current status."
	use_itemicon = FALSE
	button_icon_state = "healthstatus"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Integrated Health Analizer"
/**
 * Proc called to put a status readout to the ninja in chat.
 *
 * Called put some information about the ninja's current status into chat.
 * This information used to be displayed constantly on the status tab screen
 * when the suit was on, but was turned into this as to remove the code from
 * human.dm
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjastatus()
	var/mob/living/carbon/human/ninja = affecting
	var/list/info_list = list()
	info_list += "[span_info("Статус SpiderOS: [s_initialized ? "Активно" : "Отключено"]")]\n"
	info_list += "[span_info("Текущее время: [station_time_timestamp()]")]\n"
	//Ninja status
	info_list += "[span_info("Отпечатки: [md5(ninja.dna.uni_identity)]")]\n"
	info_list += "[span_info("ДНК: [ninja.dna.unique_enzymes]")]\n"
	info_list += "[span_info("Общее состояние здоровья: [ninja.stat > 1 ? "Мёртв" : "[ninja.health]%"]")]\n"
	info_list += "[span_info("Уровень питательных веществ: [ninja.nutrition]")]\n"
	info_list += "[span_info("Удушение: [ninja.getOxyLoss()]")]\n"
	info_list += "[span_info("Токсины: [ninja.getToxLoss()]")]\n"
	info_list += "[span_info("Ожоги: [ninja.getFireLoss()]")]\n"
	info_list += "[span_info("Физ.: [ninja.getBruteLoss()]")]\n"
	info_list += "[span_info("Температура тела: [ninja.bodytemperature-T0C] градусов C ([ninja.bodytemperature*1.8-459.67] градусов F)")]\n"

	//Diseases
	if(length(ninja.viruses))
		info_list += "[span_info("Вирусы:")]\n"
		for(var/datum/disease/ninja_disease in ninja.viruses)
			info_list += "[span_info("* [ninja_disease.name], Тип: [ninja_disease.spread_text], Стадия: [ninja_disease.stage]/[ninja_disease.max_stages], Возможное лекарство: [ninja_disease.cure_text]")]\n"
	//Реагенты
	if(ninja.reagents.reagent_list.len)
		info_list += "[span_info("Обнаружены реагенты:")]\n"
		for(var/datum/reagent/ninja_reagent in ninja.reagents.reagent_list)
			info_list += "[span_info("&emsp;[ninja_reagent.volume]u [ninja_reagent.name][ninja_reagent.overdosed ? " - [span_boldannounce("ПЕРЕДОЗИРОВКА")]" : "."]")]\n"
	else
		info_list += "[span_info("Реагенты не обнаружены.")]\n"
	if(ninja.reagents.addiction_list.len)
		info_list += "[span_danger("Обнаружены зависимости от реагентов:")]\n"
		for(var/datum/reagent/ninja_reagent in ninja.reagents.addiction_list)
			info_list += "[span_danger("&emsp;[ninja_reagent.name] Стадия: [ninja_reagent.addiction_stage]/5")]\n"
	else
		info_list += "[span_info("Зависимости от реагентов не обнаружены.")]\n"

	to_chat(ninja, "[info_list.Join()]")
