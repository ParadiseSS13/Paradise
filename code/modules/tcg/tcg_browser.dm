/// TGUI browser listing every loaded TCG card
/datum/ui_module/tcg_browser
	name = "TCG Card Browser"

/datum/ui_module/tcg_browser/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/tcg_browser/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TCGBrowser", name)
		ui.open()

/datum/ui_module/tcg_browser/ui_static_data(mob/user)
	var/list/data = list()
	var/list/cards = list()
	var/list/series_list = list()
	for(var/series_name in SStrading_card_game.cached_cards)
		series_list += series_name
		var/list/all_cards = SStrading_card_game.cached_cards[series_name]["ALL"]
		for(var/card_id in all_cards)
			var/datum/card/card_data = all_cards[card_id]
			var/image_data
			var/missing_icon = TRUE
			if(card_data.icon_state in icon_states(card_data.icon))
				image_data = icon2base64(icon(card_data.icon, card_data.icon_state, SOUTH, 1))
				missing_icon = FALSE
			cards += list(list(
				"series" = series_name,
				"id" = card_id,
				"name" = card_data.name,
				"desc" = card_data.desc,
				"effect" = card_data.effect,
				"rules" = card_data.rules,
				"rarity" = card_data.rarity,
				"cardtype" = card_data.cardtype,
				"cardsubtype" = card_data.cardsubtype,
				"faction" = card_data.faction,
				"level" = card_data.level,
				"attack" = card_data.attack,
				"defense" = card_data.defense,
				"icon_state" = card_data.icon_state,
				"image" = image_data,
				"missing_icon" = missing_icon
			))
	data["cards"] = cards
	data["series"] = series_list
	return data

/datum/ui_module/tcg_browser/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	if(action == "spawn_card")
		var/series_name = params["series"]
		var/card_id = params["id"]
		if(!SStrading_card_game.get_card(series_name, card_id))
			return
		var/obj/item/tcg_card/spawned = new(get_turf(ui.user), series_name, card_id, TRUE)
		ui.user.put_in_hands(spawned)
		log_and_message_admins("spawned TCG card [card_id] from [series_name].")
		return TRUE

USER_VERB(tcg_card_browser, R_EVENT, "TCG Card Browser", "Browse every loaded Battles of Orion card.", VERB_CATEGORY_EVENT)
	var/datum/ui_module/tcg_browser/browser = new()
	browser.ui_interact(client.mob)
