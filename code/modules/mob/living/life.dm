/mob/living/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if(notransform)
		return
	if(!loc)
		return
	var/datum/gas_mixture/environment = loc.return_air()

	// Do animations for jitter, flight, spinning, etc
	update_animations()

	if(stat != DEAD)
		//Breathing, if applicable
		handle_breathing()

		//Mutations and radiation
		handle_radiation()
		handle_mutations()
		handle_gene_stability()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Random events (vomiting etc)
		handle_random_events()

		. = 1

	//Handle temperature/pressure differences between body and environment
	if(environment)
		handle_environment(environment)

	handle_fire()

	//stuff in the stomach
	handle_stomach()

	update_gravity(mob_has_gravity())

	update_pulling()

	for(var/obj/item/weapon/grab/G in src)
		G.process()

	// eww
	if(get_nations_mode())
		process_nations()

	if(machine)
		machine.check_eye(src)

	if(stat != DEAD)
		handle_disabilities() // eye, ear, brain damages
		handle_status_effects() //all special effects, stunned, weakened, jitteryness, hallucination, sleeping, etc

	..()

/mob/living/proc/handle_breathing()
	return

/mob/living/proc/handle_radiation()
	radiation = 0 //so radiation don't accumulate in simple animals
	return

/mob/living/proc/handle_mutations()
	return

/mob/living/proc/handle_gene_stability()
	return

/mob/living/proc/handle_chemicals_in_body()
	return

/mob/living/proc/handle_random_events()
	return

/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	return

/mob/living/proc/handle_stomach()
	return

/mob/living/proc/update_pulling()
	if(pulling)
		if(incapacitated())
			stop_pulling()

//this regularly decrements all status effects, and calls handlers for
//status effects that have a repeating effect over time
/mob/living/proc/handle_status_effects()

	if(druggy)
		AdjustDruggy(-1)
	if(stuttering)
		AdjustStuttering(-1)
	if(silent)
		AdjustSilence(-1)
	if(slowed)
		AdjustSlowed(-1)
	if(slurring)
		AdjustSlur(-1)

	if(drunk)
		AdjustDrunk(-1)
		handle_drunk()
	if(drowsy)
		AdjustDrowsy(-1)
		handle_drowsy()

	// Status effects that affect `canmove` and `stat`
	var/stat_update_needed = 0
	var/canmove_update_needed = 0
	if(sleeping)
		AdjustSleeping(-1, 0, INFINITY, updating = 0)
		handle_sleeping()
		if(!sleeping)
			stat_update_needed = 1
	if(paralysis)
		AdjustParalysis(-1, 0, INFINITY, updating = 0)
		if(!paralysis)
			stat_update_needed = 1
	if(stunned)
		AdjustStunned(-1, 0, INFINITY, updating = 0)
		if(!stunned)
			canmove_update_needed = 1
	if(weakened)
		AdjustWeakened(-1, 0, INFINITY, updating = 0)
		if(!weakened)
			canmove_update_needed = 1
	// Only call these updates automatically as needed
	if(stat_update_needed)
		update_stat()
	if(canmove_update_needed)
		update_canmove()

// NOTE: Oh dear, this proc is copied EVERYWHERE throughout mob code!
/mob/living/proc/handle_disabilities()
	handle_eyes_update()
	handle_ears_update()

// Normal mobs suffer no consequence from being drunk
/mob/living/proc/handle_drunk()
	return

/mob/living/proc/handle_drowsy()
	return

/mob/living/proc/handle_sleeping()
	return

/mob/living/proc/handle_eyes_update()
	//Eyes
	if(disabilities & BLIND || stat != CONSCIOUS)	//blindness from disability or unconsciousness doesn't get better on its own
		EyeBlind(1)
	else if(eye_blind)			//blindness, heals slowly over time
		AdjustEyeBlind(-1)
	else if(eye_blurry)			//blurry eyes heal slowly
		AdjustEyeBlurry(-1)

/mob/living/proc/handle_ears_update()
	//Ears
	if(disabilities & DEAF)		//disabled-deaf, doesn't get better on its own
		EarDeaf(1)
	// deafness heals slowly over time, unless ear_damage is over 100
	else if(ear_damage < 100)
		AdjustEarDamage(-0.05)
		AdjustEarDeaf(-1)

/mob/living/proc/handle_vision()
	update_sight()

	if(stat == DEAD)
		return

	update_blind_effects()

	update_nearsighted_effects()

	update_blurry_effects()

	update_druggy_effects()

	if(machine)
		if(!machine.check_eye(src))
			reset_view(null)
	else
		if(!remote_view && !client.adminobs)
			reset_view(null)

/mob/living/proc/process_nations()
	if(client)
		var/client/C = client
		for(var/mob/living/carbon/human/H in view(src, world.view))
			C.images += H.hud_list[NATIONS_HUD]
