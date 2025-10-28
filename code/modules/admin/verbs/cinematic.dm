USER_VERB(show_cinematic, R_MAINTAINER, "Cinematic", "Shows a cinematic.", VERB_CATEGORY_HIDDEN, cinematic as anything in list("explosion", null))
	if(SSticker.current_state < GAME_STATE_PREGAME)
		return

	switch(cinematic)
		if("explosion")
			var/parameter = input(client, "station_missed = ?", "Enter Parameter", 0) as num
			var/override
			switch(parameter)
				if(1)
					override = input(client, "mode = ?","Enter Parameter", null) as anything in list("nuclear emergency", "fake", "no override")
				if(0)
					override = input(client, "mode = ?","Enter Parameter", null) as anything in list("blob", "nuclear emergency", "AI malfunction", "no override")
			SSticker.station_explosion_cinematic(parameter, override)
