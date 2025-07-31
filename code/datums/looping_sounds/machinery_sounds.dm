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

///// KITCHEN MACHINERY /////

/datum/looping_sound/kitchen/microwave
	start_sound = 'sound/machines/kitchen/microwave_start.ogg'
	start_length = 10
	mid_sounds = list('sound/machines/kitchen/microwave_mid1.ogg' = 10, 'sound/machines/kitchen/microwave_mid2.ogg' = 1)
	mid_length = 15
	end_sound = 'sound/machines/kitchen/microwave_end.ogg'

/datum/looping_sound/kitchen/deep_fryer
	start_sound = 'sound/machines/kitchen/deep_fryer_immerse.ogg'
	start_length = 10
	mid_sounds = list('sound/machines/kitchen/deep_fryer_1.ogg' = 1, 'sound/machines/kitchen/deep_fryer_2.ogg' = 1)
	mid_length = 9
	end_sound = 'sound/machines/kitchen/deep_fryer_emerge.ogg'
	volume = 5

/datum/looping_sound/kitchen/oven
	start_sound = 'sound/machines/kitchen/oven_loop_start.ogg'
	start_length = 11
	mid_sounds = list('sound/machines/kitchen/oven_loop_mid.ogg' = 1)
	mid_length = 12
	end_sound = 'sound/machines/kitchen/oven_loop_end.ogg'
	volume = 70

/datum/looping_sound/kitchen/grill
	start_sound = 'sound/machines/kitchen/grill_start.ogg'
	start_length = 13
	mid_sounds = list('sound/machines/kitchen/grill_mid.ogg' = 1)
	mid_length = 20
	end_sound = 'sound/machines/kitchen/grill_end.ogg'
	volume = 50

/datum/looping_sound/kinesis
	mid_sounds = list('sound/machines/gravgen/gravgen_mid1.ogg' = 1, 'sound/machines/gravgen/gravgen_mid2.ogg' = 1, 'sound/machines/gravgen/gravgen_mid3.ogg' = 1, 'sound/machines/gravgen/gravgen_mid4.ogg' = 1)
	mid_length = 1.8 SECONDS
	extra_range = 10
	volume = 20
	falloff_distance = 2
	falloff_exponent = 5
