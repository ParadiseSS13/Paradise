// On Linux/Unix systems the line endings are LF, on windows it's CRLF, admins that don't use notepad++
// will get logs that are one big line if the system is Linux and they are using notepad.  This solves it by adding CR to every line ending
// in the logs.  ascii character 13 = CR

GLOBAL_VAR_INIT(log_end, (world.system_type == UNIX ? ascii2text(13) : ""))
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

/proc/log_admin(text)
	GLOB.admin_log.Add(text)
	if(config.log_admin)
		rustg_log_write(GLOB.world_game_log, "ADMIN: [text][GLOB.log_end]")

/proc/log_debug(text)
	if(config.log_debug)
		rustg_log_write(GLOB.world_game_log, "DEBUG: [text][GLOB.log_end]")

	for(var/client/C in GLOB.admins)
		if(check_rights(R_DEBUG, 0, C.mob) && (C.prefs.toggles & PREFTOGGLE_CHAT_DEBUGLOGS))
			to_chat(C, "DEBUG: [text]")

/proc/log_game(text)
	if(config.log_game)
		rustg_log_write(GLOB.world_game_log, "GAME: [text][GLOB.log_end]")

/proc/log_vote(text)
	if(config.log_vote)
		rustg_log_write(GLOB.world_game_log, "VOTE: [text][GLOB.log_end]")

/proc/log_access_in(client/new_client)
	if(config.log_access)
		var/message = "[key_name(new_client)] - IP:[new_client.address] - CID:[new_client.computer_id] - BYOND v[new_client.byond_version]"
		rustg_log_write(GLOB.world_game_log, "ACCESS IN: [message][GLOB.log_end]")

/proc/log_access_out(mob/last_mob)
	if(config.log_access)
		var/message = "[key_name(last_mob)] - IP:[last_mob.lastKnownIP] - CID:[last_mob.computer_id] - BYOND Logged Out"
		rustg_log_write(GLOB.world_game_log, "ACCESS OUT: [message][GLOB.log_end]")

/proc/log_say(text, mob/speaker)
	if(config.log_say)
		rustg_log_write(GLOB.world_game_log, "SAY: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_whisper(text, mob/speaker)
	if(config.log_whisper)
		rustg_log_write(GLOB.world_game_log, "WHISPER: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_ooc(text, client/user)
	if(config.log_ooc)
		rustg_log_write(GLOB.world_game_log, "OOC: [user.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_aooc(text, client/user)
	if(config.log_ooc)
		rustg_log_write(GLOB.world_game_log, "AOOC: [user.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_looc(text, client/user)
	if(config.log_ooc)
		rustg_log_write(GLOB.world_game_log, "LOOC: [user.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_emote(text, mob/speaker)
	if(config.log_emote)
		rustg_log_write(GLOB.world_game_log, "EMOTE: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_attack(attacker, defender, message)
	if(config.log_attack)
		rustg_log_write(GLOB.world_game_log, "ATTACK: [attacker] against [defender]: [message][GLOB.log_end]") //Seperate attack logs? Why?

/proc/log_adminsay(text, mob/speaker)
	if(config.log_adminchat)
		rustg_log_write(GLOB.world_game_log, "ADMINSAY: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_qdel(text)
	rustg_log_write(GLOB.world_qdel_log, "QDEL: [text][GLOB.log_end]")

/proc/log_mentorsay(text, mob/speaker)
	if(config.log_adminchat)
		rustg_log_write(GLOB.world_game_log, "MENTORSAY: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_ghostsay(text, mob/speaker)
	if(config.log_say)
		rustg_log_write(GLOB.world_game_log, "DEADCHAT: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_ghostemote(text, mob/speaker)
	if(config.log_emote)
		rustg_log_write(GLOB.world_game_log, "DEADEMOTE: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_adminwarn(text)
	if(config.log_adminwarn)
		rustg_log_write(GLOB.world_game_log, "ADMINWARN: [html_decode(text)][GLOB.log_end]")

/proc/log_pda(text, mob/speaker)
	if(config.log_pda)
		rustg_log_write(GLOB.world_game_log, "PDA: [speaker.simple_info_line()]: [html_decode(text)][GLOB.log_end]")

/proc/log_chat(text, mob/speaker)
	if(config.log_pda)
		rustg_log_write(GLOB.world_game_log, "CHAT: [speaker.simple_info_line()] [html_decode(text)][GLOB.log_end]")

/proc/log_misc(text)
	rustg_log_write(GLOB.world_game_log, "MISC: [text][GLOB.log_end]")

/proc/log_world(text)
	SEND_TEXT(world.log, text)
	if(config && config.log_world_output)
		rustg_log_write(GLOB.world_game_log, "WORLD: [html_decode(text)][GLOB.log_end]")

/proc/log_runtime_txt(text) // different from /tg/'s log_runtime because our error handler has a log_runtime proc already that does other stuff
	rustg_log_write(GLOB.world_runtime_log, "[text][GLOB.log_end]")

/proc/log_config(text)
	rustg_log_write(GLOB.config_error_log, "[text][GLOB.log_end]")
	SEND_TEXT(world.log, text)

/proc/log_href(text)
	rustg_log_write(GLOB.world_href_log, "HREF: [html_decode(text)][GLOB.log_end]")

/proc/log_asset(text)
	rustg_log_write(GLOB.world_asset_log, "ASSET: [text][GLOB.log_end]")

/proc/log_runtime_summary(text)
	rustg_log_write(GLOB.runtime_summary_log, "[text][GLOB.log_end]")

/proc/log_tgui(text)
	rustg_log_write(GLOB.tgui_log, "[text][GLOB.log_end]")

/proc/log_sql(text)
	rustg_log_write(GLOB.sql_log, "[text][GLOB.log_end]")
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
	rustg_log_write(log, "Starting up. Round ID is [GLOB.round_id ? GLOB.round_id : "NULL"]\n-------------------------[GLOB.log_end]")

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
