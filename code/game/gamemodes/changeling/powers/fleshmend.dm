/datum/action/changeling/fleshmend
	name = "Fleshmend"
	desc = "Our flesh rapidly regenerates, healing our burns, bruises, and shortness of breath. Costs 20 chemicals."
	helptext = "If we are on fire, the healing effect will not function. Does not regrow limbs or restore lost blood. Functions while unconscious."
	button_icon_state = "fleshmend"
	chemical_cost = 20
	dna_cost = 2
	req_stat = UNCONSCIOUS
	var/recent_uses = 1 //The factor of which the healing should be divided by
	var/healing_ticks = 10
	// The ideal total healing amount,
	// divided by healing_ticks to get heal/tick
	var/total_healing = 100

/datum/action/changeling/fleshmend/New()
	..()
	START_PROCESSING(SSobj, src)

/datum/action/changeling/fleshmend/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/action/changeling/fleshmend/process()
	if(recent_uses > 1)
		recent_uses = max(1, recent_uses - (1 / healing_ticks))

//Starts healing you every second for 10 seconds. Can be used whilst unconscious.
/datum/action/changeling/fleshmend/sting_action(var/mob/living/user)
	to_chat(user, "<span class='notice'>We begin to heal rapidly.</span>")
	if(recent_uses > 1)
		to_chat(user, "<span class='warning'>Our healing's effectiveness is reduced \
			by quick repeated use!</span>")

	recent_uses++
	INVOKE_ASYNC(src, .proc/fleshmend, user)
	feedback_add_details("changeling_powers","RR")
	return TRUE

/datum/action/changeling/fleshmend/proc/fleshmend(mob/living/user)

	// The healing itself - doesn't heal toxin damage
	// (that's anatomic panacea) and the effectiveness decreases with
	// each use in a short timespan
	for(var/i in 1 to healing_ticks)
		if(user)
			var/healpertick = -(total_healing / healing_ticks)
			user.heal_overall_damage((-healpertick/recent_uses), (-healpertick/recent_uses), updating_health = FALSE)
			user.adjustOxyLoss(healpertick/recent_uses, FALSE)
			user.blood_volume = min(user.blood_volume + 30, BLOOD_VOLUME_NORMAL)
			user.updatehealth()
		else
			break
		sleep(10)
