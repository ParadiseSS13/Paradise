//Preferences stuff
	//Head accessory styles
GLOBAL_LIST_INIT(head_accessory_styles_list, list()) //stores /datum/sprite_accessory/head_accessory indexed by name
	//Marking styles
GLOBAL_LIST_INIT(marking_styles_list, list()) //stores /datum/sprite_accessory/body_markings indexed by name
	//Hairstyles
GLOBAL_LIST_INIT(hair_styles_public_list, list())			//stores /datum/sprite_accessory/hair indexed by name
GLOBAL_LIST_INIT(hair_styles_male_list, list())
GLOBAL_LIST_INIT(hair_styles_female_list, list())
GLOBAL_LIST_INIT(hair_styles_full_list, list()) //fluff hair styles
GLOBAL_LIST_INIT(facial_hair_styles_list, list())	//stores /datum/sprite_accessory/facial_hair indexed by name
GLOBAL_LIST_INIT(facial_hair_styles_male_list, list())
GLOBAL_LIST_INIT(facial_hair_styles_female_list, list())
GLOBAL_LIST_INIT(skin_styles_female_list, list())		//unused
	//Underwear
GLOBAL_LIST_INIT(underwear_list, list())		//stores /datum/sprite_accessory/underwear indexed by name
GLOBAL_LIST_INIT(underwear_m, list())	//stores only underwear name
GLOBAL_LIST_INIT(underwear_f, list())	//stores only underwear name
	//Undershirts
GLOBAL_LIST_INIT(undershirt_list, list()) 	//stores /datum/sprite_accessory/undershirt indexed by name
GLOBAL_LIST_INIT(undershirt_m, list())	 //stores only undershirt name
GLOBAL_LIST_INIT(undershirt_f, list())	 //stores only undershirt name
	//Socks
GLOBAL_LIST_INIT(socks_list, list())		//stores /datum/sprite_accessory/socks indexed by name
GLOBAL_LIST_INIT(socks_m, list())	 //stores only socks name
GLOBAL_LIST_INIT(socks_f, list())	 //stores only socks name
	//Alt Heads
GLOBAL_LIST_INIT(alt_heads_list, list())	//stores /datum/sprite_accessory/alt_heads indexed by name

GLOBAL_LIST_INIT(scarySounds, list('sound/weapons/thudswoosh.ogg','sound/weapons/taser.ogg','sound/weapons/armbomb.ogg','sound/voice/hiss1.ogg','sound/voice/hiss2.ogg', \
'sound/voice/hiss3.ogg','sound/voice/hiss4.ogg','sound/voice/hiss5.ogg','sound/voice/hiss6.ogg','sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg', \
'sound/items/welder.ogg','sound/items/welder2.ogg','sound/machines/airlock_open.ogg','sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg'))

// Reference list for disposal sort junctions. Set the sortType variable on disposal sort junctions to
// the index of the sort department that you want. For example, sortType set to 2 will reroute all packages
// tagged for the Cargo Bay.

//If you don't want to fuck up disposals, add to this list, and don't change the order.
//If you insist on changing the order, you'll have to change every sort junction to reflect the new order. --Pete

GLOBAL_LIST_INIT(TAGGERLOCATIONS, list("Disposals",
	"Cargo Bay", "QM Office", "Engineering", "CE Office",
	"Atmospherics", "HoS Office", "Security", "Medbay",
	"CMO Office", "Chemistry", "Research", "RD Office",
	"Robotics", "HoP Office", "Library", "Chapel", "Captain's Office",
	"Bar", "Kitchen", "Hydroponics", "Janitor Closet","Genetics","Brig Physician"))

GLOBAL_LIST_INIT(hit_appends, list("-OOF", "-ACK", "-UGH", "-HRNK", "-HURGH", "-GLORF"))

GLOBAL_LIST_INIT(greek_letters, list("Alpha", "Beta", "Gamma", "Delta",
	"Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu",
	"Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi",
	"Chi", "Psi", "Omega"))

GLOBAL_LIST_INIT(phonetic_alphabet, list("Alpha", "Bravo", "Charlie",
	"Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet",
	"Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec",
	"Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray",
	"Yankee", "Zulu"))

GLOBAL_LIST_INIT(numbers_as_words, list("One", "Two", "Three", "Four",
	"Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve",
	"Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen",
	"Eighteen", "Nineteen"))

	//Backpacks
#define GBACKPACK "Grey Backpack"
#define GSATCHEL "Grey Satchel"
#define GDUFFLEBAG "Grey Dufflebag"
#define LSATCHEL "Leather Satchel"
#define DBACKPACK "Department Backpack"
#define DSATCHEL "Department Satchel"
#define DDUFFLEBAG "Department Dufflebag"
GLOBAL_LIST_INIT(backbaglist, list(DBACKPACK, DSATCHEL, DDUFFLEBAG, GBACKPACK, GSATCHEL, GDUFFLEBAG, LSATCHEL))
