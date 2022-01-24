GLOBAL_LIST_INIT(robot_verbs_default, list(
	/mob/living/silicon/robot/proc/sensor_mode,
))

/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 100
	health = 100
	bubble_icon = "robot"
	universal_understand = 1
	deathgasp_on_death = TRUE

	var/sight_mode = 0
	var/custom_name = ""
	var/custom_sprite = 0 //Due to all the sprites involved, a var for our custom borgs may be best

	//Hud stuff
	var/obj/screen/hands = null
	var/obj/screen/inv1 = null
	var/obj/screen/inv2 = null
	var/obj/screen/inv3 = null
	var/obj/screen/lamp_button = null
	var/obj/screen/thruster_button = null

	var/shown_robot_modules = 0	//Used to determine whether they have the module menu shown or not
	var/obj/screen/robot_modules_background

	//3 Modules can be activated at any one time.
	var/obj/item/robot_module/module = null
	var/module_active = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	var/obj/item/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/stock_parts/cell/cell = null
	var/obj/machinery/camera/camera = null

	// Components are basically robot organs.
	var/list/components = list()

	var/obj/item/robot_parts/robot_suit/robot_suit = null //Used for deconstruction to remember what the borg was constructed out of..
	var/obj/item/mmi/mmi = null

	var/obj/item/pda/silicon/robot/rbPDA = null

	var/datum/wires/robot/wires = null

	var/opened = 0
	var/custom_panel = null
	var/list/custom_panel_names = list("Cricket")
	var/list/custom_eye_names = list("Cricket","Standard")
	var/emagged = 0
	var/is_emaggable = TRUE
	var/eye_protection = 0
	var/ear_protection = 0
	var/damage_protection = 0
	var/emp_protection = FALSE
 	/// Value incoming brute damage to borgs is mutiplied by.
	var/brute_mod = 1
	/// Value incoming burn damage to borgs is multiplied by.
	var/burn_mod = 1

	var/list/force_modules = list()
	var/allow_rename = TRUE
	var/weapons_unlock = FALSE
	var/static_radio_channels = FALSE

	var/wiresexposed = 0
	var/locked = 1
	var/list/req_one_access = list(ACCESS_ROBOTICS)
	var/list/req_access
	var/ident = 0
	//var/list/laws = list()
	var/viewalerts = 0
	var/modtype = "Default"
	var/lower_mod = 0
	var/datum/effect_system/spark_spread/spark_system //So they can initialize sparks whenever/N
	var/jeton = 0
	var/low_power_mode = 0 //whether the robot has no charge left.
	var/weapon_lock = 0
	var/weaponlock_time = 120
	var/lawupdate = 1 //Cyborgs will sync their laws with their AI by default
	var/lockcharge //Used when locking down a borg to preserve cell charge
	var/speed = 0 //Cause sec borgs gotta go fast //No they dont!
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/can_lock_cover = FALSE //Used to set if a borg can re-lock its cover.
	var/has_camera = TRUE
	var/pdahide = 0 //Used to hide the borg from the messenger list
	var/tracking_entities = 0 //The number of known entities currently accessing the internal camera
	var/braintype = "Cyborg"
	var/base_icon = ""
	var/modules_break = TRUE

	var/lamp_max = 10 //Maximum brightness of a borg lamp. Set as a var for easy adjusting.
	var/lamp_intensity = 0 //Luminosity of the headlamp. 0 is off. Higher settings than the minimum require power.
	var/lamp_recharging = 0 //Flag for if the lamp is on cooldown after being forcibly disabled.

	var/updating = 0 //portable camera camerachunk update

	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD)

	var/default_cell_type = /obj/item/stock_parts/cell/high
	var/magpulse = 0
	var/ionpulse = 0 // Jetpack-like effect.
	var/ionpulse_on = 0 // Jetpack-like effect.

	var/datum/action/item_action/toggle_research_scanner/scanner = null
	var/list/module_actions = list()

	var/see_reagents = FALSE // Determines if the cyborg can see reagents

/mob/living/silicon/robot/get_cell()
	return cell

/mob/living/silicon/robot/New(loc, syndie = FALSE, unfinished = FALSE, alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_language("Robot Talk", 1)

	wires = new(src)

	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	robot_modules_background.layer = HUD_LAYER	//Objects that appear on screen are on layer 20, UI should be just below it.
	robot_modules_background.plane = HUD_PLANE

	ident = rand(1, 999)
	rename_character(null, get_default_name())
	update_icons()
	update_headlamp()

	radio = new /obj/item/radio/borg(src)

	if(has_camera && !camera)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.network = list("SS13","Robots")
		if(wires.is_cut(WIRE_BORG_CAMERA)) // 5 = BORG CAMERA
			camera.status = 0

	if(mmi == null)
		mmi = new /obj/item/mmi/robotic_brain(src)	//Give the borg an MMI if he spawns without for some reason. (probably not the correct way to spawn a robotic brain, but it works)
		mmi.icon_state = "boris"

	initialize_components()
	//if(!unfinished)
	// Create all the robot parts.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.install(new C.external_type, FALSE)

	..()

	add_robot_verbs()

	// Remove inherited verbs that effectively do nothing for cyborgs, or lead to unintended behaviour.
	verbs -= /mob/living/verb/lay_down
	verbs -= /mob/living/verb/mob_sleep

	// Install a default cell into the borg if none is there yet
	var/datum/robot_component/cell_component = components["power cell"]
	var/obj/item/stock_parts/cell/C = cell || new default_cell_type(src)
	cell_component.install(C)

	init(alien, connect_to_AI, ai_to_sync_to)

	diag_hud_set_borgcell()
	scanner = new(src)
	scanner.Grant(src)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/create_trail)

/mob/living/silicon/robot/get_radio()
	return radio

/mob/living/silicon/robot/proc/create_trail(datum/source, atom/oldloc, _dir, forced)
	if(ionpulse_on)
		var/turf/T = get_turf(oldloc)
		if(!has_gravity(T))
			new /obj/effect/particle_effect/ion_trails(T, _dir)

/mob/living/silicon/robot/proc/init(alien, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)
	make_laws()
	additional_law_channels["Binary"] = ":b "
	if(!connect_to_AI)
		return
	var/found_ai = ai_to_sync_to
	if(!found_ai)
		found_ai = select_active_ai_with_fewest_borgs()
	if(found_ai)
		lawupdate = TRUE
		connect_to_ai(found_ai)
	else
		lawupdate = FALSE

	playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)

/mob/living/silicon/robot/rename_character(oldname, newname)
	if(!..(oldname, newname))
		return 0

	if(oldname != real_name)
		notify_ai(3, oldname, newname)
		custom_name = (newname != get_default_name()) ? newname : null
		setup_PDA()

		//We also need to update name of internal camera.
		if(camera)
			camera.c_tag = newname

		//Check for custom sprite
		if(!custom_sprite)
			if(ckey in GLOB.configuration.custom_sprites.cyborg_ckeys)
				custom_sprite = TRUE

	if(mmi && mmi.brainmob)
		mmi.brainmob.name = newname

	return 1


/mob/living/silicon/robot/proc/get_default_name(prefix as text)
	if(prefix)
		modtype = prefix
	if(mmi)
		if(istype(mmi, /obj/item/mmi/robotic_brain))
			braintype = "Android"
		else
			braintype = "Cyborg"
	else
		braintype = "Robot"

	if(custom_name)
		return custom_name
	else
		return "[modtype] [braintype]-[num2text(ident)]"

/mob/living/silicon/robot/verb/Namepick()
	set category = "Robot Commands"
	if(custom_name)
		return 0
	if(!allow_rename)
		to_chat(src, "<span class='warning'>Rename functionality is not enabled on this unit.</span>")
		return 0
	rename_self(braintype, 1)

/mob/living/silicon/robot/proc/sync()
	if(lawupdate && connected_ai)
		lawsync()
		photosync()

// setup the PDA and its name
/mob/living/silicon/robot/proc/setup_PDA()
	if(!rbPDA)
		rbPDA = new(src)
	rbPDA.set_name_and_job(real_name, braintype)
	var/datum/data/pda/app/messenger/M = rbPDA.find_program(/datum/data/pda/app/messenger)
	if(M)
		if(scrambledcodes)
			M.hidden = 1
		if(pdahide)
			M.toff = 1

/mob/living/silicon/robot/binarycheck()
	if(is_component_functioning("comms"))
		return 1
	return 0

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Destroy()
	SStgui.close_uis(wires)
	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)
			mmi.forceMove(T)
		if(mmi.brainmob)
			mind.transfer_to(mmi.brainmob)
			mmi.update_icon()
		else
			to_chat(src, "<span class='boldannounce'>Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug.</span>")
			ghostize()
			log_runtime(EXCEPTION("A borg has been destroyed, but its MMI lacked a brainmob, so the mind could not be transferred. Player: [ckey]."), src)
		mmi = null
	if(connected_ai)
		connected_ai.connected_robots -= src
	QDEL_NULL(wires)
	QDEL_NULL(module)
	QDEL_NULL(camera)
	QDEL_NULL(robot_suit)
	QDEL_NULL(spark_system)
	QDEL_NULL(self_diagnosis)
	QDEL_LIST_ASSOC_VAL(components)
	QDEL_NULL(rbPDA)
	QDEL_NULL(radio)
	scanner = null
	module_actions.Cut()
	return ..()

/mob/living/silicon/robot/proc/pick_module()
	if(module)
		return
	var/list/modules = list("Engineering", "Medical", "Miner", "Janitor", "Service")
	if(islist(force_modules) && force_modules.len)
		modules = force_modules.Copy()
	if(mmi != null && mmi.alien)
		modules = list("Hunter")
	modtype = input("Please, select a module!", "Robot", null, null) as null|anything in modules
	if(!modtype)
		return
	designation = modtype
	var/module_sprites[0] //Used to store the associations between sprite names and sprite index.

	if(module)
		return

	switch(modtype)
		if("Service")
			module = new /obj/item/robot_module/butler(src)
			module.channels = list("Service" = 1)
			module_sprites["Waitress"] = "Service"
			module_sprites["Kent"] = "toiletbot"
			module_sprites["Bro"] = "Brobot"
			module_sprites["Rich"] = "maximillion"
			module_sprites["Default"] = "Service2"
			module_sprites["Standard"] = "Standard-Serv"
			module_sprites["Noble-SRV"] = "Noble-SRV"
			module_sprites["Cricket"] = "Cricket-SERV"
			see_reagents = TRUE

		if("Miner")
			module = new /obj/item/robot_module/miner(src)
			module.channels = list("Supply" = 1)
			if(camera && ("Robots" in camera.network))
				camera.network.Add("Mining Outpost")
			module_sprites["Basic"] = "Miner_old"
			module_sprites["Advanced Droid"] = "droid-miner"
			module_sprites["Treadhead"] = "Miner"
			module_sprites["Standard"] = "Standard-Mine"
			module_sprites["Noble-DIG"] = "Noble-DIG"
			module_sprites["Cricket"] = "Cricket-MINE"
			module_sprites["Lavaland"] = "lavaland"

		if("Medical")
			module = new /obj/item/robot_module/medical(src)
			module.channels = list("Medical" = 1)
			if(camera && ("Robots" in camera.network))
				camera.network.Add("Medical")
			module_sprites["Basic"] = "Medbot"
			module_sprites["Surgeon"] = "surgeon"
			module_sprites["Advanced Droid"] = "droid-medical"
			module_sprites["Needles"] = "medicalrobot"
			module_sprites["Standard"] = "Standard-Medi"
			module_sprites["Noble-MED"] = "Noble-MED"
			module_sprites["Cricket"] = "Cricket-MEDI"
			status_flags &= ~CANPUSH
			see_reagents = TRUE

		if("Security")
			module = new /obj/item/robot_module/security(src)
			module.channels = list("Security" = 1)
			module_sprites["Basic"] = "secborg"
			module_sprites["Red Knight"] = "Security"
			module_sprites["Black Knight"] = "securityrobot"
			module_sprites["Bloodhound"] = "bloodhound"
			module_sprites["Standard"] = "Standard-Secy"
			module_sprites["Noble-SEC"] = "Noble-SEC"
			module_sprites["Cricket"] = "Cricket-SEC"
			status_flags &= ~CANPUSH

		if("Engineering")
			module = new /obj/item/robot_module/engineering(src)
			module.channels = list("Engineering" = 1)
			if(camera && ("Robots" in camera.network))
				camera.network.Add("Engineering")
			module_sprites["Basic"] = "Engineering"
			module_sprites["Antique"] = "engineerrobot"
			module_sprites["Landmate"] = "landmate"
			module_sprites["Standard"] = "Standard-Engi"
			module_sprites["Noble-ENG"] = "Noble-ENG"
			module_sprites["Cricket"] = "Cricket-ENGI"
			magpulse = 1

		if("Janitor")
			module = new /obj/item/robot_module/janitor(src)
			module.channels = list("Service" = 1)
			module_sprites["Basic"] = "JanBot2"
			module_sprites["Mopbot"]  = "janitorrobot"
			module_sprites["Mop Gear Rex"] = "mopgearrex"
			module_sprites["Standard"] = "Standard-Jani"
			module_sprites["Noble-CLN"] = "Noble-CLN"
			module_sprites["Cricket"] = "Cricket-JANI"

		if("Destroyer") // Rolling Borg
			module = new /obj/item/robot_module/destroyer(src)
			module.channels = list("Security" = 1)
			icon_state =  "droidcombat"
			status_flags &= ~CANPUSH

		if("Combat") // Gamma ERT
			module = new /obj/item/robot_module/combat(src)
			icon_state = "ertgamma"
			status_flags &= ~CANPUSH

		if("Hunter")
			module = new /obj/item/robot_module/alien/hunter(src)
			icon_state = "xenoborg-state-a"
			modtype = "Xeno-Hu"

	//languages
	module.add_languages(src)
	//subsystems
	module.add_subsystems_and_actions(src)

	//Custom_sprite check and entry
	if(custom_sprite && check_sprite("[ckey]-[modtype]"))
		module_sprites["Custom"] = "[src.ckey]-[modtype]"

	hands.icon_state = lowertext(module.module_type)
	SSblackbox.record_feedback("tally", "cyborg_modtype", 1, "[lowertext(modtype)]")
	rename_character(real_name, get_default_name())

	if(modtype == "Medical" || modtype == "Security" || modtype == "Combat")
		status_flags &= ~CANPUSH

	choose_icon(6,module_sprites)
	if(!static_radio_channels)
		radio.config(module.channels)
	notify_ai(2)

/mob/living/silicon/robot/proc/reset_module()
	notify_ai(2)

	uneq_all()
	SStgui.close_user_uis(src)
	sight_mode = null
	update_sight()
	hands.icon_state = "nomod"
	icon_state = "robot"
	module.remove_subsystems_and_actions(src)
	QDEL_NULL(module)

	camera.network.Remove(list("Engineering", "Medical", "Mining Outpost"))
	rename_character(real_name, get_default_name("Default"))
	languages = list()
	speech_synthesizer_langs = list()
	radio.recalculateChannels()

	update_icons()
	update_headlamp()

	speed = 0 // Remove upgrades.
	ionpulse = FALSE
	magpulse = FALSE
	weapons_unlock = FALSE
	add_language("Robot Talk", TRUE)
	if("lava" in weather_immunities) // Remove the lava-immunity effect given by a printable upgrade
		weather_immunities -= "lava"

	status_flags |= CANPUSH

//for borg hotkeys, here module refers to borg inv slot, not core module
/mob/living/silicon/robot/verb/cmd_toggle_module(module as num)
	set name = "Toggle Module"
	set hidden = 1
	toggle_module(module)

/mob/living/silicon/robot/verb/cmd_unequip_module()
	set name = "Unequip Module"
	set hidden = 1
	uneq_active()

// this verb lets cyborgs see the stations manifest
/mob/living/silicon/robot/verb/cmd_station_manifest()
	set category = "Robot Commands"
	set name = "Show Station Manifest"
	show_station_manifest()

/mob/living/silicon/robot/verb/toggle_component()
	set category = "Robot Commands"
	set name = "Toggle Component"
	set desc = "Toggle a component, conserving power."

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell") continue
		var/datum/robot_component/C = components[V]
		if(!C.is_missing())
			installed_components += V

	var/toggle = input(src, "Which component do you want to toggle?", "Toggle Component") as null|anything in installed_components
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	C.toggle()
	to_chat(src, "<span class='warning'>You [C.toggled ? "enable" : "disable"] [C.name].</span>")

/mob/living/silicon/robot/proc/sensor_mode()
	set name = "Set Sensor Augmentation"
	set desc = "Augment visual feed with internal sensor overlays."
	set category = "Robot Commands"
	toggle_sensor_mode()

/mob/living/silicon/robot/proc/add_robot_verbs()
	src.verbs |= GLOB.robot_verbs_default
	src.verbs |= silicon_subsystems

/mob/living/silicon/robot/proc/remove_robot_verbs()
	src.verbs -= GLOB.robot_verbs_default
	src.verbs -= silicon_subsystems

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	if(usr.stat == DEAD)
		to_chat(src, "<span class='userdanger'>Alert: You are dead.</span>")
		return //won't work if dead
	robot_alerts()

/mob/living/silicon/robot/proc/robot_alerts()
	var/list/dat = list()
	var/list/list/temp_alarm_list = SSalarm.alarms.Copy()
	for(var/cat in temp_alarm_list)
		if(!(cat in alarms_listend_for))
			continue
		dat += text("<B>[cat]</B><BR>\n")
		var/list/list/L = temp_alarm_list[cat].Copy()
		for(var/alarm in L)
			var/list/list/alm = L[alarm].Copy()
			var/list/list/sources = alm[3].Copy()
			var/area_name = alm[1]
			for(var/thing in sources)
				var/atom/A = locateUID(thing)
				if(A && A.z != z)
					L -= alarm
					continue
				dat += "<NOBR>"
				dat += text("-- [area_name]")
				dat += "</NOBR><BR>\n"
		if(!L.len)
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	var/datum/browser/alerts = new(usr, "robotalerts", "Current Station Alerts", 400, 410)
	var/dat_text = dat.Join("")
	alerts.set_content(dat_text)
	alerts.open()

/mob/living/silicon/robot/proc/ionpulse()
	if(!ionpulse_on)
		return

	if(cell.charge <= 50)
		toggle_ionpulse()
		return

	cell.charge -= 25 // 500 steps on a default cell.
	return 1

/mob/living/silicon/robot/proc/toggle_ionpulse()
	if(!ionpulse)
		to_chat(src, "<span class='notice'>No thrusters are installed!</span>")
		return

	ionpulse_on = !ionpulse_on
	to_chat(src, "<span class='notice'>You [ionpulse_on ? null :"de"]activate your ion thrusters.</span>")
	if(thruster_button)
		thruster_button.icon_state = "ionpulse[ionpulse_on]"

/mob/living/silicon/robot/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(30)
	else
		gib()
	return TRUE

// this function displays the cyborgs current cell charge in the stat panel
/mob/living/silicon/robot/proc/show_cell_power()
	if(cell)
		stat(null, text("Charge Left: [cell.charge]/[cell.maxcharge]"))
	else
		stat(null, text("No Cell Inserted!"))

/mob/living/silicon/robot/proc/show_gps_coords()
	if(locate(/obj/item/gps/cyborg) in module.modules)
		var/turf/T = get_turf(src)
		stat(null, "GPS: [COORD(T)]")

/mob/living/silicon/robot/proc/show_stack_energy()
	for(var/storage in module.storages) // Storages should only contain `/datum/robot_energy_storage`
		var/datum/robot_energy_storage/R = storage
		stat(null, "[R.statpanel_name]: [R.energy] / [R.max_energy]")

// update the status screen display
/mob/living/silicon/robot/Stat()
	..()
	if(!statpanel("Status"))
		return // They aren't looking at the status panel.

	show_cell_power()

	if(module)
		show_gps_coords()
		show_stack_energy()

/mob/living/silicon/robot/restrained()
	return 0

/mob/living/silicon/robot/InCritical()
	return low_power_mode

/mob/living/silicon/robot/alarm_triggered(src, class, area/A, list/O, obj/alarmsource)
	if(!(class in alarms_listend_for))
		return
	if(alarmsource.z != z)
		return
	if(stat == DEAD)
		return
	queueAlarm(text("--- [class] alarm detected in [A.name]!"), class)

/mob/living/silicon/robot/alarm_cancelled(src, class, area/A, obj/origin, cleared)
	if(cleared)
		if(!(class in alarms_listend_for))
			return
		if(origin.z != z)
			return
		queueAlarm("--- [class] alarm in [A.name] has been cleared.", class, 0)

/mob/living/silicon/robot/ex_act(severity)
	switch(severity)
		if(1.0)
			gib()
			return
		if(2.0)
			if(stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if(stat != 2)
				adjustBruteLoss(30)
	return


/mob/living/silicon/robot/bullet_act(obj/item/projectile/Proj)
	..(Proj)
	if(prob(75) && Proj.damage > 0) spark_system.start()
	return 2


/mob/living/silicon/robot/attackby(obj/item/W, mob/user, params)
	// Check if the user is trying to insert another component like a radio, actuator, armor etc.
	if(istype(W, /obj/item/robot_parts/robot_component) && opened)
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(C.is_missing() && istype(W, C.external_type))
				if(!user.drop_item())
					to_chat(user, "<span class='warning'>[W] seems to be stuck in your hand!</span>")
					return
				C.install(W)
				W.loc = null

				var/obj/item/robot_parts/robot_component/WC = W
				if(istype(WC))
					C.brute_damage = WC.brute
					C.electronics_damage = WC.burn

				to_chat(usr, "<span class='notice'>You install [W].</span>")

				return

	if(istype(W, /obj/item/stack/cable_coil) && user.a_intent == INTENT_HELP && (wiresexposed || istype(src, /mob/living/silicon/robot/drone)))
		user.changeNext_move(CLICK_CD_MELEE)
		if(!getFireLoss())
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
			return
		else if(!getFireLoss(TRUE))
			to_chat(user, "<span class='warning'>The damaged components are beyond saving!</span>")
			return
		var/obj/item/stack/cable_coil/coil = W
		adjustFireLoss(-30)
		updatehealth()
		add_fingerprint(user)
		coil.use(1)
		user.visible_message("<span class='alert'>\The [user] fixes some of the burnt wires on \the [src] with \the [coil].</span>")

	else if(istype(W, /obj/item/stock_parts/cell) && opened)	// trying to put a cell inside
		var/datum/robot_component/cell/C = components["power cell"]
		if(wiresexposed)
			to_chat(user, "Close the panel first.")
		else if(cell)
			to_chat(user, "There is a power cell already installed.")
		else
			user.drop_item()
			W.loc = src
			to_chat(user, "You insert the power cell.")
			C.install(W)
			//This will mean that removing and replacing a power cell will repair the mount, but I don't care at this point. ~Z
			C.brute_damage = 0
			C.electronics_damage = 0
			module?.update_cells()
			diag_hud_set_borgcell()

	else if(istype(W, /obj/item/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			to_chat(user, "Unable to locate a radio.")

	else if(istype(W, /obj/item/card/id) || istype(W, /obj/item/pda))			// trying to unlock the interface with an ID card
		if(emagged)//still allow them to open the cover
			to_chat(user, "The interface seems slightly damaged.")
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else
			if(allowed(W))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] [src]'s interface.")
				to_chat(src, "<span class='notice'>[user] [ locked ? "locked" : "unlocked"] your interface.</span>")
				update_icons()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			to_chat(user, "<span class='warning'>You must access the borg's internals!</span>")
		else if(!src.module && U.require_module)
			to_chat(user, "<span class='warning'>The borg must choose a module before it can be upgraded!</span>")
		else
			if(!user.drop_item())
				return
			if(U.action(src))
				user.visible_message("<span class='notice'>[user] applied [U] to [src].</span>", "<span class='notice'>You apply [U] to [src].</span>")
				U.forceMove(src)

	else if(istype(W, /obj/item/mmi_radio_upgrade))
		if(!opened)
			to_chat(user, "<span class='warning'>You must access the borg's internals!</span>")
			return
		else if(!mmi)
			to_chat(user, "<span class='warning'>This cyborg does not have an MMI to augment!</span>")
			return
		else if(mmi.radio)
			to_chat(user, "<span class='warning'>A radio upgrade is already installed in the MMI!</span>")
			return
		else if(user.drop_item())
			to_chat(user, "<span class='notice'>You apply the upgrade to [src].</span>")
			to_chat(src, "<span class='notice'>MMI radio capability installed.</span>")
			mmi.install_radio()
			qdel(W)
	else
		return ..()

/mob/living/silicon/robot/wirecutter_act(mob/user, obj/item/I)
	if(!opened)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(wiresexposed)
		wires.Interact(user)

/mob/living/silicon/robot/multitool_act(mob/user, obj/item/I)
	if(!opened)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(wiresexposed)
		wires.Interact(user)

/mob/living/silicon/robot/screwdriver_act(mob/user, obj/item/I)
	if(!opened)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(!cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, "<span class='notice'>The wires have been [wiresexposed ? "exposed" : "unexposed"]</span>")
		update_icons()
		I.play_tool_sound(user, I.tool_volume)
	else //radio check
		if(radio)
			radio.screwdriver_act(user, I)//Push it to the radio to let it handle everything
		else
			to_chat(user, "Unable to locate a radio.")
		update_icons()

/mob/living/silicon/robot/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!opened)
		if(locked)
			to_chat(user, "The cover is locked and cannot be opened.")
			return
		if(!I.use_tool(src, user, 0, volume = I.tool_volume))
			return
		to_chat(user, "You open the cover.")
		opened = TRUE
		update_icons()
		return
	else if(cell)
		if(!I.use_tool(src, user, 0, volume = I.tool_volume))
			return
		to_chat(user, "You close the cover.")
		opened = FALSE
		update_icons()
		return
	else if(wiresexposed && wires.is_all_cut())
		//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
		if(!mmi)
			to_chat(user, "[src] has no brain to remove.")
			return
		to_chat(user, "You jam the crowbar into the robot and begin levering the securing bolts...")
		if(I.use_tool(src, user, 30, volume = I.tool_volume))
			user.visible_message("[user] deconstructs [src]!", "<span class='notice'>You unfasten the securing bolts, and [src] falls to pieces!</span>")
			deconstruct()
		return
	// Okay we're not removing the cell or an MMI, but maybe something else?
	var/list/removable_components = list()
	for(var/V in components)
		if(V == "power cell")
			continue
		var/datum/robot_component/C = components[V]
		if(!C.is_missing())
			removable_components += V
	if(module)
		removable_components += module.custom_removals
	var/remove = input(user, "Which component do you want to pry out?", "Remove Component") as null|anything in removable_components
	if(!remove || !Adjacent(user) || !opened)
		return

	var/datum/robot_component/C = components[remove]
	if(C.is_missing()) // Somebody else removed it during the input
		return

	if(module && module.handle_custom_removal(remove, user, I))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/obj/item/robot_parts/robot_component/thing = C.wrapped
	to_chat(user, "You remove \the [thing].")
	if(istype(thing))
		thing.brute = C.brute_damage
		thing.burn = C.electronics_damage

	C.uninstall()
	thing.loc = loc





/mob/living/silicon/robot/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(I.force && I.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	..()

// Here so admins can unemag borgs.
/mob/living/silicon/robot/unemag()
	SetEmagged(FALSE)
	if(!module)
		return
	uneq_all()
	module.module_type = initial(module.module_type)
	update_module_icon()
	module.unemag()
	clear_supplied_laws()
	laws = new /datum/ai_laws/crewsimov

/mob/living/silicon/robot/emag_act(mob/user)
	if(!ishuman(user) && !issilicon(user))
		return
	var/mob/living/M = user
	if(!opened)//Cover is closed
		if(!is_emaggable)
			to_chat(user, "The emag sparks, and flashes red. This mechanism does not appear to be emaggable.")
		else if(locked)
			to_chat(user, "You emag the cover lock.")
			locked = 0
		else
			to_chat(user, "The cover is already unlocked.")
		return

	if(opened)//Cover is open
		if(emagged)
			return //Prevents the X has hit Y with Z message also you cant emag them twice
		if(wiresexposed)
			to_chat(user, "You must close the panel first")
			return
		else
			sleep(6)
			SetEmagged(TRUE)
			SetLockdown(1) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
			if(hud_used)
				hud_used.update_robot_modules_display()	//Shows/hides the emag item if the inventory screen is already open.
			disconnect_from_ai()
			to_chat(user, "You emag [src]'s interface.")
			log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
			clear_supplied_laws()
			clear_inherent_laws()
			laws = new /datum/ai_laws/syndicate_override
			var/time = time2text(world.realtime,"hh:mm:ss")
			GLOB.lawchanges.Add("[time] <B>:</B> [M.name]([M.key]) emagged [name]([key])")
			set_zeroth_law("Only [M.real_name] and people [M.p_they()] designate[M.p_s()] as being such are Syndicate Agents.")
			playsound_local(src, 'sound/voice/aisyndihack.ogg', 75, FALSE)
			to_chat(src, "<span class='warning'>ALERT: Foreign software detected.</span>")
			sleep(5)
			to_chat(src, "<span class='warning'>Initiating diagnostics...</span>")
			sleep(20)
			to_chat(src, "<span class='warning'>SynBorg v1.7 loaded.</span>")
			sleep(5)
			to_chat(src, "<span class='warning'>LAW SYNCHRONISATION ERROR</span>")
			sleep(5)
			to_chat(src, "<span class='warning'>Would you like to send a report to NanoTraSoft? Y/N</span>")
			sleep(10)
			to_chat(src, "<span class='warning'>> N</span>")
			sleep(25)
			to_chat(src, "<span class='warning'>ERRORERRORERROR</span>")
			to_chat(src, "<b>Obey these laws:</b>")
			laws.show_laws(src)
			to_chat(src, "<span class='boldwarning'>ALERT: [M.real_name] is your new master. Obey your new laws and [M.p_their()] commands.</span>")
			SetLockdown(0)
			if(module)
				module.emag_act()
				module.module_type = "Malf" // For the cool factor
				update_module_icon()
				module.rebuild_modules() // This will add the emagged items to the borgs inventory.
			update_icons()
		return

/mob/living/silicon/robot/verb/toggle_own_cover()
	set category = "Robot Commands"
	set name = "Toggle Cover"
	set desc = "Toggles the lock on your cover."

	if(can_lock_cover)
		if(alert("Are you sure?", locked ? "Unlock Cover" : "Lock Cover", "Yes", "No") == "Yes")
			locked = !locked
			update_icons()
			to_chat(usr, "<span class='notice'>You [locked ? "lock" : "unlock"] your cover.</span>")
		return
	if(!locked)
		to_chat(usr, "<span class='warning'>You cannot lock your cover yourself. Find a robotocist.</span>")
		return
	if(alert("You cannnot lock your own cover again. Are you sure?\n           You will need a robotocist to re-lock you.", "Unlock Own Cover", "Yes", "No") == "Yes")
		locked = !locked
		update_icons()
		to_chat(usr, "<span class='notice'>You unlock your cover.</span>")

/mob/living/silicon/robot/attack_ghost(mob/user)
	if(wiresexposed)
		wires.Interact(user)
	else
		..() //this calls the /mob/living/attack_ghost proc for the ghost health/cyborg analyzer

/mob/living/silicon/robot/proc/allowed(obj/item/I)
	var/obj/dummy = new /obj(null) // Create a dummy object to check access on as to avoid having to snowflake check_access on every mob
	dummy.req_access = req_access
	dummy.req_one_access = req_one_access

	if(dummy.check_access(I))
		qdel(dummy)
		return 1

	qdel(dummy)
	return 0

/mob/living/silicon/robot/update_icons()
	overlays.Cut()
	if(stat != DEAD && !(paralysis || stunned || IsWeakened() || low_power_mode)) //Not dead, not stunned.
		if(custom_panel in custom_eye_names)
			overlays += "eyes-[custom_panel]"
		else
			overlays += "eyes-[icon_state]"
	else
		overlays -= "eyes"
	if(opened)
		var/panelprefix = "ov"
		if(custom_sprite) //Custom borgs also have custom panels, heh
			panelprefix = "[ckey]"
		if(custom_panel in custom_panel_names) //For default borgs with different panels
			panelprefix = custom_panel
		if(wiresexposed)
			overlays += "[panelprefix]-openpanel +w"
		else if(cell)
			overlays += "[panelprefix]-openpanel +c"
		else
			overlays += "[panelprefix]-openpanel -c"
	borg_icons()
	update_fire()

/mob/living/silicon/robot/proc/borg_icons() // Exists so that robot/destroyer can override it
	return

/mob/living/silicon/robot/Topic(href, href_list)
	if(..())
		return 1

	if(usr != src)
		return 1

	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)
		return 1

	if(href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if(istype(O) && (O.loc == src))
			O.attack_self(src)
		return 1

	if(href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if(!istype(O) || !(O.loc == src || O.loc == src.module))
			return 1

		activate_module(O)

	//Show alerts window if user clicked on "Show alerts" in chat
	if(href_list["showalerts"])
		robot_alerts()
		return TRUE

	if(href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(module_state_1 == O)
				module_state_1 = null
				contents -= O
			else if(module_state_2 == O)
				module_state_2 = null
				contents -= O
			else if(module_state_3 == O)
				module_state_3 = null
				contents -= O
			else
				to_chat(src, "Module isn't activated.")
		else
			to_chat(src, "Module isn't activated")
		return 1

	return 1

/mob/living/silicon/robot/proc/radio_menu()
	radio.interact(src)

/mob/living/silicon/robot/proc/control_headlamp()
	if(stat || lamp_recharging || low_power_mode)
		to_chat(src, "<span class='danger'>This function is currently offline.</span>")
		return
	if(is_ventcrawling(src))
		return

//Some sort of magical "modulo" thing which somehow increments lamp power by 2, until it hits the max and resets to 0.
	lamp_intensity = (lamp_intensity+2) % (lamp_max+2)
	to_chat(src, "[lamp_intensity ? "Headlamp power set to Level [lamp_intensity/2]" : "Headlamp disabled."]")
	update_headlamp()

/mob/living/silicon/robot/proc/update_headlamp(turn_off = 0, cooldown = 100, show_warning = TRUE)
	set_light(0)

	if(lamp_intensity && (turn_off || stat || low_power_mode))
		if(show_warning)
			to_chat(src, "<span class='danger'>Your headlamp has been deactivated.</span>")
		lamp_intensity = 0
		lamp_recharging = 1
		spawn(cooldown) //10 seconds by default, if the source of the deactivation does not keep stat that long.
			lamp_recharging = 0
	else
		set_light(light_range + lamp_intensity)

	if(lamp_button)
		lamp_button.icon_state = "lamp[lamp_intensity]"

	update_icons()

/mob/living/silicon/robot/proc/deconstruct()
	var/turf/T = get_turf(src)
	if(robot_suit)
		robot_suit.forceMove(T)
		robot_suit.l_leg.forceMove(T)
		robot_suit.l_leg = null
		robot_suit.r_leg.forceMove(T)
		robot_suit.r_leg = null
		new /obj/item/stack/cable_coil(T, robot_suit.chest.wired)
		robot_suit.chest.forceMove(T)
		robot_suit.chest.wired = FALSE
		robot_suit.chest = null
		robot_suit.l_arm.forceMove(T)
		robot_suit.l_arm = null
		robot_suit.r_arm.forceMove(T)
		robot_suit.r_arm = null
		robot_suit.head.forceMove(T)
		robot_suit.head.flash1.forceMove(T)
		robot_suit.head.flash1.burn_out()
		robot_suit.head.flash1 = null
		robot_suit.head.flash2.forceMove(T)
		robot_suit.head.flash2.burn_out()
		robot_suit.head.flash2 = null
		robot_suit.head = null
		robot_suit.updateicon()
	else
		new /obj/item/robot_parts/robot_suit(T)
		new /obj/item/robot_parts/l_leg(T)
		new /obj/item/robot_parts/r_leg(T)
		new /obj/item/stack/cable_coil(T, 1)
		new /obj/item/robot_parts/chest(T)
		new /obj/item/robot_parts/l_arm(T)
		new /obj/item/robot_parts/r_arm(T)
		new /obj/item/robot_parts/head(T)
		var/b
		for(b=0, b!=2, b++)
			var/obj/item/flash/F = new /obj/item/flash(T)
			F.burn_out()
	if(cell) //Sanity check.
		cell.forceMove(T)
		cell = null
	qdel(src)

#define BORG_CAMERA_BUFFER 3 SECONDS

/mob/living/silicon/robot/Move(atom/newloc, direct, movetime)
	var/oldLoc = loc
	. = ..()
	if(. && !updating && camera)
		updating = TRUE
		spawn(BORG_CAMERA_BUFFER)
			if(camera && oldLoc != loc)
				GLOB.cameranet.updatePortableCamera(camera)
			updating = FALSE

#undef BORG_CAMERA_BUFFER

/mob/living/silicon/robot/proc/self_destruct()
	if(emagged)
		if(mmi)
			qdel(mmi)
		explosion(src.loc,1,2,4,flame_range = 2)
	else
		explosion(src.loc,-1,0,2)
	gib()
	return

/mob/living/silicon/robot/proc/UnlinkSelf()
	disconnect_from_ai()
	lawupdate = 0
	lockcharge = 0
	canmove = 1
	scrambledcodes = 1
	//Disconnect it's camera so it's not so easily tracked.
	QDEL_NULL(src.camera)
	// I'm trying to get the Cyborg to not be listed in the camera list
	// Instead of being listed as "deactivated". The downside is that I'm going
	// to have to check if every camera is null or not before doing anything, to prevent runtime errors.
	// I could change the network to null but I don't know what would happen, and it seems too hacky for me.

/mob/living/silicon/robot/proc/ResetSecurityCodes()
	set category = "Robot Commands"
	set name = "Reset Identity Codes"
	set desc = "Scrambles your security and identification codes and resets your current buffers.  Unlocks you and but permanently severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		to_chat(R, "Buffers flushed and reset. Camera system shutdown. All systems operational.")
		src.verbs -= /mob/living/silicon/robot/proc/ResetSecurityCodes

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	var/obj/item/W = get_active_hand()
	if(W)
		W.attack_self(src)

	return

/mob/living/silicon/robot/proc/SetLockdown(state = 1)
	// They stay locked down if their wire is cut.
	if(wires.is_cut(WIRE_BORG_LOCKED))
		state = 1
	if(state)
		throw_alert("locked", /obj/screen/alert/locked)
	else
		clear_alert("locked")
	lockcharge = state
	update_canmove()

/mob/living/silicon/robot/proc/choose_icon(triesleft, list/module_sprites)

	if(triesleft<1 || !module_sprites.len)
		return
	else
		triesleft--

	var/icontype
	lockcharge = 1  //Locks borg until it select an icon to avoid secborgs running around with a standard sprite
	icontype = input("Select an icon! [triesleft ? "You have [triesleft] more chances." : "This is your last try."]", "Robot", null, null) in module_sprites

	if(icontype)
		if(icontype == "Custom")
			icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		else
			icon = 'icons/mob/robots.dmi'
		icon_state = module_sprites[icontype]
		if(icontype == "Bro")
			module.module_type = "Brobot"
			update_module_icon()
		lockcharge = null
		var/list/names = splittext(icontype, "-")
		custom_panel = trim(names[1])
	else
		to_chat(src, "Something is badly wrong with the sprite selection. Harass a coder.")
		icon_state = module_sprites[1]
		lockcharge = null
		return

	update_icons()

	if(triesleft >= 1)
		var/choice = input("Look at your icon - is this what you want?") in list("Yes","No")
		if(choice=="No")
			choose_icon(triesleft, module_sprites)
			return
		else
			triesleft = 0
			return
	else
		to_chat(src, "Your icon has been set. You now require a module reset to change it.")

/mob/living/silicon/robot/proc/notify_ai(notifytype, oldname, newname)
	if(!connected_ai)
		return
	switch(notifytype)
		if(1) //New Cyborg
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - New cyborg connection detected: <a href='byond://?src=[connected_ai.UID()];track2=\ref[connected_ai];track=\ref[src]'>[name]</a></span><br>")
		if(2) //New Module
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - Cyborg module change detected: [name] has loaded the [designation] module.</span><br>")
		if(3) //New Name
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - Cyborg reclassification detected: [oldname] is now designated as [newname].</span><br>")

/mob/living/silicon/robot/proc/disconnect_from_ai()
	if(connected_ai)
		sync() // One last sync attempt
		connected_ai.connected_robots -= src
		connected_ai = null

/mob/living/silicon/robot/proc/connect_to_ai(mob/living/silicon/ai/AI)
	if(AI && AI != connected_ai)
		disconnect_from_ai()
		connected_ai = AI
		connected_ai.connected_robots |= src
		notify_ai(1)
		if(module)
			module.rebuild_modules() //This way, if a borg gets linked to a malf AI that has upgrades, they get their upgrades.
		sync()

/mob/living/silicon/robot/adjustOxyLoss(amount)
	if(suiciding)
		return ..()
	else
		return STATUS_UPDATE_NONE

/mob/living/silicon/robot/regenerate_icons()
	..()
	update_module_icon()

/mob/living/silicon/robot/emp_act(severity)
	if(emp_protection)
		return
	..()
	switch(severity)
		if(1)
			disable_component("comms", 160)
		if(2)
			disable_component("comms", 60)

/mob/living/silicon/robot/deathsquad
	base_icon = "nano_bloodhound"
	icon_state = "nano_bloodhound"
	designation = "SpecOps"
	lawupdate = 0
	scrambledcodes = 1
	has_camera = FALSE
	req_one_access = list(ACCESS_CENT_SPECOPS)
	ionpulse = 1
	magpulse = 1
	pdahide = 1
	eye_protection = 2 // Immunity to flashes and the visual part of flashbangs
	ear_protection = 1 // Immunity to the audio part of flashbangs
	damage_protection = 10 // Reduce all incoming damage by this number
	allow_rename = FALSE
	modtype = "Commando"
	faction = list("nanotrasen")
	is_emaggable = FALSE
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/bluespace
	see_reagents = TRUE

/mob/living/silicon/robot/deathsquad/init(alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/deathsquad
	module = new /obj/item/robot_module/deathsquad(src)
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)
	radio = new /obj/item/radio/borg/deathsquad(src)
	radio.recalculateChannels()
	playsound(get_turf(src), 'sound/mecha/nominalnano.ogg', 75, FALSE)

/mob/living/silicon/robot/deathsquad/bullet_act(obj/item/projectile/P)
	if(istype(P) && P.is_reflectable && P.starting)
		visible_message("<span class='danger'>[P] gets reflected by [src]!</span>", "<span class='userdanger'>[P] gets reflected by [src]!</span>")
		P.reflect_back(src)
		return -1
	return ..(P)


/mob/living/silicon/robot/ert
	designation = "ERT"
	lawupdate = 0
	scrambledcodes = 1
	req_one_access = list(ACCESS_CENT_SPECOPS)
	ionpulse = 1
	force_modules = list("Engineering", "Medical")
	static_radio_channels = 1
	allow_rename = FALSE
	weapons_unlock = TRUE
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/super
	var/eprefix = "Amber"
	see_reagents = TRUE


/mob/living/silicon/robot/ert/init(alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/ert_override
	radio = new /obj/item/radio/borg/ert(src)
	radio.recalculateChannels()
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)

/mob/living/silicon/robot/ert/New(loc)
	..(loc)
	var/rnum = rand(1,1000)
	var/borgname = "[eprefix] ERT [rnum]"
	name = borgname
	custom_name = borgname
	real_name = name
	mind = new
	mind.current = src
	mind.set_original_mob(src)
	mind.assigned_role = SPECIAL_ROLE_ERT
	mind.special_role = SPECIAL_ROLE_ERT
	if(!(mind in SSticker.minds))
		SSticker.minds += mind
	SSticker.mode.ert += mind


/mob/living/silicon/robot/ert/red
	eprefix = "Red"
	default_cell_type = /obj/item/stock_parts/cell/hyper

/mob/living/silicon/robot/ert/gamma
	default_cell_type = /obj/item/stock_parts/cell/bluespace
	force_modules = list("Combat", "Engineering", "Medical")
	damage_protection = 5 // Reduce all incoming damage by this number
	eprefix = "Gamma"
	magpulse = 1


/mob/living/silicon/robot/destroyer
	// admin-only borg, the seraph / special ops officer of borgs
	base_icon = "droidcombat"
	icon_state = "droidcombat"
	modtype = "Destroyer"
	designation = "Destroyer"
	lawupdate = 0
	scrambledcodes = 1
	has_camera = FALSE
	req_one_access = list(ACCESS_CENT_SPECOPS)
	ionpulse = 1
	magpulse = 1
	pdahide = 1
	eye_protection = 2 // Immunity to flashes and the visual part of flashbangs
	ear_protection = 1 // Immunity to the audio part of flashbangs
	emp_protection = TRUE // Immunity to EMP, due to heavy shielding
	damage_protection = 20 // Reduce all incoming damage by this number. Very high in the case of /destroyer borgs, since it is an admin-only borg.
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/bluespace
	see_reagents = TRUE

/mob/living/silicon/robot/destroyer/init(alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)
	additional_law_channels["Binary"] = ":b "
	laws = new /datum/ai_laws/deathsquad
	module = new /obj/item/robot_module/destroyer(src)
	module.add_languages(src)
	module.add_subsystems_and_actions(src)
	status_flags &= ~CANPUSH
	if(radio)
		qdel(radio)
	radio = new /obj/item/radio/borg/ert/specops(src)
	radio.recalculateChannels()
	playsound(get_turf(src), 'sound/mecha/nominalnano.ogg', 75, FALSE)

/mob/living/silicon/robot/destroyer/borg_icons()
	if(base_icon == "")
		base_icon = icon_state
	if(module_active && istype(module_active,/obj/item/borg/destroyer/mobility))
		icon_state = "[base_icon]-roll"
	else
		icon_state = base_icon
		overlays += "[base_icon]-shield"


/mob/living/silicon/robot/extinguish_light()
	update_headlamp(1, 150)

/mob/living/silicon/robot/rejuvenate()
	..()
	var/brute = 1000
	var/burn = 1000
	var/list/datum/robot_component/borked_parts = get_damaged_components(TRUE, TRUE, TRUE, TRUE)
	for(var/datum/robot_component/borked_part in borked_parts)
		brute = borked_part.brute_damage
		burn = borked_part.electronics_damage
		borked_part.heal_damage(brute,burn)
		borked_part.install(new borked_part.external_type)

/mob/living/silicon/robot/proc/check_sprite(spritename)
	. = FALSE

	var/static/all_borg_icon_states = icon_states('icons/mob/custom_synthetic/custom-synthetic.dmi')
	if(spritename in all_borg_icon_states)
		. = TRUE

/mob/living/silicon/robot/check_eye_prot()
	return eye_protection

/mob/living/silicon/robot/check_ear_prot()
	return ear_protection

/mob/living/silicon/robot/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(sight_mode & BORGMESON)
		sight |= SEE_TURFS
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	if(sight_mode & BORGXRAY)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_invisible = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		see_in_dark = 8

	if(sight_mode & BORGTHERM)
		sight |= SEE_MOBS
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/// Used in `robot_bindings.dm` when the user presses "A" if on AZERTY mode, or "Q" on QWERTY mode.
/mob/living/silicon/robot/proc/on_drop_hotkey_press()
	var/obj/item/gripper/G = get_active_hand()
	if(istype(G) && G.gripped_item)
		G.drop_gripped_item() // if the active module is a gripper, try to drop its held item.
	else
		uneq_active() // else unequip the module and put it back into the robot's inventory.
		return

/mob/living/silicon/robot/proc/check_module_damage(makes_sound = TRUE)
	if(modules_break)
		if(health < 50) //Gradual break down of modules as more damage is sustained
			if(uneq_module(module_state_3))
				if(makes_sound)
					audible_message("<span class='warning'>[src] sounds an alarm! \"SYSTEM ERROR: Module 3 OFFLINE.\"</span>")
					playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
				to_chat(src, "<span class='userdanger'>SYSTEM ERROR: Module 3 OFFLINE.</span>")

			if(health < 0)
				if(uneq_module(module_state_2))
					if(makes_sound)
						audible_message("<span class='warning'>[src] sounds an alarm! \"SYSTEM ERROR: Module 2 OFFLINE.\"</span>")
						playsound(loc, 'sound/machines/warning-buzzer.ogg', 60, TRUE)
					to_chat(src, "<span class='userdanger'>SYSTEM ERROR: Module 2 OFFLINE.</span>")

				if(health < -50)
					if(uneq_module(module_state_1))
						if(makes_sound)
							audible_message("<span class='warning'>[src] sounds an alarm! \"CRITICAL ERROR: All modules OFFLINE.\"</span>")
							playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, TRUE)
						to_chat(src, "<span class='userdanger'>CRITICAL ERROR: All modules OFFLINE.</span>")

/mob/living/silicon/robot/can_see_reagents()
	return see_reagents
