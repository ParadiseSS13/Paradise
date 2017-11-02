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


/*
////////////////////////////
/  =--------------------=  /
/  == Hair Definitions ==  /
/  =--------------------=  /
////////////////////////////
*/

/datum/sprite_accessory/hair
	icon = 'icons/mob/human_face.dmi'	  // default icon for all hairs
	var/glasses_over //Hair styles with hair that don't overhang the arms of glasses should have glasses_over set to a positive value

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = "bald"
	species_allowed = list("Human", "Unathi", "Vox", "Diona", "Kidan", "Grey", "Plasmaman", "Skeleton", "Vulpkanin", "Tajaran")
	glasses_over = 1

/datum/sprite_accessory/hair/short
	name = "Short Hair"	  // try to capatilize the names please~
	icon_state = "hair_a" // you do not need to define _s or _l sub-states, game automatically does this for you
	glasses_over = 1

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "hair_c"
	glasses_over = 1

/datum/sprite_accessory/hair/long
	name = "Shoulder-length Hair"
	icon_state = "hair_b"

/datum/sprite_accessory/hair/longalt
	name = "Shoulder-length Hair Alt"
	icon_state = "hair_longfringe"

/*/datum/sprite_accessory/hair/longish
	name = "Longer Hair"
	icon_state = "hair_b2"*/

/datum/sprite_accessory/hair/longer
	name = "Long Hair"
	icon_state = "hair_vlong"

/datum/sprite_accessory/hair/longeralt
	name = "Long Hair Alt"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/longest
	name = "Very Long Hair"
	icon_state = "hair_longest"

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "hair_longfringe"

/datum/sprite_accessory/hair/longestalt
	name = "Longer Fringe"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/halfbang
	name = "Half-banged Hair"
	icon_state = "hair_halfbang"

/datum/sprite_accessory/hair/halfbangalt
	name = "Half-banged Hair Alt"
	icon_state = "hair_halfbang_alt"

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail male"
	icon_state = "hair_ponytailm"
	gender = MALE
	glasses_over = 1

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail female"
	icon_state = "hair_ponytailf"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail alt"
	icon_state = "hair_ponytail3"
	glasses_over = 1

/datum/sprite_accessory/hair/sideponytail
	name = "Side Ponytail"
	icon_state = "hair_stail"
	gender = FEMALE
	glasses_over = 1

/datum/sprite_accessory/hair/highponytail
	name = "High Ponytail"
	icon_state = "hair_highponytail"
	gender = FEMALE
	glasses_over = 1

/datum/sprite_accessory/hair/wisp
	name = "Wisp"
	icon_state = "hair_wisp"
	gender = FEMALE

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "hair_pompadour"
	gender = MALE
	species_allowed = list("Human", "Slime People", "Unathi")
	glasses_over = 1

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "hair_quiff"
	gender = MALE
	glasses_over = 1

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedheadv2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedheadv3"

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"
	gender = FEMALE
	species_allowed = list("Human", "Slime People", "Unathi")

/datum/sprite_accessory/hair/bobcurl
	name = "Bobcurl"
	icon_state = "hair_bobcurl"
	gender = FEMALE
	species_allowed = list("Human", "Slime People", "Unathi")

/datum/sprite_accessory/hair/bob
	name = "Bob"
	icon_state = "hair_bobcut"
	gender = FEMALE
	species_allowed = list("Human", "Slime People", "Unathi")

/datum/sprite_accessory/hair/bowl
	name = "Bowl"
	icon_state = "hair_bowlcut"
	gender = MALE
	glasses_over = 1

/datum/sprite_accessory/hair/braid2
	name = "Long Braid"
	icon_state = "hair_hbraid"
	gender = FEMALE

/datum/sprite_accessory/hair/braid_hip
	name = "Hippie Braid"
	icon_state = "hair_hipbraid"
	secondary_theme = "beads"

/datum/sprite_accessory/hair/braid_hip_una
	name = "Unathi Hippie Braid"
	icon_state = "hair_ubraid"
	species_allowed = list("Unathi")
	secondary_theme = "beads"

/datum/sprite_accessory/hair/buzz
	name = "Buzzcut"
	icon_state = "hair_buzzcut"
	gender = MALE
	species_allowed = list("Human", "Slime People", "Unathi")
	glasses_over = 1

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "hair_crewcut"
	gender = MALE
	glasses_over = 1

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "hair_combover"
	gender = MALE
	glasses_over = 1

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "hair_devilock"
	glasses_over = 1

/datum/sprite_accessory/hair/dreadlocks
	name = "Dreadlocks"
	icon_state = "hair_dreads"

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/afro2
	name = "Afro 2"
	icon_state = "hair_afro2"
	glasses_over = 1

/datum/sprite_accessory/hair/afro_large
	name = "Big Afro"
	icon_state = "hair_bigafro"
	gender = MALE

/datum/sprite_accessory/hair/sergeant
	name = "Flat Top"
	icon_state = "hair_sergeant"
	gender = MALE
	glasses_over = 1

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "hair_emo"

/datum/sprite_accessory/hair/fag
	name = "Flow Hair"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hair_hitop"
	gender = MALE
	glasses_over = 1

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "hair_d"
	species_allowed = list("Human", "Slime People", "Unathi")
	glasses_over = 1

/datum/sprite_accessory/hair/jensen
	name = "Adam Jensen Hair"
	icon_state = "hair_jensen"
	gender = MALE
	glasses_over = 1

/datum/sprite_accessory/hair/cia
	name = "CIA"
	icon_state = "hair_cia"
	gender = MALE
	glasses_over = 1

/datum/sprite_accessory/hair/mulder
	name = "Mulder"
	icon_state = "hair_mulder"
	gender = MALE
	glasses_over = 1

/datum/sprite_accessory/hair/gelled
	name = "Gelled Back"
	icon_state = "hair_gelled"
	gender = FEMALE
	glasses_over = 1

/datum/sprite_accessory/hair/gentle
	name = "Gentle"
	icon_state = "hair_gentle"
	gender = FEMALE

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "hair_spikey"
	species_allowed = list("Human", "Slime People", "Unathi")
	glasses_over = 1

/datum/sprite_accessory/hair/kusanagi
	name = "Kusanagi Hair"
	icon_state = "hair_kusanagi"

/datum/sprite_accessory/hair/kagami
	name = "Pigtails"
	icon_state = "hair_kagami"
	gender = FEMALE
	glasses_over = 1

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "hair_himecut"
	gender = FEMALE

/datum/sprite_accessory/hair/braid
	name = "Floorlength Braid"
	icon_state = "hair_braid"
	gender = FEMALE

/datum/sprite_accessory/hair/odango
	name = "Odango"
	icon_state = "hair_odango"
	gender = FEMALE
	glasses_over = 1

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "hair_ombre"
	gender = FEMALE

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "hair_updo"
	gender = FEMALE

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "hair_skinhead"
	glasses_over = 1

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "hair_e"
	gender = MALE // turnoff!
	glasses_over = 1

/datum/sprite_accessory/hair/longemo
	name = "Long Emo"
	icon_state = "hair_emolong"
	gender = FEMALE

//////////////////////////////
//////START VG HAIRSTYLES/////
//////////////////////////////
/datum/sprite_accessory/hair/birdnest
	name = "Bird Nest"
	icon_state = "hair_birdnest"

/datum/sprite_accessory/hair/unkept
	name = "Unkempt"
	icon_state = "hair_unkept"

/datum/sprite_accessory/hair/duelist
	name = "Duelist"
	icon_state = "hair_duelist"
	gender = MALE

/datum/sprite_accessory/hair/modern
	name = "Modern"
	icon_state = "hair_modern"
	gender = FEMALE

/datum/sprite_accessory/hair/unshavenmohawk
	name = "Unshaven Mohawk"
	icon_state = "hair_unshavenmohawk"
	gender = MALE
	glasses_over = 1

/datum/sprite_accessory/hair/drills
	name = "Twincurls"
	icon_state = "hair_twincurl"
	gender = FEMALE

/datum/sprite_accessory/hair/minidrills
	name = "Twincurls 2"
	icon_state = "hair_twincurl2"
	gender = FEMALE
//////////////////////////////
//////END VG HAIRSTYLES///////
//////////////////////////////

///////////////////////////////////
//////START POLARIS HAIRSTYLES/////
//////////////////////////////////

/datum/sprite_accessory/hair/dave
	name = "Dave"
	icon_state = "hair_dave"

/datum/sprite_accessory/hair/rosa
	name = "Rosa"
	icon_state = "hair_rosa"

/datum/sprite_accessory/hair/jade
	name = "Jade"
	icon_state = "hair_jade"

/datum/sprite_accessory/hair/shy
	name = "Shy"
	icon_state = "hair_shy"

/datum/sprite_accessory/hair/manbun
	name = "Manbun"
	icon_state = "hair_manbun"

/datum/sprite_accessory/hair/thinningback
	name = "Thinning Back"
	icon_state = "hair_thinningrear"

/datum/sprite_accessory/hair/thinningfront
	name = "Thinning Front"
	icon_state = "hair_thinningfront"

/datum/sprite_accessory/hair/thinning
	name = "Thinning"
	icon_state = "hair_thinning"

/datum/sprite_accessory/hair/bowlcut2
	name = "Bowl 2"
	icon_state = "hair_bowlcut2"

/datum/sprite_accessory/hair/ronin
	name = "Ronin"
	icon_state = "hair_ronin"

/datum/sprite_accessory/hair/topknot
	name = "Topknot"
	icon_state = "hair_topknot"

/datum/sprite_accessory/hair/regulationmohawk
	name = "Regulation Mohawk"
	icon_state = "hair_shavedmohawk"

/datum/sprite_accessory/hair/rowbraid
	name = "Row Braid"
	icon_state = "hair_rowbraid"

/datum/sprite_accessory/hair/rowdualbraid
	name = "Row Dual Braid"
	icon_state = "hair_rowdualtail"

/datum/sprite_accessory/hair/rowbun
	name = "Row Bun"
	icon_state = "hair_rowbun"

/datum/sprite_accessory/hair/hightight
	name = "High and Tight"
	icon_state = "hair_hightight"

/datum/sprite_accessory/hair/partfade
	name = "Parted Fade"
	icon_state = "hair_shavedpart"
	gender = MALE

/datum/sprite_accessory/hair/undercut3
	name = "Undercut Swept Left"
	icon_state = "hair_undercut3"
	gender = MALE

/datum/sprite_accessory/hair/undercut2
	name = "Undercut Swept Right"
	icon_state = "hair_undercut2"
	gender = MALE

/datum/sprite_accessory/hair/undercut1
	name = "Undercut"
	icon_state = "hair_undercut1"
	gender = MALE

/datum/sprite_accessory/hair/coffeehouse
	name = "Coffee House Cut"
	icon_state = "hair_coffeehouse"
	gender = MALE

/datum/sprite_accessory/hair/tightbun
	name = "Tight Bun"
	icon_state = "hair_tightbun"
	gender = FEMALE

/datum/sprite_accessory/hair/trimmed
	name = "Trimmed"
	icon_state = "hair_trimmed"
	gender = MALE

/datum/sprite_accessory/hair/trimflat
	name = "Trimmed Flat Top"
	icon_state = "hair_trimflat"
	gender = MALE

/datum/sprite_accessory/hair/nofade
	name = "Regulation Cut"
	icon_state = "hair_nofade"
	gender = MALE

/datum/sprite_accessory/hair/baldfade
	name = "Balding Fade"
	icon_state = "hair_baldfade"
	gender = MALE

/datum/sprite_accessory/hair/highfade
	name = "High Fade"
	icon_state = "hair_highfade"
	gender = MALE

/datum/sprite_accessory/hair/medfade
	name = "Medium Fade"
	icon_state = "hair_medfade"

/datum/sprite_accessory/hair/lowfade
	name = "Low Fade"
	icon_state = "hair_lowfade"
	gender = MALE

/datum/sprite_accessory/hair/oxton
	name = "Oxton"
	icon_state = "hair_oxton"

/datum/sprite_accessory/hair/doublebun
	name = "Double-Bun"
	icon_state = "hair_doublebun"

/datum/sprite_accessory/hair/halfshaved
	name = "Half-Shaved Emo"
	icon_state = "hair_halfshaved"

/datum/sprite_accessory/hair/shortbangs
	name = "Short Bangs"
	icon_state = "hair_shortbangs"

/datum/sprite_accessory/hair/longeralt2
	name = "Long Hair Alt 2"
	icon_state = "hair_longeralt2"

/datum/sprite_accessory/hair/nia
	name = "Nia"
	icon_state = "hair_nia"

/datum/sprite_accessory/hair/eighties
	name = "80's"
	icon_state = "hair_80s"

/datum/sprite_accessory/hair/volaju
	name = "Volaju"
	icon_state = "hair_volaju"

/datum/sprite_accessory/hair/joestar
	name = "Joestar"
	icon_state = "hair_joestar"
	gender = MALE

/datum/sprite_accessory/hair/nitori
	name = "Nitori"
	icon_state = "hair_nitori"

/datum/sprite_accessory/hair/scully
	name = "Scully"
	icon_state = "hair_scully"

/datum/sprite_accessory/hair/vegeta
	name = "Vegeta"
	icon_state = "hair_toriyama2"

/datum/sprite_accessory/hair/crono
	name = "Chrono"
	icon_state = "hair_toriyama"

/datum/sprite_accessory/hair/poofy2
	name = "Poofy2"
	icon_state = "hair_poofy2"

/datum/sprite_accessory/hair/poofy
	name = "Poofy"
	icon_state = "hair_poofy"

/datum/sprite_accessory/hair/dandypomp
	name = "Dandy Pompadour"
	icon_state = "hair_dandypompadour"

/datum/sprite_accessory/hair/fringetail
	name = "Fringetail"
	icon_state = "hair_fringetail"

/datum/sprite_accessory/hair/mahdrills
	name = "Drillruru"
	icon_state = "hair_drillruru"

/datum/sprite_accessory/hair/familyman
	name = "The Family Man"
	icon_state = "hair_thefamilyman"

/datum/sprite_accessory/hair/grandebraid
	name = "Grande Braid"
	icon_state = "hair_grande"

/datum/sprite_accessory/hair/fringeemo
	name = "Emo Fringe"
	icon_state = "hair_emofringe"

/datum/sprite_accessory/hair/emo2
	name = "Emo Alt"
	icon_state = "hair_emo2"

/datum/sprite_accessory/hair/sargeant
	name = "Flat Top"
	icon_state = "hair_sargeant"

/datum/sprite_accessory/hair/rows2
	name = "Rows 2"
	icon_state = "hair_rows2"

/datum/sprite_accessory/hair/rows
	name = "Rows"
	icon_state = "hair_rows1"

/datum/sprite_accessory/hair/reversemohawk
	name = "Reverse Mohawk"
	icon_state = "hair_reversemohawk"

/datum/sprite_accessory/hair/father
	name = "Father"
	icon_state = "hair_father"

/datum/sprite_accessory/hair/beehive2
	name = "Beehive 2"
	icon_state = "hair_beehive2"

/datum/sprite_accessory/hair/sleeze
	name = "Sleeze"
	icon_state = "hair_sleeze"

/datum/sprite_accessory/hair/zieglertail
	name = "Zieglertail"
	icon_state = "hair_ziegler"

/datum/sprite_accessory/hair/spikyponytail
	name = "Spiky Ponytail"
	icon_state = "hair_spikyponytail"

/datum/sprite_accessory/hair/tresshoulder
	name = "Tress Shoulder"
	icon_state = "hair_tressshoulder"

/datum/sprite_accessory/hair/oneshoulder
	name = "One Shoulder"
	icon_state = "hair_oneshoulder"

/datum/sprite_accessory/hair/ponytail6
	name = "Ponytail 6"
	icon_state = "hair_ponytail6"

/datum/sprite_accessory/hair/ponytail5
	name = "Ponytail 5"
	icon_state = "hair_ponytail5"

/datum/sprite_accessory/hair/ponytail4
	name = "Ponytail 4"
	icon_state = "hair_ponytail4"

/datum/sprite_accessory/hair/country
	name = "Country"
	icon_state = "hair_country"

/datum/sprite_accessory/hair/bedheadlong
	name = "Bedhead Long"
	icon_state = "hair_long_bedhead"

/datum/sprite_accessory/hair/flair
	name = "Flaired Hair"
	icon_state = "hair_flair"

/datum/sprite_accessory/hair/twintail
	name = "Twintail"
	icon_state = "hair_twintail"

/datum/sprite_accessory/hair/short2
	name = "Short Hair 2"
	icon_state = "hair_shorthair3"

/datum/sprite_accessory/hair/bun2
	name = "Bun 2"
	icon_state = "hair_bun2"

/datum/sprite_accessory/hair/bun3
	name = "Bun 3"
	icon_state = "hair_bun3"

/datum/sprite_accessory/hair/shavehair
	name = "Shaved Hair"
	icon_state = "hair_shaved"

/datum/sprite_accessory/hair/veryshortovereyealternate
	name = "Overeye Very Short, Alternate"
	icon_state = "hair_veryshortovereyealternate"

/datum/sprite_accessory/hair/veryshortovereye
	name = "Overeye Very Short"
	icon_state = "hair_veryshortovereye"

/datum/sprite_accessory/hair/shortovereye
	name = "Overeye Short"
	icon_state = "hair_shortovereye"

/datum/sprite_accessory/hair/longovereye
	name = "Overeye Long"
	icon_state = "hair_longovereye"

/datum/sprite_accessory/hair/father
	name = "Father"
	icon_state = "hair_father"

/datum/sprite_accessory/hair/bun4 // Due to a vulp hairstyle called bun
	name = "Bun 4"
	icon_state = "hair_bun4"

///////////////////////////////////
//////END POLARIS HAIRSTYLES///////
//////////////////////////////////

/datum/sprite_accessory/hair/ipc
	species_allowed = list("Machine")
	glasses_over = 1
	models_allowed = list("Bishop Cybernetics mtr.", "Hesphiastos Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/hair/ipc/ipc_screen_pink
	name = "Pink IPC Screen"
	icon_state = "ipc_pink"

/datum/sprite_accessory/hair/ipc/ipc_screen_red
	name = "Red IPC Screen"
	icon_state = "ipc_red"

/datum/sprite_accessory/hair/ipc/ipc_screen_green
	name = "Green IPC Screen"
	icon_state = "ipc_green"

/datum/sprite_accessory/hair/ipc/ipc_screen_blue
	name = "Blue IPC Screen"
	icon_state = "ipc_blue"

/datum/sprite_accessory/hair/ipc/ipc_screen_breakout
	name = "Breakout IPC Screen"
	icon_state = "ipc_breakout"

/datum/sprite_accessory/hair/ipc/ipc_screen_eight
	name = "Eight IPC Screen"
	icon_state = "ipc_eight"

/datum/sprite_accessory/hair/ipc/ipc_screen_rainbow
	name = "Rainbow IPC Screen"
	icon_state = "ipc_rainbow"

/datum/sprite_accessory/hair/ipc/ipc_screen_goggles
	name = "Goggles IPC Screen"
	icon_state = "ipc_goggles"

/datum/sprite_accessory/hair/ipc/ipc_screen_heart
	name = "Heart IPC Screen"
	icon_state = "ipc_heart"

/datum/sprite_accessory/hair/ipc/ipc_screen_monoeye
	name = "Monoeye IPC Screen"
	icon_state = "ipc_monoeye"

/datum/sprite_accessory/hair/ipc/ipc_screen_nature
	name = "Nature IPC Screen"
	icon_state = "ipc_nature"

/datum/sprite_accessory/hair/ipc/ipc_screen_orange
	name = "Orange IPC Screen"
	icon_state = "ipc_orange"

/datum/sprite_accessory/hair/ipc/ipc_screen_purple
	name = "Purple IPC Screen"
	icon_state = "ipc_purple"

/datum/sprite_accessory/hair/ipc/ipc_screen_shower
	name = "Shower IPC Screen"
	icon_state = "ipc_shower"

/datum/sprite_accessory/hair/ipc/ipc_screen_static
	name = "Static IPC Screen"
	icon_state = "ipc_static"

/datum/sprite_accessory/hair/ipc/ipc_screen_yellow
	name = "Yellow IPC Screen"
	icon_state = "ipc_yellow"

/datum/sprite_accessory/hair/ipc/ipc_screen_scrolling
	name = "Scanline IPC Screen"
	icon_state = "ipc_scroll"

/datum/sprite_accessory/hair/ipc/ipc_screen_console
	name = "Console IPC Screen"
	icon_state = "ipc_console"

/datum/sprite_accessory/hair/ipc/ipc_screen_rgb
	name = "RGB IPC Screen"
	icon_state = "ipc_rgb"

/datum/sprite_accessory/hair/ipc/ipc_screen_glider
	name = "Glider IPC Screen"
	icon_state = "ipc_gol_glider"

/datum/sprite_accessory/hair/ipc/hesphiastos_alt_off
	name = "Dark Hesphiastos Screen"
	icon_state = "hesphiastos_alt_off"
	models_allowed = list("Hesphiastos Industries alt.")

/datum/sprite_accessory/hair/ipc/hesphiastos_alt_pink
	name = "Pink Hesphiastos Screen"
	icon_state = "hesphiastos_alt_pink"
	models_allowed = list("Hesphiastos Industries alt.")

/datum/sprite_accessory/hair/ipc/hesphiastos_alt_orange
	name = "Orange Hesphiastos Screen"
	icon_state = "hesphiastos_alt_orange"
	models_allowed = list("Hesphiastos Industries alt.")

/datum/sprite_accessory/hair/ipc/hesphiastos_alt_goggle
	name = "Goggles Hesphiastos Screen"
	icon_state = "hesphiastos_alt_goggles"
	models_allowed = list("Hesphiastos Industries alt.")

/datum/sprite_accessory/hair/ipc/hesphiastos_alt_scroll
	name = "Scrolling Hesphiastos Screen"
	icon_state = "hesphiastos_alt_scroll"
	models_allowed = list("Hesphiastos Industries alt.")

/datum/sprite_accessory/hair/ipc/hesphiastos_alt_rgb
	name = "RGB Hesphiastos Screen"
	icon_state = "hesphiastos_alt_rgb"
	models_allowed = list("Hesphiastos Industries alt.")

/datum/sprite_accessory/hair/ipc/hesphiastos_alt_rainbow
	name = "Rainbow Hesphiastos Screen"
	icon_state = "hesphiastos_alt_rainbow"
	models_allowed = list("Hesphiastos Industries alt.")

/*
///////////////////////////////////
/  =---------------------------=  /
/  == Alien Style Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/hair/unathi
	species_allowed = list("Unathi")
	glasses_over = 1
	icon = 'icons/mob/body_accessory.dmi'

/datum/sprite_accessory/hair/unathi/una_side_frills
	icon = 'icons/mob/human_face.dmi'
	name = "Unathi Side Frills"
	icon_state = "unathi_sidefrills"
	secondary_theme = "webbing"

/datum/sprite_accessory/hair/unathi/una_cobra_hood
    icon = 'icons/mob/human_face.dmi'
    name = "Unathi Cobra Hood"
    icon_state = "unathi_cobrahood"
    secondary_theme = "webbing"

/datum/sprite_accessory/hair/unathi/una_frills_dorsal
	icon = 'icons/mob/human_face.dmi'
	name = "Dorsal Frills"
	icon_state = "unathi_dorsalfrills"
	secondary_theme = "webbing"

/datum/sprite_accessory/hair/unathi/simple
	name = "Simple Horns"
	icon_state = "horns_simple"

/datum/sprite_accessory/hair/unathi/short
	name = "Short Horns"
	icon_state = "horns_short"

/datum/sprite_accessory/hairy/unathi/curled
	name = "Curled Horns"
	icon_state = "horns_curled"

/datum/sprite_accessory/hair/unathi/ram
	name = "Ram Horns"
	icon_state = "horns_ram"

/datum/sprite_accessory/hair/unathi/double
	name = "Double Horns"
	icon_state = "horns_drac"

/datum/sprite_accessory/hair/unathi/lower
	name = "Lower Horns"
	icon_state = "horns_lower"

/datum/sprite_accessory/hair/unathi/big
	name = "Big"
	icon_state = "horns_big"

/datum/sprite_accessory/hair/unathi/ram2
	name = "Ram alt."
	icon_state = "horns_ram2"

/datum/sprite_accessory/hair/unathi/small
	name = "Small"
	icon_state = "horns_small"

/datum/sprite_accessory/hair/unathi/chin
	name = "Chin"
	icon_state = "horns_chin"

/datum/sprite_accessory/hair/unathi/adorns
	name = "Adorns"
	icon_state = "horns_adorns"

/datum/sprite_accessory/hair/unathi/spikes
	name = "Spikes"
	icon_state = "horns_spikes"

/datum/sprite_accessory/hair/skrell
	species_allowed = list("Skrell")

/datum/sprite_accessory/hair/skrell/skr_tentacle_m
	name = "Skrell Male Tentacles"
	icon_state = "skrell_hair_m"
	gender = MALE

/datum/sprite_accessory/hair/skrell/skr_tentacle_f
	name = "Skrell Female Tentacles"
	icon_state = "skrell_hair_f"
	gender = FEMALE

/datum/sprite_accessory/hair/skrell/skr_gold_m
	name = "Gold plated Skrell Male Tentacles"
	icon_state = "skrell_hair_m"
	gender = MALE
	secondary_theme = "gold"
	no_sec_colour = 1

/datum/sprite_accessory/hair/skrell/skr_gold_f
	name = "Gold chained Skrell Female Tentacles"
	icon_state = "skrell_hair_f"
	gender = FEMALE
	secondary_theme = "gold"
	no_sec_colour = 1

/datum/sprite_accessory/hair/skrell/skr_clothtentacle_m
	name = "Cloth draped Skrell Male Tentacles"
	icon_state = "skrell_hair_m"
	gender = MALE
	secondary_theme = "cloth"

/datum/sprite_accessory/hair/skrell/skr_clothtentacle_f
	name = "Cloth draped Skrell Female Tentacles"
	icon_state = "skrell_hair_f"
	gender = FEMALE
	secondary_theme = "cloth"

/datum/sprite_accessory/hair/tajara
	species_allowed = list("Tajaran")
	glasses_over = 1

/datum/sprite_accessory/hair/tajara/taj_hair_clean
	name = "Tajara Clean"
	icon_state = "hair_clean"

/datum/sprite_accessory/hair/tajara/taj_hair_bangs
	name = "Tajara Bangs"
	icon_state = "hair_bangs"
	glasses_over = null

/datum/sprite_accessory/hair/tajara/taj_hair_braid
	name = "Tajara Braid"
	icon_state = "hair_tbraid"
	secondary_theme = "beads"
	glasses_over = null

/datum/sprite_accessory/hair/tajara/taj_hair_shaggy
	name = "Tajara Shaggy"
	icon_state = "hair_shaggy"

/datum/sprite_accessory/hair/tajara/taj_hair_mohawk
	name = "Tajaran Mohawk"
	icon_state = "hair_mohawk"

/datum/sprite_accessory/hair/tajara/taj_hair_plait
	name = "Tajara Plait"
	icon_state = "hair_plait"

/datum/sprite_accessory/hair/tajara/taj_hair_straight
	name = "Tajara Straight"
	icon_state = "hair_straight"

/datum/sprite_accessory/hair/tajara/taj_hair_long
	name = "Tajara Long"
	icon_state = "hair_long"

/datum/sprite_accessory/hair/tajara/taj_hair_rattail
	name = "Tajara Rat Tail"
	icon_state = "hair_rattail"

/datum/sprite_accessory/hair/tajara/taj_hair_spiky
	name = "Tajara Spikey"
	icon_state = "hair_tajspikey"

/datum/sprite_accessory/hair/tajara/taj_hair_messy
	name = "Tajara Messy"
	icon_state = "hair_messy"

/datum/sprite_accessory/hair/tajara/taj_hair_curls
	name = "Tajara Curly"
	icon_state = "hair_curly"
	glasses_over = null

/datum/sprite_accessory/hair/tajara/taj_hair_retro
	name = "Tajaran Ladies' Retro"
	icon_state = "hair_ladies_retro"
	glasses_over = null

/datum/sprite_accessory/hair/tajara/taj_hair_victory
	name = "Tajara Victory Curls"
	icon_state = "hair_victory"
	glasses_over = null

/datum/sprite_accessory/hair/tajara/taj_hair_bob
	name = "Tajara Bob"
	icon_state = "hair_tbob"
	glasses_over = null

/datum/sprite_accessory/hair/tajara/taj_hair_fingercurl
	name = "Tajara Finger Curls"
	icon_state = "hair_fingerwave"
	glasses_over = null



/datum/sprite_accessory/hair/vulpkanin
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_kajam
	name = "Kajam"
	icon_state = "kajam"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_keid
	name = "Keid"
	icon_state = "keid"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_adhara
	name = "Adhara"
	icon_state = "adhara"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_kleeia
	name = "Kleeia"
	icon_state = "kleeia"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_mizar
	name = "Mizar"
	icon_state = "mizar"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_apollo
	name = "Apollo"
	icon_state = "apollo"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_belle
	name = "Belle"
	icon_state = "belle"
	secondary_theme = "bands"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_bun
	name = "Bun"
	icon_state = "bun"
	glasses_over = 1

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_jagged
	name = "Jagged"
	icon_state = "jagged"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_curl
	name = "Curl"
	icon_state = "curl"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_hawk
	name = "Hawk"
	icon_state = "hawk"
	glasses_over = 1

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_anita
	name = "Anita"
	icon_state = "anita"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_spike
	name = "Spike"
	icon_state = "spike"
	glasses_over = 1

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_braided
	name = "Braided"
	icon_state = "braided"
	secondary_theme = "beads"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_punkbraided
	name = "Punk Braided"
	icon_state = "punkbraided"
	secondary_theme = "flare"

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_short2
	name = "Short Alt."
	icon_state = "short2"
	glasses_over = 1

/datum/sprite_accessory/hair/vulpkanin/vulp_hair_rough
	name = "Rough-Cropped Mane"
	icon_state = "rough"

/datum/sprite_accessory/hair/vox
	species_allowed = list("Vox")
	glasses_over = 1

/datum/sprite_accessory/hair/vox/vox_quills_short
	name = "Short Vox Quills"
	icon_state = "vox_shortquills"

/datum/sprite_accessory/hair/vox/vox_crestedquills
	name = "Crested Vox Quills"
	icon_state = "vox_crestedquills"

/datum/sprite_accessory/hair/vox/vox_tielquills
	name = "Vox Tiel Quills"
	icon_state = "vox_tielquills"

/datum/sprite_accessory/hair/vox/vox_emperorquills
	name = "Vox Emperor Quills"
	icon_state = "vox_emperorquills"

/datum/sprite_accessory/hair/vox/vox_keelquills
	name = "Vox Keel Quills"
	icon_state = "vox_keelquills"

/datum/sprite_accessory/hair/vox/vox_keetquills
	name = "Vox Keet Quills"
	icon_state = "vox_keetquills"

/datum/sprite_accessory/hair/vox/vox_quills_kingly
	name = "Kingly Vox Quills"
	icon_state = "vox_kingly"

/datum/sprite_accessory/hair/vox/vox_quills_fluff
	name = "Fluffy Vox Quills"
	icon_state = "vox_afro"

/datum/sprite_accessory/hair/vox/vox_quills_mohawk
	name = "Vox Quill Mohawk"
	icon_state = "vox_mohawk"

/datum/sprite_accessory/hair/vox/vox_quills_long
	name = "Long Vox Quills"
	icon_state = "vox_yasu"

/datum/sprite_accessory/hair/vox/vox_horns
	name = "Vox Spikes"
	icon_state = "vox_horns"

/datum/sprite_accessory/hair/vox/vox_nights
	name = "Vox Pigtails"
	icon_state = "vox_nights"

/datum/sprite_accessory/hair/vox/vox_razor
	name = "Vox Razorback"
	icon_state = "vox_razor"

/datum/sprite_accessory/hair/vox/vox_razor_clipped
	name = "Clipped Vox Razorback"
	icon_state = "vox_razor_clipped"

// Apollo-specific

/datum/sprite_accessory/hair/wryn
	species_allowed = list("Wryn")
	glasses_over = 1

/datum/sprite_accessory/hair/wryn/wry_antennae_default
	name = "Antennae"
	icon_state = "wryn_antennae"

/datum/sprite_accessory/hair/nucleation
	species_allowed = list("Nucleation")
	glasses_over = 1

/datum/sprite_accessory/hair/nucleation/nuc_crystals
	name = "Nucleation Crystals"
	icon_state = "nuc_crystal"

/datum/sprite_accessory/hair/nucleation/nuc_betaburns
	name = "Nucleation Beta Burns"
	icon_state = "nuc_betaburns"

/datum/sprite_accessory/hair/nucleation/nuc_fallout
	name = "Nucleation Fallout"
	icon_state = "nuc_fallout"

/datum/sprite_accessory/hair/nucleation/nuc_frission
	name = "Nucleation Frission"
	icon_state = "nuc_frission"

/datum/sprite_accessory/hair/nucleation/nuc_radical
	name = "Nucleation Free Radical"
	icon_state = "nuc_radical"

/datum/sprite_accessory/hair/nucleation/nuc_gammaray
	name = "Nucleation Gamma Ray"
	icon_state = "nuc_gammaray"

/datum/sprite_accessory/hair/nucleation/nuc_neutron
	name = "Nucleation Neutron Bomb"
	icon_state = "nuc_neutron"



/datum/sprite_accessory/hair/fluff
	fluff = 1

/datum/sprite_accessory/hair/fluff/zeke_fluff_tentacle //Zeke Fluff hair
	name = "Zekes Tentacles"
	icon_state = "zeke_fluff_hair"
	species_allowed = list("Skrell")

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
	var/over_hair

/datum/sprite_accessory/facial_hair/shaved
	name = "Shaved"
	icon_state = "bald"
	gender = NEUTER
	species_allowed = list("Human", "Unathi", "Tajaran", "Skrell", "Vox", "Diona", "Kidan", "Greys", "Vulpkanin", "Slime People")

/datum/sprite_accessory/facial_hair/watson
	name = "Watson Mustache"
	icon_state = "facial_watson"

/datum/sprite_accessory/facial_hair/hogan
	name = "Hulk Hogan Mustache"
	icon_state = "facial_hogan" //-Neek

/datum/sprite_accessory/facial_hair/vandyke
	name = "Van Dyke Mustache"
	icon_state = "facial_vandyke"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Square Mustache"
	icon_state = "facial_chaplin"

/datum/sprite_accessory/facial_hair/selleck
	name = "Selleck Mustache"
	icon_state = "facial_selleck"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Neckbeard"
	icon_state = "facial_neckbeard"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Full Beard"
	icon_state = "facial_fullbeard"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Long Beard"
	icon_state = "facial_longbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Very Long Beard"
	icon_state = "facial_wise"

/datum/sprite_accessory/facial_hair/elvis
	name = "Elvis Sideburns"
	icon_state = "facial_elvis"
	species_allowed = list("Human", "Slime People", "Unathi")

/datum/sprite_accessory/facial_hair/abe
	name = "Abraham Lincoln Beard"
	icon_state = "facial_abe"

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Chinstrap"
	icon_state = "facial_chin"

/datum/sprite_accessory/facial_hair/hip
	name = "Hipster Beard"
	icon_state = "facial_hip"

/datum/sprite_accessory/facial_hair/gt
	name = "Goatee"
	icon_state = "facial_gt"

/datum/sprite_accessory/facial_hair/jensen
	name = "Adam Jensen Beard"
	icon_state = "facial_jensen"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Dwarf Beard"
	icon_state = "facial_dwarf"

//////////////////////////////
//////START VG HAIRSTYLES/////
//////////////////////////////
/datum/sprite_accessory/facial_hair/britstache
	name = "Brit Stache"
	icon_state = "facial_britstache"

/datum/sprite_accessory/facial_hair/martialartist
	name = "Martial Artist"
	icon_state = "facial_martialartist"

/datum/sprite_accessory/facial_hair/moonshiner
	name = "Moonshiner"
	icon_state = "facial_moonshiner"

/datum/sprite_accessory/facial_hair/tribeard
	name = "Tri-beard"
	icon_state = "facial_tribeard"

/datum/sprite_accessory/facial_hair/unshaven
	name = "Unshaven"
	icon_state = "facial_unshaven"
//////////////////////////////
//////END VG HAIRSTYLES///////
//////////////////////////////


/datum/sprite_accessory/facial_hair/tajara
	species_allowed = list("Tajaran")

/datum/sprite_accessory/facial_hair/tajara/taj_sideburns
	name = "Tajara Sideburns"
	icon_state = "facial_sideburns"

/datum/sprite_accessory/facial_hair/tajara/taj_mutton
	name = "Tajara Mutton"
	icon_state = "facial_mutton"

/datum/sprite_accessory/facial_hair/tajara/taj_pencilstache
	name = "Tajara Pencilstache"
	icon_state = "facial_pencilstache"

/datum/sprite_accessory/facial_hair/tajara/taj_moustache
	name = "Tajara Moustache"
	icon_state = "facial_moustache"

/datum/sprite_accessory/facial_hair/tajara/taj_goatee
	name = "Tajara Goatee"
	icon_state = "facial_goatee"

/datum/sprite_accessory/facial_hair/tajara/taj_goatee_faded
	name = "Tajara Faded Goatee"
	icon_state = "facial_goatee_faded"

/datum/sprite_accessory/facial_hair/tajara/taj_smallstache
	name = "Tajara Smallstache"
	icon_state = "facial_smallstache"

/datum/sprite_accessory/facial_hair/vox
	species_allowed = list("Vox")
	gender = NEUTER

/datum/sprite_accessory/facial_hair/vox/vox_colonel
	name = "Vox Colonel Beard"
	icon_state = "vox_colonel"

/datum/sprite_accessory/facial_hair/vox/vox_long
	name = "Long Mustache"
	icon_state = "vox_fu"

/datum/sprite_accessory/facial_hair/vox/vox_neck
	name = "Neck Quills"
	icon_state = "vox_neck"

/datum/sprite_accessory/facial_hair/vox/vox_beard
	name = "Vox Quill Beard"
	icon_state = "vox_beard"

/datum/sprite_accessory/facial_hair/vulpkanin
	species_allowed = list("Vulpkanin")
	gender = NEUTER

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_blaze
	name = "Blaze"
	icon_state = "vulp_facial_blaze"

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_vulpine
	name = "Vulpine"
	icon_state = "vulp_facial_vulpine"

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_vulpine_brows
	name = "Vulpine and Brows"
	icon_state = "vulp_facial_vulpine_brows"

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_vulpine_fluff
	name = "Vulpine and Earfluff"
	icon_state = "vulp_facial_vulpine_fluff"

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_mask
	name = "Mask"
	icon_state = "vulp_facial_mask"

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_patch
	name = "Patch"
	icon_state = "vulp_facial_patch"

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_ruff
	name = "Ruff"
	icon_state = "vulp_facial_ruff"

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_kita
	name = "Kita"
	icon_state = "vulp_facial_kita"

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_swift
	name = "Swift"
	icon_state = "vulp_facial_swift"

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_elder
	name = "Elder"
	icon_state = "vulp_facial_elder"
	secondary_theme = "chin"

/datum/sprite_accessory/facial_hair/vulpkanin/vulp_slash
	name = "Slash"
	icon_state = "vulp_facial_slash"

/datum/sprite_accessory/facial_hair/unathi
	species_allowed = list("Unathi")
	gender = NEUTER
	over_hair = 1

/datum/sprite_accessory/facial_hair/unathi/una_spines_long
	name = "Long Spines"
	icon_state = "unathi_longspines"

/datum/sprite_accessory/facial_hair/unathi/una_spines_short
	name = "Short Spines"
	icon_state = "unathi_shortspines"

/datum/sprite_accessory/facial_hair/unathi/una_frills_aquaspine
	name = "Spiny Aquatic Frills"
	icon_state = "unathi_dracfrills"

/datum/sprite_accessory/facial_hair/unathi/una_frills_aquatic
	name = "Aquatic Frills"
	icon_state = "unathi_aquaticfrills"

/datum/sprite_accessory/facial_hair/unathi/una_frills_long
	name = "Long Frills"
	icon_state = "unathi_longfrills"

/datum/sprite_accessory/facial_hair/unathi/una_frills_short
	name = "Short Frills"
	icon_state = "unathi_shortfrills"

/datum/sprite_accessory/facial_hair/unathi/una_frills_webbed_aquaspine
	name = "Spiny Aquatic Webbed Frills"
	icon_state = "unathi_dracfrills"
	secondary_theme = "webbing"

/datum/sprite_accessory/facial_hair/unathi/una_frills_webbed_aquatic
	name = "Aquatic Webbed Frills"
	icon_state = "unathi_aquaticfrills"
	secondary_theme = "webbing"

/datum/sprite_accessory/facial_hair/unathi/una_frills_webbed_long
	name = "Long Webbed Frills"
	icon_state = "unathi_longfrills"
	secondary_theme = "webbing"

/datum/sprite_accessory/facial_hair/unathi/una_frills_webbed_short
	name = "Short Webbed Frills"
	icon_state = "unathi_shortfrills"
	secondary_theme = "webbing"

/datum/sprite_accessory/facial_hair/unathi/una_side_frills
	name = "Side Frills"
	icon_state = "unathi_sidefrills"
	secondary_theme = "webbing"

/datum/sprite_accessory/facial_hair/unathi/una_frills_dorsal
	over_hair = null
	name = "Dorsal Frills"
	icon_state = "unathi_dorsalfrills"
	secondary_theme = "webbing"

/datum/sprite_accessory/facial_hair/unathi/una_chin_horns
	name = "Chin Horns"
	icon = 'icons/mob/body_accessory.dmi'
	icon_state = "horns_chin"

/datum/sprite_accessory/facial_hair/unathi/una_horn_adorns
	name = "Horn Adorns"
	icon = 'icons/mob/body_accessory.dmi'
	icon_state = "horns_adorns"

/datum/sprite_accessory/facial_hair/unathi/una_spikes
	name = "Spikes"
	icon = 'icons/mob/body_accessory.dmi'
	icon_state = "horns_spikes"

//skin styles - WIP
//going to have to re-integrate this with surgery
//let the icon_state hold an icon preview for now
/datum/sprite_accessory/skin
	icon = 'icons/mob/human_races/r_human.dmi'

/datum/sprite_accessory/skin/human
	name = "Default human skin"
	icon_state = "default"
	species_allowed = list("Human")

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

/datum/sprite_accessory/head_accessory/unathi
	species_allowed = list("Unathi")
	over_hair = 1

/datum/sprite_accessory/head_accessory/unathi/simple
	name = "Simple"
	icon_state = "horns_simple"

/datum/sprite_accessory/head_accessory/unathi/short
	name = "Short"
	icon_state = "horns_short"

/datum/sprite_accessory/head_accessory/unathi/curled
	name = "Curled"
	icon_state = "horns_curled"

/datum/sprite_accessory/head_accessory/unathi/ram
	name = "Ram"
	icon_state = "horns_ram"

/datum/sprite_accessory/head_accessory/unathi/double
	name = "Double"
	icon_state = "horns_drac"

/datum/sprite_accessory/head_accessory/unathi/lower
	name = "Lower"
	icon_state = "horns_lower"

/datum/sprite_accessory/head_accessory/unathi/big
	name = "Big"
	icon_state = "horns_big"

/datum/sprite_accessory/head_accessory/unathi/ram2
	name = "Ram alt."
	icon_state = "horns_ram2"

/datum/sprite_accessory/head_accessory/unathi/small
	name = "Small"
	icon_state = "horns_small"

/datum/sprite_accessory/head_accessory/unathi/chin
	name = "Chin"
	icon_state = "horns_chin"

/datum/sprite_accessory/head_accessory/unathi/adorns
	name = "Adorns"
	icon_state = "horns_adorns"

/datum/sprite_accessory/head_accessory/unathi/spikes
	name = "Spikes"
	icon_state = "horns_spikes"

/datum/sprite_accessory/head_accessory/tajara
	species_allowed = list("Tajaran")

/datum/sprite_accessory/head_accessory/tajara/outears_taj
	name = "Tajaran Outer Ears"
	icon_state = "markings_face_outears_taj"

/datum/sprite_accessory/head_accessory/tajara/inears_taj
	name = "Tajaran Inner Ears"
	icon_state = "markings_face_inears_taj"

/datum/sprite_accessory/head_accessory/tajara/muzzle_taj
	name = "Tajaran Muzzle"
	icon_state = "markings_face_muzzle_taj"

/datum/sprite_accessory/head_accessory/tajara/muzzle_and_inears_taj
	name = "Tajaran Muzzle and Inner Ears"
	icon_state = "markings_face_muzzle_and_inears_taj"

/datum/sprite_accessory/head_accessory/tajara/taj_ears
	icon = 'icons/mob/human_face.dmi'
	name = "Tajaran Ears"
	icon_state = "ears_plain"

/datum/sprite_accessory/head_accessory/tajara/taj_nose
	name = "Tajaran Nose"
	icon_state = "markings_face_nose_taj"

/datum/sprite_accessory/head_accessory/vulpkanin
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_earfluff
	icon = 'icons/mob/human_face.dmi'
	name = "Vulpkanin Earfluff"
	icon_state = "vulp_facial_earfluff"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_blaze
	icon = 'icons/mob/human_face.dmi'
	name = "Blaze"
	icon_state = "vulp_facial_blaze"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_vulpine
	icon = 'icons/mob/human_face.dmi'
	name = "Vulpine"
	icon_state = "vulp_facial_vulpine"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_vulpine_fluff
	icon = 'icons/mob/human_face.dmi'
	name = "Vulpine and Earfluff"
	icon_state = "vulp_facial_vulpine_fluff"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_mask
	icon = 'icons/mob/human_face.dmi'
	name = "Mask"
	icon_state = "vulp_facial_mask"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_patch
	icon = 'icons/mob/human_face.dmi'
	name = "Patch"
	icon_state = "vulp_facial_patch"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_ruff
	icon = 'icons/mob/human_face.dmi'
	name = "Ruff"
	icon_state = "vulp_facial_ruff"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_kita
	icon = 'icons/mob/human_face.dmi'
	name = "Kita"
	icon_state = "vulp_facial_kita"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_swift
	icon = 'icons/mob/human_face.dmi'
	name = "Swift"
	icon_state = "vulp_facial_swift"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_nose
	name = "Vulpkanin Nose"
	icon_state = "markings_face_nose_vulp"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_nose2
	name = "Vulpkanin Nose Alt."
	icon_state = "markings_face_nose2_vulp"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_elder
	icon = 'icons/mob/human_face.dmi'
	name = "Elder"
	icon_state = "vulp_facial_elder"

/datum/sprite_accessory/head_accessory/vulpkanin/vulp_slash
	icon = 'icons/mob/human_face.dmi'
	name = "Slash"
	icon_state = "vulp_facial_slash"

/datum/sprite_accessory/head_accessory/ipc
	species_allowed = list("Machine")
	over_hair = 1

/datum/sprite_accessory/head_accessory/ipc/ipc_antennae
	name = "Antennae"
	icon_state = "antennae"

/datum/sprite_accessory/head_accessory/ipc/ipc_tv_antennae
	name = "T.V. Antennae"
	icon_state = "tvantennae"

/datum/sprite_accessory/head_accessory/ipc/ipc_tesla_antennae
	name = "Tesla Antennae"
	icon_state = "tesla"

/datum/sprite_accessory/head_accessory/ipc/ipc_light
	name = "Head Light"
	icon_state = "light"

/datum/sprite_accessory/head_accessory/ipc/ipc_side_lights
	name = "Side Lights"
	icon_state = "sidelights"

/datum/sprite_accessory/head_accessory/ipc/ipc_side_cyber_head
	name = "Cyber Pipes"
	icon_state = "cyberhead"

/datum/sprite_accessory/head_accessory/ipc/ipc_side_antlers
	name = "Antlers"
	icon_state = "antlers"

/datum/sprite_accessory/head_accessory/ipc/ipc_side_drone_eyes
	name = "Drone Eyes"
	icon_state = "droneeyes"

/datum/sprite_accessory/head_accessory/ipc/ipc_crowned
	name = "Crowned"
	icon_state = "crowned"

/datum/sprite_accessory/head_accessory/kidan
	icon = 'icons/mob/human_face.dmi'
	species_allowed = list("Kidan")
	over_hair = 1
	do_colouration = 1

/datum/sprite_accessory/head_accessory/kidan/perked_antennae
	name = "Perked-up Antennae"
	icon_state = "kidan_perky"

/datum/sprite_accessory/head_accessory/kidan/mopey_antennae
	name = "Mopey Antennae"
	icon_state = "kidan_mopey"

/datum/sprite_accessory/head_accessory/kidan/curious_antennae
	name = "Curious Antennae"
	icon_state = "kidan_curious"

/datum/sprite_accessory/head_accessory/kidan/mopey_antennae
	name = "Mopey Antennae"
	icon_state = "kidan_mopey"

/datum/sprite_accessory/head_accessory/kidan/crescent_antennae
	name = "Crescent Antennae"
	icon_state = "kidan_crescent"

/datum/sprite_accessory/head_accessory/kidan/alert_antennae
	name = "Alert Antennae"
	icon_state = "kidan_alert"

/datum/sprite_accessory/head_accessory/kidan/normal_antennae
	name = "Normal Antennae"
	icon_state = "kidan_normal"

/datum/sprite_accessory/head_accessory/kidan/long_antennae
	name = "Long Antennae"
	icon_state = "kidan_long"

/datum/sprite_accessory/head_accessory/kidan/moth_antennae
	name = "Moth Antennae"
	icon_state = "kidan_moth"


/* BODY MARKINGS */

/datum/sprite_accessory/body_markings
	icon = 'icons/mob/body_accessory.dmi'
	species_allowed = list("Unathi", "Tajaran", "Vulpkanin", "Machine", "Vox", "Kidan")
	icon_state = "accessory_none"
	marking_location = "body"

/datum/sprite_accessory/body_markings/none
	name = "None"
	species_allowed = list("Human", "Unathi", "Diona", "Grey", "Machine", "Tajaran", "Vulpkanin", "Skrell", "Slime People", "Skeleton", "Vox", "Kidan")
	icon_state = "accessory_none"

/datum/sprite_accessory/body_markings/tiger
	name = "Tiger Body"
	species_allowed = list("Unathi", "Tajaran", "Vulpkanin")
	icon_state = "markings_tiger"

/datum/sprite_accessory/body_markings/kidan
	species_allowed = list("Kidan")

/datum/sprite_accessory/body_markings/kidan/outline_kid
	name = "Kidan Outline"
	icon_state = "markings_outline_kid"

/datum/sprite_accessory/body_markings/unathi
	species_allowed = list("Unathi")

/datum/sprite_accessory/body_markings/unathi/stripe_una
	name = "Unathi Stripe"
	icon_state = "markings_stripe_una"

/datum/sprite_accessory/body_markings/unathi/belly_narrow_una
	name = "Unathi Belly"
	icon_state = "markings_belly_narrow_una"

/datum/sprite_accessory/body_markings/unathi/banded_una
	name = "Unathi Banded"
	icon_state = "markings_banded_una"

/datum/sprite_accessory/body_markings/unathi/points_una
	name = "Unathi Points"
	icon_state = "markings_points_una"

/datum/sprite_accessory/body_markings/tajara
	species_allowed = list("Tajaran")

/datum/sprite_accessory/body_markings/tajara/belly_flat_taj
	name = "Tajaran Belly"
	icon_state = "markings_belly_flat_taj"

/datum/sprite_accessory/body_markings/tajara/belly_crest_taj
	name = "Tajaran Chest Crest"
	icon_state = "markings_belly_crest_taj"

/datum/sprite_accessory/body_markings/tajara/belly_full_taj
	name = "Tajaran Belly 2"
	icon_state = "markings_belly_full_taj"

/datum/sprite_accessory/body_markings/tajara/points_taj
	name = "Tajaran Points"
	icon_state = "markings_points_taj"

/datum/sprite_accessory/body_markings/tajara/patchy_taj
	name = "Tajaran Patches"
	icon_state = "markings_patch_taj"

/datum/sprite_accessory/body_markings/vulpkanin
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/body_markings/vulpkanin/belly_fox_vulp
	name = "Vulpkanin Belly"
	icon_state = "markings_belly_fox_vulp"

/datum/sprite_accessory/body_markings/vulpkanin/belly_full_vulp
	name = "Vulpkanin Belly 2"
	icon_state = "markings_belly_full_vulp"

/datum/sprite_accessory/body_markings/vulpkanin/belly_crest_vulp
	name = "Vulpkanin Belly Crest"
	icon_state = "markings_belly_crest_vulp"

/datum/sprite_accessory/body_markings/vulpkanin/points_fade_vulp
	name = "Vulpkanin Points"
	icon_state = "markings_points_fade_vulp"

/datum/sprite_accessory/body_markings/vulpkanin/points_fade_belly_vulp
	name = "Vulpkanin Points and Belly"
	icon_state = "markings_points_fade_belly_vulp"

/datum/sprite_accessory/body_markings/vulpkanin/points_fade_belly_alt_vulp
	name = "Vulpkanin Points and Belly Alt."
	icon_state = "markings_points_fade_belly_alt_vulp"

/datum/sprite_accessory/body_markings/vulpkanin/points_sharp_vulp
	name = "Vulpkanin Points 2"
	icon_state = "markings_points_sharp_vulp"

/datum/sprite_accessory/body_markings/vulpkanin/points_crest_vulp
	name = "Vulpkanin Points and Crest"
	icon_state = "markings_points_crest_vulp"

/datum/sprite_accessory/body_markings/drask
	species_allowed = list("Drask")

/datum/sprite_accessory/body_markings/drask/arm_spines_drask
	name = "Drask Arm Spines"
	icon_state = "markings_armspines_drask"

/datum/sprite_accessory/body_markings/head
	marking_location = "head"
	species_allowed = list()

/datum/sprite_accessory/body_markings/head/kidan
	species_allowed = list("Kidan")

/datum/sprite_accessory/body_markings/head/kidan/outline_head_kid
	name = "Kidan Outline Head"
	icon_state = "markings_head_outline_kid"

/datum/sprite_accessory/body_markings/head/tajara
	species_allowed = list("Tajaran")

/datum/sprite_accessory/body_markings/head/tajara/tiger_head_taj
	name = "Tajaran Tiger Head"
	icon_state = "markings_head_tiger_taj"

/datum/sprite_accessory/body_markings/head/tajara/tiger_face_taj
	name = "Tajaran Tiger Head and Face"
	icon_state = "markings_face_tiger_taj"

/datum/sprite_accessory/body_markings/head/tajara/outears_taj
	name = "Tajaran Outer Ears"
	icon_state = "markings_face_outears_taj"

/datum/sprite_accessory/body_markings/head/tajara/inears_taj
	name = "Tajaran Inner Ears"
	icon_state = "markings_face_inears_taj"

/datum/sprite_accessory/body_markings/head/tajara/nose_taj
	name = "Tajaran Nose"
	icon_state = "markings_face_nose_taj"

/datum/sprite_accessory/body_markings/head/tajara/muzzle_taj
	name = "Tajaran Muzzle"
	icon_state = "markings_face_muzzle_taj"

/datum/sprite_accessory/body_markings/head/tajara/muzzle_and_inears_taj
	name = "Tajaran Muzzle and Inner Ears"
	icon_state = "markings_face_muzzle_and_inears_taj"

/datum/sprite_accessory/body_markings/head/tajara/muzzle_alt_taj //Companion marking for Tajaran Belly 2.
	name = "Tajaran Muzzle 2"
	icon_state = "markings_face_full_taj"

/datum/sprite_accessory/body_markings/head/tajara/points_taj //Companion marking for Tajaran Points.
	name = "Tajaran Points Head"
	icon_state = "markings_face_points_taj"

/datum/sprite_accessory/body_markings/head/tajara/patchy_taj //Companion marking for Tajaran Patches.
	name = "Tajaran Patches Head"
	icon_state = "markings_face_patch_taj"

/datum/sprite_accessory/body_markings/head/vulpkanin
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/body_markings/head/vulpkanin/tiger_head_vulp
	name = "Vulpkanin Tiger Head"
	icon_state = "markings_head_tiger_vulp"

/datum/sprite_accessory/body_markings/head/vulpkanin/tiger_face_vulp
	name = "Vulpkanin Tiger Head and Face"
	icon_state = "markings_face_tiger_vulp"

/datum/sprite_accessory/body_markings/head/vulpkanin/nose_default_vulp
	name = "Vulpkanin Nose"
	icon_state = "markings_face_nose_vulp"

/datum/sprite_accessory/body_markings/head/vulpkanin/nose2_default_vulp
	name = "Vulpkanin Nose Alt."
	icon_state = "markings_face_nose2_vulp"

/datum/sprite_accessory/body_markings/head/vulpkanin/muzzle_vulp //Companion marking for Vulpkanin Belly Alt..
	name = "Vulpkanin Muzzle"
	icon_state = "markings_face_full_vulp"

/datum/sprite_accessory/body_markings/head/vulpkanin/muzzle_ears_vulp //Companion marking for Vulpkanin Belly Alt..
	name = "Vulpkanin Muzzle and Ears"
	icon_state = "markings_face_full_ears_vulp"

/datum/sprite_accessory/body_markings/head/vulpkanin/points_fade_vulp //Companion marking for Vulpkanin Points Fade.
	name = "Vulpkanin Points Head"
	icon_state = "markings_face_points_fade_vulp"

/datum/sprite_accessory/body_markings/head/vulpkanin/points_sharp_vulp //Companion marking for Vulpkanin Points Sharp.
	name = "Vulpkanin Points Head 2"
	icon_state = "markings_face_points_sharp_vulp"

/datum/sprite_accessory/body_markings/head/unathi
	species_allowed = list("Unathi")

/datum/sprite_accessory/body_markings/head/unathi/tiger_head_una
	name = "Unathi Tiger Head"
	icon_state = "markings_head_tiger_una"
	heads_allowed = list("All")

/datum/sprite_accessory/body_markings/head/unathi/tiger_face_una
	name = "Unathi Tiger Head and Face"
	icon_state = "markings_face_tiger_una"

/datum/sprite_accessory/body_markings/head/unathi/snout_una_round
	name = "Unathi Round Snout"
	icon_state = "markings_face_snout_una_round"

/datum/sprite_accessory/body_markings/head/unathi/snout_lower_una_round
	name = "Unathi Lower Round Snout"
	icon_state = "markings_face_snout_lower_una"
	heads_allowed = list("All")

/datum/sprite_accessory/body_markings/head/unathi/banded_una //Companion marking for Unathi Banded.
	name = "Unathi Banded Head"
	icon_state = "markings_face_banded_una"
	heads_allowed = list("All")

/datum/sprite_accessory/body_markings/head/unathi/snout_narrow_una //Companion marking for Unathi Narrow Belly.
	name = "Unathi Snout 2"
	icon_state = "markings_face_narrow_una"

/datum/sprite_accessory/body_markings/head/unathi/points_una //Companion marking for Unathi Points.
	name = "Unathi Points Head"
	icon_state = "markings_face_points_una"

/datum/sprite_accessory/body_markings/head/unathi/sharp
	heads_allowed = list("Unathi Sharp Snout")

/datum/sprite_accessory/body_markings/head/unathi/sharp/tiger_face_una_sharp
	name = "Unathi Sharp Tiger Head and Face"
	icon_state = "markings_face_tiger_una_sharp"

/datum/sprite_accessory/body_markings/head/unathi/sharp/snout_una_sharp
	name = "Unathi Sharp Snout"
	icon_state = "markings_face_snout_una_sharp"

/datum/sprite_accessory/body_markings/head/unathi/sharp/snout_narrow_una_sharp //Companion marking for Unathi Narrow Belly.
	name = "Unathi Sharp Snout 2"
	icon_state = "markings_face_narrow_una_sharp"

/datum/sprite_accessory/body_markings/head/unathi/sharp/points_una_sharp //Companion marking for Unathi Points.
	name = "Unathi Sharp Points Head"
	icon_state = "markings_face_points_una"

/datum/sprite_accessory/body_markings/head/optics
	name = "Humanoid Optics"
	species_allowed = list("Machine")
	icon_state = "optics"
	models_allowed = list("Bishop Cybernetics", "Hesphiastos Industries", "Ward-Takahashi", "Xion Manufacturing Group", "Zeng-Hu Pharmaceuticals") //Should be the same as the manufacturing company of the limb in robolimbs.dm

/datum/sprite_accessory/body_markings/head/optics/bishop_alt
	name = "Bishop Alt. Optics"
	icon_state = "bishop_alt_optics"
	models_allowed = list("Bishop Cybernetics alt.")

/datum/sprite_accessory/body_markings/head/optics/morpheus_alt
	name = "Morpheus Alt. Optics"
	icon_state = "morpheus_alt_optics"
	models_allowed = list("Morpheus Cyberkinetics alt.")

/datum/sprite_accessory/body_markings/head/optics/wardtakahashi_alt
	name = "Ward-Takahashi Alt. Optics"
	icon_state = "wardtakahashi_alt_optics"
	models_allowed = list("Ward-Takahashi alt.")

/datum/sprite_accessory/body_markings/head/optics/xion_alt
	name = "Xion Alt. Optics"
	icon_state = "xion_alt_optics"
	models_allowed = list("Xion Manufacturing Group alt.")

/datum/sprite_accessory/body_markings/tattoo // Tattoos applied post-round startup with tattoo guns in item_defines.dm
	species_allowed = list("Human", "Unathi", "Vulpkanin", "Tajaran", "Skrell")
	icon_state = "accessory_none"

/datum/sprite_accessory/body_markings/tattoo/elliot
	name = "Elliot Circuit Tattoo"
	icon_state = "campbell_tattoo"
	species_allowed = null

/datum/sprite_accessory/body_markings/tattoo/tiger_body
	name = "Tiger-stripe Tattoo"
	species_allowed = list("Human", "Unathi", "Vulpkanin", "Tajaran", "Skrell")
	icon_state = "markings_tiger"

/datum/sprite_accessory/body_markings/tattoo/heart
	name = "Heart Tattoo"
	icon_state = "markings_tattoo_heart"

/datum/sprite_accessory/body_markings/tattoo/hive
	name = "Hive Tattoo"
	icon_state = "markings_tattoo_hive"

/datum/sprite_accessory/body_markings/tattoo/nightling
	name = "Nightling Tattoo"
	icon_state = "markings_tattoo_nightling"

/datum/sprite_accessory/body_markings/tattoo/grey
	species_allowed = list("Grey")

/datum/sprite_accessory/body_markings/tattoo/grey/heart_grey
	name = "Grey Heart Tattoo"
	icon_state = "markings_tattoo_heart_grey"

/datum/sprite_accessory/body_markings/tattoo/grey/hive_grey
	name = "Grey Hive Tattoo"
	icon_state = "markings_tattoo_hive_grey"

/datum/sprite_accessory/body_markings/tattoo/grey/nightling_grey
	name = "Grey Nightling Tattoo"
	icon_state = "markings_tattoo_nightling_grey"

/datum/sprite_accessory/body_markings/tattoo/grey/tiger_body_grey
	name = "Grey Tiger-stripe Tattoo"
	icon_state = "markings_tattoo_tiger_grey"

/datum/sprite_accessory/body_markings/tattoo/vox
	species_allowed = list("Vox")

/datum/sprite_accessory/body_markings/tattoo/vox/heart_vox
	name = "Vox Heart Tattoo"
	icon_state = "markings_tattoo_heart_vox"

/datum/sprite_accessory/body_markings/tattoo/vox/hive_vox
	name = "Vox Hive Tattoo"
	icon_state = "markings_tattoo_hive_vox"

/datum/sprite_accessory/body_markings/tattoo/vox/nightling_vox
	name = "Vox Nightling Tattoo"
	icon_state = "markings_tattoo_nightling_vox"

/datum/sprite_accessory/body_markings/tattoo/vox/tiger_body_vox
	name = "Vox Tiger-stripe Tattoo"
	icon_state = "markings_tattoo_tiger_vox"

/datum/sprite_accessory/body_markings/tail
	species_allowed = list()
	icon_state = "accessory_none"
	marking_location = "tail"
	tails_allowed = null

/datum/sprite_accessory/body_markings/tail/vox
	species_allowed = list("Vox")

/datum/sprite_accessory/body_markings/tail/vox/vox_band
	name = "Vox Tail Band"
	icon_state = "markings_voxtail_band"

/datum/sprite_accessory/body_markings/tail/vox/vox_tip
	name = "Vox Tail Tip"
	icon_state = "markings_voxtail_tip"

/datum/sprite_accessory/body_markings/tail/vox/vox_stripe
	name = "Vox Tail Stripe"
	icon_state = "markings_voxtail_stripe"

/datum/sprite_accessory/body_markings/tail/vulpkanin
	species_allowed = list("Vulpkanin")

/datum/sprite_accessory/body_markings/tail/vulpkanin/vulp_default_tip
	name = "Vulpkanin Default Tail Tip"
	icon_state = "markings_vulptail_tip"

/datum/sprite_accessory/body_markings/tail/vulpkanin/vulp_default_fade
	name = "Vulpkanin Default Tail Fade"
	icon_state = "markings_vulptail_fade"

/datum/sprite_accessory/body_markings/tail/vulpkanin/vulp_bushy_fluff
	name = "Vulpkanin Bushy Tail Fluff"
	tails_allowed = list("Vulpkanin Alt 1 (Bushy)")
	icon_state = "markings_vulptail2_fluff"

/datum/sprite_accessory/body_markings/tail/vulpkanin/vulp_short_tip
	name = "Vulpkanin Short Tail Tip"
	tails_allowed = list("Vulpkanin Alt 4 (Short)")
	icon_state = "markings_vulptail5_tip"

/datum/sprite_accessory/body_markings/tail/vulpkanin/vulp_hybrid_tip
	name = "Vulpkanin Bushy Straight Tail Tip"
	tails_allowed = list("Vulpkanin Alt 5 (Straight Bushy)")
	icon_state = "markings_vulptail6_tip"

/datum/sprite_accessory/body_markings/tail/vulpkanin/vulp_hybrid_fade
	name = "Vulpkanin Bushy Straight Tail Fade"
	tails_allowed = list("Vulpkanin Alt 5 (Straight Bushy)")
	icon_state = "markings_vulptail6_fade"

/datum/sprite_accessory/body_markings/tail/vulpkanin/vulp_hybrid_silverf
	name = "Vulpkanin Bushy Straight Tail Black Fade White Tip"
	tails_allowed = list("Vulpkanin Alt 5 (Straight Bushy)")
	icon_state = "markings_vulptail6_silverf"

/* ALT HEADS */

/datum/sprite_accessory/alt_heads
	icon = null
	icon_state = null
	species_allowed = null
	var/suffix = null

/datum/sprite_accessory/alt_heads/none
	name = "None"

/datum/sprite_accessory/alt_heads/una_sharp_snout
	name = "Unathi Sharp Snout"
	species_allowed = list("Unathi")
	icon_state = "head_sharp"
	suffix = "sharp"
