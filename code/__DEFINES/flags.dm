#define ALL ~0 //For convenience.
#define NONE 0

//FLAGS BITMASK
#define STOPSPRESSUREDMAGE		1		//This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_FLAG_BACK) if you see it anywhere To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.
#define NODROP					2		// This flag makes it so that an item literally cannot be removed at all, or at least that's how it should be. Only deleted.
#define NOBLUDGEON  			4		// when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define AIRTIGHT				8		// mask allows internals
#define HANDSLOW				16		// If an item has this flag, it will slow you to carry it
#define CONDUCT					32		// conducts electricity (metal etc.)
#define ABSTRACT				64		// for all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way
#define ON_BORDER				128		// item has priority to check when entering or leaving
#define PREVENT_CLICK_UNDER		256
#define NODECONSTRUCT			512

#define EARBANGPROTECT			1024

#define NOSLIP					1024 	//prevents from slipping on wet floors, in space etc

#define HEADBANGPROTECT			4096

#define BLOCK_GAS_SMOKE_EFFECT	8192	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY!
#define THICKMATERIAL 			8192	//prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body. (NOTE: flag shared with BLOCK_GAS_SMOKE_EFFECT)

#define DROPDEL					16384	// When dropped, it calls qdel on itself

///Whether or not this atom shows screentips when hovered over
#define NO_SCREENTIPS			32768

// Update flags for [/atom/proc/update_appearance]
/// Update the atom's name
#define UPDATE_NAME (1<<0)
/// Update the atom's desc
#define UPDATE_DESC (1<<1)
/// Update the atom's icon state
#define UPDATE_ICON_STATE (1<<2)
/// Update the atom's overlays
#define UPDATE_OVERLAYS (1<<3)
/// Update the atom's icon
#define UPDATE_ICON (UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/* Secondary atom flags, for the flags_2 var, denoted with a _2 */

#define SLOWS_WHILE_IN_HAND_2	1
#define NO_EMP_WIRES_2			2
#define HOLOGRAM_2				4
#define FROZEN_2				8
#define STATIONLOVING_2			16
#define INFORM_ADMINS_ON_RELOCATE_2	32
#define BANG_PROTECT_2			64
#define BLOCKS_LIGHT_2          128 // Light sources placed in anything with that flag will not emit light through them.

// A mob with OMNITONGUE has no restriction in the ability to speak
// languages that they know. So even if they wouldn't normally be able to
// through mob or tongue restrictions, this flag allows them to ignore
// those restrictions.
#define OMNITONGUE_2			256

/// Prevents mobs from getting chainshocked by teslas and the supermatter
#define SHOCKED_2 				512

// Stops you from putting things like an RCD or other items into an ORM or protolathe for materials.
#define NO_MAT_REDEMPTION_2		1024

// LAVA_PROTECT used on the flags_2 variable for both SUIT and HEAD items, and stops lava damage. Must be present in both to stop lava damage.
#define LAVA_PROTECT_2			2048

#define OVERLAY_QUEUED_2		4096

#define CHECK_RICOCHET_2		8192

/// should the contents of this atom be acted upon
#define RAD_PROTECT_CONTENTS_2	16384
/// should this object be allowed to be contaminated
#define RAD_NO_CONTAMINATE_2	32768
/// Prevents shuttles from deleting the item
#define IMMUNE_TO_SHUTTLECRUSH_2 (1<<16)
/// Prevents malf AI animate + overload ability
#define NO_MALF_EFFECT_2		(1<<17)
/// Use when this shouldn't be obscured by large icons.
#define CRITICAL_ATOM_2			(1<<18)
/// Use this flag for items that can block randomly
#define RANDOM_BLOCKER_2		(1<<19)
/// This flag allows for wearing of a belt item, even if you're not wearing a jumpsuit
#define ALLOW_BELT_NO_JUMPSUIT_2	(1<<20)

//Reagent flags
#define REAGENT_NOREACT			1

//Species clothing flags
#define HAS_UNDERWEAR 	1
#define HAS_UNDERSHIRT 	2
#define HAS_SOCKS		4

//Species Body Flags
#define HAS_HEAD_ACCESSORY	1
#define HAS_TAIL 			2
#define TAIL_OVERLAPPED		4
#define HAS_SKIN_TONE 		8
#define HAS_ICON_SKIN_TONE	16
#define HAS_SKIN_COLOR		32
#define HAS_HEAD_MARKINGS	64
#define HAS_BODY_MARKINGS	128
#define HAS_TAIL_MARKINGS	256
#define TAIL_WAGGING    	512
#define NO_EYES				1024
#define HAS_ALT_HEADS		2048
#define HAS_WING			4096
#define HAS_BODYACC_COLOR	8192
#define BALD				16384
#define ALL_RPARTS			32768
#define SHAVED				65536

//Pre-baked combinations of the above body flags
#define HAS_BODY_ACCESSORY 	HAS_TAIL|HAS_WING
#define HAS_MARKINGS		HAS_HEAD_MARKINGS|HAS_BODY_MARKINGS|HAS_TAIL_MARKINGS

//Species Diet Flags
#define DIET_CARN		1
#define DIET_OMNI		2
#define DIET_HERB		4


//bitflags for door switches.
#define OPEN	1
#define IDSCAN	2
#define BOLTS	4
#define SHOCK	8
#define SAFE	16

//flags for pass_flags
#define PASSTABLE		(1<<0)
#define PASSGLASS		(1<<1)
#define PASSGRILLE		(1<<2)
#define PASSBLOB		(1<<3)
#define PASSMOB			(1<<4)
#define LETPASSTHROW	(1<<5)
#define PASSFENCE		(1<<6)
#define PASSDOOR		(1<<7)
#define PASSGIRDER		(1<<8)

//turf-only flags
#define NOJAUNT		1
#define NO_LAVA_GEN	2 //Blocks lava rivers being generated on the turf
#define NO_RUINS 	4

//ITEM INVENTORY SLOT BITMASKS
#define SLOT_FLAG_OCLOTHING	(1<<0)
#define SLOT_FLAG_ICLOTHING	(1<<1)
#define SLOT_FLAG_GLOVES		(1<<2)
#define SLOT_FLAG_EYES		(1<<3)
#define SLOT_FLAG_EARS		(1<<4)
#define SLOT_FLAG_MASK		(1<<5)
#define SLOT_FLAG_HEAD		(1<<6)
#define SLOT_FLAG_FEET		(1<<7)
#define SLOT_FLAG_ID			(1<<8)
#define SLOT_FLAG_BELT		(1<<9)
#define SLOT_FLAG_BACK		(1<<10)
#define SLOT_FLAG_POCKET 	(1<<11)	//this is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_FLAG_TWOEARS	(1<<12)
#define SLOT_FLAG_PDA		(1<<13)
#define SLOT_FLAG_TIE		(1<<14)

//ORGAN TYPE FLAGS
#define AFFECT_ROBOTIC_ORGAN	1
#define AFFECT_ORGANIC_ORGAN	2
#define AFFECT_ALL_ORGANS		3

//Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF		(1<<0)
#define FIRE_PROOF		(1<<1) //100% immune to fire damage (but not necessarily to lava or heat)
#define FLAMMABLE		(1<<2)
#define ON_FIRE			(1<<3)
#define UNACIDABLE		(1<<4) //acid can't even appear on it, let alone melt it.
#define ACID_PROOF		(1<<5) //acid stuck on it doesn't melt it.
#define INDESTRUCTIBLE	(1<<6) //doesn't take damage
#define FREEZE_PROOF	(1<<7) //can't be frozen

//tesla_zap
#define ZAP_MACHINE_EXPLOSIVE		(1<<0)
#define ZAP_ALLOW_DUPLICATES		(1<<1)
#define ZAP_OBJ_DAMAGE				(1<<2)
#define ZAP_MOB_DAMAGE				(1<<3)
#define ZAP_MOB_STUN				(1<<4)
#define ZAP_GENERATES_POWER			(1<<5)

#define ZAP_DEFAULT_FLAGS ZAP_MOB_STUN | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
#define ZAP_FUSION_FLAGS ZAP_OBJ_DAMAGE | ZAP_MOB_DAMAGE | ZAP_MOB_STUN
#define ZAP_SUPERMATTER_FLAGS ZAP_GENERATES_POWER

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

//Mob mobility var flags
/// can move
#define MOBILITY_MOVE (1<<0)
/// can, and is, standing up
#define MOBILITY_STAND (1<<1)
/// can pickup items
#define MOBILITY_PICKUP (1<<2)
/// can hold and use items
#define MOBILITY_USE (1<<3)
/// can pull things
#define MOBILITY_PULL (1<<4)

#define MOBILITY_FLAGS_DEFAULT (MOBILITY_MOVE | MOBILITY_STAND | MOBILITY_PICKUP | MOBILITY_USE | MOBILITY_PULL)
