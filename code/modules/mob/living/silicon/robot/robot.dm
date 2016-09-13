var/list/robot_verbs_default = list(
	/mob/living/silicon/robot/proc/sensor_mode,
)

/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 100
	health = 100
	universal_understand = 1

	var/sight_mode = 0
	var/custom_name = ""
	var/custom_sprite = 0 //Due to all the sprites involved, a var for our custom borgs may be best

//Hud stuff

	var/obj/screen/inv1 = null
	var/obj/screen/inv2 = null
	var/obj/screen/inv3 = null
	var/obj/screen/lamp_button = null
	var/obj/screen/thruster_button = null

	var/shown_robot_modules = 0	//Used to determine whether they have the module menu shown or not
	var/obj/screen/robot_modules_background

//3 Modules can be activated at any one time.
	var/obj/item/weapon/robot_module/module = null
	var/module_active = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/stock_parts/cell/cell = null
	var/obj/machinery/camera/camera = null

	// Components are basically robot organs.
	var/list/components = list()

	var/obj/item/device/mmi/mmi = null

	var/obj/item/device/pda/silicon/robot/rbPDA = null

	var/datum/wires/robot/wires = null

	var/opened = 0
	var/emagged = 0
	var/wiresexposed = 0
	var/locked = 1
	var/list/req_access = list(access_robotics)
	var/ident = 0
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())
	var/viewalerts = 0
	var/modtype = "Default"
	var/lower_mod = 0
	var/datum/effect/system/spark_spread/spark_system//So they can initialize sparks whenever/N
	var/jeton = 0
	var/low_power_mode = 0 //whether the robot has no charge left.
	var/weapon_lock = 0
	var/weaponlock_time = 120
	var/lawupdate = 1 //Cyborgs will sync their laws with their AI by default
	var/lockcharge //Used when locking down a borg to preserve cell charge
	var/speed = 0 //Cause sec borgs gotta go fast //No they dont!
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/tracking_entities = 0 //The number of known entities currently accessing the internal camera
	var/braintype = "Cyborg"
	var/base_icon = ""
	var/crisis = 0

	var/lamp_max = 10 //Maximum brightness of a borg lamp. Set as a var for easy adjusting.
	var/lamp_intensity = 0 //Luminosity of the headlamp. 0 is off. Higher settings than the minimum require power.
	var/lamp_recharging = 0 //Flag for if the lamp is on cooldown after being forcibly disabled.

	var/updating = 0 //portable camera camerachunk update

	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD,NATIONS_HUD)

	var/magpulse = 0
	var/ionpulse = 0 // Jetpack-like effect.
	var/ionpulse_on = 0 // Jetpack-like effect.
	var/datum/effect/system/ion_trail_follow/ion_trail // Ionpulse effect.

	var/obj/item/borg/sight/hud/sec/sechud = null
	var/obj/item/borg/sight/hud/med/healthhud = null

	var/datum/action/item_action/toggle_research_scanner/scanner = null

/mob/living/silicon/robot/New(loc,var/syndie = 0,var/unfinished = 0, var/alien = 0)
	spark_system = new /datum/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_language("Robot Talk", 1)

	wires = new(src)

	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	robot_modules_background.layer = 19	//Objects that appear on screen are on layer 20, UI should be just below it.
	ident = rand(1, 999)
	rename_character(null, get_default_name())
	update_icons()
	update_headlamp()

	radio = new /obj/item/device/radio/borg(src)
	common_radio = radio

	init()

	if(!scrambledcodes && !camera)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.network = list("SS13","Robots")
		if(wires.IsCameraCut()) // 5 = BORG CAMERA
			camera.status = 0

	if(mmi == null)
		mmi = new /obj/item/device/mmi/posibrain(src)	//Give the borg an MMI if he spawns without for some reason. (probably not the correct way to spawn a posibrain, but it works)
		mmi.icon_state="posibrain-occupied"

	initialize_components()
	//if(!unfinished)
	// Create all the robot parts.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.installed = 1
		C.wrapped = new C.external_type

	if(!cell)
		cell = new /obj/item/weapon/stock_parts/cell(src)
		cell.maxcharge = 7500
		cell.charge = 7500

	..()

	add_robot_verbs()

	if(cell)
		var/datum/robot_component/cell_component = components["power cell"]
		cell_component.wrapped = cell
		cell_component.installed = 1

	diag_hud_set_borgcell()
	scanner = new(src)
	scanner.Grant(src)

/mob/living/silicon/robot/proc/init(var/alien=0)
	aiCamera = new/obj/item/device/camera/siliconcam/robot_camera(src)
	make_laws()
	additional_law_channels["Binary"] = ":b "
	var/new_ai = select_active_ai_with_fewest_borgs()
	if(new_ai)
		lawupdate = 1
		connect_to_ai(new_ai)
	else
		lawupdate = 0

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
			var/file = file2text("config/custom_sprites.txt")
			var/lines = splittext(file, "\n")

			for(var/line in lines)
			// split & clean up
				var/list/Entry = splittext(line, ";")
				for(var/i = 1 to Entry.len)
					Entry[i] = trim(Entry[i])

				if(Entry.len < 2)
					continue;

				if(Entry[1] == src.ckey && Entry[2] == src.real_name) //They're in the list? Custom sprite time, var and icon change required
					custom_sprite = 1
					icon = 'icons/mob/custom-synthetic.dmi'

	return 1

/mob/living/silicon/robot/proc/get_default_name(var/prefix as text)
	if(prefix)
		modtype = prefix
	if(mmi)
		if(istype(mmi, /obj/item/device/mmi/posibrain))
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
	if(scrambledcodes)
		var/datum/data/pda/app/messenger/M = rbPDA.find_program(/datum/data/pda/app/messenger)
		if(M)
			M.hidden = 1

/mob/living/silicon/robot/binarycheck()
	if(is_component_functioning("comms"))
		return 1
	return 0

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Destroy()
	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)	mmi.loc = T
		if(mmi.brainmob)
			mind.transfer_to(mmi.brainmob)
			mmi.update_icon()
		else
			to_chat(src, "<span class='boldannounce'>Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug.</span>")
			ghostize()
			error("A borg has been destroyed, but its MMI lacked a brainmob, so the mind could not be transferred. Player: [ckey].")
		mmi = null
	if(connected_ai)
		connected_ai.connected_robots -= src
	qdel(wires)
	wires = null
	qdel(module)
	module = null
	camera = null
	cell = null
	return ..()

/mob/living/silicon/robot/proc/pick_module()
	if(module)
		return
	var/list/modules = list("Standard", "Engineering", "Medical", "Miner", "Janitor", "Service", "Security")
	if(security_level == (SEC_LEVEL_GAMMA || SEC_LEVEL_EPSILON) || crisis)
		to_chat(src, "\red Crisis mode active. Combat module available.")
		modules+="Combat"
	if(ticker && ticker.mode && ticker.mode.name == "nations")
		var/datum/game_mode/nations/N = ticker.mode
		if(N.kickoff)
			modules = list("Peacekeeper")
	if(mmi != null && mmi.alien)
		modules = "Hunter"
	modtype = input("Please, select a module!", "Robot", null, null) as null|anything in modules
	if(!modtype)
		return
	designation = modtype
	var/module_sprites[0] //Used to store the associations between sprite names and sprite index.

	if(module)
		return

	switch(modtype)
		if("Standard")
			module = new /obj/item/weapon/robot_module/standard(src)
			module.channels = list("Service" = 1)
			module_sprites["Basic"] = "robot_old"
			module_sprites["Android"] = "droid"
			module_sprites["Default"] = "robot"

		if("Service")
			module = new /obj/item/weapon/robot_module/butler(src)
			module.channels = list("Service" = 1)
			module_sprites["Waitress"] = "Service"
			module_sprites["Kent"] = "toiletbot"
			module_sprites["Bro"] = "Brobot"
			module_sprites["Rich"] = "maximillion"
			module_sprites["Default"] = "Service2"
			module_sprites["Standard"] = "robotServ"

		if("Miner")
			module = new /obj/item/weapon/robot_module/miner(src)
			module.channels = list("Supply" = 1)
			if(camera && "Robots" in camera.network)
				camera.network.Add("Mining Outpost")
			module_sprites["Basic"] = "Miner_old"
			module_sprites["Advanced Droid"] = "droid-miner"
			module_sprites["Treadhead"] = "Miner"
			module_sprites["Standard"] = "robotMine"

		if("Medical")
			module = new /obj/item/weapon/robot_module/medical(src)
			module.channels = list("Medical" = 1)
			if(camera && "Robots" in camera.network)
				camera.network.Add("Medical")
			module_sprites["Basic"] = "Medbot"
			module_sprites["Surgeon"] = "surgeon"
			module_sprites["Advanced Droid"] = "droid-medical"
			module_sprites["Needles"] = "medicalrobot"
			module_sprites["Standard"] = "robotMedi"
			status_flags &= ~CANPUSH

		if("Security")
			module = new /obj/item/weapon/robot_module/security(src)
			module.channels = list("Security" = 1)
			module_sprites["Basic"] = "secborg"
			module_sprites["Red Knight"] = "Security"
			module_sprites["Black Knight"] = "securityrobot"
			module_sprites["Bloodhound"] = "bloodhound"
			module_sprites["Standard"] = "robotSecy"
			status_flags &= ~CANPUSH

		if("Engineering")
			module = new /obj/item/weapon/robot_module/engineering(src)
			module.channels = list("Engineering" = 1)
			if(camera && "Robots" in camera.network)
				camera.network.Add("Engineering")
			module_sprites["Basic"] = "Engineering"
			module_sprites["Antique"] = "engineerrobot"
			module_sprites["Landmate"] = "landmate"
			module_sprites["Standard"] = "robotEngi"
			magpulse = 1

		if("Janitor")
			module = new /obj/item/weapon/robot_module/janitor(src)
			module.channels = list("Service" = 1)
			module_sprites["Basic"] = "JanBot2"
			module_sprites["Mopbot"]  = "janitorrobot"
			module_sprites["Mop Gear Rex"] = "mopgearrex"
			module_sprites["Standard"] = "robotJani"

		if("Combat")
			module = new /obj/item/weapon/robot_module/combat(src)
			module.channels = list("Security" = 1)
			icon_state =  "droidcombat"

		if("Peacekeeper")
			module = new /obj/item/weapon/robot_module/peacekeeper(src)
			module.channels = list()
			icon_state = "droidpeace"

		if("Hunter")
			module = new /obj/item/weapon/robot_module/alien/hunter(src)
			icon = "icons/mob/alien.dmi"
			icon_state = "xenoborg-state-a"
			modtype = "Xeno-Hu"
			feedback_inc("xeborg_hunter",1)


	//languages
	module.add_languages(src)
	//subsystems
	module.add_subsystems(src)

	//Custom_sprite check and entry
	if(custom_sprite == 1)
		module_sprites["Custom"] = "[src.ckey]-[modtype]"

	hands.icon_state = lowertext(module.module_type)
	feedback_inc("cyborg_[lowertext(modtype)]",1)
	rename_character(real_name, get_default_name())

	if(modtype == "Medical" || modtype == "Security" || modtype == "Combat" || modtype == "Peacekeeper")
		status_flags &= ~CANPUSH

	choose_icon(6,module_sprites)
	radio.config(module.channels)
	notify_ai(2)

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

/mob/living/silicon/robot/proc/self_diagnosis()
	if(!is_component_functioning("diagnosis unit"))
		return null

	var/dat = "<HEAD><TITLE>[src.name] Self-Diagnosis Report</TITLE></HEAD><BODY>\n"
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		dat += "<b>[C.name]</b><br><table><tr><td>Brute Damage:</td><td>[C.brute_damage]</td></tr><tr><td>Electronics Damage:</td><td>[C.electronics_damage]</td></tr><tr><td>Powered:</td><td>[C.is_powered() ? "Yes" : "No"]</td></tr><tr><td>Toggled:</td><td>[ C.toggled ? "Yes" : "No"]</td></table><br>"

	return dat

/mob/living/silicon/robot/verb/self_diagnosis_verb()
	set category = "Robot Commands"
	set name = "Self Diagnosis"

	if(!is_component_functioning("diagnosis unit"))
		to_chat(src, "\red Your self-diagnosis component isn't functioning.")

	var/dat = self_diagnosis()
	src << browse(dat, "window=robotdiagnosis")


/mob/living/silicon/robot/verb/toggle_component()
	set category = "Robot Commands"
	set name = "Toggle Component"
	set desc = "Toggle a component, conserving power."

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell") continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			installed_components += V

	var/toggle = input(src, "Which component do you want to toggle?", "Toggle Component") as null|anything in installed_components
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	if(C.toggled)
		C.toggled = 0
		to_chat(src, "\red You disable [C.name].")
	else
		C.toggled = 1
		to_chat(src, "\red You enable [C.name].")

/mob/living/silicon/robot/proc/sensor_mode()
	set name = "Set Sensor Augmentation"
	set desc = "Augment visual feed with internal sensor overlays."
	set category = "Robot Commands"
	toggle_sensor_mode()

/mob/living/silicon/robot/proc/add_robot_verbs()
	src.verbs |= robot_verbs_default
	src.verbs |= silicon_subsystems

/mob/living/silicon/robot/proc/remove_robot_verbs()
	src.verbs -= robot_verbs_default
	src.verbs -= silicon_subsystems

/mob/living/silicon/robot/proc/ionpulse()
	if(!ionpulse_on)
		return

	if(cell.charge <= 50)
		toggle_ionpulse()
		return

	cell.charge -= 50 // 500 steps on a default cell.
	return 1

/mob/living/silicon/robot/proc/toggle_ionpulse()
	if(!ionpulse)
		to_chat(src, "<span class='notice'>No thrusters are installed!</span>")
		return

	if(!ion_trail)
		ion_trail = new
		ion_trail.set_up(src)

	ionpulse_on = !ionpulse_on
	to_chat(src, "<span class='notice'>You [ionpulse_on ? null :"de"]activate your ion thrusters.</span>")
	if(ionpulse_on)
		ion_trail.start()
	else
		ion_trail.stop()
	if(thruster_button)
		thruster_button.icon_state = "ionpulse[ionpulse_on]"

/mob/living/silicon/robot/blob_act()
	if(stat != 2)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	else
		gib()
		return 1
	return 0

// this function displays the cyborgs current cell charge in the stat panel
/mob/living/silicon/robot/proc/show_cell_power()
	if(cell)
		stat(null, text("Charge Left: [cell.charge]/[cell.maxcharge]"))
	else
		stat(null, text("No Cell Inserted!"))


// update the status screen display
/mob/living/silicon/robot/Stat()
	..()
	statpanel("Status")
	if(client.statpanel == "Status")
		show_cell_power()

/mob/living/silicon/robot/restrained()
	return 0


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


/mob/living/silicon/robot/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	if(prob(75) && Proj.damage > 0) spark_system.start()
	return 2


/mob/living/silicon/robot/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && (FAT in tmob.mutations))
				if(prob(20))
					to_chat(usr, "<span class='danger'>You fail to push [tmob]'s fat ass out of the way.</span>")
					now_pushing = 0
					return
			if(!(tmob.status_flags & CANPUSH))
				now_pushing = 0
				return
		now_pushing = 0
		..()
		if(!istype(AM, /atom/movable))
			return
		if(!now_pushing)
			now_pushing = 1
			if(!AM.anchored)
				var/t = get_dir(src, AM)
				if(istype(AM, /obj/structure/window/full))
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return
				step(AM, t)
			now_pushing = null
		return
	return

/mob/living/silicon/robot/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/restraints/handcuffs)) // fuck i don't even know why isrobot() in handcuff code isn't working so this will have to do
		return

	if(opened) // Are they trying to insert something?
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(!C.installed && istype(W, C.external_type))
				C.installed = 1
				C.wrapped = W
				C.install()
				user.drop_item()
				W.loc = null

				var/obj/item/robot_parts/robot_component/WC = W
				if(istype(WC))
					C.brute_damage = WC.brute
					C.electronics_damage = WC.burn

				to_chat(usr, "\blue You install the [W.name].")

				return

	if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent == I_HELP)
		if(W == module_active)
			return
		if(!getBruteLoss())
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
			return
		var/obj/item/weapon/weldingtool/WT = W
		user.changeNext_move(CLICK_CD_MELEE)
		if(WT.remove_fuel(0))
			playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
			adjustBruteLoss(-30)
			updatehealth()
			add_fingerprint(user)
			user.visible_message("<span class='alert'>\The [user] patches some dents on \the [src] with \the [WT].</span>")
		else
			to_chat(user, "<span class='warning'>Need more welding fuel!</span>")
			return


	else if(istype(W, /obj/item/stack/cable_coil) && user.a_intent == I_HELP && (wiresexposed || istype(src,/mob/living/silicon/robot/drone)))
		if(!getFireLoss())
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
			return
		var/obj/item/stack/cable_coil/coil = W
		adjustFireLoss(-30)
		updatehealth()
		add_fingerprint(user)
		coil.use(1)
		user.visible_message("<span class='alert'>\The [user] fixes some of the burnt wires on \the [src] with \the [coil].</span>")

	else if(istype(W, /obj/item/weapon/crowbar))	// crowbar means open or close the cover
		if(opened)
			if(cell)
				to_chat(user, "You close the cover.")
				opened = 0
				update_icons()
			else if(wiresexposed && wires.IsAllCut())
				//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
				if(!mmi)
					to_chat(user, "\The [src] has no brain to remove.")
					return

				to_chat(user, "You jam the crowbar into the robot and begin levering [mmi].")
				if(do_after(user,3 SECONDS, target = src))
					to_chat(user, "You damage some parts of the chassis, but eventually manage to rip out [mmi]!")
					var/obj/item/robot_parts/robot_suit/C = new/obj/item/robot_parts/robot_suit(loc)
					C.l_leg = new/obj/item/robot_parts/l_leg(C)
					C.r_leg = new/obj/item/robot_parts/r_leg(C)
					C.l_arm = new/obj/item/robot_parts/l_arm(C)
					C.r_arm = new/obj/item/robot_parts/r_arm(C)
					C.updateicon()
					new/obj/item/robot_parts/chest(loc)
					qdel(src)
			else
				// Okay we're not removing the cell or an MMI, but maybe something else?
				var/list/removable_components = list()
				for(var/V in components)
					if(V == "power cell") continue
					var/datum/robot_component/C = components[V]
					if(C.installed == 1 || C.installed == -1)
						removable_components += V

				var/remove = input(user, "Which component do you want to pry out?", "Remove Component") as null|anything in removable_components
				if(!remove)
					return
				var/datum/robot_component/C = components[remove]
				var/obj/item/robot_parts/robot_component/I = C.wrapped
				to_chat(user, "You remove \the [I].")
				if(istype(I))
					I.brute = C.brute_damage
					I.burn = C.electronics_damage

				I.loc = src.loc

				if(C.installed == 1)
					C.uninstall()
				C.installed = 0

		else
			if(locked)
				to_chat(user, "The cover is locked and cannot be opened.")
			else
				to_chat(user, "You open the cover.")
				opened = 1
				update_icons()

	else if(istype(W, /obj/item/weapon/stock_parts/cell) && opened)	// trying to put a cell inside
		var/datum/robot_component/C = components["power cell"]
		if(wiresexposed)
			to_chat(user, "Close the panel first.")
		else if(cell)
			to_chat(user, "There is a power cell already installed.")
		else
			user.drop_item()
			W.loc = src
			cell = W
			to_chat(user, "You insert the power cell.")

			C.installed = 1
			C.wrapped = W
			C.install()
			//This will mean that removing and replacing a power cell will repair the mount, but I don't care at this point. ~Z
			C.brute_damage = 0
			C.electronics_damage = 0
			diag_hud_set_borgcell()

	else if(istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/device/multitool))
		if(wiresexposed)
			wires.Interact(user)
		else
			to_chat(user, "You can't reach the wiring.")

	else if(istype(W, /obj/item/weapon/screwdriver) && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
		update_icons()

	else if(istype(W, /obj/item/weapon/screwdriver) && opened && cell)	// radio
		if(radio)
			radio.attackby(W,user)//Push it to the radio to let it handle everything
		else
			to_chat(user, "Unable to locate a radio.")
		update_icons()

	else if(istype(W, /obj/item/device/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			to_chat(user, "Unable to locate a radio.")

	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged)//still allow them to open the cover
			to_chat(user, "The interface seems slightly damaged")
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else
			if(allowed(usr))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] [src]'s interface.")
				update_icons()
			else
				to_chat(user, "\red Access denied.")

	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			to_chat(user, "<span class='warning'>You must access the borgs internals!</span>")
		else if(!src.module && U.require_module)
			to_chat(user, "<span class='warning'>The borg must choose a module before it can be upgraded!</span>")
		else if(U.locked)
			to_chat(user, "<span class='warning'>The upgrade is locked and cannot be used yet!</span>")
		else
			if(!user.drop_item())
				return
			if(U.action(src))
				to_chat(user, "<span class='notice'>You apply the upgrade to [src].</span>")
				U.forceMove(src)
			else
				to_chat(user, "<span class='danger'>Upgrade error.</span>")

	else
		spark_system.start()
		return ..()

/mob/living/silicon/robot/emag_act(user as mob)
	if(!ishuman(user) && !issilicon(user))
		return
	var/mob/living/M = user
	if(!opened)//Cover is closed
		if(locked)
			to_chat(user, "You emag the cover lock.")
			locked = 0
		else
			to_chat(user, "The cover is already unlocked.")
		return

	if(opened)//Cover is open
		if(emagged)	return//Prevents the X has hit Y with Z message also you cant emag them twice
		if(wiresexposed)
			to_chat(user, "You must close the panel first")
			return
		else
			sleep(6)
			emagged = 1
			SetLockdown(1) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
			if(src.hud_used)
				src.hud_used.update_robot_modules_display()	//Shows/hides the emag item if the inventory screen is already open.
			disconnect_from_ai()
			to_chat(user, "You emag [src]'s interface.")
//			message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden.")
			log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
			clear_supplied_laws()
			clear_inherent_laws()
			laws = new /datum/ai_laws/syndicate_override
			var/time = time2text(world.realtime,"hh:mm:ss")
			lawchanges.Add("[time] <B>:</B> [M.name]([M.key]) emagged [name]([key])")
			set_zeroth_law("Only [M.real_name] and people he designates as being such are Syndicate Agents.")
			to_chat(src, "\red ALERT: Foreign software detected.")
			sleep(5)
			to_chat(src, "\red Initiating diagnostics...")
			sleep(20)
			to_chat(src, "\red SynBorg v1.7 loaded.")
			sleep(5)
			to_chat(src, "\red LAW SYNCHRONISATION ERROR")
			sleep(5)
			to_chat(src, "\red Would you like to send a report to NanoTraSoft? Y/N")
			sleep(10)
			to_chat(src, "\red > N")
			sleep(20)
			to_chat(src, "\red ERRORERRORERROR")
			to_chat(src, "<b>Obey these laws:</b>")
			laws.show_laws(src)
			to_chat(src, "\red \b ALERT: [M.real_name] is your new master. Obey your new laws and his commands.")
			SetLockdown(0)
			if(src.module && istype(src.module, /obj/item/weapon/robot_module/miner))
				for(var/obj/item/weapon/pickaxe/drill/cyborg/D in src.module.modules)
					qdel(D)
				src.module.modules += new /obj/item/weapon/pickaxe/drill/cyborg/diamond(src.module)
				src.module.rebuild()
			if(src.module && istype(src.module, /obj/item/weapon/robot_module/medical))
				for(var/obj/item/weapon/borg_defib/F in src.module.modules)
					F.safety = 0
			if(module)
				module.module_type = "Malf" // For the cool factor
				update_module_icon()
			update_icons()
		return

/mob/living/silicon/robot/verb/unlock_own_cover()
	set category = "Robot Commands"
	set name = "Unlock Cover"
	set desc = "Unlocks your own cover if it is locked. You can not lock it again. A human will have to lock it for you."
	if(locked)
		switch(alert("You can not lock your cover again, are you sure?\n      (You can still ask for a human to lock it)", "Unlock Own Cover", "Yes", "No"))
			if("Yes")
				locked = 0
				update_icons()
				to_chat(usr, "You unlock your cover.")

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	switch(M.a_intent)

		if(I_HELP)
			for(var/mob/O in viewers(src, null))
				if((O.client && !( O.blinded )))
					O.show_message(text("<span class='notice'>[M] caresses [src]'s plating with its scythe like arm.</span>"), 1)

		if(I_GRAB)
			grabbedby(M)

		if(I_HARM)
			M.do_attack_animation(src)
			var/damage = rand(10, 20)
			if(prob(90))
				playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has slashed at [src]!</span>",\
								"<span class='userdanger'>[M] has slashed at [src]!</span>")
				if(prob(8))
					flash_eyes(affect_silicon = 1)
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] took a swipe at [src]!</span>", \
								"<span class='userdanger'>[M] took a swipe at [src]!</span>")

		if(I_DISARM)
			if(!(lying))
				M.do_attack_animation(src)
				if(prob(85))
					Stun(7)
					step(src,get_dir(M,src))
					spawn(5)
						step(src,get_dir(M,src))
					playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has forced back [src]!</span>",\
									"<span class='userdanger'>[M] has forced back [src]!</span>")
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
					visible_message("<span class='danger'>[M] attempted to force back [src]!</span>",\
									"<span class='userdanger'>[M] attempted to force back [src]!</span>")
	return



/mob/living/silicon/robot/attack_slime(mob/living/carbon/slime/M as mob)
	if(..()) //successful slime shock
		flash_eyes(affect_silicon = 1)
		var/stunprob = M.powerlevel * 7 + 10
		if(prob(stunprob) && M.powerlevel >= 8)
			adjustBruteLoss(M.powerlevel * rand(6,10))

	var/damage = rand(1, 3)

	if(M.is_adult)
		damage = rand(20, 40)
	else
		damage = rand(5, 35)
	damage = round(damage / 2) // borgs recieve half damage
	adjustBruteLoss(damage)
	updatehealth()

	return

/mob/living/silicon/robot/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.custom_emote(1, "[M.friendly] [src]")
	else
		M.do_attack_animation(src)
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		visible_message("<span class='danger'><B>[M]</B> [M.attacktext] [src]!</span>")
		add_logs(M, src, "attacked", admin=0)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		switch(M.melee_damage_type)
			if(BRUTE)
				adjustBruteLoss(damage)
			if(BURN)
				adjustFireLoss(damage)
			if(TOX)
				adjustToxLoss(damage)
			if(OXY)
				adjustOxyLoss(damage)
			if(CLONE)
				adjustCloneLoss(damage)
			if(STAMINA)
				adjustStaminaLoss(damage)
		updatehealth()


/mob/living/silicon/robot/attack_hand(mob/user)

	add_fingerprint(user)

	if(opened && !wiresexposed && (!istype(user, /mob/living/silicon)))
		if(cell)
			cell.updateicon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			to_chat(user, "You remove \the [cell].")
			cell = null
			update_icons()
			diag_hud_set_borgcell()

	if(!opened && (!istype(user, /mob/living/silicon)))
		if(user.a_intent == I_HELP)
			user.visible_message("<span class='notice'>[user] pets [src]!</span>", \
								"<span class='notice'>You pet [src]!</span>")

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return 1
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_hand()) || check_access(H.wear_id))
			return 1
	return 0

/mob/living/silicon/robot/proc/check_access(obj/item/weapon/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return 1

	var/list/L = req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in req_access)
		if(req in I.access) //have one of the required accesses
			return 1
	return 0

/mob/living/silicon/robot/update_icons()

	overlays.Cut()
	if(stat != DEAD && !(paralysis || stunned || weakened || low_power_mode)) //Not dead, not stunned.
		overlays += "eyes-[icon_state]"
	else
		overlays -= "eyes"

	if(opened && custom_sprite == 1) //Custom borgs also have custom panels, heh
		if(wiresexposed)
			overlays += "[src.ckey]-openpanel +w"
		else if(cell)
			overlays += "[src.ckey]-openpanel +c"
		else
			overlays += "[src.ckey]-openpanel -c"

	if(opened)
		if(wiresexposed)
			overlays += "ov-openpanel +w"
		else if(cell)
			overlays += "ov-openpanel +c"
		else
			overlays += "ov-openpanel -c"

	var/combat = list("Combat","Peacekeeper")
	if(modtype in combat)
		if(base_icon == "")
			base_icon = icon_state
		if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
			icon_state = "[base_icon]-roll"
		else
			icon_state = base_icon
		for(var/obj/item/borg/combat/shield/S in module.modules)
			if(activated(S))
				overlays += "[base_icon]-shield"
	update_fire()

/mob/living/silicon/robot/proc/installed_modules()
	if(weapon_lock)
		to_chat(src, "\red Weapon lock active, unable to use modules! Count:[weaponlock_time]")
		return

	if(!module)
		pick_module()
		return
	var/dat = {"<A HREF='?src=[UID()];mach_close=robotmod'>Close</A>
	<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	<table border='0'>
	<tr><td>Module 1:</td><td>[module_state_1 ? "<A HREF=?src=[UID()];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]</td></tr>
	<tr><td>Module 2:</td><td>[module_state_2 ? "<A HREF=?src=[UID()];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]</td></tr>
	<tr><td>Module 3:</td><td>[module_state_3 ? "<A HREF=?src=[UID()];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]</td></tr>
	</table><BR>
	<B>Installed Modules</B><BR><BR>

	<table border='0'>"}
	for(var/obj in module.modules)
		if(!obj)
			dat += text("<tr><td><B>Resource depleted</B></td></tr>")
		else if(activated(obj))
			dat += text("<tr><td>[obj]</td><td><B>Activated</B></td></tr>")
		else
			dat += text("<tr><td>[obj]</td><td><A HREF=?src=[UID()];act=\ref[obj]>Activate</A></td></tr>")
	if(emagged)
		if(activated(module.emag))
			dat += text("<tr><td>[module.emag]</td><td><B>Activated</B></td></tr>")
		else
			dat += text("<tr><td>[module.emag]</td><td><A HREF=?src=[UID()];act=\ref[module.emag]>Activate</A></td></tr>")
	dat += "</table>"
/*
		if(activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=[UID()];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=[UID()];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
*/
	var/datum/browser/popup = new(src, "robotmod", "Modules")
	popup.set_content(dat)
	popup.open()


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

	if(href_list["showalerts"])
		subsystem_alarm_monitor()
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
		installed_modules()

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
		installed_modules()
		return 1

	return 1

/mob/living/silicon/robot/proc/radio_menu()
	radio.interact(src)//Just use the radio's Topic() instead of bullshit special-snowflake code

/mob/living/silicon/robot/proc/control_headlamp()
	if(stat || lamp_recharging || low_power_mode)
		to_chat(src, "<span class='danger'>This function is currently offline.</span>")
		return

//Some sort of magical "modulo" thing which somehow increments lamp power by 2, until it hits the max and resets to 0.
	lamp_intensity = (lamp_intensity+2) % (lamp_max+2)
	to_chat(src, "[lamp_intensity ? "Headlamp power set to Level [lamp_intensity/2]" : "Headlamp disabled."]")
	update_headlamp()

/mob/living/silicon/robot/proc/update_headlamp(var/turn_off = 0, var/cooldown = 100)
	set_light(0)

	if(lamp_intensity && (turn_off || stat || low_power_mode))
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

#define BORG_CAMERA_BUFFER 30
/mob/living/silicon/robot/Move(a, b, flag)
	var/oldLoc = src.loc
	. = ..()
	if(.)
		if(src.camera)
			if(!updating)
				updating = 1
				spawn(BORG_CAMERA_BUFFER)
					if(oldLoc != src.loc)
						cameranet.updatePortableCamera(src.camera)
					updating = 0
	if(module)
		if(module.type == /obj/item/weapon/robot_module/janitor)
			var/turf/tile = loc
			if(isturf(tile))
				tile.clean_blood()
				if(istype(tile, /turf/simulated))
					var/turf/simulated/S = tile
					S.dirt = 0
				for(var/A in tile)
					if(istype(A, /obj/effect))
						if(is_cleanable(A))
							qdel(A)
					else if(istype(A, /obj/item))
						var/obj/item/cleaned_item = A
						cleaned_item.clean_blood()
					else if(istype(A, /mob/living/carbon/human))
						var/mob/living/carbon/human/cleaned_human = A
						if(cleaned_human.lying)
							if(cleaned_human.head)
								cleaned_human.head.clean_blood()
								cleaned_human.update_inv_head(0,0)
							if(cleaned_human.wear_suit)
								cleaned_human.wear_suit.clean_blood()
								cleaned_human.update_inv_wear_suit(0,0)
							else if(cleaned_human.w_uniform)
								cleaned_human.w_uniform.clean_blood()
								cleaned_human.update_inv_w_uniform(0,0)
							if(cleaned_human.shoes)
								cleaned_human.shoes.clean_blood()
								cleaned_human.update_inv_shoes(0,0)
							cleaned_human.clean_blood()
							to_chat(cleaned_human, "<span class='danger'>[src] cleans your face!</span>")
		return
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
	if(src.camera)
		qdel(src.camera)
		src.camera = null
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

/mob/living/silicon/robot/proc/SetLockdown(var/state = 1)
	// They stay locked down if their wire is cut.
	if(wires.LockedCut())
		state = 1
	if(state)
		throw_alert("locked", /obj/screen/alert/locked)
	else
		clear_alert("locked")
	lockcharge = state
	update_canmove()

/mob/living/silicon/robot/proc/choose_icon(var/triesleft, var/list/module_sprites)

	if(triesleft<1 || !module_sprites.len)
		return
	else
		triesleft--

	var/icontype

	if(custom_sprite == 1)
		icontype = "Custom"
		triesleft = 0
	else
		lockcharge = 1  //Locks borg until it select an icon to avoid secborgs running around with a standard sprite
		icontype = input("Select an icon! [triesleft ? "You have [triesleft] more chances." : "This is your last try."]", "Robot", null, null) in module_sprites

	if(icontype)
		icon_state = module_sprites[icontype]
		if(icontype == "Bro")
			module.module_type = "Brobot"
			update_module_icon()
		lockcharge = null
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

/mob/living/silicon/robot/proc/notify_ai(var/notifytype, var/oldname, var/newname)
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

/mob/living/silicon/robot/proc/connect_to_ai(var/mob/living/silicon/ai/AI)
	if(AI && AI != connected_ai)
		disconnect_from_ai()
		connected_ai = AI
		connected_ai.connected_robots |= src
		notify_ai(1)
		sync()

/mob/living/silicon/robot/adjustOxyLoss(var/amount)
	if(suiciding)
		..()

/mob/living/silicon/robot/regenerate_icons()
	..()
	update_module_icon()

/mob/living/silicon/robot/deathsquad
	base_icon = "nano_bloodhound"
	icon_state = "nano_bloodhound"
	lawupdate = 0
	scrambledcodes = 1
	modtype = "Commando"
	faction = list("nanotrasen")
	designation = "Nanotrasen Combat"
	req_access = list(access_cent_specops)
	ionpulse = 1
	var/searching_for_ckey = 0

/mob/living/silicon/robot/deathsquad/New(loc)
	..()
	cell.maxcharge = 25000
	cell.charge = 25000

/mob/living/silicon/robot/deathsquad/init()
	laws = new /datum/ai_laws/deathsquad
	module = new /obj/item/weapon/robot_module/deathsquad(src)

	aiCamera = new/obj/item/device/camera/siliconcam/robot_camera(src)
	radio = new /obj/item/device/radio/borg/deathsquad(src)
	radio.recalculateChannels()

	playsound(loc, 'sound/mecha/nominalsyndi.ogg', 75, 0)

/mob/living/silicon/robot/deathsquad/attack_hand(mob/user)
	if(isnull(ckey) && !searching_for_ckey)
		searching_for_ckey = 1
		to_chat(user, "<span class='notice'>Now checking for possible borgs.</span>")
		var/list/borg_candidates = pollCandidates("Do you want to play as a Nanotrasen Combat borg?")
		if(borg_candidates.len > 0 && isnull(ckey))
			searching_for_ckey = 0
			var/mob/M = pick(borg_candidates)
			M.mind.transfer_to(src)
			M.mind.assigned_role = "MODE"
			M.mind.special_role = SPECIAL_ROLE_DEATHSQUAD
			ticker.mode.traitors |= M.mind // Adds them to current traitor list. Which is really the extra antagonist list.
			key = M.key
		else
			searching_for_ckey = 0
			to_chat(user, "<span class='notice'>Unable to connect to Central Command. Please wait and try again later.</span>")
			return
	else
		to_chat(user, "<span class='warning'>[src] is already checking for possible borgs.</span>")
		return

/mob/living/silicon/robot/syndicate
	base_icon = "syndie_bloodhound"
	icon_state = "syndie_bloodhound"
	lawupdate = 0
	scrambledcodes = 1
	faction = list("syndicate")
	designation = "Syndicate Assault"
	modtype = "Syndicate"
	req_access = list(access_syndicate)
	ionpulse = 1
	lawchannel = "State"
	var/playstyle_string = "<span class='userdanger'>You are a Syndicate assault cyborg!</span><br>\
							<b>You are armed with powerful offensive tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
							Your cyborg LMG will slowly produce ammunition from your power supply, and your operative pinpointer will find and locate fellow nuclear operatives. \
							<i>Help the operatives secure the disk at all costs!</i></b>"

/mob/living/silicon/robot/syndicate/New(loc)
	..()
	cell.maxcharge = 25000
	cell.charge = 25000

/mob/living/silicon/robot/syndicate/init()
	laws = new /datum/ai_laws/syndicate_override
	module = new /obj/item/weapon/robot_module/syndicate(src)

	aiCamera = new/obj/item/device/camera/siliconcam/robot_camera(src)
	radio = new /obj/item/device/radio/borg/syndicate(src)
	radio.recalculateChannels()

	spawn(5)
		if(playstyle_string)
			to_chat(src, playstyle_string)

	playsound(loc, 'sound/mecha/nominalsyndi.ogg', 75, 0)

/mob/living/silicon/robot/syndicate/medical
	base_icon = "syndi-medi"
	icon_state = "syndi-medi"
	modtype = "Syndicate Medical"
	designation = "Syndicate Medical"
	playstyle_string = "<span class='userdanger'>You are a Syndicate medical cyborg!</span><br>\
						<b>You are armed with powerful medical tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your hypospray will produce Restorative Nanites, a wonder-drug that will heal most types of bodily damages, including clone and brain damage. It also produces morphine for offense. \
						Your defibrillator paddles can revive operatives through their hardsuits, or can be used on harm intent to shock enemies! \
						Your energy saw functions as a circular saw, but can be activated to deal more damage, and your operative pinpointer will find and locate fellow nuclear operatives. \
						<i>Help the operatives secure the disk at all costs!</i></b>"

/mob/living/silicon/robot/syndicate/medical/init()
	..()
	module = new /obj/item/weapon/robot_module/syndicate_medical(src)

/mob/living/silicon/robot/combat
	base_icon = "droidcombat"
	icon_state = "droidcombat"
	modtype = "Combat"
	designation = "Combat"

/mob/living/silicon/robot/combat/init()
	..()
	module = new /obj/item/weapon/robot_module/combat(src)
	module.channels = list("Security" = 1)
	//languages
	module.add_languages(src)
	//subsystems
	module.add_subsystems(src)

	status_flags &= ~CANPUSH

	radio.config(module.channels)
	notify_ai(2)

/mob/living/silicon/robot/peacekeeper
	base_icon = "droidpeace"
	icon_state = "droidpeace"
	modtype = "Peacekeeper"
	designation = "Peacekeeper"

/mob/living/silicon/robot/peacekeeper/init()
	..()
	module = new /obj/item/weapon/robot_module/peacekeeper(src)
	//languages
	module.add_languages(src)
	//subsystems
	module.add_subsystems(src)

	status_flags &= ~CANPUSH

	notify_ai(2)

/mob/living/silicon/robot/emp_act(severity)
	..()
	switch(severity)
		if(1)
			disable_component("comms", 160)
		if(2)
			disable_component("comms", 60)
