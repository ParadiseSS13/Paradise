#define ALL ~0 //For convenience.
#define NONE 0

/// All the cardinal direction bitflags.
#define ALL_CARDINALS (NORTH | SOUTH | EAST | WEST)

//FLAGS BITMASK
#define STOPSPRESSUREDMAGE		(1<<0)		//This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & ITEM_SLOT_BACK) if you see it anywhere To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.
#define NODROP					(1<<1)		// This flag makes it so that an item literally cannot be removed at all, or at least that's how it should be. Only deleted.
#define NOBLUDGEON  			(1<<2)		// when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define AIRTIGHT				(1<<3)		// mask allows internals
#define HANDSLOW				(1<<4)		// If an item has this flag, it will slow you to carry it
#define CONDUCT					(1<<5)		// conducts electricity (metal etc.)
#define ABSTRACT				(1<<6)		// for all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way
#define ON_BORDER				(1<<7)		// item has priority to check when entering or leaving
#define PREVENT_CLICK_UNDER		(1<<8)
#define NODECONSTRUCT			(1<<9)
#define EARBANGPROTECT			(1<<10)
#define HEADBANGPROTECT			(1<<11)
#define SKIP_TRANSFORM_REEQUIP	(1<<15)		// This flag makes items be skipped when a user transforms species.

#define BLOCK_GAS_SMOKE_EFFECT	(1<<12)	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY!
#define THICKMATERIAL 			(1<<12)	//prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body. (NOTE: flag shared with BLOCK_GAS_SMOKE_EFFECT)

#define DROPDEL					(1<<13)	// When dropped, it calls qdel on itself

///Whether or not this atom shows screentips when hovered over
#define NO_SCREENTIPS			(1<<14)

// Update flags for [/atom/proc/update_appearance]
/// Update the atom's name
#define UPDATE_NAME			(1<<0)
/// Update the atom's desc
#define UPDATE_DESC			(1<<1)
/// Update the atom's icon state
#define UPDATE_ICON_STATE	(1<<2)
/// Update the atom's overlays
#define UPDATE_OVERLAYS		(1<<3)
/// Update the atom's icon
#define UPDATE_ICON			(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/* Secondary atom flags, for the flags_2 var, denoted with a _2 */

#define SLOWS_WHILE_IN_HAND_2		(1<<0)
#define NO_EMP_WIRES_2				(1<<1)
#define HOLOGRAM_2					(1<<2)
#define FROZEN_2					(1<<3)
#define STATIONLOVING_2				(1<<4)
#define INFORM_ADMINS_ON_RELOCATE_2	(1<<5)
#define BANG_PROTECT_2				(1<<6)
#define BLOCKS_LIGHT_2				(1<<7) // Light sources placed in anything with that flag will not emit light through them.
/// Whether a decal element's parent has already been initialized and thus has already had its decals attached.
/// see https://github.com/tgstation/tgstation/pull/71658 for a detailed explanation of the flag.
#define DECAL_INIT_UPDATE_EXPERIENCED_2 (1<<8)

// A mob with OMNITONGUE has no restriction in the ability to speak
// languages that they know. So even if they wouldn't normally be able to
// through mob or tongue restrictions, this flag allows them to ignore
// those restrictions.
#define OMNITONGUE_2			(1<<8)

/// Prevents mobs from getting chainshocked by teslas and the supermatter
#define SHOCKED_2				(1<<9)

// Stops you from putting things like an RCD or other items into an ORM or protolathe for materials.
#define NO_MAT_REDEMPTION_2		(1<<10)

// LAVA_PROTECT used on the flags_2 variable for both SUIT and HEAD items, and stops lava damage. Must be present in both to stop lava damage.
#define LAVA_PROTECT_2			(1<<11)

#define OVERLAY_QUEUED_2		(1<<12)

/// should the contents of this atom be acted upon
#define RAD_PROTECT_CONTENTS_2		(1<<14)
/// should this object be allowed to be contaminated
#define RAD_NO_CONTAMINATE_2		(1<<15)
/// Prevents shuttles from deleting the item
#define IMMUNE_TO_SHUTTLECRUSH_2 	(1<<16)
/// Prevents malf AI animate + overload ability
#define NO_MALF_EFFECT_2			(1<<17)
/// Use when this shouldn't be obscured by large icons.
#define CRITICAL_ATOM_2				(1<<18)
/// Use this flag for items that can block randomly
#define RANDOM_BLOCKER_2			(1<<19)
/// This flag allows for wearing of a belt item, even if you're not wearing a jumpsuit
#define ALLOW_BELT_NO_JUMPSUIT_2	(1<<20)

// /atom ricochet flags
/// If the thing can reflect light (lasers/energy)
#define RICOCHET_SHINY	(1<<0)
/// If the thing can reflect matter (bullets/bomb shrapnel)
#define RICOCHET_HARD 	(1<<1)

//Reagent flags
#define REAGENT_NOREACT			1

//Species clothing flags
#define HAS_UNDERWEAR	(1<<0)
#define HAS_UNDERSHIRT	(1<<1)
#define HAS_SOCKS		(1<<2)

//Species Body Flags
#define HAS_HEAD_ACCESSORY	(1<<0)
#define HAS_TAIL 			(1<<1)
#define TAIL_OVERLAPPED		(1<<2)
#define HAS_SKIN_TONE 		(1<<3)
#define HAS_ICON_SKIN_TONE	(1<<4)
#define HAS_SKIN_COLOR		(1<<5)
#define HAS_HEAD_MARKINGS	(1<<6)
#define HAS_BODY_MARKINGS	(1<<7)
#define HAS_TAIL_MARKINGS	(1<<8)
#define TAIL_WAGGING    	(1<<9)
#define NO_EYES				(1<<10)
#define HAS_ALT_HEADS		(1<<11)
#define HAS_WING			(1<<12)
#define HAS_BODYACC_COLOR	(1<<13)
#define BALD				(1<<14)
#define ALL_RPARTS			(1<<15)
#define SHAVED				(1<<16)

//Pre-baked combinations of the above body flags
#define HAS_BODY_ACCESSORY 	(HAS_TAIL | HAS_WING)
#define HAS_MARKINGS		(HAS_HEAD_MARKINGS | HAS_BODY_MARKINGS | HAS_TAIL_MARKINGS)

//Species Diet Flags
#define DIET_CARN		(1<<0)
#define DIET_OMNI		(1<<1)
#define DIET_HERB		(1<<2)


//bitflags for door switches.
#define OPEN	(1<<0)
#define IDSCAN	(1<<1)
#define BOLTS	(1<<2)
#define SHOCK	(1<<3)
#define SAFE	(1<<4)

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
#define PASSTAKE    	(1<<9)
#define PASSBARRICADE	(1<<10)

//turf-only flags, under the flags variable
#define BLESSED_TILE	(1<<0)
#define NO_LAVA_GEN	    (1<<1) //Blocks lava rivers being generated on the turf
#define NO_RUINS     	(1<<2)
#define LAVA_BRIDGE		(1<<3)	//! This turf has already been reserved for a lavaland bridge placement.

// turf flags, under the turf_flags variable
/// If a turf is an unused reservation turf awaiting assignment
#define UNUSED_RESERVATION_TURF (1<<4)
/// If a turf is a reserved turf
#define RESERVATION_TURF (1<<5)

//ORGAN TYPE FLAGS
#define AFFECT_ROBOTIC_ORGAN	1
#define AFFECT_ORGANIC_ORGAN	2
#define AFFECT_ALL_ORGANS	3

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
#define ZAP_MACHINE_EXPLOSIVE	(1<<0)
#define ZAP_ALLOW_DUPLICATES	(1<<1)
#define ZAP_OBJ_DAMAGE			(1<<2)
#define ZAP_MOB_DAMAGE			(1<<3)
#define ZAP_MOB_STUN			(1<<4)
#define ZAP_GENERATES_POWER		(1<<5)

#define ZAP_DEFAULT_FLAGS (ZAP_MOB_STUN | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
#define ZAP_FUSION_FLAGS (ZAP_OBJ_DAMAGE | ZAP_MOB_DAMAGE | ZAP_MOB_STUN)
#define ZAP_SUPERMATTER_FLAGS (ZAP_GENERATES_POWER)

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

//Mob mobility var flags
/// can move
#define MOBILITY_MOVE	(1<<0)
/// can, and is, standing up
#define MOBILITY_STAND	(1<<1)
/// can pickup items
#define MOBILITY_PICKUP	(1<<2)
/// can hold and use items
#define MOBILITY_USE	(1<<3)
/// can pull things
#define MOBILITY_PULL	(1<<4)

#define MOBILITY_FLAGS_DEFAULT (MOBILITY_MOVE | MOBILITY_STAND | MOBILITY_PICKUP | MOBILITY_USE | MOBILITY_PULL)

// Scope component flags
/// Do we have the scope cancel on move?
#define SCOPE_MOVEMENT_CANCELS 	(1<<0)
/// Can we use scope from mechs, lockers, etc?
#define SCOPE_TURF_ONLY 		(1<<1)
/// Do we let the user scope and click on the middle of their screen?
#define SCOPE_CLICK_MIDDLE 		(1<<2)
/// Should the user hold the item in active hand to use it?
#define SCOPE_NEED_ACTIVE_HAND 	(1<<3)
