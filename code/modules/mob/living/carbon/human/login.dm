/mob/living/carbon/human/Login()
	..()

	if(species && species.ventcrawler)
		src << "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>"
	update_pipe_vision()
	update_hud()
	return
