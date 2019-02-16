/obj/structure/computerframe
	density = 1
	anchored = 0
	name = "computer frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"
	max_integrity = 100
	var/state = 0
	var/obj/item/circuitboard/circuit = null
	var/base_mineral = /obj/item/stack/sheet/metal
//	weight = 1.0E8

/obj/structure/computerframe/deconstruct(disassembled = TRUE)
	drop_computer_parts()
	return ..() // will qdel the frame

/obj/structure/computerframe/obj_break(damage_flag)
	deconstruct()

/obj/structure/computerframe/proc/drop_computer_parts()
	new base_mineral(loc, 5)
	if(circuit)
		circuit.forceMove(loc)
		circuit = null
	if(state >= 3)
		var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
		A.amount = 5
	if(state >= 4)
		new /obj/item/stack/sheet/glass(loc, 2)

/obj/item/circuitboard
	density = 0
	anchored = 0
	w_class = WEIGHT_CLASS_SMALL
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
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/circuitboard/computer
	board_type = "computer"

/obj/item/circuitboard/machine
	board_type = "machine"

/obj/item/circuitboard/message_monitor
	name = "Circuit board (Message Monitor)"
	build_path = /obj/machinery/computer/message_monitor
	origin_tech = "programming=2"
/obj/item/circuitboard/camera
	name = "Circuit board (Camera Monitor)"
	build_path = /obj/machinery/computer/security
	origin_tech = "programming=2;combat=2"

/obj/item/circuitboard/camera/telescreen
	name = "Circuit board (Telescreen)"
	build_path = /obj/machinery/computer/security/telescreen
/obj/item/circuitboard/camera/telescreen/entertainment
	name = "Circuit board (Entertainment Monitor)"
	build_path = /obj/machinery/computer/security/telescreen/entertainment
/obj/item/circuitboard/camera/wooden_tv
	name = "Circuit board (Wooden TV)"
	build_path = /obj/machinery/computer/security/wooden_tv
/obj/item/circuitboard/camera/mining
	name = "Circuit board (Outpost Camera Monitor)"
	build_path = /obj/machinery/computer/security/mining
/obj/item/circuitboard/camera/engineering
	name = "Circuit board (Engineering Camera Monitor)"
	build_path = /obj/machinery/computer/security/engineering


/obj/item/circuitboard/xenobiology
	name = "Circuit board (Xenobiology Console)"
	build_path = /obj/machinery/computer/camera_advanced/xenobio
	origin_tech = "programming=3;biotech=3"
/obj/item/circuitboard/aicore
	name = "Circuit board (AI Core)"
	origin_tech = "programming=3"
	board_type = "other"
/obj/item/circuitboard/aiupload
	name = "Circuit board (AI Upload)"
	build_path = /obj/machinery/computer/aiupload
	origin_tech = "programming=4;engineering=4"
/obj/item/circuitboard/borgupload
	name = "Circuit board (Cyborg Upload)"
	build_path = /obj/machinery/computer/borgupload
	origin_tech = "programming=4;engineering=4"
/obj/item/circuitboard/med_data
	name = "Circuit board (Medical Records)"
	build_path = /obj/machinery/computer/med_data
	origin_tech = "programming=2;biotech=2"
/obj/item/circuitboard/pandemic
	name = "circuit board (PanD.E.M.I.C. 2200)"
	build_path = /obj/machinery/computer/pandemic
	origin_tech = "programming=2;biotech=2"
/obj/item/circuitboard/scan_consolenew
	name = "Circuit board (DNA Machine)"
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"
/obj/item/circuitboard/communications
	name = "Circuit board (Communications Console)"
	build_path = /obj/machinery/computer/communications
	origin_tech = "programming=3;magnets=3"
/obj/item/circuitboard/card
	name = "Circuit board (ID Computer)"
	build_path = /obj/machinery/computer/card
	origin_tech = "programming=3"
/obj/item/circuitboard/card/minor
	name = "Circuit board (Dept ID Computer)"
	build_path = /obj/machinery/computer/card/minor
	var/target_dept = TARGET_DEPT_GENERIC
/obj/item/circuitboard/card/minor/hos
	name = "Circuit board (Sec ID Computer)"
	build_path = /obj/machinery/computer/card/minor/hos
	target_dept = TARGET_DEPT_SEC
/obj/item/circuitboard/card/minor/cmo
	name = "Circuit board (Medical ID Computer)"
	build_path = /obj/machinery/computer/card/minor/cmo
	target_dept = TARGET_DEPT_MED
/obj/item/circuitboard/card/minor/rd
	name = "Circuit board (Science ID Computer)"
	build_path = /obj/machinery/computer/card/minor/rd
	target_dept = TARGET_DEPT_SCI
/obj/item/circuitboard/card/minor/ce
	name = "Circuit board (Engineering ID Computer)"
	build_path = /obj/machinery/computer/card/minor/ce
	target_dept = TARGET_DEPT_ENG
/obj/item/circuitboard/card/centcom
	name = "Circuit board (CentComm ID Computer)"
	build_path = /obj/machinery/computer/card/centcom
/obj/item/circuitboard/teleporter
	name = "Circuit board (Teleporter Console)"
	build_path = /obj/machinery/computer/teleporter
	origin_tech = "programming=3;bluespace=3;plasmatech=3"
/obj/item/circuitboard/secure_data
	name = "Circuit board (Security Records)"
	build_path = /obj/machinery/computer/secure_data
	origin_tech = "programming=2;combat=2"
/obj/item/circuitboard/skills
	name = "Circuit board (Employment Records)"
	build_path = /obj/machinery/computer/skills
/obj/item/circuitboard/stationalert_engineering
	name = "Circuit Board (Station Alert Console (Engineering))"
	build_path = /obj/machinery/computer/station_alert
/obj/item/circuitboard/stationalert_security
	name = "Circuit Board (Station Alert Console (Security))"
	build_path = /obj/machinery/computer/station_alert
/obj/item/circuitboard/stationalert_all
	name = "Circuit Board (Station Alert Console (All))"
	build_path = /obj/machinery/computer/station_alert/all
/obj/item/circuitboard/atmos_alert
	name = "Circuit Board (Atmospheric Alert Computer)"
	build_path = /obj/machinery/computer/atmos_alert
/obj/item/circuitboard/atmoscontrol
	name = "Circuit Board (Central Atmospherics Computer)"
	build_path = /obj/machinery/computer/atmoscontrol
/obj/item/circuitboard/air_management
	name = "Circuit board (Atmospheric Monitor)"
	build_path = /obj/machinery/computer/general_air_control
/obj/item/circuitboard/injector_control
	name = "Circuit board (Injector Control)"
	build_path = /obj/machinery/computer/general_air_control/fuel_injection
/obj/item/circuitboard/pod
	name = "Circuit board (Massdriver Control)"
	build_path = /obj/machinery/computer/pod
/obj/item/circuitboard/pod/deathsquad
	name = "Circuit board (Deathsquad Massdriver control)"
	build_path = /obj/machinery/computer/pod/deathsquad
/obj/item/circuitboard/robotics
	name = "Circuit board (Robotics Control Console)"
	build_path = /obj/machinery/computer/robotics
	origin_tech = "programming=3"
/obj/item/circuitboard/drone_control
	name = "Circuit board (Drone Control)"
	build_path = /obj/machinery/computer/drone_control
	origin_tech = "programming=3"
/obj/item/circuitboard/cloning
	name = "Circuit board (Cloning Machine Console)"
	build_path = /obj/machinery/computer/cloning
	origin_tech = "programming=2;biotech=2"
/obj/item/circuitboard/arcade/battle
	name = "circuit board (Arcade Battle)"
	build_path = /obj/machinery/computer/arcade/battle
	origin_tech = "programming=1"
/obj/item/circuitboard/arcade/orion_trail
	name = "circuit board (Orion Trail)"
	build_path = /obj/machinery/computer/arcade/orion_trail
	origin_tech = "programming=1"
/obj/item/circuitboard/solar_control
	name = "Circuit board (Solar Control)"
	build_path = /obj/machinery/power/solar_control
	origin_tech = "programming=2;powerstorage=2"
/obj/item/circuitboard/powermonitor
	name = "Circuit board (Power Monitor)"
	build_path = /obj/machinery/computer/monitor
	origin_tech = "programming=2;powerstorage=2"
/obj/item/circuitboard/olddoor
	name = "Circuit board (DoorMex)"
	build_path = /obj/machinery/computer/pod/old
/obj/item/circuitboard/syndicatedoor
	name = "Circuit board (ProComp Executive)"
	build_path = /obj/machinery/computer/pod/old/syndicate
/obj/item/circuitboard/swfdoor
	name = "Circuit board (Magix)"
	build_path = /obj/machinery/computer/pod/old/swf
/obj/item/circuitboard/prisoner
	name = "Circuit board (Prisoner Management)"
	build_path = /obj/machinery/computer/prisoner


// RD console circuits, so that {de,re}constructing one of the special consoles doesn't ruin everything forever
/obj/item/circuitboard/rdconsole
	name = "Circuit Board (RD Console)"
	desc = "Swipe a Scientist level ID or higher to reconfigure."
	build_path = /obj/machinery/computer/rdconsole/core
	req_access = list(access_tox) // This is for adjusting the type of computer we're building - in case something messes up the pre-existing robotics or mechanics consoles
	var/access_types = list("R&D Core", "Robotics", "E.X.P.E.R.I-MENTOR", "Mechanics", "Public")
	id = 1
/obj/item/circuitboard/rdconsole/robotics
	name = "Circuit Board (RD Console - Robotics)"
	build_path = /obj/machinery/computer/rdconsole/robotics
	id = 2
/obj/item/circuitboard/rdconsole/experiment
	name = "Circuit Board (RD Console - E.X.P.E.R.I-MENTOR)"
	build_path = /obj/machinery/computer/rdconsole/experiment
	id = 3
/obj/item/circuitboard/rdconsole/mechanics
	name = "Circuit Board (RD Console - Mechanics)"
	build_path = /obj/machinery/computer/rdconsole/mechanics
	id = 4
/obj/item/circuitboard/rdconsole/public
	name = "Circuit Board (RD Console - Public)"
	build_path = /obj/machinery/computer/rdconsole/public
	id = 5


/obj/item/circuitboard/mecha_control
	name = "Circuit Board (Exosuit Control Console)"
	build_path = /obj/machinery/computer/mecha
/obj/item/circuitboard/pod_locater
	name = "Circuit Board (Pod Location Console)"
	build_path = /obj/machinery/computer/podtracker
/obj/item/circuitboard/rdservercontrol
	name = "Circuit Board (RD Server Control)"
	build_path = /obj/machinery/computer/rdservercontrol
/obj/item/circuitboard/crew
	name = "Circuit board (Crew Monitoring Computer)"
	build_path = /obj/machinery/computer/crew
	origin_tech = "programming=2;biotech=2"
/obj/item/circuitboard/mech_bay_power_console
	name = "Circuit board (Mech Bay Power Control Console)"
	build_path = /obj/machinery/computer/mech_bay_power_console
	origin_tech = "programming=3;powerstorage=3"
/obj/item/circuitboard/ordercomp
	name = "Circuit board (Supply Ordering Console)"
	build_path = /obj/machinery/computer/ordercomp
	origin_tech = "programming=3"
/obj/item/circuitboard/supplycomp
	name = "Circuit board (Supply Shuttle Console)"
	build_path = /obj/machinery/computer/supplycomp
	origin_tech = "programming=3"
	var/contraband_enabled = 0

/obj/item/circuitboard/operating
	name = "Circuit board (Operating Computer)"
	build_path = /obj/machinery/computer/operating
	origin_tech = "programming=2;biotech=3"
/obj/item/circuitboard/comm_monitor
	name = "Circuit board (Telecommunications Monitor)"
	build_path = /obj/machinery/computer/telecomms/monitor
	origin_tech = "programming=3;magnets=3;bluespace=2"
/obj/item/circuitboard/comm_server
	name = "Circuit board (Telecommunications Server Monitor)"
	build_path = /obj/machinery/computer/telecomms/server
	origin_tech = "programming=3;magnets=3;bluespace=2"
/obj/item/circuitboard/comm_traffic
	name = "Circuitboard (Telecommunications Traffic Control)"
	build_path = /obj/machinery/computer/telecomms/traffic
	origin_tech = "programming=3;magnets=3;bluespace=2"


/obj/item/circuitboard/shuttle
	name = "circuit board (Shuttle)"
	build_path = /obj/machinery/computer/shuttle
	var/shuttleId
	var/possible_destinations = ""

/obj/item/circuitboard/labor_shuttle
	name = "circuit Board (Labor Shuttle)"
	build_path = /obj/machinery/computer/shuttle/labor
/obj/item/circuitboard/labor_shuttle/one_way
	name = "circuit Board (Prisoner Shuttle Console)"
	build_path = /obj/machinery/computer/shuttle/labor/one_way
/obj/item/circuitboard/ferry
	name = "circuit Board (Transport Ferry)"
	build_path = /obj/machinery/computer/shuttle/ferry
/obj/item/circuitboard/ferry/request
	name = "circuit Board (Transport Ferry Console)"
	build_path = /obj/machinery/computer/shuttle/ferry/request
/obj/item/circuitboard/mining_shuttle
	name = "circuit Board (Mining Shuttle)"
	build_path = /obj/machinery/computer/shuttle/mining
/obj/item/circuitboard/white_ship
	name = "circuit Board (White Ship)"
	build_path = /obj/machinery/computer/shuttle/white_ship
/obj/item/circuitboard/golem_ship
	name = "circuit Board (Golem Ship)"
	build_path = /obj/machinery/computer/shuttle/golem_ship
/obj/item/circuitboard/shuttle/syndicate
	name = "circuit board (Syndicate Shuttle)"
	build_path = /obj/machinery/computer/shuttle/syndicate
/obj/item/circuitboard/shuttle/syndicate/recall
	name = "circuit board (Syndicate Shuttle Recall Terminal)"
	build_path = /obj/machinery/computer/shuttle/syndicate/recall
/obj/item/circuitboard/shuttle/syndicate/drop_pod
	name = "circuit board (Syndicate Drop Pod)"
	build_path = /obj/machinery/computer/shuttle/syndicate/drop_pod


/obj/item/circuitboard/HolodeckControl
	name = "Circuit board (Holodeck Control)"
	build_path = /obj/machinery/computer/HolodeckControl
	origin_tech = "programming=4"
/obj/item/circuitboard/aifixer
	name = "Circuit board (AI Integrity Restorer)"
	build_path = /obj/machinery/computer/aifixer
	origin_tech = "programming=2;biotech=2"
/obj/item/circuitboard/area_atmos
	name = "Circuit board (Area Air Control)"
	build_path = /obj/machinery/computer/area_atmos
	origin_tech = "programming=2"
/obj/item/circuitboard/telesci_console
	name = "Circuit board (Telepad Control Console)"
	build_path = /obj/machinery/computer/telescience
	origin_tech = "programming=3;bluespace=3;plasmatech=4"

/obj/item/circuitboard/atmos_automation
	name = "Circuit board (Atmospherics Automation)"
	build_path = /obj/machinery/computer/general_air_control/atmos_automation
/obj/item/circuitboard/large_tank_control
	name = "Circuit board (Atmospheric Tank Control)"
	build_path = /obj/machinery/computer/general_air_control/large_tank_control
	origin_tech = "programming=2;engineering=3;materials=2"

/obj/item/circuitboard/turbine_computer
	name = "circuit board (Turbine Computer)"
	build_path = /obj/machinery/computer/turbine_computer
	origin_tech = "programming=4;engineering=4;powerstorage=4"

/obj/item/circuitboard/HONKputer
	name = "Circuit board (HONKputer)"
	build_path = /obj/machinery/computer/HONKputer
	origin_tech = "programming=2"
	icon = 'icons/obj/machines/HONKputer.dmi'
	icon_state = "bananium_board"
	board_type = "honkcomputer"


/obj/item/circuitboard/supplycomp/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I,/obj/item/multitool))
		var/catastasis = contraband_enabled
		var/opposite_catastasis
		if(catastasis)
			opposite_catastasis = "STANDARD"
			catastasis = "BROAD"
		else
			opposite_catastasis = "BROAD"
			catastasis = "STANDARD"

		switch( alert("Current receiver spectrum is set to: [catastasis]","Multitool-Circuitboard interface","Switch to [opposite_catastasis]","Cancel") )
		//switch( alert("Current receiver spectrum is set to: " {(contraband_enabled) ? ("BROAD") : ("STANDARD")} , "Multitool-Circuitboard interface" , "Switch to " {(contraband_enabled) ? ("STANDARD") : ("BROAD")}, "Cancel") )
			if("Switch to STANDARD","Switch to BROAD")
				contraband_enabled = !contraband_enabled

			if("Cancel")
				return
			else
				to_chat(user, "DERP! BUG! Report this (And what you were doing to cause it) to Agouri")
	return

/obj/item/circuitboard/rdconsole/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I,/obj/item/card/id)||istype(I, /obj/item/pda))
		if(allowed(user))
			user.visible_message("<span class='notice'>\the [user] waves [user.p_their()] ID past the [src]'s access protocol scanner.</span>", "<span class='notice'>You swipe your ID past the [src]'s access protocol scanner.</span>")
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
			if(istype(P, /obj/item/wrench))
				playsound(loc, P.usesound, 50, 1)
				if(do_after(user, 20 * P.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					anchored = 1
					state = 1
			if(istype(P, /obj/item/weldingtool))
				var/obj/item/weldingtool/WT = P
				if(!WT.remove_fuel(0, user))
					to_chat(user, "<span class='warning'>The welding tool must be on to complete this task.</span>")
					return
				playsound(loc, WT.usesound, 50, 1)
				if(do_after(user, 20 * WT.toolspeed, target = src))
					if(!src || !WT.isOn()) return
					to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
					deconstruct(TRUE)
		if(1)
			if(istype(P, /obj/item/wrench))
				playsound(loc, P.usesound, 50, 1)
				if(do_after(user, 20 * P.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					anchored = 0
					state = 0
			if(istype(P, /obj/item/circuitboard) && !circuit)
				var/obj/item/circuitboard/B = P
				if(B.board_type == "computer")
					playsound(loc, B.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
					icon_state = "1"
					circuit = P
					user.drop_item()
					P.loc = src
				else
					to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
			if(istype(P, /obj/item/screwdriver) && circuit)
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				state = 2
				icon_state = "2"
			if(istype(P, /obj/item/crowbar) && circuit)
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				state = 1
				icon_state = "0"
				circuit.loc = loc
				circuit = null
		if(2)
			if(istype(P, /obj/item/screwdriver) && circuit)
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				state = 1
				icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.amount >= 5)
					playsound(loc, C.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
					if(do_after(user, 20 * C.toolspeed, target = src))
						if(state == 2 && C.amount >= 5 && C.use(5))
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							state = 3
							icon_state = "3"
						else
							to_chat(user, "<span class='warning'>At some point during construction you lost some cable. Make sure you have five lengths before trying again.</span>")
							return
				else
					to_chat(user, "<span class='warning'>You need five lengths of cable to wire the frame.</span>")
					return
		if(3)
			if(istype(P, /obj/item/wirecutters))
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 2
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
				A.amount = 5

			if(istype(P, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = P
				if(G.amount >= 2)
					playsound(loc, G.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You start to add the glass panel to the frame.</span>")
					if(do_after(user, 20 * G.toolspeed, target = src))
						if(state == 3 && G.amount >= 2 && G.use(2))
							to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
							state = 4
							icon_state = "4"
						else
							to_chat(user, "<span class='warning'>At some point during construction you lost some glass. Make sure you have two sheets before trying again.</span>")
							return
				else
					to_chat(user, "<span class='warning'>You need two sheets of glass for this.</span>")
					return
		if(4)
			if(istype(P, /obj/item/crowbar))
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				state = 3
				icon_state = "3"
				new /obj/item/stack/sheet/glass(loc, 2)
			if(istype(P, /obj/item/screwdriver))
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/B = new circuit.build_path (loc)
				if(circuit.powernet) B:powernet = circuit.powernet
				if(circuit.id) B:id = circuit.id
				if(circuit.records) B:records = circuit.records
				if(circuit.frequency) B:frequency = circuit.frequency
				if(istype(circuit,/obj/item/circuitboard/supplycomp))
					var/obj/machinery/computer/supplycomp/SC = B
					var/obj/item/circuitboard/supplycomp/C = circuit
					SC.can_order_contraband = C.contraband_enabled
				qdel(src)



/obj/structure/computerframe/HONKputer
	name = "Bananium Computer-frame"
	icon = 'icons/obj/machines/HONKputer.dmi'
	base_mineral = /obj/item/stack/sheet/mineral/bananium

/obj/structure/computerframe/HONKputer/attackby(obj/item/P as obj, mob/user as mob, params)
	switch(state)
		if(0)
			if(istype(P, /obj/item/wrench))
				playsound(loc, P.usesound, 50, 1)
				if(do_after(user, 20, target = src))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					anchored = 1
					state = 1
			if(istype(P, /obj/item/weldingtool))
				var/obj/item/weldingtool/WT = P
				if(!WT.remove_fuel(0, user))
					to_chat(user, "<span class='warning'>The welding tool must be on to complete this task.</span>")
					return
				playsound(loc, WT.usesound, 50, 1)
				if(do_after(user, 20 * WT.toolspeed, target = src))
					if(!src || !WT.isOn()) return
					to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
					deconstruct(TRUE)
		if(1)
			if(istype(P, /obj/item/wrench))
				playsound(loc, P.usesound, 50, 1)
				if(do_after(user, 20 * P.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					anchored = 0
					state = 0
			if(istype(P, /obj/item/circuitboard) && !circuit)
				var/obj/item/circuitboard/B = P
				if(B.board_type == "honkcomputer")
					playsound(loc, P.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
					icon_state = "1"
					circuit = P
					user.drop_item()
					P.loc = src
				else
					to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
			if(istype(P, /obj/item/screwdriver) && circuit)
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				state = 2
				icon_state = "2"
			if(istype(P, /obj/item/crowbar) && circuit)
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				state = 1
				icon_state = "0"
				circuit.loc = loc
				circuit = null
		if(2)
			if(istype(P, /obj/item/screwdriver) && circuit)
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				state = 1
				icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.amount >= 5)
					playsound(loc, C.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
					if(do_after(user, 20 * C.toolspeed, target = src))
						if(state == 2 && C.amount >= 5 && C.use(5))
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							state = 3
							icon_state = "3"
						else
							to_chat(user, "<span class='warning'>At some point during construction you lost some cable. Make sure you have five lengths before trying again.</span>")
							return
				else
					to_chat(user, "<span class='warning'>You need five lengths of cable to wire the frame.</span>")
					return
		if(3)
			if(istype(P, /obj/item/wirecutters))
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 2
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
				A.amount = 5

			if(istype(P, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = P
				if(G.amount >= 2)
					playsound(loc, G.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You start to add the glass panel to the frame.</span>")
					if(do_after(user, 20 * G.toolspeed, target = src))
						if(state == 3 && G.amount >= 2 && G.use(2))
							to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
							state = 4
							icon_state = "4"
						else
							to_chat(user, "<span class='warning'>At some point during construction you lost some glass. Make sure you have two sheets before trying again.</span>")
							return
				else
					to_chat(user, "<span class='warning'>You need two sheets of glass for this.</span>")
					return
		if(4)
			if(istype(P, /obj/item/crowbar))
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				state = 3
				icon_state = "3"
				new /obj/item/stack/sheet/glass(loc, 2)
			if(istype(P, /obj/item/screwdriver))
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/B = new circuit.build_path (loc)
				if(circuit.powernet) B:powernet = circuit.powernet
				if(circuit.id) B:id = circuit.id
				if(circuit.records) B:records = circuit.records
				if(circuit.frequency) B:frequency = circuit.frequency
				qdel(src)
