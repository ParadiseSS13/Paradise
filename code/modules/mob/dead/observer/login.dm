/mob/dead/observer/Login()
	..()
	if (ghostimage)
		ghostimage.icon_state = src.icon_state
	updateghostimages()
	
	update_interface()