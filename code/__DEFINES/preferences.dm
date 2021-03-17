//Preference toggles
#define SOUND_ADMINHELP		1
#define SOUND_MIDI			2
#define SOUND_AMBIENCE		4
#define SOUND_LOBBY			8
#define SOUND_HEARTBEAT		32
#define SOUND_BUZZ			64
#define SOUND_INSTRUMENTS	128
#define SOUND_MENTORHELP	256
#define SOUND_DISCO         512
#define SOUND_AI_VOICE      1024
#define SOUND_PRAYERNOTIFY      2048

#define SOUND_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|SOUND_HEARTBEAT|SOUND_BUZZ|SOUND_INSTRUMENTS|SOUND_MENTORHELP|SOUND_DISCO|SOUND_AI_VOICE|SOUND_PRAYERNOTIFY)

#define PREFTOGGLE_CHAT_OOC					1
#define PREFTOGGLE_CHAT_DEAD				2
#define PREFTOGGLE_CHAT_GHOSTEARS			4
#define PREFTOGGLE_CHAT_GHOSTSIGHT			8
#define PREFTOGGLE_CHAT_PRAYER				16
#define PREFTOGGLE_CHAT_RADIO				32
#define PREFTOGGLE_AZERTY					64
#define PREFTOGGLE_CHAT_DEBUGLOGS 			128
#define PREFTOGGLE_CHAT_LOOC 				256
#define PREFTOGGLE_CHAT_GHOSTRADIO 			512
#define PREFTOGGLE_SHOW_TYPING 				1024
#define PREFTOGGLE_DISABLE_SCOREBOARD 		2048
#define PREFTOGGLE_DISABLE_KARMA_REMINDER	4096
#define PREFTOGGLE_MEMBER_PUBLIC			8192
#define PREFTOGGLE_CHAT_NO_ADMINLOGS 		16384
#define PREFTOGGLE_DONATOR_PUBLIC			32768
#define PREFTOGGLE_CHAT_NO_TICKETLOGS 		65536
#define PREFTOGGLE_UI_DARKMODE 				131072
#define PREFTOGGLE_DISABLE_KARMA 			262144
#define PREFTOGGLE_CHAT_NO_MENTORTICKETLOGS 524288
#define PREFTOGGLE_TYPING_ONCE 				1048576
#define PREFTOGGLE_AMBIENT_OCCLUSION 		2097152
#define PREFTOGGLE_CHAT_GHOSTPDA 			4194304
#define PREFTOGGLE_NUMPAD_TARGET 			8388608

#define TOGGLES_TOTAL 						16777215 // If you add or remove a preference toggle above, make sure you update this define with the total value of the toggles combined.

#define TOGGLES_DEFAULT (PREFTOGGLE_CHAT_OOC|PREFTOGGLE_CHAT_DEAD|PREFTOGGLE_CHAT_GHOSTEARS|PREFTOGGLE_CHAT_GHOSTSIGHT|PREFTOGGLE_CHAT_PRAYER|PREFTOGGLE_CHAT_RADIO|PREFTOGGLE_CHAT_LOOC|PREFTOGGLE_MEMBER_PUBLIC|PREFTOGGLE_DONATOR_PUBLIC|PREFTOGGLE_AMBIENT_OCCLUSION|PREFTOGGLE_CHAT_GHOSTPDA|PREFTOGGLE_NUMPAD_TARGET)

// toggles_2 variables. These MUST be prefixed with PREFTOGGLE_2
#define PREFTOGGLE_2_RANDOMSLOT		1
#define PREFTOGGLE_2_FANCYUI		2
#define PREFTOGGLE_2_ITEMATTACK		4
#define PREFTOGGLE_2_WINDOWFLASHING	8
#define PREFTOGGLE_2_ANONDCHAT		16
#define PREFTOGGLE_2_AFKWATCH		32
#define PREFTOGGLE_2_RUNECHAT		64
#define PREFTOGGLE_2_DEATHMESSAGE	128
#define PREFTOGGLE_2_EMOTE_BUBBLE	256
// Yes I know this being an "enable to disable" is misleading, but it avoids having to tweak all existing pref entries
#define PREFTOGGLE_2_REVERB_DISABLE	512
#define PREFTOGGLE_2_FORCE_WHITE_RUNECHAT	1024

#define TOGGLES_2_TOTAL 			2047 // If you add or remove a preference toggle above, make sure you update this define with the total value of the toggles combined.

#define TOGGLES_2_DEFAULT (PREFTOGGLE_2_FANCYUI|PREFTOGGLE_2_ITEMATTACK|PREFTOGGLE_2_WINDOWFLASHING|PREFTOGGLE_2_RUNECHAT|PREFTOGGLE_2_DEATHMESSAGE|PREFTOGGLE_2_EMOTE_BUBBLE)

// Sanity checks
#if TOGGLES_TOTAL > 16777215
#error toggles bitflag over 16777215. Please use toggles_2.
#endif

#if TOGGLES_2_TOTAL > 16777215
#error toggles_2 bitflag over 16777215. Please make an issue report and postpone the feature you are working on.
#endif



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
#define EXP_TYPE_EXEMPT			"Exempt"
#define EXP_TYPE_COMMAND		"Command"
#define EXP_TYPE_ENGINEERING	"Engineering"
#define EXP_TYPE_MEDICAL		"Medical"
#define EXP_TYPE_SCIENCE		"Science"
#define EXP_TYPE_SUPPLY			"Supply"
#define EXP_TYPE_SECURITY		"Security"
#define EXP_TYPE_SILICON		"Silicon"
#define EXP_TYPE_SERVICE		"Service"
#define EXP_TYPE_WHITELIST		"Whitelist"

#define EXP_DEPT_TYPE_LIST		list(EXP_TYPE_SERVICE, EXP_TYPE_MEDICAL, EXP_TYPE_ENGINEERING, EXP_TYPE_SCIENCE, EXP_TYPE_SECURITY, EXP_TYPE_COMMAND, EXP_TYPE_SILICON, EXP_TYPE_SPECIAL)

// Defines just for parallax because its levels make storing it in the regular prefs a pain in the ass
// These dont need to be bitflags because there isnt going to be more than one at a time of these active
// But its gonna piss off my OCD if it isnt bitflags, so deal with it, -affected
#define PARALLAX_DISABLE		1
#define PARALLAX_LOW			2
#define PARALLAX_MED			4
#define PARALLAX_HIGH			8
#define PARALLAX_INSANE			16
