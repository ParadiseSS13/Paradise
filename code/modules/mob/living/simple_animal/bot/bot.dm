//Defines for bots are now found in code\__DEFINES\bots.dm
// Emotes for bots are shared with silicon, and are found at code/modules/mob/living/silicon/emotes.dm

// AI (i.e. game AI, not the AI player) controlled bots
/mob/living/simple_animal/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER - 0.1
	mob_biotypes = MOB_ROBOTIC
	light_range = 3
	light_power = 0.5
	light_color = "#f3ffbb"
	stop_automated_movement = TRUE
	wander = FALSE
	healable = FALSE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	has_unlimited_silicon_privilege = TRUE
	sentience_type = SENTIENCE_ARTIFICIAL
	status_flags = 0 						// No default canpush
	hud_type = /datum/hud/bot

	speak_emote = list("states")
	friendly = "boops"
	bubble_icon = "machine"
	faction = list("neutral", "silicon")

	var/list/users = list() 				// For dialog updates
	var/window_id = "bot_control"
	var/window_name = "Protobot 1.0" 		// Popup title
	var/window_width = 0 					// 0 for default size
	var/window_height = 0
	var/obj/item/paicard/paicard 			// Inserted pai card.
	var/allow_pai = TRUE					// Are we even allowed to insert a pai card.

	/// storing bot_name prior to pai and restoring it. MULEBOT uses this for suffix system
	var/bot_name

	var/disabling_timer_id = null
	var/list/player_access = list()
	var/emagged = FALSE
	/// The ID card that the bot "holds"
	var/obj/item/card/id/access_card
	var/list/prev_access = list()
	var/on = TRUE
	/// Maint panel
	var/open = FALSE
	var/locked = TRUE
	/// Used to differentiate between being hacked by silicons and emagged by humans.
	var/hacked = FALSE
	/// Is currently hijacked by a pulse demon?
	var/hijacked = FALSE
	/// Custom text returned to a silicon upon hacking a bot.
	var/text_hack = ""
	/// Text shown when resetting a bots hacked status to normal.
	var/text_dehack = ""
	/// Shown when a silicon tries to reset a bot emagged with the emag item, which cannot be reset.
	var/text_dehack_fail = ""
	/// What the bot will display to the HUD user.
	var/declare_message = ""
	/// Used by some bots for tracking failures to reach their target.
	var/frustration = 0
	/// The speed at which the bot moves, or the number of times it moves per process() tick.
	var/base_speed = 2
	/// The end point of a bot's path, or the target location.
	var/turf/ai_waypoint
	/// List of turfs through which a bot 'steps' to reach the waypoint
	var/list/path = list()
	var/pathset = FALSE
	/// List of unreachable targets for an ignore-list enabled bot to ignore.
	var/list/ignore_list = list()
	/// List of jobs claimed by bot
	var/static/list/ignore_job = list()
	/// Standardizes the vars that indicate the bot is busy with its function.
	var/mode = BOT_IDLE
	/// Number of times the bot tried and failed to move.
	var/tries = 0
	/// If enabled, the AI cannot *Remotely* control a bot. It can still control it through cameras.
	var/remote_disabled = FALSE
	/// Links a bot to the AI calling it.
	var/mob/living/silicon/ai/calling_ai
	/// The bot's radio, for speaking to people.
	var/obj/item/radio/Radio
	/// Which channels can the bot listen to
	var/list/radio_config = null
	/// The bot's default radio channel
	var/radio_channel = "Common"
	/// Set to make bot automatically patrol
	var/auto_patrol = FALSE
	/// This is turf to navigate to (location of beacon)
	var/turf/patrol_target
	/// The turf of a user summoning a bot.
	var/turf/summon_target
	/// Pending new destination (waiting for beacon response)
	var/new_destination
	/// Destination description tag
	var/destination
	/// The next destination in the patrol route
	var/next_destination
	/// This ticks up every automated action, at 300 we clean the ignore list
	var/ignore_list_cleanup_timer = 1
	var/robot_arm = /obj/item/robot_parts/r_arm

	/// Number of times retried a blocked path
	var/blockcount = 0
	/// Count of pticks awaiting a beacon response
	var/awaiting_beacon	= 0

	/// The nearest beacon's tag
	var/nearest_beacon
	/// The nearest beacon's location
	var/turf/nearest_beacon_loc

	///The type of bot it is.
	var/model = ""
	/// Bot Purpose under Show Laws
	var/bot_purpose = "improve the station to the best of your ability"
	/// Bot control frequency
	var/control_freq = BOT_FREQ

	/// The radio filter the bot uses to identify itself on the network.
	var/bot_filter
	/// Type of bot, one of the *_BOT defines.
	var/bot_type
	/// The type of data HUD the bot uses. Diagnostic by default.
	var/data_hud_type = DATA_HUD_DIAGNOSTIC_BASIC
	// This holds text for what the bot is mode doing, reported on the remote bot control interface.
	var/list/mode_name = list("In Pursuit","Preparing to Arrest", "Arresting", \
	"Beginning Patrol", "Patrolling", "Summoned by PDA", \
	"Cleaning", "Repairing", "Proceeding to work site", "Healing", \
	"Responding", "Navigating to Delivery Location", "Navigating to Home", \
	"Waiting for clear path", "Calculating navigation path", "Pinging beacon network", "Unable to reach destination")

	var/reset_access_timer_id

	/// List of access values you can have to access the bot. Consider this as req_one_access
	var/list/req_access = list()

	hud_possible = list(DIAG_STAT_HUD, DIAG_BOT_HUD, DIAG_HUD) // Diagnostic HUD views

	/// Storing last chased target known location
	var/turf/last_target_location
	/// Will be true if we lost target we were chasing
	var/lost_target = FALSE

	/// Cooldown for when to cleanup the ignore list.
	COOLDOWN_DECLARE(ignore_list_cleanup_cd)

/mob/living/simple_animal/bot/Initialize(mapload)
	. = ..()
	GLOB.bots_list += src
	icon_living = icon_state
	icon_dead = icon_state
	access_card = new /obj/item/card/id(src)
	// This access is so bots can be immediately set to patrol and leave Robotics, instead of having to be let out first.
	access_card.access += ACCESS_ROBOTICS
	set_custom_texts()
	Radio = new/obj/item/radio/headset/bot(src)
	Radio.follow_target = src
	add_language("Galactic Common", 1)
	add_language("Sol Common", 1)
	add_language("Tradeband", 1)
	add_language("Gutter", 1)
	add_language("Trinary", 1)
	default_language = GLOB.all_languages["Galactic Common"]

	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
		permanent_huds |= diag_hud

	diag_hud_set_bothealth()
	diag_hud_set_botstat()
	diag_hud_set_botmode()

	REMOVE_TRAIT(src, TRAIT_CAN_STRIP, TRAIT_GENERIC)
	RemoveElement(/datum/element/strippable)

/mob/living/simple_animal/bot/Destroy()
	if(paicard)
		ejectpai()
	set_path(null)

	var/datum/atom_hud/data_hud = GLOB.huds[data_hud_type]
	if(data_hud)
		data_hud.remove_hud_from(src)

	GLOB.bots_list -= src
	QDEL_NULL(path)
	QDEL_NULL(Radio)
	QDEL_NULL(access_card)

	if(reset_access_timer_id)
		deltimer(reset_access_timer_id)
		reset_access_timer_id = null

	ignore_list = null
	return ..()

/obj/item/radio/headset/bot
	requires_tcomms = FALSE

/obj/item/radio/headset/bot/recalculateChannels()
	var/mob/living/simple_animal/bot/B = loc
	if(istype(B))
		if(!B.radio_config)
			B.radio_config = list("AI Private" = 1)
			if(!(B.radio_channel in B.radio_config)) // Put it first so it's the :h channel
				B.radio_config.Insert(1, "[B.radio_channel]")
				B.radio_config["[B.radio_channel]"] = 1
		config(B.radio_config)

/mob/living/simple_animal/bot/proc/try_chasing_target(mob/target)
	if(target in view(12, src))
		if(lost_target)
			frustration = 0
			lost_target = FALSE
		last_target_location = get_turf(target)
		var/dist = get_dist(src, target)
		GLOB.move_manager.move_to(src, target, 1, 4)
		if(get_dist(src, target) >= dist)
			frustration++
		return

	if(!lost_target)
		GLOB.move_manager.stop_looping(src)
		lost_target = TRUE
		frustration = 0

	if(get_turf(src) == last_target_location)
		frustration += 2
		return

	if(!bot_move(last_target_location, move_speed = 6))
		var/last_target_pos_path = get_path_to(src, last_target_location, access = access_card.access, skip_first = TRUE)
		if(length(last_target_pos_path) == 0)
			frustration = 10
			return
		set_path(last_target_pos_path)
		bot_move(last_target_location, move_speed = 6)
	frustration++

/// Setter for mode, so it's all tracable to one place.
/mob/living/simple_animal/bot/proc/set_mode(new_mode)
	mode = new_mode

/mob/living/simple_animal/bot/proc/get_mode()
	if(client) // Player bots do not have modes, thus the override. Also an easy way for PDA users/AI to know when a bot is a player.
		if(paicard)
			return "<b>pAI Controlled</b>"
		else
			return "<b>Autonomous</b>"
	else if(!on)
		return "<span class='bad'>Inactive</span>"
	else if(hijacked)
		return "<span class='bad'>ERROR</span>"
	else if(!mode)
		return "<span class='good'>Idle</span>"
	else
		return "<span class='average'>[mode_name[mode]]</span>"

/mob/living/simple_animal/bot/proc/turn_on()
	if(disabling_timer_id)
		return FALSE
	if(stat)
		return FALSE
	on = TRUE
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "depowered")
	set_light(initial(light_range))
	update_icon()
	update_controls()
	diag_hud_set_botstat()
	return TRUE

/mob/living/simple_animal/bot/proc/turn_off()
	on = FALSE
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, "depowered")
	set_light(0)
	bot_reset() // Resets an AI's call, should it exist.
	update_icon()
	update_controls()

/mob/living/simple_animal/bot/med_hud_set_health()
	return // We use a different hud

/mob/living/simple_animal/bot/med_hud_set_status()
	return // We use a different hud

/mob/living/simple_animal/bot/mob_negates_gravity()
	return anchored

/mob/living/simple_animal/bot/death(gibbed)
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE
	explode()

/mob/living/simple_animal/bot/proc/explode()
	qdel(src)

/mob/living/simple_animal/bot/emag_act(mob/user)
	if(locked) // First emag application unlocks the bot's interface. Apply a screwdriver to use the emag again.
		locked = FALSE
		to_chat(user, "<span class='notice'>You bypass [src]'s controls.</span>")
		return TRUE

	if(!locked && open) //Bot panel is unlocked by ID or emag, and the panel is screwed open. Ready for emagging.
		emagged = TRUE
		remote_disabled = TRUE // Manually emagging the bot locks out the AI built in panel.
		locked = TRUE // Access denied forever!
		bot_reset()
		turn_on() // The bot automatically turns on when emagged, unless recently hit with EMP.
		to_chat(src, "<span class='userdanger'>(#$*#$^^( OVERRIDE DETECTED</span>")
		show_laws()
		if(user)
			add_attack_logs(user, src, "Emagged")
		return TRUE

	else //Bot is unlocked, but the maint panel has not been opened with a screwdriver yet.
		to_chat(user, "<span class='warning'>You need to open maintenance panel first!</span>")

/mob/living/simple_animal/bot/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health > maxHealth/3)
			. += "[src]'s parts look loose."
		else
			. += "[src]'s parts look very loose!"
	else
		. += "[src] is in pristine condition."

/mob/living/simple_animal/bot/adjustHealth(amount, updating_health = TRUE)
	if(amount > 0 && prob(10))
		new /obj/effect/decal/cleanable/blood/oil(loc)
	. = ..()

/mob/living/simple_animal/bot/updatehealth(reason = "none given")
	..(reason)
	diag_hud_set_bothealth()

/// Add an atom to our list of ignored objects.
/mob/living/simple_animal/bot/proc/add_to_ignore(atom/subject)
	if(isnull(subject) || (subject in ignore_list))
		return

	if(length(ignore_list) >= 50)
		remove_ignored_atom(ignore_list[1])

	ignore_list += subject
	RegisterSignal(subject, COMSIG_PARENT_QDELETING, PROC_REF(remove_ignored_atom))

/// Remove an atom from the ignore list.
/mob/living/simple_animal/bot/proc/remove_ignored_atom(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	ignore_list -= source

/// Wipe the ignore list.
/mob/living/simple_animal/bot/proc/clear_ignore_list()
	for(var/atom/A as anything in ignore_list)
		remove_ignored_atom(A)

/mob/living/simple_animal/bot/handle_automated_action()
	diag_hud_set_botmode()

	if(COOLDOWN_FINISHED(src, ignore_list_cleanup_cd))
		clear_ignore_list()
		COOLDOWN_START(src, ignore_list_cleanup_cd, 20 SECONDS)

	if(!on)
		return

	if(hijacked)
		return

	switch(mode) // High-priority overrides are processed first. Bots can do nothing else while under direct command.
		if(BOT_RESPONDING)	// Called by the AI.
			call_mode()
			return
		if(BOT_SUMMON)		// Called by PDA
			bot_summon()
			return
		if(BOT_PATHING)
			return FALSE
	return TRUE // Successful completion. Used to prevent child process() continuing if this one is ended early.

/mob/living/simple_animal/bot/attack_alien(mob/living/carbon/alien/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	apply_damage(rand(15,30), BRUTE)
	visible_message("<span class='danger'>[user] has slashed [src]!</span>")
	playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(loc)

/mob/living/simple_animal/bot/attack_animal(mob/living/simple_animal/M)
	M.do_attack_animation(src)
	if(M.melee_damage_upper == 0)
		return
	apply_damage(M.melee_damage_upper, BRUTE)
	visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>")
	add_attack_logs(M, src, "Animal attacked", ATKLOG_ALL)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(loc)

/mob/living/simple_animal/bot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_HELP)
		interact(H)
	else
		return ..()

/mob/living/simple_animal/bot/attack_ghost(mob/M)
	interact(M)

/mob/living/simple_animal/bot/attack_ai(mob/user)
	if(!topic_denied(user))
		interact(user)
	else
		to_chat(user, "<span class='warning'>[src]'s interface is not responding!</span>")

/mob/living/simple_animal/bot/proc/interact(mob/user)
	show_controls(user)

/mob/living/simple_animal/bot/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/pda))
		if(allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, "Controls are now [locked ? "locked." : "unlocked."]")
			return ITEM_INTERACT_COMPLETE
		if(emagged)
			to_chat(user, "<span class='danger'>ERROR</span>")
		if(open)
			to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(W, /obj/item/paicard))
		if(paicard)
			to_chat(user, "<span class='warning'>A [paicard] is already inserted!</span>")
			return ITEM_INTERACT_COMPLETE

		if(!allow_pai || key)
			to_chat(user, "<span class='warning'>[src] is not compatible with [W].</span>")
			return ITEM_INTERACT_COMPLETE

		if(locked || open || hijacked)
			to_chat(user, "<span class='warning'>The personality slot is locked.</span>")
			return ITEM_INTERACT_COMPLETE

		var/obj/item/paicard/card = W
		if(!card.pai?.mind)
			to_chat(user, "<span class='warning'>[W] is inactive.</span>")
			return ITEM_INTERACT_COMPLETE

		if(!card.pai.ckey || jobban_isbanned(card.pai, ROLE_SENTIENT))
			to_chat(user, "<span class='warning'>[W] is unable to establish a connection to [src].</span>")
			return ITEM_INTERACT_COMPLETE

		if(!user.drop_item())
			return ITEM_INTERACT_COMPLETE

		W.forceMove(src)
		paicard = card
		user.visible_message("[user] inserts [W] into [src]!", "<span class='notice'>You insert [W] into [src].</span>")
		paicard.pai.mind.transfer_to(src)
		to_chat(src, "<span class='notice'>You sense your form change as you are uploaded into [src].</span>")
		bot_name = name
		name = paicard.pai.name
		faction = user.faction
		add_attack_logs(user, paicard.pai, "Uploaded to [src.bot_name]")
		return ITEM_INTERACT_COMPLETE

	if(istype(W, /obj/item/hemostat) && paicard)
		if(open)
			to_chat(user, "<span class='warning'>Close the access panel before manipulating the personality slot!</span>")
			return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='notice'>You attempt to pull [paicard] free...</span>")
		if(do_after(user, 30 * W.toolspeed, target = src))
			if(paicard)
				user.visible_message("<span class='notice'>[user] uses [W] to pull [paicard] out of [bot_name]!</span>","<span class='notice'>You pull [paicard] out of [bot_name] with [W].</span>")
				ejectpai(user)
				return ITEM_INTERACT_COMPLETE

/mob/living/simple_animal/bot/screwdriver_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(locked)
		to_chat(user, "<span class='warning'>The maintenance panel is locked.</span>")
		return TRUE // Must be true or we attempt to stab the bot

	open = !open
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>The maintenance panel is now [open ? "opened" : "closed"].</span>")
	return TRUE


/mob/living/simple_animal/bot/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	if(user == src) // No self-repair dummy
		return
	. = TRUE
	if(health >= maxHealth)
		to_chat(user, "<span class='warning'>[src] does not need a repair!</span>")
		return
	if(!open)
		to_chat(user, "<span class='warning'>Unable to repair with the maintenance panel closed!</span>")
		return
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	adjustBruteLoss(-10)
	add_fingerprint(user)
	user.visible_message("[user] repairs [src]!","<span class='notice'>You repair [src].</span>")

/mob/living/simple_animal/bot/bullet_act(obj/item/projectile/Proj)
	if(Proj && (Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		if(prob(75) && Proj.damage > 0)
			do_sparks(5, 1, src)
	return ..()

/mob/living/simple_animal/bot/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( loc )
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.anchored = TRUE
	pulse2.dir = pick(GLOB.cardinal)
	QDEL_IN(pulse2, 10)

	if(paicard)
		paicard.emp_act(severity)
		visible_message("[paicard] is flies out of [bot_name]!")
		ejectpai()

	if(on)
		turn_off()
	addtimer(CALLBACK(src, PROC_REF(un_emp), was_on), severity * 300)


/mob/living/simple_animal/bot/proc/un_emp(was_on)
	stat &= ~EMPED
	if(was_on)
		turn_on()

/mob/living/simple_animal/bot/proc/disable(time)
	if(disabling_timer_id)
		deltimer(disabling_timer_id) // If we already have disabling timer, lets replace it with new one
	if(on)
		turn_off()
	disabling_timer_id = addtimer(CALLBACK(src, PROC_REF(enable)), time, TIMER_STOPPABLE)

/mob/living/simple_animal/bot/proc/enable()
	if(disabling_timer_id)
		deltimer(disabling_timer_id)
		disabling_timer_id = null
	if(!on)
		turn_on()

/mob/living/simple_animal/bot/rename_character(oldname, newname)
	if(!..(oldname, newname))
		return FALSE

	set_custom_texts()
	return TRUE

/mob/living/simple_animal/bot/proc/set_custom_texts() // Superclass for setting hack texts. Appears only if a set is not given to a bot locally.
	text_hack = "You hack [name]."
	text_dehack = "You reset [name]."
	text_dehack_fail = "You fail to reset [name]."

/mob/living/simple_animal/bot/proc/speak(message, channel) // Pass a message to have the bot say() it. Pass a frequency to say it on the radio.
	if((!on) || (!message))
		return
	if(channel)
		Radio.autosay(message, name, channel == "headset" ? null : channel)
	else
		say(message)
	return

// Generalized behavior code, override where needed!

/*
scan() will search for a given type (such as turfs, human mobs, or objects) in the bot's view range, and return a single result.
Arguments: The object type to be searched (such as "/mob/living/carbon/human"), the old scan result to be ignored, if one exists,
and the view range, which defaults to 7 (full screen) if an override is not passed.
If the bot maintains an ignore list, it is also checked here.
If avoid_bot = TRUE, it will claim it's target. List of bots that use it: Cleanbot and Floorbot
Example usage: patient = scan(/mob/living/carbon/human, oldpatient, 1)
The proc would return a human next to the bot to be set to the patient var.
Pass the desired type path itself, declaring a temporary var beforehand is not required.
*/
/mob/living/simple_animal/bot/proc/scan(atom/scan_type, atom/old_target, scan_range = DEFAULT_SCAN_RANGE, avoid_bot)
	for(var/atom/A in view(scan_range, src)) // Search for something in range!
		if(!istype(A, scan_type)) // Check that the thing we found is the type we want!
			continue // If not, keep searching!
		if((A in ignore_list) || (A == old_target)) // Filter for blacklisted elements, usually unreachable or previously processed ones
			continue
		var/scan_result = process_scan(A) // Some bots may require additional processing when a result is selected.
		if(!scan_result)
			continue // The current element failed assessment, move on to the next.
		if(assign_bot(A, avoid_bot)) // Is the target claimed by a bot
			continue
		return scan_result

/mob/living/simple_animal/bot/proc/assign_bot(atom/A, avoid_bot)
	if(!avoid_bot) // Only bots with avoid bot should be considered
		return FALSE
	if(A.UID() in ignore_job) // Is this target already claimed by a bot
		return TRUE
	claim_job(A) // Claim the job so other bots don't come

/mob/living/simple_animal/bot/proc/claim_job(atom/A) // Adds the target to ignore_job list
	var/ignore_amount = length(GLOB.bots_list) // 1 claim per bot
	if(length(ignore_job) >= ++ignore_amount) // Something went wrong, cull the herd
		ignore_job.Cut()
	ignore_job |= A.UID()

// When the scan finds a target, run bot specific processing to select it for the next step. Empty by default.
/mob/living/simple_animal/bot/proc/process_scan(atom/scan_target)
	return scan_target

/*
Movement proc for stepping a bot through a path generated through A-star.
Pass a positive integer as an argument to override a bot's default speed.
*/
/mob/living/simple_animal/bot/proc/bot_move(dest, move_speed)
	if(!dest || !path || !length(path)) // A-star failed or a path/destination was not set.
		set_path(null)
		return FALSE

	dest = get_turf(dest) // We must always compare turfs, so get the turf of the dest var if dest was originally something else.
	var/turf/last_node = get_turf(path[length(path)]) // This is the turf at the end of the path, it should be equal to dest.
	if(get_turf(src) == dest) // We have arrived, no need to move again.
		return TRUE

	else if(dest != last_node) // The path should lead us to our given destination. If this is not true, we must stop.
		set_path(null)
		return FALSE

	var/step_count = move_speed ? move_speed : base_speed // If a value is passed into move_speed, use that instead of the default speed var.

	if(step_count >= 1 && tries < BOT_STEP_MAX_RETRIES)
		for(var/step_number in 1 to step_count)
			// Hopefully this wont fill the buckets too much
			addtimer(CALLBACK(src, PROC_REF(bot_step)), BOT_STEP_DELAY * (step_number - 1))
	else
		return FALSE
	return TRUE


/mob/living/simple_animal/bot/proc/bot_step() // Step,increase tries if failed
	if(!length(path))
		return FALSE

	if(!step_towards(src, path[1]))
		tries++
		return FALSE

	increment_path()
	tries = 0
	return TRUE


/mob/living/simple_animal/bot/proc/check_bot_access()
	if(mode != BOT_SUMMON && mode != BOT_RESPONDING)
		access_card.access = prev_access

/mob/living/simple_animal/bot/proc/call_bot(call_src, turf/waypoint, message=TRUE)
	bot_reset() // Reset a bot before setting it to call mode.
	var/area/end_area = get_area(waypoint)

	access_card.access = get_all_accesses() // Give the bot temporary all access

	set_path(get_path_to(src, waypoint, 200, access = access_card.access))
	calling_ai = call_src // Link the AI to the bot!
	ai_waypoint = waypoint

	if(path && length(path)) // Ensures that a valid path is calculated!
		if(!on)
			turn_on() // Saves the AI the hassle of having to activate a bot manually.
		if(client)
			reset_access_timer_id = addtimer(CALLBACK(src, PROC_REF(bot_reset)), 600, TIMER_OVERRIDE|TIMER_STOPPABLE) //if the bot is player controlled, they get the extra access for a limited time
			to_chat(src, "<span class='notice'><span class='big'>Priority waypoint set by [calling_ai] <b>[call_src]</b>. Proceed to <b>[end_area.name]</b>.</span><br>[length(path)-1] meters to destination. You have been granted additional door access for 60 seconds.</span>")
		if(message)
			to_chat(calling_ai, "<span class='notice'>[bicon(src)] [name] called to [end_area.name]. [length(path)-1] meters to destination.</span>")
		pathset = TRUE
		set_mode(BOT_RESPONDING)
		tries = 0
	else
		if(message)
			to_chat(calling_ai, "<span class='danger'>Failed to calculate a valid route. Ensure destination is clear of obstructions and within range.</span>")
		calling_ai = null
		access_card.access = prev_access // Don't forget to reset it
		set_path(null)

/mob/living/simple_animal/bot/proc/call_mode() // Handles preparing a bot for a call, as well as calling the move proc.
// Handles the bot's movement during a call.
	var/success = bot_move(ai_waypoint, 3)
	if(!success)
		if(calling_ai)
			to_chat(calling_ai, "[bicon(src)] [get_turf(src) == ai_waypoint ? "<span class='notice'>[src] successfully arrived to waypoint.</span>" : "<span class='danger'>[src] failed to reach waypoint.</span>"]")
			calling_ai = null
		bot_reset()

/mob/living/simple_animal/bot/proc/bot_reset()
	if(calling_ai) // Simple notification to the AI if it called a bot. It will not know the cause or identity of the bot.
		to_chat(calling_ai, "<span class='danger'>Call command to a bot has been reset.</span>")
		calling_ai = null
	if(reset_access_timer_id)
		deltimer(reset_access_timer_id)
		reset_access_timer_id = null
	set_path(null)
	ignore_job.Cut()
	new_destination = null
	destination = null
	last_target_location = null
	lost_target = FALSE
	summon_target = null
	pathset = FALSE
	access_card.access = prev_access
	tries = 0
	set_mode(BOT_IDLE)
	diag_hud_set_botstat()
	diag_hud_set_botmode()



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Patrol and summon code!
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/mob/living/simple_animal/bot/proc/bot_patrol()
	patrol_step()
	addtimer(CALLBACK(src, PROC_REF(do_patrol)), 5)

/mob/living/simple_animal/bot/proc/do_patrol()
	if(mode == BOT_PATROL)
		patrol_step()

/mob/living/simple_animal/bot/proc/start_patrol()
	set_path(null)
	if(tries >= BOT_STEP_MAX_RETRIES) // Bot is trapped, so stop trying to patrol.
		auto_patrol = FALSE
		tries = 0
		speak("Unable to start patrol.")

		return

	if(!auto_patrol) // A bot not set to patrol should not be patrolling.
		set_mode(BOT_IDLE)
		return


	if(patrol_target) // has patrol target
		INVOKE_ASYNC(src, PROC_REF(target_patrol))
	else // No patrol target, so need a new one
		speak("Engaging patrol mode.")
		find_patrol_target()
		tries++

/mob/living/simple_animal/bot/proc/target_patrol()
	calc_path() // Find a route to it
	if(!length(path))
		patrol_target = null
		return
	set_mode(BOT_PATROL)

// Perform a single patrol step

/mob/living/simple_animal/bot/proc/patrol_step()

	if(client) // In use by player, don't actually move.
		return

	if(loc == patrol_target) // Reached target
		// Find the next beacon matching the target.
		if(!get_next_patrol_target())
			find_patrol_target() // If it fails, look for the nearest one instead.
		return

	else if(length(path) && patrol_target) // Valid path
		if(path[1] == loc)
			increment_path()
			return


		var/moved = bot_move(patrol_target) // step_towards(src, next) // attempt to move
		if(!moved) // Couldn't proceed the next step of the path BOT_STEP_MAX_RETRIES times
			addtimer(CALLBACK(src, PROC_REF(patrol_step_not_moved)), 2)

	else // No path, so calculate new one
		set_mode(BOT_START_PATROL)

/mob/living/simple_animal/bot/proc/patrol_step_not_moved()
	calc_path()
	if(!length(path))
		find_patrol_target()
	tries = 0

// Finds the nearest beacon to self
/mob/living/simple_animal/bot/proc/find_patrol_target()
	nearest_beacon = null
	new_destination = null
	find_nearest_beacon()
	if(nearest_beacon)
		patrol_target = nearest_beacon_loc
		destination = next_destination
	else
		auto_patrol = FALSE
		set_mode(BOT_IDLE)
		speak("Disengaging patrol mode.")

/mob/living/simple_animal/bot/proc/get_next_patrol_target()
	// Search the beacon list for the next target in the list.
	for(var/obj/machinery/navbeacon/NB in GLOB.navbeacons["[z]"])
		if(NB.location == next_destination) // Does the Beacon location text match the destination?
			destination = new_destination // We now know the name of where we want to go.
			patrol_target = NB.loc // Get its location and set it as the target.
			next_destination = NB.codes["next_patrol"] // Also get the name of the next beacon in line.
			return TRUE

/mob/living/simple_animal/bot/proc/find_nearest_beacon()
	for(var/obj/machinery/navbeacon/NB in GLOB.navbeacons["[z]"])
		var/dist = get_dist(src, NB)
		if(nearest_beacon) //Loop though the beacon net to find the true closest beacon.
			//Ignore the beacon if were are located on it.
			if(dist>1 && dist<get_dist(src,nearest_beacon_loc))
				nearest_beacon = NB.location
				nearest_beacon_loc = NB.loc
				next_destination = NB.codes["next_patrol"]
			else
				continue
		else if(dist > 1) //Begin the search, save this one for comparison on the next loop.
			nearest_beacon = NB.location
			nearest_beacon_loc = NB.loc
	patrol_target = nearest_beacon_loc
	destination = nearest_beacon

/mob/living/simple_animal/bot/proc/bot_control_message(command, mob/user, user_turf)
	switch(command)
		if("stop")
			to_chat(src, "<span class='warning big'>STOP PATROL</span>")
		if("go")
			to_chat(src, "<span class='warning big'>START PATROL</span>")
		if("summon")
			var/area/a = get_area(user_turf)
			to_chat(src, "<span class='warning big'>PRIORITY ALERT: [user] in [a.name]!</span>")
		if("home")
			to_chat(src, "<span class='warning big'>RETURN HOME!</span>")
		if("ejectpai")
			return // Do nothing for this
		else
			to_chat(src, "<span class='warning'>Unidentified control sequence received: [command]</span>")

/mob/living/simple_animal/bot/proc/handle_command(mob/user, command, list/params)
	// We aint even on, why bother
	if(!on)
		return FALSE

	// Check to see if we are the commanded bot
	if(emagged || remote_disabled || hijacked) // Emagged bots do not respect anyone's authority! Bots with their remote controls off cannot get commands.
		return FALSE

	if(client)
		bot_control_message(command, user, params["target"] ? params["target"] : "Unknown")

	// Process control input
	switch(command)
		if("stop")
			bot_reset() // HOLD IT!!
			auto_patrol = FALSE

		if("go")
			auto_patrol = TRUE

		if("summon")
			bot_reset()
			var/list/user_access = params["useraccess"]
			summon_target = params["target"] // Location of the user

			if(length(user_access))
				access_card.access = user_access + prev_access // Adds the user's access, if any.

			set_mode(BOT_SUMMON)
			calc_summon_path()
			speak("Responding.", radio_channel)

	return TRUE


/mob/living/simple_animal/bot/proc/bot_summon() // Summoned to PDA
	summon_step()

// Calculates a path to the current destination
// Given an optional turf to avoid
/mob/living/simple_animal/bot/proc/calc_path(turf/avoid)
	check_bot_access()
	set_path(get_path_to(src, patrol_target, 120, access = access_card.access, exclude=avoid))

/mob/living/simple_animal/bot/proc/calc_summon_path(turf/avoid)
	set waitfor = FALSE
	check_bot_access()
	set_path(get_path_to(src, summon_target, 150, access = access_card.access, exclude=avoid))
	if(!length(path)) // Cannot reach target. Give up and announce the issue.
		speak("Summon command failed, destination unreachable.",radio_channel)
		bot_reset()

/mob/living/simple_animal/bot/proc/summon_step()

	if(client)		// In use by player, don't actually move.
		return

	if(loc == summon_target)		// Arrived to summon location.
		bot_reset()
		return

	else if(length(path) && summon_target)		//Proper path acquired!
		var/turf/next = path[1]
		if(next == loc)
			increment_path()
			return

		var/moved = bot_move(summon_target, 3)	// Move attempt
		if(!moved)
			addtimer(CALLBACK(src, PROC_REF(try_calc_path)), 2)


	else	// No path, so calculate new one
		calc_summon_path()

/mob/living/simple_animal/bot/proc/try_calc_path()
	calc_summon_path()
	tries = 0


/mob/living/simple_animal/bot/proc/openedDoor(obj/machinery/door/D)
	frustration = 0

/mob/living/simple_animal/bot/proc/show_controls(mob/M)
	users |= M
	var/dat = ""
	dat = get_controls(M)
	var/datum/browser/popup = new(M,window_id,window_name,350,600)
	popup.set_content(dat)
	popup.open()
	onclose(M, window_id, UID())
	return

/mob/living/simple_animal/bot/proc/update_controls()
	for(var/mob/M in users)
		show_controls(M)

/mob/living/simple_animal/bot/proc/get_controls(mob/M)
	return "PROTOBOT - NOT FOR USE"

/mob/living/simple_animal/bot/proc/allowed(mob/M)
	var/acc = M.get_access() // See mob.dm

	if(acc == IGNORE_ACCESS || M.can_admin_interact())
		return TRUE // Mob ignores access

	return has_access(list(), req_access, acc)

/mob/living/simple_animal/bot/proc/canhack(mob/M)
	return ((issilicon(M) && (!emagged || hacked)) || M.can_admin_interact())

/mob/living/simple_animal/bot/proc/handle_hacking(mob/M) // Refactored out of Topic/ to allow re-use by TGUIs
	if(!canhack(M))
		return
	if(!emagged)
		emagged = TRUE
		hacked = TRUE
		locked = TRUE
		to_chat(M, "<span class='warning'>[text_hack]</span>")
		show_laws()
		bot_reset()
		add_attack_logs(M, src, "Hacked")
	else if(!hacked)
		to_chat(M, "<span class='userdanger'>[text_dehack_fail]</span>")
	else
		emagged = FALSE
		hacked = FALSE
		to_chat(M, "<span class='notice'>[text_dehack]</span>")
		show_laws()
		bot_reset()
		add_attack_logs(M, src, "Dehacked")

/mob/living/simple_animal/bot/update_icon_state()
	icon_state = "[initial(icon_state)][on]"

/mob/living/simple_animal/bot/proc/topic_denied(mob/user) // Access check proc for bot topics! Remember to place in a bot's individual Topic if desired.
	if(user.can_admin_interact())
		return FALSE
	if(user.incapacitated() || !(issilicon(user) || in_range(src, user)))
		return TRUE
	if(emagged) // An emagged bot cannot be controlled by humans, silicons can if one hacked it.
		if(!hacked) // Manually emagged by a human - access denied to all.
			return TRUE
		else if(!(issilicon(user) || ispulsedemon(user))) // Bot is hacked, so only silicons are allowed access.
			return TRUE
	if(hijacked && !ispulsedemon(user))
		return FALSE
	if(locked && !(issilicon(user) || ispulsedemon(user)))
		return TRUE
	return FALSE

/mob/living/simple_animal/bot/proc/hack(mob/user)
	var/hack
	if(issilicon(user) || user.can_admin_interact()) // Allows silicons or admins to toggle the emag status of a bot.
		hack += "[emagged ? "Software compromised! Unit may exhibit dangerous or erratic behavior." : "Unit operating normally. Release safety lock?"]<BR>"
		hack += "Harm Prevention Safety System: <A href='byond://?src=[UID()];operation=hack'>[emagged ? "<span class='bad'>DANGER</span>" : "Engaged"]</A><BR>"
	else if(!locked) // Humans with access can use this option to hide a bot from the AI's remote control panel and PDA control.
		hack += "Remote network control radio: <A href='byond://?src=[UID()];operation=remote'>[remote_disabled ? "Disconnected" : "Connected"]</A><BR>"
	return hack

/mob/living/simple_animal/bot/proc/showpai(mob/user)
	var/eject = ""
	if(!locked || issilicon(usr) || user.can_admin_interact())
		if(paicard || allow_pai)
			eject += "Personality card status: "
			if(paicard)
				if(client)
					eject += "<A href='byond://?src=[UID()];operation=ejectpai'>Active</A>"
				else
					eject += "<A href='byond://?src=[UID()];operation=ejectpai'>Inactive</A>"
			else if(!allow_pai || key)
				eject += "Unavailable"
			else
				eject += "Not inserted"
			eject += "<BR>"
		eject += "<BR>"
	return eject

/mob/living/simple_animal/bot/proc/ejectpai(mob/user = null, announce = 1)
	if(paicard)
		if(mind && paicard.pai)
			mind.transfer_to(paicard.pai)
		else if(paicard.pai)
			paicard.pai.key = key
		else
			ghostize(GHOST_FLAGS_OBSERVE_ONLY) // The pAI card that just got ejected was dead.
		key = null
		paicard.forceMove(loc)
		if(user)
			add_attack_logs(user, paicard.pai, "Ejected from [src.bot_name],")
		else
			add_attack_logs(src, paicard.pai, "Ejected")
		if(announce)
			to_chat(paicard.pai, "<span class='notice'>You feel your control fade as [paicard] ejects from [bot_name].</span>")
		paicard = null
		name = bot_name
		faction = initial(faction)

/mob/living/simple_animal/bot/proc/ejectpairemote(mob/user)
	if(allowed(user) && paicard)
		speak("Ejecting personality chip.", radio_channel)
		ejectpai(user)

/mob/living/simple_animal/bot/Login()
	. = ..()
	access_card.access += player_access

	var/datum/atom_hud/data_hud = GLOB.huds[data_hud_type]
	if(data_hud)
		data_hud.add_hud_to(src)

	diag_hud_set_botmode()
	show_laws()

/mob/living/simple_animal/bot/Logout()
	. = ..()

	bot_reset()

/mob/living/simple_animal/bot/revive(full_heal = 0, admin_revive = 0)
	if(..())
		update_icon(UPDATE_ICON_STATE)
		. = 1

/mob/living/simple_animal/bot/ghost()
	if(stat != DEAD) // Only ghost if we're doing this while alive, the pAI probably isn't dead yet.
		..()
	if(paicard && (!client || stat == DEAD))
		ejectpai(0)

/mob/living/simple_animal/bot/sentience_act()
	faction -= "silicon"

/mob/living/simple_animal/bot/verb/show_laws()
	set name = "Show Directives"
	set category = "IC"

	to_chat(src, "<b>Directives:</b>")
	if(paicard && paicard.pai && paicard.pai.master && paicard.pai.pai_law0)
		to_chat(src, "<span class='warning'>Your master, [paicard.pai.master], may overrule any and all laws.</span>")
		to_chat(src, "0. [paicard.pai.pai_law0]")
	if(emagged)
		to_chat(src, "<span class='danger'>1. #$!@#$32K#$</span>")
	else if(HAS_TRAIT(src, TRAIT_CMAGGED))
		to_chat(src, "<span class='sans'>1. Be funny.</span>")
	else
		to_chat(src, "1. You are a machine built to serve the station's crew and AI(s).")
		to_chat(src, "2. Your function is to [bot_purpose].")
		to_chat(src, "3. You cannot serve your function if you are broken.")
		to_chat(src, "4. Serve your function to the best of your ability.")
	if(paicard && paicard.pai && paicard.pai.pai_laws)
		to_chat(src, "<b>Supplemental Directive(s):</b>")
		to_chat(src, "[paicard.pai.pai_laws]")

/mob/living/simple_animal/bot/get_access()
	if(hijacked)
		return get_all_accesses()

	. = ..()

	if(access_card)
		. |= access_card.GetAccess()

/mob/living/simple_animal/bot/proc/door_opened(obj/machinery/door/D)
	frustration = 0

/mob/living/simple_animal/bot/handle_message_mode(message_mode, message, verb, speaking, used_radios)
	switch(message_mode)
		if("intercom")
			for(var/obj/item/radio/intercom/I in view(1, src))
				I.talk_into(src, message, null, verb, speaking)
				used_radios += I
		if("headset")
			Radio.talk_into(src, message, null, verb, speaking)
			used_radios += Radio
		else
			if(message_mode)
				Radio.talk_into(src, message, message_mode, verb, speaking)
				used_radios += Radio

/mob/living/simple_animal/bot/is_mechanical()
	return TRUE

/mob/living/simple_animal/bot/proc/set_path(list/newpath)
	path = newpath ? newpath : list()

/mob/living/simple_animal/bot/proc/increment_path()
	if(!path || !length(path))
		return
	path.Cut(1, 2)

/mob/living/simple_animal/bot/proc/drop_part(obj/item/drop_item, dropzone)
	new drop_item(dropzone)


// Common data shared among all the bots, used by BotStatus.js
/mob/living/simple_animal/bot/ui_data(mob/user)
	var/list/data = list()
	data["locked"] = locked // Controls, locked or not
	data["noaccess"] = topic_denied(user) // Does the current user have access? admins, silicons etc can still access bots with locked controls
	data["maintpanel"] = open
	data["on"] = on
	data["painame"] = paicard ? paicard.pai.name : null
	data["canhack"] = canhack(user)
	data["emagged"] = emagged
	data["remote_disabled"] = remote_disabled
	if(bot_type != MULE_BOT)
		data["autopatrol"] = auto_patrol
	return data

// AI bot access verb TGUI
/mob/living/simple_animal/bot/proc/get_bot_data()
	. = list(
	"name" = name ? name : model, // name is the actual bot name. PAI may change it. Mulebot suffix system uses bot_name // WHY, WHO MADE THIS
	"model" = model, //
	"status" = mode, // BOT_IDLE is 0, using mode_name will bsod tgui
	"location" = get_area(src),
	"on" = on,
	"UID" = UID(),
	)
