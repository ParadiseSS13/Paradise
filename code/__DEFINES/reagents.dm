#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REAGENT_OVERDOSE_EFFECT 1
#define REAGENT_OVERDOSE_FLAGS 2
// container_type defines
#define INJECTABLE		1	// Makes it possible to add reagents through droppers and syringes.
#define DRAWABLE		2	// Makes it possible to remove reagents through syringes.

#define REFILLABLE		4	// Makes it possible to add reagents through any reagent container.
#define DRAINABLE		8	// Makes it possible to remove reagents through any reagent container.

#define TRANSPARENT		16	// Used on containers which you want to be able to see the reagents off.
#define AMOUNT_VISIBLE	32	// For non-transparent containers that still have the general amount of reagents in them visible.

// Is an open container for all intents and purposes.
#define OPENCONTAINER 	(REFILLABLE | DRAINABLE | TRANSPARENT)
