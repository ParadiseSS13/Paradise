//Preference toggles
#define SOUND_ADMINHELP		(1<<0)
#define SOUND_MIDI			(1<<1)
#define SOUND_AMBIENCE		(1<<2)
#define SOUND_LOBBY			(1<<3)
#define SOUND_HEARTBEAT		(1<<4)
#define SOUND_BUZZ			(1<<5)
#define SOUND_INSTRUMENTS	(1<<6)
#define SOUND_MENTORHELP	(1<<7)
#define SOUND_DISCO         (1<<8)
#define SOUND_AI_VOICE      (1<<9)
#define SOUND_PRAYERNOTIFY  (1<<10)
#define SOUND_MUTE_END_OF_ROUND  (1<<11)

#define SOUND_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|SOUND_HEARTBEAT|SOUND_BUZZ|SOUND_INSTRUMENTS|SOUND_MENTORHELP|SOUND_DISCO|SOUND_AI_VOICE|SOUND_PRAYERNOTIFY)

#define LIGHT_NEW_LIGHTING	(1<<0)
#define LIGHT_EXPOSURE		(1<<1)
#define LIGHT_GLARE			(1<<2)

#define LIGHT_DEFAULT		(LIGHT_NEW_LIGHTING|LIGHT_EXPOSURE|LIGHT_GLARE)

#define PREFTOGGLE_CHAT_OOC					(1<<0)
#define PREFTOGGLE_CHAT_DEAD				(1<<1)
#define PREFTOGGLE_CHAT_GHOSTEARS			(1<<2)
#define PREFTOGGLE_CHAT_GHOSTSIGHT			(1<<3)
#define PREFTOGGLE_CHAT_PRAYER				(1<<4) // Defunct
#define PREFTOGGLE_CHAT_RADIO				(1<<5)
// #define PREFTOGGLE_AZERTY					(1<<6) // obsolete
#define PREFTOGGLE_CHAT_DEBUGLOGS 			(1<<7)
#define PREFTOGGLE_CHAT_LOOC 				(1<<8)
#define PREFTOGGLE_CHAT_GHOSTRADIO 			(1<<9)
#define PREFTOGGLE_SHOW_TYPING 				(1<<10)
#define PREFTOGGLE_DISABLE_SCOREBOARD 		(1<<11)
// #define PREFTOGGLE_DISABLE_KARMA_REMINDER	(1<<12)	// Defunct as of 2023-03-12
#define PREFTOGGLE_MEMBER_PUBLIC			(1<<13)
#define PREFTOGGLE_CHAT_NO_ADMINLOGS 		(1<<14)
#define PREFTOGGLE_DONATOR_PUBLIC			(1<<15)
#define PREFTOGGLE_CHAT_NO_TICKETLOGS 		(1<<16)
// #define PREFTOGGLE_UI_DARKMODE 				(1<<17) // Defunct as of 2024-01-29
// #define PREFTOGGLE_DISABLE_KARMA 			(1<<18)	// Defunct as of 2023-03-12
#define PREFTOGGLE_CHAT_NO_MENTORTICKETLOGS  (1<<19)
// #define PREFTOGGLE_TYPING_ONCE 				(1<<20) // Defunct as of 2024-01-29
#define PREFTOGGLE_AMBIENT_OCCLUSION 		(1<<21)
#define PREFTOGGLE_CHAT_GHOSTPDA 			(1<<22)
// #define PREFTOGGLE_NUMPAD_TARGET 			(1<<23) // Made obsolete with key bindings

#define TOGGLES_TOTAL 							16777215 // If you add or remove a preference toggle above, make sure you update this define with the total value of the toggles combined.

#define TOGGLES_DEFAULT (PREFTOGGLE_CHAT_OOC|PREFTOGGLE_CHAT_DEAD|PREFTOGGLE_CHAT_GHOSTEARS|PREFTOGGLE_CHAT_GHOSTSIGHT|PREFTOGGLE_CHAT_PRAYER|PREFTOGGLE_CHAT_RADIO|PREFTOGGLE_CHAT_DEBUGLOGS|PREFTOGGLE_CHAT_LOOC|PREFTOGGLE_MEMBER_PUBLIC|PREFTOGGLE_DONATOR_PUBLIC|PREFTOGGLE_AMBIENT_OCCLUSION|PREFTOGGLE_CHAT_GHOSTPDA)

// toggles_2 variables. These MUST be prefixed with PREFTOGGLE_2
#define PREFTOGGLE_2_RANDOMSLOT						(1<<0) // 1
#define PREFTOGGLE_2_FANCYUI						(1<<1) // 2
#define PREFTOGGLE_2_ITEMATTACK						(1<<2) // 4
#define PREFTOGGLE_2_WINDOWFLASHING					(1<<3) // 8
#define PREFTOGGLE_2_ANON							(1<<4) // 16
#define PREFTOGGLE_2_AFKWATCH						(1<<5) // 32
#define PREFTOGGLE_2_RUNECHAT						(1<<6) // 64
#define PREFTOGGLE_2_DEATHMESSAGE					(1<<7) // 128
// #define PREFTOGGLE_2_EMOTE_BUBBLE				(1<<8) // 256 - Defunct as of 2024-01-29
// Yes I know this being an "enable to disable" is misleading, but it avoids having to tweak all existing pref entries
#define PREFTOGGLE_2_REVERB_DISABLE					(1<<9) // 512
// #define PREFTOGGLE_2_FORCE_WHITE_RUNECHAT		(1<<10) // 1024 Defunct as of 2024-08-03 with runechat color preferences
// #define PREFTOGGLE_2_SIMPLE_STAT_PANEL			(1<<11) // 2048 Defunct as of 2024-02-14 with browser stat panels
#define PREFTOGGLE_2_SEE_ITEM_OUTLINES 				(1<<12) // 4096
#define PREFTOGGLE_2_HIDE_ITEM_TOOLTIPS  			(1<<13) // 8192
#define PREFTOGGLE_2_THOUGHT_BUBBLE					(1<<14) // 16384
#define PREFTOGGLE_2_MC_TAB							(1<<15) // 32768
#define PREFTOGGLE_2_DANCE_DISCO					(1<<16) // 65536
#define PREFTOGGLE_2_MOD_ACTIVATION_METHOD			(1<<17) // 131072
#define PREFTOGGLE_2_PARALLAX_IN_DARKNESS			(1<<18) // 262144
#define PREFTOGGLE_2_DISABLE_TGUI_INPUT				(1<<19) // 524288
#define PREFTOGGLE_2_ENABLE_TGUI_SAY_LIGHT_MODE		(1<<20) // 1048576
#define PREFTOGGLE_2_SWAP_INPUT_BUTTONS				(1<<21) // 2097152
#define PREFTOGGLE_2_LARGE_INPUT_BUTTONS			(1<<22) // 4194304
#define PREFTOGGLE_2_BIG_STRIP_MENU					(1<<23) // 8388608

#define TOGGLES_2_TOTAL 							16776191 // If you add or remove a preference toggle above, make sure you update this define with the total value of the toggles combined.

#define TOGGLES_2_DEFAULT (PREFTOGGLE_2_FANCYUI|PREFTOGGLE_2_ITEMATTACK|PREFTOGGLE_2_WINDOWFLASHING|PREFTOGGLE_2_RUNECHAT|PREFTOGGLE_2_DEATHMESSAGE|PREFTOGGLE_2_SEE_ITEM_OUTLINES|PREFTOGGLE_2_THOUGHT_BUBBLE|PREFTOGGLE_2_DANCE_DISCO|PREFTOGGLE_2_MOD_ACTIVATION_METHOD|PREFTOGGLE_2_SWAP_INPUT_BUTTONS|PREFTOGGLE_2_LARGE_INPUT_BUTTONS)


// toggles_3 variables. These MUST be prefixed with PREFTOGGLE_3
#define PREFTOGGLE_3_COGBAR_ANIMATIONS				(1<<0) // 1

#define TOGGLES_3_TOTAL 							1 // If you add or remove a preference toggle above, make sure you update this define with the total value of the toggles combined.

#define TOGGLES_3_DEFAULT (PREFTOGGLE_3_COGBAR_ANIMATIONS)

// Sanity checks
// I should really convert these to a JSON list at some point hnnnnnng
#if TOGGLES_TOTAL > 16777215
#error toggles bitflag over 16777215. Please use toggles_2.
#endif

#if TOGGLES_2_TOTAL > 16777215
#error toggles_2 bitflag over 16777215. Please use toggles_3.
#endif

#if TOGGLES_3_TOTAL > 16777215
#error toggles_3 bitflag over 16777215. Please make an issue report and postpone the feature you are working on.
#endif

// This is a list index. Required to start at 1 instead of 0 so it's properly placed in the list
#define PREFTOGGLE_CATEGORY_GENERAL		1
#define PREFTOGGLE_CATEGORY_LIVING		2
#define PREFTOGGLE_CATEGORY_GHOST		3
#define PREFTOGGLE_CATEGORY_ADMIN		4

// Preftoggle type defines
/// Special toggles, stuff that just overrides set_toggles entirely
#define PREFTOGGLE_SPECIAL		0
/// Interacts with the sound bitflag
#define PREFTOGGLE_SOUND		1
/// Interacts with the light bitflag
#define PREFTOGGLE_LIGHT		2
/// Interacts with the toggles bitflag
#define PREFTOGGLE_TOGGLE1		3
/// Interacts with the toggles2 bitflag
#define PREFTOGGLE_TOGGLE2		4


// Admin attack logs filter system, see /proc/add_attack_logs and /proc/msg_admin_attack
#define ATKLOG_ALL	0
#define ATKLOG_ALMOSTALL	1
#define ATKLOG_MOST	2
#define ATKLOG_FEW	3
#define ATKLOG_NONE	4

// Playtime tracking system, see jobs_exp.dm
#define EXP_TYPE_LIVING			"Living"
#define EXP_TYPE_CREW			"Crew"
#define EXP_TYPE_SPECIAL		"Special"
#define EXP_TYPE_GHOST			"Ghost"
#define EXP_TYPE_COMMAND		"Command"
#define EXP_TYPE_ENGINEERING	"Engineering"
#define EXP_TYPE_MEDICAL		"Medical"
#define EXP_TYPE_SCIENCE		"Science"
#define EXP_TYPE_SUPPLY			"Supply"
#define EXP_TYPE_SECURITY		"Security"
#define EXP_TYPE_SILICON		"Silicon"
#define EXP_TYPE_SERVICE		"Service"

#define EXP_DEPT_TYPE_LIST		list(EXP_TYPE_SUPPLY, EXP_TYPE_SERVICE, EXP_TYPE_MEDICAL, EXP_TYPE_ENGINEERING, EXP_TYPE_SCIENCE, EXP_TYPE_SECURITY, EXP_TYPE_COMMAND, EXP_TYPE_SILICON, EXP_TYPE_SPECIAL, EXP_TYPE_GHOST)

// Defines for the glow level preference for the lighting.
#define GLOW_HIGH    0
#define GLOW_MED     1 // Default.
#define GLOW_LOW     2
#define GLOW_DISABLE 3

// Defines just for parallax because its levels make storing it in the regular prefs a pain in the ass
// These dont need to be bitflags because there isnt going to be more than one at a time of these active
// But its gonna piss off my OCD if it isnt bitflags, so deal with it, -affected
#define PARALLAX_DISABLE		(1<<0)
#define PARALLAX_LOW			(1<<1)
#define PARALLAX_MED			(1<<2)
#define PARALLAX_HIGH			(1<<3)
#define PARALLAX_INSANE			(1<<4)

// 2FA Defines. These are the same as the schema DB enums //

/// Client has 2FA disabled
#define _2FA_DISABLED "DISABLED"
/// Client will be prompted for 2FA on IP changes
#define _2FA_ENABLED_IP "ENABLED_IP"
/// Client will be prompted for 2FA always
#define _2FA_ENABLED_ALWAYS "ENABLED_ALWAYS"


#define MAX_SAVE_SLOTS 30 // Save slots for regular players
#define MAX_SAVE_SLOTS_MEMBER 30 // Save slots for BYOND members

#define TAB_CHAR 	0
#define TAB_GAME 	1
#define TAB_ANTAG 	2
#define TAB_KEYS 	3
#define TAB_TOGGLES 4

// Colourblind modes
#define COLOURBLIND_MODE_NONE "None"
#define COLOURBLIND_MODE_DEUTER "Red-green (green weak, deuteranopia)"
#define COLOURBLIND_MODE_PROT "Red-green (red weak, protanopia)"
#define COLOURBLIND_MODE_TRIT "Blue-yellow (tritanopia)"

/// Best FPS options for clients. A regular list that has only divisors of 1000
GLOBAL_LIST_INIT(client_fps_options, list_fps_options())

/proc/list_fps_options()
	var/list/options = list()

	for(var/option in 1 to 1000 / world.fps)
		if(1000 % option) // Lummox said it works better with divisors of 1000
			continue

		options += 1000 / option

	return options
