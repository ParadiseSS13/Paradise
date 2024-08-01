/datum/martial_combo/plasma_fist/tornado_sweep
	name = "Tornado Sweep"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Repulses target and everyone back."

/datum/martial_combo/plasma_fist/tornado_sweep/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.say("TORNADO SWEEP!")
	INVOKE_ASYNC(src, PROC_REF(do_tornado_effect), user)
	var/datum/spell/aoe/repulse/R = new(null)
	var/list/turfs = list()
	for(var/turf/T in range(1,user))
		turfs.Add(T)
	R.cast(turfs)
	return MARTIAL_COMBO_DONE

/datum/martial_combo/plasma_fist/tornado_sweep/proc/do_tornado_effect(mob/living/carbon/human/user)
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		user.dir = i
		playsound(user.loc, 'sound/weapons/punch1.ogg', 15, TRUE, -1)
		sleep(1)
