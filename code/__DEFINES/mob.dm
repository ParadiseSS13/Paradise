///////////////////ORGAN DEFINES///////////////////

// Organ defines.
#define ORGAN_BROKEN     1
#define ORGAN_ROBOT      2
#define ORGAN_SPLINTED   4
#define ORGAN_DEAD       8
#define ORGAN_MUTATED    16
#define ORGAN_ASSISTED   32

#define DROPLIMB_SHARP 0
#define DROPLIMB_BLUNT 1
#define DROPLIMB_BURN 2

#define AGE_MIN 17			//youngest a character can be
#define AGE_MAX 85			//oldest a character can be


#define LEFT 1
#define RIGHT 2


//Pulse levels, very simplified
#define PULSE_NONE		0	//so !M.pulse checks would be possible
#define PULSE_SLOW		1	//<60 bpm
#define PULSE_NORM		2	//60-90 bpm
#define PULSE_FAST		3	//90-120 bpm
#define PULSE_2FAST		4	//>120 bpm
#define PULSE_THREADY	5	//occurs during hypovolemic shock
//feel free to add shit to lists below


//proc/get_pulse methods
#define GETPULSE_HAND	0	//less accurate (hand)
#define GETPULSE_TOOL	1	//more accurate (med scanner, sleeper, etc)

//Reagent Metabolization flags, defines the type of reagents that affect this mob
#define PROCESS_ORG 1		//Only processes reagents with "ORGANIC" or "ORGANIC | SYNTHETIC"
#define PROCESS_SYN 2		//Only processes reagents with "SYNTHETIC" or "ORGANIC | SYNTHETIC"
#define PROCESS_DUO 4		//Only processes reagents with "ORGANIC | SYNTHETIC"

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

// Taste sensitivity - the more the more reagents you'll taste
#define TASTE_SENSITIVITY_NORMAL 1
#define TASTE_SENSITIVITY_SHARP 1.5
#define TASTE_SENSITIVITY_DULL 0.75
#define TASTE_SENSITIVITY_NO_TASTE 0

// Reagent type flags, defines the types of mobs this reagent will affect
#define ORGANIC 1
#define SYNTHETIC 2

// Appearance change flags
#define APPEARANCE_UPDATE_DNA 1
#define APPEARANCE_RACE	2|APPEARANCE_UPDATE_DNA
#define APPEARANCE_GENDER 4|APPEARANCE_UPDATE_DNA
#define APPEARANCE_SKIN 8
#define APPEARANCE_HAIR 16
#define APPEARANCE_HAIR_COLOR 32
#define APPEARANCE_SECONDARY_HAIR_COLOR 64
#define APPEARANCE_FACIAL_HAIR 128
#define APPEARANCE_FACIAL_HAIR_COLOR 256
#define APPEARANCE_SECONDARY_FACIAL_HAIR_COLOR 512
#define APPEARANCE_EYE_COLOR 1024
#define APPEARANCE_ALL_HAIR APPEARANCE_HAIR|APPEARANCE_HAIR_COLOR|APPEARANCE_SECONDARY_HAIR_COLOR|APPEARANCE_FACIAL_HAIR|APPEARANCE_FACIAL_HAIR_COLOR|APPEARANCE_SECONDARY_FACIAL_HAIR_COLOR
#define APPEARANCE_HEAD_ACCESSORY 2048
#define APPEARANCE_MARKINGS 4096
#define APPEARANCE_BODY_ACCESSORY 8192
#define APPEARANCE_ALT_HEAD 16384
#define APPEARANCE_ALL_BODY APPEARANCE_ALL_HAIR|APPEARANCE_HEAD_ACCESSORY|APPEARANCE_MARKINGS|APPEARANCE_BODY_ACCESSORY|APPEARANCE_ALT_HEAD
#define APPEARANCE_ALL 32767

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

#define POCKET_STRIP_DELAY			40	//time taken (in deciseconds) to search somebody's pockets

#define DEFAULT_ITEM_STRIP_DELAY		40  //time taken (in deciseconds) to strip somebody
#define DEFAULT_ITEM_PUTON_DELAY		20  //time taken (in deciseconsd) to reverse-strip somebody

#define IGNORE_ACCESS -1

#define CHEM_MOB_SPAWN_INVALID   0
#define CHEM_MOB_SPAWN_HOSTILE   1
#define CHEM_MOB_SPAWN_FRIENDLY  2

#define TINT_IMPAIR 2			//Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3			//Threshold of tint level to obscure vision fully

#define isliving(A)		(istype((A), /mob/living))
#define iscarbon(A)		(istype((A), /mob/living/carbon))
#define ishuman(A)		(istype((A), /mob/living/carbon/human))
#define isbrain(A)		(istype((A), /mob/living/carbon/brain))
#define isalien(A)		(istype((A), /mob/living/carbon/alien))
#define isalienadult(A)	(istype((A), /mob/living/carbon/alien/humanoid))
#define islarva(A)		(istype((A), /mob/living/carbon/alien/larva))
#define isslime(A)		(istype((A), /mob/living/carbon/slime))

//Human sub-species
#define isabductor(A) (is_species(A, "Abductor"))

#define isanimal(A)		(istype((A), /mob/living/simple_animal))
#define iscorgi(A)		(istype((A), /mob/living/simple_animal/pet/corgi))
#define ismouse(A)		(istype((A), /mob/living/simple_animal/mouse))
#define isbot(A)		(istype((A), /mob/living/simple_animal/bot))
#define isswarmer(A)	(istype((A), /mob/living/simple_animal/hostile/swarmer))
#define isguardian(A)	(istype((A), /mob/living/simple_animal/hostile/guardian))



#define issilicon(A)	(istype((A), /mob/living/silicon))
#define isAI(A)			(istype((A), /mob/living/silicon/ai))
#define isrobot(A)		(istype((A), /mob/living/silicon/robot))
#define ispAI(A)		(istype((A), /mob/living/silicon/pai))

// For the tcomms monitor
#define ispathhuman(A)		(ispath(A, /mob/living/carbon/human))
#define ispathbrain(A)		(ispath(A, /mob/living/carbon/brain))
#define ispathslime(A)		(ispath(A, /mob/living/carbon/slime))
#define ispathbot(A)			(ispath(A, /mob/living/simple_animal/bot))
#define ispathsilicon(A)	(ispath(A, /mob/living/silicon))
#define ispathanimal(A)		(ispath(A, /mob/living/simple_animal))

#define isAutoAnnouncer(A)	(istype((A), /mob/living/automatedannouncer))

#define isAIEye(A)		(istype((A), /mob/camera/aiEye))
#define isovermind(A)	(istype((A), /mob/camera/blob))

#define isSpirit(A)		(istype((A), /mob/spirit))
#define ismask(A)		(istype((A), /mob/spirit/mask))

#define isobserver(A)	(istype((A), /mob/dead/observer))

#define isnewplayer(A)  (istype((A), /mob/new_player))

#define isorgan(A)		(istype((A), /obj/item/organ/external))
#define hasorgans(A)	(ishuman(A))

#define is_admin(user)	(check_rights(R_ADMIN, 0, (user)) != 0)
