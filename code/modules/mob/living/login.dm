/mob/living/Login()
	..()
	//Mind updates
	sync_mind()
	update_stat("mob login")
	update_sight()

	var/turf/T = get_turf(src)
	if(isturf(T))
		update_z(T.z)

	//If they're SSD, remove it so they can wake back up.
	player_logged = 0
	//Vents
	if(ventcrawler)
		to_chat(src, SPAN_NOTICE("You can ventcrawl! Use alt+click on vents to quickly travel about the station."))

	if(ranged_ability)
		ranged_ability.add_ranged_ability(src, SPAN_NOTICE("You currently have <b>[ranged_ability]</b> active!"))

	//Should update regardless of if we can ventcrawl, since we can end up in pipes in other ways.
	update_pipe_vision(loc)
