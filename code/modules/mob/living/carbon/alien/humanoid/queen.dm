/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 250
	health = 250
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	heal_rate = 5
	plasma_rate = 20
	move_delay_add = 2
	max_plasma = 1000

/mob/living/carbon/alien/humanoid/queen/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
		if(Q == src)		continue
		if(Q.stat == DEAD)	continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid,/mob/living/carbon/alien/humanoid/proc/resin)
	verbs -= /mob/living/carbon/alien/verb/alien_ventcrawl
	..()


/mob/living/carbon/alien/humanoid/queen

	handle_regular_hud_updates()

		..() //-Yvarov

		if (src.healths)
			if (src.stat != 2)
				switch(health)
					if(250 to INFINITY)
						src.healths.icon_state = "health0"
					if(175 to 250)
						src.healths.icon_state = "health1"
					if(100 to 175)
						src.healths.icon_state = "health2"
					if(50 to 100)
						src.healths.icon_state = "health3"
					if(0 to 50)
						src.healths.icon_state = "health4"
					else
						src.healths.icon_state = "health5"
			else
				src.healths.icon_state = "health6"


//Queen verbs
/mob/living/carbon/alien/humanoid/queen/verb/lay_egg()

	set name = "Lay Egg (250)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	if(locate(/obj/effect/alien/egg) in get_turf(src))
		src << "There's already an egg here."
		return

	if(powerc(250,1))//Can't plant eggs on spess tiles. That's silly.
		adjustToxLoss(-250)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has laid an egg!</B>"), 1)
		new /obj/effect/alien/egg(loc)
	return


/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "queen_s"
	pixel_x = -16
	large = 1

/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	if(lying)
		if(resting)					icon_state = "queen_sleep"
		else						icon_state = "queen_l"
		for(var/image/I in overlays_lying)
			overlays += I
	else
		icon_state = "queen_s"
		for(var/image/I in overlays_standing)
			overlays += I



/mob/living/carbon/alien/humanoid/queen/verb/evolve() // -- TLE
	set name = "Evolve (1000)"
	set desc = "The ultimate transformation. Become an alien Empress. Only one empress can exist at a time."
	set category = "Alien"

	if(powerc(1000))
		// Queen check
		var/no_queen = 1
		for(var/mob/living/carbon/alien/humanoid/empress/E in living_mob_list)
			if(!E.key && E.brain_op_stage != 4)
				continue
			no_queen = 0

		if(no_queen)
			adjustToxLoss(-1000)
			src << "\green You begin to evolve!"
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\green <B>[src] begins to twist and contort!</B>"), 1)
			var/mob/living/carbon/alien/humanoid/empress/large/new_xeno = new (loc)
			if(mind)
				mind.transfer_to(new_xeno)
			else
				new_xeno.key = key
			del(src)
		else
			src << "<span class='notice'>We already have an alive empress.</span>"
	return

