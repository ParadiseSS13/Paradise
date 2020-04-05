/mob/living/Life(seconds, times_fired)
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if(notransform)
		return FALSE
	if(!loc)
		return FALSE
	var/datum/gas_mixture/environment = loc.return_air()

	if(client || registered_z) // This is a temporary error tracker to make sure we've caught everything
		var/turf/T = get_turf(src)
		if(client && registered_z != T.z)
			message_admins("[src] [ADMIN_FLW(src, "FLW")] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z]. If you could ask them how that happened and notify the coders, it would be appreciated.")
			log_game("Z-TRACKING: [src] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z].")
			update_z(T.z)
		else if (!client && registered_z)
			log_game("Z-TRACKING: [src] of type [src.type] has a Z-registration despite not having a client.")
			update_z(null)
	if(stat != DEAD)
		//Chemicals in the body
		handle_chemicals_in_body()

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Breathing, if applicable
		handle_breathing(times_fired)

		//Random events (vomiting etc)
		handle_random_events()

		. = 1

	handle_diseases()

	//Heart Attack, if applicable
	if(stat != DEAD)
		handle_heartattack()

	//Handle temperature/pressure differences between body and environment
	if(environment)
		handle_environment(environment)

	handle_fire()

	//stuff in the stomach
	handle_stomach(times_fired)

	update_gravity(mob_has_gravity())

	update_pulling()

	for(var/obj/item/grab/G in src)
		G.process()

	if(handle_regular_status_updates()) // Status & health update, are we dead or alive etc.
		handle_disabilities() // eye, ear, brain damages
		handle_status_effects() //all special effects, stunned, weakened, jitteryness, hallucination, sleeping, etc

	if(client)
		handle_regular_hud_updates()

	..()

/mob/living/proc/handle_breathing(times_fired)
	return

/mob/living/proc/handle_heartattack()
	return

/mob/living/proc/handle_mutations_and_radiation()
	radiation = 0 //so radiation don't accumulate in simple animals
	return

/mob/living/proc/handle_chemicals_in_body()
	return

/mob/living/proc/handle_diseases()
	return

/mob/living/proc/handle_random_events()
	return

/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	return

/mob/living/proc/handle_stomach(times_fired)
	return

/mob/living/proc/update_pulling()
	if(pulling)
		if(incapacitated())
			stop_pulling()

//This updates the health and status of the mob (conscious, unconscious, dead)
/mob/living/proc/handle_regular_status_updates()
	return stat != DEAD

//this updates all special effects: stunned, sleeping, weakened, druggy, stuttering, etc..
/mob/living/proc/handle_status_effects()
	handle_stunned()
	handle_weakened()
	handle_stuttering()
	handle_silent()
	handle_drugged()
	handle_slurring()
	handle_paralysed()
	handle_sleeping()
	handle_slowed()
	handle_drunk()
	handle_cultslurring()


/mob/living/proc/handle_stunned()
	if(stunned)
		AdjustStunned(-1, updating = 1, force = 1)
		if(!stunned)
			update_icons()
	return stunned

/mob/living/proc/handle_weakened()
	if(weakened)
		AdjustWeakened(-1, updating = 1, force = 1)
		if(!weakened)
			update_icons()
	return weakened

/mob/living/proc/handle_stuttering()
	if(stuttering)
		stuttering = max(stuttering-1, 0)
	return stuttering

/mob/living/proc/handle_silent()
	if(silent)
		AdjustSilence(-1)
	return silent

/mob/living/proc/handle_drugged()
	if(druggy)
		AdjustDruggy(-1)
	return druggy

/mob/living/proc/handle_slurring()
	if(slurring)
		AdjustSlur(-1)
	return slurring

/mob/living/proc/handle_cultslurring()
	if(cultslurring)
		AdjustCultSlur(-1)
	return cultslurring

/mob/living/proc/handle_paralysed()
	if(paralysis)
		AdjustParalysis(-1, updating = 1, force = 1)
	return paralysis

/mob/living/proc/handle_sleeping()
	if(sleeping)
		AdjustSleeping(-1)
		throw_alert("asleep", /obj/screen/alert/asleep)
	else
		clear_alert("asleep")
	return sleeping

/mob/living/proc/handle_slowed()
	if(slowed)
		AdjustSlowed(-1)
	return slowed

/mob/living/proc/handle_drunk()
	if(drunk)
		AdjustDrunk(-1)
	return drunk

/mob/living/proc/handle_disabilities()
	//Eyes
	if(disabilities & BLIND || stat)	//blindness from disability or unconsciousness doesn't get better on its own
		EyeBlind(1)
	else if(eye_blind)			//blindness, heals slowly over time
		AdjustEyeBlind(-1)
	else if(eye_blurry)			//blurry eyes heal slowly
		AdjustEyeBlurry(-1)

//this handles hud updates. Calls update_vision() and handle_hud_icons()
/mob/living/proc/handle_regular_hud_updates()
	if(!client)	return 0

	handle_vision()
	handle_hud_icons()

	return 1

/mob/living/proc/handle_vision()
	update_sight()

	if(stat == DEAD)
		return

	if(machine)
		if(!machine.check_eye(src))
			reset_perspective(null)
	else
		if(!remote_view && !client.adminobs)
			reset_perspective(null)

// Gives a mob the vision of being dead
/mob/living/proc/grant_death_vision()
	sight |= SEE_TURFS
	sight |= SEE_MOBS
	sight |= SEE_OBJS
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_OBSERVER
	sync_lighting_plane_alpha()

/mob/living/proc/handle_hud_icons()
	handle_hud_icons_health()
	return

/mob/living/proc/handle_hud_icons_health()
	return
