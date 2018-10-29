/mob/living/silicon/pai/Life(seconds, times_fired)
	. = ..()
	if(.)
		//if(secHUD == 1)
		//	process_sec_hud(src, 1)
		////if(medHUD == 1)
		//	process_med_hud(src, 1)
		if(silence_time)
			if(world.timeofday >= silence_time)
				silence_time = null
				to_chat(src, "<font color=green>Communication circuit reinitialized. Speech and messaging functionality restored.</font>")

		if(cable)
			if(get_dist(src, cable) > 1)
				var/turf/T = get_turf_or_move(loc)
				for(var/mob/M in viewers(T))
					M.show_message("<span class='warning'>The data cable rapidly retracts back into its spool.</span>", 3, "<span class='warning'>You hear a click and the sound of wire spooling rapidly.</span>", 2)
				qdel(src.cable)
				cable = null

/mob/living/silicon/pai/updatehealth(reason = "none given")
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = 100 - getBruteLoss() - getFireLoss()
		update_stat("updatehealth([reason])")
