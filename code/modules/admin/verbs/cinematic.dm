USER_VERB(show_cinematic, R_MAINTAINER, "Cinematic", "Shows a cinematic.", VERB_CATEGORY_HIDDEN, cinematic as anything in list("explosion", null))
	if(SSticker.current_state < GAME_STATE_PREGAME)
		return

	switch(cinematic)
		if("explosion")
			var/parameter = wrapped_number_input(client, "station_missed = ?", "Enter Parameter", 0)
			var/override
			switch(parameter)
				if(1)
					override = wrapped_selection_input(client, "mode = ?","Enter Parameter", list("nuclear emergency", "fake", "no override"))
				if(0)
					override = wrapped_selection_input(client, "mode = ?","Enter Parameter", list("blob", "nuclear emergency", "AI malfunction", "no override"))
			SSticker.station_explosion_cinematic(parameter, override)
