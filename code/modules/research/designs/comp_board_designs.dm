///////////////////////////////////
//////////Computer Boards//////////
///////////////////////////////////

datum/design/seccamera
	name = "Console Board (Camera Monitor)"
	desc = "Allows for the construction of circuit boards used to build camera monitors."
	id = "seccamera"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/camera

datum/design/aicore
	name = "Console Board (AI Core)"
	desc = "Allows for the construction of circuit boards used to build new AI cores."
	id = "aicore"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aicore

datum/design/aiupload
	name = "Console Board (AI Upload)"
	desc = "Allows for the construction of circuit boards used to build an AI Upload Console."
	id = "aiupload"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aiupload

datum/design/borgupload
	name = "Console Board (Cyborg Upload)"
	desc = "Allows for the construction of circuit boards used to build a Cyborg Upload Console."
	id = "borgupload"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/borgupload

datum/design/med_data
	name = "Console Board (Medical Records)"
	desc = "Allows for the construction of circuit boards used to build a medical records console."
	id = "med_data"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/med_data

datum/design/operating
	name = "Console Board (Operating Computer)"
	desc = "Allows for the construction of circuit boards used to build an operating computer console."
	id = "operating"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/operating

datum/design/pandemic
	name = "Console Board (PanD.E.M.I.C. 2200)"
	desc = "Allows for the construction of circuit boards used to build a PanD.E.M.I.C. 2200 console."
	id = "pandemic"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pandemic

datum/design/scan_console
	name = "Console Board (DNA Machine)"
	desc = "Allows for the construction of circuit boards used to build a new DNA scanning console."
	id = "scan_console"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/scan_consolenew

datum/design/comconsole
	name = "Console Board (Communications Console)"
	desc = "Allows for the construction of circuit boards used to build a communications console."
	id = "comconsole"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/communications

datum/design/idcardconsole
	name = "Console Board (ID Computer)"
	desc = "Allows for the construction of circuit boards used to build an ID computer."
	id = "idcardconsole"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/card

datum/design/crewconsole
	name = "Console Board (Crew Monitoring Computer)"
	desc = "Allows for the construction of circuit boards used to build a Crew monitoring computer."
	id = "crewconsole"
	req_tech = list("programming" = 3, "magnets" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/crew

datum/design/teleconsole
	name = "Console Board (Teleporter Console)"
	desc = "Allows for the construction of circuit boards used to build a teleporter control console."
	id = "teleconsole"
	req_tech = list("programming" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter

datum/design/secdata
	name = "Console Board (Security Records Console)"
	desc = "Allows for the construction of circuit boards used to build a security records console."
	id = "secdata"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/secure_data

datum/design/atmosalerts
	name = "Console Board (Atmosphere Alert)"
	desc = "Allows for the construction of circuit boards used to build an atmosphere alert console.."
	id = "atmosalerts"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/atmos_alert

datum/design/air_management
	name = "Console Board (Atmospheric Monitor)"
	desc = "Allows for the construction of circuit boards used to build an Atmospheric Monitor."
	id = "air_management"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/air_management

datum/design/robocontrol
	name = "Console Board (Robotics Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Robotics Control console."
	id = "robocontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/robotics

datum/design/dronecontrol
	name = "Console Board (Drone Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Drone Control console."
	id = "dronecontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/drone_control

datum/design/clonecontrol
	name = "Console Board (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cloning

datum/design/powermonitor
	name = "Console Board (Power Monitor)"
	desc = "Allows for the construction of circuit boards used to build a new power monitor"
	id = "powermonitor"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/powermonitor

datum/design/solarcontrol
	name = "Console Board (Solar Control)"
	desc = "Allows for the construction of circuit boards used to build a solar control console"
	id = "solarcontrol"
	req_tech = list("programming" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/solar_control

datum/design/prisonmanage
	name = "Console Board (Prisoner Management Console)"
	desc = "Allows for the construction of circuit boards used to build a prisoner management console."
	id = "prisonmanage"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/prisoner

datum/design/mechacontrol
	name = "Console Board (Exosuit Control Console)"
	desc = "Allows for the construction of circuit boards used to build an exosuit control console."
	id = "mechacontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha_control

datum/design/mechapower
	name = "Console Board (Mech Bay Power Control Console)"
	desc = "Allows for the construction of circuit boards used to build a mech bay power control console."
	id = "mechapower"
	req_tech = list("programming" = 2, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_bay_power_console

datum/design/rdconsole
	name = "Console Board (R&D Console)"
	desc = "Allows for the construction of circuit boards used to build a new R&D console."
	id = "rdconsole"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdconsole

datum/design/ordercomp
	name = "Console Board (Supply Ordering Console)"
	desc = "Allows for the construction of circuit boards used to build a supply ordering console."
	id = "ordercomp"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ordercomp

datum/design/supplycomp
	name = "Console Board (Supply Shuttle Console)"
	desc = "Allows for the construction of circuit boards used to build a supply shuttle console."
	id = "supplycomp"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/supplycomp

datum/design/comm_monitor
	name = "Console Board (Telecommunications Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications monitor."
	id = "comm_monitor"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_monitor

datum/design/comm_server
	name = "Console Board (Telecommunications Server Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunication server browser and monitor."
	id = "comm_server"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_server

datum/design/message_monitor
	name = "Console Board (Messaging Monitor Console)"
	desc = "Allows for the construction of circuit boards used to build a messaging monitor console."
	id = "message_monitor"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/message_monitor

datum/design/comm_traffic
	name = "Console Board (Telecommunications Traffic Control Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications traffic control console."
	id = "comm_traffic"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_traffic

datum/design/telesci_console
	name = "Console Board (Telepad Control Console Board)"
	desc = "Allows for the construction of circuit boards used to build a telescience console."
	id = "telesci_console"
	req_tech = list("programming" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_console

datum/design/aifixer
	name = "Console Board (AI Integrity Restorer)"
	desc = "Allows for the construction of circuit boards used to build an AI Integrity Restorer."
	id = "aifixer"
	req_tech = list("programming" = 3, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aifixer
	
datum/design/rdservercontrol
	name = "Console Board (R&D Server Control Console)"
	desc = "The circuit board for a R&D Server Control Console"
	id = "rdservercontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdservercontrol