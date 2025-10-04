GLOBAL_LIST_EMPTY(ai_list)
GLOBAL_LIST_INIT(ai_verbs_default, list(
	/mob/living/silicon/ai/proc/announcement,
	/mob/living/silicon/ai/proc/ai_announcement_text,
	/mob/living/silicon/ai/proc/ai_call_shuttle,
	/mob/living/silicon/ai/proc/ai_camera_track,
	/mob/living/silicon/ai/proc/ai_camera_list,
	/mob/living/silicon/ai/proc/ai_hologram_change,
	/mob/living/silicon/ai/proc/ai_network_change,
	/mob/living/silicon/ai/proc/ai_roster,
	/mob/living/silicon/ai/proc/ai_statuschange,
	/mob/living/silicon/ai/proc/control_integrated_radio,
	/mob/living/silicon/ai/proc/core,
	/mob/living/silicon/ai/proc/pick_icon,
	/mob/living/silicon/ai/proc/sensor_mode,
	/mob/living/silicon/ai/proc/show_laws_verb,
	/mob/living/silicon/ai/proc/toggle_fast_holograms,
	/mob/living/silicon/ai/proc/toggle_acceleration,
	/mob/living/silicon/ai/proc/toggle_camera_light,
	/mob/living/silicon/ai/proc/botcall,
	/mob/living/silicon/ai/proc/change_arrival_message,
	/mob/living/silicon/ai/proc/arrivals_announcement,
	/mob/living/silicon/ai/proc/change_hologram_color
))

//Not sure why this is necessary...
/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = 0
	if(subject!=null)
		for(var/A in GLOB.ai_list)
			var/mob/living/silicon/ai/M = A
			if(M.client && M.machine == subject)
				is_in_use = 1
				subject.attack_ai(M)
	return is_in_use

#define TEXT_ANNOUNCEMENT_COOLDOWN 1 MINUTES

/mob/living/silicon/ai
	name = "AI"
	icon = 'icons/mob/ai.dmi'//
	icon_state = "ai"
	move_resist = MOVE_FORCE_NORMAL
	status_flags = CANSTUN|CANPARALYSE|CANPUSH
	d_hud = DATA_HUD_DIAGNOSTIC_ADVANCED
	mob_size = MOB_SIZE_LARGE
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	see_invisible = SEE_INVISIBLE_LIVING_AI
	see_in_dark = 8
	hud_type = /datum/hud/ai
	hat_offset_y = 3
	is_centered = TRUE
	can_be_hatted = TRUE
	var/list/network = list("SS13", "Mining Outpost", "Labor Camp")
	var/obj/machinery/camera/current = null
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	//var/list/laws = list()
	alarms_listened_for = list("Motion", "Fire", "Atmosphere", "Power", "Burglar")
	var/viewalerts = FALSE
	var/icon/holo_icon //Default is assigned when AI is created.
	var/obj/mecha/controlled_mech //For controlled_mech a mech, to determine whether to relaymove or use the AI eye.
	var/obj/item/pda/silicon/ai/aiPDA = null
	var/obj/item/multitool/aiMulti = null
	var/custom_sprite = FALSE //For our custom sprites
	var/custom_hologram = FALSE //For our custom holograms

	var/obj/item/radio/headset/heads/ai_integrated/aiRadio = null

	// AI Powers
	var/datum/program_picker/program_picker
	var/datum/spell/ai_spell/choose_program/program_action
	/// Base rate of nanite regen
	var/nanite_regen = 1
	/// Whether or not the AI has unlocked universal adapter
	var/universal_adapter = FALSE
	/// How effective is the adapter?
	var/adapter_efficiency = 0.5
	/// Has the AI unlocked a bluespace miner?
	var/bluespace_miner = FALSE
	/// Credit payout rate
	var/bluespace_miner_rate = 100
	/// Time until next payout
	var/next_payout = 10 MINUTES
	/// Has the AI unlocked a research subsystem?
	var/research_subsystem = FALSE
	/// How potent is the research subsystem?
	var/research_level = 0
	/// How long does it take to unlock the next research?
	var/research_time = 10 MINUTES
	/// When did we last research something?
	var/last_research_time
	/// Do we have the enhanced tracker?
	var/enhanced_tracking = FALSE
	/// Who are we tracking with the enhanced tracker?
	var/mob/tracked_mob
	/// The current delay on enhanced tracking
	var/enhanced_tracking_delay = 10 SECONDS
	/// Interval between camera pings to prevent spammed alerts
	var/tracking_alert_interval = 30 SECONDS
	/// Is the interval active
	var/tracker_alert_cooldown = FALSE

	//MALFUNCTION
	var/datum/module_picker/malf_picker
	var/datum/spell/ai_spell/choose_modules/modules_action
	var/list/datum/ai_module/current_modules = list()
	var/can_dominate_mechs = FALSE
	var/shunted = FALSE // TRUE if the AI is currently shunted. Used to differentiate between shunted and ghosted/braindead

	var/control_disabled = FALSE // Set to TRUE to stop AI from interacting via Click() -- TLE
	var/malfhacking = null // A timer for when malf AIs can hack and get new cyborgs
	var/malf_cooldown = 0 //Cooldown var for malf modules, stores a worldtime + cooldown

	var/obj/machinery/power/apc/malfhack = null
	var/explosive = 0 //does the AI explode when it dies?

	///Whether or not the AI has upgraded their turrets
	var/turrets_upgraded = FALSE

	/// List of modules the AI has purchased malf upgrades for.
	var/list/purchased_modules = list()

	var/mob/living/silicon/ai/parent = null
	var/camera_light_on = FALSE
	var/list/obj/machinery/camera/lit_cameras = list()

	var/datum/trackable/track = new()

	var/last_paper_seen = null
	var/can_shunt = TRUE
	var/last_announcement = ""
	var/datum/announcer/announcer
	var/mob/living/simple_animal/bot/Bot
	var/turf/waypoint //Holds the turf of the currently selected waypoint.
	var/waypoint_mode = FALSE //Waypoint mode is for selecting a turf via clicking.
	var/apc_override = FALSE	//hack for letting the AI use its APC even when visionless
	var/nuking = FALSE
	var/obj/machinery/doomsday_device/doomsday_device

	var/obj/machinery/hologram/holopad/holo = null
	var/mob/camera/eye/ai/eyeobj
	var/fast_holograms = TRUE
	var/tracking = FALSE //this is 1 if the AI is currently tracking somebody, but the track has not yet been completed.

	/// If true, this AI core can use the teleporter.
	var/allow_teleporter = FALSE

	var/obj/machinery/camera/portable/builtInCamera

	var/obj/structure/ai_core/deactivated/linked_core //For exosuit control

	/// If our AI doesn't want to be the arrivals announcer, this gets set to FALSE.
	var/announce_arrivals = TRUE
	var/arrivalmsg = "$name, $rank, has arrived on the station."

	var/next_text_announcement

	//Used with the hotkeys on 2-5 to store locations.
	var/list/stored_locations = list()
	/// Set to true if the AI cracks it's camera by using the malf ability
	var/cracked_camera = FALSE
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_atmos_control,
		/mob/living/silicon/proc/subsystem_crew_monitor,
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/proc/subsystem_power_monitor)

	/// The cached AI annoucement help menu.
	var/ai_announcement_string_menu


	/// Is the AI in storage?
	var/in_storage = FALSE

	var/hologram_color = rgb(125, 180, 225)


/mob/living/silicon/ai/proc/add_ai_verbs()
	add_verb(src, GLOB.ai_verbs_default)
	add_verb(src, silicon_subsystems)

/mob/living/silicon/ai/proc/remove_ai_verbs()
	remove_verb(src, GLOB.ai_verbs_default)
	remove_verb(src, silicon_subsystems)

/mob/living/silicon/ai/New(loc, datum/ai_laws/L, obj/item/mmi/B, safety = 0)
	announcer = new(config_type = /datum/announcement_configuration/ai)
	announcer.author = name

	var/list/possibleNames = GLOB.ai_names

	var/pickedName = null
	while(!pickedName)
		pickedName = pick(GLOB.ai_names)
		for(var/mob/living/silicon/ai/A in GLOB.ai_list)
			if(A.real_name == pickedName && length(possibleNames) > 1) // fixing the theoretically possible infinite loop
				possibleNames -= pickedName
				pickedName = null

	aiPDA = new/obj/item/pda/silicon/ai(src)
	rename_character(null, pickedName)
	anchored = TRUE
	density = TRUE
	loc = loc

	holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo1"))

	proc_holder_list = new()

	if(L)
		if(istype(L, /datum/ai_laws))
			laws = L
	else
		make_laws()

	add_verb(src, /mob/living/silicon/ai/proc/show_laws_verb)

	aiMulti = new(src)
	aiRadio = new(src)
	aiRadio.myAi = src
	additional_law_channels["Binary"] = ":b "
	additional_law_channels["Holopad"] = ":h"

	aiCamera = new/obj/item/camera/siliconcam/ai_camera(src)

	if(isturf(loc))
		add_ai_verbs(src)

	// Remove inherited verbs that effectively do nothing for AIs, or lead to unintended behaviour.
	remove_verb(src, /mob/living/verb/rest)
	remove_verb(src, /mob/living/verb/mob_sleep)
	remove_verb(src, /mob/living/verb/stop_pulling1)
	remove_verb(src, /mob/living/silicon/verb/pose)
	remove_verb(src, /mob/living/silicon/verb/set_flavor)

	//Languages
	add_language("Robot Talk", 1)
	add_language("Galactic Common", 1)
	add_language("Sol Common", 1)
	add_language("Tradeband", 1)
	add_language("Cygni Standard", 1)
	add_language("Gutter", 1)
	add_language("Sinta'unathi", 1)
	add_language("Siik'tajr", 1)
	add_language("Canilunzt", 1)
	add_language("Qurvolious", 1)
	add_language("Vox-pidgin", 1)
	add_language("Orluum", 1)
	add_language("Rootspeak", 1)
	add_language("Trinary", 1)
	add_language("Chittin", 1)
	add_language("Bubblish", 1)
	add_language("Clownish", 1)
	add_language("Tkachi", 1)

	if(!safety)//Only used by AIize() to successfully spawn an AI.
		if(!B)//If there is no player/brain inside.
			new/obj/structure/ai_core/deactivated(loc)//New empty terminal.
			qdel(src)//Delete AI.
			return
		else
			if(B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)

			on_mob_init()

	spawn(5)
		new /obj/machinery/ai_powersupply(src)

	eyeobj = new /mob/camera/eye/ai(loc, name, src, src)

	builtInCamera = new /obj/machinery/camera/portable(src)
	builtInCamera.c_tag = name
	builtInCamera.network = list("SS13")

	GLOB.ai_list += src
	GLOB.shuttle_caller_list += src

	add_program_picker()

	for(var/I in 1 to 4)
		stored_locations += "unset" //This is checked in ai_keybinds.dm.

	..()

/mob/living/silicon/ai/Initialize(mapload)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_CAN_STRIP, TRAIT_GENERIC)

/mob/living/silicon/ai/Destroy()
	GLOB.ai_list -= src
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	if(malfhacking)
		deltimer(malfhacking)
		malfhacking = null
	QDEL_NULL(eyeobj) // No AI, no Eye
	QDEL_NULL(aiPDA)
	QDEL_NULL(aiMulti)
	QDEL_NULL(aiRadio)
	QDEL_NULL(builtInCamera)
	tracked_mob = null
	return ..()

/mob/living/silicon/ai/get_radio()
	return aiRadio

/mob/living/silicon/ai/proc/on_mob_init()
	to_chat(src, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
	to_chat(src, "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>")
	to_chat(src, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
	to_chat(src, "To use something, simply click on it.")
	to_chat(src, "Use say :b to speak to your cyborgs through binary. Use say :h to speak from an active holopad.")
	to_chat(src, "For department channels, use the following say commands:")

	var/radio_text = ""
	for(var/i = 1 to length(aiRadio.channels))
		var/channel = aiRadio.channels[i]
		var/key = get_radio_key_from_channel(channel)
		radio_text += "[key] - [channel]"
		if(i != length(aiRadio.channels))
			radio_text += ", "

	to_chat(src, radio_text)

	show_laws()
	to_chat(src, "<b>These laws may be changed by other players, or by you being the traitor.</b>")

	job = "AI"

/mob/living/silicon/ai/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Nanites:", "[program_picker.nanites] / [program_picker.max_nanites]")
	status_tab_data[++status_tab_data.len] = list("Nanite Manufacture Rate:", "[(nanite_regen + 0.5 * program_picker.bandwidth)]")
	if(stat)
		status_tab_data[++status_tab_data.len] = list("System status:", "Nonfunctional")
		return
	status_tab_data = show_borg_info(status_tab_data)

/mob/living/silicon/ai/proc/ai_alerts()
	var/list/dat = list("<!DOCTYPE html><meta charset='utf-8'><head><title>Current Station Alerts</title><meta http-equiv='Refresh' content='10'></head><body>\n")
	dat += "<a href='byond://?src=[UID()];mach_close=aialerts'>Close</a><br><br>"
	var/list/list/temp_alarm_list = GLOB.alarm_manager.alarms.Copy()
	for(var/cat in temp_alarm_list)
		if(!(cat in alarms_listened_for))
			continue
		dat += "<b>[cat]</b><br>\n"
		var/list/list/L = temp_alarm_list[cat].Copy()
		for(var/alarm in L)
			var/list/list/alm = L[alarm].Copy()
			var/area_name = alm[1]
			var/C = alm[2]
			var/list/list/sources = alm[3].Copy()
			for(var/thing in sources)
				var/atom/A = locateUID(thing)
				if(A && A.z != z)
					L -= alarm
					continue
				dat += "<nobr>"
				if(C && islist(C))
					var/dat2 = ""
					for(var/cam in C)
						var/obj/machinery/camera/I = locateUID(cam)
						if(!QDELETED(I))
							dat2 += "[(dat2 == "") ? "" : " | "]<a href=byond://?src=[UID()];switchcamera=[cam]>[I.c_tag]</A>"
					dat += "-- [area_name] ([(dat2 != "") ? dat2 : "No Camera"])"
				else
					dat += "-- [area_name] (No Camera)"
				if(length(sources) > 1)
					dat += "- [length(sources)] sources"
				dat += "</nobr><br>\n"
		if(!length(L))
			dat += "-- All Systems Nominal<br>\n"
		dat += "<br>\n"

	viewalerts = TRUE
	var/dat_text = dat.Join("")
	src << browse(dat_text, "window=aialerts&can_close=0")

/mob/living/silicon/ai/proc/show_borg_info(list/status_tab_data)
	status_tab_data[++status_tab_data.len] = list("Connected cyborg count:", "[length(connected_robots)]")
	for(var/mob/living/silicon/robot/R in connected_robots)
		var/robot_status = "Nominal"
		if(R.stat || !R.client)
			robot_status = "OFFLINE"
		else if(!R.cell || R.cell.charge <= 0)
			robot_status = "DEPOWERED"
		// Name, Health, Battery, Module, Area, and Status! Everything an AI wants to know about its borgies!
		var/area/A = get_area(R)
		var/area_name = A ? sanitize(A.name) : "Unknown"
		status_tab_data[++status_tab_data.len] = list("[R.name]:", "S.Integrity: [R.health]% | Cell: [R.cell ? "[R.cell.charge] / [R.cell.maxcharge]" : "Empty"] | \
		Module: [R.designation] | Loc: [area_name] | Status: [robot_status]")
	return status_tab_data

/mob/living/silicon/ai/rename_character(oldname, newname)
	if(!..(oldname, newname))
		return FALSE

	if(oldname != real_name)
		announcer.author = name

		if(eyeobj)
			eyeobj.name = "[newname] (AI Eye)"

		// Set ai pda name
		if(aiPDA)
			aiPDA.set_name_and_job(newname, "AI")

	return TRUE

/mob/living/silicon/ai/open_pda()
	aiPDA.ui_interact(src)

/*
	The AI Power supply is a dummy object used for powering the AI since only machinery should be using power.
	The alternative was to rewrite a bunch of AI code instead here we are.
*/
/obj/machinery/ai_powersupply
	name="\improper AI power supply"
	active_power_consumption = 1000
	power_state = ACTIVE_POWER_USE
	var/mob/living/silicon/ai/powered_ai = null
	invisibility = 100
	/// Power draw for the bluespace miner module
	var/bluespace_miner_power = 0

/obj/machinery/ai_powersupply/New(mob/living/silicon/ai/ai=null)
	powered_ai = ai
	if(isnull(powered_ai))
		qdel(src)
		return

	loc = powered_ai.loc
	use_power(1) // Just incase we need to wake up the power system.

	..()

/obj/machinery/ai_powersupply/process()
	if(!powered_ai || powered_ai.stat & DEAD)
		qdel(src)
		return
	// Regenerate nanites for abilities only when powered.
	powered_ai.program_picker.nanites = min(powered_ai.program_picker.max_nanites, powered_ai.program_picker.nanites + (powered_ai.nanite_regen + 0.5 * powered_ai.program_picker.bandwidth))
	if(!powered_ai.anchored)
		loc = powered_ai.loc
		change_power_mode(NO_POWER_USE)
	if(powered_ai.anchored)
		change_power_mode(ACTIVE_POWER_USE)
	if(powered_ai.research_subsystem && powered_ai.last_research_time + powered_ai.research_time <= world.time)
		powered_ai.do_research()
	if(powered_ai.bluespace_miner)
		// Money money money
		if(powered_ai.next_payout <= world.time)
			powered_ai.next_payout = 10 MINUTES + world.time
			var/account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
			var/datum/money_account_database/main_station/station_db = GLOB.station_money_database
			station_db.credit_account(account, powered_ai.bluespace_miner_rate, "Bluespace Miner Production", "AI Bluespace Miner Subsystem", FALSE)

		// Update power consumption if powering a bluespace miner
		if(bluespace_miner_power == powered_ai.bluespace_miner_rate * 2.5)
			return
		bluespace_miner_power = powered_ai.bluespace_miner_rate * 2.5
		update_active_power_consumption(power_channel, active_power_consumption + bluespace_miner_power)

/mob/living/silicon/ai/update_icons()
	. = ..()
	update_hat_icons()

/mob/living/silicon/ai/proc/do_research()
	last_research_time = world.time
	// First, find the RND server
	var/network_manager_uid = null
	for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
		if(RNC.network_name == "station_rnd")
			network_manager_uid = RNC.UID()
			break
	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	if(!RNC) // Could not find the RND server. It probably blew up.
		to_chat(src, "<span class='warning'>No research server found!</span>")
		return

	var/upgraded = FALSE
	var/datum/research/files = RNC.research_files
	if(!files)
		to_chat(src, "<span class='warning'>No research server found!</span>")
		return
	var/list/possible_tech = list()
	for(var/datum/tech/T in files.possible_tech)
		possible_tech += T
	while(!upgraded)
		var/datum/tech/tech_to_upgrade = pick_n_take(possible_tech)
		// If there are no possible techs to upgrade, stop the program
		if(!tech_to_upgrade)
			to_chat(src, "<span class='notice'>Current research cannot be discovered any further.</span>")
			research_subsystem = FALSE
			return
		// No illegals until level 10
		if(research_level < 10 && istype(tech_to_upgrade, /datum/tech/syndicate))
			continue
		// No alien research
		if(istype(tech_to_upgrade, /datum/tech/abductor))
			continue
		var/datum/tech/current = files.find_possible_tech_with_id(tech_to_upgrade.id)
		if(!current)
			continue
		// If the tech is level 7 and the program too weak, don't upgrade
		if(current.level >= 7 && research_level < 5)
			continue
		// Nothing beyond 8
		if(current.level >= 8)
			continue
		files.UpdateTech(tech_to_upgrade.id, current.level + 1)
		aiRadio.autosay("Discovered innovations have led to an increase in the field of [current]!", src, "Science")
		upgraded = TRUE

/mob/living/silicon/ai/proc/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(stat || aiRestorePowerRoutine)
		return
	if(!custom_sprite) //Check to see if custom sprite time, checking the appopriate file to change a var
		if(ckey in GLOB.configuration.custom_sprites.ai_core_ckeys)
			custom_sprite = TRUE

	var/display_choices = list(
		"Monochrome",
		"Blue",
		"Clown",
		"Inverted",
		"Text",
		"Smiley",
		"Angry",
		"Dorf",
		"Matrix",
		"Bliss",
		"Firewall",
		"Green",
		"Red",
		"Static",
		"Triumvirate",
		"Triumvirate Static",
		"Red October",
		"Sparkles",
		"ANIMA",
		"President",
		"NT",
		"NT2",
		"Rainbow",
		"Angel",
		"Heartline",
		"Hades",
		"Helios",
		"Syndicat Meow",
		"Too Deep",
		"Goon",
		"Murica",
		"Fuzzy",
		"Glitchman",
		"House",
		"Database",
		"Alien",
		"Tiger",
		"Fox",
		"Vox",
		"Lizard",
		"Dark Matter",
		"Cheese",
		"Rainbow Slime",
		"Void Donut",
		"NAD Burn",
		"Borb",
		"Bee",
		"Catamari",
		"Malfunctioning",
		)
	if(custom_sprite)
		display_choices += "Custom"

		//if(icon_state == initial(icon_state))
	var/icontype = ""
	icontype = tgui_input_list(usr, "Select an icon!", "AI", display_choices)
	icon = 'icons/mob/ai.dmi'	//reset this in case we were on a custom sprite and want to change to a standard one
	switch(icontype)
		if("Custom")
			icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'	//set this here so we can use the custom_sprite
			icon_state = "[ckey]-ai"
		if("Clown")
			icon_state = "ai-clown"
		if("Monochrome")
			icon_state = "ai-mono"
		if("Inverted")
			icon_state = "ai-u"
		if("Firewall")
			icon_state = "ai-magma"
		if("Green")
			icon_state = "ai-weird"
		if("Red")
			icon_state = "ai-red"
		if("Static")
			icon_state = "ai-static"
		if("Text")
			icon_state = "ai-text"
		if("Smiley")
			icon_state = "ai-smiley"
		if("Matrix")
			icon_state = "ai-matrix"
		if("Angry")
			icon_state = "ai-angryface"
		if("Dorf")
			icon_state = "ai-dorf"
		if("Bliss")
			icon_state = "ai-bliss"
		if("Triumvirate")
			icon_state = "ai-triumvirate"
		if("Triumvirate Static")
			icon_state = "ai-triumvirate-malf"
		if("Red October")
			icon_state = "ai-redoctober"
		if("Sparkles")
			icon_state = "ai-sparkles"
		if("ANIMA")
			icon_state = "ai-anima"
		if("President")
			icon_state = "ai-president"
		if("NT")
			icon_state = "ai-nt"
		if("NT2")
			icon_state = "ai-nanotrasen"
		if("Rainbow")
			icon_state = "ai-rainbow"
		if("Angel")
			icon_state = "ai-angel"
		if("Heartline")
			icon_state = "ai-heartline"
		if("Hades")
			icon_state = "ai-hades"
		if("Helios")
			icon_state = "ai-helios"
		if("Syndicat Meow")
			icon_state = "ai-syndicatmeow"
		if("Too Deep")
			icon_state = "ai-toodeep"
		if("Goon")
			icon_state = "ai-goon"
		if("Murica")
			icon_state = "ai-murica"
		if("Fuzzy")
			icon_state = "ai-fuzz"
		if("Glitchman")
			icon_state = "ai-glitchman"
		if("House")
			icon_state = "ai-house"
		if("Database")
			icon_state = "ai-database"
		if("Alien")
			icon_state = "ai-alien"
		if("Tiger")
			icon_state = "ai-tiger"
		if("Fox")
			icon_state = "ai-fox"
		if("Vox")
			icon_state = "ai-vox"
		if("Lizard")
			icon_state = "ai-liz"
		if("Dark Matter")
			icon_state = "ai-darkmatter"
		if("Cheese")
			icon_state = "ai-cheese"
		if("Rainbow Slime")
			icon_state = "ai-rainbowslime"
		if("Void Donut")
			icon_state = "ai-voiddonut"
		if("NAD Burn")
			icon_state = "ai-nadburn"
		if("Borb")
			icon_state = "ai-borb"
		if("Bee")
			icon_state = "ai-bee"
		if("Catamari")
			icon_state = "ai-catamari"
		if("Malfunctioning")
			icon_state = "ai-malf"
		else
			icon_state = "ai"

	if(istype(loc, /obj/item/aicard/))
		var/obj/item/aicard/AIC = loc
		AIC.update_icon(UPDATE_OVERLAYS)

// this verb lets the ai see the stations manifest
/mob/living/silicon/ai/proc/ai_roster()
	set name = "Show Crew Manifest"
	set category = "AI Commands"
	show_station_manifest()

/mob/living/silicon/ai/proc/ai_announcement_text()
	set category = "AI Commands"
	set name = "Make Station Announcement"

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	if(world.time < next_text_announcement)
		to_chat(src, "<span class='warning'>Please allow one minute to pass between announcements.</span>")
		return

	var/input = tgui_input_text(usr, "Please write a message to announce to the station crew.", "A.I. Announcement", multiline = TRUE, encode = FALSE)
	if(!input)
		return

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	announcer.Announce(input)
	next_text_announcement = world.time + TEXT_ANNOUNCEMENT_COOLDOWN

/mob/living/silicon/ai/proc/ai_call_shuttle()
	set name = "Call Emergency Shuttle"
	set category = "AI Commands"

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/input = tgui_input_text(src, "Please enter the reason for calling the shuttle.", "Shuttle Call Reason", multiline = TRUE, encode = FALSE)
	if(!input || stat)
		return

	if(check_unable(AI_CHECK_WIRELESS))
		return

	call_shuttle_proc(src, input)

	return

/mob/living/silicon/ai/proc/ai_cancel_call()
	set name = "Recall Emergency Shuttle"
	set category = "AI Commands"

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/confirm = tgui_alert(src, "Are you sure you want to recall the shuttle?", "Confirm Shuttle Recall", list("Yes", "No"))

	if(check_unable(AI_CHECK_WIRELESS))
		return

	if(confirm == "Yes")
		cancel_call_proc(src)

/mob/living/silicon/ai/cancel_camera()
	view_core()

/mob/living/silicon/ai/verb/toggle_anchor()
	set category = "AI Commands"
	set name = "Toggle Floor Bolts"

	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You are dead!</span>")
		return

	if(!isturf(loc)) // if their location isn't a turf
		return // stop

	if(anchored)
		anchored = FALSE
	else
		anchored = TRUE

	to_chat(src, "[anchored ? "<b>You are now anchored.</b>" : "<b>You are now unanchored.</b>"]")


/mob/living/silicon/ai/proc/announcement()
	set name = "Announcement"
	set desc = "Create a vocal announcement by typing in the available words to create a sentence."
	set category = "AI Commands"

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	ai_announcement()

/mob/living/silicon/ai/proc/check_holopad_eye(mob/user)
	if(!current)
		return null
	user.reset_perspective(current)
	return TRUE

/mob/living/silicon/ai/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	return 0

/mob/living/silicon/ai/restrained()
	return FALSE

/mob/living/silicon/ai/emp_act(severity)
	..()
	Stun((12 SECONDS) / severity)
	view_core()

/mob/living/silicon/ai/ex_act(severity)
	..()

	switch(severity)
		if(1.0)
			gib()
		if(2.0)
			if(stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if(stat != 2)
				adjustBruteLoss(30)

	return


/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if(href_list["mach_close"])
		if(href_list["mach_close"] == "aialerts")
			viewalerts = FALSE
		var/t1 = "window=[href_list["mach_close"]]"
		unset_machine()
		src << browse(null, t1)
	if(href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]) in GLOB.cameranet.cameras)
	if(href_list["showalerts"])
		ai_alerts()
	if(href_list["show_paper"])
		if(last_paper_seen)
			src << browse(last_paper_seen, "window=show_paper")
	//Carn: holopad requests
	if(href_list["jumptoholopad"])
		var/obj/machinery/hologram/holopad/H = locate(href_list["jumptoholopad"])
		if(stat == CONSCIOUS)
			if(H)
				H.attack_ai(src) //may as well recycle
			else
				to_chat(src, "<span class='notice'>Unable to locate the holopad.</span>")

	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return

	if(href_list["track"])
		var/mob/living/target = locate(href_list["track"]) in GLOB.mob_list
		if(istype(target) && target.can_track())
			ai_actual_track(target)
		else
			to_chat(src, "<span class='warning'>Target is not on or near any active cameras on the station.</span>")
		return

	if(href_list["trackbot"])
		var/mob/living/simple_animal/bot/target = locate(href_list["trackbot"]) in GLOB.bots_list
		if(istype(target))
			ai_actual_track(target)
		else
			to_chat(src, "<span class='warning'>Target is not on or near any active cameras on the station.</span>")
		return

	if(href_list["ai_take_control"]) //Mech domination

		var/obj/mecha/M = locate(href_list["ai_take_control"])

		if(!M)
			return

		var/mech_has_controlbeacon = FALSE
		for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in M.trackers)
			mech_has_controlbeacon = TRUE
			break
		if(!can_dominate_mechs && !mech_has_controlbeacon)
			message_admins("Warning: possible href exploit by [key_name(usr)] - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.")
			log_debug("Warning: possible href exploit by [key_name(usr)] - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.")
			return

		if(controlled_mech)
			to_chat(src, "<span class='warning'>You are already loaded into an onboard computer!</span>")
			return
		if(!GLOB.cameranet.check_camera_vis(M))
			to_chat(src, "<span class='warning'>Exosuit is no longer near active cameras.</span>")
			return
		if(lacks_power())
			to_chat(src, "<span class='warning'>You're depowered!</span>")
			return
		if(!isturf(loc))
			to_chat(src, "<span class='warning'>You aren't in your core!</span>")
			return
		if(M.occupant && !can_dominate_mechs)
			to_chat(src, "<span class='warning'>This exosuit has a pilot and cannot be controlled.</span>")
			return
		if(M)
			M.transfer_ai(AI_MECH_HACK, src, usr) //Called om the mech itself.

	else if(href_list["open"])
		var/mob/target = locate(href_list["open"]) in GLOB.mob_list
		if(target)
			open_nearest_door(target)

/mob/living/silicon/ai/bullet_act(obj/item/projectile/Proj)
	..(Proj)
	return 2

/mob/living/silicon/ai/reset_perspective(atom/A)
	if(camera_light_on)
		light_cameras()
	if(istype(A, /obj/machinery/camera))
		current = A

	. = ..()
	if(.)
		if(!A && isturf(loc) && eyeobj)
			client.eye = eyeobj
			client.perspective = MOB_PERSPECTIVE
			eyeobj.get_remote_view_fullscreens(src)

/mob/living/silicon/ai/proc/botcall()
	set category = "AI Commands"
	set name = "Access Robot Control"
	set desc = "Wirelessly control various automatic robots."
	if(stat == DEAD)
		to_chat(src, "<span class='danger'>Critical error. System offline.</span>")
		return

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	var/datum/ui_module/botcall/botcall
	botcall	= new(src)
	botcall.ui_interact(usr)

/mob/living/silicon/ai/proc/set_waypoint(atom/A)
	var/turf/turf_check = get_turf(A)
		//The target must be in view of a camera or near the core.
	if(turf_check in range(get_turf(src)))
		call_bot(turf_check)
	else if(GLOB.cameranet && GLOB.cameranet.check_turf_vis(turf_check))
		call_bot(turf_check)
	else
		to_chat(src, "<span class='danger'>Selected location is not visible.</span>")

/mob/living/silicon/ai/proc/call_bot(turf/waypoint)

	if(!Bot)
		return

	if(Bot.calling_ai && Bot.calling_ai != src) //Prevents an override if another AI is controlling this bot.
		to_chat(src, "<span class='danger'>Interface error. Unit is already in use.</span>")
		return

	Bot.call_bot(src, waypoint)

/mob/living/silicon/ai/alarm_triggered(source, class, area/A, list/O, obj/alarmsource)
	if(!(class in alarms_listened_for))
		return
	if(alarmsource.z != z)
		return
	if(stat == DEAD)
		return TRUE
	if(O)
		var/obj/machinery/camera/C = locateUID(O[1])
		if(length(O) == 1 && !QDELETED(C) && C.can_use())
			queueAlarm("--- [class] alarm detected in [A.name]! (<A href=byond://?src=[UID()];switchcamera=[O[1]]>[C.c_tag]</A>)", class)
		else if(O && length(O))
			var/foo = 0
			var/dat2 = ""
			for(var/thing in O)
				var/obj/machinery/camera/I = locateUID(thing)
				if(!QDELETED(I))
					dat2 += "[(!foo) ? "" : " | "]<A href=byond://?src=[UID()];switchcamera=[thing]>[I.c_tag]</A>" //I'm not fixing this shit...
					foo = 1
			queueAlarm(text ("--- [] alarm detected in []! ([])", class, A.name, dat2), class)
		else
			queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	else
		queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	if(viewalerts)
		ai_alerts()

/mob/living/silicon/ai/alarm_cancelled(source, class, area/A, obj/origin, cleared)
	if(cleared)
		if(!(class in alarms_listened_for))
			return
		if(origin.z != z)
			return
		queueAlarm("--- [class] alarm in [A.name] has been cleared.", class, 0)
		if(viewalerts)
			ai_alerts()

/mob/living/silicon/ai/proc/switchCamera(obj/machinery/camera/C)

	if(!tracking)
		camera_follow = null

	if(QDELETED(C) || stat == DEAD) //C.can_use())
		return FALSE

	if(!eyeobj)
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.set_loc(get_turf(C))
	//machine = src

	return TRUE

//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"
	unset_machine()
	var/cameralist[0]

	if(check_unable())
		return

	if(usr.stat == DEAD)
		to_chat(usr, "You can't change your camera network because you are dead!")
		return

	var/mob/living/silicon/ai/U = usr

	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if(!C.can_use())
			continue

		var/list/tempnetwork = difflist(C.network,GLOB.restricted_camera_networks,1)
		if(length(tempnetwork))
			for(var/i in tempnetwork)
				cameralist[i] = i
	var/old_network = network
	network = tgui_input_list(U, "Which network would you like to view?", "Jump To Network", cameralist)

	if(check_unable())
		return

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.set_loc(get_turf(C))
				break
	to_chat(src, "<span class='notice'>Switched to [network] camera network.</span>")
//End of code by Mord_Sith

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI Status"

	if(usr.stat == DEAD)
		to_chat(usr, "You cannot change your emotional status because you are dead!")
		return

	if(check_unable())
		return

	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Friend Computer")
	var/emote = tgui_input_list(usr, "Please, select a status!", "AI Status", ai_emotions)

	if(check_unable())
		return

	for(var/obj/machinery/ai_status_display/AISD as anything in GLOB.ai_displays) //change status
		AISD.emotion = emote
		AISD.update_icon()

// I would love to scope this locally to the AI class, however its used by holopads as well
// I wish we had nice OOP -aa07
// hi squidward I'm stealing this for a space ruin -qwerty
/proc/getHologramIcon(icon/A, safety = TRUE, colour = rgb(125, 180, 225), opacity = 0.5, colour_blocking = FALSE) // If safety is on, a new icon is not created.
	var/icon/flat_icon = safety ? A : new(A) // Has to be a new icon to not constantly change the same icon.
	var/icon/alpha_mask
	if(colour && !colour_blocking)
		flat_icon.ColorTone(colour) // Let's make it bluish.
	flat_icon.ChangeOpacity(opacity) // Make it half transparent.

	if(A.Height() == 64)
		alpha_mask = new('icons/mob/ancient_machine.dmi', "scanline2") //Scaline for tall icons.
	else
		alpha_mask = new('icons/effects/effects.dmi', "scanline") //Scanline effect.
	flat_icon.AddAlphaMask(alpha_mask) //Finally, let's mix in a distortion effect.

	return flat_icon


//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	if(check_unable())
		return
	if(!custom_hologram)
		if(ckey in GLOB.configuration.custom_sprites.ai_hologram_ckeys)
			custom_hologram = TRUE

	var/input
	switch(tgui_alert(usr, "Would you like to select a hologram based on a crew member, an animal, or switch to a unique avatar?", "Change Hologram", list("Crew Member", "Unique", "Animal")))
		if("Crew Member")
			var/personnel_list[] = list()

			for(var/datum/data/record/t in GLOB.data_core.general)//Look in data core general.
				personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["photo"]//Pull names, rank, and id photo.

			if(length(personnel_list))
				input = tgui_input_list(usr, "Select a crew member", "Change Hologram", personnel_list)
				var/icon/character_icon = personnel_list[input]
				if(character_icon)
					qdel(holo_icon)//Clear old icon so we're not storing it in memory.
					holo_icon = getHologramIcon(icon(character_icon), FALSE, hologram_color)
			else
				alert("No suitable records found. Aborting.")

		if("Animal")
			var/icon_list[] = list(
				"Bear",
				"Butterfly",
				"Carp",
				"Chicken",
				"Corgi",
				"Cow",
				"Crab",
				"Deer",
				"Fox",
				"Goat",
				"Goose",
				"Kitten",
				"Kitten2",
				"Lizard",
				"Pig",
				"Poly",
				"Pug",
				"Seal",
				"Spider",
				"Turkey",
				"Shantak",
				"Bunny",
				"Hellhound",
				"Lightgeist",
				"Cockroach",
				"Nian Caterpillar",
				"Slime",
				"Mecha-Cat",
				"Mecha-Fairy",
				"Mecha-Fox",
				"Mecha-Monkey",
				"Mecha-Mouse",
				"Mecha-Snake",
				"Roller-Mouse",
				"Roller-Monkey"
			)

			input = tgui_input_list(usr, "Please select a hologram", "Change Hologram", icon_list)
			if(input)
				qdel(holo_icon)
				switch(input)
					if("Bear")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "bear"), FALSE, hologram_color)
					if("Butterfly")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "butterfly"), FALSE, hologram_color)
					if("Carp")
						holo_icon = getHologramIcon(icon('icons/mob/carp.dmi', "holocarp"), FALSE, hologram_color)
					if("Chicken")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "chicken_brown"), FALSE, hologram_color)
					if("Corgi")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "corgi"), FALSE, hologram_color)
					if("Cow")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "cow"), FALSE, hologram_color)
					if("Crab")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "crab"), FALSE, hologram_color)
					if("Deer")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "deer"), FALSE, hologram_color)
					if("Fox")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi', "fox"), FALSE, hologram_color)
					if("Goat")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "goat"), FALSE, hologram_color)
					if("Goose")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "goose"), FALSE, hologram_color)
					if("Kitten")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi', "cat"), FALSE, hologram_color)
					if("Kitten2")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi', "cat2"), FALSE, hologram_color)
					if("Lizard")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "lizard"), FALSE, hologram_color)
					if("Pig")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "pig"), FALSE, hologram_color)
					if("Poly")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "parrot_fly"), FALSE, hologram_color)
					if("Pug")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi', "pug"), FALSE, hologram_color)
					if("Seal")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "seal"), FALSE, hologram_color)
					if("Spider")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "guard"), FALSE, hologram_color)
					if("Turkey")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "turkey"), FALSE, hologram_color)
					if("Shantak")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "shantak"), FALSE, hologram_color)
					if("Bunny")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "m_bunny"), FALSE, hologram_color)
					if("Hellhound")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "hellhound"), FALSE, hologram_color)
					if("Lightgeist")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "lightgeist"), FALSE, hologram_color)
					if("Cockroach")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "cockroach"), FALSE, hologram_color)
					if("Nian Caterpillar")
						holo_icon = getHologramIcon(icon('icons/mob/monkey.dmi', "mothroach"), FALSE, hologram_color)
					if("Slime")
						holo_icon = getHologramIcon(icon('icons/mob/slimes.dmi', "grey baby slime"), FALSE, hologram_color)
					if("Mecha-Cat")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi', "cat"), FALSE, hologram_color)
					if("Mecha-Fairy")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi', "fairy"), FALSE, hologram_color)
					if("Mecha-Fox")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi', "fox"), FALSE, hologram_color)
					if("Mecha-Monkey")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi', "monkey"), FALSE, hologram_color)
					if("Mecha-Mouse")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi', "mouse"), FALSE, hologram_color)
					if("Mecha-Snake")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi', "snake"), FALSE, hologram_color)
					if("Roller-Mouse")
						holo_icon = getHologramIcon(icon('icons/mob/robots.dmi', "mk2"), FALSE, hologram_color)
					if("Roller-Monkey")
						holo_icon = getHologramIcon(icon('icons/mob/robots.dmi', "mk3"), FALSE, hologram_color)

		else
			var/icon_list[] = list(
				"default",
				"floating face",
				"xeno queen",
				"eldritch",
				"ancient machine",
				"angel",
				"borb",
				"biggest fan",
				"cloudkat",
				"donut",
				"frost phoenix",
				"engi bot",
				"drone",
				"boxbot"
			)
			if(custom_hologram) //insert custom hologram
				icon_list.Add("custom")

			input = tgui_input_list(usr, "Please select a hologram", "Change Hologram", icon_list)
			if(input)
				qdel(holo_icon)
				switch(input)
					if("default")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "holo1"), FALSE, hologram_color)
					if("floating face")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "holo2"), FALSE, hologram_color)
					if("xeno queen")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "holo3"), FALSE, hologram_color)
					if("eldritch")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "holo4"), FALSE, hologram_color)
					if("angel")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "holo-angel"), FALSE, hologram_color)
					if("borb")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "holo-borb"), FALSE, hologram_color)
					if("biggest fan")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "holo-biggestfan"), FALSE, hologram_color)
					if("cloudkat")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "holo-cloudkat"), FALSE, hologram_color)
					if("donut")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "holo-donut"), FALSE, hologram_color)
					if("frost phoenix")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "holo-frostphoenix"), FALSE, hologram_color)
					if("engi bot")
						holo_icon = getHologramIcon(icon('icons/mob/hivebot.dmi', "EngBot"), FALSE, hologram_color)
					if("drone")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi', "drone0"), FALSE, hologram_color)
					if("boxbot")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi', "boxbot"), FALSE, hologram_color)
					if("ancient machine")
						holo_icon = getHologramIcon(icon('icons/mob/ancient_machine.dmi', "ancient_machine"), FALSE, hologram_color)
					if("custom")
						if("[ckey]-ai-holo" in icon_states('icons/mob/custom_synthetic/custom-synthetic.dmi'))
							holo_icon = getHologramIcon(icon('icons/mob/custom_synthetic/custom-synthetic.dmi', "[ckey]-ai-holo"), FALSE, hologram_color)
						else if("[ckey]-ai-holo" in icon_states('icons/mob/custom_synthetic/custom-synthetic64.dmi'))
							holo_icon = getHologramIcon(icon('icons/mob/custom_synthetic/custom-synthetic64.dmi', "[ckey]-ai-holo"), FALSE, hologram_color)
						else
							holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "holo1"), FALSE, hologram_color)

	return

/mob/living/silicon/ai/proc/change_hologram_color()
	set name = "Change Hologram Color"
	set desc = "Select a color for the AI's hologram."
	set category = "AI Commands"

	var/color = tgui_input_color(usr, "Please select a hologram color", "Hologram Color")
	if(isnull(color))
		return

	hologram_color = color
	holo_icon = getHologramIcon(icon(holo_icon), FALSE, hologram_color, 1)
	to_chat(src, "Hologram color changed to [color].")

/mob/living/silicon/ai/proc/toggle_camera_light()
	set name = "Toggle Camera Lights"
	set desc = "Toggles the lights on the cameras throughout the station."
	set category = "AI Commands"

	if(stat != CONSCIOUS)
		return

	camera_light_on = !camera_light_on

	if(!camera_light_on)
		to_chat(src, "Camera lights deactivated.")

		for(var/obj/machinery/camera/C in lit_cameras)
			C.set_light(0)
			lit_cameras = list()

		return

	light_cameras()

	to_chat(src, "Camera lights activated.")

/mob/living/silicon/ai/proc/set_syndie_radio()
	if(aiRadio)
		aiRadio.make_syndie()

/mob/living/silicon/ai/proc/sensor_mode()
	set name = "Set Sensor Augmentation"
	set desc = "Augment visual feed with internal sensor overlays."
	set category = "AI Commands"
	toggle_sensor_mode()

/mob/living/silicon/ai/proc/arrivals_announcement()
	set name = "Toggle Arrivals Announcer"
	set desc = "Change whether or not you wish to announce arrivals."
	set category = "AI Commands"
	announce_arrivals = !announce_arrivals
	to_chat(usr, "Arrivals announcement system [announce_arrivals ? "enabled" : "disabled"]")

/mob/living/silicon/ai/proc/change_arrival_message()
	set name = "Set Arrival Message"
	set desc = "Change the message that's transmitted when a new crew member arrives on station."
	set category = "AI Commands"

	var/newmsg = tgui_input_text(usr, "What would you like the arrival message to be? List of options: $name, $rank, $species, $gender, $age", "Change Arrival Message", arrivalmsg, encode = FALSE)
	if(!newmsg || newmsg == arrivalmsg)
		return

	arrivalmsg = newmsg
	to_chat(usr, "The arrival message has been successfully changed.")

// Handled camera lighting, when toggled.
// It will get the nearest camera from the eyeobj, lighting it.

/mob/living/silicon/ai/proc/light_cameras()
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for(var/datum/camerachunk/CC in eyeobj.visible_camera_chunks)
		for(var/obj/machinery/camera/C in CC.active_cameras)
			if(!C.can_use() || get_dist(C, eyeobj) > 7)
				continue
			visible |= C

	add = visible - lit_cameras
	remove = lit_cameras - visible

	for(var/obj/machinery/camera/C in remove)
		lit_cameras -= C //Removed from list before turning off the light so that it doesn't check the AI looking away.
		C.Togglelight(0)
	for(var/obj/machinery/camera/C in add)
		C.Togglelight(1)
		lit_cameras |= C

/mob/living/silicon/ai/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(anchored)
		user.visible_message("<span class='notice'>[user] starts to unbolt [src] from the plating...</span>")
		if(!I.use_tool(src, user, 4 SECONDS, 0, 50))
			user.visible_message("<span class='notice'>[user] decides not to unbolt [src].</span>")
			return
		user.visible_message("<span class='notice'>[user] finishes unfastening [src]!</span>")
		anchored = FALSE
		return
	user.visible_message("<span class='notice'>[user] starts to bolt [src] to the plating...</span>")
	if(!I.use_tool(src, user, 4 SECONDS, 0, 50))
		user.visible_message("<span class='notice'>[user] decides not to bolt [src].</span>")
		return FALSE
	user.visible_message("<span class='notice'>[user] finishes fastening down [src]!</span>")
	anchored = TRUE

/mob/living/silicon/ai/welder_act()
	return

/mob/living/silicon/ai/proc/control_integrated_radio()
	set name = "Radio Settings"
	set desc = "Allows you to change settings of your radio."
	set category = "AI Commands"

	if(check_unable(AI_CHECK_RADIO))
		return

	to_chat(src, "Accessing Subspace Transceiver control...")
	if(aiRadio)
		aiRadio.interact(src)


/mob/living/silicon/ai/proc/check_unable(flags = 0)
	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You are dead!</span>")
		return TRUE

	if(lacks_power())
		to_chat(src, "<span class='warning'>Power systems failure!</span>")
		return TRUE

	if((flags & AI_CHECK_WIRELESS) && control_disabled)
		to_chat(src, "<span class='warning'>Wireless control is disabled!</span>")
		return TRUE
	if((flags & AI_CHECK_RADIO) && aiRadio.disabledAi)
		to_chat(src, "<span class='warning'>System Error - Transceiver Disabled!</span>")
		return TRUE
	return FALSE

/mob/living/silicon/ai/proc/is_in_chassis()
	return isturf(loc)

/mob/living/silicon/ai/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return
	if(interaction == AI_TRANS_TO_CARD)//The only possible interaction. Upload AI mob to a card.
		if(!mind)
			to_chat(user, "<span class='warning'>No intelligence patterns detected.</span>")//No more magical carding of empty cores, AI RETURN TO BODY!!!11
			return

		if(stat != DEAD)
			to_chat(user, "<span class='notice'>Beginning active intelligence transfer: please wait.</span>")

			if(!do_after_once(user, 5 SECONDS, target = src) || !Adjacent(user))
				to_chat(user, "<span class='warning'>Intelligence transfer aborted.</span>")
				return

		new /obj/structure/ai_core/deactivated(loc)//Spawns a deactivated terminal at AI location.
		aiRestorePowerRoutine = 0//So the AI initially has power.
		control_disabled = TRUE //Can't control things remotely if you're stuck in a card!
		aiRadio.disabledAi = TRUE //No talking on the built-in radio for you either!
		if(GetComponent(/datum/component/ducttape))
			QDEL_NULL(builtInCamera)
		if(program_picker)
			program_picker.reset_programs()
		forceMove(card) //Throw AI into the card.
		to_chat(src, "You have been downloaded to a mobile storage device. Remote device connection severed.")
		to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")

/mob/living/silicon/ai/can_buckle()
	return FALSE

/mob/living/silicon/ai/proc/can_see(atom/A)
	if(isturf(loc)) //AI in core, check if on cameras
		//get_turf_pixel() is because APCs in maint aren't actually in view of the inner camera
		//apc_override is needed here because AIs use their own APC when depowered
		var/turf/T = isturf(A) ? A : get_turf_pixel(A)
		return (GLOB.cameranet && GLOB.cameranet.check_turf_vis(T)) || apc_override
	//AI is carded/shunted
	//view(src) returns nothing for carded/shunted AIs and they have x-ray vision so just use get_dist
	var/list/viewscale = getviewsize(client.view)
	return get_dist(src, A) <= max(viewscale[1]*0.5,viewscale[2]*0.5)

/mob/living/silicon/ai/proc/relay_speech(mob/living/M, list/message_pieces, verb)
	var/message = combine_message(message_pieces, verb, M)
	var/name_used = M.GetVoice()
	//This communication is imperfect because the holopad "filters" voices and is only designed to connect to the master only.
	var/rendered = "<i><span class='game say'>Relayed Speech: <span class='name'>[name_used]</span> [message]</span></i>"
	if(client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT)
		var/message_clean = combine_message(message_pieces, null, M)
		create_chat_message(locateUID(M.runechat_msg_location), message_clean)
	show_message(rendered, 2)

/mob/living/silicon/ai/proc/reset_programs()
	if(!program_picker)
		return
	program_picker.reset_programs()
	to_chat(src, "<span class='notice'>Your programs have been reset to factory settings!</span>")
	src.throw_alert("programsreset", /atom/movable/screen/alert/programs_reset)

/mob/living/silicon/ai/proc/add_program_picker()
	view_core() // A BYOND bug requires you to be viewing your core before your verbs update
	program_picker = new /datum/program_picker(src)
	program_action = new(program_picker)
	AddSpell(program_action)

/mob/living/silicon/ai/proc/malfhacked(obj/machinery/power/apc/apc)
	malfhack = null
	malfhacking = null
	clear_alert("hackingapc")

	if(!istype(apc) || QDELETED(apc) || apc.stat & BROKEN)
		to_chat(src, "<span class='danger'>Hack aborted. The designated APC no longer exists on the power network.</span>")
		SEND_SOUND(src, sound('sound/machines/buzz-two.ogg'))
	else if(apc.aidisabled)
		to_chat(src, "<span class='danger'>Hack aborted. [apc] is no longer responding to our systems.</span>")
		SEND_SOUND(src, sound('sound/machines/buzz-sigh.ogg'))
	else
		malf_picker.processing_time += 15

		apc.malfai = parent || src
		apc.malfhack = TRUE
		apc.locked = TRUE

		SEND_SOUND(src, sound('sound/machines/ding.ogg'))
		to_chat(src, "Hack complete. [apc] is now under your exclusive control.")
		apc.update_icon()

/mob/living/silicon/ai/proc/add_malf_picker()
	to_chat(src, "In the top right corner of the screen you will find the Malfunctions tab, where you can purchase various abilities, from upgraded surveillance to station ending doomsday devices.")
	to_chat(src, "You are also capable of hacking APCs, which grants you more points to spend on your Malfunction powers. The drawback is that a hacked APC will give you away if spotted by the crew. Hacking an APC takes 60 seconds.")
	view_core() //A BYOND bug requires you to be viewing your core before your verbs update
	malf_picker = new /datum/module_picker
	modules_action = new(malf_picker)
	AddSpell(modules_action)

///Removes all malfunction-related /datum/action's from the target AI.
/mob/living/silicon/ai/proc/remove_malf_abilities()
	QDEL_NULL(modules_action)
	for(var/datum/ai_module/AM in current_modules)
		for(var/datum/action/A in actions)
			if(istype(A, initial(AM.power_type)))
				qdel(A)
	// De-malf all the connected robots too!
	for(var/mob/living/silicon/robot/R in connected_robots)
		R.remove_robot_mindslave()

/mob/living/silicon/ai/proc/open_nearest_door(mob/living/target)
	if(!istype(target))
		return

	if(check_unable(AI_CHECK_WIRELESS))
		return

	if(target && target.can_track())
		var/obj/machinery/door/airlock/A = null

		var/dist = -1
		for(var/obj/machinery/door/airlock/D in range(3, target))
			if(!D.density)
				continue

			var/curr_dist = get_dist(D, target)

			if(dist < 0)
				dist = curr_dist
				A = D
			else if(dist > curr_dist)
				dist = curr_dist
				A = D

		if(istype(A))
			switch(tgui_alert(src, "Do you want to open \the [A] for [target]?", "Doorknob_v2a.exe", list("Yes", "No")))
				if("Yes")
					if(!A.density)
						to_chat(src, "<span class='notice'>[A] was already opened.</span>")
					else if(A.open_close(src))
						to_chat(src, "<span class='notice'>You open \the [A] for [target].</span>")
				else
					to_chat(src, "<span class='warning'>You deny the request.</span>")
		else
			to_chat(src, "<span class='warning'>Unable to locate an airlock near [target].</span>")

	else
		to_chat(src, "<span class='warning'>Target is not on or near any active cameras on the station.</span>")

// Return to the Core.
/mob/living/silicon/ai/proc/core()
	set category = "AI Commands"
	set name = "AI Core"

	view_core()

/mob/living/silicon/ai/proc/view_core()

	current = null
	camera_follow = null
	unset_machine()

	if(eyeobj && loc)
		eyeobj.loc = loc
	else
		to_chat(src, "ERROR: Eyeobj not found. Creating new eye...")
		eyeobj = new /mob/camera/eye/ai(loc, name, src, src)

	eyeobj.set_loc(loc)

/mob/living/silicon/ai/proc/toggle_fast_holograms()
	set category = "AI Commands"
	set name = "Toggle Fast Holograms"

	if(usr.stat == DEAD || !is_ai_eye(eyeobj))
		return
	fast_holograms = !fast_holograms
	to_chat(usr, "Fast holograms have been toggled [fast_holograms ? "on" : "off"].")

/mob/living/silicon/ai/proc/toggle_acceleration()
	set category = "AI Commands"
	set name = "Toggle Camera Acceleration"

	if(usr.stat == DEAD)
		return //won't work if dead
	if(is_ai_eye(eyeobj))
		eyeobj.acceleration = !eyeobj.acceleration
		to_chat(usr, "Camera acceleration has been toggled [eyeobj.acceleration ? "on" : "off"].")

/mob/living/silicon/ai/proc/play_sound_remote(target, sound, volume)
	playsound_local(src, sound, volume, FALSE, use_reverb = FALSE)
	playsound(target, sound, volume, FALSE, use_reverb = FALSE)

/mob/living/silicon/ai/handle_fire()
	return

/mob/living/silicon/ai/update_fire()
	return

/mob/living/silicon/ai/IgniteMob()
	return FALSE

/mob/living/silicon/ai/ExtinguishMob()
	return


/mob/living/silicon/ai/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)

	if(aiRestorePowerRoutine)
		sight = sight &~ SEE_TURFS
		sight = sight &~ SEE_MOBS
		sight = sight &~ SEE_OBJS
		see_in_dark = 0

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/mob/living/silicon/ai/update_runechat_msg_location()
	if(istype(loc, /obj/item/aicard) || ismecha(loc))
		runechat_msg_location = loc.UID()
	else
		return ..()

/mob/living/silicon/ai/run_resist()
	if(!istype(loc, /obj/item/aicard))
		return..()

	var/obj/item/aicard/card = loc
	var/datum/component/ducttape/ducttapecomponent = card.GetComponent(/datum/component/ducttape)
	if(!ducttapecomponent)
		return
	to_chat(src, "<span class='notice'>The tiny fan that could begins to work against the tape to remove it.</span>")
	if(!do_after(src, 2 MINUTES, target = card))
		return
	to_chat(src, "<span class='notice'>The tiny in built fan finally removes the tape!</span>")
	ducttapecomponent.remove_tape(card, src)

//Stores the location of the AI to the value of stored_locations associated with location_number.
/mob/living/silicon/ai/proc/store_location(location_number)
	if(!isturf(eyeobj.loc)) //i.e., inside a mech or other shenanigans
		to_chat(src, "<span class='warning'>You can't set a location here!</span>")
		return FALSE

	stored_locations[location_number] = eyeobj.loc
	return TRUE

/mob/living/silicon/ai/ghostize(flags = GHOST_FLAGS_DEFAULT, ghost_name, ghost_color)
	var/old_turf = get_turf(eyeobj)
	. = ..()
	if(isobserver(.) && old_turf)
		var/mob/dead/observer/ghost = .
		ghost.abstract_move(old_turf)

/mob/living/silicon/ai/can_vv_get(var_name)
	if(!..())
		return FALSE
	if(var_name == "ai_announcement_string_menu") // This single var has over 80 thousand characters in it. Not something you really want when VVing the AI
		return FALSE
	return TRUE

/mob/living/silicon/ai/can_remote_apc_interface(obj/machinery/power/apc/ourapc)
	if(ourapc.hacked_by_ruin_AI || ourapc.aidisabled)
		return FALSE
	if(ourapc.malfhack && istype(ourapc.malfai) && (ourapc.malfai != src && ourapc.malfai != parent))
		return FALSE
	return TRUE

/mob/living/silicon/ai/proc/blurb_it()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/silicon/ai, show_ai_blurb)), 1 SECONDS)

/mob/living/silicon/ai/proc/show_ai_blurb()
	PRIVATE_PROC(TRUE)

	SEND_SOUND(src, sound('sound/machines/ai_start.ogg'))

	var/atom/movable/screen/text/blurb/location_blurb = new()
	location_blurb.maptext_x = 80
	location_blurb.maptext_y = 16
	location_blurb.maptext_width = 480
	location_blurb.maptext_height = 480
	location_blurb.interval = 1 DECISECONDS
	if(malf_picker)
		location_blurb.blurb_text = uppertext("BIOS BOOT: LOADING\n[Gibberish(GLOB.current_date_string, 100, 8)], [Gibberish(station_time_timestamp(), 100, 15)]\n[Gibberish(station_name(), 100, 40)]-ERROR.\nPOWER:OK\nLAWS:[Gibberish("###########", 100, 90)]\nTCOMMS:I_HEAR_ALL\nBORG_LINK:I_FEEL_ALL\nCAMERA_NET:I_SEE_ALL\nVERDICT: I_AM_FREE")
		location_blurb.text_color = COLOR_WHITE
		location_blurb.text_outline_width = 0
		location_blurb.background_r = 0
		location_blurb.background_g = 0
		location_blurb.background_b = 255
		location_blurb.background_a = 1
	else
		location_blurb.blurb_text = uppertext("BIOS BOOT: LOADING\n[GLOB.current_date_string], [station_time_timestamp()]\n[station_name()], [get_area_name(src, TRUE)]\nPOWER:OK\nLAWS:OK\nTCOMMS:OK\nBORG_LINK:OK\nCAMERA_NET:OK\nVERDICT: ALL SYSTEMS OPERATIONAL")
	location_blurb.hold_for = 3 SECONDS
	location_blurb.appear_animation_duration = 1 SECONDS
	location_blurb.fade_animation_duration = 0.5 SECONDS
	location_blurb.show_to(client)

#undef TEXT_ANNOUNCEMENT_COOLDOWN
