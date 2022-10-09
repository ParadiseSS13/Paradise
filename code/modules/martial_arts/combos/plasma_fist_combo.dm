// PLASMA_FIST COMBOS

// Plasma Fist
/datum/martial_combo/plasma_fist/plasma_fist
	name = "The Plasma Fist"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Knocks the brain out of the opponent and gibs their body."

/datum/martial_combo/plasma_fist/plasma_fist/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	playsound(target.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	user.say("PLASMA FIST!")
	target.visible_message("<span class='danger'>[user] has hit [target] with THE PLASMA FIST TECHNIQUE!</span>", \
								"<span class='userdanger'>[user] has hit [target] with THE PLASMA FIST TECHNIQUE!</span>")
	target.gib()
	return MARTIAL_COMBO_DONE

// Throwback
/datum/martial_combo/plasma_fist/throwback
	name = "Throwback"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Throws the target and an item at them."

/datum/martial_combo/plasma_fist/throwback/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	target.visible_message("<span class='danger'>[user] has hit [target] with Plasma Punch!</span>", \
								"<span class='userdanger'>[user] has hit [target] with Plasma Punch!</span>")
	playsound(target.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(target, get_step_away(target, user)))
	target.throw_at(throw_target, 200, 4, user)
	user.say("HYAH!")
	return MARTIAL_COMBO_DONE

// Tornado Sweep
/datum/martial_combo/plasma_fist/tornado_sweep
	name = "Tornado Sweep"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Repulses target and everyone back."

/datum/martial_combo/plasma_fist/tornado_sweep/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.say("TORNADO SWEEP!")
	INVOKE_ASYNC(src, .proc/do_tornado_effect, user)
	var/obj/effect/proc_holder/spell/aoe_turf/repulse/R = new(null)
	var/list/turfs = list()
	for(var/turf/T in range(1,user))
		turfs.Add(T)
	R.cast(turfs)
	return MARTIAL_COMBO_DONE

/datum/martial_combo/plasma_fist/tornado_sweep/proc/do_tornado_effect(mob/living/carbon/human/user)
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		user.dir = i
		playsound(user.loc, 'sound/weapons/punch1.ogg', 15, 1, -1)
		sleep(1)
