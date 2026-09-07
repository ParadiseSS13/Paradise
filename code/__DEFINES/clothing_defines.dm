//Item inventory slots bitmasks
#define ITEM_SLOT_BACK 			(1<<0) // back
#define ITEM_SLOT_MASK 			(1<<1) // mask
#define ITEM_SLOT_HANDCUFFED 	(1<<2) // handcuffs
#define ITEM_SLOT_LEFT_HAND 	(1<<3) // l_hand
#define ITEM_SLOT_RIGHT_HAND 	(1<<4) // r_hand
#define ITEM_SLOT_BOTH_HANDS	(ITEM_SLOT_LEFT_HAND | ITEM_SLOT_RIGHT_HAND)
#define ITEM_SLOT_BELT 			(1<<5) // belt
#define ITEM_SLOT_ID 			(1<<6) // id
#define ITEM_SLOT_LEFT_EAR 		(1<<7) // l_ear
#define ITEM_SLOT_RIGHT_EAR 	(1<<8) // r_ear
#define ITEM_SLOT_BOTH_EARS		(ITEM_SLOT_LEFT_EAR | ITEM_SLOT_RIGHT_EAR)
#define ITEM_SLOT_EYES 			(1<<9) // eyes
#define ITEM_SLOT_GLOVES 		(1<<10) // gloves
#define ITEM_SLOT_HEAD 			(1<<11) // head
#define ITEM_SLOT_SHOES 		(1<<12) // shoes
#define ITEM_SLOT_OUTER_SUIT 	(1<<13) // wear_suit
#define ITEM_SLOT_JUMPSUIT	 	(1<<14) // w_uniform
#define ITEM_SLOT_LEFT_POCKET 	(1<<15) // l_store
#define ITEM_SLOT_RIGHT_POCKET 	(1<<16) // r_store
#define ITEM_SLOT_BOTH_POCKETS	(ITEM_SLOT_LEFT_POCKET | ITEM_SLOT_RIGHT_POCKET)
#define ITEM_SLOT_SUIT_STORE 	(1<<17) // suit_storage
#define ITEM_SLOT_IN_BACKPACK 	(1<<18) // this just puts stuff a backpack if you have one
#define ITEM_SLOT_LEGCUFFED 	(1<<19) // legcuffs
#define ITEM_SLOT_PDA 			(1<<20) // pda
#define ITEM_SLOT_ACCESSORY 	(1<<21) // accessories
#define ITEM_SLOT_COLLAR 		(1<<22) // pet collar
#define ITEM_SLOT_NECK			(1<<23) // neck
#define ITEM_SLOT_AMOUNT_FLAG	(1<<(ITEM_SLOT_AMOUNT-1))
#define ITEM_SLOT_AMOUNT 		24 // IF YOU ADD ANY NEW CLOTHING SLOTS, MAKE SURE TO UPDATE THIS TO THE AMOUNT OF SLOTS.

/// Translates an ITEM_SLOT back to an index that can be looked up in inv_slots. e.g. (1<<19) becomes 19.
#define ITEM_SLOT_2_INDEX(slot) (round(log(2, slot), 1) + 1)

//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
#define HIDEGLOVES		(1<<0)	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESUITSTORAGE	(1<<1)	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEJUMPSUIT	(1<<2)	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESHOES		(1<<3)	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDETAIL 		(1<<4)	//APPLIES ONLY TO THE EXTERIOR SUIT!!

#define HIDEMASK	(1<<0)	//APPLIES ONLY TO HELMETS/MASKS!!
#define HIDEEARS	(1<<1)	//APPLIES ONLY TO HELMETS/MASKS!! (ears means headsets and such)
#define HIDEEYES	(1<<2)	//APPLIES ONLY TO HELMETS/MASKS!! (eyes means glasses)
#define HIDEFACE	(1<<3)	//APPLIES ONLY TO HELMETS/MASKS!! Dictates whether we appear as unknown.

// Boolean defines for hands
#define HAND_BOOL_RIGHT 0
#define HAND_BOOL_LEFT 1

// accessory slots
#define ACCESSORY_SLOT_DECOR    (1<<0)
#define ACCESSORY_SLOT_UTILITY  (1<<1)
#define ACCESSORY_SLOT_ARMBAND  (1<<2)

///max number of accessories that can be equiped to one piece of clothing
#define MAX_EQUIPABLE_ACCESSORIES 5
//Cant seem to find a mob bitflags area other than the powers one

// bitflags for clothing parts
#define HEAD			(1<<0)
#define UPPER_TORSO		(1<<1)
#define LOWER_TORSO		(1<<2)
#define LEG_LEFT		(1<<3)
#define LEG_RIGHT		(1<<4)
#define LEGS			(LEG_LEFT | LEG_RIGHT)
#define FOOT_LEFT		(1<<5)
#define FOOT_RIGHT		(1<<6)
#define FEET			(FOOT_LEFT | FOOT_RIGHT)
#define ARM_LEFT		(1<<7)
#define ARM_RIGHT		(1<<8)
#define ARMS			(ARM_LEFT | ARM_RIGHT)
#define HAND_LEFT		(1<<9)
#define HAND_RIGHT		(1<<10)
#define HANDS			(HAND_LEFT | HAND_RIGHT)
#define FULL_BODY		((1<<11)-1) //10 bit bitmask, update me if we ever add more clothing parts.

// the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection()
// The values here should add up to 1.
// Hands and feet have 2.5%, arms and legs 7.5%, each of the torso parts has 15% and the head has 30%
#define THERMAL_PROTECTION_HEAD			0.3
#define THERMAL_PROTECTION_UPPER_TORSO	0.15
#define THERMAL_PROTECTION_LOWER_TORSO	0.15
#define THERMAL_PROTECTION_LEG_LEFT		0.075
#define THERMAL_PROTECTION_LEG_RIGHT	0.075
#define THERMAL_PROTECTION_FOOT_LEFT	0.025
#define THERMAL_PROTECTION_FOOT_RIGHT	0.025
#define THERMAL_PROTECTION_ARM_LEFT		0.075
#define THERMAL_PROTECTION_ARM_RIGHT	0.075
#define THERMAL_PROTECTION_HAND_LEFT	0.025
#define THERMAL_PROTECTION_HAND_RIGHT	0.025

//flags for covering body parts
#define GLASSESCOVERSEYES	(1<<0)
#define MASKCOVERSEYES		(1<<1)		// get rid of some of the other mess in these flags
#define HEADCOVERSEYES		(1<<2)		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH		(1<<3)		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH		(1<<4)

// Suit sensor levels
#define SUIT_SENSOR_OFF 0
#define SUIT_SENSOR_BINARY 1
#define SUIT_SENSOR_VITAL 2
#define SUIT_SENSOR_TRACKING 3

#define BLOCKHEADHAIR 			4		// temporarily removes the user's hair overlay. Leaves facial hair.
#define BLOCKHAIR				32768	// temporarily removes the user's hair, facial and otherwise.

//flags for muzzle speech blocking
#define MUZZLE_MUTE_NONE 0 // Does not mute you.
#define MUZZLE_MUTE_MUFFLE 1 // Muffles everything you say "MHHPHHMMM!!!
#define MUZZLE_MUTE_ALL 2 // Completely mutes you.

