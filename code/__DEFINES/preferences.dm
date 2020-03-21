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

#define SOUND_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|SOUND_HEARTBEAT|SOUND_BUZZ|SOUND_INSTRUMENTS|SOUND_MENTORHELP|SOUND_DISCO|SOUND_AI_VOICE)

#define CHAT_OOC		1
#define CHAT_DEAD		2
#define CHAT_GHOSTEARS	4
#define CHAT_GHOSTSIGHT	8
#define CHAT_PRAYER		16
#define CHAT_RADIO		32
#define AZERTY          64
#define CHAT_DEBUGLOGS	128
#define CHAT_LOOC		256
#define CHAT_GHOSTRADIO 512
#define SHOW_TYPING 	1024
#define DISABLE_SCOREBOARD 2048
#define DISABLE_KARMA_REMINDER	4096
#define MEMBER_PUBLIC	8192
#define CHAT_NO_ADMINLOGS 16384
#define DONATOR_PUBLIC	32768
#define CHAT_NO_TICKETLOGS 65536
#define UI_DARKMODE 131072
#define DISABLE_KARMA 262144
#define CHAT_NO_MENTORTICKETLOGS 524288
#define TYPING_ONCE 1048576
#define AMBIENT_OCCLUSION 2097152
#define CHAT_GHOSTPDA 4194304
#define NUMPAD_TARGET 8388608
#define TOGGLES_TOTAL 16777215 // If you add or remove a preference toggle above, make sure you update this define with the total value of the toggles combined.


#define TOGGLES_DEFAULT (CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_LOOC|MEMBER_PUBLIC|DONATOR_PUBLIC|AMBIENT_OCCLUSION|CHAT_GHOSTPDA|NUMPAD_TARGET)

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
