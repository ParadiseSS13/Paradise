/**
 * General defines used for emotes
 */

// Emote types.
// These determine how the emote is treated when not directly visible (or audible).

/// Emote is visible. These emotes will be runechatted.
#define EMOTE_VISIBLE (1<<0)
/// Emote is audible (in character).
#define EMOTE_AUDIBLE (1<<1)
/// Emote makes a sound. These emotes will specifically not be runechatted.
#define EMOTE_SOUND (1<<2)
/// Regardless of its existing flags, this emote will not be sent to runechat.
#define EMOTE_FORCE_NO_RUNECHAT (1<<3)
/// This emote uses the mouth, and so should be blocked if the user is muzzled or can't breathe (for humans).
#define EMOTE_MOUTH (1<<4)

// User audio cooldown system.
// This is a value stored on the user and represents their ability to perform emotes.

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

// This defines the base cooldown for how often each emote can be used.

/// Default cooldown for emotes
#define DEFAULT_EMOTE_COOLDOWN (2 SECONDS)

// Each mob can only make sounds with (intentional) emotes this often.
// These emotes will still be sent to chat, but won't play their associated sound effect.

/// Default cooldown for audio that comes from emotes.
#define AUDIO_EMOTE_COOLDOWN (5 SECONDS)

// Emote parameter types
// If nothing is passed in for a target, this can determine the possible target.

// This first set of defines denotes the behavior if a match can't be found.

/// If this is set and a valid target is not found, the emote will not execute.
#define EMOTE_TARGET_MUST_MATCH 1
/// If this is set and a valid target is not found, the emote will just ignore the parameter entirely.
#define EMOTE_TARGET_DEFAULT_TO_BASE 2
/// If this is set and a valid target is not found, the emote will work with the params that it has.
#define EMOTE_TARGET_USE_PARAMS_ANYWAY 3
/// No matching/processing will be performed, and the target will be purely what's passed in.
#define EMOTE_TARGET_RAW 4

// This set determines the type of target that we want to check for.

/// The target will check all nearby living mobs.
#define EMOTE_TARGET_MOB (1<<0)
/// The target will check all objects nearby.
#define EMOTE_TARGET_OBJ (1<<1)
/// The target will check nearby mobs and objects.
#define EMOTE_TARGET_ANY (EMOTE_TARGET_MOB | EMOTE_TARGET_OBJ)
