GLOBAL_LIST_INIT(command_strings, list(
	"patroloff" = "STOP PATROL",
	"patrolon" = "START PATROL",
	"stop" = "STOP",
	"go" = "GO",
	"home" = "RETURN HOME",
))

#define SENTIENT_BOT_RESET_TIMER 45 SECONDS

/mob/living/basic/bot
	icon = 'icons/obj/aibots.dmi'
	mob_biotypes = MOB_ROBOTIC
	basic_mob_flags = DEL_ON_DEATH
	density = FALSE

	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	hud_possible = list(DIAG_STAT_HUD, DIAG_BOT_HUD, DIAG_HUD, DIAG_BATT_HUD, DIAG_PATH_HUD = HUD_LIST_LIST)

	maximum_survivable_temperature = INFINITY
	minimum_survivable_temperature = 0

	sentience_type = SENTIENCE_ARTIFICIAL
	status_flags = NONE // no default canpush
	ai_controller = /datum/ai_controller/basic_controller/bot
	pass_flags = PASSMOB
	melee_attack_cooldown_min = 1.5

	speak_emote = list("states")

	bubble_icon = "machine"

	faction = list("neutral", "silicon", "turret")
	light_range = 3
	light_power = 0.6
	speed = 0

	/// Access needed to use this robot
	var/req_one_access = list(ACCESS_ROBOTICS)
	var/req_access = list()
	/// The Robot arm attached to this robot - has a 50% chance to drop on death.
	var/robot_arm = /obj/item/robot_parts/r_arm
	/// The inserted (if any) pAI in this bot.
	var/obj/item/paicard/paicard
	/// The type of bot it is, for radio control.
	var/bot_type = NONE
	/// All initial access this bot started with.
	var/list/initial_access = list()
	/// Bot-related mode flags on the Bot indicating how they will act. BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED | BOT_MODE_CAN_BE_SAPIENT | BOT_MODE_ROUNDSTART_POSSESSION
	/// DO NOT MODIFY MANUALLY, USE set_bot_mode_flags. If you don't shit breaks BAD
	var/bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED | BOT_MODE_CAN_BE_SAPIENT | BOT_MODE_ROUNDSTART_POSSESSION
	/// Bot-related cover flags on the Bot to deal with what has been done to their cover, including emagging. BOT_COVER_MAINTS_OPEN | BOT_COVER_LOCKED | BOT_COVER_EMAGGED | BOT_COVER_HACKED
	var/bot_access_flags = BOT_COVER_LOCKED
	///Small name of what the bot gets messed with when getting hacked/emagged.
	var/hackables = "system circuits"
	///Standardizes the vars that indicate the bot is busy with its function.
	var/mode = BOT_IDLE
	/// Links a bot to the AI calling it.
	var/calling_ai
	/// The bot's radio, for speaking to people.
	var/obj/item/radio/Radio
	/// Which channels can the bot listen to
	var/list/radio_config = null
	/// The bot's default radio channel
	var/radio_channel = "Common"
	///our access card
	var/obj/item/card/id/access_card
	///The trim type that will grant additional acces
	var/datum/id_trim/additional_access
	///file the path icon is stored in
	var/path_image_icon = 'icons/obj/aibots.dmi'
	///state of the path icon
	var/path_image_icon_state = "path_indicator"
	///what color this path icon will use
	var/path_image_color = COLOR_WHITE
	///list of all layed path icons
	var/list/current_pathed_turfs = list()

	///The type of data HUD the bot uses. Diagnostic by default.
	var/data_hud_type = TRAIT_DIAGNOSTIC_HUD
	/// If true we will allow ghosts to control this mob
	var/can_be_possessed = FALSE
	/// Message to display upon possession
	var/possessed_message = "You're a generic bot. How did one of these even get made?"
	/// Action we use to say voice lines out loud, also we just pass anything we try to say through here just in case it plays a voice line
	var/datum/action/cooldown/bot_announcement/pa_system
	/// Type of bot_announcement ability we want
	var/announcement_type
	///list of traits we apply and remove when turning on/off
	var/static/list/on_toggle_traits = list(
		TRAIT_IMMOBILIZED,
		TRAIT_HANDS_BLOCKED,
	)
	///name of the UI we will attempt to open
	var/bot_ui = "SimpleBot"
	// The faction of the bot before it inherited the pai's faction
	var/list/original_faction
	// The allies of the bot before it inherited the pai's faction
	var/list/original_allies
	/// Timer for bots disabled by a baton
	var/disabling_timer_id = null
	/// Is currently hijacked by a pulse demon?
	var/hijacked = FALSE
	/// Is currently emagged?
	var/emagged = FALSE
	/// If true we will offer this
	COOLDOWN_DECLARE(offer_ghosts_cooldown)

/mob/living/basic/bot/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/ai_retaliate)
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(after_attacked))
	GLOB.bots_list += src

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
	add_language("Skkula-Runespeak", 1)
	set_default_language(GLOB.all_languages["Galactic Common"])

	access_card = new /obj/item/card/id(src)
	// This access is so bots can be immediately set to patrol and leave Robotics, instead of having to be let out first.
	access_card.access += ACCESS_ROBOTICS
	Radio = new/obj/item/radio/headset/bot(src)
	Radio.follow_target = src

	//Adds bot to the diagnostic HUD system
	prepare_huds()
	for(var/hud_key, hud in GLOB.huds)
		var/datum/atom_hud/data/diagnostic/diag_hud = hud
		if(!istype(diag_hud))
			continue
		diag_hud.add_to_hud(src)
		permanent_huds |= diag_hud
	diag_hud_set_bothealth()
	diag_hud_set_botstat()
	diag_hud_set_botmode()

	REMOVE_TRAIT(src, TRAIT_CAN_STRIP, TRAIT_GENERIC)
	RemoveElement(/datum/element/strippable)

	// If a bot has its own HUD (for player bots), provide it.
	if(!isnull(data_hud_type))
		ADD_TRAIT(src, data_hud_type, INNATE_TRAIT)

	pa_system = (isnull(announcement_type)) ? new(src, automated_announcements = generate_speak_list()) : new announcement_type(src, automated_announcements = generate_speak_list())
	pa_system.Grant(src)
	ai_controller.set_blackboard_key(BB_ANNOUNCE_ABILITY, pa_system)
	ai_controller.set_blackboard_key(BB_RADIO_CHANNEL, radio_channel)
	update_appearance()

/mob/living/basic/bot/proc/set_mode_flags(mode_flags)
	SHOULD_CALL_PARENT(TRUE)
	bot_mode_flags = mode_flags
	SEND_SIGNAL(src, COMSIG_BOT_MODE_FLAGS_SET, mode_flags)

/mob/living/basic/bot/proc/get_mode()
	if(client) //Player bots do not have modes, thus the override. Also an easy way for PDA users/AI to know when a bot is a player.
		return SPAN_BOLD("[paicard ? "pAI Controlled" : "Autonomous"]")

	if(!(bot_mode_flags & BOT_MODE_ON))
		return SPAN_BAD("Inactive")

	return SPAN_INFORMATION("[mode]")

/**
 * Returns a status string about the bot's current status, if it's moving, manually controlled, or idle.
 */
/mob/living/basic/bot/proc/get_mode_ui()
	if(client)
		return paicard ? "pAI Controlled" : "Autonomous"

	if(!(bot_mode_flags & BOT_MODE_ON))
		return "Inactive"

	return "[mode]"

/**
 * Returns a string of flavor text for emagged bots.
 */
/mob/living/basic/bot/proc/get_emagged_message()
	return "You are a malfunctioning bot! Disrupt everyone and cause chaos!"

/mob/living/basic/bot/proc/turn_on(mob/user)
	if(stat == DEAD)
		return FALSE
	set_mode_flags(bot_mode_flags | BOT_MODE_ON)
	remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED))
	set_light(bot_mode_flags & BOT_MODE_ON ? initial(light_range) : 0)
	ai_controller.set_ai_status(AI_STATUS_ON)
	update_appearance()
	diag_hud_set_botstat()
	return TRUE

/mob/living/basic/bot/proc/turn_off()
	set_mode_flags(bot_mode_flags & ~BOT_MODE_ON)
	set_light(bot_mode_flags & BOT_MODE_ON ? initial(light_range) : 0)
	ai_controller.set_ai_status(AI_STATUS_OFF)
	bot_reset() // Resets an AI's call, should it exist.
	update_appearance()

/mob/living/basic/bot/Destroy()
	GLOB.bots_list -= src
	calling_ai = null
	QDEL_NULL(paicard)
	QDEL_NULL(pa_system)
	QDEL_NULL(Radio)
	QDEL_NULL(access_card)
	return ..()

/// Returns true if this mob can be controlled
/mob/living/basic/bot/proc/check_possession(mob/potential_possessor)
	if(!can_be_possessed)
		to_chat(potential_possessor, SPAN_WARNING("The bot's personality download has been disabled!"))
	return can_be_possessed

/// Fired after something takes control of this mob
/mob/living/basic/bot/proc/post_possession()
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	speak("New personality installed successfully!")
	rename(src)

/// Allows renaming the bot to something else
/mob/living/basic/bot/proc/rename(mob/user)
	var/new_name = sanitize_text(
		tgui_input_text(
			user = user,
			message = "This machine is designated [real_name]. Would you like to update [p_their()] registration?",
			title = "Name change",
			default = real_name,
			max_length = MAX_NAME_LEN,
		)
	)
	if(isnull(new_name) || QDELETED(src))
		return
	if(key && user != src)
		var/accepted = tgui_alert(
			src,
			message = "Do you wish to be renamed to [new_name]?",
			title = "Name change",
			buttons = list("Yes", "No"),
		)
		if(accepted != "Yes" || QDELETED(src))
			return
	name = new_name
	real_name = new_name

/mob/living/basic/bot/proc/allowed(mob/M)
	var/acc = M.get_access() // See mob.dm

	if(acc == IGNORE_ACCESS || M.can_admin_interact())
		return TRUE // Mob ignores access

	if(!(bot_access_flags & BOT_COVER_LOCKED)) // Unlocked.
		return TRUE

	return has_access(req_access, req_one_access, acc)

/mob/living/basic/bot/death(gibbed)
	if(paicard)
		ejectpai()
	explode()
	return ..()

/mob/living/basic/bot/proc/explode()
	visible_message(SPAN_BOLDNOTICE("[src] blows apart!"))
	do_sparks(3, TRUE, src)
	var/atom/location_destroyed = drop_location()
	if(prob(50))
		drop_part(robot_arm, location_destroyed)

/mob/living/basic/bot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(bot_access_flags & BOT_COVER_LOCKED) // First emag application unlocks the bot's interface. Apply a screwdriver to use the emag again.
		bot_access_flags &= ~BOT_COVER_LOCKED
		return TRUE
	if((bot_access_flags & BOT_COVER_LOCKED) || !(bot_access_flags & BOT_COVER_MAINTS_OPEN)) // Bot panel is unlocked by ID or emag, and the panel is screwed open. Ready for emagging.
		return FALSE
	bot_access_flags |= BOT_COVER_EMAGGED
	bot_access_flags |= BOT_COVER_LOCKED
	set_mode_flags(bot_mode_flags & ~BOT_MODE_REMOTE_ENABLED) // Manually emagging the bot also locks the AI from controlling it.
	bot_reset()
	turn_on() // The bot automatically turns on when emagged, unless recently hit with EMP.
	to_chat(src, SPAN_USERDANGER("(#$*#$^^( OVERRIDE DETECTED"))
	to_chat(src, SPAN_BOLDNOTICE(get_emagged_message()))
	if(user)
		log_attack(user, src, "emagged")
	emag_effects(user)
	emagged = TRUE
	return TRUE

/mob/living/basic/bot/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health > (maxHealth * 0.3))
			. += "[src]'s parts look loose."
		else
			. += "[src]'s parts look very loose!"
	else
		. += "[src] is in pristine condition."

	. += SPAN_NOTICE("[p_their()] maintenance panel is [bot_access_flags & BOT_COVER_MAINTS_OPEN ? "open" : "closed"].")
	. += SPAN_INFO("You can use a <b>screwdriver</b> to [bot_access_flags & BOT_COVER_MAINTS_OPEN ? "close" : "open"] [p_them()].")

	if(bot_access_flags & BOT_COVER_MAINTS_OPEN)
		. += SPAN_NOTICE("[p_their()] control panel is [bot_access_flags & BOT_COVER_LOCKED ? "locked" : "unlocked"].")
		if(!(bot_access_flags & BOT_COVER_EMAGGED) && (issilicon(user) || user.Adjacent(src)))
			. += SPAN_INFO("Alt-click [issilicon(user) ? "" : "or use your ID on "][p_them()] to [bot_access_flags & BOT_COVER_LOCKED ? "un" : ""]lock [p_their()] control panel.")
	if(isnull(paicard))
		return
	. += SPAN_NOTICE("[p_they()] [p_have()] a pAI device installed.")
	if(!(bot_access_flags & BOT_COVER_MAINTS_OPEN))
		. += SPAN_INFO("You can use a <b>hemostat</b> to remove it.")

/mob/living/basic/bot/updatehealth()
	. = ..()
	diag_hud_set_bothealth()

/mob/living/basic/bot/med_hud_set_health()
	return // we use a different hud

/mob/living/basic/bot/med_hud_set_status()
	return // we use a different hud

/mob/living/basic/bot/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(user.a_intent == INTENT_HELP)
		ui_interact(user)
		return
	return ..()

/mob/living/basic/bot/attack_ai(mob/user)
	if(!topic_denied(user))
		ui_interact(user)
		return
	to_chat(user, SPAN_WARNING("[src]'s interface is not responding!"))

/mob/living/basic/bot/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, bot_ui, name)
		ui.open()

/mob/living/basic/bot/AltClick(mob/user, modifiers)
	. = ..()
	unlock_with_id(user)

/mob/living/basic/bot/proc/unlock_with_id(mob/living/user)
	if(bot_access_flags & BOT_COVER_EMAGGED)
		return
	if(bot_access_flags & BOT_COVER_MAINTS_OPEN)
		return
	if(!allowed(user))
		return
	bot_access_flags ^= BOT_COVER_LOCKED
	to_chat(user, SPAN_NOTICE("Controls are now [bot_access_flags & BOT_COVER_LOCKED ? "locked" : "unlocked"]."))
	return TRUE

/mob/living/basic/bot/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(bot_access_flags & BOT_COVER_LOCKED)
		to_chat(user, SPAN_WARNING("The maintenance panel is locked!"))
		return

	tool.play_tool_sound(src)
	bot_access_flags ^= BOT_COVER_MAINTS_OPEN
	to_chat(user, SPAN_NOTICE("The maintenance panel is now [bot_access_flags & BOT_COVER_MAINTS_OPEN ? "opened" : "closed"]."))
	return TRUE

/mob/living/basic/bot/welder_act(mob/living/user, obj/item/tool)
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.a_intent != INTENT_HELP)
		return FALSE

	if(!tool.use_tool(src, user, 0 SECONDS, volume=40))
		return FALSE

	heal_overall_damage(10)
	user.visible_message(SPAN_NOTICE("[user] repairs [src]!"), SPAN_NOTICE("You repair [src]."))
	return TRUE

/mob/living/basic/bot/attack_by(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.GetID())
		unlock_with_id(user)
		return

	if(istype(attacking_item, /obj/item/paicard))
		insertpai(user, attacking_item)
		return

	if(attacking_item.tool_behaviour != TOOL_HEMOSTAT || !paicard)
		return ..()

	if(!do_after(user, 3 SECONDS, target = src) || !paicard)
		return

	user.visible_message(SPAN_NOTICE("[user] uses [attacking_item] to pull [paicard] out of [initial(src.name)]!"), \
		SPAN_NOTICE("You pull [paicard] out of [initial(src.name)] with [attacking_item]."))

	ejectpai(user)

/mob/living/basic/bot/attack_ghost(mob/M)
	ui_interact(M)

/mob/living/basic/bot/adjustHealth(amount, updating_health)
	if(amount > 0 && stat != DEAD)
		do_sparks(5, 4, src)
		. = TRUE
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(loc)
	return ..()

/mob/living/basic/bot/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	. = ..()
	if(prob(25))
		return
	if(hitting_projectile.damage_type != BRUTE && hitting_projectile.damage_type != BURN)
		return
	if(!hitting_projectile.is_hostile_projectile() || hitting_projectile.damage <= 0)
		return
	do_sparks(5, TRUE, src)

/mob/living/basic/bot/emp_act(severity)
	. = ..()
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
		visible_message("[paicard] is flies out of [src]!")
		ejectpai()

	if(bot_mode_flags & BOT_MODE_ON)
		turn_off()
	addtimer(CALLBACK(src, PROC_REF(turn_on)), severity * 30 SECONDS)

/**
 * Pass a message to have the bot say() it, passing through our announcement action to potentially also play a sound.
 * Optionally pass a frequency to say it on the radio.
 */
/mob/living/basic/bot/proc/speak(message, channel)
	if(!message)
		return
	if(channel)
		Radio.autosay(message, name, channel)
	else
		say(message)
	return

/mob/living/basic/bot/proc/radio(message, list/message_mods = list(), list/spans, language)
	return

/mob/living/basic/bot/proc/drop_part(obj/item/drop_item, dropzone)
	var/obj/item/item_to_drop
	if(ispath(drop_item))
		item_to_drop = new drop_item(dropzone)
	else
		item_to_drop = drop_item
		item_to_drop.forceMove(dropzone)

	if(istype(item_to_drop, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/dropped_cell = item_to_drop
		dropped_cell.charge = 0
		return

	if(istype(item_to_drop, /obj/item/storage))
		item_to_drop.contents = list()
		return

	if(!istype(item_to_drop, /obj/item/gun/energy))
		return
	var/obj/item/gun/energy/dropped_gun = item_to_drop
	dropped_gun.cell.charge = 0
	dropped_gun.update_appearance()

/mob/living/basic/bot/proc/disable(time)
	if(disabling_timer_id)
		deltimer(disabling_timer_id) // If we already have disabling timer, lets replace it with new one
	if(bot_mode_flags & BOT_MODE_ON)
		turn_off()
	disabling_timer_id = addtimer(CALLBACK(src, PROC_REF(enable)), time, TIMER_STOPPABLE)

/mob/living/basic/bot/proc/enable()
	if(disabling_timer_id)
		deltimer(disabling_timer_id)
		disabling_timer_id = null
	if(!(bot_mode_flags & BOT_MODE_ON))
		turn_on()

/mob/living/basic/bot/proc/bot_reset(bypass_ai_reset = FALSE)
	SEND_SIGNAL(src, COMSIG_BOT_RESET)
	access_card.access = initial_access
	update_bot_mode(new_mode = src::mode)
	diag_hud_set_botstat()
	diag_hud_set_botmode()
	if(bypass_ai_reset || isnull(calling_ai))
		return
	var/mob/living/ai_caller = calling_ai
	if(isnull(ai_caller))
		return
	to_chat(ai_caller, SPAN_DANGER("Call command to a bot has been reset."))
	calling_ai = null

//PDA control. Some bots, especially MULEs, may have more parameters.
/mob/living/basic/bot/proc/bot_control(command, mob/user, list/params = list())
	if(!(bot_mode_flags & BOT_MODE_ON) || bot_access_flags & BOT_COVER_EMAGGED || !(bot_mode_flags & BOT_MODE_REMOTE_ENABLED)) //Emagged bots do not respect anyone's authority! Bots with their remote controls off cannot get commands.
		return TRUE //ACCESS DENIED
	if(client && command != "ejectpai")
		bot_control_message(command, user)
	// process control input
	switch(command)
		if("patroloff")
			set_patrol_off()
		if("patrolon")
			set_mode_flags(bot_mode_flags | BOT_MODE_AUTOPATROL)
		if("summon")
			summon_bot(user, user_access = params["user_access"])
		if("ejectpai")
			eject_pai_remote(user)

// AI bot access verb TGUI
/mob/living/basic/bot/proc/get_bot_data()
	. = list(
	"name" = name, // name is the actual bot name. PAI may change it. Mulebot suffix system uses bot_name // WHY, WHO MADE THIS
	"model" = "", //
	"status" = mode, // BOT_IDLE is 0, using mode_name will bsod tgui
	"location" = get_area(src),
	"on" = bot_mode_flags & BOT_MODE_ON,
	"UID" = UID(),
	)

/mob/living/basic/bot/proc/set_patrol_off()
	bot_reset()
	set_mode_flags(bot_mode_flags & ~BOT_MODE_AUTOPATROL)

/mob/living/basic/bot/proc/bot_control_message(command, user)
	if(command == "summon")
		return "PRIORITY ALERT:[user] in [get_area_name(user)]!"
	return GLOB.command_strings[command] || "Unidentified control sequence received:[command]"

/mob/living/basic/bot/ui_data(mob/user)
	var/list/data = list()
	data["can_hack"] = issilicon(user)
	data["custom_controls"] = list()
	data["emagged"] = bot_access_flags & BOT_COVER_EMAGGED
	data["has_access"] = allowed(user)
	data["locked"] = (bot_access_flags & BOT_COVER_LOCKED)
	data["settings"] = list()
	if(!(bot_access_flags & BOT_COVER_LOCKED) || issilicon(user))
		data["settings"]["pai_inserted"] = !isnull(paicard)
		data["settings"]["allow_possession"] = bot_mode_flags & BOT_MODE_CAN_BE_SAPIENT
		data["settings"]["possession_enabled"] = can_be_possessed
		data["settings"]["airplane_mode"] = !(bot_mode_flags & BOT_MODE_REMOTE_ENABLED)
		data["settings"]["maintenance_lock"] = !(bot_access_flags & BOT_COVER_MAINTS_OPEN)
		data["settings"]["power"] = bot_mode_flags & BOT_MODE_ON
		data["settings"]["patrol_station"] = bot_mode_flags & BOT_MODE_AUTOPATROL
	return data

// Actions received from TGUI
/mob/living/basic/bot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/the_user = ui.user
	if(!allowed(the_user))
		return

	if(action == "lock")
		bot_access_flags ^= BOT_COVER_LOCKED

	switch(action)
		if("power")
			if(bot_mode_flags & BOT_MODE_ON)
				turn_off()
			else
				turn_on()
		if("maintenance")
			bot_access_flags ^= BOT_COVER_MAINTS_OPEN
		if("patrol")
			set_mode_flags(bot_mode_flags ^ BOT_MODE_AUTOPATROL)
			bot_reset()
		if("airplane")
			set_mode_flags(bot_mode_flags ^ BOT_MODE_REMOTE_ENABLED)
		if("hack")
			if(!issilicon(the_user))
				return
			if(!(bot_access_flags & BOT_COVER_EMAGGED))
				bot_access_flags |= (BOT_COVER_LOCKED|BOT_COVER_EMAGGED|BOT_COVER_HACKED)
				emag_effects(the_user)
				to_chat(the_user, SPAN_WARNING("You overload [src]'s [hackables]."))
				message_admins("Safety lock of [ADMIN_LOOKUPFLW(src)] was disabled by [ADMIN_LOOKUPFLW(the_user)] in [ADMIN_VERBOSEJMP(the_user)]")
				bot_reset()
				to_chat(src, SPAN_USERDANGER("(#$*#$^^( OVERRIDE DETECTED"))
				to_chat(src, SPAN_BOLDNOTICE(get_emagged_message()))
				return
			if(!(bot_access_flags & BOT_COVER_HACKED))
				to_chat(the_user, SPAN_BOLDDANGER("You fail to repair [src]'s [hackables]."))
				return
			bot_access_flags &= ~(BOT_COVER_EMAGGED|BOT_COVER_HACKED)
			to_chat(the_user, SPAN_NOTICE("You reset the [src]'s [hackables]."))
			bot_reset()
			to_chat(src, SPAN_USERDANGER("Software restored to standard."))
			to_chat(src, SPAN_BOLDNOTICE(possessed_message))
		if("eject_pai")
			if(!paicard)
				return
			to_chat(the_user, SPAN_NOTICE("You eject [paicard] from [initial(src.name)]."))
			ejectpai(the_user)
		if("rename")
			rename(the_user)

/mob/living/basic/bot/update_icon_state()
	icon_state = "[isnull(base_icon_state) ? initial(icon_state) : base_icon_state][bot_mode_flags & BOT_MODE_ON]"
	return ..()

/// Access check proc for bot topics! Remember to place in a bot's individual Topic if desired.
/mob/living/basic/bot/proc/topic_denied(mob/user)
	// 0 for access, 1 for denied.
	if(!(bot_access_flags & BOT_COVER_EMAGGED)) //An emagged bot cannot be controlled by humans, silicons can if one hacked it.
		return FALSE
	if(!(bot_access_flags & BOT_COVER_HACKED)) //Manually emagged by a human - access denied to all.
		return TRUE
	if(!issilicon(user)) //Bot is hacked, so only silicons and admins are allowed access.
		return TRUE

	return FALSE

/// Places a pAI in control of this mob
/mob/living/basic/bot/proc/insertpai(mob/user, obj/item/paicard/card)
	if(paicard)
		to_chat(user, SPAN_WARNING("The PAI slot is occupied!"))
		return
	if(key)
		to_chat(user, SPAN_WARNING("The PAI personality is already online!"))
		return
	if(!(bot_access_flags & BOT_COVER_MAINTS_OPEN))
		to_chat(user, SPAN_WARNING("You can't access the PAI slot!"))
		return
	if(!(bot_mode_flags & BOT_MODE_CAN_BE_SAPIENT))
		to_chat(user, SPAN_WARNING("The bot's firmware is not compatible with your PAI card."))
		return
	if(isnull(card.pai?.mind))
		to_chat(user, SPAN_WARNING("You have no active PAI in the card!"))
		return
	card.forceMove(src)
	paicard = card
	user.visible_message("[user] inserts [card] into [src]!", SPAN_NOTICE("You insert [card] into [src]."))
	paicard.pai.mind.transfer_to(src)
	to_chat(src, SPAN_NOTICE("You sense your form change as you are uploaded into [src]."))
	name = paicard.pai.name
	faction = user.faction
	add_attack_logs(user, paicard.pai, "Uploaded to [src.name]")

/mob/living/basic/bot/ghost()
	if(stat != DEAD) // Only ghost if we're doing this while alive, the pAI probably isn't dead yet.
		return ..()
	if(paicard && (!client || stat == DEAD))
		ejectpai()

/// Ejects a pAI from this bot
/mob/living/basic/bot/proc/ejectpai(mob/user = null, announce = TRUE)
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
			add_attack_logs(user, paicard.pai, "Ejected from [src],")
		else
			add_attack_logs(src, paicard.pai, "Ejected")
		if(announce)
			to_chat(paicard.pai, SPAN_NOTICE("You feel your control fade as [paicard] ejects from [src]."))
		paicard = null
		faction = initial(faction)

/// Ejects the pAI remotely.
/mob/living/basic/bot/proc/eject_pai_remote(mob/user)
	if(!allowed(user) || !paicard)
		return
	speak("Ejecting personality chip.", radio_channel)
	ejectpai(user)

/mob/living/basic/bot/Login()
	. = ..()
	if(!. || isnull(client))
		return FALSE
	speed = 2

	diag_hud_set_botmode()

/mob/living/basic/bot/Logout()
	. = ..()
	bot_reset()
	speed = initial(speed)

/mob/living/basic/bot/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return
	update_appearance()

/mob/living/basic/bot/rust_heretic_act()
	adjustBruteLoss(400)

/mob/living/basic/bot/get_access()
	return access_card.GetAccess()

/mob/living/basic/bot/proc/generate_speak_list()
	return null

/mob/living/basic/bot/proc/summon_bot(atom/summoner, turf/turf_destination, user_access = list(), grant_all_access = FALSE)
	if(is_ai(summoner) && !set_ai_caller(summoner))
		return FALSE
	bot_reset(bypass_ai_reset = is_ai(summoner))
	var/turf/destination = turf_destination ? turf_destination : get_turf(summoner)
	ai_controller?.set_blackboard_key(BB_BOT_SUMMON_TARGET, destination)
	var/list/access_to_grant = grant_all_access ? get_all_accesses() : user_access + initial_access
	access_card.access = access_to_grant
	speak("Responding.", radio_channel)
	update_bot_mode(new_mode = BOT_SUMMON)
	if(client) //if we're sentient, we reset ourselves after a short period
		addtimer(CALLBACK(src, PROC_REF(bot_reset)), SENTIENT_BOT_RESET_TIMER)
	return TRUE

/mob/living/basic/bot/proc/set_ai_caller(mob/living/ai_caller)
	if(!isnull(calling_ai) && calling_ai != src)
		return FALSE
	calling_ai = ai_caller
	return TRUE

/mob/living/basic/bot/proc/update_bot_mode(new_mode, update_hud = TRUE)
	mode = new_mode
	update_appearance()
	if(update_hud)
		diag_hud_set_botmode()

/mob/living/basic/bot/proc/after_attacked(datum/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER

	if(attack_flags & ATTACKER_DAMAGING_ATTACK)
		do_sparks(5, 4, source = src)

/mob/living/basic/bot/proc/emag_effects(user)
	return

/mob/living/basic/bot/proc/on_bot_movement(atom/movable/source, atom/oldloc, dir, forced)
	return

#undef SENTIENT_BOT_RESET_TIMER
