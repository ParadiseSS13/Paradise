//Damage things	//TODO: merge these down to reduce on defines
//Way to waste perfectly good damagetype names (BRUTE) on this... If you were really worried about case sensitivity, you could have just used lowertext(damagetype) in the proc...
#define BRUTE		"brute"
#define BURN		"fire"
#define TOX			"tox"
#define OXY			"oxy"
#define CLONE		"clone"
#define STAMINA 	"stamina"
#define BRAIN		"brain"

//damage flags
#define MELEE 		"melee"
#define BULLET 		"bullet"
#define LASER 		"laser"
#define ENERGY 		"energy"
#define BOMB 		"bomb"
#define RAD 		"rad"
#define FIRE 		"fire"
#define ACID 		"acid"
#define MAGIC		"magic"

#define STUN		"stun"
#define STAM_CRIT   "stam_crit"
#define WEAKEN		"weaken"
#define KNOCKDOWN	"knockdown"
#define PARALYZE	"paralize"
#define IRRADIATE	"irradiate"
#define STUTTER		"stutter"
#define SLUR		"slur"
#define EYE_BLUR	"eye_blur"
#define DROWSY		"drowsy"
#define JITTER		"jitter"

/// Jitter decays at a rate of 3 per life cycle, 15 if resting.
#define SECONDS_TO_JITTER SECONDS_TO_LIFE_CYCLES*3

//I hate adding defines like this but I'd much rather deal with bitflags than lists and string searches
#define BRUTELOSS		(1<<0)
#define FIRELOSS		(1<<1)
#define TOXLOSS			(1<<2)
#define OXYLOSS			(1<<3)
/// Stam crits the effected mob, as well as ensures they dont die from suicide
#define SHAME 			(1<<4)
#define OBLITERATION 	(1<<5)

//Bitflags defining which status effects could be or are inflicted on a mob
#define CANSTUN			(1<<0)
#define CANWEAKEN		(1<<1)
#define CANPARALYSE		(1<<2)
#define CANPUSH			(1<<3)
#define PASSEMOTES		(1<<4) //Mob has holders inside of it that need to see emotes.
#define GODMODE			(1<<5)
#define TERMINATOR_FORM (1<<6)

//Health Defines
#define HEALTH_THRESHOLD_CRIT 0
#define HEALTH_THRESHOLD_SUCCUMB -30
#define HEALTH_THRESHOLD_KNOCKOUT -50
#define HEALTH_THRESHOLD_DEAD -100

//Grab levels
#define GRAB_PASSIVE  1
#define GRAB_AGGRESSIVE  2
#define GRAB_NECK    3
#define GRAB_UPGRADING  4
#define GRAB_KILL    5

//Attack types for checking shields/hit reactions

#define MELEE_ATTACK 1
#define UNARMED_ATTACK 2
#define PROJECTILE_ATTACK 3
#define THROWN_PROJECTILE_ATTACK 4
#define LEAP_ATTACK 5
#define ALL_ATTACK_TYPES list(MELEE_ATTACK, UNARMED_ATTACK, PROJECTILE_ATTACK, THROWN_PROJECTILE_ATTACK, LEAP_ATTACK)
#define NON_PROJECTILE_ATTACKS list(MELEE_ATTACK, UNARMED_ATTACK, LEAP_ATTACK)

// the standard parry time out time
#define PARRY_DEFAULT_TIMEOUT 1 SECONDS

//attack visual effects
#define ATTACK_EFFECT_PUNCH		"punch"
#define ATTACK_EFFECT_KICK		"kick"
#define ATTACK_EFFECT_SMASH		"smash"
#define ATTACK_EFFECT_CLAW		"claw"
#define ATTACK_EFFECT_DISARM	"disarm"
#define ATTACK_EFFECT_BITE		"bite"
#define ATTACK_EFFECT_MECHFIRE	"mech_fire"
#define ATTACK_EFFECT_MECHTOXIN	"mech_toxin"
#define ATTACK_EFFECT_BOOP		"boop" //Honk
//NOTE: INTENT_HOTKEY_* defines are not actual intents!
//they are here to support hotkeys
#define INTENT_HOTKEY_LEFT  "left"
#define INTENT_HOTKEY_RIGHT "right"

//Embedded objects
#define EMBEDDED_PAIN_CHANCE 					15	//Chance for embedded objects to cause pain (damage user)
#define EMBEDDED_ITEM_FALLOUT 					5	//Chance for embedded object to fall out (causing pain but removing the object)
#define EMBED_CHANCE							45	//Chance for an object to embed into somebody when thrown (if it's sharp)
#define EMBEDDED_PAIN_MULTIPLIER				2	//Coefficient of multiplication for the damage the item does while embedded (this*item.w_class)
#define EMBEDDED_FALL_PAIN_MULTIPLIER			5	//Coefficient of multiplication for the damage the item does when it falls out (this*item.w_class)
#define EMBEDDED_IMPACT_PAIN_MULTIPLIER			4	//Coefficient of multiplication for the damage the item does when it first embeds (this*item.w_class)
#define EMBED_THROWSPEED_THRESHOLD				4	//The minimum value of an item's throw_speed for it to embed (Unless it has embedded_ignore_throwspeed_threshold set to 1)
#define EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER 8	//Coefficient of multiplication for the damage the item does when removed without a surgery (this*item.w_class)
#define EMBEDDED_UNSAFE_REMOVAL_TIME			30	//A Time in ticks, total removal time = (this*item.w_class)

// Body Parts
#define BODY_ZONE_HEAD		"head"
#define BODY_ZONE_CHEST		"chest"
#define BODY_ZONE_L_ARM		"l_arm"
#define BODY_ZONE_R_ARM		"r_arm"
#define BODY_ZONE_L_LEG		"l_leg"
#define BODY_ZONE_R_LEG		"r_leg"

#define BODY_ZONE_PRECISE_EYES		"eyes"
#define BODY_ZONE_PRECISE_MOUTH		"mouth"
#define BODY_ZONE_PRECISE_GROIN		"groin"
#define BODY_ZONE_PRECISE_L_HAND	"l_hand"
#define BODY_ZONE_PRECISE_R_HAND	"r_hand"
#define BODY_ZONE_PRECISE_L_FOOT	"l_foot"
#define BODY_ZONE_PRECISE_R_FOOT	"r_foot"

//We will round to this value in damage calculations.
#define DAMAGE_PRECISION 0.1

//Gun Stuff
#define SAWN_INTACT  0
#define SAWN_OFF     1

#define WEAPON_DUAL_WIELD 0
#define WEAPON_LIGHT 1
#define WEAPON_MEDIUM 2
#define WEAPON_HEAVY 3

#define HIS_GRACE_SATIATED 		0 		// He hungers not. If bloodthirst is set to this, His Grace is asleep.
#define HIS_GRACE_PECKISH 		20 		// Slightly hungry.
#define HIS_GRACE_HUNGRY 		60 		// Getting closer.
#define HIS_GRACE_FAMISHED 		100 	// Dangerously close.
#define HIS_GRACE_STARVING 		120 	// Incredibly close to breaking loose.
#define HIS_GRACE_CONSUME_OWNER 140 	// His Grace consumes His owner at this point and becomes aggressive.
#define HIS_GRACE_FALL_ASLEEP 	160 	// If it reaches this point, He falls asleep and resets.

#define HIS_GRACE_FORCE_BONUS 	5 		// How much force is gained per kill.
#define ASCEND_BONUS			20		// How much force we get on ascend per kill

#define EXPLODE_NONE 0				//Don't even ask me why we need this.
#define EXPLODE_DEVASTATE 1
#define EXPLODE_HEAVY 2
#define EXPLODE_LIGHT 3

#define EMP_HEAVY 1
#define EMP_LIGHT 2
#define EMP_WEAKENED 3

/*
* converts life cycle values into deciseconds. try and avoid usage of this.
* this is needed as many functions for stun durations used to output cycles as values, but we now track stun times in deciseconds.
*/
#define STATUS_EFFECT_CONSTANT * 20

#define IS_HORIZONTAL(x) x.body_position

/// Compatible firemode is in the gun. Wait until it's held in the user hands.
#define AUTOFIRE_STAT_IDLE (1<<0)
/// Gun is active and in the user hands. Wait until user does a valid click.
#define AUTOFIRE_STAT_ALERT	(1<<1)
/// Gun is shooting.
#define AUTOFIRE_STAT_FIRING (1<<2)

/// Multiplier for wall damage for comparison with object integrity.
#define OBJ_INTEGRITY_TO_WALL_DAMAGE 10
