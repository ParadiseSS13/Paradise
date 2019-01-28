/mob/living/Login()
	..()
	//Mind updates
	sync_mind()
	update_stat("mob login")
	update_sight()

	//If they're SSD, remove it so they can wake back up.
	player_logged = 0

	//empty the SSD acknowledged list so that players get the SSD warning if you go SSD again
	ssd_acknowledged.Cut()

	//Vents
	if(ventcrawler)
		to_chat(src, "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>")

	if(ranged_ability)
		ranged_ability.add_ranged_ability(src, "<span class='notice'>You currently have <b>[ranged_ability]</b> active!</span>")

	//Should update regardless of if we can ventcrawl, since we can end up in pipes in other ways.
	update_pipe_vision()

	update_interface()

	return .
