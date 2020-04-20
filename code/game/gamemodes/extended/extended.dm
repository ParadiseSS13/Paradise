/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	required_players = 0

/datum/game_mode/announce()
	to_chat(world, "<B>El modo de juego actual es: extended!</B>")
	to_chat(world, "<B>Solo diviertete y rolea!</B>")

/datum/game_mode/extended/pre_setup()
	return 1

/datum/game_mode/extended/post_setup()
	..()
