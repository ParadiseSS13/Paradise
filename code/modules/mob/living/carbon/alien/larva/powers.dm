
/mob/living/carbon/alien/larva/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"

	if(stat != CONSCIOUS)
		return

	if(layer != ABOVE_NORMAL_TURF_LAYER)
		layer = ABOVE_NORMAL_TURF_LAYER
		visible_message("<B>[src] scurries to the ground!</B>", "<span class='noticealien'>You are now hiding.</span>")
	else
		layer = MOB_LAYER
		visible_message("[src] slowly peeks up from the ground...", "<span class=notice'>You have stopped hiding.</span>")

/mob/living/carbon/alien/larva/verb/evolve()
	set name = "Evolve"
	set desc = "Evolve into a fully grown Alien."
	set category = "Alien"

	if(stat != CONSCIOUS)
		return

	if(handcuffed || legcuffed)
		to_chat(src, "<span class='warning'>You cannot evolve when you are cuffed.</span>")

	if(amount_grown >= max_grown)	//TODO ~Carn
		//green is impossible to read, so i made these blue and changed the formatting slightly
		to_chat(src, "<span class='boldnotice'>You are growing into a beautiful alien! It is time to choose a caste.</span>")
		to_chat(src, "<span class='notice'>There are three to choose from:</span>")
		to_chat(src, "<B>Hunters</B> <span class='notice'>are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves.</span>")
		to_chat(src, "<B>Sentinels</B> <span class='notice'>are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters.</span>")
		to_chat(src, "<B>Drones</B> <span class='notice'>are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen.</span>")
		var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Hunter","Sentinel","Drone")

		var/mob/living/carbon/alien/humanoid/new_xeno
		switch(alien_caste)
			if("Hunter")
				new_xeno = new /mob/living/carbon/alien/humanoid/hunter(loc)
			if("Sentinel")
				new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(loc)
			if("Drone")
				new_xeno = new /mob/living/carbon/alien/humanoid/drone(loc)
		if(mind)
			mind.transfer_to(new_xeno)
		else
			new_xeno.key = key
		new_xeno.mind.name = new_xeno.name
		qdel(src)
		return
	else
		to_chat(src, "<span class='warning'>You are not fully grown.</span>")
		return
