/hook/startup/proc/setup_title_screen()
	var/list/provisional_title_screens = flist("config/title_screens/images/")
	var/list/title_screens = list()
	var/use_rare_screens = prob(1)

	for(var/S in provisional_title_screens)
		var/list/L = splittext(S,"+")
		if(L.len == 1 && L[1] != "blank.png")
			title_screens += S

		else if(L.len > 1)
			if(use_rare_screens && lowertext(L[1]) == "rare")
				title_screens += S
			else if(GLOB.using_map && (lowertext(L[1]) == lowertext(GLOB.using_map.name)))
				title_screens += S

	if(!isemptylist(title_screens))
		if(length(title_screens) > 1)
			for(var/S in title_screens)
				var/list/L = splittext(S,".")
				if(L.len != 2 || L[1] != "default")
					continue
				title_screens -= S
				break

		var/file_path = "config/title_screens/images/[pick(title_screens)]"

		var/icon/icon = new(fcopy_rsc(file_path))

		for(var/turf/unsimulated/wall/splashscreen/splash in world)
			splash.icon = icon
		return TRUE
	return FALSE
