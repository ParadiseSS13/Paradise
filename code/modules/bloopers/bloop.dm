/// Thank you Iris!
/datum/blooper
	var/name = "None"
	var/id = "No Voice"
	var/soundpath

	var/minpitch = BLOOPER_DEFAULT_MINPITCH
	var/maxpitch = BLOOPER_DEFAULT_MAXPITCH
	var/minvariance = BLOOPER_DEFAULT_MINVARY
	var/maxvariance = BLOOPER_DEFAULT_MAXVARY

	// Speed vars. Speed determines the number of characters required for each blooper, with lower speeds being faster with higher blooper density
	var/minspeed = BLOOPER_DEFAULT_MINSPEED
	var/maxspeed = BLOOPER_DEFAULT_MAXSPEED

	var/bloop_count_multiplier = 1

	// Visibility vars. Regardless of what's set below, these can still be obtained via adminbus and genetics. Rule of fun.
	var/list/ckeys_allowed
	var/ignore = FALSE // If TRUE - only for admins
	var/allow_random = FALSE

/datum/bloop_queue_entry
	var/start_time
	var/volume
	var/pitch
	var/stamp

/datum/bloop_queue_entry/New(start_time_, volume_, pitch_, stamp_)
	start_time = start_time_
	volume = volume_
	pitch = pitch_
	stamp = stamp_

/proc/init_blooper_sounds()
	for(var/sound_blooper_path in subtypesof(/datum/blooper))
		var/datum/blooper/B = new sound_blooper_path()
		GLOB.blooper_list[B.id] = sound_blooper_path
		if(B.allow_random)
			GLOB.blooper_random_list[B.id] = sound_blooper_path

/mob/living/proc/do_blooper(volume, pitch, queue_time)
	if(!GLOB.blooper_allowed)
		return
	if(queue_time && blooper_current_blooper != queue_time)
		return
	if(!blooper)
		if(!dna.blooper_id || !set_blooper_id(dna.blooper_id))
			if(!set_blooper_id("mutedc4"))
				return
	if(!ishuman(src))
		return
	volume = min(volume, 100)
	playsound(src, blooper, volume, TRUE, frequency = pitch, ignore_walls = FALSE)

// Bloopers
/mob/living/proc/bp_bloop(bloopsound)
	blooper = sound(bloopsound)

/mob/living/proc/set_blooper_id(id)
	if(!id)
		return FALSE
	var/datum/blooper/B = GLOB.blooper_list[id]
	if(!B)
		return FALSE
	blooper = sound(initial(B.soundpath))
	blooper_id = id
	return blooper

/mob/living/proc/process_bloopers(mob/living/char)
	var/now = world.time
	for(var/datum/bloop_queue_entry/entry in char.blooper_queue)
		if(entry.start_time > now)
			continue
		do_blooper(entry.volume, entry.pitch, entry.stamp)
		char.blooper_queue -= entry

/datum/character_save/proc/preview_blooper_voice(mob/user, message)
	if(!user?.client)
		return
	if(!message)
		return

	var/datum/blooper/voice_type = GLOB.blooper_list[blooper_id]
	if(!voice_type)
		to_chat(user, SPAN_WARNING("Select a voice first."))

	var/soundpath = initial(voice_type.soundpath)

	var/preview_volume = min(blooper_volume, 100)
	var/blooper_count = min(round((length_char(message) / blooper_speed)) + 1, BLOOPER_MAX_BLOOPERS / 4) // Limit this for performance. Less timers.
	var/total_delay = 0
	for(var/i in 1 to blooper_count)
		if(total_delay > BLOOPER_MAX_TIME)
			break
		var/pitch = BLOOPER_DO_VARY(blooper_pitch, blooper_pitch_range)
		addtimer(CALLBACK(src, PROC_REF(play_preview_blooper), user, soundpath, pitch, preview_volume), total_delay)
		total_delay += rand(DS2TICKS(blooper_speed / BLOOPER_SPEED_BASELINE), DS2TICKS(blooper_speed / BLOOPER_SPEED_BASELINE) + DS2TICKS(blooper_speed / BLOOPER_SPEED_BASELINE)) TICKS


/datum/character_save/proc/play_preview_blooper(mob/user, soundpath, pitch, volume)
	if(QDELETED(user) || !user.client)
		return
	var/sound/bloop_sound =  sound(soundpath, volume = volume)
	bloop_sound.frequency = pitch
	SEND_SOUND(user, bloop_sound)
