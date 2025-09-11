// Расширение прока на отстегивание ящика
/datum/species/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	if((SEND_SIGNAL(H, COMSIG_GADOM_CAN_GRAB)  & GADOM_CAN_GRAB) && H.loaded)
		SEND_SIGNAL(H, COMSIG_GADOM_UNLOAD)
	. = .. ()
