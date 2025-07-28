/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	single_antag_positions = list()

/datum/game_mode/extended/announce()
	to_chat(world, "<B>The current game mode is - Extended Role-Playing!</B>")
	to_chat(world, "<B>Just have fun and role-play!</B>")

/datum/game_mode/extended/pre_setup()
	return 1

/datum/game_mode/extended/post_setup()
	..()
