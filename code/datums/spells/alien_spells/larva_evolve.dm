// Make this reflect amount grown, can't do that currently
/datum/spell/alien_spell/evolve_larva
	name = "Evolve."
	desc = "Evolve into a fully grown Alien."
	action_icon_state = "alien_evolve_larva"

/datum/spell/alien_spell/evolve_larva/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/alien_spell/evolve_larva/cast(list/targets, mob/living/carbon/alien/larva/user)
	if(user.stat != CONSCIOUS)
		return

	if(user.handcuffed || user.legcuffed)
		to_chat(user, "<span class='warning'>You cannot evolve when you are cuffed.</span>")
		return

	if(user.amount_grown < user.max_grown)
		to_chat(user, "<span class='warning'>You are not fully grown.</span>")
		return
	//green is impossible to read, so i made these blue and changed the formatting slightly
	to_chat(user, "<span class='boldnotice'>You are growing into a beautiful alien! It is time to choose a caste.</span>")
	to_chat(user, "<span class='notice'>There are three to choose from:</span>")
	to_chat(user, "<B>Hunters</B> <span class='notice'>are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves.</span>")
	to_chat(user, "<B>Sentinels</B> <span class='notice'>are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters.</span>")
	to_chat(user, "<B>Drones</B> <span class='notice'>are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen.</span>")
	var/static/list/to_evolve = list("Hunter" = image(icon = 'icons/mob/alien.dmi', icon_state = "alienh_s"),
								"Sentinel" = image(icon = 'icons/mob/alien.dmi', icon_state = "aliens_s"),
								"Drone" = image(icon = 'icons/mob/alien.dmi', icon_state = "aliend_s"))
	var/new_xeno = show_radial_menu(user, user, to_evolve, src, radius = 40)
	var/turf/T = user.loc
	if(!new_xeno)
		return
	var/to_spawn
	switch(new_xeno)
		if("Hunter")
			to_spawn = new /mob/living/carbon/alien/humanoid/hunter(T)
		if("Sentinel")
			to_spawn = new /mob/living/carbon/alien/humanoid/sentinel(T)
		if("Drone")
			to_spawn = new /mob/living/carbon/alien/humanoid/drone(T)
	if(user.mind)
		user.mind.transfer_to(to_spawn)
	SSblackbox.record_feedback("tally", "alien_growth", 1, "[lowertext(new_xeno)]")
	qdel(user)
