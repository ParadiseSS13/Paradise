/mob/living/death(gibbed)
	blinded = max(blinded, 1)

	clear_fullscreens()
	update_action_buttons_icon()
	..(gibbed)