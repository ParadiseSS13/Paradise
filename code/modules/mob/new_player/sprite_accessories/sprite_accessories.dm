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

/proc/init_sprite_accessory_subtypes(var/prototype, var/list/L, var/list/male, var/list/female, var/list/full_list)
	if(!istype(L))	L = list()
	if(!istype(male))	male = list()
	if(!istype(female))	female = list()
	if(!istype(full_list))	full_list = list()

	for(var/path in subtypesof(prototype))
		var/datum/sprite_accessory/D = new path()

		if(D.name)
			if(D.fluff)
				full_list[D.name] = D
			else
				L[D.name] = D
				full_list[D.name] = D

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
	var/list/models_allowed = list() //Specifies which, if any, hairstyles or markings can be accessed by which prosthetics. Should equal the manufacturing company name in robolimbs.dm.
	var/list/heads_allowed = null //Specifies which, if any, alt heads a head marking, hairstyle or facial hair style is compatible with.
	var/list/tails_allowed = null //Specifies which, if any, tails a tail marking is compatible with.
	var/marking_location //Specifies which bodypart a body marking is located on.
	var/secondary_theme = null //If exists, there's a secondary colour to that hair style and the secondary theme's icon state's suffix is equal to this.
	var/no_sec_colour = null //If exists, prohibit the colouration of the secondary theme.
	var/fluff = 0
	// Whether or not the accessory can be affected by colouration
	var/do_colouration = 1

/* HAIR */

/datum/sprite_accessory/hair
	icon = 'icons/mob/sprite_accessories/human/human_hair.dmi'	  // default icon for all human hair. Override if it doesn't belong to human. Human hair that is shared belongs in human file.
	var/glasses_over //Hair styles with hair that don't overhang the arms of glasses should have glasses_over set to a positive value

/datum/sprite_accessory/hair/bald
	icon = 'icons/mob/human_face.dmi' // Keep bald hair here, as for some reason, putting it elsewhere lead to it being colourable - Also it make sense as it is shared by everyone.
	name = "Bald"
	icon_state = "bald"
	species_allowed = list("Human", "Unathi", "Vox", "Diona", "Kidan", "Grey", "Plasmaman", "Skeleton", "Vulpkanin", "Tajaran")
	glasses_over = 1

/datum/sprite_accessory/facial_hair
	gender = MALE // barf (unless you're a dorf, dorfs dig chix /w beards :P)
	icon = 'icons/mob/sprite_accessories/human/human_facial_hair.dmi'
	var/over_hair

/datum/sprite_accessory/hair/fluff
	fluff = 1

/* HEAD ACCESSORY */

/datum/sprite_accessory/head_accessory
	icon = 'icons/mob/body_accessory.dmi'
	species_allowed = list("Unathi", "Vulpkanin", "Tajaran", "Machine")
	icon_state = "accessory_none"
	var/over_hair

/datum/sprite_accessory/head_accessory/none
	name = "None"
	species_allowed = list("Human", "Unathi", "Diona", "Grey", "Kidan", "Machine", "Tajaran", "Vulpkanin", "Skrell", "Slime People", "Skeleton", "Vox")
	icon_state = "accessory_none"

/* BODY MARKINGS */

/datum/sprite_accessory/body_markings
	icon = 'icons/mob/sprite_accessories/human/human_body_markings.dmi'
	species_allowed = list("Unathi", "Tajaran", "Vulpkanin", "Machine", "Vox", "Kidan")
	icon_state = "accessory_none"
	marking_location = "body"

/datum/sprite_accessory/body_markings/head
	marking_location = "head"
	species_allowed = list()


/datum/sprite_accessory/body_markings/tail
	species_allowed = list()
	icon_state = "accessory_none"
	marking_location = "tail"
	tails_allowed = null

/* ALT HEADS */

/datum/sprite_accessory/alt_heads
	icon = null
	icon_state = null
	species_allowed = null
	var/suffix = null

/datum/sprite_accessory/alt_heads/none
	name = "None"

//skin styles - WIP
//going to have to re-integrate this with surgery
//let the icon_state hold an icon preview for now
/datum/sprite_accessory/skin
	icon = 'icons/mob/human_races/r_human.dmi'

/datum/sprite_accessory/skin/human
	name = "Default human skin"
	icon_state = "default"
	species_allowed = list("Human",)

/datum/sprite_accessory/skin/human/human_tatt01
	name = "Tatt01 human skin"
	icon_state = "tatt1"

/datum/sprite_accessory/skin/tajaran
	name = "Default tajaran skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_tajaran.dmi'
	species_allowed = list("Tajaran")

/datum/sprite_accessory/skin/vulpkanin
	name = "Default Vulpkanin skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_vulpkanin.dmi'
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/skin/unathi
	name = "Default Unathi skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_lizard.dmi'
	species_allowed = list("Unathi")

/datum/sprite_accessory/skin/skrell
	name = "Default skrell skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_skrell.dmi'
	species_allowed = list("Skrell")

///////////////////////////
// Underwear Definitions //
///////////////////////////
/datum/sprite_accessory/underwear
	icon = 'icons/mob/underwear.dmi'
	species_allowed = list("Human", "Unathi", "Diona", "Vulpkanin", "Tajaran", "Kidan", "Grey", "Plasmaman", "Machine", "Skrell", "Slime People", "Skeleton", "Drask")
	gender = NEUTER

/datum/sprite_accessory/underwear/nude
	name = "Nude"
	icon_state = null
	species_allowed = list("Human", "Unathi", "Diona", "Vulpkanin", "Tajaran", "Kidan", "Grey", "Plasmaman", "Machine", "Skrell", "Slime People", "Skeleton", "Drask", "Vox")

/datum/sprite_accessory/underwear/male
	gender = MALE

/datum/sprite_accessory/underwear/male/male_white
	name = "Mens White"
	icon_state = "male_white"

/datum/sprite_accessory/underwear/male/male_grey
	name = "Mens Grey"
	icon_state = "male_grey"

/datum/sprite_accessory/underwear/male/male_grey
	name = "Mens Grey Alt"
	icon_state = "male_greyalt"

/datum/sprite_accessory/underwear/male/male_green
	name = "Mens Green"
	icon_state = "male_green"

/datum/sprite_accessory/underwear/male/male_blue
	name = "Mens Blue"
	icon_state = "male_blue"

/datum/sprite_accessory/underwear/male/male_red
	name = "Mens Red"
	icon_state = "male_red"

/datum/sprite_accessory/underwear/male/male_black
	name = "Mens Black"
	icon_state = "male_black"

/datum/sprite_accessory/underwear/male/male_black_alt
	name = "Mens Black Alt"
	icon_state = "male_blackalt"

/datum/sprite_accessory/underwear/male/male_striped
	name = "Mens Striped"
	icon_state = "male_stripe"

/datum/sprite_accessory/underwear/male/male_heart
	name = "Mens Hearts"
	icon_state = "male_hearts"

/datum/sprite_accessory/underwear/male/male_kinky
	name = "Mens Kinky"
	icon_state = "male_kinky"

/datum/sprite_accessory/underwear/male/male_mankini
	name = "Mankini"
	icon_state = "male_mankini"

/datum/sprite_accessory/underwear/female
	gender = FEMALE

/datum/sprite_accessory/underwear/female/female_red
	name = "Ladies Red"
	icon_state = "female_red"

/datum/sprite_accessory/underwear/female/female_green
	name = "Ladies Green"
	icon_state = "female_green"

/datum/sprite_accessory/underwear/female/female_white
	name = "Ladies White"
	icon_state = "female_white"

/datum/sprite_accessory/underwear/female/female_whiter
	name = "Ladies Whiter"
	icon_state = "female_whiter"

/datum/sprite_accessory/underwear/female/female_whitealt
	name = "Ladies White Alt"
	icon_state = "female_whitealt"

/datum/sprite_accessory/underwear/female/female_yellow
	name = "Ladies Yellow"
	icon_state = "female_yellow"

/datum/sprite_accessory/underwear/female/female_blue
	name = "Ladies Blue"
	icon_state = "female_blue"
/datum/sprite_accessory/underwear/female/female_babyblue
	name = "Ladies Baby Blue"
	icon_state = "female_babyblue"

/datum/sprite_accessory/underwear/female/female_black
	name = "Ladies Black"
	icon_state = "female_black"

/datum/sprite_accessory/underwear/female/female_blacker
	name = "Ladies Blacker"
	icon_state = "female_blacker"

/datum/sprite_accessory/underwear/female/female_blackalt
	name = "Ladies Black Alt"
	icon_state = "female_blackalt"

/datum/sprite_accessory/underwear/female/female_kinky
	name = "Ladies Kinky"
	icon_state = "female_kinky"

/datum/sprite_accessory/underwear/female/female_babydoll
	name = "Ladies Full Grey"
	icon_state = "female_babydoll"

/datum/sprite_accessory/underwear/female/female_pink
	name = "Ladies Pink"
	icon_state = "female_pink"

/datum/sprite_accessory/underwear/female/female_thong
	name = "Ladies Thong"
	icon_state = "female_thong"

////////////////////////////
// Undershirt Definitions //
////////////////////////////
/datum/sprite_accessory/undershirt
	icon = 'icons/mob/underwear.dmi'
	species_allowed = list("Human", "Unathi", "Diona", "Vulpkanin", "Tajaran", "Kidan", "Grey", "Plasmaman", "Machine", "Skrell", "Slime People", "Skeleton", "Drask")
	gender = NEUTER

/datum/sprite_accessory/undershirt/nude
	name = "Nude"
	icon_state = null
	species_allowed = list("Human", "Unathi", "Diona", "Vulpkanin", "Tajaran", "Kidan", "Grey", "Plasmaman", "Machine", "Skrell", "Slime People", "Skeleton", "Drask", "Vox")

//plain color shirts
/datum/sprite_accessory/undershirt/shirt_white
	name = "White Shirt"
	icon_state = "shirt_white"

/datum/sprite_accessory/undershirt/shirt_black
	name = "Black Shirt"
	icon_state = "shirt_black"

/datum/sprite_accessory/undershirt/shirt_blacker
	name = "Blacker Shirt"
	icon_state = "shirt_blacker"

/datum/sprite_accessory/undershirt/shirt_grey
	name = "Grey Shirt"
	icon_state = "shirt_grey"

/datum/sprite_accessory/undershirt/shirt_red
	name = "Red Shirt"
	icon_state = "shirt_red"

/datum/sprite_accessory/undershirt/shirt_blue
	name = "Blue Shirt"
	icon_state = "shirt_blue"

/datum/sprite_accessory/undershirt/shirt_yellow
	name = "Yellow Shirt"
	icon_state = "shirt_yellow"

/datum/sprite_accessory/undershirt/shirt_green
	name = "Green Shirt"
	icon_state = "shirt_green"

/datum/sprite_accessory/undershirt/shirt_darkblue
	name = "Dark Blue Shirt"
	icon_state = "shirt_darkblue"

/datum/sprite_accessory/undershirt/shirt_darkred
	name = "Dark Red Shirt"
	icon_state = "shirt_darkred"

/datum/sprite_accessory/undershirt/shirt_darkgreen
	name = "Dark Green Shirt"
	icon_state = "shirt_darkgreen"
//end plain color shirts

//graphic shirts
/datum/sprite_accessory/undershirt/shirt_heart
	name = "Heart Shirt"
	icon_state = "shirt_heart"

/datum/sprite_accessory/undershirt/shirt_corgi
	name = "Corgi Shirt"
	icon_state = "shirt_corgi"

/datum/sprite_accessory/undershirt/shirt_clown
	name = "Clown Shirt"
	icon_state = "shirt_clown"

/datum/sprite_accessory/undershirt/shirt_alien
	name = "Alien Shirt"
	icon_state = "shirt_alien"

/datum/sprite_accessory/undershirt/shirt_jack
	name = "Union Jack Shirt"
	icon_state = "shirt_jack"

/datum/sprite_accessory/undershirt/love_nt
	name = "I Love NT Shirt"
	icon_state = "shirt_lovent"

/datum/sprite_accessory/undershirt/peace
	name = "Peace Shirt"
	icon_state = "shirt_peace"

/datum/sprite_accessory/undershirt/mondmondjaja
	name = "Band Shirt"
	icon_state = "shirt_band"

/datum/sprite_accessory/undershirt/pacman
	name = "Pogoman Shirt"
	icon_state = "shirt_pogoman"

/datum/sprite_accessory/undershirt/shirt_ss13
	name = "SS13 Shirt"
	icon_state = "shirt_ss13"

/datum/sprite_accessory/undershirt/shirt_question
	name = "Question Mark Shirt"
	icon_state = "shirt_question"

/datum/sprite_accessory/undershirt/shirt_skull
	name = "Skull Shirt"
	icon_state = "shirt_skull"

/datum/sprite_accessory/undershirt/shirt_commie
	name = "Communist Shirt"
	icon_state = "shirt_commie"

/datum/sprite_accessory/undershirt/shirt_nano
	name = "Nanotrasen Shirt"
	icon_state = "shirt_nano"

/datum/sprite_accessory/undershirt/shirt_meat
	name = "Meat Shirt"
	icon_state = "shirt_meat"

/datum/sprite_accessory/undershirt/shirt_tiedie
	name = "Tiedie Shirt"
	icon_state = "shirt_tiedie"

/datum/sprite_accessory/undershirt/blue_striped
	name = "Striped Blue Shirt"
	icon_state = "shirt_bluestripe"

/datum/sprite_accessory/undershirt/brightblue_striped
	name = "Striped Bright Blue Shirt"
	icon_state = "shirt_brightbluestripe"
//end graphic shirts

//short sleeved
/datum/sprite_accessory/undershirt/short_white
	name = "White Short-sleeved Shirt"
	icon_state = "short_white"

/datum/sprite_accessory/undershirt/short_purple
	name = "Purple Short-sleeved Shirt"
	icon_state = "short_purple"

/datum/sprite_accessory/undershirt/short_blue
	name = "Blue Short-sleeved Shirt"
	icon_state = "short_blue"

/datum/sprite_accessory/undershirt/short_green
	name = "Green Short-sleeved Shirt"
	icon_state = "short_green"

/datum/sprite_accessory/undershirt/short_black
	name = "Black Short-sleeved Shirt"
	icon_state = "short_black"
//end short sleeved

//polo shirts
/datum/sprite_accessory/undershirt/polo_blue
	name = "Blue Polo Shirt"
	icon_state = "polo_blue"

/datum/sprite_accessory/undershirt/polo_red
	name = "Red Polo Shirt"
	icon_state = "polo_red"

/datum/sprite_accessory/undershirt/polo_greyelllow
	name = "Grey-Yellow Polo Shirt"
	icon_state = "polo_greyellow"
//end polo shirts

//sport shirts
/datum/sprite_accessory/undershirt/sport_green
	name = "Green Sports Shirt"
	icon_state = "sport_green"

/datum/sprite_accessory/undershirt/sport_red
	name = "Red Sports Shirt"
	icon_state = "sport_red"

/datum/sprite_accessory/undershirt/sport_blue
	name = "Blue Sports Shirt"
	icon_state = "sport_blue"

/datum/sprite_accessory/undershirt/jersey_red
	name = "Red Jersey"
	icon_state = "jersey_red"

/datum/sprite_accessory/undershirt/jersey_blue
	name = "Blue Jersey"
	icon_state = "jersey_blue"
//end sport shirts

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

/datum/sprite_accessory/undershirt/tank_black
	name = "Black Tank-Top"
	icon_state = "tank_black"

/datum/sprite_accessory/undershirt/tank_blacker
	name = "Blacker Tank-Top"
	icon_state = "tank_blacker"

/datum/sprite_accessory/undershirt/tank_grey
	name = "Grey Tank-Top"
	icon_state = "tank_grey"

/datum/sprite_accessory/undershirt/tank_red
	name = "Red Tank-Top"
	icon_state = "tank_red"

/datum/sprite_accessory/undershirt/tank_fire
	name = "Fire Tank-Top"
	icon_state = "tank_fire"

/datum/sprite_accessory/undershirt/tank_stripes
	name = "Striped Tank-Top"
	icon_state = "tank_stripes"
//end tanktops

///////////////////////
// Socks Definitions //
///////////////////////
/datum/sprite_accessory/socks
	icon = 'icons/mob/underwear.dmi'
	species_allowed = list("Human", "Unathi", "Diona", "Vulpkanin", "Tajaran", "Kidan", "Grey", "Plasmaman", "Machine", "Skrell", "Slime People", "Skeleton", "Drask")
	gender = NEUTER

/datum/sprite_accessory/socks/nude
	name = "Nude"
	icon_state = null
	species_allowed = list("Human", "Unathi", "Diona", "Vulpkanin", "Tajaran", "Kidan", "Grey", "Plasmaman", "Machine", "Skrell", "Slime People", "Skeleton", "Drask", "Vox")

/datum/sprite_accessory/socks/white_norm
	name = "Normal White"
	icon_state = "white_norm"

/datum/sprite_accessory/socks/black_norm
	name = "Normal Black"
	icon_state = "black_norm"

/datum/sprite_accessory/socks/white_short
	name = "Short White"
	icon_state = "white_short"

/datum/sprite_accessory/socks/black_short
	name = "Short Black"
	icon_state = "black_short"

/datum/sprite_accessory/socks/white_knee
	name = "Knee-high White"
	icon_state = "white_knee"

/datum/sprite_accessory/socks/black_knee
	name = "Knee-high Black"
	icon_state = "black_knee"

/datum/sprite_accessory/socks/thin_knee
	name = "Knee-high Thin"
	icon_state = "thin_knee"
	gender = FEMALE

/datum/sprite_accessory/socks/striped_knee
	name = "Knee-high Striped"
	icon_state = "striped_knee"

/datum/sprite_accessory/socks/rainbow_knee
	name = "Knee-high Rainbow"
	icon_state = "rainbow_knee"

/datum/sprite_accessory/socks/white_thigh
	name = "Thigh-high White"
	icon_state = "white_thigh"

/datum/sprite_accessory/socks/black_thigh
	name = "Thigh-high Black"
	icon_state = "black_thigh"

/datum/sprite_accessory/socks/thin_thigh
	name = "Thigh-high Thin"
	icon_state = "thin_thigh"
	gender = FEMALE

/datum/sprite_accessory/socks/striped_thigh
	name = "Thigh-high Striped"
	icon_state = "striped_thigh"

/datum/sprite_accessory/socks/rainbow_thigh
	name = "Thigh-high Rainbow"
	icon_state = "rainbow_thigh"

/datum/sprite_accessory/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"
	gender = FEMALE

/datum/sprite_accessory/socks/black_fishnet
	name = "Black Fishnet"
	icon_state = "black_fishnet"

/datum/sprite_accessory/socks/vox
	species_allowed = list("Vox")

/datum/sprite_accessory/socks/vox/vox_white
	name = "Vox White"
	icon_state = "vox_white"

/datum/sprite_accessory/socks/vox/vox_black
	name = "Vox Black"
	icon_state = "vox_black"

/datum/sprite_accessory/socks/vox/vox_thin
	name = "Vox Black Thin"
	icon_state = "vox_blackthin"

/datum/sprite_accessory/socks/vox/vox_rainbow
	name = "Vox Rainbow"
	icon_state = "vox_rainbow"

/datum/sprite_accessory/socks/vox/vox_stripped
	name = "Vox Striped"
	icon_state = "vox_white"

/datum/sprite_accessory/socks/vox/vox_white_thigh
	name = "Vox Thigh-high White"
	icon_state = "vox_whiteTH"

/datum/sprite_accessory/socks/vox/vox_black_thigh
	name = "Vox Thigh-high Black"
	icon_state = "vox_blackTH"

/datum/sprite_accessory/socks/vox/vox_thin_thigh
	name = "Vox Thigh-high Thin"
	icon_state = "vox_blackthinTH"

/datum/sprite_accessory/socks/vox/vox_rainbow_thigh
	name = "Vox Thigh-high Rainbow"
	icon_state = "vox_rainbowTH"

/datum/sprite_accessory/socks/vox/vox_striped_thigh
	name = "Vox Thigh-high Striped"
	icon_state = "vox_stripedTH"

/datum/sprite_accessory/socks/vox/vox_fishnet
	name = "Vox Fishnets"
	icon_state = "vox_fishnet"