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

	// Visibility vars. Regardless of what's set below, these can still be obtained via adminbus and genetics. Rule of fun.
	var/list/ckeys_allowed
	var/ignore = FALSE // If TRUE - only for admins
	var/allow_random = FALSE

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
		if(!blooper_id || !set_blooper_id(blooper_id))
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
	while(LAZYLEN(char.blooper_queue))
		var/list/entry = char.blooper_queue[length(char.blooper_queue)]
		if(entry["start_time"] > now)
			continue
		do_blooper(entry["volume"], entry["pitch"], entry["stamp"])
		char.blooper_queue.len--

