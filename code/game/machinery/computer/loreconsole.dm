/datum/lore_console_entry
	var/title
	var/body

/datum/lore_console_entry/New(title_ = "", body_)
	title = title_
	body = body_

/obj/machinery/computer/loreconsole
	circuit = /obj/item/circuitboard/nonfunctional
	icon_keyboard = "lore_key"
	icon_screen = "loreconsole"
	light_power_on = 2
	var/list/entries = list()

/obj/machinery/computer/loreconsole/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/loreconsole/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/loreconsole/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LoreConsole", name)
		ui.open()

/obj/machinery/computer/loreconsole/ui_static_data(mob/user)
	var/list/data = list()
	data["entries"] = list()
	for(var/datum/lore_console_entry/entry as anything in entries)
		data["entries"] += list(list("title" = entry.title, "body" = entry.body))

	return data
