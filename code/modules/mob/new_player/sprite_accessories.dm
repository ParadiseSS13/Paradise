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
			if(MALE)	male += D.name
			if(FEMALE)	female += D.name
			else
				male += D.name
				female += D.name
	return L

/datum/sprite_accessory
	var/icon			//the icon file the accessory is located in
	var/icon_state		//the icon_state of the accessory
	var/name			//the preview name of the accessory
	var/gender = NEUTER	//Determines if the accessory will be skipped or included in random hair generations

	// Restrict some styles to specific species
	var/list/species_allowed = list("Human")

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
		species_allowed = list("Human","Unathi","Vox","Diona","Kidan","Grey","Plasmaman","Skellington")

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
		name = "Ponytail 1"
		icon_state = "hair_ponytail"

	ponytail2
		name = "Ponytail 2"
		icon_state = "hair_pa"
		gender = FEMALE

	ponytail3
		name = "Ponytail 3"
		icon_state = "hair_ponytail3"

	sideponytail
		name = "Side Ponytail"
		icon_state = "hair_stail"
		gender = FEMALE

	parted
		name = "Parted"
		icon_state = "hair_parted"

	pompadour
		name = "Pompadour"
		icon_state = "hair_pompadour"
		gender = MALE
		species_allowed = list("Human","Unathi")

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
		species_allowed = list("Human","Unathi")

	bobcurl
		name = "Bobcurl"
		icon_state = "hair_bobcurl"
		gender = FEMALE
		species_allowed = list("Human","Unathi")

	bob
		name = "Bob"
		icon_state = "hair_bobcut"
		gender = FEMALE
		species_allowed = list("Human","Unathi")

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
		species_allowed = list("Human","Unathi")

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
		species_allowed = list("Human","Unathi")
	jensen
		name = "Adam Jensen Hair"
		icon_state = "hair_jensen"
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
		species_allowed = list("Human","Unathi")

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

	icp_screen_pink
		name = "pink IPC screen"
		icon_state = "ipc_pink"
		species_allowed = list("Machine")

	icp_screen_red
		name = "red IPC screen"
		icon_state = "ipc_red"
		species_allowed = list("Machine")

	icp_screen_green
		name = "green IPC screen"
		icon_state = "ipc_green"
		species_allowed = list("Machine")

	icp_screen_blue
		name = "blue IPC screen"
		icon_state = "ipc_blue"
		species_allowed = list("Machine")

	icp_screen_breakout
		name = "breakout IPC screen"
		icon_state = "ipc_breakout"
		species_allowed = list("Machine")

	icp_screen_eight
		name = "eight IPC screen"
		icon_state = "ipc_eight"
		species_allowed = list("Machine")

	icp_screen_goggles
		name = "goggles IPC screen"
		icon_state = "ipc_goggles"
		species_allowed = list("Machine")

	icp_screen_heart
		name = "heart IPC screen"
		icon_state = "ipc_heart"
		species_allowed = list("Machine")

	icp_screen_monoeye
		name = "monoeye IPC screen"
		icon_state = "ipc_monoeye"
		species_allowed = list("Machine")

	icp_screen_nature
		name = "nature IPC screen"
		icon_state = "ipc_nature"
		species_allowed = list("Machine")

	icp_screen_orange
		name = "orange IPC screen"
		icon_state = "ipc_orange"
		species_allowed = list("Machine")

	icp_screen_purple
		name = "purple IPC screen"
		icon_state = "ipc_purple"
		species_allowed = list("Machine")

	icp_screen_shower
		name = "shower IPC screen"
		icon_state = "ipc_shower"
		species_allowed = list("Machine")

	icp_screen_static
		name = "static IPC screen"
		icon_state = "ipc_static"
		species_allowed = list("Machine")

	icp_screen_yellow
		name = "yellow IPC screen"
		icon_state = "ipc_yellow"
		species_allowed = list("Machine")

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
		species_allowed = list("Human","Unathi","Tajaran","Skrell","Vox","Diona","Kidan","Greys","Machine", "Vulpkanin")


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
	una_spines_long
		name = "Long Unathi Spines"
		icon_state = "soghun_longspines"
		species_allowed = list("Unathi")

	una_spines_short
		name = "Short Unathi Spines"
		icon_state = "soghun_shortspines"
		species_allowed = list("Unathi")

	una_frills_long
		name = "Long Unathi Frills"
		icon_state = "soghun_longfrills"
		species_allowed = list("Unathi")

	una_frills_short
		name = "Short Unathi Frills"
		icon_state = "soghun_shortfrills"
		species_allowed = list("Unathi")

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
		name = "Tajara Smallsatche"
		icon_state = "facial_smallstache"
		species_allowed = list("Tajaran")

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

	vulp_earfluff
		name = "Earfluff"
		icon_state = "vulp_facial_earfluff"
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

	species_allowed = list("Human","Unathi","Vox","Diona","Kidan","Grey","Plasmaman","Skellington")

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

	male_green
		name = "Mens Green"
		icon_state = "male_green"
		gender = MALE

	male_blue
		name = "Mens Blue"
		icon_state = "male_blue"
		gender = MALE

	male_black
		name = "Mens Black"
		icon_state = "male_black"
		gender = MALE

	male_mankini
		name = "Mankini"
		icon_state = "male_mankini"
		gender = MALE

	female_red
		name = "Ladies Red"
		icon_state = "female_red"
		gender = FEMALE

	female_white
		name = "Ladies White"
		icon_state = "female_white"
		gender = FEMALE

	female_yellow
		name = "Ladies Yellow"
		icon_state = "female_yellow"
		gender = FEMALE

	female_blue
		name = "Ladies Blue"
		icon_state = "female_blue"
		gender = FEMALE

	female_black
		name = "Ladies Black"
		icon_state = "female_black"
		gender = FEMALE

	female_kinky
		name = "Ladies Kinky"
		icon_state = "female_kinky"
		gender = FEMALE

////////////////////////////
// Undershirt Definitions //
////////////////////////////
/datum/sprite_accessory/undershirt
	icon = 'icons/mob/underwear.dmi'

	species_allowed = list("Human","Unathi","Vox","Diona","Kidan","Grey","Plasmaman","Skellington")

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
/datum/sprite_accessory/undershirt/tank_white
	name = "White Tank-Top"
	icon_state = "tank_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_black
	name = "Black Tank-Top"
	icon_state = "tank_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_grey
	name = "Grey Tank-Top"
	icon_state = "tank_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_fire
	name = "Fire Tank-Top"
	icon_state = "tank_fire"
	gender = NEUTER
//end tanktops

///////////////////////
// Socks Definitions //
///////////////////////
/datum/sprite_accessory/socks
	icon = 'icons/mob/underwear.dmi'

/datum/sprite_accessory/socks/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/white_norm
	name = "Normal White"
	icon_state = "white_norm"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/black_norm
	name = "Normal Black"
	icon_state = "black_norm"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/white_short
	name = "Short White"
	icon_state = "white_short"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/black_short
	name = "Short Black"
	icon_state = "black_short"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/white_knee
	name = "Knee-high White"
	icon_state = "white_knee"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/black_knee
	name = "Knee-high Black"
	icon_state = "black_knee"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/thin_knee
	name = "Knee-high Thin"
	icon_state = "thin_knee"
	gender = FEMALE
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/striped_knee
	name = "Knee-high Striped"
	icon_state = "striped_knee"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/rainbow_knee
	name = "Knee-high Rainbow"
	icon_state = "rainbow_knee"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/white_thigh
	name = "Thigh-high White"
	icon_state = "white_thigh"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")

/datum/sprite_accessory/socks/black_thigh
	name = "Thigh-high Black"
	icon_state = "black_thigh"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/thin_thigh
	name = "Thigh-high Thin"
	icon_state = "thin_thigh"
	gender = FEMALE
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/striped_thigh
	name = "Thigh-high Striped"
	icon_state = "striped_thigh"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/rainbow_thigh
	name = "Thigh-high Rainbow"
	icon_state = "rainbow_thigh"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"
	gender = FEMALE
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")


/datum/sprite_accessory/socks/black_fishnet
	name = "Black Fishnet"
	icon_state = "black_fishnet"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Diona","Grey","Machine","Tajaran","Vulpakanin","Slime People","Skellington")

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
	name = "Vox Stripped"
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

/datum/sprite_accessory/socks/vox_stripped_thigh
	name = "Vox Thigh-high Stripped"
	icon_state = "vox_strippedTH"
	gender = NEUTER
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox_fishnet
	name = "Vox Fishnets"
	icon_state = "vox_fishnet"
	gender = NEUTER
	species_allowed = list("Vox")