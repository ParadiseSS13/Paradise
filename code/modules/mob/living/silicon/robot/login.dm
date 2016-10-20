/mob/living/silicon/robot/Login()
	..()
	if(client)
		client.hotkeytype = "Cyborg"
	regenerate_icons()
	show_laws(0)
