/mob/living/Login()
	..()
	//Mind updates
	sync_mind()

	//If they're SSD, remove it so they can wake back up.
	player_logged = 0

	//Vents
	if(ventcrawler)
		to_chat(src, "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>")

	//Should update regardless of if we can ventcrawl, since we can end up in pipes in other ways.
	update_pipe_vision()

	update_interface()

	return .
