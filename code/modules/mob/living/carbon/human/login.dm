/mob/living/carbon/human/Login()
	..()

	if(species && species.ventcrawler)
		src << "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>"
	update_pipe_vision()
	update_hud()
	if(ticker && ticker.mode)
		ticker.mode.update_all_synd_icons()	//This proc only sounds CPU-expensive on paper. It is O(n^2), but the outer for-loop only iterates through syndicates, which are only prsenet in nuke rounds and even when they exist, there's usually 6 of them.
	return
