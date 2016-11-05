/mob/proc/update_pull_hud_icon()
	if(client && hud_used)
		if(hud_used.pull_icon)
			hud_used.pull_icon.update_icon(src)
