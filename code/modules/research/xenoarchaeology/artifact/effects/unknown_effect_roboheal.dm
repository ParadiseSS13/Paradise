
/datum/artifact_effect/roboheal
	effecttype = "roboheal"

/datum/artifact_effect/roboheal/New()
	..()
	effect_type = pick(3,4)

/datum/artifact_effect/roboheal/DoEffectTouch(var/mob/user)
	if(user)
		if(istype(user, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = user
			to_chat(R, "\blue Your systems report damaged components mending by themselves!")
			R.adjustBruteLoss(rand(-10,-30))
			R.adjustFireLoss(rand(-10,-30))
			return 1

/datum/artifact_effect/roboheal/DoEffectAura()
	if(holder)
		var/turf/T = get_turf(holder)
		for(var/mob/living/silicon/robot/M in range(src.effectrange,T))
			if(prob(10))
				to_chat(M, "\blue SYSTEM ALERT: Beneficial energy field detected!")
			M.adjustBruteLoss(-1)
			M.adjustFireLoss(-1)
			M.updatehealth()
		return 1

/datum/artifact_effect/roboheal/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		for(var/mob/living/silicon/robot/M in range(src.effectrange,T))
			to_chat(M, "\blue SYSTEM ALERT: Structural damage has been repaired by energy pulse!")
			M.adjustBruteLoss(-10)
			M.adjustFireLoss(-10)
			M.updatehealth()
		return 1
