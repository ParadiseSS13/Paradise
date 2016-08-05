/mob/living/carbon/alien/humanoid/Login()
	..()
	if(!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	return
