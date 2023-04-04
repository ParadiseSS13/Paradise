/datum/looping_sound/showering
	start_sound = 'sound/machines/shower/shower_start.ogg'
	start_length = 2
	mid_sounds = list('sound/machines/shower/shower_mid1.ogg' = 1,'sound/machines/shower/shower_mid2.ogg' = 1,'sound/machines/shower/shower_mid3.ogg' = 1)
	mid_length = 10
	end_sound = 'sound/machines/shower/shower_end.ogg'
	volume = 20

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/supermatter
	mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1)
	mid_length = 60
	volume = 40
	extra_range = 25
	falloff_exponent = 10
	falloff_distance = 5
	vary = TRUE
	channel = CHANNEL_ENGINE

GLOBAL_DATUM_INIT(firealarm_soundloop, /datum/looping_sound/firealarm, new(list(), FALSE))

/datum/looping_sound/firealarm
	mid_sounds = 'sound/machines/fire_alarm.ogg'
	mid_length = 20
	volume = 80
	extra_range = 15
	falloff_exponent = 5
	channel = CHANNEL_FIREALARM

/datum/looping_sound/firealarm/sound_loop(looped)
	. = ..()
	if(!length(output_atoms))
		stop()

