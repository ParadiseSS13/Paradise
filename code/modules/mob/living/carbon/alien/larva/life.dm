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
		SetSilence(0)
	else				//ALIVE. LIGHTS ARE ON
		if(health < -25 || !get_int_organ(/obj/item/organ/internal/brain))
			death()
			blinded = 1
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
			blinded = 1
			stat = UNCONSCIOUS
		else if(sleeping)
			blinded = 1
			stat = UNCONSCIOUS
			if(prob(10) && health)
				emote("hiss_")
		//CONSCIOUS
		else
			stat = CONSCIOUS

		/*	What in the living hell is this?*/
		if(move_delay_add > 0)
			move_delay_add = max(0, move_delay_add - rand(1, 2))

		//Eyes
		if(disabilities & BLIND)	//disabled-blind, doesn't get better on its own
			blinded = 1
		else if(eye_blind)			//blindness, heals slowly over time
			AdjustEyeBlind(-1)
			blinded = 1
		else if(eye_blurry)	//blurry eyes heal slowly
			AdjustEyeBlurry(-1)

		//Ears
		if(disabilities & DEAF)	//disabled-deaf, doesn't get better on its own
			EarDeaf(1)
		else if(ear_deaf)			//deafness, heals slowly over time
			AdjustEarDeaf(-1)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold.
			AdjustEarDamage(-0.05)

		if(stuttering)
			AdjustStuttering(-1)

		if(silent)
			AdjustSilence(-1)

		if(druggy)
			AdjustDruggy(-1)
	return 1
