/// If used, an implant will trigger when an emote is intentionally used.
#define BIOCHIP_EMOTE_TRIGGER_INTENTIONAL (1<<0)
/// If used, an implant will trigger when an emote is forced/unintentionally used.
#define BIOCHIP_EMOTE_TRIGGER_UNINTENTIONAL (1<<1)
/// If used, an implant will always trigger when the user makes an emote.
#define BIOCHIP_EMOTE_TRIGGER_ALWAYS (BIOCHIP_EMOTE_TRIGGER_UNINTENTIONAL | BIOCHIP_EMOTE_TRIGGER_INTENTIONAL)
/// If used, an implant will trigger on the user's first death.
#define BIOCHIP_TRIGGER_DEATH_ONCE (1<<2)
/// If used, an implant will trigger any time a user dies.
#define BIOCHIP_TRIGGER_DEATH_ANY (1<<3)
/// If used, an implant will NOT trigger on death when a user is gibbed.
#define BIOCHIP_TRIGGER_NOT_WHEN_GIBBED (1<<4)

// Defines related to the way that the implant is activated. This is the value for implant.activated
/// The implant is passively active (like a mindshield)
#define BIOCHIP_ACTIVATED_PASSIVE 0
/// The implant is activated manually by a trigger
#define BIOCHIP_ACTIVATED_ACTIVE 1
