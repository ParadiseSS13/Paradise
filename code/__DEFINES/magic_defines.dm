// Bitflags for magic resistance types
/// Default magic resistance that blocks normal magic (wizard, spells, magical staff projectiles)
#define MAGIC_RESISTANCE (1<<0)
/// Tinfoil hat magic resistance that blocks mental magic (telepathy / mind links, mind curses, abductors)
#define MAGIC_RESISTANCE_MIND (1<<1)
/// Holy magic resistance that blocks unholy magic (revenant, vampire, voice of god)
#define MAGIC_RESISTANCE_HOLY (1<<2)

DEFINE_BITFIELD(antimagic_flags, list(
	"MAGIC_RESISTANCE" = MAGIC_RESISTANCE,
	"MAGIC_RESISTANCE_HOLY" = MAGIC_RESISTANCE_HOLY,
	"MAGIC_RESISTANCE_MIND" = MAGIC_RESISTANCE_MIND,
))

/// Whether the spell can be cast while the user has antimagic on them that corresponds to the spell's own antimagic flags.
#define SPELL_REQUIRES_NO_ANTIMAGIC (1 << 0)
