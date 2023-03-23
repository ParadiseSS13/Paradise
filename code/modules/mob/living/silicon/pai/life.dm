/mob/living/silicon/pai/Life(seconds, times_fired)
	. = ..()
	if(QDELETED(src) || stat == DEAD)
		return
	if(silence_time)
		if(world.timeofday >= silence_time)
			silence_time = null
			to_chat(src, "<font color=green>Communication circuit reinitialized. Speech and messaging functionality restored.</font>")

	if(installed_software["doorjack"])
		var/datum/pai_software/door_jack/DJ = installed_software["doorjack"]
		if(DJ.cable)
			if(get_dist(src, DJ.cable) > 1)
				visible_message("<span class='warning'>The data cable connected to [src] rapidly retracts back into its spool!</span>")
				QDEL_NULL(DJ.cable)

	if(installed_software["sec_chem"])
		if(chemicals < initial(chemicals))
			if(world.time > (last_change_chemicals + 30 SECONDS))
				chemicals += 5
				last_change_chemicals = world.time

/mob/living/silicon/pai/updatehealth(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		return ..()
	health = maxHealth - getBruteLoss() - getFireLoss()
	update_stat("updatehealth([reason])", should_log)
