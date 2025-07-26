SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE

/datum/controller/subsystem/title/Initialize()
	var/list/provisional_title_screens = flist("config/title_screens/images/")
	var/list/title_screens = list()
	var/use_rare_screens = prob(1)

	for(var/S in provisional_title_screens)
		var/list/L = splittext(S,"+")
		if(length(L) == 1 && L[1] != "blank.png")
			title_screens += S

		else if(length(L) > 1)
			if(use_rare_screens && lowertext(L[1]) == "rare")
				title_screens += S

	if(!isemptylist(title_screens))
		if(length(title_screens) > 1)
			for(var/S in title_screens)
				var/list/L = splittext(S,".")
				if(length(L) != 2 || L[1] != "default")
					continue
				title_screens -= S
				break

		var/file_path = "config/title_screens/images/[pick(title_screens)]"
		log_debug("Loading title screen from '[file_path]'.")

		var/icon/icon = new(fcopy_rsc(file_path))

		GLOB.title_splash.icon = icon
		// Below operations are needed to centrally place the new splashscreen on the lobby area
		GLOB.title_splash.pixel_x = -((icon.Width() - world.icon_size) / 2)
		GLOB.title_splash.pixel_y = -((icon.Height() - world.icon_size) / 2)
