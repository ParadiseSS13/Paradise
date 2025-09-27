///////////////////ORGAN DEFINES///////////////////

// Organ defines.
#define ORGAN_BROKEN       (1 << 0)
#define ORGAN_ROBOT        (1 << 1)
#define ORGAN_SPLINTED     (1 << 2)
#define ORGAN_DEAD         (1 << 3)
#define ORGAN_MUTATED      (1 << 4)
#define ORGAN_INT_BLEEDING (1 << 5)
#define ORGAN_DISFIGURED   (1 << 6)
#define ORGAN_BURNT		   (1 << 7)
#define ORGAN_SALVED	   (1 << 8)

// Organ datum defines. Each one of these represents a slot for organ datums in internal_organ_datums
#define ORGAN_DATUM_HEART	"heart"
#define ORGAN_DATUM_LUNGS	"lungs"
#define ORGAN_DATUM_BATTERY "battery"

// Organ quality datums.
#define ORGAN_DAMAGED 1
#define ORGAN_NORMAL 2
#define ORGAN_PRISTINE 3

// For limb resistance flags
#define CANNOT_BREAK		(1 << 0)
#define CANNOT_DISMEMBER 	(1 << 1)
#define CANNOT_BURN			(1 << 2)
#define CANNOT_INT_BLEED	(1 << 3)

#define PROCESS_ACCURACY 10

#define DROPLIMB_SHARP 0
#define DROPLIMB_BLUNT 1
#define DROPLIMB_BURN 2

//Mob bio-types flags
#define MOB_ORGANIC 	(1 << 0)
#define MOB_MINERAL		(1 << 1)
#define MOB_ROBOTIC 	(1 << 2)
#define MOB_UNDEAD		(1 << 3)
#define MOB_HUMANOID 	(1 << 4)
#define MOB_BUG 		(1 << 5)
#define MOB_BEAST		(1 << 6)  // Not meant for human species, generally
#define MOB_EPIC		(1 << 7) //megafauna
#define MOB_REPTILE		(1 << 8)
#define MOB_SPIRIT		(1 << 9)
#define MOB_PLANT		(1 << 10)

#define AGE_MIN 20			//youngest a character can be
#define AGE_MAX 500			//oldest a character can be

/// Mob is standing up, usually associated with lying_angle value of 0.
#define STANDING_UP 0
/// Mob is lying down, usually associated with lying_angle values of 90 or 270.
#define LYING_DOWN 1

///How much a mob's sprite should be moved when they're lying down
#define PIXEL_Y_OFFSET_LYING -6

#define LEFT 1
#define RIGHT 2

#define SPLINT_LIFE 2000 //number of steps splints stay on


//Pulse levels, very simplified
#define PULSE_NONE		0	//so !M.pulse checks would be possible
#define PULSE_SLOW		1	//<60 bpm
#define PULSE_NORM		2	//60-90 bpm
#define PULSE_FAST		3	//90-120 bpm
#define PULSE_2FAST		4	//>120 bpm
#define PULSE_THREADY	5	//occurs during hypovolemic shock
//feel free to add shit to lists below

//Reagent Metabolization flags, defines the type of reagents that affect this mob
#define PROCESS_ORG (1<<0)		//Only processes reagents with "ORGANIC" or "ORGANIC | SYNTHETIC"
#define PROCESS_SYN (1<<1)		//Only processes reagents with "SYNTHETIC" or "ORGANIC | SYNTHETIC"
#define PROCESS_DUO (1<<2)		//Only processes reagents with "ORGANIC | SYNTHETIC"

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.
#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.
#define SHOES_SLOWDOWN 0			// How much shoes slow you down by default. Negative values speed you up


//Mob attribute defaults.
#define DEFAULT_MARKING_STYLES list("head" = "None", "body" = "None", "tail" = "None") //Marking styles. Use instead of initial() for m_styles.
#define DEFAULT_MARKING_COLOURS list("head" = "#000000", "body" = "#000000", "tail" = "#000000") //Marking colours. Use instead of initial() for m_colours.

#define OXYCONCEN_PLASMEN_IGNITION 0.5 //Moles of oxygen in the air needed to light up a poorly clothed Plasmaman. Same as LINDA requirements for plasma burning.

////////REAGENT STUFF////////
// How many units of reagent are consumed per tick, by default.
#define  REAGENTS_METABOLISM 0.4

// By defining the effect multiplier this way, it'll exactly adjust
// all effects according to how they originally were with the 0.4 metabolism
#define REAGENTS_EFFECT_MULTIPLIER REAGENTS_METABOLISM / 0.4

// Factor of how fast mob nutrition decreases
#define	HUNGER_FACTOR 0.1

// Taste sensitivity - lower is more sensitive
// Represents the minimum portion of total taste the mob can sense
#define TASTE_SENSITIVITY_NORMAL 15
#define TASTE_SENSITIVITY_SHARP 10
#define TASTE_SENSITIVITY_DULL 25
#define TASTE_SENSITIVITY_NO_TASTE 101

// Reagent type flags, defines the types of mobs this reagent will affect
#define ORGANIC 1
#define SYNTHETIC 2

// Appearance change flags
#define APPEARANCE_UPDATE_DNA 					(1<<0)
#define APPEARANCE_RACE							(1<<1)|APPEARANCE_UPDATE_DNA
#define APPEARANCE_GENDER 						(1<<2)|APPEARANCE_UPDATE_DNA
#define APPEARANCE_SKIN 						(1<<3)
#define APPEARANCE_HAIR 						(1<<4)
#define APPEARANCE_HAIR_COLOR 					(1<<5)
#define APPEARANCE_SECONDARY_HAIR_COLOR 		(1<<6)
#define APPEARANCE_FACIAL_HAIR 					(1<<7)
#define APPEARANCE_FACIAL_HAIR_COLOR 			(1<<8)
#define APPEARANCE_SECONDARY_FACIAL_HAIR_COLOR 	(1<<9)
#define APPEARANCE_EYE_COLOR 					(1<<10)
#define APPEARANCE_ALL_HAIR 					(APPEARANCE_HAIR|APPEARANCE_HAIR_COLOR|APPEARANCE_SECONDARY_HAIR_COLOR|APPEARANCE_FACIAL_HAIR|APPEARANCE_FACIAL_HAIR_COLOR|APPEARANCE_SECONDARY_FACIAL_HAIR_COLOR)
#define APPEARANCE_HEAD_ACCESSORY 				(1<<11)
#define APPEARANCE_MARKINGS 					(1<<12)
#define APPEARANCE_BODY_ACCESSORY 				(1<<13)
#define APPEARANCE_ALT_HEAD 					(1<<14)
#define APPEARANCE_ALL_BODY 					(APPEARANCE_ALL_HAIR|APPEARANCE_HEAD_ACCESSORY|APPEARANCE_MARKINGS|APPEARANCE_BODY_ACCESSORY|APPEARANCE_ALT_HEAD)
#define APPEARANCE_ALL 							((1<<15)-1) // If you add or remove an appearance change flag above, make sure you update this define with the amount of the flags.

#define STAMINA_REGEN_BLOCK_TIME (10 SECONDS)

//Slime evolution threshold. Controls how fast slimes can split/grow
#define SLIME_EVOLUTION_THRESHOLD 10

//Slime extract crossing. Controls how many extracts is required to feed to a slime to core-cross.
#define SLIME_EXTRACT_CROSSING_REQUIRED 10

//If you add a new status, be sure to add a list for it to the simple_animals global in _globalvars/lists/mobs.dm
//Hostile Mob AI Status
#define AI_ON       1
#define AI_IDLE     2
#define AI_OFF      3
#define AI_Z_OFF    4

// Intents
#define INTENT_HELP		"help"
#define INTENT_DISARM	"disarm"
#define INTENT_GRAB		"grab"
#define INTENT_HARM		"harm"

// Movement Intents
#define MOVE_INTENT_WALK "walk"
#define MOVE_INTENT_RUN  "run"

// AI wire/radio settings
#define AI_CHECK_WIRELESS 1
#define AI_CHECK_RADIO 2

//determines if a mob can smash through it
#define ENVIRONMENT_SMASH_NONE 			0
#define ENVIRONMENT_SMASH_STRUCTURES 	(1<<0) //crates, lockers, ect
#define ENVIRONMENT_SMASH_WALLS 		(1<<1) //walls
#define ENVIRONMENT_SMASH_RWALLS 		(1<<2) //rwalls

// Reproduction
#define DEFAULT_MAX_OFFSPRING 8

///Flags used by the flags parameter of electrocute act.

///Makes it so that the shock doesn't take gloves into account.
#define SHOCK_NOGLOVES 	(1<<0)
///Used when the shock is from a tesla bolt.
#define SHOCK_TESLA 	(1<<1)
///Used when an illusion shocks something. Makes the shock deal stamina damage and not trigger certain secondary effects.
#define SHOCK_ILLUSION 	(1<<2)
///The shock doesn't stun.
#define SHOCK_NOSTUN 	(1<<3)

#define POCKET_STRIP_DELAY			4 SECONDS	//time taken to search somebody's pockets

#define DEFAULT_ITEM_STRIP_DELAY		4 SECONDS  //time taken to strip somebody
#define DEFAULT_ITEM_PUTON_DELAY		2 SECONDS  //time taken to reverse-strip somebody

#define IGNORE_ACCESS -1

//gold slime core spawning
#define NO_SPAWN 0
#define HOSTILE_SPAWN 1
#define FRIENDLY_SPAWN 2

///Max amount of living Xenobio mobs allowed at any given time (excluding slimes).
#define MAX_GOLD_CORE_MOBS 45

#define TINT_IMPAIR 2			//Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3			//Threshold of tint level to obscure vision fully
#define EYE_SHINE_THRESHOLD 6	//dark_view threshold past which a humanoid's eyes will 'shine' in the dark.

#define STATUS_UPDATE_HEALTH 		(1<<0)
#define STATUS_UPDATE_STAT 			(1<<1)
#define STATUS_UPDATE_STAMINA 		(1<<2)
#define STATUS_UPDATE_BLIND 		(1<<3)
#define STATUS_UPDATE_NEARSIGHTED 	(1<<4)

#define STATUS_UPDATE_NONE 0
#define STATUS_UPDATE_ALL (~0)
#define INVISIBILITY_ABSTRACT 101
#define UNHEALING_EAR_DAMAGE 100

/// Nian and Nian Worme cocoon do_after delay, in seconds.
#define COCOON_WEAVE_DELAY 5 SECONDS
/// Nian and Nian worme delay after they emerge from their cocoon, in seconds.
#define COCOON_EMERGE_DELAY 15 SECONDS
/// Nian and nian worme fly swatter damage multiplier, X + 1 => Total multiplier. (Ex. Value of 9 => 10x dmg)
#define FLYSWATTER_DAMAGE_MULTIPLIER 9

/// If you examine the same atom twice in this timeframe, we call examine_more() instead of examine()
#define EXAMINE_MORE_WINDOW 1 SECONDS

#define DIRECTION_LOCK_SLOWDOWN 3

//Human sub-species
#define isabductor(A) (is_species(A, /datum/species/abductor))
#define isgolem(A) (is_species(A, /datum/species/golem))
#define ismonkeybasic(A) (is_species(A, /datum/species/monkey))
#define isfarwa(A) (is_species(A, /datum/species/monkey/tajaran))
#define iswolpin(A) (is_species(A, /datum/species/monkey/vulpkanin))
#define isneara(A) (is_species(A, /datum/species/monkey/skrell))
#define isstok(A) (is_species(A, /datum/species/monkey/unathi))
#define isplasmaman(A) (is_species(A, /datum/species/plasmaman))
#define isshadowperson(A) (is_species(A, /datum/species/shadow))
#define isskeleton(A) (is_species(A, /datum/species/skeleton))
#define ishumanbasic(A) (is_species(A, /datum/species/human))
#define isunathi(A) (is_species(A, /datum/species/unathi))
#define istajaran(A) (is_species(A, /datum/species/tajaran))
#define isvulpkanin(A) (is_species(A, /datum/species/vulpkanin))
#define isskrell(A) (is_species(A, /datum/species/skrell))
#define isvox(A) (is_species(A, /datum/species/vox))
#define iskidan(A) (is_species(A, /datum/species/kidan))
#define isslimeperson(A) (is_species(A, /datum/species/slime))
#define isgrey(A) (is_species(A, /datum/species/grey))
#define isdiona(A) (is_species(A, /datum/species/diona))
#define ismachineperson(A) (is_species(A, /datum/species/machine))
#define isdrask(A) (is_species(A, /datum/species/drask))
#define ismoth(A) (is_species(A, /datum/species/moth))

#define isdog(A)			(istype((A), /mob/living/simple_animal/pet/dog))
#define iscorgi(A)			(istype((A), /mob/living/simple_animal/pet/dog/corgi))
#define ismouse(A)			(istype((A), /mob/living/basic/mouse))
#define isbot(A)			(istype((A), /mob/living/simple_animal/bot))
#define isguardian(A)		(istype((A), /mob/living/simple_animal/hostile/guardian))
#define isnymph(A)      	(istype((A), /mob/living/basic/diona_nymph))
#define iscaterpillar(A)	(istype((A), /mob/living/basic/nian_caterpillar))
#define ishostile(A) 		(istype((A), /mob/living/simple_animal/hostile))
#define isretaliate(A) 		(istype((A), /mob/living/simple_animal/hostile/retaliate))
#define isterrorspider(A) 	(istype((A), /mob/living/simple_animal/hostile/poison/terror_spider))
#define isslaughterdemon(A) (istype((A), /mob/living/simple_animal/demon/slaughter))
#define isdemon(A) 			(istype((A), /mob/living/simple_animal/demon))
#define iscat(A) 			(istype((A), /mob/living/simple_animal/pet/cat))
#define isgorilla(A) 		(istype((A), /mob/living/basic/gorilla))
#define ismorph(A)			(istype((A), /mob/living/simple_animal/hostile/morph))

#define issilicon(A)	(istype((A), /mob/living/silicon))
#define is_ai(A)			(istype((A), /mob/living/silicon/ai))
#define isrobot(A)		(istype((A), /mob/living/silicon/robot))
#define isdrone(A)		(istype((A), /mob/living/silicon/robot/drone))
#define ispAI(A)		(istype((A), /mob/living/silicon/pai))

// For the tcomms monitor
#define ispathhuman(A)		(ispath(A, /mob/living/carbon/human))
#define ispathbrain(A)		(ispath(A, /mob/living/brain))
#define ispathslime(A)		(ispath(A, /mob/living/simple_animal/slime))
#define ispathbot(A)			(ispath(A, /mob/living/simple_animal/bot))
#define ispathsilicon(A)	(ispath(A, /mob/living/silicon))
#define ispathanimal(A)		(ispath(A, /mob/living/simple_animal))

#define iscameramob(A)	(istype((A), /mob/camera))
#define is_ai_eye(A)		(istype((A), /mob/camera/eye/ai))
#define isovermind(A)	(istype((A), /mob/camera/blob))

#define isobserver(A)	(istype((A), /mob/dead/observer))

#define isnewplayer(A)  (istype((A), /mob/new_player))

#define is_external_organ(A)		(istype((A), /obj/item/organ/external))
#define is_internal_organ(A)		(istype((A), /obj/item/organ/internal))
#define	is_organ(A)				(istype((A), /obj/item/organ))

#define is_admin(user)	(check_rights(R_ADMIN, 0, (user)) != 0)

#define is_developer(user) (check_rights(R_DEV_TEAM, 0, (user)) != 0)

#define SLEEP_CHECK_DEATH(X) sleep(X); if(QDELETED(src) || stat == DEAD) return;

// Locations
#define is_ventcrawling(A)  (istype(A.loc, /obj/machinery/atmospherics))
#define is_mecha_occupant(A)  (istype(A.loc, /obj/mecha))

// Hearing protection
#define HEARING_PROTECTION_NONE	0
#define HEARING_PROTECTION_MINOR	1
#define HEARING_PROTECTION_MAJOR	2
#define HEARING_PROTECTION_TOTAL	3

// Defines used in /mob/living/carbon/human/update_health_hud to override the health status
#define HEALTH_HUD_OVERRIDE_NONE 0
#define HEALTH_HUD_OVERRIDE_CRIT 1
#define HEALTH_HUD_OVERRIDE_DEAD 2
#define HEALTH_HUD_OVERRIDE_HEALTHY 3
// Eye protection
#define FLASH_PROTECTION_VERYVUNERABLE -4
#define FLASH_PROTECTION_EXTRA_SENSITIVE -2
#define FLASH_PROTECTION_SENSITIVE -1
#define FLASH_PROTECTION_NONE 0
#define FLASH_PROTECTION_FLASH 1
#define FLASH_PROTECTION_WELDER 2

#define MAX_EYE_BLURRY_FILTER_SIZE 2
#define EYE_BLUR_TO_FILTER_SIZE_MULTIPLIER 0.005

/proc/bodypart_name_to_clothing_bitflag(bodypart_name)
	switch(bodypart_name)
		if("head")
			return HEAD
		if("chest")
			return UPPER_TORSO
		if("groin")
			return LOWER_TORSO
		if("l_arm")
			return ARM_LEFT
		if("l_hand")
			return HAND_LEFT
		if("r_arm")
			return ARM_RIGHT
		if("r_hand")
			return HAND_RIGHT
		if("r_leg")
			return LEG_RIGHT
		if("r_foot")
			return FOOT_RIGHT
		if("l_leg")
			return LEG_LEFT
		if("l_foot")
			return FOOT_LEFT

#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

#define TS_DAMAGE_SIMPLE 0
#define TS_DAMAGE_POISON 1
#define TS_DAMAGE_BRUTE 2

#define TS_DESC_RED "Red - Assault"
#define TS_DESC_GRAY "Gray - Ambush"
#define TS_DESC_GREEN "Green - Nurse"
#define TS_DESC_WHITE "White - Infect"
#define TS_DESC_BLACK "Black - Poison"
#define TS_DESC_PURPLE "Purple - Guard"
#define TS_DESC_BROWN "Brown - Breacher"
#define TS_DESC_PRINCE "Prince - HERO"
#define TS_DESC_PRINCESS "Princess - HORDE"
#define TS_DESC_MOTHER "Mother - SUPPORT"
#define TS_DESC_QUEEN "Queen - LEADER"

#define TS_TIER_1 1
#define TS_TIER_2 2
#define TS_TIER_3 3
#define TS_TIER_4 4
#define TS_TIER_5 5

/* Defines used for `incorporeal_move` */
#define NO_INCORPOREAL_MOVE				0
#define INCORPOREAL_MOVE_NORMAL			1
#define INCORPOREAL_MOVE_NINJA			2
#define INCORPOREAL_MOVE_HOLY_BLOCK		3

// Brain damage ratio defines
// These are built around the baseline of a brain having a max hp of 120
#define BRAIN_DAMAGE_RATIO_LIGHT 	1 / 12
#define BRAIN_DAMAGE_RATIO_MINOR	3 / 12
#define BRAIN_DAMAGE_RATIO_MODERATE 6 / 12
#define BRAIN_DAMAGE_RATIO_SEVERE 	8 / 12
#define BRAIN_DAMAGE_RATIO_CRITICAL 10 / 12

#define GRAB_PIXEL_SHIFT_PASSIVE 6
#define GRAB_PIXEL_SHIFT_AGGRESSIVE 12
#define GRAB_PIXEL_SHIFT_NECK 16

/// Default minimum body temperature mobs can exist in before taking damage
#define NPC_DEFAULT_MIN_TEMP 250
/// Default maximum body temperature mobs can exist in before taking damage
#define NPC_DEFAULT_MAX_TEMP 350

#define MP_SPELL_PRIORITY 		1
#define MP_THROW_MODE_PRIORITY 	2
#define MP_GIVE_MODE_PRIORITY 	3
#define MP_AUTO_GUN_PRIORITY 	4
#define MP_CLOWN_CAR_PRIORITY 	5
#define MP_MECHA_PRIORITY 		6

#define GHOST_START_AS_OBSERVER 	(1 << 0) // Ghost started playing as an observer.
#define GHOST_CAN_REENTER 			(1 << 1) // Ghost can reenter its corpse
#define GHOST_RESPAWNABLE			(1 << 2) // Ghost can respawn. Note that checking respawnability is better via GLOB.non_respawnable_keys and TRAIT_RESPAWNABLE
#define GHOST_VISION				(1 << 3) // Ghost can see invisible things (like other ghosts)
#define GHOST_HEALTH_SCAN			(1 << 4) // Ghost uses health scanner on click
#define GHOST_SEE_RADS				(1 << 5) // Ghost can see radiation
#define GHOST_GAS_SCAN				(1 << 6) // Ghost uses gas analyzer on click
#define GHOST_PLANT_ANALYZER		(1 << 7) // Ghost uses plant analyzer on click

#define GHOST_FLAGS_DEFAULT (GHOST_CAN_REENTER | GHOST_RESPAWNABLE | GHOST_VISION)
#define GHOST_FLAGS_START_AS_OBSERVER (GHOST_FLAGS_DEFAULT | GHOST_START_AS_OBSERVER)
#define GHOST_FLAGS_NO_REENTER (GHOST_FLAGS_DEFAULT & ~GHOST_CAN_REENTER)
#define GHOST_FLAGS_NO_RESPAWNABLE (GHOST_FLAGS_DEFAULT & ~GHOST_RESPAWNABLE)
#define GHOST_FLAGS_OBSERVE_ONLY (GHOST_FLAGS_DEFAULT & ~(GHOST_CAN_REENTER | GHOST_RESPAWNABLE))
