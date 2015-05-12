/mob/living/silicon/pai/Life()
	if (src.stat == 2)
		return
	if(src.cable)
		if(get_dist(src, src.cable) > 1)
			var/turf/T = get_turf_or_move(src.loc)
			for (var/mob/M in viewers(T))
				M.show_message("\red The data cable rapidly retracts back into its spool.", 3, "\red You hear a click and the sound of wire spooling rapidly.", 2)
			del(src.cable)

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

