/obj/item/circuitboard/message_monitor
	board_name = "Message Monitor"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/message_monitor

/obj/item/circuitboard/camera
	board_name = "Camera Monitor"
	desc = "A monitor board whose type can be changed when screwed."
	icon_state = "security"
	build_path = /obj/machinery/computer/security
	origin_tech = "programming=2;combat=2"
	var/static/list/monitor_names_paths = list(
							"Camera Monitor" = /obj/machinery/computer/security,
							"Wooden TV" = /obj/machinery/computer/security/wooden_tv,
							"Outpost Camera Monitor" = /obj/machinery/computer/security/mining,
							"Engineering Camera Monitor" = /obj/machinery/computer/security/engineering,
							"Research Monitor" = /obj/machinery/computer/security/telescreen/research,
							"Research Director Monitor" = /obj/machinery/computer/security/telescreen/rd,
							"Prison Monitor" = /obj/machinery/computer/security/telescreen/prison,
							"Interrogation Monitor" = /obj/machinery/computer/security/telescreen/interrogation,
							"MiniSat Monitor" = /obj/machinery/computer/security/telescreen/minisat,
							"AI Upload Monitor" = /obj/machinery/computer/security/telescreen/upload,
							"Vault Monitor" = /obj/machinery/computer/security/telescreen/vault,
							"Turbine Vent Monitor" = /obj/machinery/computer/security/telescreen/turbine,
							"Engine Camera Monitor" = /obj/machinery/computer/security/telescreen/engine)

/obj/item/circuitboard/camera/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/choice = tgui_input_list(user, "Circuit Setting", "What would you change the board setting to?", monitor_names_paths)
	if(!choice)
		return
	board_name = choice
	build_path = monitor_names_paths[choice]
	format_board_name()
	to_chat(user, SPAN_NOTICE("You set the board to [board_name]."))

/obj/item/circuitboard/camera/telescreen
	board_name = "Telescreen"
	build_path = /obj/machinery/computer/security/telescreen

/obj/item/circuitboard/camera/engine
	board_name = "Engine Camera Monitor"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/security/telescreen/engine

/obj/item/circuitboard/camera/research
	board_name = "Research Monitor"
	icon_state = "science"
	build_path = /obj/machinery/computer/security/telescreen/research

/obj/item/circuitboard/camera/rd
	board_name = "Research Director Monitor"
	icon_state = "science"
	build_path = /obj/machinery/computer/security/telescreen/rd

/obj/item/circuitboard/camera/prison
	board_name = "Prison Monitor"
	build_path = /obj/machinery/computer/security/telescreen/prison

/obj/item/circuitboard/camera/interrogation
	board_name = "Interrogation Monitor"
	build_path = /obj/machinery/computer/security/telescreen/interrogation

/obj/item/circuitboard/camera/minisat
	board_name = "MiniSat Monitor"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/security/telescreen/minisat

/obj/item/circuitboard/camera/upload
	board_name = "AI Upload Monitor"
	icon_state = "science"
	build_path = /obj/machinery/computer/security/telescreen/upload

/obj/item/circuitboard/camera/vault
	board_name = "Vault Monitor"
	icon_state = "command"
	build_path = /obj/machinery/computer/security/telescreen/vault

/obj/item/circuitboard/camera/turbine
	board_name = "Turbine Vent Monitor"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/security/telescreen/turbine

/obj/item/circuitboard/camera/wooden_tv
	board_name = "Wooden TV"
	build_path = /obj/machinery/computer/security/wooden_tv

/obj/item/circuitboard/camera/mining
	board_name = "Outpost Camera Monitor"
	icon_state = "supply"
	build_path = /obj/machinery/computer/security/mining

/obj/item/circuitboard/camera/engineering
	board_name = "Engineering Camera Monitor"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/security/engineering

/obj/item/circuitboard/xenobiology
	board_name = "Xenobiology Console"
	icon_state = "science"
	build_path = /obj/machinery/computer/camera_advanced/xenobio
	origin_tech = "programming=3;biotech=3"

/obj/item/circuitboard/aicore
	board_name = "AI Core"
	icon_state = "science"
	origin_tech = "programming=3"
	board_type = "other"

/obj/item/circuitboard/aiupload
	board_name = "AI Upload"
	icon_state = "command"
	build_path = /obj/machinery/computer/aiupload
	origin_tech = "programming=4;engineering=4"

/obj/item/circuitboard/aiupload_broken
	board_name = "AI Upload"
	desc = SPAN_WARNING("The board is charred and smells of burnt plastic. It has been rendered useless.")
	icon_state = "command_broken"

/obj/item/circuitboard/borgupload
	board_name = "Cyborg Upload"
	icon_state = "command"
	build_path = /obj/machinery/computer/borgupload
	origin_tech = "programming=4;engineering=4"

/obj/item/circuitboard/nonfunctional
	board_name = "destroyed"
	desc = "The board is barely recognizable. Its original function is a mystery."
	icon_state = "command_broken"

/obj/item/circuitboard/med_data
	board_name = "Medical Records"
	icon_state = "medical"
	build_path = /obj/machinery/computer/med_data
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/scan_consolenew
	board_name = "DNA Machine"
	icon_state = "medical"
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/communications
	board_name = "Communications Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/communications
	origin_tech = "programming=3;magnets=3"

/obj/item/circuitboard/card
	board_name = "ID Computer"
	icon_state = "command"
	build_path = /obj/machinery/computer/card
	origin_tech = "programming=3"

/obj/item/circuitboard/card/minor
	board_name = "Dept ID Computer"
	build_path = /obj/machinery/computer/card/minor
	var/target_dept = TARGET_DEPT_GENERIC

/obj/item/circuitboard/card/minor/hos
	board_name = "Sec ID Computer"
	icon_state = "security"
	build_path = /obj/machinery/computer/card/minor/hos
	target_dept = TARGET_DEPT_SEC

/obj/item/circuitboard/card/minor/cmo
	board_name = "Medical ID Computer"
	icon_state = "medical"
	build_path = /obj/machinery/computer/card/minor/cmo
	target_dept = TARGET_DEPT_MED

/obj/item/circuitboard/card/minor/qm
	board_name = "Supply ID Computer"
	build_path = /obj/machinery/computer/card/minor/qm
	target_dept = TARGET_DEPT_SUP

/obj/item/circuitboard/card/minor/rd
	board_name = "Science ID Computer"
	icon_state = "science"
	build_path = /obj/machinery/computer/card/minor/rd
	target_dept = TARGET_DEPT_SCI

/obj/item/circuitboard/card/minor/ce
	board_name = "Engineering ID Computer"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/card/minor/ce
	target_dept = TARGET_DEPT_ENG

/obj/item/circuitboard/card/centcom
	board_name = "CentComm ID Computer"
	build_path = /obj/machinery/computer/card/centcom

/obj/item/circuitboard/teleporter
	board_name = "Teleporter Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/teleporter
	origin_tech = "programming=3;bluespace=3;plasmatech=3"

/obj/item/circuitboard/secure_data
	board_name = "Security Records"
	icon_state = "security"
	build_path = /obj/machinery/computer/secure_data
	origin_tech = "programming=2;combat=2"

/obj/item/circuitboard/stationalert_engineering
	board_name = "Station Alert Console - Engineering"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/stationalert
	board_name = "Station Alert Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/atmos_alert
	board_name = "Atmospheric Alert Computer"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/circuitboard/atmoscontrol
	board_name = "Central Atmospherics Computer"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/atmoscontrol

/obj/item/circuitboard/air_management
	board_name = "Air Sensor Monitor"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/general_air_control

/obj/item/circuitboard/robotics
	board_name = "Robotics Control Console"
	icon_state = "science"
	build_path = /obj/machinery/computer/robotics
	origin_tech = "programming=3"

/obj/item/circuitboard/drone_control
	board_name = "Drone Control"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/drone_control
	origin_tech = "programming=3"

/obj/item/circuitboard/cloning
	board_name = "Cloning Machine Console"
	icon_state = "medical"
	build_path = /obj/machinery/computer/cloning
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/arcade/battle
	board_name = "Arcade Battle"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/battle
	origin_tech = "programming=1"

/obj/item/circuitboard/arcade/orion_trail
	board_name = "Orion Trail"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/orion_trail
	origin_tech = "programming=1"

/obj/item/circuitboard/arcade/recruiter
	board_name = "Nanotrasen Recruiter Simulator"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/recruiter
	origin_tech = "programming=1"

/obj/item/circuitboard/solar_control
	board_name = "Solar Control"
	icon_state = "engineering"
	build_path = /obj/machinery/power/solar_control
	origin_tech = "programming=2;powerstorage=2"

/obj/item/circuitboard/powermonitor
	board_name = "Power Monitor"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/monitor
	origin_tech = "programming=2;powerstorage=2"

/obj/item/circuitboard/powermonitor/secret
	board_name = "Outdated Power Monitor"
	build_path = /obj/machinery/computer/monitor/secret

/obj/item/circuitboard/prisoner
	board_name = "Prisoner Management"
	icon_state = "security"
	build_path = /obj/machinery/computer/prisoner

/obj/item/circuitboard/brigcells
	board_name = "Brig Cell Control"
	icon_state = "security"
	build_path = /obj/machinery/computer/brigcells

/obj/item/circuitboard/sm_monitor
	board_name = "Supermatter Monitoring Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/sm_monitor
	origin_tech = "programming=2;powerstorage=2"

/obj/item/circuitboard/singulo_monitor
	board_name = "Singularity Monitoring Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/singulo_monitor
	origin_tech = "programming=2;powerstorage=2"

/obj/item/circuitboard/fission_monitor
	board_name = "\improper NGCR Monitoring Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/fission_monitor
	origin_tech = "programming=2;powerstorage=2"

// RD console circuits, so that de/reconstructing one of the special consoles doesn't ruin everything forever
/obj/item/circuitboard/rdconsole
	board_name = "RD Console"
	desc = "Swipe a Scientist level ID or higher to reconfigure."
	icon_state = "science"
	build_path = /obj/machinery/computer/rdconsole/core
	req_access = list(ACCESS_TOX) // This is for adjusting the type of computer we're building
	var/list/access_types = list("R&D Core", "Public")

/obj/item/circuitboard/rdconsole/public
	board_name = "RD Console - Public"
	build_path = /obj/machinery/computer/rdconsole/public

/obj/item/circuitboard/mecha_control
	board_name = "Exosuit Control Console"
	icon_state = "science"
	build_path = /obj/machinery/computer/mecha

/obj/item/circuitboard/rnd_network_controller
	board_name = "R&D Network Controller"
	icon_state = "science"
	build_path = /obj/machinery/computer/rnd_network_controller

/obj/item/circuitboard/rnd_backup_console
	board_name = "R&D Backup Console"
	icon_state = "science"
	build_path = /obj/machinery/computer/rnd_backup

/obj/item/circuitboard/crew
	board_name = "Crew Monitoring Computer"
	icon_state = "medical"
	build_path = /obj/machinery/computer/crew
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/mech_bay_power_console
	board_name = "Mech Bay Power Control Console"
	icon_state = "science"
	build_path = /obj/machinery/computer/mech_bay_power_console
	origin_tech = "programming=3;powerstorage=3"

/obj/item/circuitboard/ai_resource_console
	board_name = "AI Resource Management Console"
	icon_state = "science"
	build_path = /obj/machinery/computer/ai_resource
	origin_tech = "programming=4"

/obj/item/circuitboard/ordercomp
	board_name = "Supply Ordering Console"
	icon_state = "supply"
	build_path = /obj/machinery/computer/supplycomp/public
	origin_tech = "programming=3"

/obj/item/circuitboard/supplycomp
	board_name = "Supply Shuttle Console"
	icon_state = "supply"
	build_path = /obj/machinery/computer/supplycomp
	origin_tech = "programming=3"
	var/contraband_enabled = 0

/obj/item/circuitboard/operating
	board_name = "Operating Computer"
	icon_state = "medical"
	build_path = /obj/machinery/computer/operating
	origin_tech = "programming=2;biotech=3"

/obj/item/circuitboard/shuttle
	board_name = "Shuttle"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle
	var/shuttleId
	var/possible_destinations = ""

/obj/item/circuitboard/labor_shuttle
	board_name = "Labor Shuttle"
	icon_state = "security"
	build_path = /obj/machinery/computer/shuttle/labor

/obj/item/circuitboard/labor_shuttle/one_way
	board_name = "Prisoner Shuttle Console"
	build_path = /obj/machinery/computer/shuttle/labor/one_way

/obj/item/circuitboard/ferry
	board_name = "Transport Ferry"
	build_path = /obj/machinery/computer/shuttle/ferry

/obj/item/circuitboard/ferry/request
	board_name = "Transport Ferry Console"
	icon_state = "supply"
	build_path = /obj/machinery/computer/shuttle/ferry/request

/obj/item/circuitboard/mining_shuttle
	board_name = "Mining Shuttle"
	icon_state = "supply"
	build_path = /obj/machinery/computer/shuttle/mining

/obj/item/circuitboard/white_ship
	board_name = "White Ship"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle/white_ship

/obj/item/circuitboard/shuttle/syndicate
	board_name = "Syndicate Shuttle"
	build_path = /obj/machinery/computer/shuttle/syndicate

/obj/item/circuitboard/shuttle/syndicate/recall
	board_name = "Syndicate Shuttle Recall Terminal"
	build_path = /obj/machinery/computer/shuttle/syndicate/recall

/obj/item/circuitboard/shuttle/syndicate/drop_pod
	board_name = "Syndicate Drop Pod"
	build_path = /obj/machinery/computer/shuttle/syndicate/drop_pod

/obj/item/circuitboard/shuttle/golem_ship
	board_name = "Golem Ship"
	build_path = /obj/machinery/computer/shuttle/golem_ship

/obj/item/circuitboard/holodeck_control
	board_name = "Holodeck Control"
	icon_state = "generic"
	build_path = /obj/machinery/computer/holodeck_control
	origin_tech = "programming=4"

/obj/item/circuitboard/aifixer
	board_name = "AI Integrity Restorer"
	icon_state = "science"
	build_path = /obj/machinery/computer/aifixer
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/area_atmos
	board_name = "Area Air Control"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/area_atmos

/obj/item/circuitboard/telesci_console
	board_name = "Telepad Control Console"
	icon_state = "science"
	build_path = /obj/machinery/computer/telescience
	origin_tech = "programming=3;bluespace=3;plasmatech=4"

/obj/item/circuitboard/large_tank_control
	board_name = "Large Tank Control"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/general_air_control/large_tank_control
	origin_tech = "programming=2;engineering=3;materials=2"

/obj/item/circuitboard/turbine_computer
	board_name = "Turbine Computer"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/turbine_computer
	origin_tech = "programming=4;engineering=4;powerstorage=4"

/obj/item/circuitboard/supplycomp/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	var/catastasis // Why is it called this
	var/opposite_catastasis
	if(contraband_enabled)
		catastasis = "BROAD"
		opposite_catastasis = "STANDARD"
	else
		catastasis = "STANDARD"
		opposite_catastasis = "BROAD"

	var/choice = tgui_alert(user, "Current receiver spectrum is set to: [catastasis]", "Multitool-Circuitboard interface", list("Switch to [opposite_catastasis]", "Cancel"))
	if(!choice || choice == "Cancel")
		return

	contraband_enabled = !contraband_enabled
	playsound(src, 'sound/effects/pop.ogg', 50)

/obj/item/circuitboard/rdconsole/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id) || istype(I, /obj/item/pda))
		if(allowed(user))
			user.visible_message(SPAN_NOTICE("[user] waves [user.p_their()] ID past [src]'s access protocol scanner."), SPAN_NOTICE("You swipe your ID past [src]'s access protocol scanner."))
			var/console_choice = tgui_input_list(user, "What do you want to configure the access to?", "Access Modification", access_types)
			if(!console_choice)
				return
			switch(console_choice)
				if("R&D Core")
					board_name = "RD Console"
					build_path = /obj/machinery/computer/rdconsole/core
				if("Public")
					board_name = "RD Console - Public"
					build_path = /obj/machinery/computer/rdconsole/public

			format_board_name()
			to_chat(user, SPAN_NOTICE("Access protocols set to [console_choice]."))
		else
			to_chat(user, SPAN_WARNING("Access Denied."))
		return
	return ..()
