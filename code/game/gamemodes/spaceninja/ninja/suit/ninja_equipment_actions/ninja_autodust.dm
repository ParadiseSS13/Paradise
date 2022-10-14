//Automatically dusts ninja if enabled!

/datum/action/item_action/ninja_autodust
	check_flags = NONE
	name = "Auto-Dust"
	desc = "Automatically dusts user if turned on!"
	use_itemicon = FALSE
	button_icon_state = "dust"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Auto-Dust"


/**
 * Proc called to enable/disable autodust.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninja_toggle_autodust()
	var/mob/living/carbon/human/user = src.loc
	if(!auto_dust)
		auto_dust = TRUE
		user.show_message("Вы включили программу [span_warning("\"Автораспыления\"")] текущий режим \
						[health_threshold==-90 ? span_green("\"Обнаружение смерти\"") : span_green("\"Обнаружение критического состояния\"") ]")
		var/choise = alert("Переключить режим?",, "Да","Нет")
		if(choise == "Да")
			if(health_threshold == 0 && auto_dust)
				health_threshold = -90
				user.show_message("Вы переключили программу [span_warning("\"Автораспыления\"")]  в режим <span class='green'>\"Обнаружение смерти\"</span>")
			else if(health_threshold == -90 && auto_dust)
				health_threshold = 0
				user.show_message("Вы переключили программу [span_warning("\"Автораспыления\"")] в режим <span class='green'>\"Обнаружение критического состояния\"</span>")
	else if(auto_dust)
		auto_dust = FALSE
		user.show_message("Вы выключили программу [span_warning("\"Автораспыления\"")]")
	for(var/datum/action/item_action/ninja_autodust/ninja_action in actions)
		toggle_ninja_action_active(ninja_action, auto_dust)
/**
 * Proc called to dust the ninja!
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninja_autodust()
	if(!affecting)	//safety check
		return
	var/mob/living/carbon/human/ninja = affecting
	add_attack_logs(ninja, ninja, "Self-dusted")
	ninja.visible_message(span_warning("[ninja] мгновенно сгорает в ослепительной вспышке!"),span_reallybig("Программа [span_warning("\"Автораспыления\"")] активирована!</span>\n \
																												[span_revenwarning("Стихли все звуки. \n \
																																	Вокруг мёртвая Тишина. \n \
																																	Пепел сакуры... \n")]"))
	for(var/obj/item/I in ninja.contents)
		if(I == src)
			continue
		if(I.flags & NODROP)
			qdel(I)
	ninja.dust()
