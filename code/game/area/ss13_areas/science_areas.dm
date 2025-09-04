// Robotics areas

/area/station/science/robotics
	name = "\improper Robotics Lab"
	icon_state = "robo"
	request_console_flags = RC_SUPPLY
	request_console_name = "Robotics"

/area/station/science/robotics/chargebay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/station/science/robotics/showroom
	name = "\improper Robotics Showroom"
	icon_state = "showroom"

/area/station/science/research
	name = "Research Division"
	icon_state = "sci"

/area/station/science/lobby
	name = "Research Division Lobby"
	icon_state = "sci"

/area/station/science/testrange
	name = "Research Test Range"
	icon_state = "sci"

/area/station/science/break_room
	name = "\improper Science Break Room"
	icon_state = "scibreak"

/area/station/science/genetics
	name = "\improper Genetics Lab"
	icon_state = "genetics"
	request_console_flags = RC_ASSIST
	request_console_name = "Genetics"

/area/station/science
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_wires = /datum/wires/airlock/science

/area/station/science/rnd
	name = "Research and Development"
	icon_state = "rnd"
	request_console_flags = RC_SUPPLY
	request_console_name = "Science"

/area/station/science/hallway
	name = "\improper Research Lab"
	icon_state = "sci"

/area/station/science/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xenobio"
	xenobiology_compatible = TRUE
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Xenobiology"

/area/station/science/storage
	name = "\improper Science Toxins Storage"
	icon_state = "toxstorage"

/area/station/science/toxins/test
	name = "\improper Toxins Test Area"
	icon_state = "toxtest"
	valid_territory = FALSE

/area/station/science/toxins/mixing
	name = "\improper Toxins Mixing Room"
	icon_state = "toxmix"
	request_console_flags = RC_SUPPLY
	request_console_name = "Science"

/area/station/science/toxins/launch
	name = "\improper Toxins Launch Room"
	icon_state = "toxlaunch"
	request_console_flags = RC_SUPPLY
	request_console_name = "Science"

/area/station/science/misc_lab
	name = "\improper Research Testing Lab"
	icon_state = "scichem"
	request_console_flags = RC_SUPPLY
	request_console_name = "Science"

/area/station/science/test_chamber
	name = "\improper Research Testing Chamber"
	icon_state = "scitest"

/area/station/science/server
	name = "\improper Server Room"
	icon_state = "server"
	airlock_wires = /datum/wires/airlock/command // Like every one has command doors.

/area/station/science/server/coldroom
	name = "\improper Server Coldroom"
	icon_state = "servercold"
