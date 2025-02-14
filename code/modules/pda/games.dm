// Games Hub

/datum/data/pda/app/games
	name = "Games"
	icon = "gamepad"
	template = "pda_games"

/datum/data/pda/app/games/update_ui(mob/user, list/data)
	var/list/games = list()
	for(var/datum/data/pda/app/game/game in pda.programs)
		games += list(game.get_game_info())
	data["games"] = games

/datum/data/pda/app/games/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("play")
			var/datum/data/pda/app/game/game = locate(params["id"]) in pda.programs
			pda.start_program(game)

// Game-type App

/datum/data/pda/app/game
	name = "base game"
	icon = "gamepad"
	hidden = TRUE

/datum/data/pda/app/game/proc/get_game_info()
	return list(name = name, icon = icon, id = UID())
