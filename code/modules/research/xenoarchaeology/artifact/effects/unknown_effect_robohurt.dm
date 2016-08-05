
/datum/artifact_effect/robohurt
	effecttype = "robohurt"

/datum/artifact_effect/robohurt/New()
	..()
	effect_type = pick(3,4)

/datum/artifact_effect/robohurt/DoEffectTouch(var/mob/user)
	if(user)
		if(istype(user, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = user
			to_chat(R, "\red Your systems report severe damage has been inflicted!")
			R.adjustBruteLoss(rand(10,50))
			R.adjustFireLoss(rand(10,50))
			return 1

/datum/artifact_effect/robohurt/DoEffectAura()
	if(holder)
		var/turf/T = get_turf(holder)
		for(var/mob/living/silicon/robot/M in range(src.effectrange,T))
			if(prob(10))
				to_chat(M, "\red SYSTEM ALERT: Harmful energy field detected!")
			M.adjustBruteLoss(1)
			M.adjustFireLoss(1)
			M.updatehealth()
		return 1

/datum/artifact_effect/robohurt/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		for(var/mob/living/silicon/robot/M in range(src.effectrange,T))
			to_chat(M, "\red SYSTEM ALERT: Structural damage inflicted by energy pulse!")
			M.adjustBruteLoss(10)
			M.adjustFireLoss(10)
			M.updatehealth()
		return 1
