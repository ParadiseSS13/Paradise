GLOBAL_LIST_INIT(special_role_times, list( //minimum age (in days) for accounts to play these roles
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
	ROLE_ALIEN = 21,
	ROLE_DEMON = 21,
	ROLE_SENTIENT = 21,
// 	ROLE_GANG = 21,
	ROLE_BORER = 21,
	ROLE_NINJA = 21,
	ROLE_GSPIDER = 21,
	ROLE_ABDUCTOR = 30
))

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
	if(!GLOB.configuration.gamemode.antag_account_age_restriction)
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	var/minimal_player_age_antag = GLOB.special_role_times[num2text(role)]
	if(!isnum(minimal_player_age_antag))
		return 0

	return max(0, minimal_player_age_antag - C.player_age)

/proc/check_client_age(client/C, days) // If days isn't provided, returns the age of the client. If it is provided, it returns the days until the player_age is equal to or greater than the days variable
	if(!days)
		return C.player_age
	else
		return max(0, days - C.player_age)

/datum/preferences
	var/client/parent
	//doohickeys for savefiles
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/max_save_slots = MAX_SAVE_SLOTS
	var/max_gear_slots = 0

	//non-preference stuff
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = "1"				//Saved changlog timestamp (unix epoch) to detect if there was a change. Dont set this to 0 unless you want the last changelog date to be 4x longer than the expected lifespan of the universe.
	var/exp
	var/ooccolor = "#b82e00"
	var/list/be_special = list()				//Special role selection
	var/UI_style = "Midnight"
	var/toggles = TOGGLES_DEFAULT
	var/toggles2 = TOGGLES_2_DEFAULT // Created because 1 column has a bitflag limit of 24 (BYOND limitation not MySQL)
	var/sound = SOUND_DEFAULT
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255
	var/clientfps = 0
	var/atklog = ATKLOG_ALL
	var/fuid							// forum userid

	/// Volume mixer, indexed by channel as TEXT (numerical indexes will not work). Volume goes from 0 to 100.
	var/list/volume_mixer = list(
		"1024" = 100, // CHANNEL_LOBBYMUSIC
		"1023" = 100, // CHANNEL_ADMIN
		"1022" = 100, // CHANNEL_VOX
		"1021" = 100, // CHANNEL_JUKEBOX
		"1020" = 100, // CHANNEL_HEARTBEAT
		"1019" = 100, // CHANNEL_BUZZ
		"1018" = 100, // CHANNEL_AMBIENCE
		"1017" = 100, // CHANNEL_ENGINE
	)
	/// The volume mixer save timer handle. Used to debounce the DB call to save, to avoid spamming.
	var/volume_mixer_saving = null

	// BYOND membership
	var/unlock_content = 0

	var/gear_tab = "General"
	// Parallax
	var/parallax = PARALLAX_HIGH
	/// 2FA status
	var/_2fa_status = _2FA_DISABLED
	///Screentip Mode, in pixels. 8 is small, 15 is mega big, 0 is off.
	var/screentip_mode = 8
	///Color of screentips at top of screen
	var/screentip_color = "#ffd391"
	/// Did we load successfully?
	var/successful_load = FALSE
	/// Have we loaded characters already?
	var/characters_loaded = FALSE

	// 0 = character settings, 1 = game preferences, 2 = loadout
	var/current_tab = TAB_CHAR

	/// List of all character saves we have. This is indexed based on the slot number
	var/list/datum/character_save/character_saves = list()
	/// The current active character
	var/datum/character_save/active_character
	/// How dark things are if client is a ghost, 0-255
	var/ghost_darkness_level = LIGHTING_PLANE_ALPHA_VISIBLE

/datum/preferences/New(client/C, datum/db_query/Q) // Process our query
	parent = C

	max_gear_slots = GLOB.configuration.general.base_loadout_points

	if(!SSdbcore.IsConnected())
		return // Bail

	if(istype(C))
		if(!IsGuestKey(C.key))
			unlock_content = C.IsByondMember()
			if(unlock_content)
				max_save_slots = MAX_SAVE_SLOTS_MEMBER

		successful_load = load_preferences(Q)
		if(!successful_load)
			to_chat(C, "<span class='narsie'>Your preferences failed to load. Please inform the server host immediately.</span>")

/datum/preferences/proc/color_square(colour)
	return "<span style='font-face: fixedsys; background-color: [colour]; color: [colour]'>___</span>"

// Hello I am a proc full of snowflake species checks how are you
/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return
	active_character.update_preview_icon()
	user << browse_rsc(active_character.preview_icon_front, "previewicon.png")
	user << browse_rsc(active_character.preview_icon_side, "previewicon2.png")

	var/dat = ""
	dat += "<center>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=[TAB_CHAR]' [current_tab == TAB_CHAR ? "class='linkOn'" : ""]>Character Settings</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=[TAB_GAME]' [current_tab == TAB_GAME ? "class='linkOn'" : ""]>Game Preferences</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=[TAB_GEAR]' [current_tab == TAB_GEAR ? "class='linkOn'" : ""]>Loadout</a>"
	dat += "</center>"
	dat += "<HR>"

	switch(current_tab)
		if(TAB_CHAR) // Character Settings
			var/datum/species/S = GLOB.all_species[active_character.species]
			if(!istype(S)) //The species was invalid. Set the species to the default, fetch the datum for that species and generate a random character.
				active_character.species = initial(active_character.species)
				S = GLOB.all_species[active_character.species]
				active_character.randomise()

			dat += "<div class='statusDisplay' style='max-width: 128px; position: absolute; left: 150px; top: 150px'><img src=previewicon.png class='charPreview'><img src=previewicon2.png class='charPreview'></div>"
			dat += "<table width='100%'><tr><td width='405px' height='25px' valign='top'>"
			dat += "<b>Name: </b>"
			dat += "<a href='?_src_=prefs;preference=name;task=input'><b>[active_character.real_name]</b></a>"
			dat += "<a href='?_src_=prefs;preference=name;task=random'>(Randomize)</a>"
			dat += "<a href='?_src_=prefs;preference=name'><span class='[active_character.be_random_name ? "good" : "bad"]'>(Always Randomize)</span></a><br>"
			dat += "</td><td width='405px' height='25px' valign='left'>"
			dat += "<center>"
			dat += "Slot <b>[default_slot][active_character.from_db ? "" : " (empty)"]</b><br>"
			dat += "<a href=\"byond://?_src_=prefs;preference=open_load_dialog\">Load slot</a> - "
			dat += "<a href=\"byond://?_src_=prefs;preference=save\">Save slot</a>"
			if(active_character.from_db)
				dat += "- <a href=\"byond://?_src_=prefs;preference=clear\"><span class='bad'>Clear slot</span></a>"
			dat += "</center>"
			dat += "</td></tr></table>"
			dat += "<table width='100%'><tr><td width='405px' height='200px' valign='top'>"
			dat += "<h2>Identity</h2>"
			dat += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender'>[active_character.gender == MALE ? "Male" : (active_character.gender == FEMALE ? "Female" : "Genderless")]</a>"
			dat += "<br>"
			dat += "<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[active_character.age]</a><br>"
			dat += "<b>Body:</b> <a href='?_src_=prefs;preference=all;task=random'>(&reg;)</a><br>"
			dat += "<b>Species:</b> <a href='?_src_=prefs;preference=species;task=input'>[active_character.species]</a><br>"
			if(active_character.species == "Vox") // Purge these bastards
				dat += "<b>N2 Tank:</b> <a href='?_src_=prefs;preference=speciesprefs;task=input'>[active_character.speciesprefs ? "Large N2 Tank" : "Specialized N2 Tank"]</a><br>"
			if(active_character.species == "Grey")
				dat += "<b>Wingdings:</b> Set in disabilities<br>"
				dat += "<b>Voice Translator:</b> <a href ='?_src_=prefs;preference=speciesprefs;task=input'>[active_character.speciesprefs ? "Yes" : "No"]</a><br>"
			dat += "<b>Secondary Language:</b> <a href='?_src_=prefs;preference=language;task=input'>[active_character.language]</a><br>"
			if(S.autohiss_basic_map)
				dat += "<b>Auto-accent:</b> <a href='?_src_=prefs;preference=autohiss_mode;task=input'>[active_character.autohiss_mode == AUTOHISS_FULL ? "Full" : (active_character.autohiss_mode == AUTOHISS_BASIC ? "Basic" : "Off")]</a><br>"
			dat += "<b>Blood Type:</b> <a href='?_src_=prefs;preference=b_type;task=input'>[active_character.b_type]</a><br>"
			if(S.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
				dat += "<b>Skin Tone:</b> <a href='?_src_=prefs;preference=s_tone;task=input'>[S.bodyflags & HAS_ICON_SKIN_TONE ? "[active_character.s_tone]" : "[-active_character.s_tone + 35]/220"]</a><br>"
			dat += "<b>Disabilities:</b> <a href='?_src_=prefs;preference=disabilities'>\[Set\]</a><br>"
			dat += "<b>Nanotrasen Relation:</b> <a href ='?_src_=prefs;preference=nt_relation;task=input'>[active_character.nanotrasen_relation]</a><br>"
			dat += "<a href='byond://?_src_=prefs;preference=flavor_text;task=input'>Set Flavor Text</a><br>"
			if(length(active_character.flavor_text) <= 40)
				if(!length(active_character.flavor_text))
					dat += "\[...\]<br>"
				else
					dat += "[active_character.flavor_text]<br>"
			else dat += "[TextPreview(active_character.flavor_text)]...<br>"

			dat += "<h2>Hair & Accessories</h2>"

			if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
				var/headaccessoryname = "Head Accessory: "
				if(active_character.species == "Unathi")
					headaccessoryname = "Horns: "
				dat += "<b>[headaccessoryname]</b>"
				dat += "<a href='?_src_=prefs;preference=ha_style;task=input'>[active_character.ha_style]</a> "
				dat += "<a href='?_src_=prefs;preference=headaccessory;task=input'>Color</a> [color_square(active_character.hacc_colour)]<br>"

			if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
				dat += "<b>Head Markings:</b> "
				dat += "<a href='?_src_=prefs;preference=m_style_head;task=input'>[active_character.m_styles["head"]]</a>"
				dat += "<a href='?_src_=prefs;preference=m_head_colour;task=input'>Color</a> [color_square(active_character.m_colours["head"])]<br>"
			if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
				dat += "<b>Body Markings:</b> "
				dat += "<a href='?_src_=prefs;preference=m_style_body;task=input'>[active_character.m_styles["body"]]</a>"
				dat += "<a href='?_src_=prefs;preference=m_body_colour;task=input'>Color</a> [color_square(active_character.m_colours["body"])]<br>"
			if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
				dat += "<b>Tail Markings:</b> "
				dat += "<a href='?_src_=prefs;preference=m_style_tail;task=input'>[active_character.m_styles["tail"]]</a>"
				dat += "<a href='?_src_=prefs;preference=m_tail_colour;task=input'>Color</a> [color_square(active_character.m_colours["tail"])]<br>"

			dat += "<b>Hair:</b> "
			dat += "<a href='?_src_=prefs;preference=h_style;task=input'>[active_character.h_style]</a>"
			dat += "<a href='?_src_=prefs;preference=hair;task=input'>Color</a> [color_square(active_character.h_colour)]"
			var/datum/sprite_accessory/temp_hair_style = GLOB.hair_styles_public_list[active_character.h_style]
			if(temp_hair_style && temp_hair_style.secondary_theme && !temp_hair_style.no_sec_colour)
				dat += " <a href='?_src_=prefs;preference=secondary_hair;task=input'>Color #2</a> [color_square(active_character.h_sec_colour)]"
			// Hair gradient
			dat += "<br>"
			dat += "- <b>Gradient:</b>"
			dat += " <a href='?_src_=prefs;preference=h_grad_style;task=input'>[active_character.h_grad_style]</a>"
			dat += " <a href='?_src_=prefs;preference=h_grad_colour;task=input'>Color</a> [color_square(active_character.h_grad_colour)]"
			dat += " <a href='?_src_=prefs;preference=h_grad_alpha;task=input'>[active_character.h_grad_alpha]</a>"
			dat += "<br>"
			dat += "- <b>Gradient Offset:</b> <a href='?_src_=prefs;preference=h_grad_offset;task=input'>[active_character.h_grad_offset_x],[active_character.h_grad_offset_y]</a>"
			dat += "<br>"

			dat += "<b>Facial Hair:</b> "
			dat += "<a href='?_src_=prefs;preference=f_style;task=input'>[active_character.f_style ? "[active_character.f_style]" : "Shaved"]</a>"
			dat += "<a href='?_src_=prefs;preference=facial;task=input'>Color</a> [color_square(active_character.f_colour)]"
			var/datum/sprite_accessory/temp_facial_hair_style = GLOB.facial_hair_styles_list[active_character.f_style]
			if(temp_facial_hair_style && temp_facial_hair_style.secondary_theme && !temp_facial_hair_style.no_sec_colour)
				dat += " <a href='?_src_=prefs;preference=secondary_facial;task=input'>Color #2</a> [color_square(active_character.f_sec_colour)]"
			dat += "<br>"


			if(!(S.bodyflags & ALL_RPARTS))
				dat += "<b>Eyes:</b> "
				dat += "<a href='?_src_=prefs;preference=eyes;task=input'>Color</a> [color_square(active_character.e_colour)]<br>"

			if((S.bodyflags & HAS_SKIN_COLOR) || GLOB.body_accessory_by_species[active_character.species] || check_rights(R_ADMIN, 0, user)) //admins can always fuck with this, because they are admins
				dat += "<b>Body Color:</b> "
				dat += "<a href='?_src_=prefs;preference=skin;task=input'>Color</a> [color_square(active_character.s_colour)]<br>"

			if(GLOB.body_accessory_by_species[active_character.species] || check_rights(R_ADMIN, 0, user))
				dat += "<b>Body Accessory:</b> "
				dat += "<a href='?_src_=prefs;preference=body_accessory;task=input'>[active_character.body_accessory ? "[active_character.body_accessory]" : "None"]</a><br>"

			dat += "</td><td width='405px' height='200px' valign='top'>"
			dat += "<h2>Occupation Choices</h2>"
			dat += "<a href='?_src_=prefs;preference=job;task=menu'>Set Occupation Preferences</a><br>"
			if(jobban_isbanned(user, ROLEBAN_RECORDS))
				dat += "<b>You are banned from using character records.</b><br>"
			else
				dat += "<a href=\"byond://?_src_=prefs;preference=records;record=1\">Character Records</a><br>"

			dat += "<h2>Limbs</h2>"
			if(S.bodyflags & HAS_ALT_HEADS) //Species with alt heads.
				dat += "<b>Alternate Head:</b> "
				dat += "<a href='?_src_=prefs;preference=alt_head;task=input'>[active_character.alt_head]</a><br>"
			dat += "<b>Limbs and Parts:</b> <a href='?_src_=prefs;preference=limbs;task=input'>Adjust</a><br>"
			if(active_character.species != "Slime People" && active_character.species != "Machine")
				dat += "<b>Internal Organs:</b> <a href='?_src_=prefs;preference=organs;task=input'>Adjust</a><br>"

			//display limbs below
			var/ind = 0
			for(var/name in active_character.organ_data)
				var/status = active_character.organ_data[name]
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
					if("ears")
						organ_name = "ears"
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
						if(active_character.rlimb_data[name] && GLOB.all_robolimbs[active_character.rlimb_data[name]])
							R = GLOB.all_robolimbs[active_character.rlimb_data[name]]
						else
							R = GLOB.basic_robolimb
						dat += "\t[R.company] [organ_name] prosthesis"
					if("amputated")
						dat += "\tAmputated [organ_name]"
					if("cybernetic")
						dat += "\tCybernetic [organ_name]"
			if(!ind)	dat += "\[...\]<br>"
			else		dat += "<br>"

			dat += "<h2>Clothing</h2>"
			if(S.clothing_flags & HAS_UNDERWEAR)
				dat += "<b>Underwear:</b> <a href ='?_src_=prefs;preference=underwear;task=input'>[active_character.underwear]</a><BR>"
			if(S.clothing_flags & HAS_UNDERSHIRT)
				dat += "<b>Undershirt:</b> <a href ='?_src_=prefs;preference=undershirt;task=input'>[active_character.undershirt]</a><BR>"
			if(S.clothing_flags & HAS_SOCKS)
				dat += "<b>Socks:</b> <a href ='?_src_=prefs;preference=socks;task=input'>[active_character.socks]</a><BR>"
			dat += "<b>Backpack Type:</b> <a href ='?_src_=prefs;preference=bag;task=input'>[active_character.backbag]</a><br>"

			dat += "</td></tr></table>"

		if(TAB_GAME) // General Preferences
			// LEFT SIDE OF THE PAGE
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
			dat += "<h2>General Settings</h2>"
			dat += "<b>2FA Setup:</b> <a href='?_src_=prefs;preference=edit_2fa'>[_2fastatus_to_text()]</a><br>"
			if(user.client.holder)
				dat += "<b>Adminhelp sound:</b> <a href='?_src_=prefs;preference=hear_adminhelps'><b>[(sound & SOUND_ADMINHELP)?"On":"Off"]</b></a><br>"
			dat += "<b>AFK Cryoing:</b> <a href='?_src_=prefs;preference=afk_watch'>[(toggles2 & PREFTOGGLE_2_AFKWATCH) ? "Yes" : "No"]</a><br>"
			dat += "<b>Ambient Occlusion:</b> <a href='?_src_=prefs;preference=ambientocclusion'><b>[toggles & PREFTOGGLE_AMBIENT_OCCLUSION ? "Enabled" : "Disabled"]</b></a><br>"
			dat += "<b>Attack Animations:</b> <a href='?_src_=prefs;preference=ghost_att_anim'>[(toggles2 & PREFTOGGLE_2_ITEMATTACK) ? "Yes" : "No"]</a><br>"
			if(unlock_content)
				dat += "<b>BYOND Membership Publicity:</b> <a href='?_src_=prefs;preference=publicity'><b>[(toggles & PREFTOGGLE_MEMBER_PUBLIC) ? "Public" : "Hidden"]</b></a><br>"
			dat += "<b>Custom UI settings:</b><br>"
			dat += " - <b>Alpha (transparency):</b> <a href='?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a><br>"
			dat += " - <b>Color:</b> <a href='?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b></a> <span style='border: 1px solid #161616; background-color: [UI_style_color];'>&nbsp;&nbsp;&nbsp;</span><br>"
			dat += " - <b>UI Style:</b> <a href='?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>"
			dat += "<b>Deadchat Anonymity:</b> <a href='?_src_=prefs;preference=ghost_anonsay'><b>[toggles2 & PREFTOGGLE_2_ANONDCHAT ? "Anonymous" : "Not Anonymous"]</b></a><br>"
			if(user.client.donator_level > 0)
				dat += "<b>Donator Publicity:</b> <a href='?_src_=prefs;preference=donor_public'><b>[(toggles & PREFTOGGLE_DONATOR_PUBLIC) ? "Public" : "Hidden"]</b></a><br>"
			dat += "<b>Fancy TGUI:</b> <a href='?_src_=prefs;preference=tgui'>[(toggles2 & PREFTOGGLE_2_FANCYUI) ? "Yes" : "No"]</a><br>"
			dat += "<b>FPS:</b>	 <a href='?_src_=prefs;preference=clientfps;task=input'>[clientfps]</a><br>"
			dat += "<b>Ghost Ears:</b> <a href='?_src_=prefs;preference=ghost_ears'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</b></a><br>"
			dat += "<b>Ghost Radio:</b> <a href='?_src_=prefs;preference=ghost_radio'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTRADIO) ? "All Chatter" : "Nearest Speakers"]</b></a><br>"
			dat += "<b>Ghost Sight:</b> <a href='?_src_=prefs;preference=ghost_sight'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</b></a><br>"
			dat += "<b>Ghost PDA:</b> <a href='?_src_=prefs;preference=ghost_pda'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTPDA) ? "All PDA Messages" : "No PDA Messages"]</b></a><br>"
			if(check_rights(R_ADMIN,0))
				dat += "<b>OOC Color:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : GLOB.normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ooccolor;task=input'><b>Change</b></a><br>"
			if(GLOB.configuration.general.allow_character_metadata)
				dat += "<b>OOC Notes:</b> <a href='?_src_=prefs;preference=metadata;task=input'><b>Edit</b></a><br>"
			dat += "<b>Parallax (Fancy Space):</b> <a href='?_src_=prefs;preference=parallax'>"
			switch (parallax)
				if(PARALLAX_LOW)
					dat += "Low"
				if(PARALLAX_MED)
					dat += "Medium"
				if(PARALLAX_INSANE)
					dat += "Insane"
				if(PARALLAX_DISABLE)
					dat += "Disabled"
				else
					dat += "High"
			dat += "</a><br>"
			dat += "<b>Set screentip mode:</b> <a href='?_src_=prefs;preference=screentip_mode'>[(screentip_mode == 0) ? "Disabled" : "[screentip_mode]px"]</a><br>"
			dat += "<b>Screentip color:</b> <span style='border: 1px solid #161616; background-color: [screentip_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=screentip_color'><b>Change</b></a><br>"
			dat += "<b>Play Admin MIDIs:</b> <a href='?_src_=prefs;preference=hear_midis'><b>[(sound & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Play Lobby Music:</b> <a href='?_src_=prefs;preference=lobby_music'><b>[(sound & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Randomized Character Slot:</b> <a href='?_src_=prefs;preference=randomslot'><b>[toggles2 & PREFTOGGLE_2_RANDOMSLOT ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Window Flashing:</b> <a href='?_src_=prefs;preference=winflash'>[(toggles2 & PREFTOGGLE_2_WINDOWFLASHING) ? "Yes" : "No"]</a><br>"
			// RIGHT SIDE OF THE PAGE
			dat += "</td><td width='300px' height='300px' valign='top'>"
			dat += "<h2>Special Role Settings</h2>"
			if(jobban_isbanned(user, ROLE_SYNDICATE))
				dat += "<b>You are banned from special roles.</b>"
				be_special = list()
			else
				for(var/i in GLOB.special_roles)
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
			var/total_cost = build_loadout()

			var/fcolor = "#3366CC"
			if(total_cost < max_gear_slots)
				fcolor = "#E67300"
			dat += "<table align='center' width='100%'>"
			dat += "<tr><td colspan=4><center><b><font color='[fcolor]'>[total_cost]/[max_gear_slots]</font> loadout points spent.</b> \[<a href='?_src_=prefs;preference=gear;clear_loadout=1'>Clear Loadout</a>\]</center></td></tr>"
			dat += "<tr><td colspan=4><center><b>"

			var/firstcat = 1
			for(var/category in GLOB.loadout_categories)
				if(firstcat)
					firstcat = 0
				else
					dat += " |"
				if(category == gear_tab)
					dat += " <span class='linkOff'>[category]</span> "
				else
					dat += " <a href='?_src_=prefs;preference=gear;select_category=[category]'>[category]</a> "
			dat += "</b></center></td></tr>"

			var/datum/loadout_category/LC = GLOB.loadout_categories[gear_tab]
			dat += "<tr><td colspan=4><hr></td></tr>"
			dat += "<tr><td colspan=4><b><center>[LC.category]</center></b></td></tr>"
			dat += "<tr><td colspan=4><hr></td></tr>"
			for(var/gear_name in LC.gear)
				var/datum/gear/G = LC.gear[gear_name]
				var/ticked = (G.type in active_character.loadout_gear)
				if(G.donator_tier > user.client.donator_level)
					dat += "<tr style='vertical-align:top;'><td width=15%><B>[G.display_name]</B></td>"
				else
					dat += "<tr style='vertical-align:top;'><td width=15%><a style='white-space:normal;' [ticked ? "class='linkOn' " : ""]href='?_src_=prefs;preference=gear;toggle_gear=[G.type]'>[G.display_name]</a></td>"
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
						. += " <a href='?_src_=prefs;preference=gear;gear=[G.type];tweak=\ref[tweak]'>[tweak.get_contents(active_character.get_tweak_metadata(G, tweak))]</a>"
					. += "</td></tr>"
			dat += "</table>"

	dat += "<hr><center>"
	if(!IsGuestKey(user.key))
		dat += "<a href='?_src_=prefs;preference=load'>Undo</a> - "
		dat += "<a href='?_src_=prefs;preference=save'>Save Setup</a> - "

	dat += "<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center>"

	var/datum/browser/popup = new(user, "preferences", "<div align='center'>Character Setup</div>", 820, 660)
	popup.set_content(dat)
	popup.open(0)

/datum/preferences/proc/open_load_dialog(mob/user)
	var/dat = "<body>"
	dat += "<tt><center>"
	dat += "<b>Select a character slot to load</b><hr>"
	var/name

	for(var/i in 1 to length(character_saves))
		var/datum/character_save/CS = character_saves[i]
		if(CS.from_db)
			name = CS.real_name
		else
			name = "Character [i]"
		if(i == default_slot)
			name = "<b>[name]</b>"
		dat += "<a href='?_src_=prefs;preference=changeslot;num=[i];'>[name]</a><br>"

	dat += "<hr>"
	dat += "<a href='byond://?_src_=prefs;preference=close_load_dialog'>Close</a><br>"
	dat += "</center></tt>"

	var/datum/browser/popup = new(user, "saves", "<div align='center'>Character Saves</div>", 300, 390)
	popup.set_content(dat)
	popup.open(0)

/datum/preferences/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")


/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	var/datum/job/job = SSjobs.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if(!isnum(desiredLvl))
		to_chat(user, "<span class='warning'>UpdateJobPreference - desired level was not a number. Please notify coders!</span>")
		ShowChoices(user)
		return

	if(role == "Assistant")
		if(active_character.job_support_low & job.flag)
			active_character.job_support_low &= ~job.flag
		else
			active_character.job_support_low |= job.flag
		active_character.SetChoices(user)
		return 1

	active_character.SetJobPreferenceLevel(job, desiredLvl)
	active_character.SetChoices(user)

	return 1

// This is scoped here instead of /datum/character_save just because of ShowChoices()
/datum/preferences/proc/SetJob(mob/user, role)
	var/datum/job/job = SSjobs.GetJob(role)
	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if(role == "Assistant")
		if(active_character.job_support_low & job.flag)
			active_character.job_support_low &= ~job.flag
		else
			active_character.job_support_low |= job.flag
		active_character.SetChoices(user)
		return 1

	if(active_character.GetJobDepartment(job, 1) & job.flag)
		active_character.SetJobDepartment(job, 1)
	else if(active_character.GetJobDepartment(job, 2) & job.flag)
		active_character.SetJobDepartment(job, 2)
	else if(active_character.GetJobDepartment(job, 3) & job.flag)
		active_character.SetJobDepartment(job, 3)
	else//job = Never
		active_character.SetJobDepartment(job, 4)

	active_character.SetChoices(user)
	return 1

/**
  * Rebuilds the `loadout_gear` list of the [active_character], and returns the total end cost.
  *
  * Caches and cuts the existing [/datum/character_save/var/loadout_gear] list and remakes it, checking the `subtype_selection_cost` and overall cost validity of each item.
  *
  * If the item's [/datum/gear/var/subtype_selection_cost] is `FALSE`, any future items with the same [/datum/gear/var/main_typepath] will have their cost skipped.
  * If adding the item will take the total cost over the maximum, it won't be added to the list.
  *
  * Arguments:
  * * new_item - A new [/datum/gear] item to be added to the `loadout_gear` list.
  */
/datum/preferences/proc/build_loadout(datum/gear/new_item)
	var/total_cost = 0
	var/list/type_blacklist = list()
	var/list/loadout_cache = active_character.loadout_gear.Copy()
	active_character.loadout_gear.Cut()
	if(new_item)
		loadout_cache += new_item.type

	for(var/I in loadout_cache)
		var/datum/gear/G = GLOB.gear_datums[text2path(I) || I]
		if(!G)
			continue
		var/added_cost = G.cost
		if(!G.subtype_selection_cost) // If listings of the same subtype shouldn't have their cost added.
			if(G.main_typepath in type_blacklist)
				added_cost = 0
			else
				type_blacklist += G.main_typepath

		if((total_cost + added_cost) > max_gear_slots)
			continue // If the final cost is too high, don't add the item.
		active_character.loadout_gear += G.type
		total_cost += added_cost
	return total_cost
