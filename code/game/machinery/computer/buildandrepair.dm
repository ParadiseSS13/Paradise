/obj/item/circuitboard
	/// Use `board_name` instead of this.
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	origin_tech = "programming=2"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_GLASS=200)
	usesound = 'sound/items/deconstruct.ogg'
	/// Use this instead of `name`. Formats as: `circuit board ([board_name])`
	var/board_name = null
	var/id = null
	var/frequency = null
	var/build_path = null
	var/board_type = "computer"
	var/list/req_components = null
	var/powernet = null
	var/list/records = null

/obj/item/circuitboard/computer
	board_type = "computer"

/obj/item/circuitboard/machine
	board_type = "machine"

/obj/item/circuitboard/Initialize(mapload)
	. = ..()
	format_board_name()

/obj/item/circuitboard/proc/format_board_name()
	if(board_name) // Should always have this, but just in case.
		name = "[initial(name)] ([board_name])"
	else
		name = "[initial(name)]"

/obj/item/circuitboard/examine(mob/user)
	. = ..()
	if(LAZYLEN(req_components))
		var/list/nice_list = list()
		for(var/B in req_components)
			var/atom/A = B
			if(!ispath(A))
				continue
			nice_list += list("[req_components[A]] [initial(A.name)]\s")
		. += "<span class='notice'>Required components: [english_list(nice_list)].</span>"

/obj/item/circuitboard/message_monitor
	board_name = "Message Monitor"
	build_path = /obj/machinery/computer/message_monitor
	origin_tech = "programming=2"

/obj/item/circuitboard/camera
	board_name = "Camera Monitor"
	build_path = /obj/machinery/computer/security
	origin_tech = "programming=2;combat=2"

/obj/item/circuitboard/camera/telescreen
	board_name = "Telescreen"
	build_path = /obj/machinery/computer/security/telescreen

/obj/item/circuitboard/camera/telescreen/entertainment
	board_name = "Entertainment Monitor"
	build_path = /obj/machinery/computer/security/telescreen/entertainment

/obj/item/circuitboard/camera/wooden_tv
	board_name = "Wooden TV"
	build_path = /obj/machinery/computer/security/wooden_tv

/obj/item/circuitboard/camera/mining
	board_name = "Outpost Camera Monitor"
	build_path = /obj/machinery/computer/security/mining

/obj/item/circuitboard/camera/engineering
	board_name = "Engineering Camera Monitor"
	build_path = /obj/machinery/computer/security/engineering

/obj/item/circuitboard/xenobiology
	board_name = "Xenobiology Console"
	build_path = /obj/machinery/computer/camera_advanced/xenobio
	origin_tech = "programming=3;biotech=3"

/obj/item/circuitboard/aicore
	board_name = "AI Core"
	origin_tech = "programming=3"
	board_type = "other"

/obj/item/circuitboard/aiupload
	board_name = "AI Upload"
	build_path = /obj/machinery/computer/aiupload
	origin_tech = "programming=4;engineering=4"

/obj/item/circuitboard/borgupload
	board_name = "Cyborg Upload"
	build_path = /obj/machinery/computer/borgupload
	origin_tech = "programming=4;engineering=4"

/obj/item/circuitboard/med_data
	board_name = "Medical Records"
	build_path = /obj/machinery/computer/med_data
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/pandemic
	board_name = "PanD.E.M.I.C. 2200"
	build_path = /obj/machinery/computer/pandemic
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/scan_consolenew
	board_name = "DNA Machine"
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/communications
	board_name = "Communications Console"
	build_path = /obj/machinery/computer/communications
	origin_tech = "programming=3;magnets=3"

/obj/item/circuitboard/card
	board_name = "ID Computer"
	build_path = /obj/machinery/computer/card
	origin_tech = "programming=3"

/obj/item/circuitboard/card/minor
	board_name = "Dept ID Computer"
	build_path = /obj/machinery/computer/card/minor
	var/target_dept = TARGET_DEPT_GENERIC

/obj/item/circuitboard/card/minor/hos
	board_name = "Sec ID Computer"
	build_path = /obj/machinery/computer/card/minor/hos
	target_dept = TARGET_DEPT_SEC

/obj/item/circuitboard/card/minor/cmo
	board_name = "Medical ID Computer"
	build_path = /obj/machinery/computer/card/minor/cmo
	target_dept = TARGET_DEPT_MED

/obj/item/circuitboard/card/minor/rd
	board_name = "Science ID Computer"
	build_path = /obj/machinery/computer/card/minor/rd
	target_dept = TARGET_DEPT_SCI

/obj/item/circuitboard/card/minor/ce
	board_name = "Engineering ID Computer"
	build_path = /obj/machinery/computer/card/minor/ce
	target_dept = TARGET_DEPT_ENG

/obj/item/circuitboard/card/centcom
	board_name = "CentComm ID Computer"
	build_path = /obj/machinery/computer/card/centcom

/obj/item/circuitboard/teleporter
	board_name = "Teleporter Console"
	build_path = /obj/machinery/computer/teleporter
	origin_tech = "programming=3;bluespace=3;plasmatech=3"

/obj/item/circuitboard/secure_data
	board_name = "Security Records"
	build_path = /obj/machinery/computer/secure_data
	origin_tech = "programming=2;combat=2"

/obj/item/circuitboard/stationalert_engineering
	board_name = "Station Alert Console - Engineering"
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/stationalert
	board_name = "Station Alert Console"
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/atmos_alert
	board_name = "Atmospheric Alert Computer"
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/circuitboard/atmoscontrol
	board_name = "Central Atmospherics Computer"
	build_path = /obj/machinery/computer/atmoscontrol

/obj/item/circuitboard/air_management
	board_name = "Atmospheric Monitor"
	build_path = /obj/machinery/computer/general_air_control

/obj/item/circuitboard/injector_control
	board_name = "Injector Control"
	build_path = /obj/machinery/computer/general_air_control/fuel_injection

/obj/item/circuitboard/pod
	board_name = "Massdriver Control"
	build_path = /obj/machinery/computer/pod

/obj/item/circuitboard/pod/deathsquad
	board_name = "Deathsquad Massdriver Control"
	build_path = /obj/machinery/computer/pod/deathsquad

/obj/item/circuitboard/robotics
	board_name = "Robotics Control Console"
	build_path = /obj/machinery/computer/robotics
	origin_tech = "programming=3"

/obj/item/circuitboard/drone_control
	board_name = "Drone Control"
	build_path = /obj/machinery/computer/drone_control
	origin_tech = "programming=3"

/obj/item/circuitboard/cloning
	board_name = "Cloning Machine Console"
	build_path = /obj/machinery/computer/cloning
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/arcade/battle
	board_name = "Arcade Battle"
	build_path = /obj/machinery/computer/arcade/battle
	origin_tech = "programming=1"

/obj/item/circuitboard/arcade/orion_trail
	board_name = "Orion Trail"
	build_path = /obj/machinery/computer/arcade/orion_trail
	origin_tech = "programming=1"

/obj/item/circuitboard/solar_control
	board_name = "Solar Control"
	build_path = /obj/machinery/power/solar_control
	origin_tech = "programming=2;powerstorage=2"

/obj/item/circuitboard/powermonitor
	board_name = "Power Monitor"
	build_path = /obj/machinery/computer/monitor
	origin_tech = "programming=2;powerstorage=2"

/obj/item/circuitboard/powermonitor/secret
	board_name = "Outdated Power Monitor"
	build_path = /obj/machinery/computer/monitor/secret
	origin_tech = "programming=2;powerstorage=2"

/obj/item/circuitboard/olddoor
	board_name = "DoorMex"
	build_path = /obj/machinery/computer/pod/old

/obj/item/circuitboard/syndicatedoor
	board_name = "ProComp Executive"
	build_path = /obj/machinery/computer/pod/old/syndicate

/obj/item/circuitboard/swfdoor
	board_name = "Magix"
	build_path = /obj/machinery/computer/pod/old/swf

/obj/item/circuitboard/prisoner
	board_name = "Prisoner Management"
	build_path = /obj/machinery/computer/prisoner

/obj/item/circuitboard/brigcells
	board_name = "Brig Cell Control"
	build_path = /obj/machinery/computer/brigcells

/obj/item/circuitboard/sm_monitor
	board_name = "Supermatter Monitoring Console"
	build_path = /obj/machinery/computer/sm_monitor
	origin_tech = "programming=2;powerstorage=2"

// RD console circuits, so that de/reconstructing one of the special consoles doesn't ruin everything forever
/obj/item/circuitboard/rdconsole
	board_name = "RD Console"
	desc = "Swipe a Scientist level ID or higher to reconfigure."
	build_path = /obj/machinery/computer/rdconsole/core
	req_access = list(ACCESS_TOX) // This is for adjusting the type of computer we're building - in case something messes up the pre-existing robotics or mechanics consoles
	var/list/access_types = list("R&D Core", "Robotics", "E.X.P.E.R.I-MENTOR", "Mechanics", "Public")
	id = 1

/obj/item/circuitboard/rdconsole/robotics
	board_name = "RD Console - Robotics"
	build_path = /obj/machinery/computer/rdconsole/robotics
	id = 2

/obj/item/circuitboard/rdconsole/experiment
	board_name = "RD Console - E.X.P.E.R.I-MENTOR"
	build_path = /obj/machinery/computer/rdconsole/experiment
	id = 3

/obj/item/circuitboard/rdconsole/mechanics
	board_name = "RD Console - Mechanics"
	build_path = /obj/machinery/computer/rdconsole/mechanics
	id = 4

/obj/item/circuitboard/rdconsole/public
	board_name = "RD Console - Public"
	build_path = /obj/machinery/computer/rdconsole/public
	id = 5


/obj/item/circuitboard/mecha_control
	board_name = "Exosuit Control Console"
	build_path = /obj/machinery/computer/mecha

/obj/item/circuitboard/pod_locater
	board_name = "Pod Location Console"
	build_path = /obj/machinery/computer/podtracker

/obj/item/circuitboard/rdservercontrol
	board_name = "RD Server Control"
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/circuitboard/crew
	board_name = "Crew Monitoring Computer"
	build_path = /obj/machinery/computer/crew
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/mech_bay_power_console
	board_name = "Mech Bay Power Control Console"
	build_path = /obj/machinery/computer/mech_bay_power_console
	origin_tech = "programming=3;powerstorage=3"

/obj/item/circuitboard/ordercomp
	board_name = "Supply Ordering Console"
	build_path = /obj/machinery/computer/supplycomp/public
	origin_tech = "programming=3"

/obj/item/circuitboard/supplycomp
	board_name = "Supply Shuttle Console"
	build_path = /obj/machinery/computer/supplycomp
	origin_tech = "programming=3"
	var/contraband_enabled = 0

/obj/item/circuitboard/operating
	board_name = "Operating Computer"
	build_path = /obj/machinery/computer/operating
	origin_tech = "programming=2;biotech=3"

/obj/item/circuitboard/shuttle
	board_name = "Shuttle"
	build_path = /obj/machinery/computer/shuttle
	var/shuttleId
	var/possible_destinations = ""

/obj/item/circuitboard/labor_shuttle
	board_name = "Labor Shuttle"
	build_path = /obj/machinery/computer/shuttle/labor

/obj/item/circuitboard/labor_shuttle/one_way
	board_name = "Prisoner Shuttle Console"
	build_path = /obj/machinery/computer/shuttle/labor/one_way

/obj/item/circuitboard/ferry
	board_name = "Transport Ferry"
	build_path = /obj/machinery/computer/shuttle/ferry

/obj/item/circuitboard/ferry/request
	board_name = "Transport Ferry Console"
	build_path = /obj/machinery/computer/shuttle/ferry/request

/obj/item/circuitboard/mining_shuttle
	board_name = "Mining Shuttle"
	build_path = /obj/machinery/computer/shuttle/mining

/obj/item/circuitboard/white_ship
	board_name = "White Ship"
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

/obj/item/circuitboard/HolodeckControl
	board_name = "Holodeck Control"
	build_path = /obj/machinery/computer/HolodeckControl
	origin_tech = "programming=4"

/obj/item/circuitboard/aifixer
	board_name = "AI Integrity Restorer"
	build_path = /obj/machinery/computer/aifixer
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/area_atmos
	board_name = "Area Air Control"
	build_path = /obj/machinery/computer/area_atmos
	origin_tech = "programming=2"

/obj/item/circuitboard/telesci_console
	board_name = "Telepad Control Console"
	build_path = /obj/machinery/computer/telescience
	origin_tech = "programming=3;bluespace=3;plasmatech=4"

/obj/item/circuitboard/large_tank_control
	board_name = "Atmospheric Tank Control"
	build_path = /obj/machinery/computer/general_air_control/large_tank_control
	origin_tech = "programming=2;engineering=3;materials=2"

/obj/item/circuitboard/turbine_computer
	board_name = "Turbine Computer"
	build_path = /obj/machinery/computer/turbine_computer
	origin_tech = "programming=4;engineering=4;powerstorage=4"

/obj/item/circuitboard/HONKputer
	board_name = "HONKputer"
	build_path = /obj/machinery/computer/HONKputer
	origin_tech = "programming=2"
	icon = 'icons/obj/machines/HONKputer.dmi'
	icon_state = "bananium_board"
	board_type = "honkcomputer"


/obj/item/circuitboard/supplycomp/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/multitool))
		var/catastasis = contraband_enabled
		var/opposite_catastasis
		if(catastasis)
			opposite_catastasis = "STANDARD"
			catastasis = "BROAD"
		else
			opposite_catastasis = "BROAD"
			catastasis = "STANDARD"

		switch(alert("Current receiver spectrum is set to: [catastasis]", "Multitool-Circuitboard interface", "Switch to [opposite_catastasis]", "Cancel"))
		//switch( alert("Current receiver spectrum is set to: " {(contraband_enabled) ? ("BROAD") : ("STANDARD")} , "Multitool-Circuitboard interface" , "Switch to " {(contraband_enabled) ? ("STANDARD") : ("BROAD")}, "Cancel") )
			if("Switch to STANDARD", "Switch to BROAD")
				contraband_enabled = !contraband_enabled

			if("Cancel")
				return
			else
				to_chat(user, "DERP! BUG! Report this (And what you were doing to cause it) to Agouri")
		return
	return ..()

/obj/item/circuitboard/rdconsole/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id) || istype(I, /obj/item/pda))
		if(allowed(user))
			user.visible_message("<span class='notice'>\the [user] waves [user.p_their()] ID past the [src]'s access protocol scanner.</span>", "<span class='notice'>You swipe your ID past the [src]'s access protocol scanner.</span>")
			var/console_choice = input(user, "What do you want to configure the access to?", "Access Modification", "R&D Core") as null|anything in access_types
			if(!console_choice)
				return
			switch(console_choice)
				if("R&D Core")
					board_name = "RD Console"
					build_path = /obj/machinery/computer/rdconsole/core
					id = 1
				if("Robotics")
					board_name = "RD Console - Robotics"
					build_path = /obj/machinery/computer/rdconsole/robotics
					id = 2
				if("E.X.P.E.R.I-MENTOR")
					board_name = "RD Console - E.X.P.E.R.I-MENTOR"
					build_path = /obj/machinery/computer/rdconsole/experiment
					id = 3
				if("Mechanics")
					board_name = "RD Console - Mechanics"
					build_path = /obj/machinery/computer/rdconsole/mechanics
					id = 4
				if("Public")
					board_name = "RD Console - Public"
					build_path = /obj/machinery/computer/rdconsole/public
					id = 5

			format_board_name()
			to_chat(user, "<span class='notice'>Access protocols set to [console_choice].</span>")
		else
			to_chat(user, "<span class='warning'>Access Denied</span>")
		return
	return ..()


/obj/structure/computerframe
	name = "computer frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"
	density = TRUE
	max_integrity = 100
	var/state = 0
	var/obj/item/circuitboard/circuit = null
	var/base_mineral = /obj/item/stack/sheet/metal

/obj/structure/computerframe/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
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
		var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil(loc)
		A.amount = 5
	if(state >= 4)
		new /obj/item/stack/sheet/glass(loc, 2)

/obj/structure/computerframe/attackby(obj/item/I, mob/user, params)
	switch(state)
		if(0)
			if(istype(I, /obj/item/wrench))
				playsound(loc, I.usesound, 50, 1)
				if(do_after(user, 20 * I.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					anchored = 1
					state = 1
				return
		if(1)
			if(istype(I, /obj/item/wrench))
				playsound(loc, I.usesound, 50, 1)
				if(do_after(user, 20 * I.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					anchored = 0
					state = 0
				return
			if(istype(I, /obj/item/circuitboard) && !circuit)
				var/obj/item/circuitboard/B = I
				if(B.board_type == "computer")
					playsound(loc, B.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
					name += " ([B.board_name])"
					icon_state = "1"
					circuit = I
					user.drop_item()
					I.loc = src
				else
					to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return
			if(istype(I, /obj/item/screwdriver) && circuit)
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				state = 2
				icon_state = "2"
				return
			if(istype(I, /obj/item/crowbar) && circuit)
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				state = 1
				name = initial(name)
				icon_state = "0"
				circuit.loc = loc
				circuit = null
				return
		if(2)
			if(istype(I, /obj/item/screwdriver) && circuit)
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				state = 1
				icon_state = "1"
				return
			if(istype(I, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = I
				if(C.get_amount() >= 5)
					playsound(loc, C.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
					if(do_after(user, 20 * C.toolspeed, target = src))
						if(state == 2 && C.get_amount() >= 5 && C.use(5))
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
			if(istype(I, /obj/item/wirecutters))
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 2
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil(loc)
				A.amount = 5
				return
			if(istype(I, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = I
				if(G.get_amount() >= 2)
					playsound(loc, G.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You start to add the glass panel to the frame.</span>")
					if(do_after(user, 20 * G.toolspeed, target = src))
						if(state == 3 && G.get_amount() >= 2 && G.use(2))
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
			if(istype(I, /obj/item/crowbar))
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				state = 3
				icon_state = "3"
				new /obj/item/stack/sheet/glass(loc, 2)
				return
			if(istype(I, /obj/item/screwdriver))
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/B = new circuit.build_path (loc)
				if(circuit.powernet) B:powernet = circuit.powernet
				if(circuit.id) B:id = circuit.id
				if(circuit.records) B:records = circuit.records
				if(circuit.frequency) B:frequency = circuit.frequency
				if(istype(circuit, /obj/item/circuitboard/supplycomp))
					var/obj/machinery/computer/supplycomp/SC = B
					var/obj/item/circuitboard/supplycomp/C = circuit
					SC.can_order_contraband = C.contraband_enabled
				qdel(src)
				return
	if(user.a_intent == INTENT_HARM)
		return ..()


/obj/structure/computerframe/welder_act(mob/user, obj/item/I)
	if(state)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume) && !state)
		to_chat(user, "<span class='notice'>You deconstruct [src].</span>")
		deconstruct(TRUE)



/obj/structure/computerframe/HONKputer
	name = "Bananium Computer-frame"
	icon = 'icons/obj/machines/HONKputer.dmi'
	base_mineral = /obj/item/stack/sheet/mineral/bananium

/obj/structure/computerframe/HONKputer/attackby(obj/item/I, mob/user, params)
	switch(state)
		if(0)
			if(istype(I, /obj/item/wrench))
				playsound(loc, I.usesound, 50, 1)
				if(do_after(user, 20, target = src))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					anchored = 1
					state = 1
		if(1)
			if(istype(I, /obj/item/wrench))
				playsound(loc, I.usesound, 50, 1)
				if(do_after(user, 20 * I.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					anchored = 0
					state = 0
			if(istype(I, /obj/item/circuitboard) && !circuit)
				var/obj/item/circuitboard/B = I
				if(B.board_type == "honkcomputer")
					playsound(loc, I.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
					icon_state = "1"
					circuit = I
					user.drop_item()
					I.loc = src
				else
					to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
			if(istype(I, /obj/item/screwdriver) && circuit)
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				state = 2
				icon_state = "2"
			if(istype(I, /obj/item/crowbar) && circuit)
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				state = 1
				icon_state = "0"
				circuit.loc = loc
				circuit = null
			return
		if(2)
			if(istype(I, /obj/item/screwdriver) && circuit)
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				state = 1
				icon_state = "1"
			if(istype(I, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = I
				if(C.get_amount() >= 5)
					playsound(loc, C.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
					if(do_after(user, 20 * C.toolspeed, target = src))
						if(state == 2 && C.get_amount() >= 5 && C.use(5))
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
			if(istype(I, /obj/item/wirecutters))
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 2
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil(loc)
				A.amount = 5

			if(istype(I, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = I
				if(G.get_amount() >= 2)
					playsound(loc, G.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You start to add the glass panel to the frame.</span>")
					if(do_after(user, 20 * G.toolspeed, target = src))
						if(state == 3 && G.get_amount() >= 2 && G.use(2))
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
			if(istype(I, /obj/item/crowbar))
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				state = 3
				icon_state = "3"
				new /obj/item/stack/sheet/glass(loc, 2)
			if(istype(I, /obj/item/screwdriver))
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/B = new circuit.build_path (loc)
				if(circuit.powernet) B:powernet = circuit.powernet
				if(circuit.id) B:id = circuit.id
				if(circuit.records) B:records = circuit.records
				if(circuit.frequency) B:frequency = circuit.frequency
				qdel(src)
			return
	return ..()
