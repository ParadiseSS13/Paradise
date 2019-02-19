var/list/preferences_datums = list()

var/global/list/special_role_times = list( //minimum age (in days) for accounts to play these roles
	ROLE_PAI = 0,
	ROLE_POSIBRAIN = 0,
	ROLE_GUARDIAN = 0,
	ROLE_TRAITOR = 7,
	ROLE_CHANGELING = 14,
	ROLE_SHADOWLING = 14,
	ROLE_WIZARD = 14,
	ROLE_REV = 14,
	ROLE_VAMPIRE = 14,
	ROLE_BLOB = 14,
	ROLE_REVENANT = 14,
	ROLE_OPERATIVE = 21,
	ROLE_CULTIST = 21,
	ROLE_RAIDER = 21,
	ROLE_ALIEN = 21,
	ROLE_DEMON = 21,
	ROLE_SENTIENT = 21,
// 	ROLE_GANG = 21,
	ROLE_BORER = 21,
	ROLE_NINJA = 21,
	ROLE_GSPIDER = 21,
	ROLE_ABDUCTOR = 30,
	ROLE_DEVIL = 14
)

/proc/player_old_enough_antag(client/C, role)
	if(available_in_days_antag(C, role))
		return 0	//available_in_days>0 = still some days required = player not old enough
	if(role_available_in_playtime(C, role))
		return 0	//available_in_playtime>0 = still some more playtime required = they are not eligible
	return 1

/proc/available_in_days_antag(client/C, role)
	if(!C)
		return 0
	if(!role)
		return 0
	if(!config.use_age_restriction_for_antags)
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	var/minimal_player_age_antag = special_role_times[num2text(role)]
	if(!isnum(minimal_player_age_antag))
		return 0

	return max(0, minimal_player_age_antag - C.player_age)

/proc/check_client_age(client/C, var/days) // If days isn't provided, returns the age of the client. If it is provided, it returns the days until the player_age is equal to or greater than the days variable
	if(!days)
		return C.player_age
	else
		return max(0, days - C.player_age)
	return 0

#define MAX_SAVE_SLOTS 20 // Save slots for regular players
#define MAX_SAVE_SLOTS_MEMBER 20 // Save slots for BYOND members

#define TAB_CHAR 0
#define TAB_GAME 1
#define TAB_GEAR 2

/datum/preferences
	var/client/parent
	//doohickeys for savefiles
//	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
//	var/savefile_version = 0
	var/max_save_slots = MAX_SAVE_SLOTS
	var/max_gear_slots = 0

	//non-preference stuff
	var/warns = 0
	var/muted = 0
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/exp
	var/ooccolor = "#b82e00"
	var/be_special = list()				//Special role selection
	var/UI_style = "Midnight"
	var/nanoui_fancy = TRUE
	var/toggles = TOGGLES_DEFAULT
	var/sound = SOUND_DEFAULT
	var/show_ghostitem_attack = TRUE
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255
	var/windowflashing = TRUE
	var/clientfps = 0
	var/atklog = ATKLOG_ALL

	//ghostly preferences
	var/ghost_anonsay = 0

	//character preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we are a random name every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/spawnpoint = "Arrivals Shuttle" //where this character will spawn (0-2).
	var/b_type = "A+"					//blood type (not-chooseable)
	var/underwear = "Nude"					//underwear type
	var/undershirt = "Nude"					//undershirt type
	var/socks = "Nude"					//socks type
	var/backbag = GBACKPACK				//backpack type
	var/ha_style = "None"				//Head accessory style
	var/hacc_colour = "#000000"			//Head accessory colour
	var/list/m_styles = list(
		"head" = "None",
		"body" = "None",
		"tail" = "None"
		)			//Marking styles.
	var/list/m_colours = list(
		"head" = "#000000",
		"body" = "#000000",
		"tail" = "#000000"
		)		//Marking colours.
	var/h_style = "Bald"				//Hair type
	var/h_colour = "#000000"			//Hair color
	var/h_sec_colour = "#000000"		//Secondary hair color
	var/f_style = "Shaved"				//Facial hair type
	var/f_colour = "#000000"			//Facial hair color
	var/f_sec_colour = "#000000"		//Secondary facial hair color
	var/s_tone = 0						//Skin tone
	var/s_colour = "#000000"			//Skin color
	var/e_colour = "#000000"			//Eye color
	var/alt_head = "None"				//Alt head style.
	var/species = "Human"
	var/language = "None"				//Secondary language
	var/autohiss_mode = AUTOHISS_OFF	//Species autohiss level. OFF, BASIC, FULL.

	var/body_accessory = null

	var/speciesprefs = 0//I hate having to do this, I really do (Using this for oldvox code, making names universal I guess

		//Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null

		//Jobs, uses bitflags
	var/job_support_high = 0
	var/job_support_med = 0
	var/job_support_low = 0

	var/job_medsci_high = 0
	var/job_medsci_med = 0
	var/job_medsci_low = 0

	var/job_engsec_high = 0
	var/job_engsec_med = 0
	var/job_engsec_low = 0

	var/job_karma_high = 0
	var/job_karma_med = 0
	var/job_karma_low = 0

	//Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = 2

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()
	var/list/rlimb_data = list()

	var/list/player_alt_titles = new()		// the default name of a job like "Medical Doctor"
//	var/accent = "en-us"
//	var/voice = "m1"
//	var/pitch = 50
//	var/talkspeed = 175
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/disabilities = 0

	var/nanotrasen_relation = "Neutral"

	// 0 = character settings, 1 = game preferences
	var/current_tab = TAB_CHAR

		// OOC Metadata:
	var/metadata = ""
	var/slot_name = ""

	// Whether or not to use randomized character slots
	var/randomslot = 0

	// jukebox volume
	var/volume = 100

	// BYOND membership
	var/unlock_content = 0

	//Gear stuff
	var/list/gear = list()
	var/gear_tab = "General"

/datum/preferences/New(client/C)
	parent = C
	b_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

	max_gear_slots = config.max_loadout_points
	var/loaded_preferences_successfully = FALSE
	if(istype(C))
		if(!IsGuestKey(C.key))
			unlock_content = C.IsByondMember()
			if(unlock_content)
				max_save_slots = MAX_SAVE_SLOTS_MEMBER
			if(C.donator_level >= DONATOR_LEVEL_ONE)
				max_gear_slots += 5

		loaded_preferences_successfully = load_preferences(C) // Do not call this with no client/C, it generates a runtime / SQL error
		if(loaded_preferences_successfully)
			if(load_character(C))
				return
	//we couldn't load character data so just randomize the character appearance + name
	random_character()		//let's create a random character then - rather than a fat, bald and naked man.
	real_name = random_name(gender)
	if(istype(C))
		if(!loaded_preferences_successfully)
			save_preferences(C) // Do not call this with no client/C, it generates a runtime / SQL error
		save_character(C)		// Do not call this with no client/C, it generates a runtime / SQL error

/datum/preferences/proc/color_square(colour)
	return "<span style='font-face: fixedsys; background-color: [colour]; color: [colour]'>___</span>"

// Hello I am a proc full of snowflake species checks how are you
/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return
	update_preview_icon()
	user << browse_rsc(preview_icon_front, "previewicon.png")
	user << browse_rsc(preview_icon_side, "previewicon2.png")

	var/dat = ""
	dat += "<center>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=[TAB_CHAR]' [current_tab == TAB_CHAR ? "class='linkOn'" : ""]>Character Settings</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=[TAB_GAME]' [current_tab == TAB_GAME ? "class='linkOn'" : ""]>Game Preferences</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=[TAB_GEAR]' [current_tab == TAB_GEAR ? "class='linkOn'" : ""]>Loadout</a>"
	dat += "</center>"
	dat += "<HR>"

	switch(current_tab)
		if(TAB_CHAR) // Character Settings
			var/datum/species/S = GLOB.all_species[species]
			if(!istype(S)) //The species was invalid. Set the species to the default, fetch the datum for that species and generate a random character.
				species = initial(species)
				S = GLOB.all_species[species]
				random_character()

			dat += "<div class='statusDisplay' style='max-width: 128px; position: absolute; left: 150px; top: 150px'><img src=previewicon.png class='charPreview'><img src=previewicon2.png class='charPreview'></div>"
			dat += "<table width='100%'><tr><td width='405px' height='25px' valign='top'>"
			dat += "<b>Name: </b>"
			dat += "<a href='?_src_=prefs;preference=name;task=input'><b>[real_name]</b></a>"
			dat += "<a href='?_src_=prefs;preference=name;task=random'>(Randomize)</a>"
			dat += "<a href='?_src_=prefs;preference=name'><span class='[be_random_name ? "good" : "bad"]'>(Always Randomize)</span></a><br>"
			dat += "</td><td width='405px' height='25px' valign='left'>"
			dat += "<center>"
			dat += "Slot <b>[slot_name]</b> - "
			dat += "<a href=\"byond://?_src_=prefs;preference=open_load_dialog\">Load slot</a> - "
			dat += "<a href=\"byond://?_src_=prefs;preference=save\">Save slot</a> - "
			dat += "<a href=\"byond://?_src_=prefs;preference=reload\">Reload slot</a>"
			dat += "</center>"
			dat += "</td></tr></table>"
			dat += "<table width='100%'><tr><td width='405px' height='200px' valign='top'>"
			dat += "<h2>Identity</h2>"
			if(appearance_isbanned(user))
				dat += "<b>You are banned from using custom names and appearances. \
				You can continue to adjust your characters, but you will be randomised once you join the game.\
				</b><br>"
			dat += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender'>[gender == MALE ? "Male" : (gender == FEMALE ? "Female" : "Genderless")]</a>"
			dat += "<br>"
			dat += "<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[age]</a><br>"
			dat += "<b>Body:</b> <a href='?_src_=prefs;preference=all;task=random'>(&reg;)</a><br>"
			dat += "<b>Species:</b> <a href='?_src_=prefs;preference=species;task=input'>[species]</a><br>"
			if(species == "Vox")
				dat += "<b>N2 Tank:</b> <a href='?_src_=prefs;preference=speciesprefs;task=input'>[speciesprefs ? "Large N2 Tank" : "Specialized N2 Tank"]</a><br>"
			if(species == "Grey")
				dat += "<b>Wingdings:</b> Set in disabilities<br>"
				dat += "<b>Voice Translator:</b> <a href ='?_src_=prefs;preference=speciesprefs;task=input'>[speciesprefs ? "Yes" : "No"]</a><br>"
			dat += "<b>Secondary Language:</b> <a href='?_src_=prefs;preference=language;task=input'>[language]</a><br>"
			if(S.autohiss_basic_map)
				dat += "<b>Auto-accent:</b> <a href='?_src_=prefs;preference=autohiss_mode;task=input'>[autohiss_mode == AUTOHISS_FULL ? "Full" : (autohiss_mode == AUTOHISS_BASIC ? "Basic" : "Off")]</a><br>"
			dat += "<b>Blood Type:</b> <a href='?_src_=prefs;preference=b_type;task=input'>[b_type]</a><br>"
			if(S.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
				dat += "<b>Skin Tone:</b> <a href='?_src_=prefs;preference=s_tone;task=input'>[S.bodyflags & HAS_ICON_SKIN_TONE ? "[s_tone]" : "[-s_tone + 35]/220"]</a><br>"
			dat += "<b>Disabilities:</b> <a href='?_src_=prefs;preference=disabilities'>\[Set\]</a><br>"
			dat += "<b>Nanotrasen Relation:</b> <a href ='?_src_=prefs;preference=nt_relation;task=input'>[nanotrasen_relation]</a><br>"
			dat += "<a href='byond://?_src_=prefs;preference=flavor_text;task=input'>Set Flavor Text</a><br>"
			if(lentext(flavor_text) <= 40)
				if(!lentext(flavor_text))	dat += "\[...\]<br>"
				else						dat += "[flavor_text]<br>"
			else dat += "[TextPreview(flavor_text)]...<br>"

			dat += "<h2>Hair & Accessories</h2>"

			if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
				var/headaccessoryname = "Head Accessory: "
				if(species == "Unathi")
					headaccessoryname = "Horns: "
				dat += "<b>[headaccessoryname]</b>"
				dat += "<a href='?_src_=prefs;preference=ha_style;task=input'>[ha_style]</a> "
				dat += "<a href='?_src_=prefs;preference=headaccessory;task=input'>Color</a> [color_square(hacc_colour)]<br>"

			if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
				dat += "<b>Head Markings:</b> "
				dat += "<a href='?_src_=prefs;preference=m_style_head;task=input'>[m_styles["head"]]</a>"
				dat += "<a href='?_src_=prefs;preference=m_head_colour;task=input'>Color</a> [color_square(m_colours["head"])]<br>"
			if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
				dat += "<b>Body Markings:</b> "
				dat += "<a href='?_src_=prefs;preference=m_style_body;task=input'>[m_styles["body"]]</a>"
				dat += "<a href='?_src_=prefs;preference=m_body_colour;task=input'>Color</a> [color_square(m_colours["body"])]<br>"
			if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
				dat += "<b>Tail Markings:</b> "
				dat += "<a href='?_src_=prefs;preference=m_style_tail;task=input'>[m_styles["tail"]]</a>"
				dat += "<a href='?_src_=prefs;preference=m_tail_colour;task=input'>Color</a> [color_square(m_colours["tail"])]<br>"

			dat += "<b>Hair:</b> "
			dat += "<a href='?_src_=prefs;preference=h_style;task=input'>[h_style]</a>"
			dat += "<a href='?_src_=prefs;preference=hair;task=input'>Color</a> [color_square(h_colour)]"
			var/datum/sprite_accessory/temp_hair_style = GLOB.hair_styles_public_list[h_style]
			if(temp_hair_style && temp_hair_style.secondary_theme && !temp_hair_style.no_sec_colour)
				dat += " <a href='?_src_=prefs;preference=secondary_hair;task=input'>Color #2</a> [color_square(h_sec_colour)]"
			dat += "<br>"

			dat += "<b>Facial Hair:</b> "
			dat += "<a href='?_src_=prefs;preference=f_style;task=input'>[f_style ? "[f_style]" : "Shaved"]</a>"
			dat += "<a href='?_src_=prefs;preference=facial;task=input'>Color</a> [color_square(f_colour)]"
			var/datum/sprite_accessory/temp_facial_hair_style = GLOB.facial_hair_styles_list[f_style]
			if(temp_facial_hair_style && temp_facial_hair_style.secondary_theme && !temp_facial_hair_style.no_sec_colour)
				dat += " <a href='?_src_=prefs;preference=secondary_facial;task=input'>Color #2</a> [color_square(f_sec_colour)]"
			dat += "<br>"


			if(!(S.bodyflags & ALL_RPARTS))
				dat += "<b>Eyes:</b> "
				dat += "<a href='?_src_=prefs;preference=eyes;task=input'>Color</a> [color_square(e_colour)]<br>"

			if((S.bodyflags & HAS_SKIN_COLOR) || body_accessory_by_species[species] || check_rights(R_ADMIN, 0, user)) //admins can always fuck with this, because they are admins
				dat += "<b>Body Color:</b> "
				dat += "<a href='?_src_=prefs;preference=skin;task=input'>Color</a> [color_square(s_colour)]<br>"

			if(body_accessory_by_species[species] || check_rights(R_ADMIN, 0, user))
				dat += "<b>Body Accessory:</b> "
				dat += "<a href='?_src_=prefs;preference=body_accessory;task=input'>[body_accessory ? "[body_accessory]" : "None"]</a><br>"

			dat += "</td><td width='405px' height='200px' valign='top'>"
			dat += "<h2>Occupation Choices</h2>"
			dat += "<a href='?_src_=prefs;preference=job;task=menu'>Set Occupation Preferences</a><br>"
			if(jobban_isbanned(user, "Records"))
				dat += "<b>You are banned from using character records.</b><br>"
			else
				dat += "<a href=\"byond://?_src_=prefs;preference=records;record=1\">Character Records</a><br>"

			dat += "<h2>Limbs</h2>"
			if(S.bodyflags & HAS_ALT_HEADS) //Species with alt heads.
				dat += "<b>Alternate Head:</b> "
				dat += "<a href='?_src_=prefs;preference=alt_head;task=input'>[alt_head]</a><br>"
			dat += "<b>Limbs and Parts:</b> <a href='?_src_=prefs;preference=limbs;task=input'>Adjust</a><br>"
			if(species != "Slime People" && species != "Machine")
				dat += "<b>Internal Organs:</b> <a href='?_src_=prefs;preference=organs;task=input'>Adjust</a><br>"

			//display limbs below
			var/ind = 0
			for(var/name in organ_data)
				var/status = organ_data[name]
				var/organ_name = null
				switch(name)
					if("chest")
						organ_name = "torso"
					if("groin")
						organ_name = "lower body"
					if("head")
						organ_name = "head"
					if("l_arm")
						organ_name = "left arm"
					if("r_arm")
						organ_name = "right arm"
					if("l_leg")
						organ_name = "left leg"
					if("r_leg")
						organ_name = "right leg"
					if("l_foot")
						organ_name = "left foot"
					if("r_foot")
						organ_name = "right foot"
					if("l_hand")
						organ_name = "left hand"
					if("r_hand")
						organ_name = "right hand"
					if("eyes")
						organ_name = "eyes"
					if("heart")
						organ_name = "heart"
					if("lungs")
						organ_name = "lungs"
					if("liver")
						organ_name = "liver"
					if("kidneys")
						organ_name = "kidneys"

				if(status in list("cyborg", "amputated", "cybernetic"))
					++ind
					if(ind > 1) dat += ", "

				switch(status)
					if("cyborg")
						var/datum/robolimb/R
						if(rlimb_data[name] && all_robolimbs[rlimb_data[name]])
							R = all_robolimbs[rlimb_data[name]]
						else
							R = basic_robolimb
						dat += "\t[R.company] [organ_name] prosthesis"
					if("amputated")
						dat += "\tAmputated [organ_name]"
					if("cybernetic")
						dat += "\tCybernetic [organ_name]"
			if(!ind)	dat += "\[...\]<br>"
			else		dat += "<br>"

			dat += "<h2>Clothing</h2>"
			if(S.clothing_flags & HAS_UNDERWEAR)
				dat += "<b>Underwear:</b> <a href ='?_src_=prefs;preference=underwear;task=input'>[underwear]</a><BR>"
			if(S.clothing_flags & HAS_UNDERSHIRT)
				dat += "<b>Undershirt:</b> <a href ='?_src_=prefs;preference=undershirt;task=input'>[undershirt]</a><BR>"
			if(S.clothing_flags & HAS_SOCKS)
				dat += "<b>Socks:</b> <a href ='?_src_=prefs;preference=socks;task=input'>[socks]</a><BR>"
			dat += "<b>Backpack Type:</b> <a href ='?_src_=prefs;preference=bag;task=input'>[backbag]</a><br>"

			dat += "</td></tr></table>"

		if(TAB_GAME) // General Preferences
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
			dat += "<h2>General Settings</h2>"
			dat += "<b>Fancy NanoUI:</b> <a href='?_src_=prefs;preference=nanoui'>[(nanoui_fancy) ? "Yes" : "No"]</a><br>"
			dat += "<b>Ghost-Item Attack Animation:</b> <a href='?_src_=prefs;preference=ghost_att_anim'>[(show_ghostitem_attack) ? "Yes" : "No"]</a><br>"
			dat += "<b>Window Flashing:</b> <a href='?_src_=prefs;preference=winflash'>[(windowflashing) ? "Yes" : "No"]</a><br>"
			dat += "<b>Custom UI settings:</b><br>"
			dat += " - <b>UI Style:</b> <a href='?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>"
			dat += " - <b>Color:</b> <a href='?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b></a> <table style='display:inline;' bgcolor='[UI_style_color]'<tr><td>__</td></tr></table><br>"
			dat += " - <b>Alpha (transparency):</b> <a href='?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a><br>"
			dat += "<br>"
			dat += "<b>Play admin midis:</b> <a href='?_src_=prefs;preference=hear_midis'><b>[(sound & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Play lobby music:</b> <a href='?_src_=prefs;preference=lobby_music'><b>[(sound & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>"
			if(user.client.holder)
				dat += "<b>Adminhelp sound:</b> "
				dat += "<a href='?_src_=prefs;preference=hear_adminhelps'><b>[(sound & SOUND_ADMINHELP)?"On":"Off"]</b></a><br>"

			if(check_rights(R_ADMIN,0))
				dat += "<b>OOC:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ooccolor;task=input'><b>Change</b></a><br>"
			if(config.allow_Metadata)
				dat += "<b>OOC notes:</b> <a href='?_src_=prefs;preference=metadata;task=input'><b>Edit</b></a><br>"
			if(unlock_content)
				dat += "<b>BYOND Membership Publicity:</b> <a href='?_src_=prefs;preference=publicity'><b>[(toggles & MEMBER_PUBLIC) ? "Public" : "Hidden"]</b></a><br>"
			if(user.client.donator_level >= DONATOR_LEVEL_ONE)
				dat += "<b>Donator Publicity:</b> <a href='?_src_=prefs;preference=donor_public'><b>[(toggles & DONATOR_PUBLIC) ? "Public" : "Hidden"]</b></a><br>"

			dat += "<b>Randomized character slot:</b> <a href='?_src_=prefs;preference=randomslot'><b>[randomslot ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Ghost ears:</b> <a href='?_src_=prefs;preference=ghost_ears'><b>[(toggles & CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</b></a><br>"
			dat += "<b>Ghost sight:</b> <a href='?_src_=prefs;preference=ghost_sight'><b>[(toggles & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</b></a><br>"
			dat += "<b>Ghost radio:</b> <a href='?_src_=prefs;preference=ghost_radio'><b>[(toggles & CHAT_GHOSTRADIO) ? "All Chatter" : "Nearest Speakers"]</b></a><br>"
			dat += "<b>Deadchat anonymity:</b> <a href='?_src_=prefs;preference=ghost_anonsay'><b>[ghost_anonsay ? "Anonymous" : "Not Anonymous"]</b></a><br>"
			dat += "<b>FPS:</b> <a href='?_src_=prefs;preference=clientfps;task=input'>[clientfps]</a><br>"
			dat += "</td><td width='300px' height='300px' valign='top'>"
			dat += "<h2>Special Role Settings</h2>"
			if(jobban_isbanned(user, "Syndicate"))
				dat += "<b>You are banned from special roles.</b>"
				be_special = list()
			else
				for(var/i in special_roles)
					if(jobban_isbanned(user, i))
						dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[BANNED]</b></font><br>"
					else if(!player_old_enough_antag(user.client, i))
						var/available_in_days_antag = available_in_days_antag(user.client, i)
						var/role_available_in_playtime = get_exp_format(role_available_in_playtime(user.client, i))
						if(available_in_days_antag)
							dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[IN [(available_in_days_antag)] DAYS]</b></font><br>"
						else if(role_available_in_playtime)
							dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[IN [(role_available_in_playtime)]]</b></font><br>"
						else
							dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[ERROR]</b></font><br>"
					else
						dat += "<b>Be [capitalize(i)]:</b> <a href='?_src_=prefs;preference=be_special;role=[i]'><b>[(i in src.be_special) ? "Yes" : "No"]</b></a><br>"
			dat += "</td></tr></table>"

		if(TAB_GEAR)
			var/total_cost = 0
			var/list/type_blacklist = list()
			if(gear && gear.len)
				for(var/i = 1, i <= gear.len, i++)
					var/datum/gear/G = gear_datums[gear[i]]
					if(G)
						if(!G.subtype_cost_overlap)
							if(G.subtype_path in type_blacklist)
								continue
							type_blacklist += G.subtype_path
						total_cost += G.cost

			var/fcolor =  "#3366CC"
			if(total_cost < max_gear_slots)
				fcolor = "#E67300"
			dat += "<table align='center' width='100%'>"
			dat += "<tr><td colspan=4><center><b><font color='[fcolor]'>[total_cost]/[max_gear_slots]</font> loadout points spent.</b> \[<a href='?_src_=prefs;preference=gear;clear_loadout=1'>Clear Loadout</a>\]</center></td></tr>"
			dat += "<tr><td colspan=4><center><b>"

			var/firstcat = 1
			for(var/category in loadout_categories)
				var/datum/loadout_category/LC = loadout_categories[category]
				if(LC.donor_only)
					if(user.client.donator_level < DONATOR_LEVEL_TWO) // level two donators get the donator loadout, so don't show it to anyone with less than that
						continue
				if(firstcat)
					firstcat = 0
				else
					dat += " |"
				if(category == gear_tab)
					dat += " <span class='linkOff'>[category]</span> "
				else
					dat += " <a href='?_src_=prefs;preference=gear;select_category=[category]'>[category]</a> "
			dat += "</b></center></td></tr>"

			var/datum/loadout_category/LC = loadout_categories[gear_tab]
			dat += "<tr><td colspan=4><hr></td></tr>"
			dat += "<tr><td colspan=4><b><center>[LC.category]</center></b></td></tr>"
			dat += "<tr><td colspan=4><hr></td></tr>"
			for(var/gear_name in LC.gear)
				var/datum/gear/G = LC.gear[gear_name]
				var/ticked = (G.display_name in gear)
				dat += "<tr style='vertical-align:top;'><td width=15%><a style='white-space:normal;' [ticked ? "class='linkOn' " : ""]href='?_src_=prefs;preference=gear;toggle_gear=[G.display_name]'>[G.display_name]</a></td>"
				dat += "<td width = 5% style='vertical-align:top'>[G.cost]</td><td>"
				if(G.allowed_roles)
					dat += "<font size=2>Restrictions: "
					for(var/role in G.allowed_roles)
						dat += role + " "
					dat += "</font>"
				dat += "</td><td><font size=2><i>[G.description]</i></font></td></tr>"
				if(ticked)
					. += "<tr><td colspan=4>"
					for(var/datum/gear_tweak/tweak in G.gear_tweaks)
						. += " <a href='?_src_=prefs;preference=gear;gear=[G.display_name];tweak=\ref[tweak]'>[tweak.get_contents(get_tweak_metadata(G, tweak))]</a>"
					. += "</td></tr>"
			dat += "</table>"

	dat += "<hr><center>"
	if(!IsGuestKey(user.key))
		dat += "<a href='?_src_=prefs;preference=load'>Undo</a> - "
		dat += "<a href='?_src_=prefs;preference=save'>Save Setup</a> - "

	dat += "<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center>"

	var/datum/browser/popup = new(user, "preferences", "<div align='center'>Character Setup</div>", 820, 640)
	popup.set_content(dat)
	popup.open(0)


/datum/preferences/proc/get_gear_metadata(var/datum/gear/G)
	. = gear[G.display_name]
	if(!.)
		. = list()
		gear[G.display_name] = .

/datum/preferences/proc/get_tweak_metadata(var/datum/gear/G, var/datum/gear_tweak/tweak)
	var/list/metadata = get_gear_metadata(G)
	. = metadata["[tweak]"]
	if(!.)
		. = tweak.get_default()
		metadata["[tweak]"] = .

/datum/preferences/proc/set_tweak_metadata(var/datum/gear/G, var/datum/gear_tweak/tweak, var/new_metadata)
	var/list/metadata = get_gear_metadata(G)
	metadata["[tweak]"] = new_metadata


/datum/preferences/proc/SetChoices(mob/user, limit = 13, list/splitJobs = list("Civilian","Research Director","AI","Bartender"), width = 760, height = 790)
	if(!job_master)
		return

	//limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//width	 - Screen' width. Defaults to 550 to make it look nice.
	//height 	 - Screen's height. Defaults to 500 to make it look nice.


	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Choose occupation chances</b><br>Unavailable occupations are crossed out.<br><br>"
	HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>\[Done\]</a></center><br>" // Easier to press up here.
	HTML += "<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br></div>"
	HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
	var/index = -1

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob
	if(!job_master)		return
	for(var/datum/job/job in job_master.occupations)

		if(job.admin_only)
			continue

		index += 1
		if((index >= limit) || (job.title in splitJobs))
			if((index < limit) && (lastJob != null))
				//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
				//the last job's selection color. Creating a rather nice effect.
				for(var/i = 0, i < (limit - index), i += 1)
					HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
			HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
		var/rank = job.title
		lastJob = job
		if(!is_job_whitelisted(user, rank))
			HTML += "<font color=red>[rank]</font></td><td><font color=red><b> \[KARMA]</b></font></td></tr>"
			continue
		if(jobban_isbanned(user, rank))
			HTML += "<del>[rank]</del></td><td><b> \[BANNED]</b></td></tr>"
			continue
		var/available_in_playtime = job.available_in_playtime(user.client)
		if(available_in_playtime)
			HTML += "<del>[rank]</del></td><td> \[ " + get_exp_format(available_in_playtime) + " as " + job.get_exp_req_type()  + " \]</td></tr>"
			continue
		if(job.barred_by_disability(user.client))
			HTML += "<del>[rank]</del></td><td> \[ DISABILITY \]</td></tr>"
			continue
		if(!job.player_old_enough(user.client))
			var/available_in_days = job.available_in_days(user.client)
			HTML += "<del>[rank]</del></td><td> \[IN [(available_in_days)] DAYS]</td></tr>"
			continue
		if((job_support_low & CIVILIAN) && (rank != "Civilian"))
			HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
			continue
		if((rank in command_positions) || (rank == "AI"))//Bold head jobs
			HTML += "<b><span class='dark'>[rank]</span></b>"
		else
			HTML += "<span class='dark'>[rank]</span>"

		HTML += "</td><td width='40%'>"

		var/prefLevelLabel = "ERROR"
		var/prefLevelColor = "pink"
		var/prefUpperLevel = -1 // level to assign on left click
		var/prefLowerLevel = -1 // level to assign on right click

		if(GetJobDepartment(job, 1) & job.flag)
			prefLevelLabel = "High"
			prefLevelColor = "slateblue"
			prefUpperLevel = 4
			prefLowerLevel = 2
		else if(GetJobDepartment(job, 2) & job.flag)
			prefLevelLabel = "Medium"
			prefLevelColor = "green"
			prefUpperLevel = 1
			prefLowerLevel = 3
		else if(GetJobDepartment(job, 3) & job.flag)
			prefLevelLabel = "Low"
			prefLevelColor = "orange"
			prefUpperLevel = 2
			prefLowerLevel = 4
		else
			prefLevelLabel = "NEVER"
			prefLevelColor = "red"
			prefUpperLevel = 3
			prefLowerLevel = 1


		HTML += "<a class='white' href='?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"

//			HTML += "<a href='?_src_=prefs;preference=job;task=input;text=[rank]'>"

		if(rank == "Civilian")//Civilian is special
			if(job_support_low & CIVILIAN)
				HTML += " <font color=green>\[Yes]</font></a>"
			else
				HTML += " <font color=red>\[No]</font></a>"
			if(job.alt_titles)
				HTML += "<br><b><a class='white' href=\"byond://?_src_=prefs;preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></b></td></tr>"
			HTML += "</td></tr>"
			continue
/*
		if(GetJobDepartment(job, 1) & job.flag)
			HTML += " <font color=blue>\[High]</font>"
		else if(GetJobDepartment(job, 2) & job.flag)
			HTML += " <font color=green>\[Medium]</font>"
		else if(GetJobDepartment(job, 3) & job.flag)
			HTML += " <font color=orange>\[Low]</font>"
		else
			HTML += " <font color=red>\[NEVER]</font>"
			*/
		HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font></a>"

		if(job.alt_titles)
			HTML += "<br><b><a class='white' href=\"?_src_=prefs;preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></b></td></tr>"


		HTML += "</td></tr>"

	for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
		HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

	HTML += "</td'></tr></table>"

	HTML += "</center></table>"

	switch(alternate_option)
		if(GET_RANDOM_JOB)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=white>Get random job if preferences unavailable</font></a></u></center><br>"
		if(BE_ASSISTANT)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=white>Be a civilian if preferences unavailable</font></a></u></center><br>"
		if(RETURN_TO_LOBBY)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=white>Return to lobby if preferences unavailable</font></a></u></center><br>"

	HTML += "<center><a href='?_src_=prefs;preference=job;task=reset'>\[Reset\]</a></center>"
	HTML += "</tt>"

	user << browse(null, "window=preferences")
//		user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_window_options("can_close=0")
	popup.set_content(HTML)
	popup.open(0)
	return

/datum/preferences/proc/SetJobPreferenceLevel(var/datum/job/job, var/level)
	if(!job)
		return 0

	if(level == 1) // to high
		// remove any other job(s) set to high
		job_support_med |= job_support_high
		job_engsec_med |= job_engsec_high
		job_medsci_med |= job_medsci_high
		job_karma_med |= job_karma_high
		job_support_high = 0
		job_engsec_high = 0
		job_medsci_high = 0
		job_karma_high = 0

	if(job.department_flag == SUPPORT)
		job_support_low &= ~job.flag
		job_support_med &= ~job.flag
		job_support_high &= ~job.flag

		switch(level)
			if(1)
				job_support_high |= job.flag
			if(2)
				job_support_med |= job.flag
			if(3)
				job_support_low |= job.flag

		return 1
	else if(job.department_flag == ENGSEC)
		job_engsec_low &= ~job.flag
		job_engsec_med &= ~job.flag
		job_engsec_high &= ~job.flag

		switch(level)
			if(1)
				job_engsec_high |= job.flag
			if(2)
				job_engsec_med |= job.flag
			if(3)
				job_engsec_low |= job.flag

		return 1
	else if(job.department_flag == MEDSCI)
		job_medsci_low &= ~job.flag
		job_medsci_med &= ~job.flag
		job_medsci_high &= ~job.flag

		switch(level)
			if(1)
				job_medsci_high |= job.flag
			if(2)
				job_medsci_med |= job.flag
			if(3)
				job_medsci_low |= job.flag

		return 1
	else if(job.department_flag == KARMA)
		job_karma_low &= ~job.flag
		job_karma_med &= ~job.flag
		job_karma_high &= ~job.flag

		switch(level)
			if(1)
				job_karma_high |= job.flag
			if(2)
				job_karma_med |= job.flag
			if(3)
				job_karma_low |= job.flag

		return 1

	return 0

/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	var/datum/job/job = job_master.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if(!isnum(desiredLvl))
		to_chat(user, "<span class='warning'>UpdateJobPreference - desired level was not a number. Please notify coders!</span>")
		ShowChoices(user)
		return

	if(role == "Civilian")
		if(job_support_low & job.flag)
			job_support_low &= ~job.flag
		else
			job_support_low |= job.flag
		SetChoices(user)
		return 1

	SetJobPreferenceLevel(job, desiredLvl)
	SetChoices(user)

	return 1

/datum/preferences/proc/ShowDisabilityState(mob/user, flag, label)
	var/datum/species/S = GLOB.all_species[species]
	if(flag == DISABILITY_FLAG_FAT && !(CAN_BE_FAT in S.species_traits))
		return "<li><i>[species] cannot be fat.</i></li>"
	return "<li><b>[label]:</b> <a href=\"?_src_=prefs;task=input;preference=disabilities;disability=[flag]\">[disabilities & flag ? "Yes" : "No"]</a></li>"

/datum/preferences/proc/SetDisabilities(mob/user)
	var/datum/species/S = GLOB.all_species[species]
	var/HTML = "<body>"
	HTML += "<tt><center>"

	if(CAN_WINGDINGS in S.species_traits)
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_WINGDINGS, "Speak in Wingdings")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_NEARSIGHTED, "Nearsighted")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_COLOURBLIND, "Colourblind")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_BLIND, "Blind")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_DEAF, "Deaf")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_MUTE, "Mute")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_FAT, "Obese")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_NERVOUS, "Stutter")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_SWEDISH, "Swedish accent")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_CHAV, "Chav accent")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_LISP, "Lisp")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_DIZZY, "Dizziness")


	HTML += {"</ul>
		<a href=\"?_src_=prefs;task=close;preference=disabilities\">\[Done\]</a>
		<a href=\"?_src_=prefs;task=reset;preference=disabilities\">\[Reset\]</a>
		</center></tt>"}

	var/datum/browser/popup = new(user, "disabil", "<div align='center'>Choose Disabilities</div>", 350, 380)
	popup.set_content(HTML)
	popup.open(0)

/datum/preferences/proc/SetRecords(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"

	HTML += "<a href=\"byond://?_src_=prefs;preference=records;task=med_record\">Medical Records</a><br>"

	if(lentext(med_record) <= 40)
		HTML += "[med_record]"
	else
		HTML += "[copytext(med_record, 1, 37)]..."

	HTML += "<br><a href=\"byond://?_src_=prefs;preference=records;task=gen_record\">Employment Records</a><br>"

	if(lentext(gen_record) <= 40)
		HTML += "[gen_record]"
	else
		HTML += "[copytext(gen_record, 1, 37)]..."

	HTML += "<br><a href=\"byond://?_src_=prefs;preference=records;task=sec_record\">Security Records</a><br>"

	if(lentext(sec_record) <= 40)
		HTML += "[sec_record]<br>"
	else
		HTML += "[copytext(sec_record, 1, 37)]...<br>"

	HTML += "<a href=\"byond://?_src_=prefs;preference=records;records=-1\">\[Done\]</a>"
	HTML += "</center></tt>"

	var/datum/browser/popup = new(user, "records", "<div align='center'>Character Records</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(0)

/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	return player_alt_titles.Find(job.title) > 0 \
		? player_alt_titles[job.title] \
		: job.title

/datum/preferences/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/preferences/proc/SetJob(mob/user, role)
	var/datum/job/job = job_master.GetJob(role)
	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if(role == "Civilian")
		if(job_support_low & job.flag)
			job_support_low &= ~job.flag
		else
			job_support_low |= job.flag
		SetChoices(user)
		return 1

	if(GetJobDepartment(job, 1) & job.flag)
		SetJobDepartment(job, 1)
	else if(GetJobDepartment(job, 2) & job.flag)
		SetJobDepartment(job, 2)
	else if(GetJobDepartment(job, 3) & job.flag)
		SetJobDepartment(job, 3)
	else//job = Never
		SetJobDepartment(job, 4)

	SetChoices(user)
	return 1

/datum/preferences/proc/ResetJobs()
	job_support_high = 0
	job_support_med = 0
	job_support_low = 0

	job_medsci_high = 0
	job_medsci_med = 0
	job_medsci_low = 0

	job_engsec_high = 0
	job_engsec_med = 0
	job_engsec_low = 0

	job_karma_high = 0
	job_karma_med = 0
	job_karma_low = 0


/datum/preferences/proc/GetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(job.department_flag)
		if(SUPPORT)
			switch(level)
				if(1)
					return job_support_high
				if(2)
					return job_support_med
				if(3)
					return job_support_low
		if(MEDSCI)
			switch(level)
				if(1)
					return job_medsci_high
				if(2)
					return job_medsci_med
				if(3)
					return job_medsci_low
		if(ENGSEC)
			switch(level)
				if(1)
					return job_engsec_high
				if(2)
					return job_engsec_med
				if(3)
					return job_engsec_low
		if(KARMA)
			switch(level)
				if(1)
					return job_karma_high
				if(2)
					return job_karma_med
				if(3)
					return job_karma_low
	return 0

/datum/preferences/proc/SetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(level)
		if(1)//Only one of these should ever be active at once so clear them all here
			job_support_high = 0
			job_medsci_high = 0
			job_engsec_high = 0
			job_karma_high = 0
			return 1
		if(2)//Set current highs to med, then reset them
			job_support_med |= job_support_high
			job_medsci_med |= job_medsci_high
			job_engsec_med |= job_engsec_high
			job_karma_med |= job_karma_high
			job_support_high = 0
			job_medsci_high = 0
			job_engsec_high = 0
			job_karma_high = 0

	switch(job.department_flag)
		if(SUPPORT)
			switch(level)
				if(2)
					job_support_high = job.flag
					job_support_med &= ~job.flag
				if(3)
					job_support_med |= job.flag
					job_support_low &= ~job.flag
				else
					job_support_low |= job.flag
		if(MEDSCI)
			switch(level)
				if(2)
					job_medsci_high = job.flag
					job_medsci_med &= ~job.flag
				if(3)
					job_medsci_med |= job.flag
					job_medsci_low &= ~job.flag
				else
					job_medsci_low |= job.flag
		if(ENGSEC)
			switch(level)
				if(2)
					job_engsec_high = job.flag
					job_engsec_med &= ~job.flag
				if(3)
					job_engsec_med |= job.flag
					job_engsec_low &= ~job.flag
				else
					job_engsec_low |= job.flag
		if(KARMA)
			switch(level)
				if(2)
					job_karma_high = job.flag
					job_karma_med &= ~job.flag
				if(3)
					job_karma_med |= job.flag
					job_karma_low &= ~job.flag
				else
					job_karma_low |= job.flag
	return 1

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!user)	return

	var/datum/species/S = GLOB.all_species[species]
	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("random")
				if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_ASSISTANT)
					alternate_option += 1
				else if(alternate_option == RETURN_TO_LOBBY)
					alternate_option = 0
				else
					return 0
				SetChoices(user)
			if("alt_title")
				var/datum/job/job = locate(href_list["job"])
				if(job)
					var/choices = list(job.title) + job.alt_titles
					var/choice = input("Pick a title for [job.title].", "Character Generation", GetPlayerAltTitle(job)) as anything in choices | null
					if(choice)
						SetPlayerAltTitle(job, choice)
						SetChoices(user)
			if("input")
				SetJob(user, href_list["text"])
			if("setJobLevel")
				UpdateJobPreference(user, href_list["text"], text2num(href_list["level"]))
			else
				SetChoices(user)
		return 1
	else if(href_list["preference"] == "disabilities")

		switch(href_list["task"])
			if("close")
				user << browse(null, "window=disabil")
				ShowChoices(user)
			if("reset")
				disabilities=0
				SetDisabilities(user)
			if("input")
				var/dflag=text2num(href_list["disability"])
				if(dflag >= 0)
					if(!(dflag==DISABILITY_FLAG_FAT && !(CAN_BE_FAT in S.species_traits))) //If the disability isn't fatness, toggle it. If it IS fatness, check to see if the species can be fat before going ahead.
						disabilities ^= text2num(href_list["disability"]) //MAGIC
				SetDisabilities(user)
			else
				SetDisabilities(user)
		return 1

	else if(href_list["preference"] == "records")
		if(text2num(href_list["record"]) >= 1)
			SetRecords(user)
			return
		else
			user << browse(null, "window=records")
		if(href_list["task"] == "med_record")
			var/medmsg = input(usr,"Set your medical notes here.","Medical Records",html_decode(med_record)) as message

			if(medmsg != null)
				medmsg = copytext(medmsg, 1, MAX_PAPER_MESSAGE_LEN)
				medmsg = html_encode(medmsg)

				med_record = medmsg
				SetRecords(user)

		if(href_list["task"] == "sec_record")
			var/secmsg = input(usr,"Set your security notes here.","Security Records",html_decode(sec_record)) as message

			if(secmsg != null)
				secmsg = copytext(secmsg, 1, MAX_PAPER_MESSAGE_LEN)
				secmsg = html_encode(secmsg)

				sec_record = secmsg
				SetRecords(user)
		if(href_list["task"] == "gen_record")
			var/genmsg = input(usr,"Set your employment notes here.","Employment Records",html_decode(gen_record)) as message

			if(genmsg != null)
				genmsg = copytext(genmsg, 1, MAX_PAPER_MESSAGE_LEN)
				genmsg = html_encode(genmsg)

				gen_record = genmsg
				SetRecords(user)

	if(href_list["preference"] == "gear")
		if(href_list["toggle_gear"])
			var/datum/gear/TG = gear_datums[href_list["toggle_gear"]]
			if(TG.display_name in gear)
				gear -= TG.display_name
			else
				if(TG.donor_only)
					if(user.client.donator_level < DONATOR_LEVEL_TWO) // donator items are locked to > tier 2
						//they normally can't even get this far- but just in case of href exploits, we check them here
						return
				var/total_cost = 0
				var/list/type_blacklist = list()
				for(var/gear_name in gear)
					var/datum/gear/G = gear_datums[gear_name]
					if(istype(G))
						if(!G.subtype_cost_overlap)
							if(G.subtype_path in type_blacklist)
								continue
							type_blacklist += G.subtype_path
						total_cost += G.cost

				if((total_cost + TG.cost) <= max_gear_slots)
					gear += TG.display_name

		else if(href_list["gear"] && href_list["tweak"])
			var/datum/gear/gear = gear_datums[href_list["gear"]]
			var/datum/gear_tweak/tweak = locate(href_list["tweak"])
			if(!tweak || !istype(gear) || !(tweak in gear.gear_tweaks))
				return
			var/metadata = tweak.get_metadata(user, get_tweak_metadata(gear, tweak))
			if(!metadata || !CanUseTopic(user))
				return
			set_tweak_metadata(gear, tweak, metadata)
		else if(href_list["select_category"])
			gear_tab = href_list["select_category"]
		else if(href_list["clear_loadout"])
			gear.Cut()

		ShowChoices(user)
		return

	switch(href_list["task"])
		if("random")
			var/datum/robolimb/robohead
			if(S.bodyflags & ALL_RPARTS)
				var/head_model = "[!rlimb_data["head"] ? "Morpheus Cyberkinetics" : rlimb_data["head"]]"
				robohead = all_robolimbs[head_model]
			switch(href_list["preference"])
				if("name")
					real_name = random_name(gender,species)
					if(isnewplayer(user))
						var/mob/new_player/N = user
						N.new_player_panel_proc()
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Wryn", "Vulpkanin", "Vox"))
						h_colour = rand_hex_color()
				if("secondary_hair")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Wryn", "Vulpkanin", "Vox"))
						h_sec_colour = rand_hex_color()
				if("h_style")
					h_style = random_hair_style(gender, species, robohead)
				if("facial")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Wryn", "Vulpkanin", "Vox"))
						f_colour = rand_hex_color()
				if("secondary_facial")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Wryn", "Vulpkanin", "Vox"))
						f_sec_colour = rand_hex_color()
				if("f_style")
					f_style = random_facial_hair_style(gender, species, robohead)
				if("headaccessory")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
						hacc_colour = rand_hex_color()
				if("ha_style")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
						ha_style = random_head_accessory(species)
				if("m_style_head")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						m_styles["head"] = random_marking_style("head", species, robohead, null, alt_head)
				if("m_head_colour")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						m_colours["head"] = rand_hex_color()
				if("m_style_body")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings.
						m_styles["body"] = random_marking_style("body", species)
				if("m_body_colour")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings.
						m_colours["body"] = rand_hex_color()
				if("m_style_tail")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						m_styles["tail"] = random_marking_style("tail", species, null, body_accessory)
				if("m_tail_colour")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						m_colours["tail"] = rand_hex_color()
				if("underwear")
					underwear = random_underwear(gender, species)
					ShowChoices(user)
				if("undershirt")
					undershirt = random_undershirt(gender, species)
					ShowChoices(user)
				if("socks")
					socks = random_socks(gender, species)
					ShowChoices(user)
				if("eyes")
					e_colour = rand_hex_color()
				if("s_tone")
					if(S.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
						s_tone = random_skin_tone()
				if("s_color")
					if(S.bodyflags & HAS_SKIN_COLOR)
						s_colour = rand_hex_color()
				if("bag")
					backbag = pick(GLOB.backbaglist)
				/*if("skin_style")
					h_style = random_skin_style(gender)*/
				if("all")
					random_character()
		if("input")
			switch(href_list["preference"])
				if("name")
					var/raw_name = input(user, "Choose your character's name:", "Character Preference") as text|null
					if(!isnull(raw_name)) // Check to ensure that the user entered text (rather than cancel.)
						var/new_name = reject_bad_name(raw_name, 1)
						if(new_name)
							real_name = new_name
							if(isnewplayer(user))
								var/mob/new_player/N = user
								N.new_player_panel_proc()
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min(round(text2num(new_age)), AGE_MAX),AGE_MIN)
				if("species")
					var/list/new_species = list("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin")
					var/prev_species = species
//						var/whitelisted = 0

					if(config.usealienwhitelist) //If we're using the whitelist, make sure to check it!
						for(var/Spec in GLOB.whitelisted_species)
							if(is_alien_whitelisted(user,Spec))
								new_species += Spec
//									whitelisted = 1
//							if(!whitelisted)
//								alert(user, "You cannot change your species as you need to be whitelisted. If you wish to be whitelisted contact an admin in-game, on the forums, or on IRC.")
					else //Not using the whitelist? Aliens for everyone!
						new_species += GLOB.whitelisted_species

					species = input("Please select a species", "Character Generation", null) in new_species
					var/datum/species/NS = GLOB.all_species[species]
					if(!istype(NS)) //The species was invalid. Notify the user and fail out.
						species = prev_species
						to_chat(user, "<span class='warning'>Invalid species, please pick something else.</span>")
						return
					if(prev_species != species)
						if(NS.has_gender && gender == PLURAL)
							gender = pick(MALE,FEMALE)
						var/datum/robolimb/robohead
						if(NS.bodyflags & ALL_RPARTS)
							var/head_model = "[!rlimb_data["head"] ? "Morpheus Cyberkinetics" : rlimb_data["head"]]"
							robohead = all_robolimbs[head_model]
						//grab one of the valid hair styles for the newly chosen species
						h_style = random_hair_style(gender, species, robohead)

						//grab one of the valid facial hair styles for the newly chosen species
						f_style = random_facial_hair_style(gender, species, robohead)

						if(NS.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
							ha_style = random_head_accessory(species)
						else
							ha_style = "None" // No Vulp ears on Unathi
							hacc_colour = rand_hex_color()

						if(NS.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
							m_styles["head"] = random_marking_style("head", species, robohead, null, alt_head)
						else
							m_styles["head"] = "None"
							m_colours["head"] = "#000000"

						if(NS.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
							m_styles["body"] = random_marking_style("body", species)
						else
							m_styles["body"] = "None"
							m_colours["body"] = "#000000"

						if(NS.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
							m_styles["tail"] = random_marking_style("tail", species, null, body_accessory)
						else
							m_styles["tail"] = "None"
							m_colours["tail"] = "#000000"

						// Don't wear another species' underwear!
						var/datum/sprite_accessory/SA = GLOB.underwear_list[underwear]
						if(!SA || !(species in SA.species_allowed))
							underwear = random_underwear(gender, species)

						SA = GLOB.undershirt_list[undershirt]
						if(!SA || !(species in SA.species_allowed))
							undershirt = random_undershirt(gender, species)

						SA = GLOB.socks_list[socks]
						if(!SA || !(species in SA.species_allowed))
							socks = random_socks(gender, species)

						//reset skin tone and colour
						if(NS.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
							random_skin_tone(species)
						else
							s_tone = 0

						if(!(NS.bodyflags & HAS_SKIN_COLOR))
							s_colour = "#000000"

						alt_head = "None" //No alt heads on species that don't have them.
						speciesprefs = 0 //My Vox tank shouldn't change how my future Grey talks.

						body_accessory = null //no vulptail on humans damnit

						//Reset prosthetics.
						organ_data = list()
						rlimb_data = list()

						if(!(NS.autohiss_basic_map))
							autohiss_mode = AUTOHISS_OFF
				if("speciesprefs")
					speciesprefs = !speciesprefs //Starts 0, so if someone clicks the button up top there, this won't be 0 anymore. If they click it again, it'll go back to 0.
				if("language")
//						var/languages_available
					var/list/new_languages = list("None")
/*
					if(config.usealienwhitelist)
						for(var/L in GLOB.all_languages)
							var/datum/language/lang = GLOB.all_languages[L]
							if((!(lang.flags & RESTRICTED)) && (is_alien_whitelisted(user, L)||(!( lang.flags & WHITELISTED ))))
								new_languages += lang
								languages_available = 1

						if(!(languages_available))
							alert(user, "There are not currently any available secondary languages.")
					else
*/
					for(var/L in GLOB.all_languages)
						var/datum/language/lang = GLOB.all_languages[L]
						if(!(lang.flags & RESTRICTED))
							new_languages += lang.name

					language = input("Please select a secondary language", "Character Generation", null) in new_languages

				if("autohiss_mode")
					if(S.autohiss_basic_map)
						var/list/autohiss_choice = list("Off" = AUTOHISS_OFF, "Basic" = AUTOHISS_BASIC, "Full" = AUTOHISS_FULL)
						var/new_autohiss_pref = input(user, "Choose your character's auto-accent level:", "Character Preference") as null|anything in autohiss_choice
						autohiss_mode = autohiss_choice[new_autohiss_pref]

				if("metadata")
					var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , metadata)  as message|null
					if(new_metadata)
						metadata = sanitize(copytext(new_metadata,1,MAX_MESSAGE_LEN))

				if("b_type")
					var/new_b_type = input(user, "Choose your character's blood-type:", "Character Preference") as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if(new_b_type)
						b_type = new_b_type

				if("hair")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Vulpkanin", "Vox")) //Species that have hair. (No HAS_HAIR flag)
						var/input = "Choose your character's hair colour:"
						var/new_hair = input(user, input, "Character Preference", h_colour) as color|null
						if(new_hair)
							h_colour = new_hair

				if("secondary_hair")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Vulpkanin", "Vox"))
						var/datum/sprite_accessory/hair_style = GLOB.hair_styles_public_list[h_style]
						if(hair_style.secondary_theme && !hair_style.no_sec_colour)
							var/new_hair = input(user, "Choose your character's secondary hair colour:", "Character Preference", h_sec_colour) as color|null
							if(new_hair)
								h_sec_colour = new_hair

				if("h_style")
					var/list/valid_hairstyles = list()
					for(var/hairstyle in GLOB.hair_styles_public_list)
						var/datum/sprite_accessory/SA = GLOB.hair_styles_public_list[hairstyle]

						if(hairstyle == "Bald") //Just in case.
							valid_hairstyles += hairstyle
							continue
						if(S.bodyflags & ALL_RPARTS) //Species that can use prosthetic heads.
							var/head_model
							if(!rlimb_data["head"]) //Handle situations where the head is default.
								head_model = "Morpheus Cyberkinetics"
							else
								head_model = rlimb_data["head"]
							var/datum/robolimb/robohead = all_robolimbs[head_model]
							if((species in SA.species_allowed) && robohead.is_monitor && ((SA.models_allowed && (robohead.company in SA.models_allowed)) || !SA.models_allowed)) //If this is a hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
								valid_hairstyles += hairstyle //Give them their hairstyles if they do.
							else
								if(!robohead.is_monitor && ("Human" in SA.species_allowed)) /*If the hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																							But if the user has a robotic humanoid head and the hairstyle can fit humans, let them use it as a wig. */
									valid_hairstyles += hairstyle
						else //If the user is not a species who can have robotic heads, use the default handling.
							if(species in SA.species_allowed) //If the user's head is of a species the hairstyle allows, add it to the list.
								valid_hairstyles += hairstyle

					var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference") as null|anything in valid_hairstyles
					if(new_h_style)
						h_style = new_h_style

				if("headaccessory")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species with head accessories.
						var/input = "Choose the colour of your your character's head accessory:"
						var/new_head_accessory = input(user, input, "Character Preference", hacc_colour) as color|null
						if(new_head_accessory)
							hacc_colour = new_head_accessory

				if("ha_style")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species with head accessories.
						var/list/valid_head_accessory_styles = list()
						for(var/head_accessory_style in GLOB.head_accessory_styles_list)
							var/datum/sprite_accessory/H = GLOB.head_accessory_styles_list[head_accessory_style]
							if(!(species in H.species_allowed))
								continue

							valid_head_accessory_styles += head_accessory_style

						var/new_head_accessory_style = input(user, "Choose the style of your character's head accessory:", "Character Preference") as null|anything in valid_head_accessory_styles
						if(new_head_accessory_style)
							ha_style = new_head_accessory_style

				if("alt_head")
					if(organ_data["head"] == "cyborg")
						return
					if(S.bodyflags & HAS_ALT_HEADS) //Species with alt heads.
						var/list/valid_alt_heads = list()
						valid_alt_heads["None"] = GLOB.alt_heads_list["None"] //The only null entry should be the "None" option
						for(var/alternate_head in GLOB.alt_heads_list)
							var/datum/sprite_accessory/alt_heads/head = GLOB.alt_heads_list[alternate_head]
							if(!(species in head.species_allowed))
								continue

							valid_alt_heads += alternate_head

						var/new_alt_head = input(user, "Choose your character's alternate head style:", "Character Preference") as null|anything in valid_alt_heads
						if(new_alt_head)
							alt_head = new_alt_head
						if(m_styles["head"])
							var/head_marking = m_styles["head"]
							var/datum/sprite_accessory/body_markings/head/head_marking_style = GLOB.marking_styles_list[head_marking]
							if(!head_marking_style.heads_allowed || (!("All" in head_marking_style.heads_allowed) && !(alt_head in head_marking_style.heads_allowed)))
								m_styles["head"] = "None"

				if("m_style_head")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						var/list/valid_markings = list()
						valid_markings["None"] = GLOB.marking_styles_list["None"]
						for(var/markingstyle in GLOB.marking_styles_list)
							var/datum/sprite_accessory/body_markings/head/M = GLOB.marking_styles_list[markingstyle]
							if(!(species in M.species_allowed))
								continue
							if(M.marking_location != "head")
								continue
							if(alt_head && alt_head != "None")
								if(!("All" in M.heads_allowed) && !(alt_head in M.heads_allowed))
									continue
							else
								if(M.heads_allowed && !("All" in M.heads_allowed))
									continue

							if(S.bodyflags & ALL_RPARTS) //Species that can use prosthetic heads.
								var/head_model
								if(!rlimb_data["head"]) //Handle situations where the head is default.
									head_model = "Morpheus Cyberkinetics"
								else
									head_model = rlimb_data["head"]
								var/datum/robolimb/robohead = all_robolimbs[head_model]
								if(robohead.is_monitor && M.name != "None") //If the character can have prosthetic heads and they have the default Morpheus head (or another monitor-head), no optic markings.
									continue
								else if(!robohead.is_monitor && M.name != "None") //Otherwise, if they DON'T have the default head and the head's not a monitor but the head's not in the style's list of allowed models, skip.
									if(!(robohead.company in M.models_allowed))
										continue

							valid_markings += markingstyle

						var/new_marking_style = input(user, "Choose the style of your character's head markings:", "Character Preference", m_styles["head"]) as null|anything in valid_markings
						if(new_marking_style)
							m_styles["head"] = new_marking_style

				if("m_head_colour")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						var/input = "Choose the colour of your your character's head markings:"
						var/new_markings = input(user, input, "Character Preference", m_colours["head"]) as color|null
						if(new_markings)
							m_colours["head"] = new_markings

				if("m_style_body")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
						var/list/valid_markings = list()
						valid_markings["None"] = GLOB.marking_styles_list["None"]
						for(var/markingstyle in GLOB.marking_styles_list)
							var/datum/sprite_accessory/M = GLOB.marking_styles_list[markingstyle]
							if(!(species in M.species_allowed))
								continue
							if(M.marking_location != "body")
								continue

							valid_markings += markingstyle

						var/new_marking_style = input(user, "Choose the style of your character's body markings:", "Character Preference", m_styles["body"]) as null|anything in valid_markings
						if(new_marking_style)
							m_styles["body"] = new_marking_style

				if("m_body_colour")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
						var/input = "Choose the colour of your your character's body markings:"
						var/new_markings = input(user, input, "Character Preference", m_colours["body"]) as color|null
						if(new_markings)
							m_colours["body"] = new_markings

				if("m_style_tail")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						var/list/valid_markings = list()
						valid_markings["None"] = GLOB.marking_styles_list["None"]
						for(var/markingstyle in GLOB.marking_styles_list)
							var/datum/sprite_accessory/body_markings/tail/M = GLOB.marking_styles_list[markingstyle]
							if(M.marking_location != "tail")
								continue
							if(!(species in M.species_allowed))
								continue
							if(!body_accessory)
								if(M.tails_allowed)
									continue
							else
								if(!M.tails_allowed || !(body_accessory in M.tails_allowed))
									continue

							valid_markings += markingstyle

						var/new_marking_style = input(user, "Choose the style of your character's tail markings:", "Character Preference", m_styles["tail"]) as null|anything in valid_markings
						if(new_marking_style)
							m_styles["tail"] = new_marking_style

				if("m_tail_colour")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						var/input = "Choose the colour of your your character's tail markings:"
						var/new_markings = input(user, input, "Character Preference", m_colours["tail"]) as color|null
						if(new_markings)
							m_colours["tail"] = new_markings

				if("body_accessory")
					var/list/possible_body_accessories = list()
					if(check_rights(R_ADMIN, 1, user))
						possible_body_accessories = body_accessory_by_name.Copy()
					else
						for(var/B in body_accessory_by_name)
							var/datum/body_accessory/accessory = body_accessory_by_name[B]
							if(!istype(accessory))
								possible_body_accessories += "None" //the only null entry should be the "None" option
								continue
							if(species in accessory.allowed_species)
								possible_body_accessories += B

					var/new_body_accessory = input(user, "Choose your body accessory:", "Character Preference") as null|anything in possible_body_accessories
					if(new_body_accessory)
						m_styles["tail"] = "None"
						body_accessory = (new_body_accessory == "None") ? null : new_body_accessory

				if("facial")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Vulpkanin", "Vox")) //Species that have facial hair. (No HAS_HAIR_FACIAL flag)
						var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference", f_colour) as color|null
						if(new_facial)
							f_colour = new_facial

				if("secondary_facial")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Vulpkanin", "Vox"))
						var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[f_style]
						if(facial_hair_style.secondary_theme && !facial_hair_style.no_sec_colour)
							var/new_facial = input(user, "Choose your character's secondary facial-hair colour:", "Character Preference", f_sec_colour) as color|null
							if(new_facial)
								f_sec_colour = new_facial

				if("f_style")
					var/list/valid_facial_hairstyles = list()
					for(var/facialhairstyle in GLOB.facial_hair_styles_list)
						var/datum/sprite_accessory/SA = GLOB.facial_hair_styles_list[facialhairstyle]

						if(facialhairstyle == "Shaved") //Just in case.
							valid_facial_hairstyles += facialhairstyle
							continue
						if(gender == MALE && SA.gender == FEMALE)
							continue
						if(gender == FEMALE && SA.gender == MALE)
							continue
						if(S.bodyflags & ALL_RPARTS) //Species that can use prosthetic heads.
							var/head_model
							if(!rlimb_data["head"]) //Handle situations where the head is default.
								head_model = "Morpheus Cyberkinetics"
							else
								head_model = rlimb_data["head"]
							var/datum/robolimb/robohead = all_robolimbs[head_model]
							if((species in SA.species_allowed) && robohead.is_monitor && ((SA.models_allowed && (robohead.company in SA.models_allowed)) || !SA.models_allowed)) //If this is a facial hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
								valid_facial_hairstyles += facialhairstyle //Give them their facial hairstyles if they do.
							else
								if(!robohead.is_monitor && ("Human" in SA.species_allowed)) /*If the facial hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																							But if the user has a robotic humanoid head and the facial hairstyle can fit humans, let them use it as a wig. */
									valid_facial_hairstyles += facialhairstyle
						else //If the user is not a species who can have robotic heads, use the default handling.
							if(species in SA.species_allowed) //If the user's head is of a species the facial hair style allows, add it to the list.
								valid_facial_hairstyles += facialhairstyle

					var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_facial_hairstyles
					if(new_f_style)
						f_style = new_f_style

				if("underwear")
					var/list/valid_underwear = list()
					for(var/underwear in GLOB.underwear_list)
						var/datum/sprite_accessory/SA = GLOB.underwear_list[underwear]
						if(gender == MALE && SA.gender == FEMALE)
							continue
						if(gender == FEMALE && SA.gender == MALE)
							continue
						if(!(species in SA.species_allowed))
							continue
						valid_underwear[underwear] = GLOB.underwear_list[underwear]
					var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference") as null|anything in valid_underwear
					ShowChoices(user)
					if(new_underwear)
						underwear = new_underwear
				if("undershirt")
					var/list/valid_undershirts = list()
					for(var/undershirt in GLOB.undershirt_list)
						var/datum/sprite_accessory/SA = GLOB.undershirt_list[undershirt]
						if(gender == MALE && SA.gender == FEMALE)
							continue
						if(gender == FEMALE && SA.gender == MALE)
							continue
						if(!(species in SA.species_allowed))
							continue
						valid_undershirts[undershirt] = GLOB.undershirt_list[undershirt]
					var/new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in valid_undershirts
					ShowChoices(user)
					if(new_undershirt)
						undershirt = new_undershirt

				if("socks")
					var/list/valid_sockstyles = list()
					for(var/sockstyle in GLOB.socks_list)
						var/datum/sprite_accessory/SA = GLOB.socks_list[sockstyle]
						if(gender == MALE && SA.gender == FEMALE)
							continue
						if(gender == FEMALE && SA.gender == MALE)
							continue
						if(!(species in SA.species_allowed))
							continue
						valid_sockstyles[sockstyle] = GLOB.socks_list[sockstyle]
					var/new_socks = input(user, "Choose your character's socks:", "Character Preference")  as null|anything in valid_sockstyles
					ShowChoices(user)
					if(new_socks)
						socks = new_socks

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference", e_colour) as color|null
					if(new_eyes)
						e_colour = new_eyes

				if("s_tone")
					if(S.bodyflags & HAS_SKIN_TONE)
						var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
						if(new_s_tone)
							s_tone = 35 - max(min(round(new_s_tone), 220), 1)
					else if(S.bodyflags & HAS_ICON_SKIN_TONE)
						var/const/MAX_LINE_ENTRIES = 4
						var/prompt = "Choose your character's skin tone: 1-[S.icon_skin_tones.len]\n("
						for(var/i = 1 to S.icon_skin_tones.len)
							if(i > MAX_LINE_ENTRIES && !((i - 1) % MAX_LINE_ENTRIES))
								prompt += "\n"
							prompt += "[i] = [S.icon_skin_tones[i]]"
							if(i != S.icon_skin_tones.len)
								prompt += ", "
						prompt += ")"
						var/skin_c = input(user, prompt, "Character Preference") as num|null
						if(isnum(skin_c))
							s_tone = max(min(round(skin_c), S.icon_skin_tones.len), 1)

				if("skin")
					if((S.bodyflags & HAS_SKIN_COLOR) || body_accessory_by_species[species] || check_rights(R_ADMIN, 0, user))
						var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference", s_colour) as color|null
						if(new_skin)
							s_colour = new_skin

				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference", ooccolor) as color|null
					if(new_ooccolor)
						ooccolor = new_ooccolor

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference") as null|anything in GLOB.backbaglist
					if(new_backbag)
						backbag = new_backbag

				if("nt_relation")
					var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
					if(new_relation)
						nanotrasen_relation = new_relation

				if("flavor_text")
					var/msg = input(usr,"Set the flavor text in your 'examine' verb. The flavor text should be a physical descriptor of your character at a glance. SFW Drawn Art of your character is acceptable.","Flavor Text",html_decode(flavor_text)) as message

					if(msg != null)
						msg = copytext(msg, 1, MAX_MESSAGE_LEN)
						msg = html_encode(msg)

						flavor_text = msg

				if("limbs")
					var/valid_limbs = list("Left Leg", "Right Leg", "Left Arm", "Right Arm", "Left Foot", "Right Foot", "Left Hand", "Right Hand")
					if(S.bodyflags & ALL_RPARTS)
						valid_limbs = list("Torso", "Lower Body", "Head", "Left Leg", "Right Leg", "Left Arm", "Right Arm", "Left Foot", "Right Foot", "Left Hand", "Right Hand")
					var/limb_name = input(user, "Which limb do you want to change?") as null|anything in valid_limbs
					if(!limb_name) return

					var/limb = null
					var/second_limb = null // if you try to change the arm, the hand should also change
					var/third_limb = null  // if you try to unchange the hand, the arm should also change
					var/valid_limb_states = list("Normal", "Amputated", "Prosthesis")
					var/no_amputate = 0

					switch(limb_name)
						if("Torso")
							limb = "chest"
							second_limb = "groin"
							no_amputate = 1
						if("Lower Body")
							limb = "groin"
							no_amputate = 1
						if("Head")
							limb = "head"
							no_amputate = 1
						if("Left Leg")
							limb = "l_leg"
							second_limb = "l_foot"
						if("Right Leg")
							limb = "r_leg"
							second_limb = "r_foot"
						if("Left Arm")
							limb = "l_arm"
							second_limb = "l_hand"
						if("Right Arm")
							limb = "r_arm"
							second_limb = "r_hand"
						if("Left Foot")
							limb = "l_foot"
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = "l_leg"
						if("Right Foot")
							limb = "r_foot"
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = "r_leg"
						if("Left Hand")
							limb = "l_hand"
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = "l_arm"
						if("Right Hand")
							limb = "r_hand"
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = "r_arm"

					var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in valid_limb_states
					if(!new_state) return

					switch(new_state)
						if("Normal")
							if(limb == "head")
								m_styles["head"] = "None"
								h_style = GLOB.hair_styles_public_list["Bald"]
								f_style = GLOB.facial_hair_styles_list["Shaved"]
							organ_data[limb] = null
							rlimb_data[limb] = null
							if(third_limb)
								organ_data[third_limb] = null
								rlimb_data[third_limb] = null
						if("Amputated")
							if(!no_amputate)
								organ_data[limb] = "amputated"
								rlimb_data[limb] = null
								if(second_limb)
									organ_data[second_limb] = "amputated"
									rlimb_data[second_limb] = null
						if("Prosthesis")
							var/choice
							var/subchoice
							var/datum/robolimb/R = new()
							var/in_model
							var/robolimb_companies = list()
							for(var/limb_type in typesof(/datum/robolimb)) //This loop populates a list of companies that offer the limb the user selected previously as one of their cybernetic products.
								R = new limb_type()
								if(!R.unavailable_at_chargen && (limb in R.parts) && R.has_subtypes) //Ensures users can only choose companies that offer the parts they want, that singular models get added to the list as well companies that offer more than one model, and...
									robolimb_companies[R.company] = R //List only main brands that have the parts we're looking for.
							R = new() //Re-initialize R.

							choice = input(user, "Which manufacturer do you wish to use for this limb?") as null|anything in robolimb_companies //Choose from a list of companies that offer the part the user wants.
							if(!choice)
								return
							R.company = choice
							R = all_robolimbs[R.company]
							if(R.has_subtypes == 1) //If the company the user selected provides more than just one base model, lets handle it.
								var/list/robolimb_models = list()
								for(var/limb_type in typesof(R)) //Handling the different models of parts that manufacturers can provide.
									var/datum/robolimb/L = new limb_type()
									if(limb in L.parts) //Make sure that only models that provide the parts the user needs populate the list.
										robolimb_models[L.company] = L
										if(robolimb_models.len == 1) //If there's only one model available in the list, autoselect it to avoid having to bother the user with a dialog that provides only one option.
											subchoice = L.company //If there ends up being more than one model populating the list, subchoice will be overwritten later anyway, so this isn't a problem.
										if(second_limb in L.parts) //If the child limb of the limb the user selected is also present in the model's parts list, state it's been found so the second limb can be set later.
											in_model = 1
								if(robolimb_models.len > 1) //If there's more than one model in the list that can provide the part the user wants, let them choose.
									subchoice = input(user, "Which model of [choice] [limb_name] do you wish to use?") as null|anything in robolimb_models
								if(subchoice)
									choice = subchoice
							if(limb in list("head", "chest", "groin"))
								if(!(S.bodyflags & ALL_RPARTS))
									return
								if(limb == "head")
									ha_style = "None"
									alt_head = null
									h_style = GLOB.hair_styles_public_list["Bald"]
									f_style = GLOB.facial_hair_styles_list["Shaved"]
									m_styles["head"] = "None"
							rlimb_data[limb] = choice
							organ_data[limb] = "cyborg"
							if(second_limb)
								if(subchoice)
									if(in_model)
										rlimb_data[second_limb] = choice
										organ_data[second_limb] = "cyborg"
								else
									rlimb_data[second_limb] = choice
									organ_data[second_limb] = "cyborg"
				if("organs")
					var/organ_name = input(user, "Which internal function do you want to change?") as null|anything in list("Eyes", "Heart", "Lungs", "Liver", "Kidneys")
					if(!organ_name)
						return

					var/organ = null
					switch(organ_name)
						if("Eyes")
							organ = "eyes"
						if("Heart")
							organ = "heart"
						if("Lungs")
							organ = "lungs"
						if("Liver")
							organ = "liver"
						if("Kidneys")
							organ = "kidneys"

					var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in list("Normal", "Cybernetic")
					if(!new_state) return

					switch(new_state)
						if("Normal")
							organ_data[organ] = null
						if("Cybernetic")
							organ_data[organ] = "cybernetic"

				if("clientfps")
					var/version_message
					if(user.client && user.client.byond_version < 511)
						version_message = "\nYou need to be using byond version 511 or later to take advantage of this feature, your version of [user.client.byond_version] is too low"
					if(world.byond_version < 511)
						version_message += "\nThis server does not currently support client side fps. You can set now for when it does."
					var/desiredfps = input(user, "Choose your desired fps.[version_message]\n(0 = synced with server tick rate (currently:[world.fps]))", "Character Preference", clientfps)  as null|num
					if(!isnull(desiredfps))
						clientfps = desiredfps
						if(world.byond_version >= 511 && user.client && user.client.byond_version >= 511)
							parent.fps = clientfps

/*
				if("skin_style")
					var/skin_style_name = input(user, "Select a new skin style") as null|anything in list("default1", "default2", "default3")
					if(!skin_style_name) return
*/

/*					if("spawnpoint")
					var/list/spawnkeys = list()
					for(var/S in spawntypes)
						spawnkeys += S
					var/choice = input(user, "Where would you like to spawn when latejoining?") as null|anything in spawnkeys
					if(!choice || !spawntypes[choice])
						spawnpoint = "Arrivals Shuttle"
						return
					spawnpoint = choice */

		else
			switch(href_list["preference"])
				if("publicity")
					if(unlock_content)
						toggles ^= MEMBER_PUBLIC

				if("donor_public")
					if(user.client.donator_level >= DONATOR_LEVEL_ONE)
						toggles ^= DONATOR_PUBLIC

				if("gender")
					if(!S.has_gender)
						var/newgender = input(user, "Choose Gender:") as null|anything in list("Male", "Female", "Genderless")
						switch(newgender)
							if("Male")
								gender = MALE
							if("Female")
								gender = FEMALE
							if("Genderless")
								gender = PLURAL
					else
						if(gender == MALE)
							gender = FEMALE
						else
							gender = MALE
					underwear = random_underwear(gender)

				if("hear_adminhelps")
					sound ^= SOUND_ADMINHELP
				if("ui")
					switch(UI_style)
						if("Midnight")
							UI_style = "Plasmafire"
						if("Plasmafire")
							UI_style = "Retro"
						if("Retro")
							UI_style = "Slimecore"
						if("Slimecore")
							UI_style = "Operative"
						if("Operative")
							UI_style = "White"
						else
							UI_style = "Midnight"

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()

				if("nanoui")
					nanoui_fancy = !nanoui_fancy

				if("ghost_att_anim")
					show_ghostitem_attack = !show_ghostitem_attack

				if("winflash")
					windowflashing = !windowflashing

				if("UIcolor")
					var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!", UI_style_color) as color|null
					if(!UI_style_color_new) return
					UI_style_color = UI_style_color_new

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()

				if("UIalpha")
					var/UI_style_alpha_new = input(user, "Select a new alpha(transparence) parameter for UI, between 50 and 255", UI_style_alpha) as num
					if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return
					UI_style_alpha = UI_style_alpha_new

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()

				if("be_special")
					var/r = href_list["role"]
					if(r in special_roles)
						be_special ^= r

				if("name")
					be_random_name = !be_random_name

				if("randomslot")
					randomslot = !randomslot
					if(isnewplayer(usr))
						var/mob/new_player/N = usr
						N.new_player_panel_proc()

				if("hear_midis")
					sound ^= SOUND_MIDI

				if("lobby_music")
					sound ^= SOUND_LOBBY
					if((sound & SOUND_LOBBY) && user.client)
						user.client.playtitlemusic()
					else
						user.stop_sound_channel(CHANNEL_LOBBYMUSIC)

				if("ghost_ears")
					toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					toggles ^= CHAT_GHOSTSIGHT

				if("ghost_radio")
					toggles ^= CHAT_GHOSTRADIO

				if("ghost_radio")
					toggles ^= CHAT_GHOSTRADIO

				if("ghost_anonsay")
					ghost_anonsay = !ghost_anonsay

				if("save")
					save_preferences(user)
					save_character(user)

				if("reload")
					load_preferences(user)
					load_character(user)

				if("open_load_dialog")
					if(!IsGuestKey(user.key))
						open_load_dialog(user)
						return 1

				if("close_load_dialog")
					close_load_dialog(user)

				if("changeslot")
					if(!load_character(user,text2num(href_list["num"])))
						random_character()
						real_name = random_name(gender)
						save_character(user)
					close_load_dialog(user)
					if(isnewplayer(user))
						var/mob/new_player/N = user
						N.new_player_panel_proc()

				if("tab")
					if(href_list["tab"])
						current_tab = text2num(href_list["tab"])

	ShowChoices(user)
	return 1

/datum/preferences/proc/copy_to(mob/living/carbon/human/character)
	var/datum/species/S = GLOB.all_species[species]
	character.set_species(S.type) // Yell at me if this causes everything to melt
	if(be_random_name)
		real_name = random_name(gender,species)

	if(config.humans_need_surnames)
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [pick(GLOB.last_names)]"
		else if(firstspace == name_length)
			real_name += "[pick(GLOB.last_names)]"

	character.add_language(language)


	character.real_name = real_name
	character.dna.real_name = real_name
	character.name = character.real_name

	character.flavor_text = flavor_text
	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record

	character.change_gender(gender)
	character.age = age
	character.b_type = b_type

	//Head-specific
	var/obj/item/organ/external/head/H = character.get_organ("head")

	H.hair_colour = h_colour

	H.sec_hair_colour = h_sec_colour

	H.facial_colour = f_colour

	H.sec_facial_colour = f_sec_colour

	H.h_style = h_style
	H.f_style = f_style

	H.alt_head = alt_head
	//End of head-specific.

	character.skin_colour = s_colour

	character.s_tone = s_tone

	// Destroy/cyborgize organs
	for(var/name in organ_data)

		var/status = organ_data[name]
		var/obj/item/organ/external/O = character.bodyparts_by_name[name]
		if(O)
			if(status == "amputated")
				qdel(O.remove(character))

			else if(status == "cyborg")
				if(rlimb_data[name])
					O.robotize(rlimb_data[name], convert_all = 0)
				else
					O.robotize()
		else
			var/obj/item/organ/internal/I = character.get_int_organ_tag(name)
			if(I)
				if(status == "cybernetic")
					I.robotize()

	character.dna.b_type = b_type

	// Wheelchair necessary?
	var/obj/item/organ/external/l_foot = character.get_organ("l_foot")
	var/obj/item/organ/external/r_foot = character.get_organ("r_foot")
	if(!l_foot && !r_foot)
		var/obj/structure/chair/wheelchair/W = new /obj/structure/chair/wheelchair (character.loc)
		character.buckled = W
		character.update_canmove()
		W.dir = character.dir
		W.buckled_mob = character
		W.add_fingerprint(character)

	character.underwear = underwear
	character.undershirt = undershirt
	character.socks = socks

	if(character.dna.species.bodyflags & HAS_HEAD_ACCESSORY)
		H.headacc_colour = hacc_colour
		H.ha_style = ha_style
	if(character.dna.species.bodyflags & HAS_MARKINGS)
		character.m_colours = m_colours
		character.m_styles = m_styles

	if(body_accessory)
		character.body_accessory = body_accessory_by_name["[body_accessory]"]

	character.backbag = backbag

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.dna.species.has_gender && (character.gender in list(PLURAL, NEUTER)))
		if(isliving(src)) //Ghosts get neuter by default
			message_admins("[key_name_admin(character)] has spawned with their gender as plural or neuter. Please notify coders.")
			character.change_gender(MALE)

	character.change_eye_color(e_colour)

	if(disabilities & DISABILITY_FLAG_FAT && (CAN_BE_FAT in character.dna.species.species_traits))
		character.dna.SetSEState(FATBLOCK, TRUE, TRUE)
		character.overeatduration = 600
		character.dna.default_blocks.Add(FATBLOCK)

	if(disabilities & DISABILITY_FLAG_NEARSIGHTED)
		character.dna.SetSEState(GLASSESBLOCK, TRUE, TRUE)
		character.dna.default_blocks.Add(GLASSESBLOCK)

	if(disabilities & DISABILITY_FLAG_BLIND)
		character.dna.SetSEState(BLINDBLOCK, TRUE, TRUE)
		character.dna.default_blocks.Add(BLINDBLOCK)

	if(disabilities & DISABILITY_FLAG_DEAF)
		character.dna.SetSEState(DEAFBLOCK, TRUE, TRUE)
		character.dna.default_blocks.Add(DEAFBLOCK)

	if(disabilities & DISABILITY_FLAG_COLOURBLIND)
		character.dna.SetSEState(COLOURBLINDBLOCK, TRUE, TRUE)
		character.dna.default_blocks.Add(COLOURBLINDBLOCK)

	if(disabilities & DISABILITY_FLAG_MUTE)
		character.dna.SetSEState(MUTEBLOCK, TRUE, TRUE)
		character.dna.default_blocks.Add(MUTEBLOCK)

	if(disabilities & DISABILITY_FLAG_NERVOUS)
		character.dna.SetSEState(NERVOUSBLOCK, TRUE, TRUE)
		character.dna.default_blocks.Add(NERVOUSBLOCK)

	if(disabilities & DISABILITY_FLAG_SWEDISH)
		character.dna.SetSEState(SWEDEBLOCK, TRUE, TRUE)
		character.dna.default_blocks.Add(SWEDEBLOCK)

	if(disabilities & DISABILITY_FLAG_CHAV)
		character.dna.SetSEState(CHAVBLOCK, TRUE, TRUE)
		character.dna.default_blocks.Add(CHAVBLOCK)

	if(disabilities & DISABILITY_FLAG_LISP)
		character.dna.SetSEState(LISPBLOCK, TRUE, TRUE)
		character.dna.default_blocks.Add(LISPBLOCK)

	if(disabilities & DISABILITY_FLAG_DIZZY)
		character.dna.SetSEState(DIZZYBLOCK, TRUE, TRUE)
		character.dna.default_blocks.Add(DIZZYBLOCK)

	if(disabilities & DISABILITY_FLAG_WINGDINGS && (CAN_WINGDINGS in character.dna.species.species_traits))
		character.dna.SetSEState(WINGDINGSBLOCK, TRUE, TRUE)
		character.dna.default_blocks.Add(WINGDINGSBLOCK)

	character.dna.species.handle_dna(character)

	if(character.dna.dirtySE)
		character.dna.UpdateSE()
	domutcheck(character, null, MUTCHK_FORCED) //'Activates' all the above disabilities.

	character.dna.ready_dna(character, flatten_SE = 0)
	character.sync_organ_dna(assimilate=1)
	character.UpdateAppearance()

	// Do the initial caching of the player's body icons.
	character.force_update_limbs()
	character.update_eyes()
	character.regenerate_icons()

/datum/preferences/proc/open_load_dialog(mob/user)

	var/DBQuery/query = dbcon.NewQuery("SELECT slot,real_name FROM [format_table_name("characters")] WHERE ckey='[user.ckey]' ORDER BY slot")
	var/list/slotnames[max_save_slots]

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		return
	while(query.NextRow())
		slotnames[text2num(query.item[1])] = query.item[2]

	var/dat = "<body>"
	dat += "<tt><center>"
	dat += "<b>Select a character slot to load</b><hr>"
	var/name

	for(var/i in 1 to max_save_slots)
		name = slotnames[i] || "Character [i]"
		if(i == default_slot)
			name = "<b>[name]</b>"
		dat += "<a href='?_src_=prefs;preference=changeslot;num=[i];'>[name]</a><br>"

	dat += "<hr>"
	dat += "<a href='byond://?_src_=prefs;preference=close_load_dialog'>Close</a><br>"
	dat += "</center></tt>"
//		user << browse(dat, "window=saves;size=300x390")
	var/datum/browser/popup = new(user, "saves", "<div align='center'>Character Saves</div>", 300, 390)
	popup.set_content(dat)
	popup.open(0)

/datum/preferences/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")
