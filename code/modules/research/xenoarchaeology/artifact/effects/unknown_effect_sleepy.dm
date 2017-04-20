
//todo
/datum/artifact_effect/sleepy
	effecttype = "sleepy"

/datum/artifact_effect/sleepy/New()
	..()
	effect_type = pick(5,2)

/datum/artifact_effect/sleepy/DoEffectTouch(var/mob/toucher)
	if(toucher)
		var/weakness = GetAnomalySusceptibility(toucher)
		if(ishuman(toucher) && prob(weakness * 100))
			var/mob/living/carbon/human/H = toucher
			to_chat(H, pick("<span class='notice'>You feel like taking a nap.</span>","<span class='notice'>You feel a yawn coming on.</span>","<span class='notice'>You feel a little tired.</span>"))
			H.AdjustDrowsy(rand(5,25) * weakness, bound_lower = 0, bound_upper = 50 * weakness)
			H.AdjustEyeBlurry(rand(1,3) * weakness, bound_lower = 0, bound_upper = 50 * weakness)
			return 1
		else if(isrobot(toucher))
			to_chat(toucher, "<span class='warning'>SYSTEM ALERT: CPU cycles slowing down.</span>")
			return 1

/datum/artifact_effect/sleepy/DoEffectAura()
	if(holder)
		var/turf/T = get_turf(holder)
		for(var/mob/living/carbon/human/H in range(src.effectrange,T))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				if(prob(10))
					to_chat(H, pick("<span class='notice'>You feel like taking a nap.</span>","<span class='notice'>You feel a yawn coming on.</span>","<span class='notice'>You feel a little tired.</span>"))
				H.AdjustDrowsy(1 * weakness, bound_lower = 0, bound_upper = 25 * weakness)
				H.AdjustEyeBlurry(1 * weakness, bound_lower = 0, bound_upper = 25 * weakness)
		for(var/mob/living/silicon/robot/R in range(src.effectrange,holder))
			to_chat(R, "<span class='warning'>SYSTEM ALERT: CPU cycles slowing down.</span>")
		return 1

/datum/artifact_effect/sleepy/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		for(var/mob/living/carbon/human/H in range(src.effectrange, T))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				to_chat(H, pick("<span class='notice'>You feel like taking a nap.</span>","<span class='notice'>You feel a yawn coming on.</span>","<span class='notice'>You feel a little tired.</span>"))
				H.AdjustDrowsy(rand(5,15) * weakness, bound_lower = 0, bound_upper = 50 * weakness)
				H.AdjustEyeBlurry(rand(5,15) * weakness, bound_lower = 0, bound_upper = 50 * weakness)
		for(var/mob/living/silicon/robot/R in range(src.effectrange,holder))
			to_chat(R, "<span class='warning'>SYSTEM ALERT: CPU cycles slowing down.</span>")
		return 1
