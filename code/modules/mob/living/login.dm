/mob/living/Login()
	..()
	//Mind updates
	sync_mind()

	//If they're SSD, remove it so they can wake back up.
	player_logged = 0

	//Vents
	if(ventcrawler)
		src << "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>"
	//Should update regardless of if we can ventcrawl, since we can end up in pipes in other ways.
	update_pipe_vision()
	
	update_interface()

	//Round specific stuff like hud updates
	if(ticker && ticker.mode)
		var/ref = "\ref[mind]"
		switch(ticker.mode.name)
			if("revolution")
				if((mind in ticker.mode.revolutionaries) || (src.mind in ticker.mode:head_revolutionaries))
					ticker.mode.update_rev_icons_added(src.mind)
			if("cult")
				if(mind in ticker.mode:cult)
					ticker.mode.update_cult_icons_added(src.mind)
			if("nuclear emergency")
				if(mind in ticker.mode:syndicates)
					ticker.mode.update_all_synd_icons()
			if("mutiny")
				var/datum/game_mode/mutiny/mode = get_mutiny_mode()
				if(mode)
					mode.update_all_icons()
			if("vampire")
				if((ref in ticker.mode.vampire_thralls) || (mind in ticker.mode.vampire_enthralled))
					ticker.mode.update_vampire_icons_added(mind)
			if("shadowling")
				if((mind in ticker.mode.shadowling_thralls) || (mind in ticker.mode.shadows))
					ticker.mode.update_shadow_icons_added(src.mind)
	return .
