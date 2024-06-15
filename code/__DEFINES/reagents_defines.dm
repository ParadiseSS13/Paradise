#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REAGENT_OVERDOSE_EFFECT 1
#define REAGENT_OVERDOSE_FLAGS 2
// container_type defines
#define INJECTABLE		(1<<0)	// Makes it possible to add reagents through droppers and syringes.
#define DRAWABLE		(1<<1)	// Makes it possible to remove reagents through syringes.

#define REFILLABLE		(1<<2)	// Makes it possible to add reagents through any reagent container.
#define DRAINABLE		(1<<3)	// Makes it possible to remove reagents through any reagent container.

#define TRANSPARENT		(1<<4)	// Used on containers which you want to be able to see the reagents off.
#define AMOUNT_VISIBLE	(1<<5)	// For non-transparent containers that still have the general amount of reagents in them visible.

// Is an open container for all intents and purposes.
#define OPENCONTAINER 	(REFILLABLE | DRAINABLE | TRANSPARENT)

#define REAGENT_TOUCH 1
#define REAGENT_INGEST 2

///Health threshold for synthflesh and rezadone to unhusk someone
#define UNHUSK_DAMAGE_THRESHOLD 50
///Amount of synthflesh required to unhusk someone
#define SYNTHFLESH_UNHUSK_AMOUNT 100

///Syringe mob interaction modes
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2

/// Like O- blood but doesn't contribute to blood_volume or vampire nutrition
#define BLOOD_TYPE_FAKE_BLOOD	"Vh Null"

/// Used for secondary goals.
/// TOO easy, not accepted for variety goals.
#define REAGENT_GOAL_SKIP 0
/// Easy reagent, ask for a lot for single goals.
#define REAGENT_GOAL_EASY 1
/// Normal reagent, ask for a middling amount for single goals.
#define REAGENT_GOAL_NORMAL 2
/// Hard reagent, ask for a little for single goals.
#define REAGENT_GOAL_HARD 3
/// TOO hard, accepted for variety goals, but never used for single goals.
#define REAGENT_GOAL_EXCESSIVE 4
