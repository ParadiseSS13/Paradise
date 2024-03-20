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

// Slot defines for var/list/inv_slots, some of these dont really show up on the HUD,
// but still function like it in other ways. I know thats weird, and I hate it too.
#define SLOT_HUD_BACK 1
#define SLOT_HUD_WEAR_MASK 2
#define SLOT_HUD_HANDCUFFED 3
#define SLOT_HUD_LEFT_HAND 4 // l_hand
#define SLOT_HUD_RIGHT_HAND 5 // r_hand
#define SLOT_HUD_BELT 6
#define SLOT_HUD_WEAR_ID 7
#define SLOT_HUD_LEFT_EAR 8 // l_ear
#define SLOT_HUD_GLASSES 9
#define SLOT_HUD_GLOVES 10
#define SLOT_HUD_HEAD 11
#define SLOT_HUD_SHOES 12
#define SLOT_HUD_OUTER_SUIT 13 // wear_suit
#define SLOT_HUD_JUMPSUIT 14 // w_uniform
#define SLOT_HUD_LEFT_STORE 15 // l_store
#define SLOT_HUD_RIGHT_STORE 16 // r_store
#define SLOT_HUD_SUIT_STORE 17
#define SLOT_HUD_IN_BACKPACK 18 // this just puts stuff a backpack if you have one
#define SLOT_HUD_LEGCUFFED 19
#define SLOT_HUD_RIGHT_EAR 20 // r_ear
#define SLOT_HUD_WEAR_PDA 21
#define SLOT_HUD_TIE 22
#define SLOT_HUD_COLLAR 23
#define SLOT_HUD_AMOUNT 23

// accessory slots
#define ACCESSORY_SLOT_DECOR 1
#define ACCESSORY_SLOT_UTILITY 2
#define ACCESSORY_SLOT_ARMBAND 3

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
