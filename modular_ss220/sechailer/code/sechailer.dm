GLOBAL_LIST_EMPTY(sechailers)

/datum/action/item_action/dispatch
	name = "Signal Dispatch"
	desc = "Открывает колесо быстрого выбора для сообщения о преступлениях, включая ваше текущее местоположение."
	button_overlay_icon_state = "dispatch"
	button_overlay_icon = 'modular_ss220/sechailer/icons/sechailer.dmi'
	use_itemicon = FALSE

/obj/item/clothing/mask/gas/sechailer
	var/obj/item/radio/radio // For dispatch to work
	var/dispatch_cooldown = 25 SECONDS
	var/on_cooldown = FALSE
	var/emped = FALSE
	var/static/list/available_dispatch_messages = list(
		"502 (Убийство)",
		"101 (Сопротивление Аресту)",
		"308 (Вторжение)",
		"305 (Мятеж)",
		"402 (Нападение на Офицера)")
	actions_types = list(/datum/action/item_action/dispatch, /datum/action/item_action/halt, /datum/action/item_action/adjust, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/hos
	actions_types = list(/datum/action/item_action/dispatch, /datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/warden
	actions_types = list(/datum/action/item_action/dispatch, /datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/swat
	actions_types = list(/datum/action/item_action/dispatch, /datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/blue
	actions_types = list(/datum/action/item_action/dispatch, /datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/Destroy()
	qdel(radio)
	GLOB.sechailers -= src
	. = ..()

/obj/item/clothing/mask/gas/sechailer/Initialize()
	. = ..()
	GLOB.sechailers += src
	radio = new /obj/item/radio(src)
	radio.listening = FALSE
	radio.config(list("Security" = 0))
	radio.follow_target = src

/obj/item/clothing/mask/gas/sechailer/proc/dispatch(mob/user)
	for(var/option in available_dispatch_messages)
		available_dispatch_messages[option] = image(icon = 'modular_ss220/sechailer/icons/menu.dmi', icon_state = option)
	var/message = show_radial_menu(user, src, available_dispatch_messages)
	var/location_name = get_location_name(src, TRUE) // get_location_name works better as Affected says

	if(!message)
		return
	if(on_cooldown)
		var/list/cooldown_info = list("Ожидайте. Система оповещения ")
		if(emped)
			cooldown_info += "в защитном режиме, "
		else
			cooldown_info += "перезаряжается, "
		// Cooldown not updating realtime, and i don't want to rewrite it just for the sake of it
		cooldown_info += "примерное время восстановления: [dispatch_cooldown / 10] секунд."
		to_chat(user, span_notice(cooldown_info.Join()))
		return

	on_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reboot)), dispatch_cooldown)
	// This code if fucking hell, but it works as intended
	for(var/atom/movable/hailer in GLOB.sechailers)
		var/security_channel_found = FALSE
		if(!hailer.loc || !ismob(hailer.loc))
			continue
		// Check if mob has a radio, then check if the radio has the right channels
		for(var/obj/item/radio/my_radio in user)
			for(var/chan in 1 to length(my_radio.channels))
				var/channel_name = my_radio.channels[chan]
				if(channel_name == DEPARTMENT_SECURITY)
					security_channel_found = TRUE
					break
		if(security_channel_found)
			radio.autosay("Центр, Код [message], офицер [user] запрашивает помощь в [location_name].", "Система Оповещения", DEPARTMENT_SECURITY, list(z))
			playsound(hailer.loc, 'modular_ss220/sechailer/sound/dispatch_please_respond.ogg', 55, FALSE)
			break
		else
			to_chat(user, span_warning("Внимание: Невозможно установить соединение с каналом службы безопасности, требуется подключение!"))
			playsound(hailer.loc, 'modular_ss220/sechailer/sound/radio_static.ogg', 30, TRUE)

/obj/item/clothing/mask/gas/sechailer/proc/reboot()
	on_cooldown = FALSE
	emped = FALSE

/obj/item/clothing/mask/gas/sechailer/ui_action_click(mob/user, actiontype)
	. = ..()
	if(actiontype == /datum/action/item_action/dispatch)
		dispatch(user)

/obj/item/clothing/mask/gas/sechailer/emp_act(severity)
	if(on_cooldown)
		return
	on_cooldown = TRUE
	emped = TRUE
	addtimer(CALLBACK(src, PROC_REF(reboot)), dispatch_cooldown)
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		to_chat(user, span_userdanger("Обнаружен электромагнитный импульс, система оповещения отключена для сохранения работоспособности..."))
