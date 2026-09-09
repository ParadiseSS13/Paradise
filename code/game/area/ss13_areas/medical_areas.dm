
/area/station/medical
	ambientsounds = MEDICAL_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	min_ambience_cooldown = 90 SECONDS
	max_ambience_cooldown = 180 SECONDS
	airlock_wires = /datum/wires/airlock/medbay
	area_icon_color = AREA_COLOR_MEDBAY

/area/station/medical/medbay
	name = "\improper Medbay"
	icon_state = "medbay"
	area_icon_text = "MED"
	request_console_flags = RC_ASSIST

//Medbay is a large area, these additional areas help level out APC load.
/area/station/medical/medbay2
	name = "\improper Medbay"
	icon_state = "medbay"
	area_icon_text = "MED"

/area/station/medical/medbay3
	name = "\improper Medbay"
	icon_state = "medbay"
	area_icon_text = "MED"

/area/station/medical/storage
	name = "Medical Storage"
	icon_state = "medbaystorage"
	area_icon_text = "MED\nSTORE"
	request_console_flags = RC_ASSIST
	request_console_name = "Medbay"

/area/station/medical/reception
	name = "\improper Medbay Reception"
	icon_state = "medbaylobby"
	area_icon_text = "MED\nLOBBY"
	request_console_flags = RC_ASSIST
	request_console_name = "Medbay"

/area/station/medical/psych
	name = "\improper Psych Room"
	icon_state = "medbaypsych"
	area_icon_text = "PSYCH"
	request_console_flags = RC_SUPPLY
	request_console_name = "Psychiatrist"

/area/station/medical/break_room
	name = "\improper Medbay Break Room"
	icon_state = "medbaybreak"
	area_icon_text = "MED\nBREAK"

/area/station/medical/patients_rooms
	name = "\improper Patient's Rooms"
	icon_state = "patients"
	area_icon_text = "PATIENT\nROOM"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/patients_rooms1
	name = "\improper Patient Room"
	icon_state = "patients"
	area_icon_text = "PATIENT\nROOM"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/patients_rooms_secondary
	name = "\improper Patient Room Secondary"
	icon_state = "patients"
	area_icon_text = "PATIENT\nROOM"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/coldroom
	name = "Cold Room"
	icon_state = "coldroom"
	area_icon_text = "COLD\nROOM"

/area/station/medical/storage/secondary
	name = "Medical Secondary Storage"
	icon_state = "medbaysecstorage"
	area_icon_text = "MED\n2ND\nSTORE"

/area/station/medical/virology
	name = "Virology"
	icon_state = "virology"
	area_icon_text = "VIRO"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/medical/virology/lab
	name = "\improper Virology Laboratory"

/area/station/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	area_icon_text = "MORGUE"
	ambientsounds = SPOOKY_SOUNDS
	is_haunted = TRUE
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_INFO

/area/station/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"
	area_icon_text = "MED\nCHEM"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/medical/surgery
	name = "\improper Surgery"
	icon_state = "surgery"
	area_icon_text = "SURGERY"

/area/station/medical/surgery/primary
	name = "Surgery 1"
	icon_state = "surgery1"
	area_icon_text = "SURGERY\nONE"

/area/station/medical/surgery/secondary
	name = "Surgery 2"
	icon_state = "surgery2"
	area_icon_text = "SURGERY\nTWO"

/area/station/medical/surgery/observation
	name = "Surgery Observation"

/area/station/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"
	area_icon_text = "CRYO"

/area/station/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"
	area_icon_text = "EXAM\nROOM"

/area/station/medical/cloning
	name = "\improper Cloning Lab"
	icon_state = "cloning"
	area_icon_text = "CLONE"

/area/station/medical/sleeper
	name = "\improper Medical Treatment Center"
	icon_state = "exam_room"

/area/station/medical/paramedic
	name = "Paramedic"
	icon_state = "paramedic"
	area_icon_text = "PARA\nMED"
	request_console_flags = RC_ASSIST
