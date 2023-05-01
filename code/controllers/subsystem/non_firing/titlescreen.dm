SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE

/datum/controller/subsystem/title/Initialize()
	var/file_path = "config/title_screens/images/screens.dmi"
	var/icon/icon = new(fcopy_rsc(file_path))
	var/splashscreen_type = pick(subtypesof(/datum/splashscreen))
	var/datum/splashscreen/S = new splashscreen_type

	for(var/turf/simulated/wall/indestructible/splashscreen/splash in world)
		splash.icon = icon
		splash.icon_state = pick(S.screen_states) // get random artwork from author
		splash.name = "by [S.author]"

/datum/splashscreen
	var/author = ""
	var/list/screen_states = list("reshig1", "reshig2") // sprite names go here

/datum/splashscreen/Reshig
	author = "Reshig"
	screen_states = list("reshig1", "reshig2") // all the sprites by Reshig go here

