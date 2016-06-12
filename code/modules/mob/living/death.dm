/mob/living/death(gibbed)
	blinded = max(blinded, 1)

	clear_fullscreens()
	..(gibbed)