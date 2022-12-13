//Most of these are defined at this level to reduce on checks elsewhere in the code.
//Having them here also makes for a nice reference list of the various overlay-updating procs available

/mob/proc/regenerate_icons()		//TODO: phase this out completely if possible
	SEND_SIGNAL(src, COMSIG_MOB_REGENERATE_ICONS)
	return

/mob/proc/update_icons()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_ICONS)
	return

/mob/proc/update_inv_handcuffed()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_HANDCUFFED)
	return

/mob/proc/update_inv_legcuffed()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_LEGCUFFED)
	return

/mob/proc/update_inv_back()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_BACK)
	return

/mob/proc/update_inv_l_hand()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_L_HAND)
	return

/mob/proc/update_inv_r_hand()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_R_HAND)
	return

/mob/proc/update_inv_wear_mask()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_WEAR_MASK)
	return

/mob/proc/update_inv_wear_suit()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_WEAR_SUIT)
	return

/mob/proc/update_inv_w_uniform()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_W_UNIFORM)
	return

/mob/proc/update_inv_belt()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_BELT)
	return

/mob/proc/update_inv_head()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_HEAD)
	return

/mob/proc/update_inv_gloves()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_GLOVES)
	return

/mob/proc/update_inv_neck()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_NECK)
	return

/mob/proc/update_mutations()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_MUTATIONS)
	return

/mob/proc/update_inv_wear_id()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_WEAR_ID)
	return

/mob/proc/update_inv_shoes()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_SHOES)
	return

/mob/proc/update_inv_glasses()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_GLASSES)
	return

/mob/proc/update_inv_s_store()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_S_STORE)
	return

/mob/proc/update_inv_pockets()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_POCKETS)
	return

/mob/proc/update_inv_wear_pda()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_WEAR_PDA)
	return

/mob/proc/update_inv_ears()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_INV_EARS)
	return

/mob/proc/update_transform()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_TRANSFORM)
	return
