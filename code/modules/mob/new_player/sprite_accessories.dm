/*

	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna2.dm, so you do not
	have to define any UI values for sprite accessories manually for hair and facial
	hair. Just add in new hair types and the game will naturally adapt.

	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/

/proc/init_sprite_accessory_subtypes(var/prototype, var/list/L, var/list/male, var/list/female)
	if(!istype(L))	L = list()
	if(!istype(male))	male = list()
	if(!istype(female))	female = list()

	for(var/path in subtypesof(prototype))
		var/datum/sprite_accessory/D = new path()

		L[D.name] = D

		switch(D.gender)
			if(MALE)	male[D.name] = D
			if(FEMALE)	female[D.name] = D
			else
				male[D.name] = D
				female[D.name] = D
	return L

/datum/sprite_accessory
	var/icon			//the icon file the accessory is located in
	var/icon_state		//the icon_state of the accessory
	var/name			//the preview name of the accessory
	var/gender = NEUTER	//Determines if the accessory will be skipped or included in random hair generations

	// Restrict some styles to specific species
	var/list/species_allowed = list("Human", "Slime People")
	var/models_allowed = list() //Specifies which, if any, hairstyles can be accessed by which prosthetics. Should equal the manufacturing company name in robolimbs.dm.
	var/marking_location //Specifies which bodypart a body marking is located on.

	// Whether or not the accessory can be affected by colouration
	var/do_colouration = 1


/*
////////////////////////////
/  =--------------------=  /
/  == Hair Definitions ==  /
/  =--------------------=  /
////////////////////////////
*/

/datum/sprite_accessory/hair
	icon = 'icons/mob/human_face.dmi'	  // default icon for all hairs

	bald
		name = "Bald"
		icon_state = "bald"
		gender = MALE
		species_allowed = list("Human", "Unathi", "Vox", "Diona", "Kidan", "Grey", "Plasmaman", "Skeleton")

	short
		name = "Short Hair"	  // try to capatilize the names please~
		icon_state = "hair_a" // you do not need to define _s or _l sub-states, game automatically does this for you

	cut
		name = "Cut Hair"
		icon_state = "hair_c"

	long
		name = "Shoulder-length Hair"
		icon_state = "hair_b"

	longalt
		name = "Shoulder-length Hair Alt"
		icon_state = "hair_longfringe"

	/*longish
		name = "Longer Hair"
		icon_state = "hair_b2"*/

	longer
		name = "Long Hair"
		icon_state = "hair_vlong"

	longeralt
		name = "Long Hair Alt"
		icon_state = "hair_vlongfringe"

	longest
		name = "Very Long Hair"
		icon_state = "hair_longest"

	longfringe
		name = "Long Fringe"
		icon_state = "hair_longfringe"

	longestalt
		name = "Longer Fringe"
		icon_state = "hair_vlongfringe"

	halfbang
		name = "Half-banged Hair"
		icon_state = "hair_halfbang"

	halfbangalt
		name = "Half-banged Hair Alt"
		icon_state = "hair_halfbang_alt"

	ponytail1
		name = "Ponytail male"
		icon_state = "hair_ponytailm"
		gender = MALE

	ponytail2
		name = "Ponytail female"
		icon_state = "hair_ponytailf"
		gender = FEMALE

	ponytail3
		name = "Ponytail alt"
		icon_state = "hair_ponytail3"

	sideponytail
		name = "Side Ponytail"
		icon_state = "hair_stail"
		gender = FEMALE

	highponytail
		name = "High Ponytail"
		icon_state = "hair_highponytail"
		gender = FEMALE


	wisp
		name = "Wisp"
		icon_state = "hair_wisp"
		gender = FEMALE

	parted
		name = "Parted"
		icon_state = "hair_parted"

	pompadour
		name = "Pompadour"
		icon_state = "hair_pompadour"
		gender = MALE
		species_allowed = list("Human", "Unathi")

	quiff
		name = "Quiff"
		icon_state = "hair_quiff"
		gender = MALE

	bedhead
		name = "Bedhead"
		icon_state = "hair_bedhead"

	bedhead2
		name = "Bedhead 2"
		icon_state = "hair_bedheadv2"

	bedhead3
		name = "Bedhead 3"
		icon_state = "hair_bedheadv3"

	beehive
		name = "Beehive"
		icon_state = "hair_beehive"
		gender = FEMALE
		species_allowed = list("Human", "Unathi")

	bobcurl
		name = "Bobcurl"
		icon_state = "hair_bobcurl"
		gender = FEMALE
		species_allowed = list("Human", "Unathi")

	bob
		name = "Bob"
		icon_state = "hair_bobcut"
		gender = FEMALE
		species_allowed = list("Human", "Unathi")

	bowl
		name = "Bowl"
		icon_state = "hair_bowlcut"
		gender = MALE

	braid2
		name = "Long Braid"
		icon_state = "hair_hbraid"
		gender = FEMALE

	buzz
		name = "Buzzcut"
		icon_state = "hair_buzzcut"
		gender = MALE
		species_allowed = list("Human", "Unathi")

	crew
		name = "Crewcut"
		icon_state = "hair_crewcut"
		gender = MALE

	combover
		name = "Combover"
		icon_state = "hair_combover"
		gender = MALE

	devillock
		name = "Devil Lock"
		icon_state = "hair_devilock"

	dreadlocks
		name = "Dreadlocks"
		icon_state = "hair_dreads"

	curls
		name = "Curls"
		icon_state = "hair_curls"

	afro
		name = "Afro"
		icon_state = "hair_afro"

	afro2
		name = "Afro 2"
		icon_state = "hair_afro2"

	afro_large
		name = "Big Afro"
		icon_state = "hair_bigafro"
		gender = MALE

	sargeant
		name = "Flat Top"
		icon_state = "hair_sargeant"
		gender = MALE

	emo
		name = "Emo"
		icon_state = "hair_emo"

	fag
		name = "Flow Hair"
		icon_state = "hair_f"

	feather
		name = "Feather"
		icon_state = "hair_feather"

	hitop
		name = "Hitop"
		icon_state = "hair_hitop"
		gender = MALE

	mohawk
		name = "Mohawk"
		icon_state = "hair_d"
		species_allowed = list("Human", "Unathi")

	jensen
		name = "Adam Jensen Hair"
		icon_state = "hair_jensen"
		gender = MALE

	cia
		name = "CIA"
		icon_state = "hair_cia"
		gender = MALE

	mulder
		name = "Mulder"
		icon_state = "hair_mulder"
		gender = MALE

	gelled
		name = "Gelled Back"
		icon_state = "hair_gelled"
		gender = FEMALE

	gentle
		name = "Gentle"
		icon_state = "hair_gentle"
		gender = FEMALE

	spiky
		name = "Spiky"
		icon_state = "hair_spikey"
		species_allowed = list("Human", "Unathi")

	kusangi
		name = "Kusanagi Hair"
		icon_state = "hair_kusanagi"

	kagami
		name = "Pigtails"
		icon_state = "hair_kagami"
		gender = FEMALE

	himecut
		name = "Hime Cut"
		icon_state = "hair_himecut"
		gender = FEMALE

	braid
		name = "Floorlength Braid"
		icon_state = "hair_braid"
		gender = FEMALE

	odango
		name = "Odango"
		icon_state = "hair_odango"
		gender = FEMALE

	ombre
		name = "Ombre"
		icon_state = "hair_ombre"
		gender = FEMALE

	updo
		name = "Updo"
		icon_state = "hair_updo"
		gender = FEMALE

	skinhead
		name = "Skinhead"
		icon_state = "hair_skinhead"

	balding
		name = "Balding Hair"
		icon_state = "hair_e"
		gender = MALE // turnoff!

	longemo
		name = "Long Emo"
		icon_state = "hair_emolong"
		gender = FEMALE

//////////////////////////////
//////START VG HAIRSTYLES/////
//////////////////////////////
	birdnest
		name = "Bird Nest"
		icon_state = "hair_birdnest"

	unkept
		name = "Unkempt"
		icon_state = "hair_unkept"

	duelist
		name = "Duelist"
		icon_state = "hair_duelist"
		gender = MALE

	modern
		name = "Modern"
		icon_state = "hair_modern"
		gender = FEMALE

	unshavenmohawk
		name = "Unshaven Mohawk"
		icon_state = "hair_unshavenmohawk"
		gender = MALE

	drills
		name = "Twincurls"
		icon_state = "hair_twincurl"
		gender = FEMALE

	minidrills
		name = "Twincurls 2"
		icon_state = "hair_twincurl2"
		gender = FEMALE
//////////////////////////////
//////END VG HAIRSTYLES///////
//////////////////////////////


	ipc_screen_pink
		name = "Pink IPC Screen"
		icon_state = "ipc_pink"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_red
		name = "Red IPC Screen"
		icon_state = "ipc_red"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_green
		name = "Green IPC Screen"
		icon_state = "ipc_green"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_blue
		name = "Blue IPC Screen"
		icon_state = "ipc_blue"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_breakout
		name = "Breakout IPC Screen"
		icon_state = "ipc_breakout"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_eight
		name = "Eight IPC Screen"
		icon_state = "ipc_eight"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_rainbow
		name = "Rainbow IPC Screen"
		icon_state = "ipc_rainbow"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_goggles
		name = "Goggles IPC Screen"
		icon_state = "ipc_goggles"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_heart
		name = "Heart IPC Screen"
		icon_state = "ipc_heart"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_monoeye
		name = "Monoeye IPC Screen"
		icon_state = "ipc_monoeye"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_nature
		name = "Nature IPC Screen"
		icon_state = "ipc_nature"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_orange
		name = "Orange IPC Screen"
		icon_state = "ipc_orange"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_purple
		name = "Purple IPC Screen"
		icon_state = "ipc_purple"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_shower
		name = "Shower IPC Screen"
		icon_state = "ipc_shower"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_static
		name = "Static IPC Screen"
		icon_state = "ipc_static"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_yellow
		name = "Yellow IPC Screen"
		icon_state = "ipc_yellow"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_scrolling
		name = "Scanline IPC Screen"
		icon_state = "ipc_scroll"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_console
		name = "Console IPC Screen"
		icon_state = "ipc_console"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_rgb
		name = "RGB IPC Screen"
		icon_state = "ipc_rgb"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	ipc_screen_glider
		name = "Glider IPC Screen"
		icon_state = "ipc_gol_glider"
		species_allowed = list("Machine")
		models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.")

	hesphiastos_alt_off
		name = "Dark Hesphiastos Screen"
		icon_state = "hesphiastos_alt_off"
		species_allowed = list("Machine")
		models_allowed = list("Hesphiastos Industries alt.")

	hesphiastos_alt_pink
		name = "Pink Hesphiastos Screen"
		icon_state = "hesphiastos_alt_pink"
		species_allowed = list("Machine")
		models_allowed = list("Hesphiastos Industries alt.")

	hesphiastos_alt_orange
		name = "Orange Hesphiastos Screen"
		icon_state = "hesphiastos_alt_orange"
		species_allowed = list("Machine")
		models_allowed = list("Hesphiastos Industries alt.")

	hesphiastos_alt_goggle
		name = "Goggles Hesphiastos Screen"
		icon_state = "hesphiastos_alt_goggles"
		species_allowed = list("Machine")
		models_allowed = list("Hesphiastos Industries alt.")

	hesphiastos_alt_scroll
		name = "Scrolling Hesphiastos Screen"
		icon_state = "hesphiastos_alt_scroll"
		species_allowed = list("Machine")
		models_allowed = list("Hesphiastos Industries alt.")

	hesphiastos_alt_rgb
		name = "RGB Hesphiastos Screen"
		icon_state = "hesphiastos_alt_rgb"
		species_allowed = list("Machine")
		models_allowed = list("Hesphiastos Industries alt.")

	hesphiastos_alt_rainbow
		name = "Rainbow Hesphiastos Screen"
		icon_state = "hesphiastos_alt_rainbow"
		species_allowed = list("Machine")
		models_allowed = list("Hesphiastos Industries alt.")


/*
///////////////////////////////////
/  =---------------------------=  /
/  == Facial Hair Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/facial_hair

	icon = 'icons/mob/human_face.dmi'
	gender = MALE // barf (unless you're a dorf, dorfs dig chix /w beards :P)

	shaved
		name = "Shaved"
		icon_state = "bald"
		gender = NEUTER
		species_allowed = list("Human", "Unathi", "Tajaran", "Skrell", "Vox", "Diona", "Kidan", "Greys", "Vulpkanin", "Slime People")

	watson
		name = "Watson Mustache"
		icon_state = "facial_watson"

	hogan
		name = "Hulk Hogan Mustache"
		icon_state = "facial_hogan" //-Neek

	vandyke
		name = "Van Dyke Mustache"
		icon_state = "facial_vandyke"

	chaplin
		name = "Square Mustache"
		icon_state = "facial_chaplin"

	selleck
		name = "Selleck Mustache"
		icon_state = "facial_selleck"

	neckbeard
		name = "Neckbeard"
		icon_state = "facial_neckbeard"

	fullbeard
		name = "Full Beard"
		icon_state = "facial_fullbeard"

	longbeard
		name = "Long Beard"
		icon_state = "facial_longbeard"

	vlongbeard
		name = "Very Long Beard"
		icon_state = "facial_wise"

	elvis
		name = "Elvis Sideburns"
		icon_state = "facial_elvis"
		species_allowed = list("Human","Unathi")

	abe
		name = "Abraham Lincoln Beard"
		icon_state = "facial_abe"

	chinstrap
		name = "Chinstrap"
		icon_state = "facial_chin"

	hip
		name = "Hipster Beard"
		icon_state = "facial_hip"

	gt
		name = "Goatee"
		icon_state = "facial_gt"

	jensen
		name = "Adam Jensen Beard"
		icon_state = "facial_jensen"

	dwarf
		name = "Dwarf Beard"
		icon_state = "facial_dwarf"

//////////////////////////////
//////START VG HAIRSTYLES/////
//////////////////////////////
	britstache
		name = "Brit Stache"
		icon_state = "facial_britstache"

	martialartist
		name = "Martial Artist"
		icon_state = "facial_martialartist"

	moonshiner
		name = "Moonshiner"
		icon_state = "facial_moonshiner"

	tribeard
		name = "Tri-beard"
		icon_state = "facial_tribeard"

	unshaven
		name = "Unshaven"
		icon_state = "facial_unshaven"
//////////////////////////////
//////END VG HAIRSTYLES///////
//////////////////////////////


/*
///////////////////////////////////
/  =---------------------------=  /
/  == Alien Style Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/hair

	una_horns
		name = "Unathi Horns"
		icon_state = "soghun_horns"
		species_allowed = list("Unathi")

	skr_tentacle_m
		name = "Skrell Male Tentacles"
		icon_state = "skrell_hair_m"
		species_allowed = list("Skrell")
		gender = MALE

	skr_tentacle_f
		name = "Skrell Female Tentacles"
		icon_state = "skrell_hair_f"
		species_allowed = list("Skrell")
		gender = FEMALE

	skr_gold_m
		name = "Gold plated Skrell Male Tentacles"
		icon_state = "skrell_goldhair_m"
		species_allowed = list("Skrell")
		gender = MALE

	skr_gold_f
		name = "Gold chained Skrell Female Tentacles"
		icon_state = "skrell_goldhair_f"
		species_allowed = list("Skrell")
		gender = FEMALE

	skr_clothtentacle_m
		name = "Cloth draped Skrell Male Tentacles"
		icon_state = "skrell_clothhair_m"
		species_allowed = list("Skrell")
		gender = MALE

	skr_clothtentacle_f
		name = "Cloth draped Skrell Female Tentacles"
		icon_state = "skrell_clothhair_f"
		species_allowed = list("Skrell")
		gender = FEMALE

	taj_ears
		name = "Tajaran Ears"
		icon_state = "ears_plain"
		species_allowed = list("Tajaran")

	taj_ears_clean
		name = "Tajara Clean"
		icon_state = "hair_clean"
		species_allowed = list("Tajaran")

	taj_ears_bangs
		name = "Tajara Bangs"
		icon_state = "hair_bangs"
		species_allowed = list("Tajaran")

	taj_ears_braid
		name = "Tajara Braid"
		icon_state = "hair_tbraid"
		species_allowed = list("Tajaran")

	taj_ears_shaggy
		name = "Tajara Shaggy"
		icon_state = "hair_shaggy"
		species_allowed = list("Tajaran")

	taj_ears_mohawk
		name = "Tajaran Mohawk"
		icon_state = "hair_mohawk"
		species_allowed = list("Tajaran")

	taj_ears_plait
		name = "Tajara Plait"
		icon_state = "hair_plait"
		species_allowed = list("Tajaran")

	taj_ears_straight
		name = "Tajara Straight"
		icon_state = "hair_straight"
		species_allowed = list("Tajaran")

	taj_ears_long
		name = "Tajara Long"
		icon_state = "hair_long"
		species_allowed = list("Tajaran")

	taj_ears_rattail
		name = "Tajara Rat Tail"
		icon_state = "hair_rattail"
		species_allowed = list("Tajaran")

	taj_ears_spiky
		name = "Tajara Spiky"
		icon_state = "hair_tajspiky"
		species_allowed = list("Tajaran")

	taj_ears_messy
		name = "Tajara Messy"
		icon_state = "hair_messy"
		species_allowed = list("Tajaran")

//Vulpkanin

	vulp_hair_none
		name = "None"
		icon_state = "bald"
		species_allowed = list("Vulpkanin")

	vulp_hair_kajam
		name = "Kajam"
		icon_state = "kajam"
		species_allowed = list("Vulpkanin")

	vulp_hair_keid
		name = "Keid"
		icon_state = "keid"
		species_allowed = list("Vulpkanin")

	vulp_hair_adhara
		name = "Adhara"
		icon_state = "adhara"
		species_allowed = list("Vulpkanin")

	vulp_hair_kleeia
		name = "Kleeia"
		icon_state = "kleeia"
		species_allowed = list("Vulpkanin")

	vulp_hair_mizar
		name = "Mizar"
		icon_state = "mizar"
		species_allowed = list("Vulpkanin")

	vulp_hair_apollo
		name = "Apollo"
		icon_state = "apollo"
		species_allowed = list("Vulpkanin")

	vulp_hair_belle
		name = "Belle"
		icon_state = "belle"
		species_allowed = list("Vulpkanin")

	vulp_hair_bun
		name = "Bun"
		icon_state = "bun"
		species_allowed = list("Vulpkanin")

	vulp_hair_jagged
		name = "Jagged"
		icon_state = "jagged"
		species_allowed = list("Vulpkanin")

	vulp_hair_curl
		name = "Curl"
		icon_state = "curl"
		species_allowed = list("Vulpkanin")

	vulp_hair_hawk
		name = "Hawk"
		icon_state = "hawk"
		species_allowed = list("Vulpkanin")

	vulp_hair_anita
		name = "Anita"
		icon_state = "anita"
		species_allowed = list("Vulpkanin")

	vulp_hair_short
		name = "Short"
		icon_state = "short"
		species_allowed = list("Vulpkanin")

	vulp_hair_spike
		name = "Spike"
		icon_state = "spike"
		species_allowed = list("Vulpkanin")

//Vox

	vox_quills_short
		name = "Short Vox Quills"
		icon_state = "vox_shortquills"
		species_allowed = list("Vox")

	vox_crestedquills
		name = "Crested Vox Quills"
		icon_state = "vox_crestedquills"
		species_allowed = list("Vox")

	vox_tielquills
		name = "Vox Tiel Quills"
		icon_state = "vox_tielquills"
		species_allowed = list("Vox")

	vox_emperorquills
		name = "Vox Emperor Quills"
		icon_state = "vox_emperorquills"
		species_allowed = list("Vox")

	vox_keelquills
		name = "Vox Keel Quills"
		icon_state = "vox_keelquills"
		species_allowed = list("Vox")

	vox_keetquills
		name = "Vox Keet Quills"
		icon_state = "vox_keetquills"
		species_allowed = list("Vox")

	vox_quills_kingly
		name = "Kingly Vox Quills"
		icon_state = "vox_kingly"
		species_allowed = list("Vox")

	vox_quills_fluff
		name = "Fluffy Vox Quills"
		icon_state = "vox_afro"
		species_allowed = list("Vox")

	vox_quills_mohawk
		name = "Vox Quill Mohawk"
		icon_state = "vox_mohawk"
		species_allowed = list("Vox")

	vox_quills_long
		name = "Long Vox Quills"
		icon_state = "vox_yasu"
		species_allowed = list("Vox")

	vox_horns
		name = "Vox Spikes"
		icon_state = "vox_horns"
		species_allowed = list("Vox")

	vox_nights
		name = "Vox Pigtails"
		icon_state = "vox_nights"
		species_allowed = list("Vox")

	vox_razor
		name = "Vox Razorback"
		icon_state = "vox_razor"
		species_allowed = list("Vox")

// Apollo-specific

	//Wryn antennae

	wry_antennae_default
		name = "Antennae"
		icon_state = "wryn_antennae"
		species_allowed = list("Wryn")

	//Nucleation "hairstyles"

	nuc_crystals
		name = "Nucleation Crystals"
		icon_state = "nuc_crystal"
		species_allowed = list("Nucleation")

	nuc_betaburns
		name = "Nucleation Beta Burns"
		icon_state = "nuc_betaburns"
		species_allowed = list("Nucleation")

	nuc_fallout
		name = "Nucleation Fallout"
		icon_state = "nuc_fallout"
		species_allowed = list("Nucleation")

	nuc_frission
		name = "Nucleation Frission"
		icon_state = "nuc_frission"
		species_allowed = list("Nucleation")

	nuc_radical
		name = "Nucleation Free Radical"
		icon_state = "nuc_radical"
		species_allowed = list("Nucleation")

	nuc_gammaray
		name = "Nucleation Gamma Ray"
		icon_state = "nuc_gammaray"
		species_allowed = list("Nucleation")

	nuc_neutron
		name = "Nucleation Neutron Bomb"
		icon_state = "nuc_neutron"
		species_allowed = list("Nucleation")

/datum/sprite_accessory/facial_hair

//Tajara

	taj_sideburns
		name = "Tajara Sideburns"
		icon_state = "facial_sideburns"
		species_allowed = list("Tajaran")

	taj_mutton
		name = "Tajara Mutton"
		icon_state = "facial_mutton"
		species_allowed = list("Tajaran")

	taj_pencilstache
		name = "Tajara Pencilstache"
		icon_state = "facial_pencilstache"
		species_allowed = list("Tajaran")

	taj_moustache
		name = "Tajara Moustache"
		icon_state = "facial_moustache"
		species_allowed = list("Tajaran")

	taj_goatee
		name = "Tajara Goatee"
		icon_state = "facial_goatee"
		species_allowed = list("Tajaran")

	taj_smallstache
		name = "Tajara Smallstache"
		icon_state = "facial_smallstache"
		species_allowed = list("Tajaran")

//Vox

	vox_colonel
		name = "Vox Colonel Beard"
		icon_state = "vox_colonel"
		species_allowed = list("Vox")

	vox_long
		name = "Long Mustache"
		icon_state = "vox_fu"
		species_allowed = list("Vox")

	vox_neck
		name = "Neck Quills"
		icon_state = "vox_neck"
		species_allowed = list("Vox")

	vox_beard
		name = "Vox Quill Beard"
		icon_state = "vox_beard"
		species_allowed = list("Vox")

//Vulpkanin

	vulp_blaze
		name = "Blaze"
		icon_state = "vulp_facial_blaze"
		species_allowed = list("Vulpkanin")
		gender = NEUTER

	vulp_vulpine
		name = "Vulpine"
		icon_state = "vulp_facial_vulpine"
		species_allowed = list("Vulpkanin")
		gender = NEUTER

	vulp_vulpine_fluff
		name = "Vulpine and Earfluff"
		icon_state = "vulp_facial_vulpine_fluff"
		species_allowed = list("Vulpkanin")
		gender = NEUTER

	vulp_mask
		name = "Mask"
		icon_state = "vulp_facial_mask"
		species_allowed = list("Vulpkanin")
		gender = NEUTER

	vulp_patch
		name = "Patch"
		icon_state = "vulp_facial_patch"
		species_allowed = list("Vulpkanin")
		gender = NEUTER

	vulp_ruff
		name = "Ruff"
		icon_state = "vulp_facial_ruff"
		species_allowed = list("Vulpkanin")
		gender = NEUTER

	vulp_kita
		name = "Kita"
		icon_state = "vulp_facial_kita"
		species_allowed = list("Vulpkanin")
		gender = NEUTER

	vulp_swift
		name = "Swift"
		icon_state = "vulp_facial_swift"
		species_allowed = list("Vulpkanin")
		gender = NEUTER

//Unathi

	una_spines_long
		name = "Long Spines"
		icon_state = "soghun_longspines"
		species_allowed = list("Unathi")
		gender = NEUTER

	una_spines_short
		name = "Short Spines"
		icon_state = "soghun_shortspines"
		species_allowed = list("Unathi")
		gender = NEUTER

	una_frills_long
		name = "Long Frills"
		icon_state = "soghun_longfrills"
		species_allowed = list("Unathi")
		gender = NEUTER

	una_frills_short
		name = "Short Frills"
		icon_state = "soghun_shortfrills"
		species_allowed = list("Unathi")
		gender = NEUTER

	una_frills_webbed_long
		name = "Long Webbed Frills"
		icon_state = "soghun_longfrills_webbed"
		species_allowed = list("Unathi")
		gender = NEUTER

	una_frills_webbed_short
		name = "Short Webbed Frills"
		icon_state = "soghun_shortfrills_webbed"
		species_allowed = list("Unathi")
		gender = NEUTER

	una_frills_webbed_aquatic
		name = "Aquatic Frills"
		icon_state = "soghun_aquaticfrills_webbed"
		species_allowed = list("Unathi")
		gender = NEUTER


//skin styles - WIP
//going to have to re-integrate this with surgery
//let the icon_state hold an icon preview for now
/datum/sprite_accessory/skin
	icon = 'icons/mob/human_races/r_human.dmi'

	human
		name = "Default human skin"
		icon_state = "default"
		species_allowed = list("Human")

	human_tatt01
		name = "Tatt01 human skin"
		icon_state = "tatt1"
		species_allowed = list("Human")

	tajaran
		name = "Default tajaran skin"
		icon_state = "default"
		icon = 'icons/mob/human_races/r_tajaran.dmi'
		species_allowed = list("Tajaran")

	vulpkanin
		name = "Default Vulpkanin skin"
		icon_state = "default"
		icon = 'icons/mob/human_races/r_vulpkanin.dmi'
		species_allowed = list("Vulpkanin")

	unathi
		name = "Default Unathi skin"
		icon_state = "default"
		icon = 'icons/mob/human_races/r_lizard.dmi'
		species_allowed = list("Unathi")

	skrell
		name = "Default skrell skin"
		icon_state = "default"
		icon = 'icons/mob/human_races/r_skrell.dmi'
		species_allowed = list("Skrell")

///////////////////////////
// Underwear Definitions //
///////////////////////////
/datum/sprite_accessory/underwear
	icon = 'icons/mob/underwear.dmi'

	species_allowed = list("Human", "Unathi", "Vox", "Diona", "Vulpkanin", "Kidan", "Grey", "Plasmaman", "Skeleton", "Machine")

	nude
		name = "Nude"
		icon_state = null
		gender = NEUTER

	male_white
		name = "Mens White"
		icon_state = "male_white"
		gender = MALE

	male_grey
		name = "Mens Grey"
		icon_state = "male_grey"
		gender = MALE

	male_grey
		name = "Mens Grey Alt"
		icon_state = "male_greyalt"
		gender = MALE

	male_green
		name = "Mens Green"
		icon_state = "male_green"
		gender = MALE

	male_blue
		name = "Mens Blue"
		icon_state = "male_blue"
		gender = MALE

	male_red
		name = "Mens Red"
		icon_state = "male_red"
		gender = MALE

	male_black
		name = "Mens Black"
		icon_state = "male_black"
		gender = MALE

	male_black_alt
		name = "Mens Black Alt"
		icon_state = "male_blackalt"
		gender = MALE

	male_striped
		name = "Mens Striped"
		icon_state = "male_stripe"
		gender = MALE

	male_heart
		name = "Mens Hearts"
		icon_state = "male_hearts"
		gender = MALE

	male_kinky
		name = "Mens Kinky"
		icon_state = "male_kinky"
		gender = MALE

	male_mankini
		name = "Mankini"
		icon_state = "male_mankini"
		gender = MALE

	female_red
		name = "Ladies Red"
		icon_state = "female_red"
		gender = FEMALE

	female_green
		name = "Ladies Green"
		icon_state = "female_green"
		gender = FEMALE

	female_white
		name = "Ladies White"
		icon_state = "female_white"
		gender = FEMALE

	female_whiter
		name = "Ladies Whiter"
		icon_state = "female_whiter"
		gender = FEMALE

	female_whitealt
		name = "Ladies White Alt"
		icon_state = "female_whitealt"
		gender = FEMALE

	female_yellow
		name = "Ladies Yellow"
		icon_state = "female_yellow"
		gender = FEMALE

	female_blue
		name = "Ladies Blue"
		icon_state = "female_blue"
		gender = FEMALE

	female_babyblue
		name = "Ladies Baby Blue"
		icon_state = "female_babyblue"
		gender = FEMALE

	female_black
		name = "Ladies Black"
		icon_state = "female_black"
		gender = FEMALE

	female_blacker
		name = "Ladies Blacker"
		icon_state = "female_blacker"
		gender = FEMALE

	female_blackalt
		name = "Ladies Black Alt"
		icon_state = "female_blackalt"
		gender = FEMALE

	female_kinky
		name = "Ladies Kinky"
		icon_state = "female_kinky"
		gender = FEMALE

	female_babydoll
		name = "Ladies Full Grey"
		icon_state = "female_babydoll"
		gender = FEMALE

	female_pink
		name = "Ladies Pink"
		icon_state = "female_pink"
		gender = FEMALE

	female_thong
		name = "Ladies Thong"
		icon_state = "female_thong"
		gender = FEMALE

////////////////////////////
// Undershirt Definitions //
////////////////////////////
/datum/sprite_accessory/undershirt
	icon = 'icons/mob/underwear.dmi'

	species_allowed = list("Human", "Unathi", "Vox", "Diona", "Vulpkanin", "Kidan", "Grey", "Plasmaman", "Skeleton", "Machine")

/datum/sprite_accessory/undershirt/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

//plain color shirts
/datum/sprite_accessory/undershirt/shirt_white
	name = "White Shirt"
	icon_state = "shirt_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_black
	name = "Black Shirt"
	icon_state = "shirt_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_blacker
	name = "Blacker Shirt"
	icon_state = "shirt_blacker"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_grey
	name = "Grey Shirt"
	icon_state = "shirt_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_red
	name = "Red Shirt"
	icon_state = "shirt_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_blue
	name = "Blue Shirt"
	icon_state = "shirt_blue"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_yellow
	name = "Yellow Shirt"
	icon_state = "shirt_yellow"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_green
	name = "Green Shirt"
	icon_state = "shirt_green"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_darkblue
	name = "Dark Blue Shirt"
	icon_state = "shirt_darkblue"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_darkred
	name = "Dark Red Shirt"
	icon_state = "shirt_darkred"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_darkgreen
	name = "Dark Green Shirt"
	icon_state = "shirt_darkgreen"
	gender = NEUTER
//end plain color shirts

/datum/sprite_accessory/undershirt/shirt_heart
	name = "Heart Shirt"
	icon_state = "shirt_heart"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_corgi
	name = "Corgi Shirt"
	icon_state = "shirt_corgi"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_clown
	name = "Clown Shirt"
	icon_state = "shirt_clown"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_alien
	name = "Alien Shirt"
	icon_state = "shirt_alien"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_jack
	name = "Union Jack Shirt"
	icon_state = "shirt_jack"
	gender = NEUTER

/datum/sprite_accessory/undershirt/love_nt
	name = "I Love NT Shirt"
	icon_state = "shirt_lovent"
	gender = NEUTER

/datum/sprite_accessory/undershirt/peace
	name = "Peace Shirt"
	icon_state = "shirt_peace"
	gender = NEUTER

/datum/sprite_accessory/undershirt/mondmondjaja
	name = "Band Shirt"
	icon_state = "shirt_band"
	gender = NEUTER

/datum/sprite_accessory/undershirt/pacman
	name = "Pogoman Shirt"
	icon_state = "shirt_pogoman"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_ss13
	name = "SS13 Shirt"
	icon_state = "shirt_ss13"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_question
	name = "Question Mark Shirt"
	icon_state = "shirt_question"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_skull
	name = "Skull Shirt"
	icon_state = "shirt_skull"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_commie
	name = "Communist Shirt"
	icon_state = "shirt_commie"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_nano
	name = "Nanotrasen Shirt"
	icon_state = "shirt_nano"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_meat
	name = "Meat Shirt"
	icon_state = "shirt_meat"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_tiedie
	name = "Tiedie Shirt"
	icon_state = "shirt_tiedie"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blue_striped
	name = "Striped Blue Shirt"
	icon_state = "shirt_bluestripe"
	gender = NEUTER

/datum/sprite_accessory/undershirt/brightblue_striped
	name = "Striped Bright Blue Shirt"
	icon_state = "shirt_brightbluestripe"
	gender = NEUTER


//short sleeved
/datum/sprite_accessory/undershirt/short_white
	name = "White Short-sleeved Shirt"
	icon_state = "short_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/short_purple
	name = "Purple Short-sleeved Shirt"
	icon_state = "short_purple"
	gender = NEUTER

/datum/sprite_accessory/undershirt/short_blue
	name = "Blue Short-sleeved Shirt"
	icon_state = "short_blue"
	gender = NEUTER

/datum/sprite_accessory/undershirt/short_green
	name = "Green Short-sleeved Shirt"
	icon_state = "short_green"
	gender = NEUTER

/datum/sprite_accessory/undershirt/short_black
	name = "Black Short-sleeved Shirt"
	icon_state = "short_black"
	gender = NEUTER
//end short sleeved

//polo shirts
/datum/sprite_accessory/undershirt/polo_blue
	name = "Blue Polo Shirt"
	icon_state = "polo_blue"
	gender = NEUTER

/datum/sprite_accessory/undershirt/polo_red
	name = "Red Polo Shirt"
	icon_state = "polo_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/polo_greyelllow
	name = "Grey-Yellow Polo Shirt"
	icon_state = "polo_greyellow"
	gender = NEUTER
//end polo shirts

//sport shirts
/datum/sprite_accessory/undershirt/sport_green
	name = "Green Sports Shirt"
	icon_state = "sport_green"
	gender = NEUTER

/datum/sprite_accessory/undershirt/sport_red
	name = "Red Sports Shirt"
	icon_state = "sport_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/sport_blue
	name = "Blue Sports Shirt"
	icon_state = "sport_blue"
	gender = NEUTER
//end sport shirts

/datum/sprite_accessory/undershirt/jersey_red
	name = "Red Jersey"
	icon_state = "jersey_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/jersey_blue
	name = "Blue Jersey"
	icon_state = "jersey_blue"
	gender = NEUTER


//tanktops
/datum/sprite_accessory/undershirt/tank_redtop
	name = "Red Crop-Top"
	icon_state = "tank_redtop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tank_whitetop
	name = "White Crop-Top"
	icon_state = "tank_whitetop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tank_midriff
	name = "White Mid Tank-Top"
	icon_state = "tank_midriff"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tank_white
	name = "White Tank-Top"
	icon_state = "tank_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_black
	name = "Black Tank-Top"
	icon_state = "tank_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_blacker
	name = "Blacker Tank-Top"
	icon_state = "tank_blacker"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_grey
	name = "Grey Tank-Top"
	icon_state = "tank_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_red
	name = "Red Tank-Top"
	icon_state = "tank_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_fire
	name = "Fire Tank-Top"
	icon_state = "tank_fire"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_stripes
	name = "Striped Tank-Top"
	icon_state = "tank_stripes"
	gender = NEUTER


//end tanktops

///////////////////////
// Socks Definitions //
///////////////////////
/datum/sprite_accessory/socks
	icon = 'icons/mob/underwear.dmi'
	species_allowed = list("Human", "Unathi", "Diona", "Grey", "Machine", "Tajaran", "Vulpkanin", "Slime People", "Skeleton")

/datum/sprite_accessory/socks/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER
	species_allowed = list("Human", "Unathi", "Diona", "Grey", "Machine", "Tajaran", "Vulpkanin", "Slime People", "Skeleton", "Vox")


/datum/sprite_accessory/socks/white_norm
	name = "Normal White"
	icon_state = "white_norm"
	gender = NEUTER


/datum/sprite_accessory/socks/black_norm
	name = "Normal Black"
	icon_state = "black_norm"
	gender = NEUTER


/datum/sprite_accessory/socks/white_short
	name = "Short White"
	icon_state = "white_short"
	gender = NEUTER


/datum/sprite_accessory/socks/black_short
	name = "Short Black"
	icon_state = "black_short"
	gender = NEUTER


/datum/sprite_accessory/socks/white_knee
	name = "Knee-high White"
	icon_state = "white_knee"
	gender = NEUTER


/datum/sprite_accessory/socks/black_knee
	name = "Knee-high Black"
	icon_state = "black_knee"
	gender = NEUTER


/datum/sprite_accessory/socks/thin_knee
	name = "Knee-high Thin"
	icon_state = "thin_knee"
	gender = FEMALE


/datum/sprite_accessory/socks/striped_knee
	name = "Knee-high Striped"
	icon_state = "striped_knee"
	gender = NEUTER


/datum/sprite_accessory/socks/rainbow_knee
	name = "Knee-high Rainbow"
	icon_state = "rainbow_knee"
	gender = NEUTER


/datum/sprite_accessory/socks/white_thigh
	name = "Thigh-high White"
	icon_state = "white_thigh"
	gender = NEUTER

/datum/sprite_accessory/socks/black_thigh
	name = "Thigh-high Black"
	icon_state = "black_thigh"
	gender = NEUTER


/datum/sprite_accessory/socks/thin_thigh
	name = "Thigh-high Thin"
	icon_state = "thin_thigh"
	gender = FEMALE


/datum/sprite_accessory/socks/striped_thigh
	name = "Thigh-high Striped"
	icon_state = "striped_thigh"
	gender = NEUTER


/datum/sprite_accessory/socks/rainbow_thigh
	name = "Thigh-high Rainbow"
	icon_state = "rainbow_thigh"
	gender = NEUTER


/datum/sprite_accessory/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"
	gender = FEMALE


/datum/sprite_accessory/socks/black_fishnet
	name = "Black Fishnet"
	icon_state = "black_fishnet"
	gender = NEUTER

/datum/sprite_accessory/socks/vox_white
	name = "Vox White"
	icon_state = "vox_white"
	gender = NEUTER
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox_black
	name = "Vox Black"
	icon_state = "vox_black"
	gender = NEUTER
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox_thin
	name = "Vox Black Thin"
	icon_state = "vox_blackthin"
	gender = NEUTER
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox_rainbow
	name = "Vox Rainbow"
	icon_state = "vox_rainbow"
	gender = NEUTER
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox_stripped
	name = "Vox Striped"
	icon_state = "vox_white"
	gender = NEUTER
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox_white_thigh
	name = "Vox Thigh-high White"
	icon_state = "vox_whiteTH"
	gender = NEUTER
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox_black_thigh
	name = "Vox Thigh-high Black"
	icon_state = "vox_blackTH"
	gender = NEUTER
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox_thin_thigh
	name = "Vox Thigh-high Thin"
	icon_state = "vox_blackthinTH"
	gender = NEUTER
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox_rainbow_thigh
	name = "Vox Thigh-high Rainbow"
	icon_state = "vox_rainbowTH"
	gender = NEUTER
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox_striped_thigh
	name = "Vox Thigh-high Striped"
	icon_state = "vox_stripedTH"
	gender = NEUTER
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox_fishnet
	name = "Vox Fishnets"
	icon_state = "vox_fishnet"
	gender = NEUTER
	species_allowed = list("Vox")

/* HEAD ACCESSORY */

/datum/sprite_accessory/head_accessory
	icon = 'icons/mob/body_accessory.dmi'
	species_allowed = list("Unathi", "Vulpkanin", "Tajaran", "Machine")
	icon_state = "accessory_none"

/datum/sprite_accessory/head_accessory/none
	name = "None"
	species_allowed = list("Human", "Unathi", "Diona", "Grey", "Machine", "Tajaran", "Vulpkanin", "Slime People", "Skeleton", "Vox")
	icon_state = "accessory_none"

/datum/sprite_accessory/head_accessory/simple
	name = "Simple"
	species_allowed = list("Unathi")
	icon_state = "horns_simple"

/datum/sprite_accessory/head_accessory/short
	name = "Short"
	species_allowed = list("Unathi")
	icon_state = "horns_short"

/datum/sprite_accessory/head_accessory/curled
	name = "Curled"
	species_allowed = list("Unathi")
	icon_state = "horns_curled"

/datum/sprite_accessory/head_accessory/ram
	name = "Ram"
	species_allowed = list("Unathi")
	icon_state = "horns_ram"

/datum/sprite_accessory/head_accessory/vulp_earfluff
	icon = 'icons/mob/human_face.dmi'
	name = "Vulpkanin Earfluff"
	icon_state = "vulp_facial_earfluff"
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/head_accessory/vulp_blaze
	icon = 'icons/mob/human_face.dmi'
	name = "Blaze"
	icon_state = "vulp_facial_blaze"
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/head_accessory/vulp_vulpine
	icon = 'icons/mob/human_face.dmi'
	name = "Vulpine"
	icon_state = "vulp_facial_vulpine"
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/head_accessory/vulp_vulpine_fluff
	icon = 'icons/mob/human_face.dmi'
	name = "Vulpine and Earfluff"
	icon_state = "vulp_facial_vulpine_fluff"
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/head_accessory/vulp_mask
	icon = 'icons/mob/human_face.dmi'
	name = "Mask"
	icon_state = "vulp_facial_mask"
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/head_accessory/vulp_patch
	icon = 'icons/mob/human_face.dmi'
	name = "Patch"
	icon_state = "vulp_facial_patch"
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/head_accessory/vulp_ruff
	icon = 'icons/mob/human_face.dmi'
	name = "Ruff"
	icon_state = "vulp_facial_ruff"
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/head_accessory/vulp_kita
	icon = 'icons/mob/human_face.dmi'
	name = "Kita"
	icon_state = "vulp_facial_kita"
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/head_accessory/vulp_swift
	icon = 'icons/mob/human_face.dmi'
	name = "Swift"
	icon_state = "vulp_facial_swift"
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/head_accessory/taj_ears
	icon = 'icons/mob/human_face.dmi'
	name = "Tajaran Ears"
	icon_state = "ears_plain"
	species_allowed = list("Tajaran")

/datum/sprite_accessory/head_accessory/ipc_antennae
	name = "Antennae"
	icon_state = "antennae"
	species_allowed = list("Machine")

/datum/sprite_accessory/head_accessory/ipc_tv_antennae
	name = "T.V. Antennae"
	icon_state = "tvantennae"
	species_allowed = list("Machine")

/datum/sprite_accessory/head_accessory/ipc_tesla_antennae
	name = "Tesla Antennae"
	icon_state = "tesla"
	species_allowed = list("Machine")

/datum/sprite_accessory/head_accessory/ipc_light
	name = "Head Light"
	icon_state = "light"
	species_allowed = list("Machine")


/* BODY MARKINGS */

/datum/sprite_accessory/body_markings
	icon = 'icons/mob/body_accessory.dmi'
	species_allowed = list("Unathi", "Tajaran", "Vulpkanin", "Machine")
	icon_state = "accessory_none"

/datum/sprite_accessory/body_markings/none
	name = "None"
	species_allowed = list("Human", "Unathi", "Diona", "Grey", "Machine", "Tajaran", "Vulpkanin", "Slime People", "Skeleton", "Vox")
	icon_state = "accessory_none"

/datum/sprite_accessory/body_markings/stripe
	name = "Stripe"
	species_allowed = list("Unathi")
	icon_state = "markings_stripe"

/datum/sprite_accessory/body_markings/tiger
	name = "Tiger Body"
	species_allowed = list("Unathi", "Tajaran", "Vulpkanin")
	icon_state = "markings_tiger"

/datum/sprite_accessory/body_markings/tigerhead
	name = "Tiger Body and Head"
	species_allowed = list("Unathi", "Tajaran", "Vulpkanin")
	icon_state = "markings_tigerhead"

/datum/sprite_accessory/body_markings/tigerheadface_taj
	name = "Tajaran Tiger Body, Head and Face"
	species_allowed = list("Tajaran")
	icon_state = "markings_tigerheadface_taj"

/datum/sprite_accessory/body_markings/tigerheadface_vulp
	name = "Vulpkanin Tiger Body, Head and Face"
	species_allowed = list("Vulpkanin")
	icon_state = "markings_tigerheadface_vulp"

/datum/sprite_accessory/body_markings/tigerheadface_una
	name = "Unathi Tiger Body, Head and Face"
	species_allowed = list("Unathi")
	icon_state = "markings_tigerheadface_una"

/datum/sprite_accessory/body_markings/optics
	name = "Humanoid Optics"
	species_allowed = list("Machine")
	icon_state = "optics"
	models_allowed = list("Bishop Cybernetics", "Hesphiastos Industries", "Ward-Takahashi", "Xion Manufacturing Group", "Zeng-Hu Pharmaceuticals") //Should be the same as the manufacturing company of the limb in robolimbs.dm
	marking_location = "head"

/datum/sprite_accessory/body_markings/optics/bishop_alt
	name = "Bishop Alt. Optics"
	species_allowed = list("Machine")
	icon_state = "bishop_alt_optics"
	models_allowed = list("Bishop Cybernetics alt.")

/datum/sprite_accessory/body_markings/optics/morpheus_alt
	name = "Morpheus Alt. Optics"
	species_allowed = list("Machine")
	icon_state = "morpheus_alt_optics"
	models_allowed = list("Morpheus Cyberkinetics alt.")

/datum/sprite_accessory/body_markings/optics/wardtakahashi_alt
	name = "Ward-Takahashi Alt. Optics"
	species_allowed = list("Machine")
	icon_state = "wardtakahashi_alt_optics"
	models_allowed = list("Ward-Takahashi alt.")

/datum/sprite_accessory/body_markings/optics/xion_alt
	name = "Xion Alt. Optics"
	species_allowed = list("Machine")
	icon_state = "xion_alt_optics"
	models_allowed = list("Xion Manufacturing Group alt.")

/datum/sprite_accessory/body_markings/tattoo // Tattoos applied post-round startup with tattoo guns in item_defines.dm
	name = "base tattoo"
	species_allowed = list()
	icon_state = "accessory_none"

/datum/sprite_accessory/body_markings/tattoo/elliot
	name = "Elliot Circuit Tattoo"
	icon_state = "campbell_tattoo"