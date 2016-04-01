//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/alien/larva
	var/temperature_alert = 0

/mob/living/carbon/alien/larva/Life()
	if(..()) //still breathing
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++

	//some kind of bug in canmove() isn't properly calling update_icons, so this is here as a placeholder
	update_icons()

/mob/living/carbon/alien/larva/handle_regular_status_updates()
	updatehealth()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		if(health <= -maxHealth|| brain_op_stage == 4.0)
			death()
			blinded = 1
			silent = 0
			return 1

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 25) || (MOB_THRESHOLD_CRIT >= health) )
			//if( health <= 20 && prob(1) )
			//	spawn(0)
			//		emote("gasp")
			if(!reagents.has_reagent("epinephrine"))
				adjustOxyLoss(1)
			Paralyse(3)

		if(paralysis)
			AdjustParalysis(-2)
			blinded = 1
			stat = UNCONSCIOUS
		else if(sleeping)
			sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = UNCONSCIOUS
			if( prob(10) && health )
				spawn(0)
					emote("hiss_")
		//CONSCIOUS
		else
			stat = CONSCIOUS

		/*	What in the living hell is this?*/
		if(move_delay_add > 0)
			move_delay_add = max(0, move_delay_add - rand(1, 2))

		//Eyes
		if(sdisabilities & BLIND)	//disabled-blind, doesn't get better on its own
			blinded = 1
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind-1,0)
			blinded = 1
		else if(eye_blurry)	//blurry eyes heal slowly
			eye_blurry = max(eye_blurry-1, 0)

		//Ears
		if(sdisabilities & DEAF)	//disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(ear_deaf)			//deafness, heals slowly over time
			ear_deaf = max(ear_deaf-1, 0)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold.
			ear_damage = max(ear_damage-0.05, 0)

		//Other
		if(stunned)
			AdjustStunned(-1)

		if(weakened)
			weakened = max(weakened-1,0)

		if(stuttering)
			stuttering = max(stuttering-1, 0)

		if(silent)
			silent = max(silent-1, 0)

		if(druggy)
			druggy = max(druggy-1, 0)
	return 1


/mob/living/carbon/alien/larva/handle_regular_hud_updates()

	if (stat == 2 || (XRAY in mutations))
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if (stat != 2)
		sight |= SEE_MOBS
		sight &= ~SEE_TURFS
		sight &= ~SEE_OBJS
		if(nightvision)
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_MINIMUM
		else if(!nightvision)
			see_in_dark = 4
			see_invisible = 45
		if(see_override)
			see_invisible = see_override

	if (healths)
		if (stat != 2)
			switch(health)
				if(25 to INFINITY)
					healths.icon_state = "health0"
				if(19 to 25)
					healths.icon_state = "health1"
				if(13 to 19)
					healths.icon_state = "health2"
				if(7 to 13)
					healths.icon_state = "health3"
				if(0 to 7)
					healths.icon_state = "health4"
				else
					healths.icon_state = "health5"
		else
			healths.icon_state = "health6"

	if(pullin)
		if(pulling)
			pullin.icon_state = "pull"
		else
			pullin.icon_state = "pull0"

	if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
	if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
	if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"
	//NOTE: the alerts dont reset when youre out of danger. dont blame me,
	//blame the person who coded them. Temporary fix added.


	client.screen.Remove(global_hud.blurry,global_hud.druggy,global_hud.vimpaired)

	if ((blind && stat != 2))
		if ((blinded))
			blind.layer = 18
		else
			blind.layer = 0

			if (disabilities & NEARSIGHTED)
				client.screen += global_hud.vimpaired

			if (eye_blurry)
				client.screen += global_hud.blurry

			if (druggy)
				client.screen += global_hud.druggy

	if (stat != 2)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

	return 1