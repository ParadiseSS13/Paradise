/datum/martial_combo/ninja_martial_art/energy_tornado
	name = "Energy Tornado"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Repulses target and everyone back if you are focused.<br> Creates a cloud of smoke if you have a corresponding module and enough energy."

/datum/martial_combo/ninja_martial_art/energy_tornado/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/ninja_martial_art/creeping_widow)
	if(creeping_widow.has_focus)
		user.say("糞食らえ!")
		creeping_widow.has_focus = 0
		INVOKE_ASYNC(src, .proc/do_tornado_effect, user)
		var/obj/effect/proc_holder/spell/aoe_turf/repulse/R = new(null)
		var/list/turfs = list()
		for(var/turf/T in range(1,user))
			turfs.Add(T)
		R.cast(turfs)
		add_attack_logs(user, target, "Melee attacked with martial-art [creeping_widow.name] : [name]")
		if(creeping_widow.my_suit && creeping_widow.my_suit.s_initialized && creeping_widow.my_suit.auto_smoke)
			if(locate(/datum/action/item_action/advanced/ninja/ninja_smoke_bomb) in creeping_widow.my_suit.actions)
				creeping_widow.my_suit.prime_smoke(lowcost = TRUE)
		spawn(100) creeping_widow.regain_focus(user)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL

/datum/martial_combo/ninja_martial_art/energy_tornado/proc/do_tornado_effect(mob/living/carbon/human/user)
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		user.dir = i
		playsound(user.loc, 'sound/weapons/punch1.ogg', 15, TRUE, -1)
		sleep(1)
