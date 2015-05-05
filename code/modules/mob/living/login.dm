
/mob/living/Login()
	..()
	//Mind updates
	sync_mind()

	//If they're SSD, remove it so they can wake back up.
	player_logged = 0

	//login during ventcrawl
	if(istype(loc, /obj/machinery/atmospherics)) //attach us back into the pipes
		remove_ventcrawl()
		add_ventcrawl(loc)

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
				if((ref in ticker.mode.thralls) || (mind in ticker.mode.enthralled))
					ticker.mode.update_vampire_icons_added(mind)
			if("shadowling")
				if((mind in ticker.mode.shadowling_thralls) || (mind in ticker.mode.shadows))
					ticker.mode.update_shadow_icons_added(src.mind)
	return .
