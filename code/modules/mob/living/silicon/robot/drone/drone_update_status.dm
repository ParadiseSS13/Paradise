//Easiest to check this here, then check again in the robot proc.
//Standard robots use config for crit, which is somewhat excessive for these guys.
/mob/living/silicon/robot/drone/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
	if(health <= -maxHealth && stat != DEAD)
		death()
		create_debug_log("died of damage, trigger reason: [reason]")
		return
	return ..(reason)
