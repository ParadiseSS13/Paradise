/mob/living/silicon/pai/Life()
	if (src.stat == 2)
		return
	if(src.cable)
		if(get_dist(src, src.cable) > 1)
			var/turf/T = get_turf_or_move(src.loc)
			for (var/mob/M in viewers(T))
				M.show_message("\red The data cable rapidly retracts back into its spool.", 3, "\red You hear a click and the sound of wire spooling rapidly.", 2)
			del(src.cable)
	sleeping = 0
	ear_deaf = 0

	if (src.paralysis || src.stunned || src.weakened) //Stunned etc.
		src.stat = 1
		if (src.stunned > 0)
			AdjustStunned(-1)
		if (src.weakened > 0)
			AdjustWeakened(-1)
		if (src.paralysis > 0)
			AdjustParalysis(-1)
			src.eye_blind = max(eye_blind, 1)
		else
			src.eye_blind = 0

	else	//Not stunned.
		src.stat = 0

	if(paralysis || stunned || weakened || buckled || resting || src.loc == card) canmove = 0
	else canmove = 1

	regular_hud_updates()
	if(src.secHUD == 1)
		process_sec_hud(src, 1)
	if(src.medHUD == 1)
		process_med_hud(src, 1)
	if(silence_time)
		if(world.timeofday >= silence_time)
			silence_time = null
			src << "<font color=green>Communication circuit reinitialized. Speech and messaging functionality restored.</font>"
	handle_statuses()
	handle_actions()

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = 100 - getBruteLoss() - getFireLoss()
	if(health <= 0)
		death(0)

