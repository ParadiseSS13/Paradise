/mob
	density = 1
	layer = 4.0
	animate_movement = 2
	pressure_resistance = 8
	var/datum/mind/mind

	var/stat = CONSCIOUS //Whether a mob is among the living or the dead.

	var/lying = 0
	var/zone_selected = null

	var/obj/screen/hands = null
	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/

	var/use_me = 1 //Allows all mobs to use the me verb by default, will have to manually specify they cannot
	var/damageoverlaytemp = 0
	var/computer_id = null
	var/lastattacker = null
	var/lastattacked = null
	var/attack_log = list( )
	// Would be better if this supported more than 1 thing
	var/obj/machinery/machine = null
	var/other_mobs = null
	var/memory = ""
	var/atom/movable/pulling = null
	var/next_move = null
	var/notransform = null	//Carbon
	var/other = 0.0
	var/hand = null
	/*
	Cult-specific vars
	*/

	var/bhunger = 0			//Carbon
	var/ajourn = 0

	var/real_name = null
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/canmove = 1
	var/lastpuke = 0
	var/unacidable = 0
	var/can_strip = 1
	var/list/pinned = list()            //List of things pinning this creature to walls (see living_defense.dm)
	var/list/embedded = list()          //Embedded items, since simple mobs don't have organs.
	var/list/languages = list()         // For speaking/listening.
	var/list/abilities = list()         // For species-derived or admin-given powers.
	var/list/speak_emote = list("says") // Verbs used when speaking. Defaults to 'say' if speak_emote is null.
	var/emote_type = 1		// Define emote default type, 1 for seen emotes, 2 for heard emotes
	var/name_archive //For admin things like possession

	var/timeofdeath = 0.0//Living
	var/cpr_time = 1.0//Carbon


	var/bodytemperature = 310.055	//98.7 F
	var/flying = 0
	var/spinning = 0
	var/charges = 0.0
	var/nutrition = 400.0//Carbon

	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/intent = null//Living
	var/shakecamera = 0
	var/a_intent = I_HELP//Living
	var/m_intent = "run"//Living
	var/lastKnownIP = null
	var/atom/movable/buckled = null//Living
	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living
	var/obj/item/weapon/back = null//Human/Monkey
	var/obj/item/weapon/tank/internal = null//Human/Monkey
	var/obj/item/weapon/storage/s_active = null//Carbon
	var/obj/item/clothing/mask/wear_mask = null//Carbon

	var/seer = 0 //for cult//Carbon, probably Human

	// To let a mob permanently have a different see_invisible level
	var/see_override = 0

	// A list of observers looking at this mob - used to let ghosts see what exactly
	// someone is doing
	var/list/observers = list()

	var/datum/hud/hud_used = null

	hud_possible = list(SPECIALROLE_HUD)

	var/research_scanner = 0 //For research scanner equipped mobs. Enable to show research data when examining.

	var/list/grabbed_by = list()
	var/list/requests = list()

	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/coughedtime = null

	var/emote_cd = 0		// Used to supress emote spamming. 1 if on CD, 2 if disabled by admin (manually set), else 0

	var/job = null//Living

	var/datum/dna/dna = null//Carbon
	var/radiation = 0 //Carbon

	var/list/mutations = list() //Carbon -- Doohl
	//see: setup.dm for list of mutations

	var/voice_name = "unidentifiable voice"

	var/list/faction = list("neutral") //Used for checking whether hostile simple animals will attack you, possibly more stuff later

	var/move_on_shuttle = 1 // Can move on the shuttle.

	var/has_enabled_antagHUD = 0
	var/antagHUD = 0

//Generic list for proc holders. Only way I can see to enable certain verbs/procs. Should be modified if needed.
	var/proc_holder_list[] = list()

	/* //Also unlike the spell list, this would only store the object in contents, not an object in itself.

	Add this line to whatever stat module you need in order to use the proc holder list.
	Unlike the object spell system, it's also possible to attach verb procs from these objects to right-click menus.
	This requires creating a verb for the object proc holder.

	if(proc_holder_list.len)//Generic list for proc_holder objects.
		for(var/obj/effect/proc_holder/P in proc_holder_list)
			statpanel("[P.panel]","",P)*/

//The last mob/living/carbon to push/drag/grab this mob (mostly used by slimes friend recognition)
	var/mob/living/carbon/LAssailant = null

	var/list/mob_spell_list = list() //construct spells and mime spells. Spells that do not transfer from one mob to another and can not be lost in mindswap.

//Changlings, but can be used in other modes
//	var/obj/effect/proc_holder/changpower/list/power_list = list()

//List of active diseases

	var/list/viruses = list() // replaces var/datum/disease/virus
	var/list/resistances = list()

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/status_flags = CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/area/lastarea = null

	var/digitalcamo = 0 // Can they be tracked by the AI?
	var/weakeyes = 0 //Are they vulnerable to flashes?

	var/has_unlimited_silicon_privilege = 0 // Can they interact with station electronics

	var/atom/movable/remote_control //Calls relaymove() to whatever it is

	var/remote_view = 0 // Set to 1 to prevent view resets on Life

	var/obj/control_object //Used by admins to possess objects. All mobs should have this var
	var/datum/visibility_interface/visibility_interface = null // used by the visibility system to provide an interface for the visibility networks

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/universal_understand = 0 // Set to 1 to enable the mob to understand everyone, not necessarily speak
	var/robot_talk_understand = 0
	var/alien_talk_understand = 0

	var/has_limbs = 1 //Whether this mob have any limbs he can move with

	//SSD var, changed it up some so people can have special things happen for different mobs when SSD.
	var/player_logged = 0

	var/turf/listed_turf = null  //the current turf being examined in the stat panel
	var/list/shouldnt_see = list(/atom/movable/lighting_overlay)	//list of objects that this mob shouldn't see in the stat panel. this silliness is needed because of AI alt+click and cult blood runes

	var/kills = 0

	var/stance_damage = 0 //Whether this mob's ability to stand has been affected

	var/list/active_genes = list()

	var/last_movement = -100 // Last world.time the mob actually moved of its own accord.

	var/resize = 1 //Badminnery resize

	var/datum/vision_override/vision_type = null //Vision override datum.

	var/list/permanent_huds = list()

	var/list/actions = list()
