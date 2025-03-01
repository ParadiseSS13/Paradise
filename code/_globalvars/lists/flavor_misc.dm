//Preferences stuff
	//Head accessory styles
GLOBAL_LIST_EMPTY(head_accessory_styles_list) //stores /datum/sprite_accessory/head_accessory indexed by name
	//Marking styles
GLOBAL_LIST_EMPTY(marking_styles_list) //stores /datum/sprite_accessory/body_markings indexed by name
	//Hairstyles
GLOBAL_LIST_EMPTY(hair_styles_public_list)			//stores /datum/sprite_accessory/hair indexed by name
GLOBAL_LIST_EMPTY(hair_styles_male_list)
GLOBAL_LIST_EMPTY(hair_styles_female_list)
GLOBAL_LIST_EMPTY(hair_styles_full_list) //fluff hair styles
GLOBAL_LIST_EMPTY(facial_hair_styles_list)	//stores /datum/sprite_accessory/facial_hair indexed by name
GLOBAL_LIST_EMPTY(facial_hair_styles_male_list)
GLOBAL_LIST_EMPTY(facial_hair_styles_female_list)
GLOBAL_LIST_EMPTY(hair_gradients_list) //stores /datum/sprite_accessory/hair_gradient indexed by name
	//Underwear
GLOBAL_LIST_EMPTY(underwear_list)		//stores /datum/sprite_accessory/underwear indexed by name
GLOBAL_LIST_EMPTY(underwear_m)	//stores only underwear name
GLOBAL_LIST_EMPTY(underwear_f)	//stores only underwear name
	//Undershirts
GLOBAL_LIST_EMPTY(undershirt_list) 	//stores /datum/sprite_accessory/undershirt indexed by name
GLOBAL_LIST_EMPTY(undershirt_m)	 //stores only undershirt name
GLOBAL_LIST_EMPTY(undershirt_f)	 //stores only undershirt name
	//Socks
GLOBAL_LIST_EMPTY(socks_list)		//stores /datum/sprite_accessory/socks indexed by name
GLOBAL_LIST_EMPTY(socks_m)	 //stores only socks name
GLOBAL_LIST_EMPTY(socks_f)	 //stores only socks name
	//Alt Heads
GLOBAL_LIST_EMPTY(alt_heads_list)	//stores /datum/sprite_accessory/alt_heads indexed by name

// Reference list for disposal sort junctions. Set the sort_type_txt variable on disposal sort junctions to
// the index of the sort department that you want. For example, adding "2" to sort_type_txt will reroute all packages
// tagged for the Cargo Bay. Multiple destinations can be added by separating them with ;, like "2;8" for Cargo Bay and Security.

//If you don't want to fuck up disposals, add to this list, and don't change the order.
//If you insist on changing the order, you'll have to change every sort junction to reflect the new order. --Pete

GLOBAL_LIST_INIT(TAGGERLOCATIONS, list("Disposals",
	"Cargo Bay", "QM Office", "Engineering", "CE Office",
	"Atmospherics", "HoS Office", "Security", "Medbay",
	"CMO Office", "Chemistry", "Research", "RD Office",
	"Robotics", "HoP Office", "Library", "Chapel", "Captain's Office",
	"Bar", "Kitchen", "Hydroponics", "Janitor Closet","Genetics", "Detective", "Morgue"))

GLOBAL_LIST_INIT(greek_letters, list("Alpha", "Beta", "Gamma", "Delta",
	"Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu",
	"Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi",
	"Chi", "Psi", "Omega"))

GLOBAL_LIST_INIT(phonetic_alphabet, list("Alpha", "Bravo", "Charlie",
	"Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet",
	"Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec",
	"Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray",
	"Yankee", "Zulu"))

//Backpacks
#define GBACKPACK "Grey Backpack"
#define GSATCHEL "Grey Satchel"
#define GDUFFLEBAG "Grey Dufflebag"
#define LSATCHEL "Leather Satchel"
#define DBACKPACK "Department Backpack"
#define DSATCHEL "Department Satchel"
#define DDUFFLEBAG "Department Dufflebag"
GLOBAL_LIST_INIT(backbaglist, list(DBACKPACK, DSATCHEL, DDUFFLEBAG, GBACKPACK, GSATCHEL, GDUFFLEBAG, LSATCHEL))

//Chooseable brain types for borgs
#define MMI_BORG "MMI"
#define ROBOBRAIN_BORG "Robobrain"
#define POSITRONIC_BORG "Positronic"
GLOBAL_LIST_INIT(borg_brain_choices, list(MMI_BORG, ROBOBRAIN_BORG, POSITRONIC_BORG))
GLOBAL_PROTECT(borg_brain_choices)

//Chooseable ringtones
//Due to database reasons, the name should be 16 characters long maximum
GLOBAL_LIST_INIT(pda_ringtone_choices, list("beep" = 'sound/machines/twobeep.ogg',
								"boop" = 'sound/machines/boop.ogg',
								"blup" = 'sound/misc/blup.ogg',
								"chime" = 'sound/machines/notif2.ogg',
								"slip" = 'sound/misc/slip.ogg',
								"honk" = 'sound/items/bikehorn.ogg',
								"SKREE" = 'sound/voice/shriek1.ogg',
								"holy" = 'sound/items/PDA/ambicha4-short.ogg',
								"boom" = 'sound/effects/explosionfar.ogg',
								"gavel" = 'sound/items/gavel.ogg',
								"xeno" = 'sound/voice/hiss1.ogg',
								"smoke" = 'sound/magic/smoke.ogg',
								"shatter" = 'sound/effects/pylon_shatter.ogg',
								"energy" = 'sound/weapons/egloves.ogg',
								"flare" = 'sound/goonstation/misc/matchstick_light.ogg',
								"interference" = 'sound/misc/interference.ogg',
								"zap" = 'sound/effects/eleczap.ogg',
								"disgusting" = 'sound/effects/blobattack.ogg',
								"hungry" = 'sound/weapons/bite.ogg'))
