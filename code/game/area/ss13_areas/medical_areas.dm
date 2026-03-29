
/area/station/medical
	ambientsounds = MEDICAL_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	min_ambience_cooldown = 90 SECONDS
	max_ambience_cooldown = 180 SECONDS
	airlock_wires = /datum/wires/airlock/medbay

/area/station/medical/medbay
	name = "\improper Medbay"
	icon_state = "medbay"
	request_console_flags = RC_ASSIST

//Medbay is a large area, these additional areas help level out APC load.
/area/station/medical/medbay2
	name = "\improper Medbay"
	icon_state = "medbay"

/area/station/medical/medbay3
	name = "\improper Medbay"
	icon_state = "medbay"

/area/station/medical/storage
	name = "Medical Storage"
	icon_state = "medbaystorage"
	request_console_flags = RC_ASSIST
	request_console_name = "Medbay"

/area/station/medical/reception
	name = "\improper Medbay Reception"
	icon_state = "medbaylobby"
	request_console_flags = RC_ASSIST
	request_console_name = "Medbay"

/area/station/medical/psych
	name = "\improper Psych Room"
	icon_state = "medbaypsych"
	request_console_flags = RC_SUPPLY
	request_console_name = "Psychiatrist"

/area/station/medical/break_room
	name = "\improper Medbay Break Room"
	icon_state = "medbaybreak"

/area/station/medical/patients_rooms
	name = "\improper Patient's Rooms"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/patients_rooms1
	name = "\improper Patient Room"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/patients_rooms_secondary
	name = "\improper Patient Room Secondary"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/coldroom
	name = "Cold Room"
	icon_state = "coldroom"

/area/station/medical/storage/secondary
	name = "Medical Secondary Storage"
	icon_state = "medbaysecstorage"

/area/station/medical/virology
	name = "Virology"
	icon_state = "virology"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/medical/virology/lab
	name = "\improper Virology Laboratory"

/area/station/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	ambientsounds = SPOOKY_SOUNDS
	is_haunted = TRUE
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_INFO

/area/station/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/medical/surgery
	name = "\improper Surgery"
	icon_state = "surgery"

/area/station/medical/surgery/primary
	name = "Surgery 1"
	icon_state = "surgery1"

/area/station/medical/surgery/secondary
	name = "Surgery 2"
	icon_state = "surgery2"

/area/station/medical/surgery/observation
	name = "Surgery Observation"

/area/station/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/station/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/station/medical/cloning
	name = "\improper Cloning Lab"
	icon_state = "cloning"

/area/station/medical/sleeper
	name = "\improper Medical Treatment Center"
	icon_state = "exam_room"

/area/station/medical/paramedic
	name = "Paramedic"
	icon_state = "paramedic"
	request_console_flags = RC_ASSIST
