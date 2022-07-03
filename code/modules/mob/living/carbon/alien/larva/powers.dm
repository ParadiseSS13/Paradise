
/datum/action/innate/xeno_action/hide
	name = "Hide"
	desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	button_icon_state = "alien_hide"

/datum/action/innate/xeno_action/hide/Activate()
	var/mob/living/carbon/alien/host = owner

	if(!IsAvailable())
		to_chat(host, "<span class='noticealien'>You must be conscious to do this.</span>")
		return 0

	if(host.layer != ABOVE_NORMAL_TURF_LAYER)
		host.layer = ABOVE_NORMAL_TURF_LAYER
		host.visible_message("<B>[src] scurries to the ground!</B>", "<span class='noticealien'>You are now hiding.</span>")
	else
		host.layer = MOB_LAYER
		host.visible_message("[src] slowly peeks up from the ground...", "<span class=notice'>You have stopped hiding.</span>")

/datum/action/innate/xeno_action/evolve
	name = "Evolve"
	desc = "Evolve into a fully grown Alien."
	button_icon_state = "alien_evolve_larva"

/datum/action/innate/xeno_action/evolve/Activate()
	var/mob/living/carbon/alien/larva/larva_host = owner

	if(!IsAvailable())
		to_chat(larva_host, "<span class='noticealien'>You must be conscious to do this.</span>")
		return 0
	if(larva_host.amount_grown >= larva_host.max_grown)	//TODO ~Carn
		//green is impossible to read, so i made these blue and changed the formatting slightly
		to_chat(larva_host, "<span class='boldnotice'>You are growing into a beautiful alien! It is time to choose a caste.</span>")
		to_chat(larva_host, "<span class='notice'>There are three to choose from:</span>")
		to_chat(larva_host, "<B>Hunters</B> <span class='notice'>are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves.</span>")
		to_chat(larva_host, "<B>Sentinels</B> <span class='notice'>are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters.</span>")
		to_chat(larva_host, "<B>Drones</B> <span class='notice'>are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen.</span>")
		var/alien_caste = alert(larva_host, "Please choose which alien caste you shall belong to.",,"Hunter","Sentinel","Drone")

		var/mob/living/carbon/alien/humanoid/new_xeno
		switch(alien_caste)
			if("Hunter")
				new_xeno = new /mob/living/carbon/alien/humanoid/hunter(larva_host.loc)
			if("Sentinel")
				new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(larva_host.loc)
			if("Drone")
				new_xeno = new /mob/living/carbon/alien/humanoid/drone(larva_host.loc)
		if(larva_host.mind)
			larva_host.mind.transfer_to(new_xeno)
		else
			new_xeno.key = larva_host.key
		new_xeno.mind.name = new_xeno.name
		qdel(larva_host)
		return
	else
		to_chat(larva_host, "<span class='warning'>You are not fully grown.</span>")
		return
