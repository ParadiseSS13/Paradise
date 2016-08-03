//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/alien/humanoid
	oxygen_alert = 0
	toxins_alert = 0
	fire_alert = 0
	pass_flags = PASSTABLE
	var/temperature_alert = 0


/mob/living/carbon/alien/humanoid/Life()
	. = ..()
	update_icons()



/mob/living/carbon/alien/humanoid/handle_disabilities()
	if(disabilities & EPILEPSY)
		if((prob(1) && paralysis < 10))
			to_chat(src, "<span class='danger'>You have a seizure!</span>")
			Paralyse(10)
	if(disabilities & COUGHING)
		if((prob(5) && paralysis <= 1))
			drop_item()
			spawn( 0 )
				emote("cough")
				return
	if(disabilities & TOURETTES)
		if((prob(10) && paralysis <= 1))
			Stun(10)
			spawn( 0 )
				emote("twitch")
				return
	if(disabilities & NERVOUS)
		if(prob(10))
			stuttering = max(10, stuttering)

/mob/living/carbon/alien/humanoid/proc/adjust_body_temperature(current, loc_temp, boost)
	var/temperature = current
	var/difference = abs(current-loc_temp)	//get difference
	var/increments// = difference/10			//find how many increments apart they are
	if(difference > 50)
		increments = difference/5
	else
		increments = difference/10
	var/change = increments*boost	// Get the amount to change by (x per increment)
	var/temp_change
	if(current < loc_temp)
		temperature = min(loc_temp, temperature+change)
	else if(current > loc_temp)
		temperature = max(loc_temp, temperature-change)
	temp_change = (temperature - current)
	return temp_change

/mob/living/carbon/alien/humanoid/handle_regular_status_updates()
	updatehealth()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		if(health < config.health_threshold_dead || !get_int_organ(/obj/item/organ/internal/brain))
			death()
			blinded = 1
			stat = DEAD
			silent = 0
			return 1

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 50) || (config.health_threshold_crit >= health) )
			if( health <= 20 && prob(1) )
				spawn(0)
					emote("gasp")
			if(!reagents.has_reagent("epinephrine"))
				adjustOxyLoss(1)
			Paralyse(3)

		if(paralysis)
			AdjustParalysis(-1)
			blinded = 1
			stat = UNCONSCIOUS
		else if(sleeping)
			sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = UNCONSCIOUS
			if( prob(10) && health )
				spawn(0)
					emote("hiss")
		//CONSCIOUS
		else
			stat = CONSCIOUS

		/*	What in the living hell is this?*/
		if(move_delay_add > 0)
			move_delay_add = max(0, move_delay_add - rand(1, 2))

		//Eyes
		if(disabilities & BLIND)		//disabled-blind, doesn't get better on its own
			blinded = 1
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind-1,0)
			blinded = 1
		else if(eye_blurry)	//blurry eyes heal slowly
			eye_blurry = max(eye_blurry-1, 0)

		//Ears
		if(disabilities & DEAF)		//disabled-deaf, doesn't get better on its own
			setEarDamage(-1, max(ear_deaf, 1))
		else if(ear_deaf)			//deafness, heals slowly over time
			adjustEarDamage(0,-1)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			adjustEarDamage(-0.05, 0)

		//Other
		if(stunned)
			AdjustStunned(-1)
			if(!stunned)
				update_icons()

		if(weakened)
			weakened = max(weakened-1,0)
			if(!weakened)
				update_icons()

		if(stuttering)
			stuttering = max(stuttering-1, 0)

		if(silent)
			silent = max(silent-1, 0)

		if(druggy)
			druggy = max(druggy-1, 0)
	return 1