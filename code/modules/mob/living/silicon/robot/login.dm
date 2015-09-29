/mob/living/silicon/robot/Login()
	..()
	if(client)
		client.hotkeytype = "Cyborg"
	regenerate_icons()
	show_laws(0)
	if(mind)	ticker.mode.remove_cultist(mind)
	if(mind)	ticker.mode.remove_revolutionary(mind)
	if(mind)	ticker.mode.remove_thrall(mind,0)
	if(mind)	ticker.mode.remove_shadowling(mind)
	return
