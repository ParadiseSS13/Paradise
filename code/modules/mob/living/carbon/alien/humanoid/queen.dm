/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 275
	health = 275
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	heal_rate = 5
	large = 1
	ventcrawler = 0
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.
	can_grab_facehuggers = TRUE

	amount_grown = 0
	max_grown = 300

/mob/living/carbon/alien/humanoid/queen/New()
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in GLOB.alive_mob_list)
		if(Q == src)
			continue
		if(Q.stat == DEAD)
			continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/queen
	alien_organs += new /obj/item/organ/internal/xenos/acidgland/large
	alien_organs += new /obj/item/organ/internal/xenos/eggsac
	alien_organs += new /obj/item/organ/internal/xenos/resinspinner
	alien_organs += new /obj/item/organ/internal/xenos/neurotoxin
	..()

/mob/living/carbon/alien/humanoid/queen/movement_delay()
	. = ..()
	. += 2

/mob/living/carbon/alien/humanoid/queen/can_inject(mob/user, error_msg, target_zone, penetrate_thick)
	return FALSE

//Queen verbs
/mob/living/carbon/alien/humanoid/queen/verb/lay_egg()

	set name = "Lay Egg (75)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"
	if(locate(/obj/structure/alien/egg) in get_turf(src))
		to_chat(src, "<span class='noticealien'>There's already an egg here.</span>")
		return

	if(powerc(75,1))//Can't plant eggs on spess tiles. That's silly.
		adjustPlasma(-75)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span class='alertalien'>[src] has laid an egg!</span>"), 1)
		new /obj/structure/alien/egg(loc)
	return


/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "queen_s"
	pixel_x = -16
	large = 1

/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	overlays.Cut()

	if(stat == DEAD)
		icon_state = "queen_dead"
	else if(stat == UNCONSCIOUS || lying || resting)
		icon_state = "queen_sleep"
	else
		icon_state = "queen_s"

	for(var/image/I in overlays_standing)
		overlays += I

/mob/living/carbon/alien/humanoid/queen/verb/evolve()
	set name = "Evolve (500)"
	set desc = "Evolve into an Empress."
	set category = "Alien"

	if(stat != CONSCIOUS)
		return

	if(handcuffed || legcuffed)
		to_chat(src, "<span class='warning'>You cannot evolve when you are cuffed.</span>")

	if(amount_grown >= max_grown && powerc(500))
		to_chat(src, "<span class='boldnotice'>You are able to grow into an Empress!</span>")
		to_chat(src, "<B>Empresses</B> <span class='notice'>are slow and tough, as well as powerful in combat, capable of spitting like Sentinels and tanking an insane number of hits.</span>")
		var/alien_caste = alert(src, "Do you want to evolve into an Empress?","Evolve","Yes","No")

		var/mob/living/carbon/alien/humanoid/new_xeno
		switch(alien_caste)
			if("Yes")
				adjustPlasma(-500)
				new_xeno = new /mob/living/carbon/alien/humanoid/empress(loc)
				to_chat(src, "<span class='boldnotice'>You twist and contort, changing shape into an Empress!</span>")
		if(mind)
			mind.transfer_to(new_xeno)
		else
			new_xeno.key = key
		new_xeno.mind.name = new_xeno.name
		qdel(src)
		return
	else
		if(!powerc(500))
			to_chat(src, "<span class='warning'>You do not have enough plasma.</span>")
		else
			to_chat(src, "<span class='warning'>You are not fully grown.</span>")
		return
