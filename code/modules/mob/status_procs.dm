// A bunch of empty procs for all the status procs in living/status_procs.dm, because
// I can't be bothered to deal with all the merge conflicts it would cause to
// typecast every mob in the codebase correctly

/mob/proc/Confused()
	return

/mob/proc/SetConfused()
	return

/mob/proc/AdjustConfused()
	return


/mob/proc/Dizzy()
	return

/mob/proc/SetDizzy()
	return

/mob/proc/AdjustDizzy()
	return


/mob/proc/Drowsy()
	return

/mob/proc/SetDrowsy()
	return

/mob/proc/AdjustDrowsy()
	return


/mob/proc/Drunk()
	return

/mob/proc/SetDrunk()
	return

/mob/proc/AdjustDrunk()
	return


/mob/proc/Druggy()
	return

/mob/proc/SetDruggy()
	return

/mob/proc/AdjustDruggy()
	return


/mob/proc/RestoreEars()
	return

/mob/proc/AdjustEarDamage()
	return

/mob/proc/MinimumDeafTicks()
	return


/mob/proc/EyeBlind()
	return

/mob/proc/SetEyeBlind()
	return

/mob/proc/AdjustEyeBlind()
	return


/mob/proc/EyeBlurry()
	return

/mob/proc/SetEyeBlurry()
	return

/mob/proc/AdjustEyeBlurry()
	return


/mob/proc/Hallucinate()
	return

/mob/proc/SetHallucinate()
	return

/mob/proc/AdjustHallucinate()
	return


/mob/proc/Jitter()
	return

/mob/proc/SetJitter()
	return

/mob/proc/AdjustJitter()
	return


/mob/proc/LoseBreath()
	return

/mob/proc/SetLoseBreath()
	return

/mob/proc/AdjustLoseBreath()
	return


/mob/proc/Paralyse()
	return

/mob/proc/SetParalysis()
	return

/mob/proc/AdjustParalysis()
	return


/mob/proc/Silence()
	return

/mob/proc/SetSilence()
	return

/mob/proc/AdjustSilence()
	return


/mob/proc/Sleeping()
	return

/mob/proc/SetSleeping()
	return

/mob/proc/AdjustSleeping()
	return


/mob/proc/Slowed()
	return

/mob/proc/SetSlowed()
	return

/mob/proc/AdjustSlowed()
	return


/mob/proc/Slur()
	return

/mob/proc/SetSlur()
	return

/mob/proc/AdjustSlur()
	return

/mob/proc/CultSlur()
	return

/mob/proc/SetCultSlur()
	return

/mob/proc/AdjustCultSlur()
	return

/mob/proc/Stun()
	return

/mob/proc/SetStunned()
	return

/mob/proc/AdjustStunned()
	return


/mob/proc/Stuttering()
	return

/mob/proc/SetStuttering()
	return

/mob/proc/AdjustStuttering()
	return


/mob/proc/Weaken()
	return

/mob/proc/SetWeakened()
	return

/mob/proc/AdjustWeakened()
	return

/mob/proc/adjust_bodytemperature(amount, min_temp = 0, max_temp = INFINITY)
	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		bodytemperature = Clamp(bodytemperature + amount, min_temp, max_temp)