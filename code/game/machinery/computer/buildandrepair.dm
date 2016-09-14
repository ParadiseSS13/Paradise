//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/structure/computerframe
	density = 1
	anchored = 0
	name = "computer frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/weapon/circuitboard/circuit = null
//	weight = 1.0E8

/obj/item/weapon/circuitboard
	density = 0
	anchored = 0
	w_class = 2
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	origin_tech = "programming=2"
	materials = list(MAT_GLASS=200)
	var/id = null
	var/frequency = null
	var/build_path = null
	var/board_type = "computer"
	var/list/req_components = null
	var/powernet = null
	var/list/records = null
	var/frame_desc = null
	var/contain_parts = 1


/obj/item/weapon/circuitboard/message_monitor
	name = "Circuit board (Message Monitor)"
	build_path = /obj/machinery/computer/message_monitor
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/camera
	name = "Circuit board (Camera Monitor)"
	build_path = /obj/machinery/computer/security
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/aicore
	name = "Circuit board (AI Core)"
	origin_tech = "programming=4;biotech=2"
	board_type = "other"
/obj/item/weapon/circuitboard/aiupload
	name = "Circuit board (AI Upload)"
	build_path = /obj/machinery/computer/aiupload
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/borgupload
	name = "Circuit board (Cyborg Upload)"
	build_path = /obj/machinery/computer/borgupload
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/med_data
	name = "Circuit board (Medical Records)"
	build_path = /obj/machinery/computer/med_data
/obj/item/weapon/circuitboard/pandemic
	name = "circuit board (PanD.E.M.I.C. 2200)"
	build_path = /obj/machinery/computer/pandemic
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/scan_consolenew
	name = "Circuit board (DNA Machine)"
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/communications
	name = "Circuit board (Communications Console)"
	build_path = /obj/machinery/computer/communications
	origin_tech = "programming=2;magnets=2"
/obj/item/weapon/circuitboard/card
	name = "Circuit board (ID Computer)"
	build_path = /obj/machinery/computer/card
/obj/item/weapon/circuitboard/card/centcom
	name = "Circuit board (CentComm ID Computer)"
	build_path = /obj/machinery/computer/card/centcom
/obj/item/weapon/circuitboard/teleporter
	name = "Circuit board (Teleporter Console)"
	build_path = /obj/machinery/computer/teleporter
	origin_tech = "programming=2;bluespace=2"
/obj/item/weapon/circuitboard/secure_data
	name = "Circuit board (Security Records)"
	build_path = /obj/machinery/computer/secure_data
/obj/item/weapon/circuitboard/skills
	name = "Circuit board (Employment Records)"
	build_path = /obj/machinery/computer/skills
/obj/item/weapon/circuitboard/stationalert_engineering
	name = "Circuit Board (Station Alert Console (Engineering))"
	build_path = /obj/machinery/computer/station_alert
/obj/item/weapon/circuitboard/stationalert_security
	name = "Circuit Board (Station Alert Console (Security))"
	build_path = /obj/machinery/computer/station_alert
/obj/item/weapon/circuitboard/stationalert_all
	name = "Circuit Board (Station Alert Console (All))"
	build_path = /obj/machinery/computer/station_alert/all
/obj/item/weapon/circuitboard/atmos_alert
	name = "Circuit Board (Atmospheric Alert Computer)"
	build_path = /obj/machinery/computer/atmos_alert
/obj/item/weapon/circuitboard/atmoscontrol
	name = "Circuit Board (Central Atmospherics Computer)"
	build_path = /obj/machinery/computer/atmoscontrol
/obj/item/weapon/circuitboard/air_management
	name = "Circuit board (Atmospheric Monitor)"
	build_path = /obj/machinery/computer/general_air_control
/obj/item/weapon/circuitboard/injector_control
	name = "Circuit board (Injector Control)"
	build_path = /obj/machinery/computer/general_air_control/fuel_injection
/obj/item/weapon/circuitboard/pod
	name = "Circuit board (Massdriver Control)"
	build_path = /obj/machinery/computer/pod
/obj/item/weapon/circuitboard/pod/deathsquad
	name = "Circuit board (Deathsquad Massdriver control)"
	build_path = /obj/machinery/computer/pod/deathsquad
/obj/item/weapon/circuitboard/robotics
	name = "Circuit board (Robotics Control Console)"
	build_path = /obj/machinery/computer/robotics
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/drone_control
	name = "Circuit board (Drone Control)"
	build_path = /obj/machinery/computer/drone_control
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/cloning
	name = "Circuit board (Cloning Machine Console)"
	build_path = /obj/machinery/computer/cloning
	origin_tech = "programming=3;biotech=3"
/obj/item/weapon/circuitboard/arcade/battle
	name = "circuit board (Arcade Battle)"
	build_path = /obj/machinery/computer/arcade/battle
	origin_tech = "programming=1"
/obj/item/weapon/circuitboard/arcade/orion_trail
	name = "circuit board (Orion Trail)"
	build_path = /obj/machinery/computer/arcade/orion_trail
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/solar_control
	name = "Circuit board (Solar Control)"
	build_path = /obj/machinery/power/solar_control
	origin_tech = "programming=2;powerstorage=2"
/obj/item/weapon/circuitboard/powermonitor
	name = "Circuit board (Power Monitor)"
	build_path = /obj/machinery/computer/monitor
/obj/item/weapon/circuitboard/olddoor
	name = "Circuit board (DoorMex)"
	build_path = /obj/machinery/computer/pod/old
/obj/item/weapon/circuitboard/syndicatedoor
	name = "Circuit board (ProComp Executive)"
	build_path = /obj/machinery/computer/pod/old/syndicate
/obj/item/weapon/circuitboard/swfdoor
	name = "Circuit board (Magix)"
	build_path = /obj/machinery/computer/pod/old/swf
/obj/item/weapon/circuitboard/prisoner
	name = "Circuit board (Prisoner Management)"
	build_path = /obj/machinery/computer/prisoner


// RD console circuits, so that {de,re}constructing one of the special consoles doesn't ruin everything forever
/obj/item/weapon/circuitboard/rdconsole
	name = "Circuit Board (RD Console)"
	desc = "Swipe a Scientist level ID or higher to reconfigure."
	build_path = /obj/machinery/computer/rdconsole/core
	req_access = list(access_tox) // This is for adjusting the type of computer we're building - in case something messes up the pre-existing robotics or mechanics consoles
	var/access_types = list("R&D Core", "Robotics", "E.X.P.E.R.I-MENTOR", "Mechanics", "Public")
	id = 1
/obj/item/weapon/circuitboard/rdconsole/robotics
	name = "Circuit Board (RD Console - Robotics)"
	build_path = /obj/machinery/computer/rdconsole/robotics
	id = 2
/obj/item/weapon/circuitboard/rdconsole/experiment
	name = "Circuit Board (RD Console - E.X.P.E.R.I-MENTOR)"
	build_path = /obj/machinery/computer/rdconsole/experiment
	id = 3
/obj/item/weapon/circuitboard/rdconsole/mechanics
	name = "Circuit Board (RD Console - Mechanics)"
	build_path = /obj/machinery/computer/rdconsole/mechanics
	id = 4
/obj/item/weapon/circuitboard/rdconsole/public
	name = "Circuit Board (RD Console - Public)"
	build_path = /obj/machinery/computer/rdconsole/public
	id = 5


/obj/item/weapon/circuitboard/mecha_control
	name = "Circuit Board (Exosuit Control Console)"
	build_path = /obj/machinery/computer/mecha
/obj/item/weapon/circuitboard/pod_locater
	name = "Circuit Board (Pod Location Console)"
	build_path = /obj/machinery/computer/podtracker
/obj/item/weapon/circuitboard/rdservercontrol
	name = "Circuit Board (RD Server Control)"
	build_path = /obj/machinery/computer/rdservercontrol
/obj/item/weapon/circuitboard/crew
	name = "Circuit board (Crew Monitoring Computer)"
	build_path = /obj/machinery/computer/crew
	origin_tech = "programming=3;biotech=2;magnets=2"
/obj/item/weapon/circuitboard/mech_bay_power_console
	name = "Circuit board (Mech Bay Power Control Console)"
	build_path = /obj/machinery/computer/mech_bay_power_console
	origin_tech = "programming=2;powerstorage=3"
/obj/item/weapon/circuitboard/ordercomp
	name = "Circuit board (Supply Ordering Console)"
	build_path = /obj/machinery/computer/ordercomp
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/supplycomp
	name = "Circuit board (Supply Shuttle Console)"
	build_path = /obj/machinery/computer/supplycomp
	origin_tech = "programming=3"
	var/contraband_enabled = 0

/obj/item/weapon/circuitboard/operating
	name = "Circuit board (Operating Computer)"
	build_path = /obj/machinery/computer/operating
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/comm_monitor
	name = "Circuit board (Telecommunications Monitor)"
	build_path = /obj/machinery/computer/telecomms/monitor
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/comm_server
	name = "Circuit board (Telecommunications Server Monitor)"
	build_path = /obj/machinery/computer/telecomms/server
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/comm_traffic
	name = "Circuitboard (Telecommunications Traffic Control)"
	build_path = /obj/machinery/computer/telecomms/traffic
	origin_tech = "programming=3"


/obj/item/weapon/circuitboard/shuttle
	name = "circuit board (Shuttle)"
	build_path = /obj/machinery/computer/shuttle
	var/shuttleId
	var/possible_destinations = ""

/obj/item/weapon/circuitboard/labor_shuttle
	name = "circuit Board (Labor Shuttle)"
	build_path = /obj/machinery/computer/shuttle/labor
/obj/item/weapon/circuitboard/labor_shuttle/one_way
	name = "circuit Board (Prisoner Shuttle Console)"
	build_path = /obj/machinery/computer/shuttle/labor/one_way
/obj/item/weapon/circuitboard/ferry
	name = "circuit Board (Transport Ferry)"
	build_path = /obj/machinery/computer/shuttle/ferry
/obj/item/weapon/circuitboard/ferry/request
	name = "circuit Board (Transport Ferry Console)"
	build_path = /obj/machinery/computer/shuttle/ferry/request
/obj/item/weapon/circuitboard/mining_shuttle
	name = "circuit Board (Mining Shuttle)"
	build_path = /obj/machinery/computer/shuttle/mining
/obj/item/weapon/circuitboard/white_ship
	name = "circuit Board (White Ship)"
	build_path = /obj/machinery/computer/shuttle/white_ship


/obj/item/weapon/circuitboard/HolodeckControl
	name = "Circuit board (Holodeck Control)"
	build_path = /obj/machinery/computer/HolodeckControl
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/aifixer
	name = "Circuit board (AI Integrity Restorer)"
	build_path = /obj/machinery/computer/aifixer
	origin_tech = "programming=3;biotech=2"
/obj/item/weapon/circuitboard/area_atmos
	name = "Circuit board (Area Air Control)"
	build_path = /obj/machinery/computer/area_atmos
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/telesci_console
	name = "Circuit board (Telepad Control Console)"
	build_path = /obj/machinery/computer/telescience
	origin_tech = "programming=3;bluespace=2"

/obj/item/weapon/circuitboard/atmos_automation
	name = "Circuit board (Atmospherics Automation)"
	build_path = /obj/machinery/computer/general_air_control/atmos_automation
/obj/item/weapon/circuitboard/large_tank_control
	name = "Circuit board (Atmospheric Tank Control)"
	build_path = /obj/machinery/computer/general_air_control/large_tank_control

/obj/item/weapon/circuitboard/turbine_computer
	name = "circuit board (Turbine Computer)"
	build_path = /obj/machinery/computer/turbine_computer
	origin_tech = "programming=4;engineering=4;powerstorage=4"

/obj/item/weapon/circuitboard/HONKputer
	name = "Circuit board (HONKputer)"
	build_path = /obj/machinery/computer/HONKputer
	origin_tech = "programming=4"
	icon = 'icons/obj/machines/HONKputer.dmi'
	icon_state = "bananium_board"
	board_type = "honkcomputer"


/obj/item/weapon/circuitboard/supplycomp/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I,/obj/item/device/multitool))
		var/catastasis = src.contraband_enabled
		var/opposite_catastasis
		if(catastasis)
			opposite_catastasis = "STANDARD"
			catastasis = "BROAD"
		else
			opposite_catastasis = "BROAD"
			catastasis = "STANDARD"

		switch( alert("Current receiver spectrum is set to: [catastasis]","Multitool-Circuitboard interface","Switch to [opposite_catastasis]","Cancel") )
		//switch( alert("Current receiver spectrum is set to: " {(src.contraband_enabled) ? ("BROAD") : ("STANDARD")} , "Multitool-Circuitboard interface" , "Switch to " {(src.contraband_enabled) ? ("STANDARD") : ("BROAD")}, "Cancel") )
			if("Switch to STANDARD","Switch to BROAD")
				src.contraband_enabled = !src.contraband_enabled

			if("Cancel")
				return
			else
				to_chat(user, "DERP! BUG! Report this (And what you were doing to cause it) to Agouri")
	return

/obj/item/weapon/circuitboard/rdconsole/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I,/obj/item/weapon/card/id)||istype(I, /obj/item/device/pda))
		if(allowed(user))
			user.visible_message("<span class='notice'>\the [user] waves their ID past the [src]'s access protocol scanner.</span>", "<span class='notice'>You swipe your ID past the [src]'s access protocol scanner.</span>")
			var/console_choice = input(user, "What do you want to configure the access to?", "Access Modification", "R&D Core") as null|anything in access_types
			if(console_choice == null)
				return
			switch(console_choice)
				if("R&D Core")
					name = "Circuit Board (RD Console)"
					build_path = /obj/machinery/computer/rdconsole/core
					id = 1
				if("Robotics")
					name = "Circuit Board (RD Console - Robotics)"
					build_path = /obj/machinery/computer/rdconsole/robotics
					id = 2
				if("E.X.P.E.R.I-MENTOR")
					name = "Circuit Board (RD Console - E.X.P.E.R.I-MENTOR)"
					build_path = /obj/machinery/computer/rdconsole/experiment
					id = 3
				if("Mechanics")
					name = "Circuit Board (RD Console - Mechanics)"
					build_path = /obj/machinery/computer/rdconsole/mechanics
					id = 4
				if("Public")
					name = "Circuit Board (RD Console - Public)"
					build_path = /obj/machinery/computer/rdconsole/public
					id = 5

			to_chat(user, "<span class='notice'>Access protocols set to [console_choice].</span>")
		else
			to_chat(user, "<span class='warning'>Access Denied</span>")
	return

/obj/structure/computerframe/attackby(obj/item/P as obj, mob/user as mob, params)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20, target = src))
					to_chat(user, "\blue You wrench the frame into place.")
					src.anchored = 1
					src.state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = P
				if(!WT.remove_fuel(0, user))
					to_chat(user, "The welding tool must be on to complete this task.")
					return
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				if(do_after(user, 20, target = src))
					if(!src || !WT.isOn()) return
					to_chat(user, "\blue You deconstruct the frame.")
					new /obj/item/stack/sheet/metal( src.loc, 5 )
					qdel(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20, target = src))
					to_chat(user, "\blue You unfasten the frame.")
					src.anchored = 0
					src.state = 0
			if(istype(P, /obj/item/weapon/circuitboard) && !circuit)
				var/obj/item/weapon/circuitboard/B = P
				if(B.board_type == "computer")
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					to_chat(user, "\blue You place the circuit board inside the frame.")
					src.icon_state = "1"
					src.circuit = P
					user.drop_item()
					P.loc = src
				else
					to_chat(user, "\red This frame does not accept circuit boards of this type!")
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "\blue You screw the circuit board into place.")
				src.state = 2
				src.icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "\blue You remove the circuit board.")
				src.state = 1
				src.icon_state = "0"
				circuit.loc = src.loc
				src.circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "\blue You unfasten the circuit board.")
				src.state = 1
				src.icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				if(P:amount >= 5)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20, target = src))
						if(P)
							P:amount -= 5
							if(!P:amount) qdel(P)
							to_chat(user, "\blue You add cables to the frame.")
							src.state = 3
							src.icon_state = "3"
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				to_chat(user, "\blue You remove the cables.")
				src.state = 2
				src.icon_state = "2"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
				A.amount = 5

			if(istype(P, /obj/item/stack/sheet/glass))
				if(P:amount >= 2)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20, target = src))
						if(P)
							P:use(2)
							to_chat(user, "\blue You put in the glass panel.")
							src.state = 4
							src.icon_state = "4"
		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "\blue You remove the glass panel.")
				src.state = 3
				src.icon_state = "3"
				new /obj/item/stack/sheet/glass( src.loc, 2 )
			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "\blue You connect the monitor.")
				var/B = new src.circuit.build_path ( src.loc )
				if(circuit.powernet) B:powernet = circuit.powernet
				if(circuit.id) B:id = circuit.id
				if(circuit.records) B:records = circuit.records
				if(circuit.frequency) B:frequency = circuit.frequency
				if(istype(circuit,/obj/item/weapon/circuitboard/supplycomp))
					var/obj/machinery/computer/supplycomp/SC = B
					var/obj/item/weapon/circuitboard/supplycomp/C = circuit
					SC.can_order_contraband = C.contraband_enabled
				qdel(src)



/obj/structure/computerframe/HONKputer
	name = "Bananium Computer-frame"
	icon = 'icons/obj/machines/HONKputer.dmi'

/obj/structure/computerframe/HONKputer/attackby(obj/item/P as obj, mob/user as mob, params)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20, target = src))
					to_chat(user, "\blue You wrench the frame into place.")
					src.anchored = 1
					src.state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = P
				if(!WT.remove_fuel(0, user))
					to_chat(user, "The welding tool must be on to complete this task.")
					return
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				if(do_after(user, 20, target = src))
					if(!src || !WT.isOn()) return
					to_chat(user, "\blue You deconstruct the frame.")
					new /obj/item/stack/sheet/mineral/bananium( src.loc, 5 )
					qdel(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20, target = src))
					to_chat(user, "\blue You unfasten the frame.")
					src.anchored = 0
					src.state = 0
			if(istype(P, /obj/item/weapon/circuitboard) && !circuit)
				var/obj/item/weapon/circuitboard/B = P
				if(B.board_type == "honkcomputer")
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					to_chat(user, "\blue You place the circuit board inside the frame.")
					src.icon_state = "1"
					src.circuit = P
					user.drop_item()
					P.loc = src
				else
					to_chat(user, "\red This frame does not accept circuit boards of this type!")
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "\blue You screw the circuit board into place.")
				src.state = 2
				src.icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "\blue You remove the circuit board.")
				src.state = 1
				src.icon_state = "0"
				circuit.loc = src.loc
				src.circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "\blue You unfasten the circuit board.")
				src.state = 1
				src.icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				if(P:amount >= 5)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20, target = src))
						if(P)
							P:amount -= 5
							if(!P:amount) qdel(P)
							to_chat(user, "\blue You add cables to the frame.")
							src.state = 3
							src.icon_state = "3"
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				to_chat(user, "\blue You remove the cables.")
				src.state = 2
				src.icon_state = "2"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
				A.amount = 5

			if(istype(P, /obj/item/stack/sheet/glass))
				if(P:amount >= 2)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20, target = src))
						if(P)
							P:use(2)
							to_chat(user, "\blue You put in the glass panel.")
							src.state = 4
							src.icon_state = "4"
		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "\blue You remove the glass panel.")
				src.state = 3
				src.icon_state = "3"
				new /obj/item/stack/sheet/glass( src.loc, 2 )
			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "\blue You connect the monitor.")
				var/B = new src.circuit.build_path ( src.loc )
				if(circuit.powernet) B:powernet = circuit.powernet
				if(circuit.id) B:id = circuit.id
				if(circuit.records) B:records = circuit.records
				if(circuit.frequency) B:frequency = circuit.frequency
				qdel(src)
