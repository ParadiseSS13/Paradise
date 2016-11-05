//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/alien/larva
	var/temperature_alert = 0
	low_oxy_ko = 25
	min_health = -25

/mob/living/carbon/alien/larva/Life()
	. = ..()
	if(.) //still breathing
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++
