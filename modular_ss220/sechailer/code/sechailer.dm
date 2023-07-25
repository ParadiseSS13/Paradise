GLOBAL_LIST_EMPTY(sechailers)

/datum/action/item_action/dispatch
	name = "Signal dispatch"
	desc = "Opens up a quick select wheel for reporting crimes, including your current location, to your fellow security officers."
	button_icon_state = "dispatch"
	icon_icon = 'modular_ss220/sechailer/icons/sechailer.dmi'
	use_itemicon = FALSE

/obj/item/clothing/mask/gas/sechailer
	name = "\improper security gas mask"
	var/obj/item/radio/radio //For engineering alerts.
	var/dispatch_cooldown = 250
	var/last_dispatch = 0
	actions_types = list(/datum/action/item_action/dispatch, /datum/action/item_action/halt, /datum/action/item_action/adjust, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/hos
	name = "\improper head of security's SWAT mask"
	actions_types = list(/datum/action/item_action/dispatch, /datum/action/item_action/halt, /datum/action/item_action/adjust, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/warden
	name = "\improper warden's SWAT mask"
	actions_types = list(/datum/action/item_action/dispatch, /datum/action/item_action/halt, /datum/action/item_action/adjust, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/swat
	actions_types = list(/datum/action/item_action/dispatch, /datum/action/item_action/halt, /datum/action/item_action/adjust, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/blue
	actions_types = list(/datum/action/item_action/dispatch, /datum/action/item_action/halt, /datum/action/item_action/adjust, /datum/action/item_action/selectphrase)

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
	var/area/A = get_area(src)
	if(world.time < last_dispatch + dispatch_cooldown)
		to_chat(user, "<span class='notice'>Dispatch radio broadcasting systems are recharging.</span>")
		return FALSE
	var/list/options = list()
	for(var/option in list("502 (Убийство)", "101 (Сопротивление Аресту)", "308 (Проникновение)", "305 (Мятеж)", "402 (Нападение на Офицера)")) //Just hardcoded for now!
		options[option] = image(icon = 'modular_ss220/sechailer/icons/menu.dmi', icon_state = option)
	var/message = show_radial_menu(user, src, options)
	if(!message)
		return FALSE
	radio.autosay("Диспетчер, [user], код [message] в [A], запрашивается помощь.", src, "Security", list(z))
	last_dispatch = world.time
	for(var/atom/movable/hailer in GLOB.sechailers)
		if(hailer.loc && ismob(hailer.loc))
			playsound(hailer.loc, "modular_ss220/sechailer/sound/dispatch_please_respond.ogg", 100, FALSE)

/obj/item/clothing/mask/gas/sechailer/ui_action_click(mob/user, actiontype)
	. = ..()
	if(actiontype == /datum/action/item_action/dispatch)
		dispatch(user)
