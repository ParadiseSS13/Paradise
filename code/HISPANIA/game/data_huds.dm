//borg-AI shell tracking
/mob/living/silicon/robot/proc/diag_hud_set_aishell() //Shows tracking beacons on the mech
	var/image/holder = hud_list[DIAG_TRACK_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(!shell) //Not an AI shell
		holder.icon_state = null
	else if(deployed) //AI shell in use by an AI
		holder.icon_state = "hudtrackingai"
	else	//Empty AI shell
		holder.icon_state = "hudtracking"

//AI side tracking of AI shell control
/mob/living/silicon/ai/proc/diag_hud_set_deployed() //Shows tracking beacons on the mech
	var/image/holder = hud_list[DIAG_TRACK_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(!deployed_shell)
		holder.icon_state = null
	else //AI is currently controlling a shell
		holder.icon_state = "hudtrackingai"
