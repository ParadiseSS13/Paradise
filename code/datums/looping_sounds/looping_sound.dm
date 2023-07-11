/*
	output_atoms	(list of atoms)			The destination(s) for the sounds

	mid_sounds		(list or soundfile)		Since this can be either a list or a single soundfile you can have random sounds. May contain further lists but must contain a soundfile at the end.
	mid_length		(num)					The length to wait between playing mid_sounds

	start_sound		(soundfile)				Played before starting the mid_sounds loop
	start_length	(num)					How long to wait before starting the main loop after playing start_sound

	end_sound		(soundfile)				The sound played after the main loop has concluded

	chance			(num)					Chance per loop to play a mid_sound
	volume			(num)					Sound output volume
	muted			(bool)					Private. Used to stop the sound loop.
	max_loops		(num)					The max amount of loops to run for.
	direct			(bool)					If true plays directly to provided atoms instead of from them
*/
/datum/looping_sound
	var/list/atom/output_atoms
	var/mid_sounds
	var/mid_length
	var/start_sound
	var/start_length
	var/end_sound
	var/chance
	var/volume = 100
	var/vary = FALSE
	var/max_loops
	var/direct
	var/extra_range = 0
	var/falloff_exponent
	var/muted = TRUE
	var/falloff_distance
	/// Channel of the audio, random otherwise
	var/channel
	/// If this sound is based off of an area
	var/area_sound = FALSE

/datum/looping_sound/New(list/_output_atoms = list(), start_immediately = FALSE, _direct = FALSE)
	if(!mid_sounds)
		WARNING("A looping sound datum was created without sounds to play.")
		return

	output_atoms = _output_atoms
	direct = _direct

	if(start_immediately)
		start()

/datum/looping_sound/Destroy()
	GLOB.looping_sounds -= src
	stop()
	output_atoms = null
	return ..()

/datum/looping_sound/proc/start(atom/add_thing)
	GLOB.looping_sounds += src
	if(add_thing)
		LAZYADDOR(output_atoms, add_thing)
	if(!muted)
		return
	muted = FALSE
	on_start()

/datum/looping_sound/proc/stop(atom/remove_thing, do_not_mute)
	GLOB.looping_sounds -= src
	if(remove_thing)
		LAZYREMOVE(output_atoms, remove_thing)
		if(do_not_mute && length(output_atoms)) //if there are no output_atoms then we mute regardless of your preferance
			return
	if(muted)
		return
	muted = TRUE

/datum/looping_sound/proc/sound_loop(looped = 0)
	if(muted || (max_loops && looped > max_loops))
		on_stop(looped)
		return
	if(!chance || prob(chance))
		play(get_sound(looped))
	addtimer(CALLBACK(src, PROC_REF(sound_loop), ++looped), mid_length)

/datum/looping_sound/proc/play(soundfile)
	var/list/atoms_cache = output_atoms
	var/sound/S = sound(soundfile)
	if(area_sound)
		for(var/area/sound_outputs in atoms_cache)
			for(var/mob/listener in mobs_in_area(sound_outputs, TRUE))
				S.volume = volume * (USER_VOLUME(listener, channel))
				SEND_SOUND(listener, S)
		return
	if(direct)
		S.channel = channel || SSsounds.random_available_channel()
	for(var/atom/thing in atoms_cache)
		if(direct)
			if(ismob(thing))
				var/mob/M = thing
				S.volume = volume * (USER_VOLUME(M, channel) || 1)
			SEND_SOUND(thing, S)
		else
			playsound(thing, S, volume, vary, extra_range, falloff_exponent = falloff_exponent, falloff_distance = falloff_distance, channel = channel)

/datum/looping_sound/proc/get_sound(looped, _mid_sounds)
	if(!_mid_sounds)
		. = mid_sounds
	else
		. = _mid_sounds
	while(!isfile(.) && !isnull(.))
		. = pickweight(.)

/datum/looping_sound/proc/on_start()
	var/start_wait = 0
	if(start_sound)
		play(start_sound)
		start_wait = start_length
	addtimer(CALLBACK(src, PROC_REF(sound_loop)), start_wait)

/datum/looping_sound/proc/on_stop(looped)
	if(end_sound)
		play(end_sound)

/// Looping sounds that decrease volume by a specified % each loop until it reaches a specified total % volume.
/datum/looping_sound/decreasing
	/// What volume level, as a % of original, to eventually decrease to
	var/decrease_to_amount = 50
	/// How much, as a % of original, to decrease the volume by each loop
	var/decrease_by_amount = 1

/datum/looping_sound/decreasing/sound_loop(looped = 0)
	. = ..()
	if(decrease_by_amount && decrease_to_amount && decrease_to_amount < volume)
		volume = max(volume - decrease_by_amount, decrease_to_amount)

/datum/looping_sound/decreasing/delta_alarm
	mid_sounds = 'sound/effects/delta_alarm.ogg'
	volume = 50
	mid_length = 80
	decrease_to_amount = 10
	decrease_by_amount = 5
	channel = CHANNEL_DELTA_ALARM
