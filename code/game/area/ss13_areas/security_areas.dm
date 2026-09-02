
/area/station/security
	ambientsounds = HIGHSEC_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_wires = /datum/wires/airlock/security
	area_icon_color = AREA_COLOR_SECURITY
	area_light_color = LIGHT_COLOR_STATION_WORK
	area_nightlight_color = LIGHT_COLOR_STATION_WORK_NIGHT

/area/station/security/main
	name = "\improper Security Office"
	icon_state = "securityoffice"
	area_icon_text = "SEC\nOFFICE"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Security"

/area/station/security/lobby
	name = "\improper Security Lobby"
	icon_state = "securitylobby"
	area_icon_text = "SEC\nLOBBY"

/area/station/security/brig
	name = "\improper Brig"
	icon_state = "brig"
	area_icon_text = "BRIG"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Security"

/area/station/security/brig/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = FALSE
		temp_closet.close()
	for(var/obj/machinery/door_timer/temp_timer in src)
		temp_timer.releasetime = 1
	..()

/area/station/security/permabrig
	name = "\improper Prison Wing"
	icon_state = "sec_prison_perma"
	area_icon_text = "PRISON\nPERMA"
	fast_despawn = TRUE
	can_get_auto_cryod = FALSE

/area/station/security/prison
	name = "\improper Prison Wing"
	icon_state = "sec_prison"
	area_icon_text = "PRISON"
	can_get_auto_cryod = FALSE

/area/station/security/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = FALSE
		temp_closet.close()
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in src)
		temp_timer.releasetime = 1
	..()

/area/station/security/prison/cell_block
	name = "\improper Prison Cell Block"
	icon_state = "brig"

/area/station/security/prison/cell_block/a
	name = "\improper Prison Cell Block A"
	icon_state = "brigcella"
	area_icon_text = "CELL\nBLOCK\nA"

/area/station/security/execution
	name = "Execution"
	icon_state = "execution"
	area_icon_text = "EXECUTE"
	can_get_auto_cryod = FALSE

/area/station/security/processing
	name = "Prisoner Processing"
	icon_state = "prisonerprocessing"
	area_icon_text = "PRISON\nPROCESS"
	can_get_auto_cryod = FALSE

/area/station/security/interrogation
	name = "Interrogation"
	icon_state = "interrogation"
	area_icon_text = "INTERR."
	can_get_auto_cryod = FALSE

/area/station/security/storage
	name = "Security Equipment Storage"
	icon_state = "securityequipmentstorage"
	area_icon_text = "SEC\nEQUIP\nSTORE"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Security"

/area/station/security/evidence
	name = "\improper Evidence Room"
	icon_state = "evidence"
	area_icon_text = "EVIDENCE"

/area/station/security/prisonlockers
	name = "\improper Prisoner Lockers"
	icon_state = "sec_prison_lockers"
	area_icon_text = "PRISON\nLOCKER"
	can_get_auto_cryod = FALSE

/area/station/security/prisonershuttle
	name = "\improper Security Prisoner Shuttle"
	icon_state = "security"
	area_icon_text = "SEC"
	can_get_auto_cryod = FALSE

/area/station/security/warden
	name = "\improper Warden's Office"
	icon_state = "Warden"
	area_icon_text = "WARDEN"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	request_console_flags = RC_ASSIST | RC_SUPPLY | RC_INFO
	request_console_name = "Warden"

/area/station/security/armory
	name = "\improper Armory"
	icon_state = "armory"
	area_icon_text = "ARMORY"

/area/station/security/armory/secure
	name = "\improper Secure Armory"
	icon_state = "secarmory"
	area_icon_text = "SECURE\nARMORY"
	request_console_flags = RC_ASSIST | RC_SUPPLY | RC_INFO
	request_console_name = "Warden"

/area/station/security/detective
	name = "\improper Detective's Office"
	icon_state = "detective"
	area_icon_text = "DET\nOFFICE"
	ambientsounds = list('sound/ambience/ambidet1.ogg', 'sound/ambience/ambidet2.ogg')
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Detective"

/area/station/security/range
	name = "\improper Firing Range"
	icon_state = "firingrange"
	area_icon_text = "FIRING\nRANGE"

/area/station/security/defusal
	name = "\improper Defusal Workshop"
	icon_state = "defusal"
	area_icon_text = "DEF"

/area/station/security/gamma_dock_access
	name = "\improper Gamma Armory Dock Access"
	icon_state = "gamma_access"

/area/station/security/gamma_dock
	name = "\improper Gamma Armory Dock"
	icon_state = "gamma_dock"

// Checkpoints

/area/station/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint1"
	area_icon_text = "SEC\nCHECK\nPOINT"

/area/station/security/checkpoint/secondary
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Security"

// Solitary
/area/station/security/permasolitary
	name = "Solitary Confinement"
	icon_state = "solitary"
	area_icon_text = "SOLITARY"
