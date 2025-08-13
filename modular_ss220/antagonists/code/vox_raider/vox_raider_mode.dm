/datum/game_mode
	var/list/datum/mind/vox_raiders = list()

/datum/game_mode/antag_mix/vox_raider
	name = "Vox Raiders"
	config_tag = "vox_raiders"
	required_players = 45

/datum/game_mode/antag_mix/vox_raider/New()
	. = ..()
	list_scenarios = list(/datum/antag_scenario/team/vox_raiders)

	var/datum/antag_scenario/antag_datum = /datum/antag_scenario/team/vox_raiders
	required_players = initial(antag_datum.required_players)

/datum/game_mode/antag_mix/vox_raider/announce()
	to_chat(world, "<B>The current game mode is - Vox Raiders!</B>")
	to_chat(world, "Поблизости сектора [world.name] обнаружен корабль <b>воксов</b>!")
	to_chat(world, "<b>Воксы</b> - всей стаей падки на блестяшки и ценности, с ними можно выгодно поторговаться. Но больше ценностей они ценят друг друга.")
	to_chat(world, "<b>Экипаж</b> - следите за воксами внимательно, в том числе и за теми кто на станции, не допустите потерю дорогостоящего оборудования!")
