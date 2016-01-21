
/datum/artifact_effect/radiate
	effecttype = "radiate"
	var/radiation_amount

/datum/artifact_effect/radiate/New()
	..()
	radiation_amount = rand(1, 10)
	effect_type = pick(4,5)

/datum/artifact_effect/radiate/DoEffectTouch(var/mob/living/user)
	if(user)
		user.apply_effect(radiation_amount * 5,IRRADIATE,0)
		user.updatehealth()
		return 1

/datum/artifact_effect/radiate/DoEffectAura()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/mob/living/M in range(src.effectrange,T))
			M.apply_effect(radiation_amount,IRRADIATE,0)
			M.updatehealth()
		return 1

/datum/artifact_effect/radiate/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/mob/living/M in range(src.effectrange,T))
			M.apply_effect(radiation_amount * 25,IRRADIATE,0)
			M.updatehealth()
		return 1
