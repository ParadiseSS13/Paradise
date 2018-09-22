/mob/living/death(gibbed)
	blinded = max(blinded, 1)

	if(suiciding)
		mind.suicided = TRUE

	clear_fullscreens()
	update_action_buttons_icon()

	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerDies(gibbed, src)
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerDies(gibbed, src)

	med_hud_set_health()
	med_hud_set_status()

	..(gibbed)
