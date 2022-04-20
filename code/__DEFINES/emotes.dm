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
#define EMOTE_READY (0)
/// The user can spam emotes to their heart's content.
#define EMOTE_INFINITE (1)
/// The user cannot emote as they have been blocked by an admin.
#define EMOTE_ADMIN_BLOCKED (2)
/// The user cannot emote until their cooldown expires.
#define EMOTE_ON_COOLDOWN (3)

/// Marker to separate an emote key from its parameters in user input.
#define EMOTE_PARAM_SEPARATOR "-"

// This defines the base cooldown for how often each emote can be used.

/// Default cooldown for emotes
#define DEFAULT_EMOTE_COOLDOWN (2 SECONDS)

// Each mob can only make sounds with (intentional) emotes this often.
// These emotes will still be sent to chat, but won't play their associated sound effect.

/// Default cooldown for audio that comes from emotes.
#define AUDIO_EMOTE_COOLDOWN (5 SECONDS)
