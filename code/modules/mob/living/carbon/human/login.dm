/mob/living/carbon/human/Login()
	..()

	if(dna.species && dna.species.ventcrawler)
		to_chat(src, "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>")
	update_pipe_vision()
	return
