///Basic mob flags

/// Delete mob upon death
#define DEL_ON_DEATH (1<<0)
/// Rotate mob 180 degrees while it is dead
#define FLIP_ON_DEATH (1<<1)
/// Mob remains dense while dead
#define REMAIN_DENSE_WHILE_DEAD (1<<2)
/// Mob can be set on fire
#define FLAMMABLE_MOB (1<<3)
/// Mob never takes damage from unarmed attacks
#define IMMUNE_TO_FISTS (1<<4)
/// Disables the function of attacking random body zones
#define PRECISE_ATTACK_ZONES (1<<5)

DEFINE_BITFIELD(basic_mob_flags, list(
	"DEL_ON_DEATH" = DEL_ON_DEATH,
	"FLIP_ON_DEATH" = FLIP_ON_DEATH,
	"REMAIN_DENSE_WHILE_DEAD" = REMAIN_DENSE_WHILE_DEAD,
	"FLAMMABLE_MOB" = FLAMMABLE_MOB,
	"IMMUNE_TO_FISTS" = IMMUNE_TO_FISTS,
	"PRECISE_ATTACK_ZONES" = PRECISE_ATTACK_ZONES,
))

///hunger cooldown for basic mobs
#define EAT_FOOD_COOLDOWN 45 SECONDS

