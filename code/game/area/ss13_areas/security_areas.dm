
/area/station/security
	ambientsounds = HIGHSEC_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/security/main
	name = "\improper Security Office"
	icon_state = "securityoffice"

/area/station/security/lobby
	name = "\improper Security Lobby"
	icon_state = "securitylobby"

/area/station/security/brig
	name = "\improper Brig"
	icon_state = "brig"

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
	fast_despawn = TRUE
	can_get_auto_cryod = FALSE

/area/station/security/prison
	name = "\improper Prison Wing"
	icon_state = "sec_prison"
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

/area/station/security/prison/cell_block/A
	name = "\improper Prison Cell Block A"
	icon_state = "brigcella"

/area/station/security/execution
	name = "Execution"
	icon_state = "execution"
	can_get_auto_cryod = FALSE

/area/station/security/processing
	name = "Prisoner Processing"
	icon_state = "prisonerprocessing"
	can_get_auto_cryod = FALSE

/area/station/security/interrogation
	name = "Interrogation"
	icon_state = "interrogation"
	can_get_auto_cryod = FALSE

/area/station/security/storage
	name = "Security Equipment Storage"
	icon_state = "securityequipmentstorage"

/area/station/security/evidence
	name = "\improper Evidence Room"
	icon_state = "evidence"

/area/station/security/prisonlockers
	name = "\improper Prisoner Lockers"
	icon_state = "sec_prison_lockers"
	can_get_auto_cryod = FALSE

/area/station/security/prisonershuttle
	name = "\improper Security Prisoner Shuttle"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/station/security/warden
	name = "\improper Warden's Office"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/armory
	name = "\improper Armory"
	icon_state = "armory"

/area/station/security/armory/secure
	name = "\improper Secure Armory"
	icon_state = "secarmory"

/area/station/security/detective
	name = "\improper Detective's Office"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg', 'sound/ambience/ambidet2.ogg')

/area/station/security/range
	name = "\improper Firing Range"
	icon_state = "firingrange"

// Checkpoints

/area/station/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint1"

/area/station/security/checkpoint/secondary
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint1"

// Solitary
/area/station/security/permasolitary
	name = "Solitary Confinement"
	icon_state = "solitary"
