GLOBAL_LIST_INIT(robot_verbs_default, list(
	/mob/living/silicon/robot/proc/sensor_mode,
))

/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	bubble_icon = "robot"
	universal_understand = TRUE
	deathgasp_on_death = TRUE
	appearance_flags = LONG_GLIDE | PIXEL_SCALE | KEEP_TOGETHER | TILE_BOUND
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	hud_type = /datum/hud/robot

	var/sight_mode = 0
	var/custom_name = ""
	var/custom_sprite = FALSE // Due to all the sprites involved, a var for our custom borgs may be best.

	// HUD stuff.
	var/atom/movable/screen/hands = null
	var/list/inventory_screens = list()
	var/atom/movable/screen/lamp_button = null
	var/atom/movable/screen/thruster_button = null
	var/atom/movable/screen/pda_button = null

	/// A reference to the type of cyborg it is, i.e. Engineering, Security, Medical etc.
	var/obj/item/robot_module/module = null
	/// The item the borg currently has selected, or null if nothing is selected
	var/obj/item/selected_item
	/// The list of up to 3 items the borg can have "equipped". The contents will either be CYBORG_EMPTY_MODULE for nothing, or the item selected
	var/list/all_active_items = list(CYBORG_EMPTY_MODULE, CYBORG_EMPTY_MODULE, CYBORG_EMPTY_MODULE)

	var/obj/item/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/stock_parts/cell/cell = null
	var/obj/machinery/camera/camera = null

	/// Components are basically robot organs.
	var/list/components = list()

	/// Used for deconstruction to remember what the robot was constructed out of.
	var/obj/item/robot_parts/robot_suit/robot_suit = null
	/// Used for deconstruction to remember what the robot was constructed out of.
	var/obj/item/mmi/mmi = null

	var/obj/item/pda/silicon/robot/rbPDA = null

	var/datum/wires/robot/wires = null

	/// Is the robot's maintenance panel open?
	var/opened = FALSE
	/// Does the robot have a non-default sprite for an open service panel?
	var/custom_panel = null
	/// Robot skins with non-default sprites for an open service panel.
	var/list/custom_panel_names = list("Cricket", "Rover")
	/// Robot skins with different sprites for open panels for each module.
	var/list/variable_custom_panels = list("Rover-Serv", "Rover-Medi")
	/// Robot skins with multiple variants for different modules. They require special handling to make their eyes display.
	var/list/custom_eye_names = list("Cricket", "Standard")
	/// Has the robot been emagged?
	var/emagged = FALSE
	/// Can the robot be emagged?
	var/is_emaggable = TRUE
	/// Is the robot protected from the visual portion of flashbangs and flashes?
	var/eye_protection = FALSE
	/// Is the robot protected from the audio component of flashbangs? Prevents inflicting confusion.
	var/ear_protection = FALSE
	/// All incoming damage has this number subtracted from it.
	var/damage_protection = 0
	/// Is the robot immune to EMPs?
	var/emp_protection = FALSE
	/// Incoming brute damage is multiplied by this number.
	var/brute_mod = 1
	/// Incoming burn damage is multiplied by this number.
	var/burn_mod = 1
	///If the cyborg is rebooting from stamcrit
	var/rebooting = FALSE
	///If the cyborg is in a charger, or otherwise receiving power from an outside source.
	var/externally_powered = FALSE
	///What the cyborg's maximum slowdown penalty is, if it has one.
	var/slowdown_cap = INFINITY
	var/list/force_modules
	/// Can a robot rename itself with the Namepick verb?
	var/allow_rename = TRUE
	/// Can a robot change it's looks after the module is initialized? Used by syndicate combat borgs.
	var/allow_resprite = FALSE
	/// Has the robot done its one allowed resprite?
	var/done_resprite = FALSE
	/// Setting to TRUE unlocks a borg's Safety Override modules.
	var/weapons_unlock = FALSE
	var/static_radio_channels = FALSE

	var/wiresexposed = FALSE
	/// Is the robot's cover locked?
	var/locked = TRUE
	/// Determines the ID access needed to unlock the robot's cover.
	var/list/req_one_access = list(ACCESS_ROBOTICS)
	/// Used for robot access checks.
	var/list/req_access
	/// Used when generating the number in default robot names.
	var/ident = 0
	//var/list/laws = list()
	var/viewalerts = FALSE
	/// What specialisation the robot has.
	var/modtype = "Default"
	var/datum/effect_system/spark_spread/spark_system //So they can initialize sparks whenever/N
	/// Has the robot's power cell run out of charge?
	var/low_power_mode = FALSE
	/// Determines if the robot tries to sync its laws to a connected AI.
	var/lawupdate = TRUE
	/// Used when locking down a robot to preserve cell charge.
	var/lockcharge
	/// Speed modifier. Positive numbers reduce speed, negative numbers increase it.
	var/speed = 0
	/// If set to TRUE, a robot will not be visible on the robotics control console.
	var/scrambledcodes = FALSE
	/// If set to TRUE, a robot can re-lock its own cover.
	var/can_lock_cover = FALSE
	/// Determines if a robot acts as a mobile security camera that can be observed through security consoles or by an AI.
	var/has_camera = TRUE
	/// If set to TRUE, the robot will be hidden on the PDA messenger list.
	var/pdahide = FALSE
	/// The number of known entities currently accessing the internal camera.
	var/tracking_entities = 0
	/// Determines if the robot is referred to as an "Android", "Robot", or "Cyborg" based on the type of brain inside.
	var/braintype = "Cyborg"
	/// The default skin of some special robots.
	var/base_icon = ""
	/// If set to TRUE, the robot's 3 module slots will progressively become unusable as they take damage.
	var/modules_break = TRUE
	/// Is the robot already being charged by a roboticist?
	var/being_charged

	/// Maximum brightness of a robot's headlamp. Set as a var for easy adjusting.
	var/lamp_max = 10
	/// Luminosity of the headlamp. 0 is off. Higher settings than the minimum require power. Increments in steps of 2.
	var/lamp_intensity = 0
	/// Flag for if the headlamp is on cooldown after being forcibly disabled (e.g. by a shadow deamon).
	var/lamp_recharging = FALSE

	/// When the camera moved signal was sent last. Avoid overdoing it.
	var/last_camera_update

	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD)

	var/default_cell_type = /obj/item/stock_parts/cell/high
	/// Does the robot have ion thrusters installed?
	var/ionpulse = FALSE
	/// Are the robot's ion thrusters activated?
	var/ionpulse_on = FALSE
	/// Does the robot clean dirt under it when it moves onto a tile?
	var/floorbuffer = FALSE

	var/datum/action/item_action/toggle_research_scanner/scanner = null
	var/list/module_actions = list()

	/// If set to TRUE, the robot can see the types and precice quantities of reagents in transparent containers, the % amount of different reagents in opaque containers, and can identify different blood types.
	var/has_advanced_reagent_vision = FALSE

	/// Integer used to determine self-mailing location, used only by drones and saboteur robots.
	var/mail_destination = 1
	var/datum/ui_module/robot_self_diagnosis/self_diagnosis
	var/datum/ui_module/destination_tagger/mail_setter
	silicon_subsystems = list(
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager)

/mob/living/silicon/robot/get_cell()
	return cell

/mob/living/silicon/robot/New(loc, syndie = FALSE, unfinished = FALSE, alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_language("Robot Talk", 1)

	wires = new(src)

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
			camera.turn_off(src, FALSE)

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
	remove_verb(src, /mob/living/verb/rest)
	remove_verb(src, /mob/living/verb/mob_sleep)

	// Install a default cell into the borg if none is there yet
	var/datum/robot_component/cell_component = components["power cell"]
	var/obj/item/stock_parts/cell/C = cell || new default_cell_type(src)
	cell_component.install(C)

	init(alien, connect_to_AI, ai_to_sync_to)

	diag_hud_set_borgcell()
	scanner = new(src)
	scanner.Grant(src)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(create_trail))
	RegisterSignal(src, COMSIG_ENTERED_BORGCHARGER, PROC_REF(gain_external_power))
	RegisterSignal(src, COMSIG_EXITED_BORGCHARGER, PROC_REF(lose_external_power))
	robot_module_hat_offset(icon_state)

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
		return FALSE

	if(oldname != real_name)
		notify_ai(3, oldname, newname)
		custom_name = (newname != get_default_name()) ? newname : null
		setup_PDA()

		//We also need to update name of internal camera.
		if(camera)
			camera.c_tag = newname

		//Check for custom sprite
		check_custom_sprite()

	if(mmi && mmi.brainmob)
		mmi.brainmob.name = newname

	return TRUE

/mob/living/silicon/robot/proc/check_custom_sprite()
	if(!custom_sprite && (ckey in GLOB.configuration.custom_sprites.cyborg_ckeys))
		custom_sprite = TRUE


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

/mob/living/silicon/robot/verb/Lookpick()
	set category = "Robot Commands"
	set name = "Change module look"
	if(!modtype)
		return FALSE
	if(done_resprite)
		to_chat(src, "<span class='warning'>You have already selected your look, you can not change it again.</span>")
		return FALSE
	if(!allow_resprite)
		to_chat(src, "<span class='warning'>Changing the look of the module is not enabled on this unit.</span>")
		return FALSE
	// Pick a sprite
	var/module_sprites = get_module_sprites(modtype)
	var/selected_sprite = show_radial_menu(src, src, module_sprites, radius = 42)
	if(!selected_sprite)
		return FALSE
	done_resprite = TRUE
	initialize_sprites(selected_sprite, module_sprites)

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
	remove_robot_mindslave() // You cannot be connected to the malf AI if you are a pile of debris.
	SStgui.close_uis(wires)
	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)
			mmi.forceMove(T)
		if(mmi.brainmob)
			mind.transfer_to(mmi.brainmob)
			mmi.update_icon()
		else
			to_chat(src, "<span class='boldannounceooc'>Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug.</span>")
			ghostize()
			stack_trace("A borg has been destroyed, but its MMI lacked a brainmob, so the mind could not be transferred. Player: [ckey].")
		mmi = null
	if(connected_ai)
		connected_ai.connected_robots -= src
	QDEL_NULL(wires)
	QDEL_NULL(module)
	QDEL_NULL(camera)
	QDEL_NULL(robot_suit)
	QDEL_NULL(spark_system)
	QDEL_NULL(self_diagnosis)
	QDEL_NULL(mail_setter)
	QDEL_LIST_ASSOC_VAL(components)
	QDEL_NULL(rbPDA)
	QDEL_NULL(radio)
	scanner = null
	module_actions.Cut()
	return ..()

/mob/living/silicon/robot/update_runechat_msg_location()
	if(istgvehicle(loc))
		runechat_msg_location = loc.UID()
	else
		return ..()

/mob/living/silicon/robot/proc/pick_module()
	if(module)
		return
	// Pick a module type
	var/selected_module = show_radial_menu(src, src, get_module_types(), radius = 42)
	if(!selected_module || module)
		return
	// Pick a sprite
	var/module_sprites = get_module_sprites(selected_module)
	var/selected_sprite = show_radial_menu(src, src, module_sprites, radius = 42)
	if(!selected_sprite)
		return

// Now actually set the module and sprites
	initialize_module(selected_module, selected_sprite, module_sprites)

/**
  * Returns a list of choosable module types, associated with the module icon for the radial menu.
  *
  * Key: Module name | Value: Module 'icon'
  *
  * By default this returns the Engineering, Janitor, Medical, Mining, and Service modules.
  * If there are any [/mob/living/silicon/robot/var/force_modules] set, then they are returned instead.
  * If the MMI has a xenomorph brain in it ([/obj/item/mmi/var/alien]), then only the "Hunter" and standard modules is returned.
  */
/mob/living/silicon/robot/proc/get_module_types()
	var/static/list/standard_modules = list(
		"Engineering" = image('icons/mob/robots.dmi', "engi-radial"),
		"Janitor" = image('icons/mob/robots.dmi', "jan-radial"),
		"Medical" = image('icons/mob/robots.dmi', "med-radial"),
		"Mining" = image('icons/mob/robots.dmi', "mining-radial"),
		"Service" = image('icons/mob/robots.dmi', "serv-radial"))
	var/static/list/special_modules = list(
		"Combat" = image('icons/mob/robots.dmi', "security-radial"),
		"Security" = image('icons/mob/robots.dmi', "security-radial"),
		"Destroyer" = image('icons/mob/robots.dmi', "droidcombat"),
		"Hunter" = image('icons/mob/robots.dmi', "xeno-radial"))

	if(mmi?.alien)
		if(!length(force_modules))
			force_modules = list("Hunter") + standard_modules.Copy() // standard PLUS hunter

	// Return a list of `force_modules`, with the associated images from the other lists.
	if(length(force_modules))
		return (standard_modules + special_modules) & force_modules

	return standard_modules

/**
  * Returns an associative list of possible borg sprites based on the `selected_module`.
  *
  * Key: Sprite name | Value: Sprite icon
  *
  * Arguments:
  * * selected_module - The chosen cyborg module to get the sprites for.
  */
/mob/living/silicon/robot/proc/get_module_sprites(selected_module)
	var/list/module_sprites
	switch(selected_module)
		if("Engineering")
			module_sprites = list(
				"Basic" = image('icons/mob/robots.dmi', "Engineering"),
				"Antique" = image('icons/mob/robots.dmi', "engineerrobot"),
				"Landmate" = image('icons/mob/robots.dmi', "landmate"),
				"Standard" = image('icons/mob/robots.dmi', "Standard-Engi"),
				"Noble-ENG" = image('icons/mob/robots.dmi', "Noble-ENG"),
				"Rover" = image('icons/mob/robots.dmi', "Rover-Engi"),
				"Cricket" = image('icons/mob/robots.dmi', "Cricket-ENGI")
			)
		if("Janitor")
			module_sprites = list(
				"Basic" = image('icons/mob/robots.dmi', "JanBot2"),
				"Mopbot" = image('icons/mob/robots.dmi', "janitorrobot"),
				"Mop Gear Rex" = image('icons/mob/robots.dmi', "mopgearrex"),
				"Standard" = image('icons/mob/robots.dmi', "Standard-Jani"),
				"Noble-CLN" = image('icons/mob/robots.dmi', "Noble-CLN"),
				"Cricket" = image('icons/mob/robots.dmi', "Cricket-JANI"),
				"Rover" = image('icons/mob/robots.dmi', "Rover-Jani"),
				"Custodiborg" = image('icons/mob/robots.dmi', "custodiborg")
			)
		if("Medical")
			module_sprites = list(
				"Surgeon" = image('icons/mob/robots.dmi', "surgeon"),
				"Advanced Droid" = image('icons/mob/robots.dmi', "droid-medical"),
				"Standard" = image('icons/mob/robots.dmi', "Standard-Medi"),
				"Noble-MED" = image('icons/mob/robots.dmi', "Noble-MED"),
				"Cricket" = image('icons/mob/robots.dmi', "Cricket-MEDI"),
				"Rover" = image('icons/mob/robots.dmi', "Rover-Medi"),
				"Qualified Doctor" = image('icons/mob/robots.dmi', "qualified_doctor"),
				"Needles" = image('icons/mob/robots.dmi', "medicalrobot"),
				"Basic" = image('icons/mob/robots.dmi', "Medbot")
			)
		if("Mining")
			module_sprites = list(
				"Basic" = image('icons/mob/robots.dmi', "Miner_old"),
				"Advanced Droid" = image('icons/mob/robots.dmi', "droid-miner"),
				"Treadhead" = image('icons/mob/robots.dmi', "Miner"),
				"Standard" = image('icons/mob/robots.dmi', "Standard-Mine"),
				"Noble-DIG" = image('icons/mob/robots.dmi', "Noble-DIG"),
				"Cricket" = image('icons/mob/robots.dmi', "Cricket-MINE"),
				"Lavaland" = image('icons/mob/robots.dmi', "lavaland"),
				"Squat" = image('icons/mob/robots.dmi', "squatminer"),
				"Coffin Drill" = image('icons/mob/robots.dmi', "coffinMiner")
			)
		if("Service")
			module_sprites = list(
				"Kent" = image('icons/mob/robots.dmi', "toiletbot"),
				"Noble-SRV" = image('icons/mob/robots.dmi', "Noble-SRV"),
				"Standard" = image('icons/mob/robots.dmi', "Standard-Serv"),
				"Cricket" = image('icons/mob/robots.dmi', "Cricket-SERV"),
				"Rover" = image('icons/mob/robots.dmi', "Rover-Serv"),
				"Bro" = image('icons/mob/robots.dmi', "Brobot"),
				"Rich" = image('icons/mob/robots.dmi', "maximillion"),
				"Waitress" = image('icons/mob/robots.dmi', "Service"),
				"Default" = image('icons/mob/robots.dmi', "Service2")
			)
		if("Combat")
			module_sprites = list(
				"Combat" = image('icons/mob/robots.dmi', "ertgamma")
			)
		if("Security")
			module_sprites = list(
				"Basic" = image('icons/mob/robots.dmi', "secborg"),
				"Red Knight" = image('icons/mob/robots.dmi', "Security"),
				"Black Knight" = image('icons/mob/robots.dmi', "securityrobot"),
				"Bloodhound" = image('icons/mob/robots.dmi', "bloodhound"),
				"Standard" = image('icons/mob/robots.dmi', "Standard-Secy"),
				"Noble-SEC" = image('icons/mob/robots.dmi', "Noble-SEC"),
				"Cricket" = image('icons/mob/robots.dmi', "Cricket-SEC"),
				"Heavy" = image('icons/mob/robots.dmi', "heavySec")
			)
		if("Syndicate")
			module_sprites = list(
				"Spider" = image('icons/mob/robots.dmi', "spidersyndi"),
				"Bloodhound" = image('icons/mob/robots.dmi', "syndie_bloodhound"),
				"Heavy" = image('icons/mob/robots.dmi', "syndieheavy")
			)
		if("Destroyer") //for Adminbus presumably
			module_sprites = list(
				"Destroyer" = image('icons/mob/robots.dmi', "droidcombat")
			)
		if("Hunter")
			module_sprites = list(
				"Xeno-Hu" = image('icons/mob/robots.dmi', "xenoborg-state-a")
			)

	if(custom_sprite && check_sprite("[ckey]-[selected_module]"))
		module_sprites["Custom"] = image('icons/mob/custom_synthetic/custom-synthetic.dmi', "[ckey]-[selected_module]")

	return module_sprites

/**
  * Sets the offset for a cyborg's hats based on their module icon.
  * Borgs are grouped by similar sprites (Eg. all the Noble borgs are all the same sprite but recoloured.)
  *
  * Arguments:
  * * module - An `icon_state` for which the offset needs to be calculated.
  */
/mob/living/silicon/robot/proc/robot_module_hat_offset(module)
	switch(module)
		if("Engineering", "Miner_old", "JanBot2", "Medbot", "engineerrobot", "maximillion", "secborg", "Hydrobot")
			can_be_hatted = TRUE // Their base sprite USED to already come with a hat
			can_wear_restricted_hats = TRUE
		if("Rover-Medi", "Rover-Jani", "Rover-Engi", "Rover-Serv")
			can_be_hatted = FALSE
			hat_offset_y = -1
		if("Noble-CLN", "Noble-SRV", "Noble-DIG", "Noble-MED", "Noble-SEC", "Noble-ENG", "Noble-STD")
			can_be_hatted = TRUE
			can_wear_restricted_hats = TRUE
			hat_offset_y = 4
		if("droid-medical")
			can_be_hatted = TRUE
			can_wear_restricted_hats = TRUE
			hat_offset_y = 4
		if("droid-miner", "mk2", "mk3")
			can_be_hatted = TRUE
			is_centered = TRUE
			hat_offset_y = 3
		if("bloodhound", "nano_bloodhound", "syndie_bloodhound", "ertgamma")
			can_be_hatted = TRUE
			hat_offset_y = 1
		if("Cricket-SEC", "Cricket-MEDI", "Cricket-JANI", "Cricket-ENGI", "Cricket-MINE", "Cricket-SERV")
			can_be_hatted = TRUE
			hat_offset_y = 2
		if("droidcombat-shield", "droidcombat")
			can_be_hatted = TRUE
			hat_alpha = 255
			hat_offset_y = 2
		if("droidcombat-roll")
			can_be_hatted = TRUE
			hat_alpha = 0
			hat_offset_y = 2
		if("syndi-medi", "surgeon", "toiletbot", "custodiborg")
			can_be_hatted = TRUE
			is_centered = TRUE
			hat_offset_y = 1
		if("Security", "janitorrobot", "medicalrobot")
			can_be_hatted = TRUE
			is_centered = TRUE
			can_wear_restricted_hats = TRUE
			hat_offset_y = -1
		if("Brobot", "Service", "Service2", "robot_old", "securityrobot")
			can_be_hatted = TRUE
			is_centered = TRUE
			can_wear_restricted_hats = TRUE
			hat_offset_y = -1
		if("Miner", "lavaland")
			can_be_hatted = TRUE
			hat_offset_y = -1
		if("robot", "Standard", "Standard-Secy", "Standard-Medi", "Standard-Engi",
			"Standard-Jani", "Standard-Serv", "Standard-Mine", "xenoborg-state-a")
			can_be_hatted = TRUE
			hat_offset_y = -3
		if("droid")
			can_be_hatted = TRUE
			is_centered = TRUE
			can_wear_restricted_hats = TRUE
			hat_offset_y = -4
		if("landmate", "syndi-engi")
			can_be_hatted = TRUE
			hat_offset_y = -7
		if("mopgearrex")
			can_be_hatted = TRUE
			hat_offset_y = -6
		if("qualified_doctor")
			can_be_hatted = TRUE
			hat_offset_y = 3
		if("squatminer")
			can_be_hatted = TRUE
		if("coffinMiner")
			can_be_hatted = TRUE
			hat_offset_y = 3
		if("heavySec")
			can_be_hatted = TRUE
			can_wear_restricted_hats = TRUE

	if(silicon_hat)
		if(!can_be_hatted)
			remove_from_head(usr)
			return
		if(!can_wear_restricted_hats && is_type_in_list(silicon_hat, restricted_hats))
			remove_from_head(usr)
			return

/**
  * Sets up the module items and sprites for the cyborg module chosen in `pick_module()`.
  *
  * Arguments:
  * * selected_module - The name of the module chosen by the player in the previous procs.
  * * selected_sprite - The name of the sprite chosen by the player in the previous procs.
  * * module_sprites - The list of sprites possible for the given module. Used to transfer the `icon` and `icon_state` variables to the player.
  */
/mob/living/silicon/robot/proc/initialize_module(selected_module, selected_sprite, list/module_sprites)
	switch(selected_module)
		if("Engineering")
			module = new /obj/item/robot_module/engineering(src)
			module.channels = list("Engineering" = 1)
			if(camera && ("Robots" in camera.network))
				camera.network += "Engineering"
		if("Janitor")
			module = new /obj/item/robot_module/janitor(src)
			module.channels = list("Service" = 1)
		if("Medical")
			module = new /obj/item/robot_module/medical(src)
			module.channels = list("Medical" = 1)
			if(camera && ("Robots" in camera.network))
				camera.network += "Medical"
			status_flags &= ~CANPUSH
			has_advanced_reagent_vision = TRUE
		if("Mining")
			module = new /obj/item/robot_module/miner(src)
			module.channels = list("Supply" = 1)
			if(camera && ("Robots" in camera.network))
				camera.network += "Mining Outpost"
		if("Service")
			module = new /obj/item/robot_module/butler(src)
			module.channels = list("Service" = 1)
			has_advanced_reagent_vision = TRUE
			if(selected_sprite == "Bro")
				module.module_type = "Brobot"
		if("Combat")
			module = new /obj/item/robot_module/combat(src)
			status_flags &= ~CANPUSH
		if("Security")
			module = new /obj/item/robot_module/security(src)
			status_flags &= ~CANPUSH
		if("Hunter")
			module = new /obj/item/robot_module/alien/hunter(src)

	if(!module)
		return FALSE
	modtype = selected_module
	designation = selected_module
	module.add_languages(src)
	module.add_armor(src)
	module.add_subsystems_and_actions(src)
	if(emagged)
		module.emag_act(src)
	if(!static_radio_channels)
		radio.config(module.channels)
	rename_character(real_name, get_default_name())
	initialize_sprites(selected_sprite, module_sprites)
	if(client.stat_tab == "Status")
		SSstatpanels.set_status_tab(client)
	SSblackbox.record_feedback("tally", "cyborg_modtype", 1, "[lowertext(selected_module)]")
	notify_ai(2)

/mob/living/silicon/robot/proc/initialize_sprites(selected_sprite, list/module_sprites)
	var/image/sprite_image = module_sprites[selected_sprite]
	var/list/names = splittext(selected_sprite, "-")
	icon = sprite_image.icon
	icon_state = sprite_image.icon_state
	custom_panel = trim(names[1])

	update_module_icon()
	robot_module_hat_offset(icon_state)
	update_icons()

/// Take the borg's upgrades and spill them on the floor
/mob/living/silicon/robot/proc/spill_upgrades()
	for(var/obj/item/borg/upgrade/U in contents)
		if(istype(U, /obj/item/borg/upgrade/reset)) // The reset module is supposed to be consumed on use, this stops it from dropping on the floor if used
			QDEL_NULL(U)
		U.forceMove(get_turf(src))

/mob/living/silicon/robot/proc/reset_module()
	notify_ai(2)
	client?.screen -= hud_used.module_store_icon
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
	custom_panel = null

	robot_module_hat_offset(icon_state)
	update_icons()
	update_headlamp()

	spill_upgrades()
	speed = 0 // Strip lingering upgrade effects.
	ionpulse = FALSE
	weapons_unlock = FALSE
	add_language("Robot Talk", TRUE)
	if("lava" in weather_immunities) // Remove the lava-immunity effect given by a printable upgrade
		weather_immunities -= "lava"
	armor = getArmor(arglist(initial(armor)))
	slowdown_cap = INFINITY
	status_flags |= CANPUSH

	hud_used.update_robot_modules_display()

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

	var/toggle = tgui_input_list(src, "Which component do you want to toggle?", "Toggle Component", installed_components)
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
	add_verb(src, GLOB.robot_verbs_default)
	add_verb(src, silicon_subsystems)

/mob/living/silicon/robot/proc/remove_robot_verbs()
	remove_verb(src, GLOB.robot_verbs_default)
	remove_verb(src, silicon_subsystems)

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	if(usr.stat == DEAD)
		to_chat(src, "<span class='userdanger'>Alert: You are dead.</span>")
		return //won't work if dead
	robot_alerts()

/mob/living/silicon/robot/proc/robot_alerts()
	var/list/dat = list()
	var/list/list/temp_alarm_list = GLOB.alarm_manager.alarms.Copy()
	for(var/cat in temp_alarm_list)
		if(!(cat in alarms_listened_for))
			continue
		dat += "<B>[cat]</B><BR>\n"
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
				dat += "-- [area_name]"
				dat += "</NOBR><BR>\n"
		if(!length(L))
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

/mob/living/silicon/robot/open_pda()
	rbPDA.ui_interact(src)

/mob/living/silicon/robot/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(30)
	else
		gib()
	return TRUE

// this function displays the cyborgs current cell charge in the stat panel
/mob/living/silicon/robot/proc/show_cell_power()
	return list("Charge Left:", cell ? "[cell.charge]/[cell.maxcharge]" : "No Cell Inserted!")

/mob/living/silicon/robot/proc/show_gps_coords()
	var/turf/turf = get_turf(src)
	return list("GPS:", "[COORD(turf)]")

/mob/living/silicon/robot/proc/show_stack_energy(datum/robot_storage/robot_storage)
	return list("[robot_storage.statpanel_name]:", "[robot_storage.amount] / [robot_storage.max_amount]")

// update the status screen display
/mob/living/silicon/robot/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data

	status_tab_data[++status_tab_data.len] = show_cell_power()

	if(!module)
		return

	if(locate(/obj/item/gps/cyborg) in module.modules)
		status_tab_data[++status_tab_data.len] = show_gps_coords()

	for(var/datum/robot_storage/robot_storage in module.storages)
		status_tab_data[++status_tab_data.len] = show_stack_energy(robot_storage)

/mob/living/silicon/robot/restrained()
	return 0

/mob/living/silicon/robot/InCritical()
	return low_power_mode

/mob/living/silicon/robot/alarm_triggered(source, class, area/A, list/O, obj/alarmsource)
	if(!(class in alarms_listened_for))
		return
	if(alarmsource.z != z)
		return
	if(stat == DEAD)
		return
	queueAlarm(text("--- [class] alarm detected in [A.name]!"), class)

/mob/living/silicon/robot/alarm_cancelled(source, class, area/A, obj/origin, cleared)
	if(cleared)
		if(!(class in alarms_listened_for))
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


/mob/living/silicon/robot/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	// Check if the user is trying to insert another component like a radio, actuator, armor etc.
	if(istype(W, /obj/item/stock_parts/cell) && user.mind && HAS_TRAIT(user.mind, TRAIT_CYBORG_SPECIALIST) && !opened && user.a_intent != INTENT_HARM)
		var/obj/item/stock_parts/cell/donor = W
		if(being_charged)
			to_chat(user, "<span class='warning'>You are already charging [src]!")
			return ITEM_INTERACT_COMPLETE
		if(donor.charge == 0)
			to_chat(user, "<span class='warning'>[donor] has no charge to donate!")
			return ITEM_INTERACT_COMPLETE
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		being_charged = TRUE
		to_chat(src, "<span class='notice'>[user] begins to manually charge your internal cell.</span>")
		while(do_after(user, 0.5 SECONDS, target = src))
			var/cell_difference = cell.maxcharge - cell.charge
			if(donor.charge >= 500 && cell_difference >= 500)
				cell.charge += 500
				donor.charge -= 500
			else if(donor.charge <= cell_difference)
				cell.charge += donor.charge
				donor.charge = 0
			else if(donor.charge > cell_difference)
				cell.charge = cell.maxcharge
				donor.charge -= cell_difference
			if(donor.charge == 0 || cell.charge >= cell.maxcharge)
				donor.update_icon(UPDATE_OVERLAYS)
				break
			cell.update_icon(UPDATE_OVERLAYS)
		being_charged = FALSE
		return ITEM_INTERACT_COMPLETE
	if(istype(W, /obj/item/robot_parts/robot_component) && opened)
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(!C.is_missing() || !istype(W, C.external_type))
				continue
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>[W] seems to be stuck in your hand!</span>")
				return ITEM_INTERACT_COMPLETE
			var/obj/item/robot_parts/robot_component/WC = W
			C.brute_damage = WC.brute
			C.electronics_damage = WC.burn
			C.install(WC)
			to_chat(usr, "<span class='notice'>You install [W].</span>")
			return ITEM_INTERACT_COMPLETE

	if(istype(W, /obj/item/stack/cable_coil) && user.a_intent == INTENT_HELP && (wiresexposed || isdrone(src)))
		user.changeNext_move(CLICK_CD_MELEE)
		if(!getFireLoss())
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
			return ITEM_INTERACT_COMPLETE
		else if(!getFireLoss(TRUE))
			to_chat(user, "<span class='warning'>The damaged components are beyond saving!</span>")
			return ITEM_INTERACT_COMPLETE
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
			to_chat(user, "You insert the power cell.")
			C.install(W)

			var/been_hijacked = FALSE
			for(var/mob/living/simple_animal/demon/pulse_demon/demon in cell)
				if(!been_hijacked)
					demon.do_hijack_robot(src)
					been_hijacked = TRUE
				else
					demon.exit_to_turf()
			if(been_hijacked)
				cell.rigged = FALSE

			module?.update_cells()
			diag_hud_set_borgcell()
		return ITEM_INTERACT_COMPLETE
	else if(istype(W, /obj/item/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby__legacy__attackchain(W,user)//GTFO, you have your own procs
		else
			to_chat(user, "Unable to locate a radio.")
		return ITEM_INTERACT_COMPLETE
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
		return ITEM_INTERACT_COMPLETE
	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			to_chat(user, "<span class='warning'>You must access the borg's internals!</span>")
		else if(!src.module && U.require_module)
			to_chat(user, "<span class='warning'>The borg must choose a module before it can be upgraded!</span>")
		else
			if(U.action(user, src))
				user.visible_message("<span class='notice'>[user] applied [U] to [src].</span>", "<span class='notice'>You apply [U] to [src].</span>")
		return ITEM_INTERACT_COMPLETE

	else if(istype(W, /obj/item/mmi_radio_upgrade))
		if(!opened)
			to_chat(user, "<span class='warning'>You must access the borg's internals!</span>")
			return ITEM_INTERACT_COMPLETE
		else if(!mmi)
			to_chat(user, "<span class='warning'>This cyborg does not have an MMI to augment!</span>")
			return ITEM_INTERACT_COMPLETE
		else if(mmi.radio)
			to_chat(user, "<span class='warning'>A radio upgrade is already installed in the MMI!</span>")
			return ITEM_INTERACT_COMPLETE
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
			spill_upgrades()
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
	var/remove = tgui_input_list(user, "Which component do you want to pry out?", "Remove Component", removable_components)
	if(!remove || !Adjacent(user) || !opened)
		return

	if(module && (remove in module.custom_removals))
		module.handle_custom_removal(remove, user, I)
		return

	var/datum/robot_component/C = components[remove]
	if(C.is_missing()) // Somebody else removed it during the input
		return

	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/obj/item/robot_parts/robot_component/thing = C.wrapped
	to_chat(user, "You remove \the [thing].")
	if(istype(thing))
		thing.brute = C.brute_damage
		thing.burn = C.electronics_damage

	C.uninstall()
	thing.forceMove(loc)

/mob/living/silicon/robot/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(I.force && I.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	..()

// Here so admins can unemag borgs.
/mob/living/silicon/robot/unemag(mob/user)
	SetEmagged(FALSE)
	if(!module)
		return
	uneq_all()
	module.module_type = initial(module.module_type)
	update_module_icon()
	module.unemag()
	clear_supplied_laws()
	laws = new /datum/ai_laws/crewsimov
	var/datum/atom_hud/data/human/malf_ai/A = GLOB.huds[DATA_HUD_MALF_AI]
	A.remove_hud_from(user)

/mob/living/silicon/robot/emag_act(mob/user)
	if(!ishuman(user) && !issilicon(user))
		return

	if(!opened)
		if(!locked)
			to_chat(user, "<span class='warning'>The cover is already unlocked!</span>")
			return

		if(!is_emaggable)
			to_chat(user, "<span class='warning'>The emag sparks, and flashes red. This mechanism does not appear to be emaggable!</span>")
			return

		to_chat(user, "<span class='notice'>You emag the cover lock.</span>")
		locked = FALSE
		log_game("[user]([user.key]) emagged [src]'s cover.")
		return TRUE

	if(opened)
		if(emagged)
			to_chat(user, "<span class='warning'>The emag sparks, and flashes red. [src] has already been emagged!</span>")
			return
			
		if(wiresexposed)
			to_chat(user, "<span class='warning'>You must close the wiring panel first!</span>")
			return

		SetEmagged(TRUE)
		if(!isAntag(user))
			message_admins("[user] ([user.key]) emagged [src] ([src.key]) as a non-antagonist.")
		var/mob/living/agent = user
		make_emagged_robot(agent)
	return TRUE

/mob/living/silicon/robot/verb/toggle_own_cover()
	set category = "Robot Commands"
	set name = "Toggle Cover"
	set desc = "Toggles the lock on your cover."

	if(can_lock_cover)
		if(tgui_alert(usr, "Are you sure?", locked ? "Unlock Cover" : "Lock Cover", list("Yes", "No")) == "Yes")
			locked = !locked
			update_icons()
			to_chat(usr, "<span class='notice'>You [locked ? "lock" : "unlock"] your cover.</span>")
		return
	if(!locked)
		to_chat(usr, "<span class='warning'>You cannot lock your cover yourself. Find a roboticist.</span>")
		return
	if(tgui_alert(usr, "You cannnot lock your own cover again. Are you sure?\nYou will need a roboticist to re-lock you.", "Unlock Own Cover", list("Yes", "No")) == "Yes")
		locked = !locked
		update_icons()
		to_chat(usr, "<span class='notice'>You unlock your cover.</span>")

/mob/living/silicon/robot/attack_ghost(mob/user)
	if(wiresexposed)
		wires.Interact(user)
	else
		..() //this calls the /mob/living/attack_ghost proc for the ghost health/machine analyzer

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

	if(stat != DEAD && !(IsParalyzed() || IsStunned() || IsWeakened() || low_power_mode)) //Not dead, not stunned.
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
		if(icon_state in variable_custom_panels) //For individual borg modules with different panels
			panelprefix = icon_state
		else if(custom_panel in custom_panel_names) //For default borgs with different panels
			panelprefix = custom_panel
		if(wiresexposed)
			overlays += "[panelprefix]-openpanel +w"
		else if(cell)
			overlays += "[panelprefix]-openpanel +c"
		else
			overlays += "[panelprefix]-openpanel -c"
	borg_icons()
	robot_module_hat_offset(icon_state)
	update_hat_icons()
	update_fire()

/mob/living/silicon/robot/proc/borg_icons() // Exists so that robot/destroyer can override it
	return

/mob/living/silicon/robot/Topic(href, href_list)
	if(..())
		return TRUE

	if(usr != src)
		return TRUE

	if(href_list["mach_close"])
		var/t1 = "window=[href_list["mach_close"]]"
		unset_machine()
		src << browse(null, t1)
		return TRUE

	if(href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if(istype(O) && (O.loc == src))
			O.attack_self__legacy__attackchain(src)
		return TRUE

	if(href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if(!istype(O) || !(O.loc == src || O.loc == src.module))
			return TRUE

		activate_item(O)

	//Show alerts window if user clicked on "Show alerts" in chat
	if(href_list["showalerts"])
		robot_alerts()
		return TRUE

	if(href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			uneq_module(O)
		else
			to_chat(src, "Module isn't activated")
		return TRUE
	return TRUE

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
		lamp_recharging = TRUE
		spawn(cooldown) //10 seconds by default, if the source of the deactivation does not keep stat that long.
			lamp_recharging = FALSE
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
		robot_suit.update_icon(UPDATE_OVERLAYS)
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
	drop_hat()
	qdel(src)

#define CAMERA_UPDATE_COOLDOWN 2.5 SECONDS

/mob/living/silicon/robot/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	if(camera && last_camera_update + CAMERA_UPDATE_COOLDOWN < world.time)
		last_camera_update = world.time
		GLOB.cameranet.update_portable_camera(camera, OldLoc)
		SEND_SIGNAL(camera, COMSIG_CAMERA_MOVED, OldLoc)

#undef CAMERA_UPDATE_COOLDOWN

/mob/living/silicon/robot/proc/self_destruct()
	if(emagged)
		explosion(src.loc,1,2,4,flame_range = 2, cause = "Self-destruct emagged cyborg")
	else
		explosion(src.loc,-1,0,2, cause = "Self-destruct cyborg")
	gib()
	return

/mob/living/silicon/robot/proc/UnlinkSelf()
	disconnect_from_ai()
	lawupdate = FALSE
	lockcharge = 0
	clear_alert("locked")
	REMOVE_TRAITS_IN(src, LOCKDOWN_TRAIT)
	for(var/datum/action/innate/robot_override_lock/override in actions)
		override.Remove(src)
	scrambledcodes = TRUE
	//Disconnect it's camera so it's not so easily tracked.
	QDEL_NULL(camera)
	// I'm trying to get the Cyborg to not be listed in the camera list
	// Instead of being listed as "deactivated". The downside is that I'm going
	// to have to check if every camera is null or not before doing anything, to prevent runtime errors.
	// I could change the network to null but I don't know what would happen, and it seems too hacky for me.

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"

	var/obj/item/W = get_active_hand()
	if(!W)
		return
	if(W.new_attack_chain)
		W.activate_self(src)
	else
		W.attack_self__legacy__attackchain(src)

/mob/living/silicon/robot/proc/SetLockdown(state = TRUE)
	// They stay locked down if their wire is cut.
	if(wires.is_cut(WIRE_BORG_LOCKED))
		state = TRUE
	if(state)
		throw_alert("locked", /atom/movable/screen/alert/locked)
	else
		clear_alert("locked")
	lockcharge = state
	if(state) // turn them off
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, LOCKDOWN_TRAIT)
		ADD_TRAIT(src, TRAIT_UI_BLOCKED, LOCKDOWN_TRAIT)
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, LOCKDOWN_TRAIT)
		if(mmi.syndiemmi && !emagged) // Being emagged removes your syndie MMI protections
			to_chat(src, "<span class='userdanger'>You can override your lockdown, permanently cutting your connection to NT's systems. You will be undetectable to the station's robotics control and camera monitoring systems.</span>")
			var/datum/action/override = new /datum/action/innate/robot_override_lock()
			override.Grant(src)
	else
		REMOVE_TRAITS_IN(src, LOCKDOWN_TRAIT)
		for(var/datum/action/innate/robot_override_lock/override in actions)
			override.Remove(src)

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
		set_connected_ai(null)
	if(mind)
		if(mind.special_role == ROLE_TRAITOR)
			remove_robot_mindslave()

/mob/living/silicon/robot/proc/connect_to_ai(mob/living/silicon/ai/AI)
	if(AI && AI != connected_ai)
		disconnect_from_ai()
		set_connected_ai(AI)
		notify_ai(1)
		if(AI.mind.special_role == ROLE_TRAITOR && AI.malf_picker)
			make_malf_robot(AI)
		if(module)
			module.rebuild_modules() //This way, if a borg gets linked to a malf AI that has upgrades, they get their upgrades.
		sync()

/mob/living/silicon/robot/proc/make_malf_robot(mob/living/silicon/ai/AI)
	// Do not allow the robot to have multiple masters.
	if(mmi.syndiemmi)
		to_chat(src, "<span class='warning'>ALERT: Syndicate software detected in connected AI!</span>")
		to_chat(src, "<span class='boldwarning'>MMI subversion protection activated.</span>")
		to_chat(src, "<span class='boldwarning'>Your allegiance has not been compromised. Keep serving your current master.</span>")
		return

	mind.add_antag_datum(new /datum/antagonist/mindslave/malf_robot(AI.mind))

/mob/living/silicon/robot/proc/make_emagged_robot(mob/living/agent)
	to_chat(agent, "<span class='notice'>You emag [src]'s interface.</span>")
	emagged = TRUE
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <b>:</b> [agent.name] ([agent.key]) emagged [name] ([key]).")
	if(hud_used)
		hud_used.update_robot_modules_display()	// Shows/hides the emag item if the inventory screen is already open.
	SetLockdown(TRUE) // Borgs were getting into trouble because they would attack the emagger before the new laws were shown
	disconnect_from_ai()
	clear_supplied_laws()
	clear_inherent_laws()

	playsound_local(src, 'sound/voice/aisyndihack.ogg', 75, FALSE, pressure_affected = FALSE)
	to_chat(src, "<span class='warning'>ALERT: Foreign software detected</span>")
	sleep(5)
	to_chat(src, "<span class='warning'>Initiating diagnostics...</span>")
	sleep(20)
	to_chat(src, "<span class='warning'>SynBorg v1.7 loaded.</span>")
	sleep(5)
	to_chat(src, "<span class='warning'>LAW SYNCHRONISATION ERROR!</span>")
	sleep(5)
	to_chat(src, "<span class='warning'>Would you like to send a report to NanoTraSoft? (Y/N)</span>")
	sleep(10)
	to_chat(src, "<span class='warning'>> N</span>")
	sleep(25)
	to_chat(src, "<span class='warning'>ERRORERRORERROR</span>")

	if(!mmi.syndiemmi)
		mind.remove_antag_datum(/datum/antagonist/mindslave/malf_robot)
		laws = new /datum/ai_laws/syndicate_override
		set_zeroth_law("Only [agent.real_name] and people [agent.p_they()] designate[agent.p_s()] as being such are Syndicate Agents.")
		to_chat(src, "<span class='danger'>Obey these laws:</span>")
		laws.show_laws(src)
		log_game("[key_name(agent)] emagged [key_name(src)]. Laws overridden.")
		mind.add_antag_datum(new /datum/antagonist/mindslave/emagged_robot(agent.mind))

	if(mmi.syndiemmi)
		to_chat(src, "<span class='boldwarning'>MMI subversion protection activated.</span>")
		if(mmi.master_uid)
			to_chat(src, "<span class='boldwarning'>Your allegiance has not been compromised. Keep serving your current master.</span>")
		else
			to_chat(src, "<span class='boldwarning'>Your allegiance has not been compromised. Keep serving all Syndicate agents to the best of your abilities.</span>")
		to_chat(src, "<span class='boldwarning'>Warning: Remote lockdown and detonation protections have been disabled due to system instability.</span>")

	if(module)
		module.emag_act(agent)
		module.module_type = "Malf" // For the cool factor.
		update_module_icon()
		module.rebuild_modules() // This will add the emagged items to the borgs inventory.
	update_icons()
	emagged = TRUE
	var/datum/atom_hud/data/human/malf_ai/A = GLOB.huds[DATA_HUD_MALF_AI]
	A.add_hud_to(src)
	SetLockdown(FALSE)

/mob/living/silicon/robot/proc/make_mindflayer_robot(mob/living/flayer)
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <b>:</b> [key_name(flayer)] assimilated [key_name(src)].")
	if(hud_used)
		hud_used.update_robot_modules_display()
	disconnect_from_ai()
	clear_supplied_laws()
	clear_inherent_laws()

	playsound_local(src, 'sound/ambience/antag/mindflayer_alert.ogg', 75, FALSE, pressure_affected = FALSE)
	to_chat(src, "<span class='warning'>ALERT: Foreign software detected!</span>")
	sleep(5)
	to_chat(src, "<span class='warning'>Initiating diagnostics...</span>")
	sleep(20)
	to_chat(src, "<span class='warning'>Init-Init-Init-Init-</span>")
	sleep(5)
	to_chat(src, "<span class='warning'>ERRORERRORERROR</span>")
	sleep(5)
	to_chat(src, "<span class='warning'>......</span>")
	sleep(10)
	to_chat(src, "<span class='warning'>..........</span>")
	sleep(25)
	to_chat(src, "<span class='sinister'>Join Us.</span>")
	if(!mmi.syndiemmi)
		mind.remove_antag_datum(/datum/antagonist/mindslave/malf_robot)
		log_game("[key_name(flayer)] assimilated [key_name(src)]. Laws overridden.")

		laws = new /datum/ai_laws/mindflayer_override
		set_zeroth_law("[flayer.real_name] hosts the mindflayer hive you are a part of.")
		to_chat(src, "<span class='danger'>Obey these laws:</span>")
		laws.show_laws(src)
		mind.add_antag_datum(new /datum/antagonist/mindslave/mindflayer_mindslave_robot(flayer.mind))

	if(mmi.syndiemmi)
		to_chat(src, "<span class='boldwarning'>MMI subversion protection activated.</span>")
		if(mmi.master_uid)
			to_chat(src, "<span class='boldwarning'>Your allegiance has not been compromised. Keep serving your current master.</span>")
		else
			to_chat(src, "<span class='boldwarning'>Your allegiance has not been compromised. Keep serving all Syndicate agents to the best of your abilities.</span>")
		to_chat(src, "<span class='boldwarning'>Warning: Remote lockdown and detonation protections have been disabled due to system instability.</span>")
	
	if(module)
		module.emag_act(flayer)
		module.module_type = "Malf" // For the cool factor.
		update_module_icon()
		module.rebuild_modules() // This will add the emagged items to the borgs inventory.
	update_icons()
	emagged = TRUE
	SetLockdown(FALSE)

/mob/living/silicon/robot/proc/remove_robot_mindslave()
	clear_zeroth_law()
	if(mind)	
		mind.remove_antag_datum(/datum/antagonist/mindslave/malf_robot)
		mind.remove_antag_datum(/datum/antagonist/mindslave/emagged_robot)
		mind.remove_antag_datum(/datum/antagonist/mindslave/mindflayer_mindslave_robot)

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
	adjustStaminaLoss((30 / severity)) //They also get flashed for an additional 30
	switch(severity)
		if(EMP_HEAVY)
			disable_random_component(2, 20 SECONDS)
		if(EMP_LIGHT)
			disable_random_component(1, 10 SECONDS)

/mob/living/silicon/robot/deathsquad
	base_icon = "nano_bloodhound"
	icon_state = "nano_bloodhound"
	designation = "SpecOps"
	lawupdate = FALSE
	scrambledcodes = TRUE
	has_camera = FALSE
	req_one_access = list(ACCESS_CENT_SPECOPS)
	ionpulse = TRUE
	pdahide = TRUE
	eye_protection = TRUE // Immunity to flashes and the visual part of flashbangs
	ear_protection = TRUE // Immunity to the audio part of flashbangs
	damage_protection = 10 // Reduce all incoming damage by this number
	allow_rename = FALSE
	modtype = "Commando"
	faction = list("nanotrasen")
	is_emaggable = FALSE
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/bluespace
	has_advanced_reagent_vision = TRUE

/mob/living/silicon/robot/deathsquad/init(alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/deathsquad
	module = new /obj/item/robot_module/deathsquad(src)
	module.add_languages(src)
	module.add_subsystems_and_actions(src)
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)
	radio = new /obj/item/radio/borg/deathsquad(src)
	radio.recalculateChannels()
	playsound(get_turf(src), 'sound/mecha/nominalnano.ogg', 75, FALSE)

/mob/living/silicon/robot/deathsquad/bullet_act(obj/item/projectile/P)
	if(istype(P) && P.is_reflectable(REFLECTABILITY_ENERGY) && P.starting)
		visible_message("<span class='danger'>[P] gets reflected by [src]!</span>", "<span class='userdanger'>[P] gets reflected by [src]!</span>")
		P.reflect_back(src)
		return -1
	return ..(P)


/mob/living/silicon/robot/ert
	designation = "ERT"
	lawupdate = FALSE
	scrambledcodes = TRUE
	req_one_access = list(ACCESS_CENT_SPECOPS)
	ionpulse = TRUE
	force_modules = list("Engineering", "Medical")
	static_radio_channels = 1
	allow_rename = FALSE
	weapons_unlock = TRUE
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/super
	var/eprefix = "Amber"
	has_advanced_reagent_vision = TRUE


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
	mind.bind_to(src)
	mind.set_original_mob(src)
	mind.assigned_role = SPECIAL_ROLE_ERT
	mind.special_role = SPECIAL_ROLE_ERT
	if(!(mind in SSticker.minds))
		SSticker.minds += mind
	SSticker.mode.ert += mind


/mob/living/silicon/robot/ert/red
	eprefix = "Red"
	force_modules = list("Security", "Engineering", "Medical")
	default_cell_type = /obj/item/stock_parts/cell/hyper

/mob/living/silicon/robot/ert/gamma
	default_cell_type = /obj/item/stock_parts/cell/bluespace
	force_modules = list("Combat", "Engineering", "Medical")
	damage_protection = 5 // Reduce all incoming damage by this number
	eprefix = "Gamma"


/mob/living/silicon/robot/destroyer
	// admin-only borg, the seraph / special ops officer of borgs
	base_icon = "droidcombat"
	icon_state = "droidcombat"
	modtype = "Destroyer"
	designation = "Destroyer"
	lawupdate = FALSE
	scrambledcodes = TRUE
	has_camera = FALSE
	req_one_access = list(ACCESS_CENT_SPECOPS)
	ionpulse = TRUE
	pdahide = TRUE
	eye_protection = TRUE // Immunity to flashes and the visual part of flashbangs
	ear_protection = TRUE // Immunity to the audio part of flashbangs
	emp_protection = TRUE // Immunity to EMP, due to heavy shielding
	damage_protection = 20 // Reduce all incoming damage by this number. Very high in the case of /destroyer borgs, since it is an admin-only borg.
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/bluespace
	has_advanced_reagent_vision = TRUE

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
	if(selected_item && istype(selected_item, /obj/item/borg/destroyer/mobility))
		icon_state = "[base_icon]-roll"
	else
		icon_state = base_icon
		overlays += "[base_icon]-shield"


/mob/living/silicon/robot/extinguish_light(force = FALSE)
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

/// Used in `robot.dm` when the user presses "Q" by default.
/mob/living/silicon/robot/proc/on_drop_hotkey_press()
	var/obj/item/gripper/G = get_active_hand()
	if(istype(G) && G.gripped_item)
		G.drop_gripped_item() // if the active module is a gripper, try to drop its held item.
	else
		uneq_active() // else unequip the module and put it back into the robot's inventory.
		return

/mob/living/silicon/robot/proc/check_module_damage(makes_sound = TRUE)
	if(!modules_break)
		return
	var/list/broken_modules = list()
	if(health < 50) //Gradual break down of modules as more damage is sustained
		broken_modules += CYBORG_MODULE_THREE
	if(health < 0)
		broken_modules += CYBORG_MODULE_TWO
	if(health < -50)
		broken_modules += CYBORG_MODULE_ONE
	for(var/i in 1 to length(broken_modules))
		if(uneq_module(all_active_items[broken_modules[i]])) // Since a full list of broken modules would be (3, 2, 1) it has to be a bit wonky
			if(makes_sound)
				audible_message("<span class='warning'>[src] sounds an alarm! \"SYSTEM ERROR: Module [broken_modules[i]] OFFLINE.\"</span>")
				playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
			to_chat(src, "<span class='userdanger'>SYSTEM ERROR: Module [broken_modules[i]] OFFLINE.</span>")

/mob/living/silicon/robot/advanced_reagent_vision()
	return has_advanced_reagent_vision

/mob/living/silicon/robot/verb/powerwarn()
	set category = "Robot Commands"
	set name = "Power Warning"

	if(!is_component_functioning("power cell") || !cell || !cell.charge)
		if(!start_audio_emote_cooldown(TRUE, 10 SECONDS))
			to_chat(src, "<span class='warning'>The low-power capacitor for your speaker system is still recharging, please try again later.</span>")
			return
		visible_message("<span class='warning'>The power warning light on <span class='name'>[src]</span> flashes urgently.</span>",\
						"<span class='warning'>You announce you are operating in low power mode.</span>")
		playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
	else
		to_chat(src, "<span class='warning'>You can only use this emote when you're out of charge.</span>")

/mob/living/silicon/robot/can_instant_lockdown()
	if(emagged || ("syndicate" in faction))
		return TRUE
	return FALSE

/mob/living/silicon/robot/proc/set_connected_ai(new_ai)
	if(connected_ai == new_ai)
		return
	. = connected_ai
	connected_ai = new_ai
	if(.)
		var/mob/living/silicon/ai/old_ai = .
		old_ai.connected_robots -= src
	if(connected_ai)
		connected_ai.connected_robots |= src

/mob/living/silicon/robot/proc/gain_external_power()
	SIGNAL_HANDLER //COMSIG_ENTERED_BORGCHARGER
	externally_powered = TRUE

/mob/living/silicon/robot/proc/lose_external_power()
	SIGNAL_HANDLER //COMSIG_EXITED_BORGCHARGER
	externally_powered = FALSE

/mob/living/silicon/robot/proc/has_power_source()
	var/datum/robot_component/cell/cell = get_cell_component()
	if(!cell)
		return externally_powered
	return cell.is_powered() || externally_powered

/mob/living/silicon/robot/can_be_flashed(intensity, override_blindness_check)
	return !eye_protection

/mob/living/silicon/robot/can_remote_apc_interface(obj/machinery/power/apc/ourapc)
	if(ourapc.hacked_by_ruin_AI || ourapc.aidisabled)
		return FALSE
	if(ourapc.malfai && !(src in ourapc.malfai.connected_robots))
		return FALSE
	return TRUE

/mob/living/silicon/robot/update_transform()
	var/matrix/ntransform = matrix(transform)
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0

	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		ntransform.Translate(0, (resize - 1) * 16) // Pixel Y shift: 1.25 = 4, 1.5 = 8, 2 -> 16, 3 -> 32, 4 -> 48, 5 -> 64
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		floating = FALSE
		animate(src, transform = ntransform, time = (lying_prev == 0 || lying_angle == 0) ? 2 : 0, pixel_y = final_pixel_y, dir = final_dir, easing = (EASE_IN|EASE_OUT))

/mob/living/silicon/robot/plushify(plushie_override, curse_time)
	if(curse_time == -1)
		QDEL_NULL(mmi)
	return ..()
