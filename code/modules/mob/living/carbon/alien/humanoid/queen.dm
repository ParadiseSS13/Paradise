/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 250
	health = 250
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	heal_rate = 5
	large = 1
	ventcrawler = 0

/mob/living/carbon/alien/humanoid/queen/New()
	create_reagents(100)

	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in GLOB.living_mob_list)
		if(Q == src)		continue
		if(Q.stat == DEAD)	continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/queen
	alien_organs += new /obj/item/organ/internal/xenos/acidgland
	alien_organs += new /obj/item/organ/internal/xenos/eggsac
	alien_organs += new /obj/item/organ/internal/xenos/resinspinner
	alien_organs += new /obj/item/organ/internal/xenos/neurotoxin
	..()

/mob/living/carbon/alien/humanoid/queen/movement_delay()
	. = ..()
	. += 3

/mob/living/carbon/alien/humanoid/queen/handle_regular_hud_updates()
	..() //-Yvarov

	if(healths)
		if(stat != DEAD)
			switch(health)
				if(250 to INFINITY)
					healths.icon_state = "health0"
				if(175 to 250)
					healths.icon_state = "health1"
				if(100 to 175)
					healths.icon_state = "health2"
				if(50 to 100)
					healths.icon_state = "health3"
				if(0 to 50)
					healths.icon_state = "health4"
				else
					healths.icon_state = "health5"
		else
			healths.icon_state = "health6"


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