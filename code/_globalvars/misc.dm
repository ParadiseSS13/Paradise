GLOBAL_DATUM(plmaster, /obj/effect/overlay)
GLOBAL_DATUM(slmaster, /obj/effect/overlay)

GLOBAL_VAR_INIT(CELLRATE, 0.002)  // conversion ratio between a watt-tick and kilojoule
GLOBAL_VAR_INIT(CHARGELEVEL, 0.001) // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

// Announcer intercom, because too much stuff creates an intercom for one message then hard del()s it.
GLOBAL_DATUM_INIT(global_announcer, /obj/item/radio/intercom, create_global_announcer())
GLOBAL_DATUM_INIT(command_announcer, /obj/item/radio/intercom/command, create_command_announcer())

// Load order issues means this can't be new'd until other code runs
// This is probably not the way I should be doing this, but I don't know how to do it right!
proc/create_global_announcer()
  spawn(0)
    GLOB.global_announcer = new(null)
  return

proc/create_command_announcer()
  spawn(0)
    GLOB.command_announcer = new(null)
  return

GLOBAL_LIST_INIT(paper_tag_whitelist, list("center","p","div","span","h1","h2","h3","h4","h5","h6","hr","pre",	\
	"big","small","font","i","u","b","s","sub","sup","tt","br","hr","ol","ul","li","caption","col",	\
	"table","td","th","tr"))
GLOBAL_LIST_INIT(paper_blacklist, list("java","onblur","onchange","onclick","ondblclick","onfocus","onkeydown",	\
	"onkeypress","onkeyup","onload","onmousedown","onmousemove","onmouseout","onmouseover",	\
	"onmouseup","onreset","onselect","onsubmit","onunload"))

//Reverse of dir
GLOBAL_LIST_INIT(reverse_dir, list(2, 1, 3, 8, 10, 9, 11, 4, 6, 5, 7, 12, 14, 13, 15, 32, 34, 33, 35, 40, 42, 41, 43, 36, 38, 37, 39, 44, 46, 45, 47, 16, 18, 17, 19, 24, 26, 25, 27, 20, 22, 21, 23, 28, 30, 29, 31, 48, 50, 49, 51, 56, 58, 57, 59, 52, 54, 53, 55, 60, 62, 61, 63))
GLOBAL_VAR_INIT(gravity_is_on, 1) //basically unused, just one admin verb..
// Recall time limit:  2 hours
GLOBAL_VAR_INIT(recall_time_limit, 72000) //apparently used for the comm console

//////SCORE STUFF
//Goonstyle scoreboard
GLOBAL_VAR_INIT(score_crewscore, 0) // this is the overall var/score for the whole round
GLOBAL_VAR_INIT(score_stuffshipped, 0) // how many useful items have cargo shipped out?
GLOBAL_VAR_INIT(score_stuffharvested, 0) // how many harvests have hydroponics done?
GLOBAL_VAR_INIT(score_oremined, 0) // obvious
GLOBAL_VAR_INIT(score_researchdone, 0)
GLOBAL_VAR_INIT(score_eventsendured, 0) // how many random events did the station survive?
GLOBAL_VAR_INIT(score_powerloss, 0) // how many APCs have poor charge?
GLOBAL_VAR_INIT(score_escapees, 0) // how many people got out alive?
GLOBAL_VAR_INIT(score_deadcrew, 0) // dead bodies on the station, oh no
GLOBAL_VAR_INIT(score_mess, 0) // how much poo, puke, gibs, etc went uncleaned
GLOBAL_VAR_INIT(score_meals, 0)
GLOBAL_VAR_INIT(score_disease, 0) // how many rampant, uncured diseases are on board the station
GLOBAL_VAR_INIT(score_deadcommand, 0) // used during rev, how many command staff perished
GLOBAL_VAR_INIT(score_arrested, 0) // how many traitors/revs/whatever are alive in the brig
GLOBAL_VAR_INIT(score_traitorswon, 0) // how many traitors were successful?
GLOBAL_VAR_INIT(score_allarrested, 0) // did the crew catch all the enemies alive?
GLOBAL_VAR_INIT(score_opkilled, 0) // used during nuke mode, how many operatives died?
GLOBAL_VAR_INIT(score_disc, 0) // is the disc safe and secure?
GLOBAL_VAR_INIT(score_nuked, 0) // was the station blown into little bits?
GLOBAL_VAR_INIT(score_nuked_penalty, 0) //penalty for getting blown to bits

	// these ones are mainly for the stat panel
GLOBAL_VAR_INIT(score_powerbonus, 0) // if all APCs on the station are running optimally, big bonus
GLOBAL_VAR_INIT(score_messbonus, 0) // if there are no messes on the station anywhere, huge bonus
GLOBAL_VAR_INIT(score_deadaipenalty, 0) // is the AI dead? if so, big penalty
GLOBAL_VAR_INIT(score_foodeaten, 0) // nom nom nom
GLOBAL_VAR_INIT(score_clownabuse, 0) // how many times a clown was punched, struck or otherwise maligned
GLOBAL_VAR(score_richestname) // this is all stuff to show who was the richest alive on the shuttle
GLOBAL_VAR(score_richestjob)  // kinda pointless if you dont have a money system i guess
GLOBAL_VAR_INIT(score_richestcash, 0)
GLOBAL_VAR(score_richestkey)
GLOBAL_VAR(score_dmgestname) // who had the most damage on the shuttle (but was still alive)
GLOBAL_VAR(score_dmgestjob)
GLOBAL_VAR_INIT(score_dmgestdamage, 0)
GLOBAL_VAR(score_dmgestkey)

#define TAB "&nbsp;&nbsp;&nbsp;&nbsp;"

GLOBAL_VAR_INIT(timezoneOffset, 0) // The difference betwen midnight (of the host computer) and 0 world.ticks.

// For FTP requests. (i.e. downloading runtime logs.)
// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
GLOBAL_VAR_INIT(fileaccess_timer, 0)

GLOBAL_VAR_INIT(gametime_offset, 432000) // 12:00 in seconds

//printers shutdown if too much shit printed
GLOBAL_VAR_INIT(copier_items_printed, 0)
GLOBAL_VAR_INIT(copier_max_items, 300)
GLOBAL_VAR_INIT(copier_items_printed_logged, FALSE)


GLOBAL_VAR(map_name) // Self explanatory

GLOBAL_DATUM(data_core, /datum/datacore) // Station datacore, manifest, etc

GLOBAL_VAR_INIT(panic_bunker_enabled, FALSE) // Is the panic bunker enabled

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
// This is a protected datum which means its read only. I hope the reason for protecting this is obvious
GLOBAL_DATUM_INIT(dbcon, /DBConnection, new)	//Feedback database (New database)
GLOBAL_PROTECT(dbcon)

GLOBAL_LIST_EMPTY(ability_verbs) // Create-level abilities
GLOBAL_LIST_INIT(pipe_colors, list("grey" = PIPE_COLOR_GREY, "red" = PIPE_COLOR_RED, "blue" = PIPE_COLOR_BLUE, "cyan" = PIPE_COLOR_CYAN, "green" = PIPE_COLOR_GREEN, "yellow" = PIPE_COLOR_YELLOW, "purple" = PIPE_COLOR_PURPLE))
