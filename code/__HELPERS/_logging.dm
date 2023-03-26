// On Linux/Unix systems the line endings are LF, on windows it's CRLF, admins that don't use notepad++
// will get logs that are one big line if the system is Linux and they are using notepad.  This solves it by adding CR to every line ending
// in the logs.  ascii character 13 = CR

GLOBAL_VAR_INIT(log_end, (ascii2text(13))) // CRLF for all logs
GLOBAL_PROTECT(log_end)

#define DIRECT_OUTPUT(A, B) A << B
#define SEND_IMAGE(target, image) DIRECT_OUTPUT(target, image)
#define SEND_SOUND(target, sound) DIRECT_OUTPUT(target, sound)
#define SEND_TEXT(target, text) DIRECT_OUTPUT(target, text)
#define WRITE_FILE(file, text) DIRECT_OUTPUT(file, text)

/proc/error(msg)
	log_world("## ERROR: [msg]")

//print a warning message to world.log
#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
/proc/warning(msg)
	log_world("## WARNING: [msg]")

//print a testing-mode debug message to world.log and world
#ifdef TESTING
#define testing(msg) log_world("## TESTING: [msg]"); to_chat(world, "## TESTING: [msg]")
#else
#define testing(msg)
#endif

// All the log_type() procs are used for writing down into game.log
// don't use this for logging. We have add_type_logs() for this situation
// you can look all the way down in this file for those procs

/proc/log_admin(text)
	GLOB.admin_log.Add(text)
	if(config.log_admin)
		WRITE_LOG(GLOB.world_game_log, "ADMIN: [text][GLOB.log_end]")

/proc/log_debug(text)
	if(config.log_debug)
		WRITE_LOG(GLOB.world_game_log, "DEBUG: [text][GLOB.log_end]")

	for(var/client/C in GLOB.admins)
		if(check_rights(R_DEBUG, 0, C.mob) && (C.prefs.toggles & PREFTOGGLE_CHAT_DEBUGLOGS))
			to_chat(C, "DEBUG: [text]")

/proc/log_game(text)
	if(config.log_game)
		WRITE_LOG(GLOB.world_game_log, "GAME: [text][GLOB.log_end]")

/proc/log_vote(text)
	if(config.log_vote)
		WRITE_LOG(GLOB.world_game_log, "VOTE: [text][GLOB.log_end]")

/proc/log_access_in(client/new_client)
	if(config.log_access)
		var/message = "[key_name(new_client)] - IP:[new_client.address] - CID:[new_client.computer_id] - BYOND v[new_client.byond_version].[new_client.byond_build]"
		WRITE_LOG(GLOB.world_game_log, "ACCESS IN: [message][GLOB.log_end]")
		if(new_client.ckey in GLOB.admin_datums)
			var/datum/admins/admin = GLOB.admin_datums[new_client.ckey]
			WRITE_LOG(GLOB.world_game_log, "ADMIN: Admin [key_name(new_client)] ([admin.rank]) logged in[GLOB.log_end]")

/proc/log_access_out(mob/last_mob)
	if(config.log_access)
		var/message = "[key_name(last_mob)] - IP:[last_mob.lastKnownIP] - CID:[last_mob.computer_id] - BYOND Logged Out"
		WRITE_LOG(GLOB.world_game_log, "ACCESS OUT: [message][GLOB.log_end]")
		if(last_mob.ckey in GLOB.admin_datums)
			WRITE_LOG(GLOB.world_game_log, "ADMIN: Admin [key_name(last_mob)] logged out[GLOB.log_end]")

/proc/log_say(text, mob/speaker)
	if(config.log_say)
		WRITE_LOG(GLOB.world_game_log, "SAY: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_whisper(text, mob/speaker)
	if(config.log_whisper)
		WRITE_LOG(GLOB.world_game_log, "WHISPER: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_ooc(text, client/user)
	if(config.log_ooc)
		WRITE_LOG(GLOB.world_game_log, "OOC: [user.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_aooc(text, client/user)
	if(config.log_ooc)
		WRITE_LOG(GLOB.world_game_log, "AOOC: [user.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_looc(text, client/user)
	if(config.log_ooc)
		WRITE_LOG(GLOB.world_game_log, "LOOC: [user.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_emote(text, mob/speaker)
	if(config.log_emote)
		WRITE_LOG(GLOB.world_game_log, "EMOTE: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_attack(attacker, defender, message, newhp)
	if(config.log_attack)
		WRITE_LOG(GLOB.world_game_log, "ATTACK: [attacker] against [defender]: [message] [newhp][GLOB.log_end]") //Seperate attack logs? Why?

/proc/log_conversion(text, mob/converting)
	if(config.log_conversion)
		WRITE_LOG(GLOB.world_game_log, "CONVERSION: [converting.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_adminsay(text, mob/speaker)
	if(config.log_adminchat)
		WRITE_LOG(GLOB.world_game_log, "ADMINSAY: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_qdel(text)
	WRITE_LOG(GLOB.world_qdel_log, "QDEL: [text][GLOB.log_end]")

/proc/log_mentorsay(text, mob/speaker)
	if(config.log_adminchat)
		WRITE_LOG(GLOB.world_game_log, "MENTORSAY: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_ghostsay(text, mob/speaker)
	if(config.log_say)
		WRITE_LOG(GLOB.world_game_log, "DEADCHAT: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_ghostemote(text, mob/speaker)
	if(config.log_emote)
		WRITE_LOG(GLOB.world_game_log, "DEADEMOTE: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_adminwarn(text)
	if(config.log_adminwarn)
		WRITE_LOG(GLOB.world_game_log, "ADMINWARN: [html_decode(text)][GLOB.log_end]")

/proc/log_pda(text, mob/speaker)
	if(config.log_pda)
		WRITE_LOG(GLOB.world_game_log, "PDA: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_chat(text, mob/speaker)
	if(config.log_pda)
		WRITE_LOG(GLOB.world_game_log, "CHAT: [speaker.simple_info_line()] [html_decode(text)][GLOB.log_end]")

/proc/log_misc(text)
	WRITE_LOG(GLOB.world_game_log, "MISC: [text][GLOB.log_end]")

/proc/log_antag_objectives(datum/mind/Mind)
	if(length(Mind.objectives))
		WRITE_LOG(GLOB.world_game_log, "GAME: Start objective log for [html_decode(Mind.key)]/[html_decode(Mind.name)][GLOB.log_end]")
		var/count = 1
		for(var/datum/objective/objective in Mind.objectives)
			WRITE_LOG(GLOB.world_game_log, "GAME: Objective #[count]: [objective.explanation_text][GLOB.log_end]")
			count++
		WRITE_LOG(GLOB.world_game_log, "GAME: End objective log for [html_decode(Mind.key)]/[html_decode(Mind.name)][GLOB.log_end]")

/proc/log_world(text)
	if(config && !config.disable_root_log)
		SEND_TEXT(world.log, text)
	if(config && config.log_world_output)
		WRITE_LOG(GLOB.world_game_log, "WORLD: [html_decode(text)][GLOB.log_end]")

/proc/log_runtime_txt(text) // different from /tg/'s log_runtime because our error handler has a log_runtime proc already that does other stuff
	WRITE_LOG(GLOB.world_runtime_log, "[text][GLOB.log_end]")

/proc/log_config(text)
	WRITE_LOG(GLOB.config_error_log, "[text][GLOB.log_end]")
	SEND_TEXT(world.log, text)

/proc/log_href(text)
	WRITE_LOG(GLOB.world_href_log, "HREF: [html_decode(text)][GLOB.log_end]")

/proc/log_asset(text)
	WRITE_LOG(GLOB.world_asset_log, "ASSET: [text][GLOB.log_end]")

/proc/log_runtime_summary(text)
	WRITE_LOG(GLOB.runtime_summary_log, "[text][GLOB.log_end]")

/proc/log_tgui(text)
	WRITE_LOG(GLOB.tgui_log, "[text][GLOB.log_end]")

/proc/log_sql(text)
	WRITE_LOG(GLOB.sql_log, "[text][GLOB.log_end]")
	SEND_TEXT(world.log, text) // Redirect it to DD too

/**
 * Standardized method for tracking startup times.
 */
/proc/log_startup_progress(var/message)
	to_chat(world, "<span class='danger'>[message]</span>")
	log_world(message)

// A logging proc that only outputs after setup is done, to
// help devs test initialization stuff that happens a lot
/proc/log_after_setup(var/message)
	if(SSticker && SSticker.current_state > GAME_STATE_SETTING_UP)
		to_chat(world, "<span class='danger'>[message]</span>")
		log_world(message)

/* For logging round startup. */
/proc/start_log(log)
	WRITE_LOG(log, "Starting up. Round ID is [GLOB.round_id ? GLOB.round_id : "NULL"]\n-------------------------[GLOB.log_end]")

// Helper procs for building detailed log lines

/proc/datum_info_line(var/datum/d)
	if(!istype(d))
		return
	if(!istype(d, /mob))
		return "[d] ([d.type])"
	var/mob/m = d
	return "[m] ([m.ckey]) ([m.type])"

/proc/atom_loc_line(var/atom/a)
	if(!istype(a))
		return
	var/turf/t = get_turf(a)
	if(istype(t))
		return "[a.loc] ([t.x],[t.y],[t.z]) ([a.loc.type])"
	else if(a.loc)
		return "[a.loc] (0,0,0) ([a.loc.type])"

/mob/proc/simple_info_line()
	return "[key_name(src)] ([x],[y],[z])"

/client/proc/simple_info_line()
	return "[key_name(src)] ([mob.x],[mob.y],[mob.z])"

/*
 * This are the MAIN procs to use for logging stuff.
 * They intended that way the write down log into game.log
 * AND create_log record_log for Log Viewer
 * also messages admins with specific level(or custom level)
 *
 * Also recommend to check Investigation logging (__DEFINES/logs.dm) (modules/admin/admin_investigate.dm)
 * It's a misc logs that haven't got own place in game.log
 * most common INVESTIGATE_BOMB and INVESTIGATE_ENGINE
 */

// Proc for attack log creation
// * atom/user is the actor OR the list of actors
// * target is the target of action
// * what_done is the full description of the action
// * custom_level is whether or not to message admins
/proc/add_attack_logs(atom/user, target, what_done, custom_level)
	if(islist(target)) // Multi-victim adding
		var/list/targets = target
		for(var/t in targets)
			add_attack_logs(user, t, what_done, custom_level)
		return

	var/user_str
	if(ismecha(user?.loc) || isspacepod(user?.loc))
		var/obj/vehicle = user.loc
		user_str = key_name_log(user) + COORD(vehicle)
	else
		user_str = key_name_log(user) + COORD(user)
	var/target_str
	var/target_info
	if(isatom(target))
		var/atom/AT = target
		target_str = key_name_log(AT) + COORD(AT)
		target_info = key_name_admin(target)
	else
		target_str = target
		target_info = target

	var/mob/MU = user
	var/mob/MT = target
	var/newhp = ""

	//sending logs to Log Viewer and then logs into game.log
	if(istype(MU))
		MU.create_log(ATTACK_LOG, what_done, target, get_turf(user))
	if(istype(MT))
		MT.create_log(DEFENSE_LOG, what_done, user, get_turf(MT))
	var/mob/living/alive = target
	if(istype(alive))
		newhp += "\[HP:[alive.health]:[alive.getOxyLoss()]-[alive.getToxLoss()]-[alive.getFireLoss()]-[alive.getBruteLoss()]-[alive.getStaminaLoss()]-[alive.getBrainLoss()]-[alive.getCloneLoss()]\]"
	log_attack(user_str, target_str, what_done, newhp)

	//Setting up log level of how important this log.
	var/loglevel = ATKLOG_MOST
	if(!isnull(custom_level))
		loglevel = custom_level
	else if(istype(MT))
		if(istype(MU))
			if(!MU.ckey && !MT.ckey) // Attacks between NPCs are only shown to admins with ATKLOG_ALL
				loglevel = ATKLOG_ALL
			else if(!MU.ckey || !MT.ckey || (MU.ckey == MT.ckey)) // Player v NPC combat is de-prioritized. Also no self-harm, nobody cares
				loglevel = ATKLOG_ALMOSTALL
		else
			var/area/A = get_area(MT)
			if(A && A.hide_attacklogs)
				loglevel = ATKLOG_ALMOSTALL
	else
		loglevel = ATKLOG_ALL // Hitting an object. Not a mob
	if(isLivingSSD(target))  // Attacks on SSDs are shown to admins with any log level except ATKLOG_NONE. Overrides custom level
		loglevel = ATKLOG_FEW

	// Off it goes!
	msg_admin_attack("[key_name_admin(user)] vs [target_info]: [what_done]", loglevel)

// Proc for say log creation
// * user is the actor or list of actors
// * what_said is the message actor sent
// * target is specific from user to other. Can be telepathicly or borer
// * language is on what spoken the actor. It may be borer to host, cult talk or race language
/proc/add_say_logs(user, what_said, target, language = null)
	var/mob/actor
	if(islist(user)) // god eye example
		var/list/users = user
		for(var/u in users)
			add_say_logs(u, what_said, target, language)
		return
	else if(ismob(user))
		actor = user
	else
		log_runtime(EXCEPTION("Got non-mob variable [user] with arguments [what_said] [language] [target]"))
		return
	actor.create_log(SAY_LOG, "[language ? "([language]) " : ""][what_said]", target)
	log_say("[language ? "([language]) " : ""][what_said][target ? " to [target]" : null]", actor)

// Proc for conversion log creation
// * user is who gets converted in something
// * message is the context of conversion
/proc/add_conversion_logs(mob/user, message)
	user.create_log(CONVERSION_LOG, message)
	log_conversion(message, user)

// Proc for emote log creation
// * user is who moans or screams
// * emote is the emote itself
/proc/add_emote_logs(mob/user, emote)
	user.create_log(EMOTE_LOG, emote)
	log_emote(emote, user)

// Proc for game log creation
// * text is the full description of the what got logged.
// * mob/user is OPTIONAL, for Log Viewer
// Do note that this not message admins!
// You will have to make message_admins() alone if you need
/proc/add_game_logs(text, mob/user)
	if(user && istype(user))
		user.create_log(GAME_LOG, text)
		log_game(key_name_log(user)+" "+text)
	else
		log_game(text)

// Proc for misc log creation
// * user is the actor of this miserable log
// * what is the action taken by user or no one
// * target is an optional of who user acted against
/proc/add_misc_logs(mob/user, what, target)
	if(istype(user))
		user.create_log(MISC_LOG, what, target)
	log_misc("[user ? "[user]: " : null][what][target ? " against [target]" : null]")
// Proc for deadchat log creation
// * user is the ghooost
// * text that he whined after death
/proc/add_deadchat_logs(mob/user, text)
	user.create_log(DEADCHAT_LOG, text)
	log_ghostsay(text, user)

// Proc for ooc log creation
// * user is the client, not the mob
// * text that is definetely a meta
// * local is boolean of looc or ooc type of proc
/proc/add_ooc_logs(client/user, text, local = FALSE)
	if(local)
		user.mob.create_log(LOOC_LOG, text)
		log_looc(text, user)
	else
		user.mob.create_log(OOC_LOG, text)
		log_ooc(text, user)
