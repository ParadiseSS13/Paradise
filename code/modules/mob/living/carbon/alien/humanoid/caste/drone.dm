/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 125
	health = 125
	icon_state = "aliend_s"
	can_grab_facehuggers = TRUE

	amount_grown = 0
	max_grown = 120

/mob/living/carbon/alien/humanoid/drone/New()
	if(src.name == "alien drone")
		src.name = text("alien drone ([rand(1, 1000)])")
	src.real_name = src.name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/drone
	alien_organs += new /obj/item/organ/internal/xenos/acidgland
	alien_organs += new /obj/item/organ/internal/xenos/resinspinner
	..()

//Drones use the same base as generic humanoids.
//Drone verbs

/mob/living/carbon/alien/humanoid/drone/verb/evolve() // -- TLE
	set name = "Evolve (500)"
	set desc = "Produce an interal egg sac capable of spawning children. Only one queen can exist at a time."
	set category = "Alien"

	if(amount_grown >= max_grown && powerc(500))
		// Queen check
		var/no_queen = 1
		for(var/mob/living/carbon/alien/humanoid/queen/Q in GLOB.alive_mob_list)
			if(!Q.key && Q.get_int_organ(/obj/item/organ/internal/brain/))
				continue
			no_queen = 0
		for(var/mob/living/carbon/alien/humanoid/empress/E in GLOB.alive_mob_list)
			if(!E.key && E.get_int_organ(/obj/item/organ/internal/brain/))
				continue
			no_queen = 0

		if(stat != CONSCIOUS)
			return

		if(handcuffed || legcuffed)
			to_chat(src, "<span class='warning'>You cannot evolve when you are cuffed.</span>")

		if(src.has_brain_worms())
			to_chat(src, "<span class='warning'>We cannot perform this ability at the present time!</span>")
			return

		if(amount_grown >= max_grown && no_queen)
			to_chat(src, "<span class='boldnotice'>You are able to grow into a new Queen!</span>")
			to_chat(src, "<B>Queens</B> <span class='notice'>are the backbone of a hive, able to spit like Sentinels and most importantly lay eggs that birth new facehuggers to infect prey.</span>")
			var/alien_caste = alert(src, "Do you want to evolve into a Queen?","Evolve","Yes","No")

			var/mob/living/carbon/alien/humanoid/new_xeno
			switch(alien_caste)
				if("Yes")
					adjustPlasma(-500)
					new_xeno = new /mob/living/carbon/alien/humanoid/queen(loc)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("<span class='alertalien'>[src] begins to twist and contort, changing shape!</span>"), 1)
			if(mind)
				mind.transfer_to(new_xeno)
			else
				new_xeno.key = key
			new_xeno.mind.name = new_xeno.name
			qdel(src)
			return
		else
			if(!no_queen)
				to_chat(src, "<span class='notice'>We already have an alive queen.</span>")
			if(!powerc(250))
				to_chat(src, "<span class='warning'>You do not have enough plasma.</span>")
			else
				to_chat(src, "<span class='warning'>You are not fully grown.</span>")
			return
	return
