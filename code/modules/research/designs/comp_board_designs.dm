///////////////////////////////////
//////////Computer Boards//////////
///////////////////////////////////

/datum/design/aicore
	name = "Console Board (AI Core)"
	desc = "Allows for the construction of circuit boards used to build new AI cores."
	id = "aicore"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/aicore
	category = list("Computer Boards")

/datum/design/aifixer
	name = "Console Board (AI Integrity Restorer)"
	desc = "Allows for the construction of circuit boards used to build an AI Integrity Restorer."
	id = "aifixer"
	req_tech = list("programming" = 4, "magnets" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/aifixer
	category = list("Computer Boards")

/datum/design/aiupload
	name = "Console Board (AI Upload)"
	desc = "Allows for the construction of circuit boards used to build an AI Upload Console."
	id = "aiupload"
	req_tech = list("programming" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/aiupload
	category = list("Computer Boards")

/datum/design/atmosalerts
	name = "Console Board (Atmospheric Alerts)"
	desc = "Allows for the construction of circuit boards used to build an atmosphere alert console.."
	id = "atmosalerts"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/atmos_alert
	category = list("Computer Boards")

/datum/design/air_management
	name = "Console Board (Atmospheric Monitor)"
	desc = "Allows for the construction of circuit boards used to build an Atmospheric Monitor."
	id = "air_management"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/air_management
	category = list("Computer Boards")

/datum/design/seccamera
	name = "Console Board (Camera Monitor)"
	desc = "Allows for the construction of circuit boards used to build camera monitors."
	id = "seccamera"
	req_tech = list("programming" = 2, "combat" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/camera
	category = list("Computer Boards")

/datum/design/clonecontrol
	name = "Console Board (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/cloning
	category = list("Computer Boards")

/datum/design/comconsole
	name = "Console Board (Communications Console)"
	desc = "Allows for the construction of circuit boards used to build a communications console."
	id = "comconsole"
	req_tech = list("programming" = 3, "magnets" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/communications
	category = list("Computer Boards")

/datum/design/crewconsole
	name = "Console Board (Crew Monitoring Computer)"
	desc = "Allows for the construction of circuit boards used to build a Crew monitoring computer."
	id = "crewconsole"
	req_tech = list("programming" = 3, "magnets" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/crew
	category = list("Computer Boards")

/datum/design/borgupload
	name = "Console Board (Cyborg Upload)"
	desc = "Allows for the construction of circuit boards used to build a Cyborg Upload Console."
	id = "borgupload"
	req_tech = list("programming" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/borgupload
	category = list("Computer Boards")

/datum/design/scan_console
	name = "Console Board (DNA Machine)"
	desc = "Allows for the construction of circuit boards used to build a new DNA scanning console."
	id = "scan_console"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/scan_consolenew
	category = list("Computer Boards")

/datum/design/dronecontrol
	name = "Console Board (Drone Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Drone Control console."
	id = "dronecontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/drone_control
	category = list("Computer Boards")

/datum/design/mechacontrol
	name = "Console Board (Exosuit Control Console)"
	desc = "Allows for the construction of circuit boards used to build an exosuit control console."
	id = "mechacontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha_control
	category = list("Computer Boards")

/datum/design/idcardconsole
	name = "Console Board (ID Computer)"
	desc = "Allows for the construction of circuit boards used to build an ID computer."
	id = "idcardconsole"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/card
	category = list("Computer Boards")

/datum/design/mechapower
	name = "Console Board (Mech Bay Power Control Console)"
	desc = "Allows for the construction of circuit boards used to build a mech bay power control console."
	id = "mechapower"
	req_tech = list("programming" = 3, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mech_bay_power_console
	category = list("Computer Boards")

/datum/design/med_data
	name = "Console Board (Medical Records)"
	desc = "Allows for the construction of circuit boards used to build a medical records console."
	id = "med_data"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/med_data
	category = list("Computer Boards")

/datum/design/message_monitor
	name = "Console Board (Messaging Monitor Console)"
	desc = "Allows for the construction of circuit boards used to build a messaging monitor console."
	id = "message_monitor"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/message_monitor
	category = list("Computer Boards")

/datum/design/operating
	name = "Console Board (Operating Computer)"
	desc = "Allows for the construction of circuit boards used to build an operating computer console."
	id = "operating"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/operating
	category = list("Computer Boards")

/datum/design/pandemic
	name = "Computer Design (PanD.E.M.I.C. 2200)"
	desc = "Allows for the construction of circuit boards used to build a PanD.E.M.I.C. 2200 console."
	id = "pandemic"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/pandemic
	category = list("Computer Boards")

/datum/design/powermonitor
	name = "Console Board (Power Monitor)"
	desc = "Allows for the construction of circuit boards used to build a new power monitor"
	id = "powermonitor"
	req_tech = list("programming" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/powermonitor
	category = list("Computer Boards")

/datum/design/prisonmanage
	name = "Console Board (Prisoner Management Console)"
	desc = "Allows for the construction of circuit boards used to build a prisoner management console."
	id = "prisonmanage"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/prisoner
	category = list("Computer Boards")

/datum/design/brigcells
	name = "Console Board (Brig Cell Management Console)"
	desc = "Allows for the construction of circuit boards used to build a brig cell management console."
	id = "brigcells"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/brigcells
	category = list("Computer Boards")

/datum/design/rdconsole
	name = "Console Board (R&D Console)"
	desc = "Allows for the construction of circuit boards used to build a new R&D console. Can be swiped with a Scientist level ID to manage access levels."
	id = "rdconsole"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/rdconsole
	category = list("Computer Boards")

/datum/design/rdservercontrol
	name = "Console Board (R&D Server Control Console)"
	desc = "The circuit board for a R&D Server Control Console"
	id = "rdservercontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/rdservercontrol
	category = list("Computer Boards")

/datum/design/robocontrol
	name = "Console Board (Robotics Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Robotics Control console."
	id = "robocontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/robotics
	category = list("Computer Boards")

/datum/design/secdata
	name = "Console Board (Security Records Console)"
	desc = "Allows for the construction of circuit boards used to build a security records console."
	id = "secdata"
	req_tech = list("programming" = 2, "combat" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/secure_data
	category = list("Computer Boards")

/datum/design/solarcontrol
	name = "Console Board (Solar Control)"
	desc = "Allows for the construction of circuit boards used to build a solar control console"
	id = "solarcontrol"
	req_tech = list("programming" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/solar_control
	category = list("Computer Boards")

/datum/design/spacepodlocator
	name = "Console Board (Spacepod Locator)"
	desc = "Allows for the construction of circuit boards used to build a space-pod locating console"
	id = "spacepodc"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/pod_locater
	category = list("Computer Boards")

/datum/design/ordercomp
	name = "Console Board (Supply Ordering Console)"
	desc = "Allows for the construction of circuit boards used to build a supply ordering console."
	id = "ordercomp"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/ordercomp
	category = list("Computer Boards")

/datum/design/supplycomp
	name = "Console Board (Supply Shuttle Console)"
	desc = "Allows for the construction of circuit boards used to build a supply shuttle console."
	id = "supplycomp"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/supplycomp
	category = list("Computer Boards")

/datum/design/comm_monitor
	name = "Console Board (Telecommunications Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications monitor."
	id = "comm_monitor"
	req_tech = list("programming" = 3, "magnets" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/comm_monitor
	category = list("Computer Boards")

/datum/design/comm_server
	name = "Console Board (Telecommunications Server Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunication server browser and monitor."
	id = "comm_server"
	req_tech = list("programming" = 3, "magnets" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/comm_server
	category = list("Computer Boards")

/datum/design/comm_traffic
	name = "Console Board (Telecommunications Traffic Control Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications traffic control console."
	id = "comm_traffic"
	req_tech = list("programming" = 3, "magnets" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/comm_traffic
	category = list("Computer Boards")

/datum/design/telesci_console
	name = "Console Board (Telepad Control Console)"
	desc = "Allows for the construction of circuit boards used to build a telescience console."
	id = "telesci_console"
	req_tech = list("programming" = 3, "bluespace" = 3, "plasmatech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telesci_console
	category = list("Computer Boards")

/datum/design/teleconsole
	name = "Console Board (Teleporter Console)"
	desc = "Allows for the construction of circuit boards used to build a teleporter control console."
	id = "teleconsole"
	req_tech = list("programming" = 3, "bluespace" = 3, "plasmatech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/teleporter
	category = list("Computer Boards")

/datum/design/GAC
	name = "Console Board (General Air Control)"
	desc = "Allows for the construction of circuit boards used to build a General Air Control Computer."
	id = "GAC"
	req_tech = list("programming" = 3, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/air_management
	category = list("Computer Boards")

/datum/design/tank_control
	name = "Console Board (Large Tank Control)"
	desc = "Allows for the construction of circuit boards used to build a Large Tank Control Computer."
	id = "tankcontrol"
	req_tech = list("programming" = 3, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/large_tank_control
	category = list("Computer Boards")

/datum/design/AAC
	name = "Console Board (Atmospheric Automations Console)"
	desc = "Allows for the construction of circuit boards used to build an Atmospheric Automations Console."
	id = "AAC"
	req_tech = list("programming" = 4, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/atmos_automation
	category = list("Computer Boards")

/datum/design/xenobiocamera
	name = "Console Board (Xenobiology Console)"
	desc = "Allows for the construction of circuit boards used to build xenobiology camera computers."
	id = "xenobioconsole"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/xenobiology
	category = list("Computer Boards")
