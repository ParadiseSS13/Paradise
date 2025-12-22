/mob
	density = TRUE
	layer = MOB_LAYER
	animate_movement = SLIDE_STEPS
	// We probably shouldn't ever be setting this. LONG_GLIDE makes diagonal movement faster, because you move at full speed on both axes. However, we have manual changes scatterd around that undo this, and re-establish euclidian movement. Yes, that's exactly as silly as it sounds.
	// Still, for the moment, we should at least make all mobs behave the same way that carbons do.
	appearance_flags = LONG_GLIDE
	pressure_resistance = 8
	throwforce = 10
	var/datum/mind/mind
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	rad_insulation_beta = RAD_MOB_INSULATION
	rad_insulation_gamma = RAD_MOB_INSULATION

	/// Is this mob alive, unconscious or dead?
	var/stat = CONSCIOUS // TODO: Move to /mob/living

	/// The zone this mob is currently targeting
	var/zone_selected = null

	var/atom/movable/screen/pullin = null
	var/atom/movable/screen/i_select = null
	var/atom/movable/screen/m_select = null
	var/atom/movable/screen/healths = null
	var/atom/movable/screen/throw_icon = null
	var/atom/movable/screen/staminas = null

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/atom/movable/screen/leap_icon = null
	var/atom/movable/screen/healthdoll/healthdoll = null
	var/atom/movable/screen/nutrition/nutrition_display = null

	var/use_me = TRUE //Allows all mobs to use the me verb by default, will have to manually specify they cannot
	var/damageoverlaytemp = 0
	var/computer_id = null
	var/list/attack_log_old = list()
	var/list/debug_log = null

	var/last_known_ckey = null	// Used in logging

	var/last_log = 0
	var/obj/machinery/machine = null
	var/list/grab_do_not_move = list()  /// other mobs we wont move when we're grab pulled. Not empty only when being grab pulled
	var/memory = ""
	var/notransform = FALSE	//Carbon
	/// True for left hand active, otherwise for right hand active
	var/hand = HAND_BOOL_RIGHT
	var/real_name = null
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/lying_prev = 0
	var/lastpuke = 0
	var/list/languages = list()         // For speaking/listening.
	var/list/speak_emote = list("says") // Verbs used when speaking. Defaults to 'say' if speak_emote is null.
	var/emote_type = EMOTE_VISIBLE		// Define emote default type, 1 for seen emotes, 2 for heard emotes
	var/name_archive //For admin things like possession

	var/timeofdeath = 0 //Living

	var/bodytemperature = 310.055	//98.7 F
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

	var/obj/item/l_hand = null //Living
	var/obj/item/r_hand = null //Living
	var/obj/item/back = null //Human
	var/obj/item/tank/internal = null //Human
	/// Active storage container
	var/obj/item/storage/s_active
	/// The currently worn mask
	var/obj/item/wear_mask

	/// The instantiated version of the mob's hud.
	var/datum/hud/hud_used = null

	hud_possible = list(SPECIALROLE_HUD)

	var/research_scanner = FALSE //For research scanner equipped mobs. Enable to show research data when examining.

	var/list/grabbed_by = list()
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	var/list/mapobjs = list()

	var/in_throw_mode = FALSE

	// See /datum/emote

	/// Cooldown on audio effects from emotes.
	var/audio_emote_cd_status = EMOTE_READY

	/// Cooldown on audio effects from unintentional emotes.
	var/audio_emote_unintentional_cd_status = EMOTE_READY

	/// Override for cooldowns on non-audio emotes. Should be a number in deciseconds.
	var/emote_cooldown_override = null

	/// Tracks last uses of emotes for cooldown purposes
	var/list/emotes_used

	var/job = null //Living

	var/datum/dna/dna = null //Carbon
	var/radiation = 0 //Carbon

	var/voice_name = "unidentifiable voice"

	var/list/faction = list("neutral") //Used for checking whether hostile simple animals will attack you, possibly more stuff later

	var/move_on_shuttle = TRUE // Can move on the shuttle.

	/// The type of HUD that this mob uses. Not to
	var/hud_type = /datum/hud

	var/antagHUD = FALSE  // Whether AntagHUD is active right now
	var/can_change_intents = TRUE //all mobs can change intents by default.
	///Override for sound_environments. If this is set the user will always hear a specific type of reverb (Instead of the area defined reverb)
	var/sound_environment_override = SOUND_ENVIRONMENT_NONE

//Generic list for proc holders. Only way I can see to enable certain verbs/procs. Should be modified if needed.
	var/proc_holder_list[] = list()

	var/list/mob_spell_list = list() //construct spells and mime spells. Spells that do not transfer from one mob to another and can not be lost in mindswap.

//List of active diseases

	var/list/viruses = list() // list of all diseases in a mob
	var/list/resistances = list()

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/status_flags = CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/area/lastarea = null

	var/has_unlimited_silicon_privilege = FALSE // Can they interact with station electronics

	var/atom/movable/remote_control //Calls relaymove() to whatever it is

	var/obj/control_object //Used by admins to possess objects. All mobs should have this var

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = FALSE // Set to TRUE to enable the mob to speak to everyone -- TLE
	var/universal_understand = FALSE // Set to TRUE to enable the mob to understand everyone, not necessarily speak

	var/has_limbs = 1 //Whether this mob have any limbs he can move with

	//SSD var, changed it up some so people can have special things happen for different mobs when SSD.
	var/player_logged = 0

	//Ghosted var, set only if a player has manually ghosted out of this mob.
	var/player_ghosted = 0

	var/turf/listed_turf = null  //the current turf being examined in the stat panel
	var/list/shouldnt_see = list()	//list of objects that this mob shouldn't see in the stat panel. this silliness is needed because of AI alt+click and cult blood runes

	var/stance_damage = 0 //Whether this mob's ability to stand has been affected

	/// List of the active mutation types
	var/list/active_mutations = list()

	var/last_movement = -100 // Last world.time the mob actually moved of its own accord.

	/// The direction they last moved
	var/last_movement_dir

	var/last_logout = 0

	var/resize = 1 //Badminnery resize

	var/list/permanent_huds = list()

	var/list/actions = list()
	var/list/datum/action/chameleon_item_actions

	var/list/progressbars = null	//for stacking do_after bars

	var/list/tkgrabbed_objects = list() // Assoc list of items to TK grabs

	var/registered_z

	var/datum/spell/ranged_ability //Any ranged ability the mob has, as a click override

	/// Overrides the health HUD element state if set.
	var/health_hud_override = HEALTH_HUD_OVERRIDE_NONE
	/// A soft reference to the location where this mob's runechat message will appear. Uses `UID()`.
	var/runechat_msg_location
	/// The datum receiving keyboard input. parent mob by default.
	var/datum/input_focus = null
	/// Is our mob currently suiciding? Used for suicide code along with many different revival checks
	var/suiciding = FALSE
	/// Used for some screen objects
	var/list/screens = list()
	/// lazy list. contains /atom/movable/screen/alert only,  On /mob so clientless mobs will throw alerts properly
	var/list/alerts
	/// Makes items bloody if you touch them
	var/bloody_hands = 0
	/// Basically a lazy list, copies the DNA of blood you step in
	var/list/feet_blood_DNA
	/// affects the blood color of your feet, color taken from the blood you step in
	var/feet_blood_color
	/// Weirdly named, effects how blood transfers onto objects
	var/blood_state = BLOOD_STATE_NOT_BLOODY
	/// Assoc list for tracking how "bloody" a mobs feet are, used for creating bloody foot/shoeprints on turfs when moving
	var/list/bloody_feet = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_NOT_BLOODY = 0, BLOOD_BASE_ALPHA = BLOODY_FOOTPRINT_BASE_ALPHA)
	/// Affects if you have a typing indicator
	var/typing
	/// Affects if you have a thinking indicator
	var/thinking
	/// Last thing we typed in to the typing indicator, probably does not need to exist
	var/last_typed
	/// Last time we typed something in to the typing popup
	var/last_typed_time
	// Ran after next_click on most item interactions, used in any case where we aren't required to use next click Eg: Action buttons
	var/next_move
	/// Unused, used to adjust our next move on a linar skill world.time + (how_many_deciseconds + Next move adjust) = Next move
	var/next_move_adjust = 0
	/// Value to multiply action delays by, actually used world.time + (how_many_deciseconds * Next move Adjust) = Next move
	var/next_move_modifier = 1
	// 1 decisecond click delay (above and beyond mob/next_move)
	/// This is mainly modified by click code, to modify click delays elsewhere, use next_move and changeNext_move(), Controls the click delay. Changed with
	var/next_click	= 0

	// Does not effect the build in tick delay of click, can't go below 1 click per tick
	/// Unused
	var/next_click_adjust = 0
	/// Unused
	var/next_click_modifier = 1
	/// Tracks the open UIs that a mob has, used in TGUI for various things, such as updating UIs
	var/list/open_uis = list()
	/// List of observers currently observing us.
	var/list/mob/dead/observer/observers = list()
	/// Does this mob speak OOC?
	/// Controls whether they can say some symbols.
	var/speaks_ooc = FALSE
	/// Allows a datum to intercept all click calls this mob is the source of.
	/// This is *not* necessarily an instance of [/datum/click_intercept].
	var/datum/click_interceptor

	/// gunshot residue for det work. holds the caliber of any BALLISTIC weapon fired by this mob without gloves.
	var/gunshot_residue
	/// For storing what do_after's something has, key = string, value = amount of interactions of that type happening.
	var/list/do_afters
	new_attack_chain = TRUE

	var/list/mousepointers = list()
