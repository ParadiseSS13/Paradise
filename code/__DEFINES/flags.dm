//FLAGS BITMASK
#define STOPSPRESSUREDMAGE 		1		//This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_BACK) if you see it anywhere To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.
#define NODROP					2		// This flag makes it so that an item literally cannot be removed at all, or at least that's how it should be. Only deleted.
#define NOBLUDGEON  			4		// when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define MASKINTERNALS			8		// mask allows internals
//#define USEDELAY 				16		// 1 second extra delay on use (Can be used once every 2s)
#define NOSHIELD				32		// weapon not affected by shield
#define CONDUCT					64		// conducts electricity (metal etc.)
#define ABSTRACT				128		// for all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way
#define ON_BORDER				512		// item has priority to check when entering or leaving
#define NODELAY 				32768	// 1 second attackby delay skipped (Can be used once every 0.2s). Most objects have a 1s attackby delay, which doesn't require a flag.

#define NOBLOODY				2048	// used to items if they don't want to get a blood overlay

#define GLASSESCOVERSEYES		1024
#define MASKCOVERSEYES			1024	// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES			1024	// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH			2048	// on other items, these are just for mask/head
#define HEADCOVERSMOUTH			2048

#define HEADBANGPROTECT			4096
#define EARBANGPROTECT			1024

#define THICKMATERIAL 	1024			//prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body. (NOTE: flag shared with NOSLIP)
#define NOSLIP					1024 	//prevents from slipping on wet floors, in space etc

#define OPENCONTAINER			4096	// is an open container for chemistry purposes

#define BLOCK_GAS_SMOKE_EFFECT	8192	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY! (NOTE: flag shared with ONESIZEFITSALL)
#define ONESIZEFITSALL 			8192
#define PLASMAGUARD 			16384	//Does not get contaminated by plasma.

#define	NOREACT					16384 	//Reagents dont' react inside this container.

//Species flags.

#define NO_BLOOD		1
#define NO_BREATHE 		2
#define RAD_ABSORB		8
#define NO_SCAN 		16
#define NO_PAIN 		32
#define REQUIRE_LIGHT 	64
#define IS_WHITELISTED 	128
#define HAS_LIPS 		512
#define HAS_UNDERWEAR 	1024
#define IS_SYNTHETIC	2048
#define IS_PLANT 		4096
#define CAN_BE_FAT 		8192
#define IS_RESTRICTED 	16384
#define NO_INTORGANS	32768

//Species Blood Flags
#define BLOOD_SLIME		1
//Species Body Flags
#define FEET_CLAWS		1
#define FEET_PADDED		2
#define FEET_NOSLIP		4
#define HAS_TAIL 		8
#define HAS_SKIN_TONE 	16
#define HAS_SKIN_COLOR	32
#define TAIL_WAGGING    64

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
#define PASSTABLE	1
#define PASSGLASS	2
#define PASSGRILLE	4
#define PASSBLOB	8
#define PASSMOB		16

//turf-only flags
#define NOJAUNT		1

//ITEM INVENTORY SLOT BITMASKS
#define SLOT_OCLOTHING 1
#define SLOT_ICLOTHING 2
#define SLOT_GLOVES 4
#define SLOT_EYES 8
#define SLOT_EARS 16
#define SLOT_MASK 32
#define SLOT_HEAD 64
#define SLOT_FEET 128
#define SLOT_ID 256
#define SLOT_BELT 512
#define SLOT_BACK 1024
#define SLOT_POCKET 2048		//this is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_DENYPOCKET 4096	//this is to deny items with a w_class of 2 or 1 to fit in pockets.
#define SLOT_TWOEARS 8192
#define SLOT_PDA 16384
#define SLOT_TIE 32768