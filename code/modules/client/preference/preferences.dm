/// Minimum age (in days) for accounts to play these roles.
GLOBAL_LIST_INIT(special_role_times, list(
	ROLE_PAI = 0,
	ROLE_GUARDIAN = 0,
	ROLE_TRAITOR = 7,
	ROLE_CHANGELING = 14,
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
	ROLE_ELITE = 21,
// 	ROLE_GANG = 21,
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

	//game-preferences
	var/lastchangelog = "1"				//Saved changlog timestamp (unix epoch) to detect if there was a change. Dont set this to 0 unless you want the last changelog date to be 4x longer than the expected lifespan of the universe.
	var/lastchangelog_2 = "1" // Clone of the above var for viewing changes since last connection. This is never overriden. Yes it needs to exist.
	var/exp
	var/ooccolor = "#b82e00"
	var/list/be_special = list()				//Special role selection
	var/UI_style = "Midnight"
	var/toggles = TOGGLES_DEFAULT
	var/toggles2 = TOGGLES_2_DEFAULT // Created because 1 column has a bitflag limit of 24 (BYOND limitation not MySQL)
	var/toggles3 = TOGGLES_3_DEFAULT // Created for see above. I need to JSONify this at some point -aa07
	var/sound = SOUND_DEFAULT
	var/light = LIGHT_DEFAULT
	/// Glow level for the lighting. Takes values from GLOW_HIGH to GLOW_DISABLE.
	var/glowlevel = GLOW_MED
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255
	/// This value will be converted by BYOND, don't set already converted values there, otherwise it will set client's fps 1 step higher than it should've
	var/clientfps = 100
	var/atklog = ATKLOG_ALL
	/// Forum userid
	var/fuid

	/// Volume mixer, indexed by channel as TEXT (numerical indexes will not work). Volume goes from 0 to 100.
	var/list/volume_mixer = list(
		"1012" = 100, // CHANNEL_GENERAL	//Note: This should stay on top because order in this list defines order of sliders in mixer's interface.
		"1024" = 100, // CHANNEL_LOBBYMUSIC
		"1023" = 100, // CHANNEL_ADMIN
		"1022" = 100, // CHANNEL_VOX
		"1021" = 100, // CHANNEL_JUKEBOX
		"1020" = 100, // CHANNEL_HEARTBEAT
		"1019" = 100, // CHANNEL_BUZZ
		"1018" = 100, // CHANNEL_AMBIENCE
		"1017" = 100, // CHANNEL_ENGINE
		"1016" = 100, // CHANNEL_FIREALARM
		"1015" = 100, // CHANNEL_ASH_STORM
		"1014" = 100, // CHANNEL_RADIO_NOISE
		"1013" = 100, // CHANNEL_BOSS_MUSIC
		"1011" = 100 // CHANNEL_SURGERY_SOUNDS
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
	/// Colourblind mode
	var/colourblind_mode = COLOURBLIND_MODE_NONE
	/// Active keybinds (currently useable by the mob/client)
	var/list/datum/keybindings = list()
	/// Keybinding overrides ("name" => ["key"...])
	var/list/keybindings_overrides = null
	/// Player's region override for routing optimisation
	var/server_region = null
	/// List of admin ckeys this player wont hear sounds from
	var/list/admin_sound_ckey_ignore = list()
	/// View range preference for this client
	var/viewrange = DEFAULT_CLIENT_VIEWSIZE
	/// Map preferences for the first past the post system
	var/list/map_vote_pref_json = list()

/datum/preferences/New(client/C, datum/db_query/Q) // Process our query
	parent = C

	max_gear_slots = GLOB.configuration.general.base_loadout_points

	parent?.set_macros()

	if(!SSdbcore.IsConnected())
		init_keybindings() //we want default keybinds, even if DB is not connected
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
	if(SSatoms.initialized) // DNA won't be set up on our dummy mob if it's not ready
		active_character.update_preview_icon()
		user << browse_rsc(active_character.preview_icon_front, "previewicon.png")
		user << browse_rsc(active_character.preview_icon_side, "previewicon2.png")

	var/list/dat = list()
	dat += "<center>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=[TAB_CHAR]' 	[current_tab == TAB_CHAR 	? "class='linkOn'" : ""]>Character Settings</a>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=[TAB_GAME]' 	[current_tab == TAB_GAME 	? "class='linkOn'" : ""]>Game Preferences</a>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=[TAB_ANTAG]' 	[current_tab == TAB_ANTAG 	? "class='linkOn'" : ""]>Antagonists and Maps</a>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=[TAB_KEYS]' 	[current_tab == TAB_KEYS 	? "class='linkOn'" : ""]>Key Bindings</a>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=[TAB_TOGGLES]' [current_tab == TAB_TOGGLES ? "class='linkOn'" : ""]>General Preferences</a>"
	dat += "</center>"
	dat += "<hr>"

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
			dat += "<a href='byond://?_src_=prefs;preference=name;task=input'><b>[active_character.real_name]</b></a>"
			dat += "<a href='byond://?_src_=prefs;preference=name;task=random'>(Randomize)</a>"
			dat += "<a href='byond://?_src_=prefs;preference=name'><span class='[active_character.be_random_name ? "good" : "bad"]'>(Always Randomize)</span></a><br>"
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
			dat += "<b>Age:</b> <a href='byond://?_src_=prefs;preference=age;task=input'>[active_character.age]</a><br>"
			dat += "<b>Body:</b> <a href='byond://?_src_=prefs;preference=all;task=random'>(Randomize)</a><br>"
			dat += "<b>Species:</b> <a href='byond://?_src_=prefs;preference=species;task=input'>[active_character.species]</a><br>"
			dat += "<b>Gender:</b> <a href='byond://?_src_=prefs;preference=gender'>[active_character.gender == MALE ? "Male" : (active_character.gender == FEMALE ? "Female" : "Genderless")]</a><br>"
			dat += "<b>Body Type:</b> <a href='byond://?_src_=prefs;preference=body_type'>[active_character.body_type == MALE ? "Masculine" : "Feminine"]</a>"
			dat += "<br>"
			dat += "<b>Runechat Color:</b> "
			dat += "<a href='byond://?_src_=prefs;preference=runechat_color;task=input'>Color</a> [color_square(active_character.runechat_color)]<br>"
			if(active_character.species == "Vox") // Purge these bastards
				dat += "<b>N2 Tank:</b> <a href='byond://?_src_=prefs;preference=speciesprefs;task=input'>[active_character.speciesprefs ? "Large N2 Tank" : "Specialized N2 Tank"]</a><br>"
			if(active_character.species == "Plasmaman")
				dat += "<b>Plasma Tank:</b> <a href='byond://?_src_=prefs;preference=speciesprefs;task=input'>[active_character.speciesprefs ? "Large Plasma Tank" : "Specialized Plasma Tank"]</a><br>"
			if(active_character.species == "Grey")
				dat += "<b>Wingdings:</b> Set in disabilities<br>"
				dat += "<b>Voice Translator:</b> <a href='byond://?_src_=prefs;preference=speciesprefs;task=input'>[active_character.speciesprefs ? "Yes" : "No"]</a><br>"
			dat += "<b>Secondary Language:</b> <a href='byond://?_src_=prefs;preference=language;task=input'>[active_character.language]</a><br>"
			if(S.autohiss_basic_map)
				dat += "<b>Auto-accent:</b> <a href='byond://?_src_=prefs;preference=autohiss_mode;task=input'>[active_character.autohiss_mode == AUTOHISS_FULL ? "Full" : (active_character.autohiss_mode == AUTOHISS_BASIC ? "Basic" : "Off")]</a><br>"
			if(NO_BLOOD in S.species_traits) // unique blood type for species with no_blood/unique_blood
				active_character.b_type = "None"
			else
				if(active_character.species == "Slime People")
					active_character.b_type = "Slime Jelly"
				else
					if(active_character.b_type == "None" || active_character.b_type == "Slime Jelly")
						active_character.b_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")
					dat += "<b>Blood Type:</b> <a href='byond://?_src_=prefs;preference=b_type;task=input'>[active_character.b_type]</a><br>"
			if(S.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
				dat += "<b>Skin Tone:</b> <a href='byond://?_src_=prefs;preference=s_tone;task=input'>[S.bodyflags & HAS_ICON_SKIN_TONE ? "[active_character.s_tone]" : "[-active_character.s_tone + 35]/220"]</a><br>"
			dat += "<b>Disabilities:</b> <a href='byond://?_src_=prefs;preference=disabilities'>\[Set\]</a><br>"
			dat += "<b>Nanotrasen Relation:</b> <a href='byond://?_src_=prefs;preference=nt_relation;task=input'>[active_character.nanotrasen_relation]</a><br>"
			dat += "<b>Physique:</b> <a href='byond://?_src_=prefs;preference=physique;task=input'>[active_character.physique]</a><br>"
			dat += "<b>Height:</b> <a href='byond://?_src_=prefs;preference=height;task=input'>[active_character.height]</a><br>"
			dat += "<b>Cyborg Brain Type:</b> <a href='byond://?_src_=prefs;preference=cyborg_brain_type;task=input'>[active_character.cyborg_brain_type]</a><br>"
			dat += "<b>PDA Ringtone:</b> <a href='byond://?_src_=prefs;preference=pda_ringtone;task=input'>[active_character.pda_ringtone]</a><br>"
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
				dat += "<a href='byond://?_src_=prefs;preference=ha_style;task=input'>[active_character.ha_style]</a> "
				dat += "<a href='byond://?_src_=prefs;preference=headaccessory;task=input'>Color</a> [color_square(active_character.hacc_colour)]<br>"

			if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
				dat += "<b>Head Markings:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=m_style_head;task=input'>[active_character.m_styles["head"]]</a>"
				dat += "<a href='byond://?_src_=prefs;preference=m_head_colour;task=input'>Color</a> [color_square(active_character.m_colours["head"])]<br>"
			if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
				dat += "<b>Body Markings:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=m_style_body;task=input'>[active_character.m_styles["body"]]</a>"
				dat += "<a href='byond://?_src_=prefs;preference=m_body_colour;task=input'>Color</a> [color_square(active_character.m_colours["body"])]<br>"
			if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
				dat += "<b>Tail Markings:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=m_style_tail;task=input'>[active_character.m_styles["tail"]]</a>"
				dat += "<a href='byond://?_src_=prefs;preference=m_tail_colour;task=input'>Color</a> [color_square(active_character.m_colours["tail"])]<br>"
			if(!(S.bodyflags & BALD))
				dat += "<b>Hair:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=h_style;task=input'>[active_character.h_style]</a>"
				dat += "<a href='byond://?_src_=prefs;preference=hair;task=input'>Color</a> [color_square(active_character.h_colour)]"
				var/datum/sprite_accessory/temp_hair_style = GLOB.hair_styles_public_list[active_character.h_style]
				if(temp_hair_style && temp_hair_style.secondary_theme && !temp_hair_style.no_sec_colour)
					dat += " <a href='byond://?_src_=prefs;preference=secondary_hair;task=input'>Color #2</a> [color_square(active_character.h_sec_colour)]"
				// Hair gradient
				dat += "<br>"
				dat += "- <b>Gradient:</b>"
				dat += " <a href='byond://?_src_=prefs;preference=h_grad_style;task=input'>[active_character.h_grad_style]</a>"
				dat += " <a href='byond://?_src_=prefs;preference=h_grad_colour;task=input'>Color</a> [color_square(active_character.h_grad_colour)]"
				dat += " <a href='byond://?_src_=prefs;preference=h_grad_alpha;task=input'>[active_character.h_grad_alpha]</a>"
				dat += "<br>"
				dat += "- <b>Gradient Offset:</b> <a href='byond://?_src_=prefs;preference=h_grad_offset;task=input'>[active_character.h_grad_offset_x],[active_character.h_grad_offset_y]</a>"
				dat += "<br>"
			else
				active_character.h_style = "Bald"
			if(!(S.bodyflags & SHAVED))
				dat += "<b>Facial Hair:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=f_style;task=input'>[active_character.f_style ? "[active_character.f_style]" : "Shaved"]</a>"
				dat += "<a href='byond://?_src_=prefs;preference=facial;task=input'>Color</a> [color_square(active_character.f_colour)]"
				var/datum/sprite_accessory/temp_facial_hair_style = GLOB.facial_hair_styles_list[active_character.f_style]
				if(temp_facial_hair_style && temp_facial_hair_style.secondary_theme && !temp_facial_hair_style.no_sec_colour)
					dat += " <a href='byond://?_src_=prefs;preference=secondary_facial;task=input'>Color #2</a> [color_square(active_character.f_sec_colour)]"
				dat += "<br>"
			else
				active_character.f_style = "Shaved"


			if(!(S.bodyflags & ALL_RPARTS) && (S.eyes != "blank_eyes") && !(S.bodyflags & NO_EYES))
				dat += "<b>Eyes:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=eyes;task=input'>Color</a> [color_square(active_character.e_colour)]<br>"

			if((S.bodyflags & HAS_SKIN_COLOR) || ((S.bodyflags & HAS_BODYACC_COLOR) && GLOB.body_accessory_by_species[active_character.species]) || check_rights(R_ADMIN, 0, user)) //admins can always fuck with this, because they are admins
				dat += "<b>Body Color:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=skin;task=input'>Color</a> [color_square(active_character.s_colour)]<br>"

			if(GLOB.body_accessory_by_species[active_character.species] || check_rights(R_ADMIN, 0, user))
				dat += "<b>Body Accessory:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=body_accessory;task=input'>[active_character.body_accessory ? "[active_character.body_accessory]" : "None"]</a><br>"

			dat += "</td><td width='405px' height='200px' valign='top'>"
			dat += "<h2>Occupation Choices</h2>"
			dat += "<a href='byond://?_src_=prefs;preference=job;task=menu'>Set Occupation Preferences</a><br>"
			if(jobban_isbanned(user, ROLEBAN_RECORDS))
				dat += "<b>You are banned from using character records.</b><br>"
			else
				dat += "<a href=\"byond://?_src_=prefs;preference=records;record=1\">Character Records</a><br>"

			dat += "<h2>Limbs</h2>"
			if(S.bodyflags & HAS_ALT_HEADS) //Species with alt heads.
				dat += "<b>Alternate Head:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=alt_head;task=input'>[active_character.alt_head]</a><br>"
			dat += "<b>Limbs and Parts:</b> <a href='byond://?_src_=prefs;preference=limbs;task=input'>Adjust</a><br>"
			if(active_character.species != "Slime People" && active_character.species != "Machine")
				dat += "<b>Internal Organs:</b> <a href='byond://?_src_=prefs;preference=organs;task=input'>Adjust</a><br>"

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
				dat += "<b>Underwear:</b> <a href='byond://?_src_=prefs;preference=underwear;task=input'>[active_character.underwear]</a><BR>"
			if(S.clothing_flags & HAS_UNDERSHIRT)
				dat += "<b>Undershirt:</b> <a href='byond://?_src_=prefs;preference=undershirt;task=input'>[active_character.undershirt]</a><BR>"
			if(S.clothing_flags & HAS_SOCKS)
				dat += "<b>Socks:</b> <a href='byond://?_src_=prefs;preference=socks;task=input'>[active_character.socks]</a><BR>"
			dat += "<b>Backpack Type:</b> <a href='byond://?_src_=prefs;preference=bag;task=input'>[active_character.backbag]</a><br><br>"
			dat += "<a style='font-size: 1.5em;' href='byond://?_src_=prefs;preference=loadout;task=input'>Open Loadout</a><br>"

			var/datum/species/myspecies = GLOB.all_species[active_character.species]
			if(!isnull(myspecies))
				dat += "<h2>Species Information</h2>"
				dat += "<br><b>Species Description:</b> [myspecies.blurb]<br>"

			dat += "</td></tr></table>"

		if(TAB_GAME) // General Preferences
			// LEFT SIDE OF THE PAGE
			dat += "<table><tr><td width='405px' height='300px' valign='top'>"
			dat += "<h2>General Settings</h2>"
			dat += "<b>2FA Setup:</b> <a href='byond://?_src_=prefs;preference=edit_2fa'>[_2fastatus_to_text()]</a><br>"
			if(user.client.holder)
				dat += "<b>Adminhelp sound:</b> <a href='byond://?_src_=prefs;preference=hear_adminhelps'><b>[(sound & SOUND_ADMINHELP)?"On":"Off"]</b></a><br>"
			dat += "<b>AFK Cryoing:</b> <a href='byond://?_src_=prefs;preference=afk_watch'>[(toggles2 & PREFTOGGLE_2_AFKWATCH) ? "Yes" : "No"]</a><br>"
			dat += "<b>Ambient Occlusion:</b> <a href='byond://?_src_=prefs;preference=ambientocclusion'><b>[toggles & PREFTOGGLE_AMBIENT_OCCLUSION ? "Enabled" : "Disabled"]</b></a><br>"
			dat += "<b>Attack Animations:</b> <a href='byond://?_src_=prefs;preference=ghost_att_anim'>[(toggles2 & PREFTOGGLE_2_ITEMATTACK) ? "Yes" : "No"]</a><br>"
			if(unlock_content)
				dat += "<b>BYOND Membership Publicity:</b> <a href='byond://?_src_=prefs;preference=publicity'><b>[(toggles & PREFTOGGLE_MEMBER_PUBLIC) ? "Public" : "Hidden"]</b></a><br>"
			dat += "<b>CKEY Anonymity:</b> <a href='byond://?_src_=prefs;preference=anonmode'><b>[toggles2 & PREFTOGGLE_2_ANON ? "Anonymous" : "Not Anonymous"]</b></a><br>"
			dat += "<b>Colourblind Mode:</b> <a href='byond://?_src_=prefs;preference=cbmode'>[colourblind_mode]</a><br>"
			if(user.client.donator_level > 0)
				dat += "<b>Donator Publicity:</b> <a href='byond://?_src_=prefs;preference=donor_public'><b>[(toggles & PREFTOGGLE_DONATOR_PUBLIC) ? "Public" : "Hidden"]</b></a><br>"
			dat += "<b>FPS:</b>	 <a href='byond://?_src_=prefs;preference=clientfps;task=input'>[user.client.fps]</a><br>"
			dat += "<b>Ghost Ears:</b> <a href='byond://?_src_=prefs;preference=ghost_ears'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</b></a><br>"
			dat += "<b>Ghost Radio:</b> <a href='byond://?_src_=prefs;preference=ghost_radio'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTRADIO) ? "All Chatter" : "Nearest Speakers"]</b></a><br>"
			dat += "<b>Ghost Sight:</b> <a href='byond://?_src_=prefs;preference=ghost_sight'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</b></a><br>"
			dat += "<b>Ghost PDA:</b> <a href='byond://?_src_=prefs;preference=ghost_pda'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTPDA) ? "All PDA Messages" : "No PDA Messages"]</b></a><br>"
			if(check_rights(R_ADMIN,0))
				dat += "<b>OOC Color:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : GLOB.normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='byond://?_src_=prefs;preference=ooccolor;task=input'><b>Change</b></a><br>"
			if(GLOB.configuration.general.allow_character_metadata)
				dat += "<b>OOC Notes:</b> <a href='byond://?_src_=prefs;preference=metadata;task=input'><b>Edit</b></a><br>"
			dat += "<b>Parallax (Fancy Space):</b> <a href='byond://?_src_=prefs;preference=parallax'>"
			switch(parallax)
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
			dat += "<b>Parallax in darkness:</b> <a href='byond://?_src_=prefs;preference=parallax_darkness'>[toggles2 & PREFTOGGLE_2_PARALLAX_IN_DARKNESS ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>TGUI strip menu size:</b> <a href='byond://?_src_=prefs;preference=tgui_strip_menu'>[toggles2 & PREFTOGGLE_2_BIG_STRIP_MENU ? "Full-size" : "Miniature"]</a><br>"
			dat += "<b>Play Admin MIDIs:</b> <a href='byond://?_src_=prefs;preference=hear_midis'><b>[(sound & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Play Lobby Music:</b> <a href='byond://?_src_=prefs;preference=lobby_music'><b>[(sound & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Mute End Of Round Sounds:</b> <a href='byond://?_src_=prefs;preference=mute_end_of_round'><b>[(sound & SOUND_MUTE_END_OF_ROUND) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Randomized Character Slot:</b> <a href='byond://?_src_=prefs;preference=randomslot'><b>[toggles2 & PREFTOGGLE_2_RANDOMSLOT ? "Yes" : "No"]</b></a><br>"
			dat += "<b>View Range:</b> <a href='byond://?_src_=prefs;preference=setviewrange'>[viewrange]</a><br>"
			dat += "<b>Window Flashing:</b> <a href='byond://?_src_=prefs;preference=winflash'>[(toggles2 & PREFTOGGLE_2_WINDOWFLASHING) ? "Yes" : "No"]</a><br>"
			dat += "<b>Modsuit Activation Method:</b> <a href='byond://?_src_=prefs;preference=mam'>[(toggles2 & PREFTOGGLE_2_MOD_ACTIVATION_METHOD) ? "Middle Click" : "Alt Click"]</a><br>"
			dat += "<b>Lighting settings:</b><br>"
			dat += "<b> - New Lighting:</b> <a href='byond://?_src_=prefs;preference=enablelighting'>[(light & LIGHT_NEW_LIGHTING) ? "Yes" : "No"]</a><br>"
			dat += "<b> - Glow Level:</b> <a href='byond://?_src_=prefs;preference=glowlevel'>"
			switch(glowlevel)
				if(GLOW_LOW)
					dat += "Low"
				if(GLOW_MED)
					dat += "Medium"
				if(GLOW_HIGH)
					dat += "High"
				if(GLOW_DISABLE)
					dat += "Disabled"
				else
					dat += "Medium"
			dat += "</a><br>"
			dat += "<b> - Lamp Exposure:</b> <a href='byond://?_src_=prefs;preference=exposure'>[(light & LIGHT_EXPOSURE) ? "Yes" : "No"]</a><br>"
			dat += "<b> - Lamp Glare:</b> <a href='byond://?_src_=prefs;preference=glare'>[(light & LIGHT_GLARE) ? "Yes" : "No"]</a><br>"
			// RIGHT SIDE OF THE PAGE
			dat += "</td><td width='405px' height='300px' valign='top'>"
			dat += "<h2>Interface Settings</h2>"
			dat += "<b>Set screentip mode:</b> <a href='byond://?_src_=prefs;preference=screentip_mode'>[(screentip_mode == 0) ? "Disabled" : "[screentip_mode]px"]</a><br>"
			dat += "<b>Screentip color:</b> <span style='border: 1px solid #161616; background-color: [screentip_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='byond://?_src_=prefs;preference=screentip_color'><b>Change</b></a><br>"
			dat += "<b>Thought Bubble when pointing:</b> <a href='byond://?_src_=prefs;preference=thought_bubble'>[(toggles2 & PREFTOGGLE_2_THOUGHT_BUBBLE) ? "Yes" : "No"]</a><br>"
			dat += "<b>Cogbar indicators:</b> <a href='byond://?_src_=prefs;preference=cogbar'>[(toggles3 & PREFTOGGLE_3_COGBAR_ANIMATIONS) ? "Yes" : "No"]</a><br>"
			dat += "<b>Custom UI settings:</b><br>"
			dat += " - <b>Alpha (transparency):</b> <a href='byond://?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a><br>"
			dat += " - <b>Color:</b> <a href='byond://?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b></a> <span style='border: 1px solid #161616; background-color: [UI_style_color];'>&nbsp;&nbsp;&nbsp;</span><br>"
			dat += " - <b>UI Style:</b> <a href='byond://?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>"
			dat += "<b>TGUI settings:</b><br>"
			dat += "<b> - Fancy TGUI:</b> <a href='byond://?_src_=prefs;preference=tgui'>[(toggles2 & PREFTOGGLE_2_FANCYUI) ? "Yes" : "No"]</a><br>"
			dat += "<b> - TGUI Input:</b> <a href='byond://?_src_=prefs;preference=tgui_input'>[(toggles2 & PREFTOGGLE_2_DISABLE_TGUI_INPUT) ? "No" : "Yes"]</a><br>"
			dat += "<b> - TGUI Input - Large Buttons:</b> <a href='byond://?_src_=prefs;preference=tgui_input_large'>[(toggles2 & PREFTOGGLE_2_LARGE_INPUT_BUTTONS) ? "Yes" : "No"]</a><br>"
			dat += "<b> - TGUI Input - Swap Buttons:</b> <a href='byond://?_src_=prefs;preference=tgui_input_swap'>[(toggles2 & PREFTOGGLE_2_SWAP_INPUT_BUTTONS) ? "Yes" : "No"]</a><br>"
			dat += "<b> - TGUI Say Theme:</b> <a href='byond://?_src_=prefs;preference=tgui_say_light_mode'>[(toggles2 & PREFTOGGLE_2_ENABLE_TGUI_SAY_LIGHT_MODE) ? "Light" : "Dark"]</a><br>"
			dat += "</td></tr></table>"

		if(TAB_ANTAG) // Antagonist's Preferences (and maps)
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
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
						var/is_special = (i in src.be_special)
						dat += "<b>Be [capitalize(i)]:</b><a class=[is_special ? "green" : "red"] href='byond://?_src_=prefs;preference=be_special;role=[i]'><b>[(is_special) ? "Yes" : "No"]</b></a><br>"
			dat += "<h2>Total Playtime:</h2>"
			if(!GLOB.configuration.jobs.enable_exp_tracking)
				dat += "<span class='warning'>Playtime tracking is not enabled.</span>"
			else
				dat += "<b>Your [EXP_TYPE_CREW] playtime is [user.client.get_exp_type(EXP_TYPE_CREW)]</b><br>"
			dat += "</td><td width='405px' height='300px' valign='top'>"
			dat += "<h2>Map Settings</h2>"
			dat += " - <b>Choose your map preferences:</b> <a href='byond://?_src_=prefs;preference=map_pick'><b>Click here!</b></a><br>"
			dat += "</td></tr></table>"

		if(TAB_KEYS)
			dat += "<div align='center'><b>All Key Bindings:&nbsp;</b>"
			dat += "<a href='byond://?_src_=prefs;preference=keybindings;all=reset'>Reset to Default</a>&nbsp;"
			dat += "<a href='byond://?_src_=prefs;preference=keybindings;all=clear'>Clear</a><br /></div>"
			dat += "<tr><td colspan=4><hr></td></tr>"
			dat += "<tr><td colspan=4><div align='center'><b>Please note, some keybinds are overridden by other categories.</b></div></td></tr>"
			dat += "<tr><td colspan=4><div align='center'><b>Ensure you bind all of them, or the specific one you want.</b></div></td></tr>"
			dat += "<tr><td colspan=4><hr></td></tr>"
			dat += "<tr><td colspan=4><div align='center'><b>Users of legacy mode can only rebind and use the following keys:</b></div></td></tr>"
			dat += "<tr><td colspan=4><div align='center'><b>Arrow Keys, Function Keys, Insert, Del, Home, End, PageUp, PageDn.</b></div></td></tr>"

			dat += "<table align='center' width='100%'>"

			// Lookup lists to make our life easier
			var/static/list/keybindings_by_cat
			if(!keybindings_by_cat)
				keybindings_by_cat = list()
				for(var/kb in GLOB.keybindings)
					var/datum/keybinding/KB = kb
					keybindings_by_cat["[KB.category]"] += list(KB)

			for(var/cat in GLOB.keybindings_groups)
				dat += "<tr><td colspan=4><hr></td></tr>"
				dat += "<tr><td colspan=3><h2>[cat]</h2></td></tr>"
				for(var/kb in keybindings_by_cat["[GLOB.keybindings_groups[cat]]"])
					var/datum/keybinding/KB = kb
					var/kb_uid = KB.UID() // Cache this to reduce proc jumps
					var/override_keys = (keybindings_overrides && keybindings_overrides[KB.name])
					var/list/keys = override_keys || KB.keys
					var/keys_buttons = ""
					for(var/key in keys)
						var/disp_key = key
						if(override_keys)
							disp_key = "<b>[disp_key]</b>"
						keys_buttons += "<a href='byond://?_src_=prefs;preference=keybindings;set=[kb_uid];old=[url_encode(key)];'>[disp_key]</a>&nbsp;"
					dat += "<tr>"
					dat += "<td style='width: 25%'>[KB.name]</td>"
					dat += "<td style='width: 45%'>[keys_buttons][(length(keys) < 5) ? "<a href='byond://?_src_=prefs;preference=keybindings;set=[kb_uid];'><span class='good'>+</span></a></td>" : "</td>"]"
					dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=keybindings;reset=[kb_uid]'>Reset to Default</a> <a href='byond://?_src_=prefs;preference=keybindings;clear=[kb_uid]'>Clear</a></td>"
					if(KB.category == KB_CATEGORY_EMOTE_CUSTOM)
						var/datum/keybinding/custom/custom_emote_keybind = kb
						if(custom_emote_keybind.donor_exclusive && !(user.client.donator_level || user.client.holder || unlock_content))
							dat += "</tr>"
							dat += "<tr>"
							dat += "<td><b>The use of this emote is restricted to patrons and byond members.</b></td>"
							dat += "</tr>"
							continue
						dat += "</tr>"
						dat += "<tr>"
						var/emote_text = active_character.custom_emotes[custom_emote_keybind.name] //check if this emote keybind has an associated value on the character save
						if(!emote_text)
							dat += "<td style='width: 25%'>[custom_emote_keybind.default_emote_text]</td>"
						else
							dat += "<td style='width: 25%'><i>\"[active_character.real_name] [emote_text]\"</i></td>"
						dat += "<td style='width: 45%'><a href='byond://?_src_=prefs;preference=keybindings;custom_emote_set=[kb_uid];'>Change Text</a></td>"
						dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=keybindings;custom_emote_reset=[kb_uid];'>Reset to Default</a></td>"
						dat += "<tr><td colspan=4><br></td></tr>"
					dat += "</tr>"
				dat += "<tr><td colspan=4><br></td></tr>"

			dat += "</table>"

		if(TAB_TOGGLES)
			dat += "<div align='center'><b>Preference Toggles:&nbsp;</b>"

			dat += "<table align='center' width='100%'>"

			// Lookup lists to make our life easier
			var/static/list/pref_toggles_by_category
			if(!pref_toggles_by_category)
				pref_toggles_by_category = list()
				for(var/toggle_type in GLOB.preference_toggles)
					var/datum/preference_toggle/toggle = GLOB.preference_toggles[toggle_type]
					pref_toggles_by_category["[toggle.preftoggle_category]"] += list(toggle)

			for(var/category in GLOB.preference_toggle_groups)
				dat += "<tr><td colspan=4><hr></td></tr>"
				dat += "<tr><td colspan=3><h2>[category]</h2></td></tr>"
				for(var/datum/preference_toggle/toggle as anything in pref_toggles_by_category["[GLOB.preference_toggle_groups[category]]"])
					dat += "<tr>"
					dat += "<td style='width: 25%'>[toggle.name]</td>"
					dat += "<td style='width: 45%'>[toggle.description]</td>"
					if(toggle.preftoggle_category == PREFTOGGLE_CATEGORY_ADMIN)
						if(!check_rights(toggle.rights_required, 0, (user)))
							dat += "<td style='width: 20%'><b>Admin Restricted.</b></td>"
							dat += "</tr>"
							continue
					switch(toggle.preftoggle_toggle)
						if(PREFTOGGLE_SPECIAL)
							dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=preference_toggles;toggle=[toggle.UID()];'>Adjust</a></td>"
						if(PREFTOGGLE_TOGGLE1)
							dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=preference_toggles;toggle=[toggle.UID()];'>[(toggles & toggle.preftoggle_bitflag) ? "<span class='good'>Enabled</span>" : "<span class='bad'>Disabled</span>"]</a></td>"
						if(PREFTOGGLE_TOGGLE2)
							dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=preference_toggles;toggle=[toggle.UID()];'>[(toggles2 & toggle.preftoggle_bitflag) ? "<span class='good'>Enabled</span>" : "<span class='bad'>Disabled</span>"]</a></td>"
						if(PREFTOGGLE_SOUND)
							dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=preference_toggles;toggle=[toggle.UID()];'>[(sound & toggle.preftoggle_bitflag) ? "<span class='good'>Enabled</span>" : "<span class='bad'>Disabled</span>"]</a></td>"
						if(PREFTOGGLE_LIGHT)
							dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=preference_toggles;toggle=[toggle.UID()];'>[(light & toggle.preftoggle_bitflag) ? "<span class='good'>Enabled</span>" : "<span class='bad'>Disabled</span>"]</a></td>"
					dat += "</tr>"
				dat += "<tr><td colspan=4><br></td></tr>"


	dat += "<hr><center>"
	if(!IsGuestKey(user.key))
		dat += "<a href='byond://?_src_=prefs;preference=load'>Undo</a> - "
		dat += "<a href='byond://?_src_=prefs;preference=save'>Save Setup</a> - "

	dat += "<a href='byond://?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center>"

	var/datum/browser/popup = new(user, "preferences", "<div align='center'>Character Setup</div>", 820, 810)
	popup.set_content(dat.Join(""))
	popup.open(FALSE)

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
		dat += "<a href='byond://?_src_=prefs;preference=changeslot;num=[i];'>[name]</a><br>"

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
		loadout_cache += "[new_item]"

	for(var/item in loadout_cache)
		var/datum/gear/gear = text2path(item) || item
		if(!gear || !(gear.type in GLOB.gear_datums))
			continue
		var/added_cost = gear.cost
		if(!gear.subtype_selection_cost) // If listings of the same subtype shouldn't have their cost added.
			if(gear.main_typepath in type_blacklist)
				added_cost = 0
			else
				type_blacklist += gear.main_typepath
		if((total_cost + added_cost) > max_gear_slots)
			continue // If the final cost is too high, don't add the item.
		active_character.loadout_gear[item] = loadout_cache[item] ? loadout_cache[item] : list()
		total_cost += added_cost
	return total_cost

/datum/preferences/proc/init_keybindings(overrides, raw)
	if(raw)
		try
			overrides = json_decode(raw)
		catch
			overrides = list()
	keybindings = list()
	keybindings_overrides = overrides
	for(var/kb in GLOB.keybindings)
		var/datum/keybinding/KB = kb
		var/list/keys = (overrides && overrides[KB.name]) || KB.keys
		for(var/key in keys)
			LAZYADD(keybindings[key], kb)

	parent?.update_active_keybindings()
	return keybindings

/datum/preferences/proc/capture_keybinding(mob/user, datum/keybinding/KB, old)
	var/HTML = {"
	<div id='focus' style="outline: 0;" tabindex=0>Keybinding: [KB.name]<br><br><b>Press any key to change<br>Press ESC to clear</b></div>
	<script>
	var deedDone = false;
	document.onkeyup = function(e) {
		if(deedDone){ return; }
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var shift = e.shiftKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var number = 0;
		if(e.keyCode >= 48 && e.keyCode <= 57) { <!-- keycodes 48-57 equate to 0-9, e.key returns the key eg, ! instead of shift + 1 -->
			number = e.keyCode - 48; <!-- gets the number from the keycode and we use that instead of e.key -->
			var url = 'byond://?_src_=prefs;preference=keybindings;set=[KB.UID()];old=[url_encode(old)];clear_key='+escPressed+';key='+number+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
		} else {
			var url = 'byond://?_src_=prefs;preference=keybindings;set=[KB.UID()];old=[url_encode(old)];clear_key='+escPressed+';key='+encodeURIComponent(e.key)+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
		}
		window.location=url;
		deedDone = true;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "capturekeypress", src)
