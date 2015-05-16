//Preferences stuff
	//Hairstyles
var/global/list/hair_styles_list = list()			//stores /datum/sprite_accessory/hair indexed by name
var/global/list/hair_styles_male_list = list()
var/global/list/hair_styles_female_list = list()
var/global/list/facial_hair_styles_list = list()	//stores /datum/sprite_accessory/facial_hair indexed by name
var/global/list/facial_hair_styles_male_list = list()
var/global/list/facial_hair_styles_female_list = list()
var/global/list/skin_styles_female_list = list()		//unused
	//Underwear
var/global/list/underwear_m = list("White", "Grey", "Green", "Blue", "Black", "Mankini", "None")
var/global/list/underwear_f = list("Red", "White", "Yellow", "Blue", "Black", "Thong", "None")
var/global/list/underwear_list = underwear_m + underwear_f
	//undershirt
var/global/list/undershirt_t = list("White Shirt", "White Tank top", "Black shirt", "Black Tank top", "Grey Shirt", "Grey tank top", "Lover Shirt", "Blue Ian Shirt", "UK Shirt","I Love NT Shirt", "Peace Shirt", "Band Shirt", "PogoMan Shirt", "Matroska Shirt", "White Short-sleeved shirt", "Purple Short-sleeved shirt", "Blue Short-sleeved shirt", "Green Short-sleeved shirt", "Black Short-Sleeved shirt", "Blue T-Shirt", "Red T-Shirt", "Yellow T-Shirt", "Green T-Shirt", "Blue Polo Shirt", "Red Polo Shirt", "White Polo Shirt", "Gray-Yellow Polo Shirt", "Green Sports Shirt", "Red Sports Shirt", "Blue Sports Shirt", "SS13 Shirt", "Fire Tank Top", "Question Shirt", "Skull Shirt", "Commie Shirt", "Nanotrasen Shirt", "Striped Shirt", "Blue Shirt", "Red Shirt", "Green Shirt", "Meat Shirt", "Tie-Dye Shirt", "Red Jersey", "Blue Jersey", "None")
var/global/list/undershirt_list = undershirt_t
	//Backpacks
var/global/list/backbaglist = list("Nothing", "Backpack", "Satchel", "Satchel Alt")

var/static/list/scarySounds = list('sound/weapons/thudswoosh.ogg','sound/weapons/Taser.ogg','sound/weapons/armbomb.ogg','sound/voice/hiss1.ogg','sound/voice/hiss2.ogg', \
'sound/voice/hiss3.ogg','sound/voice/hiss4.ogg','sound/voice/hiss5.ogg','sound/voice/hiss6.ogg','sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg', \
'sound/items/Welder.ogg','sound/items/Welder2.ogg','sound/machines/airlock.ogg','sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')

// Reference list for disposal sort junctions. Set the sortType variable on disposal sort junctions to
// the index of the sort department that you want. For example, sortType set to 2 will reroute all packages
// tagged for the Cargo Bay.

//If you don't want to fuck up disposals, add to this list, and don't change the order.
//If you insist on changing the order, you'll have to change every sort junction to reflect the new order. --Pete

var/list/TAGGERLOCATIONS = list("Disposals",
	"Cargo Bay", "QM Office", "Engineering", "CE Office",
	"Atmospherics", "HoS Office", "Security", "Medbay",
	"CMO Office", "Chemistry", "Research", "RD Office",
	"Robotics", "HoP Office", "Library", "Chapel", "Captain's Office",
	"Bar", "Kitchen", "Hydroponics", "Janitor Closet","Genetics")

var/list/hit_appends = list("-OOF", "-ACK", "-UGH", "-HRNK", "-HURGH", "-GLORF")