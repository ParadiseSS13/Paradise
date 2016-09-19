//print an error message to world.log

// On Linux/Unix systems the line endings are LF, on windows it's CRLF, admins that don't use notepad++
// will get logs that are one big line if the system is Linux and they are using notepad.  This solves it by adding CR to every line ending
// in the logs.  ascii character 13 = CR

/var/global/log_end= world.system_type == UNIX ? ascii2text(13) : ""


/proc/error(msg)
	log_to_dd("## ERROR: [msg]")

#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
//print a warning message to world.log
/proc/warning(msg)
	log_to_dd("## WARNING: [msg]")

//print a testing-mode debug message to world.log
/proc/testing(msg)
	log_to_dd("## TESTING: [msg]")

/proc/log_admin(text)
	admin_log.Add(text)
	if(config.log_admin)
		diary << "\[[time_stamp()]]ADMIN: [text]"


/proc/log_debug(text)
	if(config.log_debug)
		diary << "\[[time_stamp()]]DEBUG: [text]"

	for(var/client/C in admins)
		if(check_rights(R_DEBUG, 0, C.mob) && (C.prefs.toggles & CHAT_DEBUGLOGS))
			to_chat(C, "DEBUG: [text]")


/proc/log_game(text)
	if(config.log_game)
		diary << "\[[time_stamp()]]GAME: [text]"

/proc/log_vote(text)
	if(config.log_vote)
		diary << "\[[time_stamp()]]VOTE: [text]"

/proc/log_access(text)
	if(config.log_access)
		diary << "\[[time_stamp()]]ACCESS: [text]"

/proc/log_say(text)
	if(config.log_say)
		diary << "\[[time_stamp()]]SAY: [text]"

/proc/log_ooc(text)
	if(config.log_ooc)
		diary << "\[[time_stamp()]]OOC: [text]"

/proc/log_whisper(text)
	if(config.log_whisper)
		diary << "\[[time_stamp()]]WHISPER: [text]"

/proc/log_emote(text)
	if(config.log_emote)
		diary << "\[[time_stamp()]]EMOTE: [text]"

/proc/log_attack(text)
	if(config.log_attack)
		diary << "\[[time_stamp()]]ATTACK: [text]" //Seperate attack logs? Why?

/proc/log_adminsay(text)
	if(config.log_adminchat)
		diary << "\[[time_stamp()]]ADMINSAY: [text]"

/proc/log_adminwarn(text)
	if(config.log_adminwarn)
		diary << "\[[time_stamp()]]ADMINWARN: [text]"

/proc/log_pda(text)
	if(config.log_pda)
		diary << "\[[time_stamp()]]PDA: [text][log_end]"

/proc/log_misc(text)
	diary << "\[[time_stamp()]]MISC: [text][log_end]"

/proc/log_to_dd(text)
	world.log << text
	if(config && config.log_world_output)
		diary << "\[[time_stamp()]]DD_OUTPUT: [text][log_end]"

/**
 * Standardized method for tracking startup times.
 */
/proc/log_startup_progress(var/message)
	to_chat(world, "<span class='danger'>[message]</span>")
	log_to_dd(message)

// A logging proc that only outputs after setup is done, to
// help devs test initialization stuff that happens a lot
/proc/log_after_setup(var/message)
	if(ticker && ticker.current_state > GAME_STATE_SETTING_UP)
		to_chat(world, "<span class='danger'>[message]</span>")
		log_to_dd(message)

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
