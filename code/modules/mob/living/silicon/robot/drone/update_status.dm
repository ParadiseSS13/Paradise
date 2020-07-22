//Easiest to check this here, then check again in the robot proc.
//Standard robots use config for crit, which is somewhat excessive for these guys.
//Drones killed by damage will gib.
/mob/living/silicon/robot/drone/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
	if(health <= -35 && stat != DEAD)
		gib()
		create_debug_log("died of damage, trigger reason: [reason]")
		return
	return ..(reason)
