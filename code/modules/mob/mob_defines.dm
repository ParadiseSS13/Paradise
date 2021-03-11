/mob
	density = 1
	layer = MOB_LAYER
	animate_movement = 2
	pressure_resistance = 8
	throwforce = 10
	dont_save = TRUE //to avoid it messing up in buildmode saving
	var/datum/mind/mind

	var/stat = 0 //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

	/// The zone this mob is currently targeting
	var/zone_selected = null

	var/obj/screen/hands = null
	var/obj/screen/pullin = null
	var/obj/screen/i_select = null
	var/obj/screen/m_select = null
	var/obj/screen/healths = null
	var/obj/screen/throw_icon = null

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/obj/screen/leap_icon = null
	var/obj/screen/healthdoll/healthdoll = null

	var/use_me = 1 //Allows all mobs to use the me verb by default, will have to manually specify they cannot
	var/damageoverlaytemp = 0
	var/computer_id = null
	var/lastattacker = null // real name of the person  doing the attacking
	var/lastattackerckey = null // their ckey
	var/list/attack_log_old = list( )
	var/list/debug_log = null

	var/last_known_ckey = null	// Used in logging

	var/last_log = 0
	var/obj/machinery/machine = null
	var/other_mobs = null
	var/memory = ""
	var/next_move = null
	var/notransform = null	//Carbon
	var/hand = null
	var/real_name = null
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/lying = 0
	var/lying_prev = 0
	var/lastpuke = 0
	var/can_strip = 1
	var/list/languages = list()         // For speaking/listening.
	var/list/abilities = list()         // For species-derived or admin-given powers.
	var/list/speak_emote = list("says") // Verbs used when speaking. Defaults to 'say' if speak_emote is null.
	var/emote_type = 1		// Define emote default type, 1 for seen emotes, 2 for heard emotes
	var/name_archive //For admin things like possession

	var/timeofdeath = 0 //Living

	var/bodytemperature = 310.055	//98.7 F
	var/flying = 0
	var/nutrition = NUTRITION_LEVEL_FED + 50 //Carbon
	var/satiety = 0 //Carbon
	var/hunger_drain = HUNGER_FACTOR // how quickly the mob gets hungry; largely utilized by species.

	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/intent = null //Living
	var/a_intent = INTENT_HELP //Living
	var/m_intent = MOVE_INTENT_RUN //Living
	var/lastKnownIP = null
	/// movable atoms buckled to this mob
	var/atom/movable/buckled = null //Living
	/// movable atom we are buckled to
	var/atom/movable/buckling

	var/obj/item/l_hand = null //Living
	var/obj/item/r_hand = null //Living
	var/obj/item/back = null //Human
	var/obj/item/tank/internal = null //Human
	/// Active storage container
	var/obj/item/storage/s_active = null //Carbon
	var/obj/item/clothing/mask/wear_mask = null //Carbon

	var/datum/hud/hud_used = null

	hud_possible = list(SPECIALROLE_HUD)

	var/research_scanner = 0 //For research scanner equipped mobs. Enable to show research data when examining.

	var/list/grabbed_by = list()
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/emote_cd = 0		// Used to supress emote spamming. 1 if on CD, 2 if disabled by admin (manually set), else 0

	var/job = null //Living

	var/datum/dna/dna = null //Carbon
	var/radiation = 0 //Carbon

	var/voice_name = "unidentifiable voice"

	var/list/faction = list("neutral") //Used for checking whether hostile simple animals will attack you, possibly more stuff later

	var/move_on_shuttle = 1 // Can move on the shuttle.


	var/has_enabled_antagHUD = 0  // Whether antagHUD was ever enabled. Not a true boolean - sometimes it is set to 2, because reasons.
	var/antagHUD = FALSE  // Whether AntagHUD is active right now
	var/can_change_intents = 1 //all mobs can change intents by default.
	///Override for sound_environments. If this is set the user will always hear a specific type of reverb (Instead of the area defined reverb)
	var/sound_environment_override = SOUND_ENVIRONMENT_NONE

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

//List of active diseases

	var/list/viruses = list() // list of all diseases in a mob
	var/list/resistances = list()

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/status_flags = CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/area/lastarea = null

	var/digitalcamo = 0 // Can they be tracked by the AI?

	var/has_unlimited_silicon_privilege = 0 // Can they interact with station electronics

	var/atom/movable/remote_control //Calls relaymove() to whatever it is

	var/obj/control_object //Used by admins to possess objects. All mobs should have this var

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/universal_understand = 0 // Set to 1 to enable the mob to understand everyone, not necessarily speak
	var/robot_talk_understand = 0
	var/alien_talk_understand = 0

	var/has_limbs = 1 //Whether this mob have any limbs he can move with

	//SSD var, changed it up some so people can have special things happen for different mobs when SSD.
	var/player_logged = 0

	//Ghosted var, set only if a player has manually ghosted out of this mob.
	var/player_ghosted = 0

	var/turf/listed_turf = null  //the current turf being examined in the stat panel
	var/list/shouldnt_see = list()	//list of objects that this mob shouldn't see in the stat panel. this silliness is needed because of AI alt+click and cult blood runes

	var/stance_damage = 0 //Whether this mob's ability to stand has been affected

	var/list/active_mutations = list()

	var/last_movement = -100 // Last world.time the mob actually moved of its own accord.

	var/last_logout = 0

	var/resize = 1 //Badminnery resize

	var/datum/vision_override/vision_type = null //Vision override datum.

	var/list/permanent_huds = list()

	var/list/actions = list()
	var/list/datum/action/chameleon_item_actions

	var/list/progressbars = null	//for stacking do_after bars

	var/list/tkgrabbed_objects = list() // Assoc list of items to TK grabs

	var/forced_look = null // This can either be a numerical direction or a soft object reference (UID). It makes the mob always face towards the selected thing.
	var/registered_z

	var/obj/effect/proc_holder/ranged_ability //Any ranged ability the mob has, as a click override

	/// The location our runechat message should appear. Should be src by default.
	var/atom/runechat_msg_location
