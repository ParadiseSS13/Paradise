SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE


/datum/controller/subsystem/title/Initialize()
	create_title_screen()


/datum/controller/subsystem/title/proc/create_title_screen(mob/user)
	. = FALSE

	var/list/provisional_title_screens = flist("config/title_screens/images/")
	var/list/title_screens = list()
	var/use_rare_screens = user || prob(1)

	for(var/S in provisional_title_screens)
		var/list/L = splittext(S,"+")
		if(L.len == 1 && L[1] != "blank.png")
			title_screens += S

		else if(L.len > 1)
			if(use_rare_screens && lowertext(L[1]) == "rare")
				title_screens += S
			else if(SSmapping.map_datum && (lowertext(L[1]) == lowertext(SSmapping.map_datum.name)))
				title_screens += S

	if(!isemptylist(title_screens))
		if(!user && length(title_screens) > 1)
			for(var/S in title_screens)
				var/list/L = splittext(S,".")
				if(L.len != 2 || L[1] != "default")
					continue
				title_screens -= S
				break

		. = TRUE

		var/choice
		if(user)
			choice = input(user, "Choose new title screen", "Available Screens:") as null|anything in title_screens
			if(!choice)
				return FALSE
		else
			choice = pick(title_screens)

		var/file_path = "config/title_screens/images/[choice]"
		var/icon/icon = new(fcopy_rsc(file_path))

		for(var/turf/simulated/wall/indestructible/splashscreen/splash in world)

			if(splash.current_screen)
				QDEL_NULL(splash.current_screen)

			var/obj/effect/abstract/new_screen = new(splash)
			new_screen.invisibility = NONE
			new_screen.layer = splash.layer + 0.1
			new_screen.icon = icon
			new_screen.name = "Fancy Screen"
			splash.current_screen = new_screen

			// Below operations are needed to centrally place the new splashscreen on the lobby area
			new_screen.pixel_x = -((icon.Width() - world.icon_size) / 2)
			new_screen.pixel_y = -((icon.Height() - world.icon_size) / 2)

