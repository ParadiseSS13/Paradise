/mob/living/silicon/pai/update_stat(reason = "none given")
	if(health <= 0)
		death(gibbed = 0)
		create_debug_log("died of damage, trigger reason: [reason]")
