///Footstep component. Plays footsteps at parents location when it is appropriate.
/datum/component/footstep
	///How many steps the parent has taken since the last time a footstep was played.
	var/steps = 0
	///volume determines the extra volume of the footstep. This is multiplied by the base volume, should there be one.
	var/volume
	///e_range stands for extra range - aka how far the sound can be heard. This is added to the base value and ignored if there isn't a base value.
	var/e_range
	///footstep_type is a define which determines what kind of sounds should get chosen.
	var/footstep_type
	///This can be a list OR a soundfile OR null. Determines whatever sound gets played.
	var/footstep_sounds
	///Whether or not to add variation to the sounds played
	var/sound_vary = FALSE

/datum/component/footstep/Initialize(footstep_type_ = FOOTSTEP_MOB_BAREFOOT, volume_ = 0.5, e_range_ = -8, vary)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	volume = volume_
	e_range = e_range_
	footstep_type = footstep_type_
	sound_vary = vary
	switch(footstep_type)
		if(FOOTSTEP_MOB_HUMAN)
			if(!ishuman(parent))
				return COMPONENT_INCOMPATIBLE
			RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/play_humanstep)
			return // Humans don't get past here
		if(FOOTSTEP_MOB_BAREFOOT)
			footstep_sounds = GLOB.barefootstep
		if(FOOTSTEP_MOB_CLAW)
			footstep_sounds = GLOB.clawfootstep
		if(FOOTSTEP_MOB_HEAVY)
			footstep_sounds = GLOB.heavyfootstep
		if(FOOTSTEP_MOB_SHOE)
			footstep_sounds = GLOB.footstep
		if(FOOTSTEP_MOB_SLIME)
			footstep_sounds = 'sound/effects/footstep/slime1.ogg'
		if(FOOTSTEP_OBJ_MACHINE)
			footstep_sounds = 'sound/effects/bang.ogg'
			RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/play_simplestep_machine)
			return
		if(FOOTSTEP_OBJ_ROBOT)
			footstep_sounds = 'sound/effects/tank_treads.ogg'
			RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/play_simplestep_machine)
			return

	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/play_simplestep)

///Prepares a footstep. Determines if it should get played. Returns the turf it should get played on. Note that it is always a /turf/simulated/floor (eventually /turf/open)
/datum/component/footstep/proc/prepare_step()
	var/turf/simulated/floor/T = get_turf(parent)
	if(!istype(T))
		return

	var/mob/living/LM = parent
	if(!T.footstep || LM.lying || !LM.canmove || LM.resting || LM.buckled || LM.throwing || LM.flying || istype(LM.loc, /obj/machinery/atmospherics))
		return

	if(ishuman(LM))
		var/mob/living/carbon/human/H = LM
		if(!H.get_organ(BODY_ZONE_L_LEG) && !H.get_organ(BODY_ZONE_R_LEG))
			return
		if(H.m_intent == MOVE_INTENT_WALK)
			return// stealth
	steps++

	if(steps >= 6)
		steps = 0

	if(steps % 2)
		return

	if(steps != 0 && !has_gravity(LM, T)) // don't need to step as often when you hop around
		return
	return T

/datum/component/footstep/proc/play_simplestep()
	SIGNAL_HANDLER

	var/turf/simulated/floor/T = prepare_step()
	if(!T)
		return

	// Single set sound file
	if(isfile(footstep_sounds) || istext(footstep_sounds))
		playsound(T, footstep_sounds, volume, sound_vary)
		return

	// Turf-dependent sound file
	var/turf_footstep = get_turf_sound(T, footstep_type)
	if(!turf_footstep)
		return
	playsound(T,
		pick(footstep_sounds[turf_footstep][1]),	// Sound
		footstep_sounds[turf_footstep][2] * volume, // Volume
		sound_vary,									// Pitch variation
		footstep_sounds[turf_footstep][3] + e_range // Range
	)

/**
 * Plays a footstep sound for /human mobs, based on species and footwear.
 *
 * If the mob is wearing shoes then a shoe sound is played, if they're barefoot then the sound will be set by their [/datum/species/var/footstep_type] variable.
 * In both cases the final sound is based on the turf they're walking over. (Metal, wood, carpet, etc.)
 */
/datum/component/footstep/proc/play_humanstep()
	SIGNAL_HANDLER

	if(HAS_TRAIT(parent, TRAIT_SILENT_FOOTSTEPS))
		return
	var/turf/simulated/floor/T = prepare_step()
	if(!T)
		return
	var/mob/living/carbon/human/H = parent

	var/step_type = H.dna.species.footstep_type

	if((H.wear_suit?.body_parts_covered | H.w_uniform?.body_parts_covered | H.shoes?.body_parts_covered) & FEET)
		step_type = FOOTSTEP_MOB_SHOE // Feet are covered

	// Barefoot, claws, shoes, etc.
	var/list/step_sounds = get_step_sounds(step_type)
	// Metal, wood, carpet, etc.
	var/turf_footstep = get_turf_sound(T, step_type)

	playsound(T,
		pick(step_sounds[turf_footstep][1]),	// Sound
		step_sounds[turf_footstep][2] * volume, // Volume
		sound_vary,								// Pitch variation
		step_sounds[turf_footstep][3] + e_range // Range
	)


///Prepares a footstep for machine walking
/datum/component/footstep/proc/play_simplestep_machine()
	SIGNAL_HANDLER

	var/turf/simulated/floor/T = get_turf(parent)
	if(!istype(T))
		return
	playsound(T, footstep_sounds, 50, sound_vary)

/datum/component/footstep/proc/get_step_sounds(step_type)
	switch(step_type)
		if(FOOTSTEP_MOB_BAREFOOT)
			return GLOB.barefootstep
		if(FOOTSTEP_MOB_CLAW)
			return GLOB.clawfootstep
		if(FOOTSTEP_MOB_HEAVY)
			return GLOB.heavyfootstep
		else
			return GLOB.footstep

/datum/component/footstep/proc/get_turf_sound(turf/simulated/floor/T, step_type)
	switch(step_type)
		if(FOOTSTEP_MOB_BAREFOOT)
			return T.barefootstep
		if(FOOTSTEP_MOB_CLAW)
			return T.clawfootstep
		if(FOOTSTEP_MOB_HEAVY)
			return T.heavyfootstep
		else
			return T.footstep
