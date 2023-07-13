GLOBAL_LIST_EMPTY(new_player_list)

/mob/new_player/Initialize(mapload)
	GLOB.new_player_list += src
	. = ..()

/mob/new_player/Destroy()
	GLOB.new_player_list -= src
	. = ..()

/mob/new_player/Login()
	. = ..()
	show_title_screen()
