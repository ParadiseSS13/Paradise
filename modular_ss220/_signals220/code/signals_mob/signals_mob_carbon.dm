// Signals for /mob/living/carbon
// Расширение прока для переноса ящика на моба
/mob/living/carbon/human/MouseDrop_T(atom/movable/AM, mob/user)
	if(SEND_SIGNAL(usr, COMSIG_GADOM_CAN_GRAB) & GADOM_CAN_GRAB)
		SEND_SIGNAL(usr, COMSIG_GADOM_LOAD, user, AM)
	. = .. ()
