/datum/surgery/infection
	name = "External Infection Treatment"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/heal_infection, /datum/surgery_step/generic/cauterize)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)

/datum/surgery_step/heal_infection
