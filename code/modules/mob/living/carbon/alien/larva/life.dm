/mob/living/carbon/alien/larva/Life(seconds, times_fired)
	if(..()) //still breathing
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++

	//some kind of bug in canmove() isn't properly calling update_icons, so this is here as a placeholder
	update_icons()

/mob/living/carbon/alien/larva/handle_regular_status_updates()
	updatehealth()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		SetSilence(0)
	else				//ALIVE. LIGHTS ARE ON
		if(health < -25 || !get_int_organ(/obj/item/organ/internal/brain))
			death()
			SetSilence(0)
			return 1

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 25) || (config.health_threshold_crit >= health) )
			//if( health <= 20 && prob(1) )
			//	spawn(0)
			//		emote("gasp")
			if(!reagents.has_reagent("epinephrine"))
				adjustOxyLoss(1)
			Paralyse(3)

		if(paralysis)
			stat = UNCONSCIOUS
		else if(sleeping)
			stat = UNCONSCIOUS
			if(prob(10) && health)
				emote("hiss_")
		//CONSCIOUS
		else
			stat = CONSCIOUS

		/*	What in the living hell is this?*/
		if(move_delay_add > 0)
			move_delay_add = max(0, move_delay_add - rand(1, 2))

		if(eye_blind)			//blindness, heals slowly over time
			AdjustEyeBlind(-1)
		else if(eye_blurry)	//blurry eyes heal slowly
			AdjustEyeBlurry(-1)

		if(stuttering)
			AdjustStuttering(-1)

		if(silent)
			AdjustSilence(-1)

		if(druggy)
			AdjustDruggy(-1)
	return 1
