SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE


/datum/controller/subsystem/title/Initialize()
	var/file_path = "config/title_screens/images/screens.dmi"
	var/icon/icon = new(fcopy_rsc(file_path))
	var/splashscreen = "[rand(1,2)]"

	for(var/turf/simulated/wall/indestructible/splashscreen/splash in world)
		splash.icon = icon
		splash.icon_state = splashscreen
		if(splashscreen == "1" || splashscreen == "2")
			splash.name = "by Reshig"

