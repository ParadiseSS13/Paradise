/mob/living/proc/Life(seconds, times_fired)
	set waitfor = FALSE
	set invisibility = 0

	if(HAS_TRAIT(src, TRAIT_FLYING) && !floating) //TODO: Better floating
		float(TRUE)

	if(client || registered_z) // This is a temporary error tracker to make sure we've caught everything
		var/turf/T = get_turf(src)
		if(client && registered_z != T.z)
			message_admins("[src] [ADMIN_FLW(src, "FLW")] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z]. If you could ask them how that happened and notify the coders, it would be appreciated.")
			log_game("Z-TRACKING: [src] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z].")
			update_z(T.z)
		else if(!client && registered_z)
			log_game("Z-TRACKING: [src] of type [src.type] has a Z-registration despite not having a client.")
			update_z(null)

	if(notransform)
		return FALSE
	if(!loc)
		return FALSE

	if(stat != DEAD)
		//Chemicals in the body
		if(reagents)
			handle_chemicals_in_body()

	if(QDELETED(src)) // some chems can gib mobs
		return

	if(stat != DEAD)
		//Mutations and radiation
		handle_mutations_and_radiation()

	if(stat != DEAD)
		//Breathing, if applicable
		handle_breathing(times_fired)

	if(stat != DEAD)
		//Random events (vomiting etc)
		handle_random_events()

	if(LAZYLEN(viruses))
		handle_diseases()

	if(QDELETED(src)) // diseases can qdel the mob via transformations
		return

	//Heart Attack, if applicable
	if(stat != DEAD)
		handle_heartattack()

	//Handle temperature/pressure differences between body and environment
	var/datum/gas_mixture/readonly_environment = null
	if(isobj(loc))
		var/obj/O = loc
		readonly_environment = O.return_obj_air()
	if(isnull(readonly_environment))
		var/turf/T = get_turf(src)
		if(!isnull(T))
			readonly_environment = T.get_readonly_air()
	handle_environment(readonly_environment)

	handle_fire()

	update_gravity(mob_has_gravity())

	if(pulling)
		update_pulling()

	for(var/obj/item/grab/G in src)
		G.process()

	if(stat != DEAD)
		handle_critical_condition()

	if(stat != DEAD) // Status & health update, are we dead or alive etc.
		handle_disabilities() // eye, ear, brain damages

	if(stat != DEAD)
		handle_status_effects() //all special effects, stunned, weakened, jitteryness, hallucination, sleeping, etc

	if(stat != DEAD)
		if(forced_look && !isnum(forced_look))
			var/atom/A = locateUID(forced_look)
			if(istype(A))
				var/view = client ? client.maxview() : world.view
				if(get_dist(src, A) > view || !(src in viewers(view, A)))
					clear_forced_look(TRUE)
					to_chat(src, "<span class='notice'>Your direction target has left your view, you are no longer facing anything.</span>")
			else
				clear_forced_look(TRUE)
				to_chat(src, "<span class='notice'>Your direction target has left your view, you are no longer facing anything.</span>")
		// Make sure it didn't get cleared
		if(forced_look)
			setDir()

	if(stat != DEAD)
		return TRUE

/mob/living/proc/handle_breathing(times_fired)
	return

/mob/living/proc/handle_heartattack()
	return

/mob/living/proc/handle_mutations_and_radiation()
	radiation = 0 //so radiation don't accumulate in simple animals

/mob/living/proc/handle_chemicals_in_body()
	return

/mob/living/proc/handle_diseases()
	return

/mob/living/proc/handle_random_events()
	return

/// Handle temperature/pressure differences between body and environment
/mob/living/proc/handle_environment()
	return

/mob/living/proc/update_pulling()
	if(incapacitated())
		stop_pulling()

//this updates all special effects: mainly stamina
/mob/living/proc/handle_status_effects() // We check for the status effect in this proc as opposed to the procs below to avoid excessive proc call overhead
	return

/mob/living/proc/update_damage_hud()
	return

/mob/living/proc/handle_disabilities()
	//Eyes
	if(HAS_TRAIT(src, TRAIT_BLIND) || stat)	//blindness from disability or unconsciousness doesn't get better on its own
		EyeBlind(2 SECONDS)

// Gives a mob the vision of being dead
/mob/living/proc/grant_death_vision()
	sight |= SEE_TURFS
	sight |= SEE_MOBS
	sight |= SEE_OBJS
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_OBSERVER
	sync_lighting_plane_alpha()

/mob/living/proc/handle_critical_condition()
	return

/mob/living/update_health_hud()
	if(!client)
		return
	if(healths)
		var/severity = 0
		var/healthpercent = (health / maxHealth) * 100
		switch(healthpercent)
			if(100 to INFINITY)
				healths.icon_state = "health0"
			if(80 to 100)
				healths.icon_state = "health1"
				severity = 1
			if(60 to 80)
				healths.icon_state = "health2"
				severity = 2
			if(40 to 60)
				healths.icon_state = "health3"
				severity = 3
			if(20 to 40)
				healths.icon_state = "health4"
				severity = 4
			if(1 to 20)
				healths.icon_state = "health5"
				severity = 5
			else
				healths.icon_state = "health7"
				severity = 6
		if(severity > 0)
			overlay_fullscreen("brute", /atom/movable/screen/fullscreen/stretch/brute, severity)
		else
			clear_fullscreen("brute")
		if(health <= HEALTH_THRESHOLD_CRIT)
			throw_alert("succumb", /atom/movable/screen/alert/succumb)
		else
			clear_alert("succumb")

/mob/living/proc/perceived_stamina()
	return staminaloss

/mob/living/update_stamina_hud()
	if(!client || !staminas)
		return

	var/perceived_stamina = perceived_stamina()

	switch(perceived_stamina)
		if(100 to INFINITY)
			staminas.icon_state = "stamina6"
		if(80 to 100)
			staminas.icon_state = "stamina5"
		if(60 to 80)
			staminas.icon_state = "stamina4"
		if(40 to 60)
			staminas.icon_state = "stamina3"
		if(20 to 40)
			staminas.icon_state = "stamina2"
		if(1 to 20)
			staminas.icon_state = "stamina1"
		else
			staminas.icon_state = null
/*		else // The 100% stamina is currently disabled, to reduce clutter on your screen
			staminas.icon_state = "stamina0"
 */
