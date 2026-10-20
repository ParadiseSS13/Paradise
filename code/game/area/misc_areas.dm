/// will be unused once kurper gets his login interface patch done
/area/start
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	ambientsounds = null // No ambient sounds in the lobby


/area/space
	icon_state = "space"
	area_icon_text = "SPACE"
	area_icon_color = AREA_COLOR_TRANSPARENT
	requires_power = FALSE
	always_unpowered = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	valid_territory = FALSE
	outdoors = TRUE
	ambientsounds = SPACE_SOUNDS
	sound_environment = SOUND_AREA_SPACE

/area/space/nearstation
	icon_state = "space_near"
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT

/area/space/nearstation/disposals
	icon_state = "nearspace_disposals"

/area/space/nearstation/centcom
	icon_state = "space_near_cc"

/area/space/nearstation/no_teleport
	icon_state = "space_near_notp"
	tele_proof = TRUE

/area/space/atmosalert()
	return

/area/space/firealert(obj/source)
	return

/area/space/firereset(obj/source)
	return

/area/space/centcomm
	icon_state = "space_cc"
	area_icon_text = "SPACE\nCC"

/area/space/no_teleport
	icon_state = "space_notp"
	area_icon_text = "SPACE\nNOTP"
	tele_proof = TRUE

/area/game_test
	name = "Game Test Area"
	requires_power = FALSE

//SYNDICATES

/area/syndicate_mothership
	name = "\improper Syndicate Forward Base"
	icon_state = "syndie-ship"
	area_icon_text = "SYNDI\nSHIP"
	area_icon_color = AREA_COLOR_SECURITY
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	nad_allowed = TRUE
	ambientsounds = HIGHSEC_SOUNDS

/area/syndicate_mothership/jail
	name = "\improper Syndicate Jail"

/area/cordon
	name = "CORDON"
	icon_state = "cordon"
	requires_power = FALSE
	always_unpowered = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	valid_territory = FALSE
