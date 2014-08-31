/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 125
	health = 125
	storedPlasma = 100
	max_plasma = 250
	icon_state = "aliens_s"
	plasma_rate = 10

/mob/living/carbon/alien/humanoid/sentinel/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
//	if(name == "alien sentinel")
//		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid)
	..()

/mob/living/carbon/alien/humanoid/sentinel


	handle_regular_hud_updates()

		..() //-Yvarov

		if (healths)
			if (stat != 2)
				switch(health)
					if(125 to INFINITY)
						healths.icon_state = "health0"
					if(100 to 125)
						healths.icon_state = "health1"
					if(75 to 100)
						healths.icon_state = "health2"
					if(25 to 75)
						healths.icon_state = "health3"
					if(0 to 25)
						healths.icon_state = "health4"
					else
						healths.icon_state = "health5"
			else
				healths.icon_state = "health6"


/mob/living/carbon/alien/humanoid/sentinel/verb/evolve() // -- TLE
	set name = "Evolve (250)"
	set desc = "Become a Praetorian, Royal Guard to the Queen."
	set category = "Alien"

	if(powerc(250))
		adjustToxLoss(-250)
		src << "\green You begin to evolve!"
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] begins to twist and contort!</B>"), 1)
		var/mob/living/carbon/alien/humanoid/sentinel/large/new_xeno = new (loc)
		if(mind)
			mind.transfer_to(new_xeno)
		else
			new_xeno.key = key
		del(src)
	return

/mob/living/carbon/alien/humanoid/sentinel/large
	name = "alien praetorian"
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "prat_s"
	pixel_x = -16
	maxHealth = 200
	health = 200
	move_delay_add = 1
	large = 1


/mob/living/carbon/alien/humanoid/sentinel/large/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	if(lying)
		if(resting)					icon_state = "prat_sleep"
		else						icon_state = "prat_l"
		for(var/image/I in overlays_lying)
			overlays += I
	else
		icon_state = "prat_s"
		for(var/image/I in overlays_standing)
			overlays += I