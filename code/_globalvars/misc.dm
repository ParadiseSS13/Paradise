var/global/obj/effect/overlay/plmaster = null
var/global/obj/effect/overlay/slmaster = null
var/global/obj/effect/overlay/icemaster = null

// Event Manager, the manager for events.
var/datum/event_manager/event_manager = new()
// Announcer intercom, because too much stuff creates an intercom for one message then hard del()s it.
var/global/obj/item/radio/intercom/global_announcer = create_global_announcer()
var/global/obj/item/radio/intercom/command/command_announcer = create_command_announcer()
// Load order issues means this can't be new'd until other code runs
// This is probably not the way I should be doing this, but I don't know how to do it right!
proc/create_global_announcer()
  spawn(0)
    global_announcer = new(null)
  return

proc/create_command_announcer()
  spawn(0)
    command_announcer = new(null)
  return

var/list/paper_tag_whitelist = list("center","p","div","span","h1","h2","h3","h4","h5","h6","hr","pre",	\
	"big","small","font","i","u","b","s","sub","sup","tt","br","hr","ol","ul","li","caption","col",	\
	"table","td","th","tr")
var/list/paper_blacklist = list("java","onblur","onchange","onclick","ondblclick","onfocus","onkeydown",	\
	"onkeypress","onkeyup","onload","onmousedown","onmousemove","onmouseout","onmouseover",	\
	"onmouseup","onreset","onselect","onsubmit","onunload")

//Reverse of dir
var/list/reverse_dir = list(2, 1, 3, 8, 10, 9, 11, 4, 6, 5, 7, 12, 14, 13, 15, 32, 34, 33, 35, 40, 42, 41, 43, 36, 38, 37, 39, 44, 46, 45, 47, 16, 18, 17, 19, 24, 26, 25, 27, 20, 22, 21, 23, 28, 30, 29, 31, 48, 50, 49, 51, 56, 58, 57, 59, 52, 54, 53, 55, 60, 62, 61, 63)
var/gravity_is_on = 1 //basically unused, just one admin verb..
// Recall time limit:  2 hours
var/recall_time_limit=72000 //apparently used for the comm console

//////SCORE STUFF
//Goonstyle scoreboard
var/score_crewscore = 0 // this is the overall var/score for the whole round
var/score_stuffshipped = 0 // how many useful items have cargo shipped out?
var/score_stuffharvested = 0 // how many harvests have hydroponics done?
var/score_oremined = 0 // obvious
var/score_researchdone = 0
var/score_eventsendured = 0 // how many random events did the station survive?
var/score_powerloss = 0 // how many APCs have poor charge?
var/score_escapees = 0 // how many people got out alive?
var/score_deadcrew = 0 // dead bodies on the station, oh no
var/score_mess = 0 // how much poo, puke, gibs, etc went uncleaned
var/score_meals = 0
var/score_disease = 0 // how many rampant, uncured diseases are on board the station
var/score_deadcommand = 0 // used during rev, how many command staff perished
var/score_arrested = 0 // how many traitors/revs/whatever are alive in the brig
var/score_traitorswon = 0 // how many traitors were successful?
var/score_allarrested = 0 // did the crew catch all the enemies alive?
var/score_opkilled = 0 // used during nuke mode, how many operatives died?
var/score_disc = 0 // is the disc safe and secure?
var/score_nuked = 0 // was the station blown into little bits?
var/score_nuked_penalty = 0 //penalty for getting blown to bits

	// these ones are mainly for the stat panel
var/score_powerbonus = 0 // if all APCs on the station are running optimally, big bonus
var/score_messbonus = 0 // if there are no messes on the station anywhere, huge bonus
var/score_deadaipenalty = 0 // is the AI dead? if so, big penalty
var/score_foodeaten = 0 // nom nom nom
var/score_clownabuse = 0 // how many times a clown was punched, struck or otherwise maligned
var/score_richestname = null // this is all stuff to show who was the richest alive on the shuttle
var/score_richestjob = null  // kinda pointless if you dont have a money system i guess
var/score_richestcash = 0
var/score_richestkey = null
var/score_dmgestname = null // who had the most damage on the shuttle (but was still alive)
var/score_dmgestjob = null
var/score_dmgestdamage = 0
var/score_dmgestkey = null

var/TAB = "&nbsp;&nbsp;&nbsp;&nbsp;"

GLOBAL_VAR_INIT(timezoneOffset, 0) // The difference betwen midnight (of the host computer) and 0 world.ticks.

// For FTP requests. (i.e. downloading runtime logs.)
// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0

GLOBAL_VAR_INIT(gametime_offset, 432000) // 12:00 in seconds

//printers shutdown if too much shit printed
var/copier_items_printed = 0
var/copier_max_items = 300
var/copier_items_printed_logged = FALSE