/**
 * General defines used for emotes
 */

// Emote types.
// These determine how the emote is treated when not directly visible (or audible).
// These are also used in some cases for visible/audible messages.

/// Emote is visible. These emotes will be runechatted.
#define EMOTE_VISIBLE (1<<0)
/// Emote is audible (in character).
#define EMOTE_AUDIBLE (1<<1)
/// Regardless of its existing flags, an emote with this flag will not be sent to runechat.
#define EMOTE_FORCE_NO_RUNECHAT (1<<2)
/// This emote uses the mouth, and so should be blocked if the user is muzzled or can't breathe (for humans).
#define EMOTE_MOUTH (1<<3)

// User audio cooldown system.
// This is a value stored on the user and represents their current ability to perform audio emotes.

/// The user is not on emote cooldown, and is ready to emote whenever.
#define EMOTE_READY 0
/// The user can spam emotes to their heart's content.
#define EMOTE_INFINITE 1
/// The user cannot emote as they have been blocked by an admin.
#define EMOTE_ADMIN_BLOCKED 2
/// The user cannot emote until their cooldown expires.
#define EMOTE_ON_COOLDOWN 3

/// Marker to separate an emote key from its parameters in user input.
#define EMOTE_PARAM_SEPARATOR "-"

/// Default cooldown for normal (non-audio) emotes.
#define DEFAULT_EMOTE_COOLDOWN (1.5 SECONDS)

// Each mob can only play an emote with audio every AUDIO_EMOTE_COOLDOWN seconds, unless a given emote overrides its own audio cooldown.

/// Default cooldown for emote-emitted audio.
#define AUDIO_EMOTE_COOLDOWN (5 SECONDS)

/// Cooldown for emotes that are emitted unintentionally, to prevent them from getting audibly spammy.
#define AUDIO_EMOTE_UNINTENTIONAL_COOLDOWN (2 SECONDS)

// Emote parameter types
// If nothing is passed in for a target, this can determine the possible target.

// Our emote code will search around the user to find a matching target to use, based on the second set of defines.
// This first set of defines denotes the behavior if a match can't be found.

/// If this is set and a valid target is not found, the emote will not execute.
#define EMOTE_TARGET_BHVR_MUST_MATCH 1
/// If this is set and a valid target is not found, the emote will just ignore the parameter entirely.
#define EMOTE_TARGET_BHVR_DEFAULT_TO_BASE 2
/// If this is set and a valid target is not found, the emote will work with the params that it has.
#define EMOTE_TARGET_BHVR_USE_PARAMS_ANYWAY 3
/// No matching/processing will be performed, and the target will be purely what's passed in.
#define EMOTE_TARGET_BHVR_RAW 4
/// The emote target should be just a number. Anything else will be rejected.
#define EMOTE_TARGET_BHVR_NUM 5
/// The emote target is used elsewhere, and processing should be skipped.
#define EMOTE_TARGET_BHVR_IGNORE 6

// This set determines the type of target that we want to check for.

/// The target will check all nearby living mobs.
#define EMOTE_TARGET_MOB (1<<0)
/// The target will check all objects nearby.
#define EMOTE_TARGET_OBJ (1<<1)
/// The target will check nearby mobs and objects.
#define EMOTE_TARGET_ANY (EMOTE_TARGET_MOB | EMOTE_TARGET_OBJ)

/// If passed as message_param, will default to using the message's postfix.
#define EMOTE_PARAM_USE_POSTFIX 1

/// If returned from act_on_target(), emote execution will stop.
#define EMOTE_ACT_STOP_EXECUTION 1

/// List of emotes useable by ghosties
#define USABLE_DEAD_EMOTES list("*flip", "*spin", "*jump")

// Strings used for the rock paper scissors emote and status effect
#define RPS_EMOTE_ROCK 		"rock"
#define RPS_EMOTE_PAPER 	"paper"
#define RPS_EMOTE_SCISSORS 	"scissors"

#define RPS_EMOTE_THEY_WIN		"aww"
#define RPS_EMOTE_WE_WIN		"yay"
#define RPS_EMOTE_TIE			"tie"
