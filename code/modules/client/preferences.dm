//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

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
	ROLE_MUTINEER = 21,
	ROLE_MALF = 30,
)

/proc/player_old_enough_antag(client/C, role)
	if(available_in_days_antag(C, role) == 0)
		return 1	//Available in 0 days = available right now = player is old enough to play.
	return 0

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

//used for alternate_option
#define GET_RANDOM_JOB 0
#define BE_CIVILIAN 1
#define RETURN_TO_LOBBY 2

#define MAX_SAVE_SLOTS 20 // Save slots for regular players
#define MAX_SAVE_SLOTS_MEMBER 20 // Save slots for BYOND members

/datum/preferences
	//doohickeys for savefiles
//	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
//	var/savefile_version = 0
	var/max_save_slots = MAX_SAVE_SLOTS

	//non-preference stuff
	var/warns = 0
	var/muted = 0
	var/last_ip
	var/last_id

	//game-preferences
//	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = "#b82e00"
	var/be_special = list()				//Special role selection
	var/UI_style = "Midnight"
	var/nanoui_fancy = TRUE
	var/toggles = TOGGLES_DEFAULT
	var/sound = SOUND_DEFAULT
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255


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
	var/backbag = 2						//backpack type
	var/ha_style = "None"				//Head accessory style
	var/r_headacc = 0					//Head accessory colour
	var/g_headacc = 0					//Head accessory colour
	var/b_headacc = 0					//Head accessory colour
	var/m_style = "None"				//Marking style
	var/r_markings = 0					//Marking colour
	var/g_markings = 0					//Marking colour
	var/b_markings = 0					//Marking colour
	var/h_style = "Bald"				//Hair type
	var/r_hair = 0						//Hair color
	var/g_hair = 0						//Hair color
	var/b_hair = 0						//Hair color
	var/f_style = "Shaved"				//Face hair type
	var/r_facial = 0					//Face hair color
	var/g_facial = 0					//Face hair color
	var/b_facial = 0					//Face hair color
	var/s_tone = 0						//Skin tone
	var/r_skin = 0						//Skin color
	var/g_skin = 0						//Skin color
	var/b_skin = 0						//Skin color
	var/r_eyes = 0						//Eye color
	var/g_eyes = 0						//Eye color
	var/b_eyes = 0						//Eye color
	var/species = "Human"
	var/language = "None"				//Secondary language

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
	var/alternate_option = 0

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
	var/current_tab = 0

		// OOC Metadata:
	var/metadata = ""
	var/slot_name = ""

	// Whether or not to use randomized character slots
	var/randomslot = 0

	// jukebox volume
	var/volume = 100

	// BYOND membership
	var/unlock_content = 0

/datum/preferences/New(client/C)
	b_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")
	if(istype(C))
		if(!IsGuestKey(C.key))
			unlock_content = C.IsByondMember()
			if(unlock_content)
				max_save_slots = MAX_SAVE_SLOTS_MEMBER
	var/loaded_preferences_successfully = load_preferences(C)
	if(loaded_preferences_successfully)
		if(load_character(C))
			return
	//we couldn't load character data so just randomize the character appearance + name
	random_character()		//let's create a random character then - rather than a fat, bald and naked man.
	real_name = random_name(gender)
	if(!loaded_preferences_successfully)
		save_preferences(C)
	save_character(C)		//let's save this new random character so it doesn't keep generating new ones.


// Hello I am a proc full of snowflake species checks how are you
/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)	return
	update_preview_icon()
	user << browse_rsc(preview_icon_front, "previewicon.png")
	user << browse_rsc(preview_icon_side, "previewicon2.png")
	var/dat = "<html><body><center>"

	dat += "<a href='?_src_=prefs;preference=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Character Settings</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>Game Preferences</a>"
	dat += "</center>"
	dat += "<HR>"

	switch(current_tab)
		if (0) // Character Settings#
			dat += "<center>"
			dat += "Slot <b>[slot_name]</b> - "
			dat += "<a href=\"byond://?src=\ref[user];preference=open_load_dialog\">Load slot</a> - "
			dat += "<a href=\"byond://?src=\ref[user];preference=save\">Save slot</a> - "
			dat += "<a href=\"byond://?src=\ref[user];preference=reload\">Reload slot</a>"
			dat += "</center>"
			dat += "<center><h2>Occupation Choices</h2>"
			dat += "<a href='?_src_=prefs;preference=job;task=menu'>Set Occupation Preferences</a><br></center>"
			dat += "<h2>Identity</h2>"
			dat += "<table width='100%'><tr><td width='75%' valign='top'>"
			if(appearance_isbanned(user))
				dat += "<b>You are banned from using custom names and appearances. You can continue to adjust your characters, but you will be randomised once you join the game.</b><br>"
			dat += "<b>Name:</b> "
			dat += "<a href='?_src_=prefs;preference=name;task=input'><b>[real_name]</b></a><br>"
			dat += "(<a href='?_src_=prefs;preference=name;task=random'>Random Name</A>) "
			dat += "(<a href='?_src_=prefs;preference=name'>Always Random Name: [be_random_name ? "Yes" : "No"]</a>)"
			dat += "<br>"
			dat += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender'><b>[gender == MALE ? "Male" : "Female"]</b></a><br>"
			dat += "<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[age]</a>"
			//dat += "<b>Spawn Point</b>: <a href='byond://?src=\ref[user];preference=spawnpoint;task=input'>[spawnpoint]</a>"
			dat += "<br><table><tr><td><b>Body</b> "
			dat += "(<a href='?_src_=prefs;preference=all;task=random'>&reg;</A>)"
			dat += "<br>"
			dat += "Species: <a href='?_src_=prefs;preference=species;task=input'>[species]</a><br>"
			if(species == "Vox")//oldvox code, sucks I know
				dat += "N2 Tank: <a href='?_src_=prefs;preference=speciesprefs;task=input'>[speciesprefs ? "Large N2 Tank" : "Specialized N2 Tank"]</a><br>"
			dat += "Secondary Language:<br><a href='?_src_=prefs;preference=language;task=input'>[language]</a><br>"
			dat += "Blood Type: <a href='?_src_=prefs;preference=b_type;task=input'>[b_type]</a><br>"
			if(species == "Human")
				dat += "Skin Tone: <a href='?_src_=prefs;preference=s_tone;task=input'>[-s_tone + 35]/220</a><br>"

	//		dat += "Skin pattern: <a href='byond://?src=\ref[user];preference=skin_style;task=input'>Adjust</a><br>"
			dat += "<br><b>Handicaps</b><br>"
			dat += "\t<a href='?_src_=prefs;preference=disabilities'><b>\[Set Disabilities\]</b></a><br>"
			dat += "Limbs and Parts: <a href='?_src_=prefs;preference=limbs;task=input'>Adjust</a><br>"
			if(species != "Slime People" && species != "Machine")
				dat += "Internal Organs: <a href='?_src_=prefs;preference=organs;task=input'>Adjust</a><br>"

			//display limbs below
			var/ind = 0
			for(var/name in organ_data)
//				to_chat(world, "[ind] \ [organ_data.len]")
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
					if("heart")
						organ_name = "heart"
					if("eyes")
						organ_name = "eyes"

				if(status == "cyborg")
					++ind
					if(ind > 1)
						dat += ", "
					var/datum/robolimb/R
					if(rlimb_data[name] && all_robolimbs[rlimb_data[name]])
						R = all_robolimbs[rlimb_data[name]]
					else
						R = basic_robolimb
					dat += "\t[R.company] [organ_name] prosthesis"


				else if(status == "amputated")
					++ind
					if(ind > 1)
						dat += ", "
					dat += "\tAmputated [organ_name]"

				else if(status == "mechanical")
					++ind
					if(ind > 1)
						dat += ", "
					dat += "\tMechanical [organ_name]"

				else if(status == "assisted")
					++ind
					if(ind > 1)
						dat += ", "
					switch(organ_name)
						if("heart")
							dat += "\tPacemaker-assisted [organ_name]"
						if("voicebox") //on adding voiceboxes for speaking skrell/similar replacements
							dat += "\tSurgically altered [organ_name]"
						if("eyes")
							dat += "\tRetinal overlayed [organ_name]"
						else
							dat += "\tMechanically assisted [organ_name]"
			if(!ind)
				dat += "\[...\]<br><br>"
			else
				dat += "<br><br>"
			dat += "<b>Underwear:</b><BR><a href ='?_src_=prefs;preference=underwear;task=input'>[underwear]</a><BR>"
			dat += "<b>Undershirt:</b><BR><a href ='?_src_=prefs;preference=undershirt;task=input'>[undershirt]</a><BR>"
			dat += "<b>Socks:</b><BR><a href ='?_src_=prefs;preference=socks;task=input'>[socks]</a><BR>"
			dat += "Backpack Type:<br><a href ='?_src_=prefs;preference=bag;task=input'><b>[backbaglist[backbag]]</b></a><br>"
			dat += "Nanotrasen Relation:<br><a href ='?_src_=prefs;preference=nt_relation;task=input'><b>[nanotrasen_relation]</b></a><br>"
			dat += "</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64><img src=previewicon2.png height=64 width=64></td></tr></table>"
			dat += "</td><td width='300px' height='300px'>"

			if(jobban_isbanned(user, "Records"))
				dat += "<b>You are banned from using character records.</b><br>"
			else
				dat += "<b><a href=\"byond://?src=\ref[user];preference=records;record=1\">Character Records</a></b><br>"
			dat += "<a href='byond://?src=\ref[user];preference=flavor_text;task=input'><b>Set Flavor Text</b></a><br>"
			if(lentext(flavor_text) <= 40)
				if(!lentext(flavor_text))
					dat += "\[...\]"
				else
					dat += "[flavor_text]"
			else
				dat += "[TextPreview(flavor_text)]...<br>"
			dat += "<br>"

			if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species that have head accessories.
				var/headaccessoryname = "Head Accessory"
				if(species == "Unathi")
					headaccessoryname = "Horns"
				dat += "<br><b>[headaccessoryname]</b><br>"
				dat += "<a href='?_src_=prefs;preference=headaccessory;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_headacc, 2)][num2hex(g_headacc, 2)][num2hex(b_headacc, 2)]'><table style='display:inline;' bgcolor='#[num2hex(r_headacc, 2)][num2hex(g_headacc, 2)][num2hex(b_headacc)]'><tr><td>__</td></tr></table></font> "
				dat += "Style: <a href='?_src_=prefs;preference=ha_style;task=input'>[ha_style]</a><br>"

			if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species that have body markings.
				dat += "<br><b>Body Markings</b><br>"
				dat += "<a href='?_src_=prefs;preference=markings;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_markings, 2)][num2hex(g_markings, 2)][num2hex(b_markings, 2)]'><table style='display:inline;' bgcolor='#[num2hex(r_markings, 2)][num2hex(g_markings, 2)][num2hex(b_markings)]'><tr><td>__</td></tr></table></font> "
				dat += "<br>Style: <a href='?_src_=prefs;preference=m_style;task=input'>[m_style]</a><br>"

			dat += "<br><b>Hair</b><br>"
			dat += "<a href='?_src_=prefs;preference=hair;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)]'><table style='display:inline;' bgcolor='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]'><tr><td>__</td></tr></table></font> "
			dat += " <br>Style: <a href='?_src_=prefs;preference=h_style;task=input'>[h_style]</a><br>"

			dat += "<br><b>Facial Hair</b><br>"
			dat += "<a href='?_src_=prefs;preference=facial;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)]'><table  style='display:inline;' bgcolor='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]'><tr><td>__</td></tr></table></font> "
			dat += " <br>Style: <a href='?_src_=prefs;preference=f_style;task=input'>[f_style ? "[f_style]" : "Shaved"]</a><br>"

			if(species != "Machine")
				dat += "<br><b>Eyes</b><br>"
				dat += "<a href='?_src_=prefs;preference=eyes;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]'><table  style='display:inline;' bgcolor='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]'><tr><td>__</td></tr></table></font><br>"

			if((species in list("Unathi", "Tajaran", "Skrell", "Slime People", "Vulpkanin", "Machine")) || body_accessory_by_species[species] || check_rights(R_ADMIN, 0, user)) //admins can always fuck with this, because they are admins
				dat += "<br><b>Body Color</b><br>"
				dat += "<a href='?_src_=prefs;preference=skin;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_skin, 2)][num2hex(g_skin, 2)][num2hex(b_skin, 2)]'><table style='display:inline;' bgcolor='#[num2hex(r_skin, 2)][num2hex(g_skin, 2)][num2hex(b_skin)]'><tr><td>__</td></tr></table></font>"

			if(body_accessory_by_species[species] || check_rights(R_ADMIN, 0, user))
				dat += "<br><b>Body Accessory</b><br>"
				dat += "Accessory: <a href='?_src_=prefs;preference=body_accessory;task=input'>[body_accessory ? "[body_accessory]" : "None"]</a><br>"

			dat += "</td></tr></table><hr><center>"

		if (1) // General Preferences
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
			dat += "<h2>General Settings</h2>"
			dat += "<b>UI Style:</b> <a href='?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>"
			dat += "<b>Fancy NanoUI:</b> <a href='?_src_=prefs;preference=nanoui'>[(nanoui_fancy) ? "Yes" : "No"]</a><br>"
			dat += "<b>Custom UI settings:</b><br>"
			dat += "<b>Color:</b> <a href='?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b></a> <table style='display:inline;' bgcolor='[UI_style_color]'><tr><td>__</td></tr></table><br>"
			dat += "<b>Alpha (transparency):</b> <a href='?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a><br>"
			dat += "<b>Play admin midis:</b> <a href='?_src_=prefs;preference=hear_midis'><b>[(sound & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Play lobby music:</b> <a href='?_src_=prefs;preference=lobby_music'><b>[(sound & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Randomized character slot:</b> <a href='?_src_=prefs;preference=randomslot'><b>[randomslot ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Ghost ears:</b> <a href='?_src_=prefs;preference=ghost_ears'><b>[(toggles & CHAT_GHOSTEARS) ? "Nearest Creatures" : "All Speech"]</b></a><br>"
			dat += "<b>Ghost sight:</b> <a href='?_src_=prefs;preference=ghost_sight'><b>[(toggles & CHAT_GHOSTSIGHT) ? "Nearest Creatures" : "All Emotes"]</b></a><br>"
			dat += "<b>Ghost radio:</b> <a href='?_src_=prefs;preference=ghost_radio'><b>[(toggles & CHAT_GHOSTRADIO) ? "Nearest Speakers" : "All Chatter"]</b></a><br>"
			if(config.allow_Metadata)
				dat += "<b>OOC notes:</b> <a href='?_src_=prefs;preference=metadata;task=input'><b>Edit</b></a><br>"

			if(user.client)
				if(user.client.holder)
					dat += "<b>Adminhelp sound:</b> "
					dat += "<a href='?_src_=prefs;preference=hear_adminhelps'><b>[(sound & SOUND_ADMINHELP)?"On":"Off"]</b></a><br>"

				if(check_rights(R_ADMIN,0))
					dat += "<b>OOC:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ooccolor;task=input'><b>Change</b></a><br>"

				if(unlock_content)
					dat += "<b>BYOND Membership Publicity:</b> <a href='?_src_=prefs;preference=publicity'><b>[(toggles & MEMBER_PUBLIC) ? "Public" : "Hidden"]</b></a><br>"

			dat += "</td><td width='300px' height='300px' valign='top'>"
			dat += "<h2>Special Role Settings</h2>"
//				dat += "<br><br>"
			if(jobban_isbanned(user, "Syndicate"))
				dat += "<b>You are banned from special roles.</b>"
				src.be_special = list()
			else
				for (var/i in special_roles)
					if(jobban_isbanned(user, i))
						dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[BANNED]</b></font><br>"
					else if(!player_old_enough_antag(user.client,i))
						var/available_in_days_antag = available_in_days_antag(user.client,i)
						dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[IN [(available_in_days_antag)] DAYS]</b></font><br>"
					else
						dat += "<b>Be [capitalize(i)]:</b> <a href='?_src_=prefs;preference=be_special;role=[i]'><b>[(i in src.be_special) ? "Yes" : "No"]</b></a><br>"
			dat += "</td></tr></table><hr><center>"

	if(!IsGuestKey(user.key))
		dat += "<a href='?_src_=prefs;preference=load'>Undo</a> - "
		dat += "<a href='?_src_=prefs;preference=save'>Save Setup</a> - "

	dat += "<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center></body></html>"

//		user << browse(dat, "window=preferences;size=560x580")
	var/datum/browser/popup = new(user, "preferences", "<div align='center'>Character Setup</div>", 640, 810)
	popup.set_content(dat)
	popup.open(0)

/datum/preferences/proc/SetChoices(mob/user, limit = 12, list/splitJobs = list("Civilian","Research Director","AI","Bartender"), width = 760, height = 790)
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
	if (!job_master)		return
	for(var/datum/job/job in job_master.occupations)

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
				HTML += "<br><b><a class='white' href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></b></td></tr>"
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
			HTML += "<br><b><a class='white' href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></b></td></tr>"


		HTML += "</td></tr>"

	for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
		HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

	HTML += "</td'></tr></table>"

	HTML += "</center></table>"

	switch(alternate_option)
		if(GET_RANDOM_JOB)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=white>Get random job if preferences unavailable</font></a></u></center><br>"
		if(BE_CIVILIAN)
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
	if (!job)
		return 0

	if (level == 1) // to high
		// remove any other job(s) set to high
		job_support_med |= job_support_high
		job_engsec_med |= job_engsec_high
		job_medsci_med |= job_medsci_high
		job_karma_med |= job_karma_high
		job_support_high = 0
		job_engsec_high = 0
		job_medsci_high = 0
		job_karma_high = 0

	if (job.department_flag == SUPPORT)
		job_support_low &= ~job.flag
		job_support_med &= ~job.flag
		job_support_high &= ~job.flag

		switch(level)
			if (1)
				job_support_high |= job.flag
			if (2)
				job_support_med |= job.flag
			if (3)
				job_support_low |= job.flag

		return 1
	else if (job.department_flag == ENGSEC)
		job_engsec_low &= ~job.flag
		job_engsec_med &= ~job.flag
		job_engsec_high &= ~job.flag

		switch(level)
			if (1)
				job_engsec_high |= job.flag
			if (2)
				job_engsec_med |= job.flag
			if (3)
				job_engsec_low |= job.flag

		return 1
	else if (job.department_flag == MEDSCI)
		job_medsci_low &= ~job.flag
		job_medsci_med &= ~job.flag
		job_medsci_high &= ~job.flag

		switch(level)
			if (1)
				job_medsci_high |= job.flag
			if (2)
				job_medsci_med |= job.flag
			if (3)
				job_medsci_low |= job.flag

		return 1
	else if (job.department_flag == KARMA)
		job_karma_low &= ~job.flag
		job_karma_med &= ~job.flag
		job_karma_high &= ~job.flag

		switch(level)
			if (1)
				job_karma_high |= job.flag
			if (2)
				job_karma_med |= job.flag
			if (3)
				job_karma_low |= job.flag

		return 1

	return 0

/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	var/datum/job/job = job_master.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if (!isnum(desiredLvl))
		to_chat(user, "\red UpdateJobPreference - desired level was not a number. Please notify coders!")
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

/datum/preferences/proc/ShowDisabilityState(mob/user,flag,label)
	if(flag==DISABILITY_FLAG_FAT && species!=("Human" || "Tajaran" || "Grey"))
		return "<li><i>[species] cannot be fat.</i></li>"
	return "<li><b>[label]:</b> <a href=\"?_src_=prefs;task=input;preference=disabilities;disability=[flag]\">[disabilities & flag ? "Yes" : "No"]</a></li>"

/datum/preferences/proc/SetDisabilities(mob/user)
	var/HTML = "<body>"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:474: HTML += "<tt><center>"
	HTML += {"<tt><center>
		<b>Choose disabilities</b><ul>"}
	// END AUTOFIX
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_NEARSIGHTED,"Needs Glasses")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_FAT,"Obese")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_EPILEPTIC,"Seizures")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_DEAF,"Deaf")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_BLIND,"Blind")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_MUTE,"Mute")


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:481: HTML += "</ul>"
	HTML += {"</ul>
		<a href=\"?_src_=prefs;task=close;preference=disabilities\">\[Done\]</a>
		<a href=\"?_src_=prefs;task=reset;preference=disabilities\">\[Reset\]</a>
		</center></tt>"}
	// END AUTOFIX
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=disabil;size=350x300")
	return

/datum/preferences/proc/SetRecords(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Character Records</b><br>"

	HTML += "<a href=\"byond://?src=\ref[user];preference=records;task=med_record\">Medical Records</a><br>"

	if(lentext(med_record) <= 40)
		HTML += "[med_record]"
	else
		HTML += "[copytext(med_record, 1, 37)]..."

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">Employment Records</a><br>"

	if(lentext(gen_record) <= 40)
		HTML += "[gen_record]"
	else
		HTML += "[copytext(gen_record, 1, 37)]..."

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">Security Records</a><br>"

	if(lentext(sec_record) <= 40)
		HTML += "[sec_record]<br>"
	else
		HTML += "[copytext(sec_record, 1, 37)]...<br>"

	HTML += "<br>"
	HTML += "<a href=\"byond://?src=\ref[user];preference=records;records=-1\">\[Done\]</a>"
	HTML += "</center></tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=records;size=350x300")
	return

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

	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("random")
				if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_CIVILIAN)
					alternate_option += 1
				else if(alternate_option == RETURN_TO_LOBBY)
					alternate_option = 0
				else
					return 0
				SetChoices(user)
			if ("alt_title")
				var/datum/job/job = locate(href_list["job"])
				if (job)
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
					if(!(dflag==DISABILITY_FLAG_FAT && species!=("Human" || "Tajaran" || "Grey")))
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

	switch(href_list["task"])
		if("random")
			switch(href_list["preference"])
				if("name")
					real_name = random_name(gender,species)
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair")
					if(species == "Human" || species == "Unathi" || species == "Tajaran" || species == "Skrell" || species == "Machine" || species == "Wryn" || species == "Vulpkanin")
						r_hair = rand(0,255)
						g_hair = rand(0,255)
						b_hair = rand(0,255)
				if("h_style")
					h_style = random_hair_style(gender, species)
				if("facial")
					r_facial = rand(0,255)
					g_facial = rand(0,255)
					b_facial = rand(0,255)
				if("f_style")
					f_style = random_facial_hair_style(gender, species)
				if("underwear")
					underwear = random_underwear(gender)
					ShowChoices(user)
				if("undershirt")
					undershirt = random_undershirt(gender)
					ShowChoices(user)
				if("socks")
					socks = random_socks(gender)
					ShowChoices(user)
				if("eyes")
					r_eyes = rand(0,255)
					g_eyes = rand(0,255)
					b_eyes = rand(0,255)
				if("s_tone")
					if(species == "Human")
						s_tone = random_skin_tone()
				if("s_color")
					if(species in list("Unathi", "Tajaran", "Skrell", "Slime People", "Wyrn", "Vulpkanin", "Machine"))
						r_skin = rand(0,255)
						g_skin = rand(0,255)
						b_skin = rand(0,255)
				if("bag")
					backbag = rand(1,4)
				/*if("skin_style")
					h_style = random_skin_style(gender)*/
				if("all")
					random_character()
		if("input")
			switch(href_list["preference"])
				if("name")
					var/raw_name = input(user, "Choose your character's name:", "Character Preference") as text|null
					if (!isnull(raw_name)) // Check to ensure that the user entered text (rather than cancel.)
						var/new_name = reject_bad_name(raw_name)
						if(new_name)
							real_name = new_name
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)
				if("species")

					var/list/new_species = list("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin")
					var/prev_species = species
//						var/whitelisted = 0

					if(config.usealienwhitelist) //If we're using the whitelist, make sure to check it!
						for(var/S in whitelisted_species)
							if(is_alien_whitelisted(user,S))
								new_species += S
//									whitelisted = 1
//							if(!whitelisted)
//								alert(user, "You cannot change your species as you need to be whitelisted. If you wish to be whitelisted contact an admin in-game, on the forums, or on IRC.")
					else //Not using the whitelist? Aliens for everyone!
						new_species += whitelisted_species

					species = input("Please select a species", "Character Generation", null) in new_species

					if(prev_species != species)
						//grab one of the valid hair styles for the newly chosen species
						var/list/valid_hairstyles = list()
						for(var/hairstyle in hair_styles_list)
							var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
							if(gender == MALE && S.gender == FEMALE)
								continue
							if(gender == FEMALE && S.gender == MALE)
								continue
							if(!(species in S.species_allowed))
								continue

							valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

						if(valid_hairstyles.len)
							h_style = pick(valid_hairstyles)
						else
							//this shouldn't happen
							h_style = hair_styles_list["Bald"]

						//grab one of the valid facial hair styles for the newly chosen species
						var/list/valid_facialhairstyles = list()
						for(var/facialhairstyle in facial_hair_styles_list)
							var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
							if(gender == MALE && S.gender == FEMALE)
								continue
							if(gender == FEMALE && S.gender == MALE)
								continue
							if(!(species in S.species_allowed))
								continue

							valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

						if(valid_facialhairstyles.len)
							f_style = pick(valid_facialhairstyles)
						else
							//this shouldn't happen
							f_style = facial_hair_styles_list["Shaved"]

						// Don't wear another species' underwear!
						var/datum/sprite_accessory/S = underwear_list[underwear]
						if(!(species in S.species_allowed))
							underwear = random_underwear(gender, species)

						S = undershirt_list[undershirt]
						if(!(species in S.species_allowed))
							undershirt = random_undershirt(gender, species)

						S = socks_list[socks]
						if(!(species in S.species_allowed))
							socks = random_socks(gender, species)

						//reset hair colour and skin colour
						r_hair = 0//hex2num(copytext(new_hair, 2, 4))
						g_hair = 0//hex2num(copytext(new_hair, 4, 6))
						b_hair = 0//hex2num(copytext(new_hair, 6, 8))

						s_tone = 0

						ha_style = "None" // No Vulp ears on Unathi
						m_style = "None" // No Unathi markings on Tajara

						body_accessory = null //no vulptail on humans damnit

						//Reset prosthetics.
						organ_data = list()
						rlimb_data = list()
				if("speciesprefs")//oldvox code
					speciesprefs = !speciesprefs

				if("language")
//						var/languages_available
					var/list/new_languages = list("None")
/*
					if(config.usealienwhitelist)
						for(var/L in all_languages)
							var/datum/language/lang = all_languages[L]
							if((!(lang.flags & RESTRICTED)) && (is_alien_whitelisted(user, L)||(!( lang.flags & WHITELISTED ))))
								new_languages += lang
								languages_available = 1

						if(!(languages_available))
							alert(user, "There are not currently any available secondary languages.")
					else
*/
					for(var/L in all_languages)
						var/datum/language/lang = all_languages[L]
						if(!(lang.flags & RESTRICTED))
							new_languages += lang.name

					language = input("Please select a secondary language", "Character Generation", null) in new_languages

				if("metadata")
					var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , metadata)  as message|null
					if(new_metadata)
						metadata = sanitize(copytext(new_metadata,1,MAX_MESSAGE_LEN))

				if("b_type")
					var/new_b_type = input(user, "Choose your character's blood-type:", "Character Preference") as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if(new_b_type)
						b_type = new_b_type

				if("hair")
					if(species == "Human" || species == "Unathi" || species == "Tajaran" || species == "Skrell" || species == "Machine" || species == "Vulpkanin")
						var/input = "Choose your character's hair colour:"
						if(species == "Machine" && !("head" in rlimb_data))
							input = "Choose your character's frame colour:"
						var/new_hair = input(user, input, "Character Preference", rgb(r_hair, g_hair, b_hair)) as color|null
						if(new_hair)
							r_hair = hex2num(copytext(new_hair, 2, 4))
							g_hair = hex2num(copytext(new_hair, 4, 6))
							b_hair = hex2num(copytext(new_hair, 6, 8))

				if("h_style")
					var/list/valid_hairstyles = list()
					for(var/hairstyle in hair_styles_list)
						var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
						if(species == "Machine") //Species that can use prosthetic heads.
							if(species in S.species_allowed)
								if(!rlimb_data["head"])
									valid_hairstyles[hairstyle] = S
									continue
								else
									continue
							else
								if(!rlimb_data["head"])
									continue
								else if("Human" in S.species_allowed)
									valid_hairstyles[hairstyle] = S
									continue
						else
							if(!(species in S.species_allowed))
								continue

							valid_hairstyles[hairstyle] = S

					var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference") as null|anything in valid_hairstyles
					if(new_h_style)
						h_style = new_h_style

				if("headaccessory")
					if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) // Species with head accessories
						var/input = "Choose the colour of your your character's head accessory:"
						var/new_head_accessory = input(user, input, "Character Preference", rgb(r_headacc, g_headacc, b_headacc)) as color|null
						if(new_head_accessory)
							r_headacc = hex2num(copytext(new_head_accessory, 2, 4))
							g_headacc = hex2num(copytext(new_head_accessory, 4, 6))
							b_headacc = hex2num(copytext(new_head_accessory, 6, 8))

				if("ha_style")
					if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) // Species with head accessories
						var/list/valid_head_accessory_styles = list()
						for(var/head_accessory_style in head_accessory_styles_list)
							var/datum/sprite_accessory/H = head_accessory_styles_list[head_accessory_style]
							if(!(species in H.species_allowed))
								continue

							valid_head_accessory_styles[head_accessory_style] = head_accessory_styles_list[head_accessory_style]

						var/new_head_accessory_style = input(user, "Choose the style of your character's head accessory:", "Character Preference") as null|anything in valid_head_accessory_styles
						if(new_head_accessory_style)
							ha_style = new_head_accessory_style

				if("markings")
					if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) // Species with markings
						var/input = "Choose the colour of your your character's markings:"
						var/new_markings = input(user, input, "Character Preference", rgb(r_markings, g_markings, b_markings)) as color|null
						if(new_markings)
							r_markings = hex2num(copytext(new_markings, 2, 4))
							g_markings = hex2num(copytext(new_markings, 4, 6))
							b_markings = hex2num(copytext(new_markings, 6, 8))

				if("m_style")
					if(species in list("Unathi", "Vulpkanin", "Tajaran")) // Species with markings
						var/list/valid_markings = list()
						for(var/markingstyle in marking_styles_list)
							var/datum/sprite_accessory/M = marking_styles_list[markingstyle]
							if(!(species in M.species_allowed))
								continue

							if(species == "Machine") //Species that can use prosthetic heads.
								if(!("head" in rlimb_data) && M.name != "None") //If the character can have prosthetic heads and they have the default head (with screen), no optic markings.
									continue
								else if(("head" in rlimb_data) && M.name == "None") //Otherwise, if they DON'T have the default head and since they must have optics, give them a list of styles excluding the "None" option.
									continue

							valid_markings[markingstyle] = marking_styles_list[markingstyle]

						var/new_marking_style = input(user, "Choose the style of your character's markings:", "Character Preference", m_style) as null|anything in valid_markings
						if(new_marking_style)
							m_style = new_marking_style

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
						body_accessory = (new_body_accessory == "None") ? null : new_body_accessory

				if("facial")
					var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference", rgb(r_facial, g_facial, b_facial)) as color|null
					if(new_facial)
						r_facial = hex2num(copytext(new_facial, 2, 4))
						g_facial = hex2num(copytext(new_facial, 4, 6))
						b_facial = hex2num(copytext(new_facial, 6, 8))

				if("f_style")
					var/list/valid_facialhairstyles = list()
					for(var/facialhairstyle in facial_hair_styles_list)
						var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
						if(gender == MALE && S.gender == FEMALE)
							continue
						if(gender == FEMALE && S.gender == MALE)
							continue
						if(species == "Machine") //Species that can use prosthetic heads.
							if(species in S.species_allowed)
								if(!rlimb_data["head"])
									valid_facialhairstyles[facialhairstyle] = S
									continue
								else
									continue
							else
								if(!rlimb_data["head"])
									continue
								else if("Human" in S.species_allowed)
									valid_facialhairstyles[facialhairstyle] = S
									continue
								else
									continue
						else
							if(!(species in S.species_allowed))
								continue

						valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

					var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_facialhairstyles
					if(new_f_style)
						f_style = new_f_style

				if("underwear")
					var/list/underwear_options
					if(gender == MALE)
						underwear_options = underwear_m
					else
						underwear_options = underwear_f

					var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
					if(new_underwear)
						underwear = new_underwear
					ShowChoices(user)

				if("undershirt")
					var/new_undershirt
					if(gender == MALE)
						new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_m
					else
						new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_f
					if(new_undershirt)
						undershirt = new_undershirt
					ShowChoices(user)

				if("socks")
					var/list/valid_sockstyles = list()
					for(var/sockstyle in socks_list)
						var/datum/sprite_accessory/S = socks_list[sockstyle]
						if(gender == MALE && S.gender == FEMALE)
							continue
						if(gender == FEMALE && S.gender == MALE)
							continue
						if(!(species in S.species_allowed))
							continue
						valid_sockstyles[sockstyle] = socks_list[sockstyle]
					var/new_socks = input(user, "Choose your character's socks:", "Character Preference")  as null|anything in valid_sockstyles
					ShowChoices(user)
					if(new_socks)
						socks = new_socks

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference", rgb(r_eyes, g_eyes, b_eyes)) as color|null
					if(new_eyes)
						r_eyes = hex2num(copytext(new_eyes, 2, 4))
						g_eyes = hex2num(copytext(new_eyes, 4, 6))
						b_eyes = hex2num(copytext(new_eyes, 6, 8))

				if("s_tone")
					if(species != "Human")
						return
					var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
					if(new_s_tone)
						s_tone = 35 - max(min( round(new_s_tone), 220),1)

				if("skin")
					if((species in list("Unathi", "Tajaran", "Skrell", "Slime People", "Vulpkanin", "Machine")) || body_accessory_by_species[species] || check_rights(R_ADMIN, 0, user))
						var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference", rgb(r_skin, g_skin, b_skin)) as color|null
						if(new_skin)
							r_skin = hex2num(copytext(new_skin, 2, 4))
							g_skin = hex2num(copytext(new_skin, 4, 6))
							b_skin = hex2num(copytext(new_skin, 6, 8))


				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference", ooccolor) as color|null
					if(new_ooccolor)
						ooccolor = new_ooccolor

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backbaglist
					if(new_backbag)
						backbag = backbaglist.Find(new_backbag)

				if("nt_relation")
					var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
					if(new_relation)
						nanotrasen_relation = new_relation

				if("flavor_text")
					var/msg = input(usr,"Set the flavor text in your 'examine' verb. This can also be used for OOC notes and preferences!","Flavor Text",html_decode(flavor_text)) as message

					if(msg != null)
						msg = copytext(msg, 1, MAX_MESSAGE_LEN)
						msg = html_encode(msg)

						flavor_text = msg

				if("limbs")
					var/valid_limbs = list("Left Leg", "Right Leg", "Left Arm", "Right Arm", "Left Foot", "Right Foot", "Left Hand", "Right Hand")
					if(species == "Machine")
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
							if(species != "Machine")
								third_limb = "l_leg"
						if("Right Foot")
							limb = "r_foot"
							if(species != "Machine")
								third_limb = "r_leg"
						if("Left Hand")
							limb = "l_hand"
							if(species != "Machine")
								third_limb = "l_arm"
						if("Right Hand")
							limb = "r_hand"
							if(species != "Machine")
								third_limb = "r_arm"

					var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in valid_limb_states
					if(!new_state) return

					switch(new_state)
						if("Normal")
							if(limb == "head")
								m_style = "None"
								h_style = random_hair_style(gender, species)
								f_style = facial_hair_styles_list["Shaved"]
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
							var/choice = input(user, "Which manufacturer do you wish to use for this limb?") as null|anything in chargen_robolimbs
							if(!choice)
								return
							if(limb == "head")
								m_style = "Humanoid Optics"
								ha_style = "None"
								h_style = hair_styles_list["Bald"]
							rlimb_data[limb] = choice
							organ_data[limb] = "cyborg"
							if(second_limb)
								rlimb_data[second_limb] = choice
								organ_data[second_limb] = "cyborg"

				if("organs")
					var/organ_name = input(user, "Which internal function do you want to change?") as null|anything in list("Heart", "Eyes")
					if(!organ_name) return

					var/organ = null
					switch(organ_name)
						if("Heart")
							organ = "heart"
						if("Eyes")
							organ = "eyes"

					var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in list("Normal","Assisted","Mechanical")
					if(!new_state) return

					switch(new_state)
						if("Normal")
							organ_data[organ] = null
						if("Assisted")
							organ_data[organ] = "assisted"
						if("Mechanical")
							organ_data[organ] = "mechanical"

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

				if("gender")
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
							UI_style = "White"
						else
							UI_style = "Midnight"

				if("nanoui")
					nanoui_fancy = !nanoui_fancy

				if("UIcolor")
					var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!", UI_style_color) as color|null
					if(!UI_style_color_new) return
					UI_style_color = UI_style_color_new

				if("UIalpha")
					var/UI_style_alpha_new = input(user, "Select a new alpha(transparence) parameter for UI, between 50 and 255", UI_style_alpha) as num
					if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return
					UI_style_alpha = UI_style_alpha_new

				if("be_special")
					var/r = href_list["role"]
					if(!(r in special_roles))
						var/cleaned_r = sql_sanitize_text(r)
						if(r != cleaned_r) // up to no good
							message_admins("[user] attempted an href exploit! (This could have possibly lead to a \"Bobby Tables\" exploit, so they're probably up to no good). String: [r] ID: [last_id] IP: [last_ip]")
							to_chat(user, "<span class='userdanger'>Stop right there, criminal scum</span>")
					else
						be_special ^= r

				if("name")
					be_random_name = !be_random_name

				if("randomslot")
					randomslot = !randomslot

				if("hear_midis")
					sound ^= SOUND_MIDI

				if("lobby_music")
					sound ^= SOUND_LOBBY
					if(sound & SOUND_LOBBY)
						to_chat(user, sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1))
					else
						to_chat(user, sound(null, repeat = 0, wait = 0, volume = 85, channel = 1))

				if("ghost_ears")
					toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					toggles ^= CHAT_GHOSTSIGHT

				if("ghost_radio")
					toggles ^= CHAT_GHOSTRADIO

				if("ghost_radio")
					toggles ^= CHAT_GHOSTRADIO

				if("save")
					save_preferences(user)
					save_character(user)

				if("reload")
					load_preferences(user)
					load_character(user)

				if("open_load_dialog")
					if(!IsGuestKey(user.key))
						open_load_dialog(user)

				if("close_load_dialog")
					close_load_dialog(user)

				if("changeslot")
					if(!load_character(user,text2num(href_list["num"])))
						random_character()
						real_name = random_name(gender)
						save_character(user)
					close_load_dialog(user)

				if("tab")
					if (href_list["tab"])
						current_tab = text2num(href_list["tab"])

	ShowChoices(user)
	return 1

/datum/preferences/proc/copy_to(mob/living/carbon/human/character)
	var/datum/species/S = all_species[species]
	character.change_species(species) // Yell at me if this causes everything to melt
	if(be_random_name)
		real_name = random_name(gender,species)

	if(config.humans_need_surnames)
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [pick(last_names)]"
		else if(firstspace == name_length)
			real_name += "[pick(last_names)]"

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

	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes

	character.r_hair = r_hair
	character.g_hair = g_hair
	character.b_hair = b_hair

	character.r_facial = r_facial
	character.g_facial = g_facial
	character.b_facial = b_facial

	character.r_skin = r_skin
	character.g_skin = g_skin
	character.b_skin = b_skin

	character.s_tone = s_tone

	character.h_style = h_style
	character.f_style = f_style

	// Destroy/cyborgize organs
	for(var/name in organ_data)

		var/status = organ_data[name]
		var/obj/item/organ/external/O = character.organs_by_name[name]
		if(O)
			if(status == "amputated")
				character.organs_by_name[O.limb_name] = null
				character.organs -= O
				if(O.children) // This might need to become recursive.
					for(var/obj/item/organ/external/child in O.children)
						character.organs_by_name[child.limb_name] = null
						character.organs -= child

			else if(status == "cyborg")
				if(rlimb_data[name])
					O.robotize(rlimb_data[name])
				else
					O.robotize()
		else
			var/obj/item/organ/internal/I = character.get_int_organ_tag(name)
			if(I)
				if(status == "assisted")
					I.mechassist()
				else if(status == "mechanical")
					I.robotize()

	character.dna.b_type = b_type
	if(disabilities & DISABILITY_FLAG_FAT && character.species.flags & CAN_BE_FAT)
		character.dna.SetSEState(FATBLOCK,1,1)
		character.mutations += FAT
		character.mutations += OBESITY
		character.overeatduration = 600
	if(disabilities & DISABILITY_FLAG_NEARSIGHTED)
		character.dna.SetSEState(GLASSESBLOCK,1,1)
		character.disabilities|=NEARSIGHTED
	if(disabilities & DISABILITY_FLAG_EPILEPTIC)
		character.dna.SetSEState(EPILEPSYBLOCK,1,1)
		character.disabilities|=EPILEPSY
	if(disabilities & DISABILITY_FLAG_DEAF)
		character.dna.SetSEState(DEAFBLOCK,1,1)
		character.sdisabilities|=DEAF
	if(disabilities & DISABILITY_FLAG_MUTE)
		character.dna.SetSEState(MUTEBLOCK,1,1)
		character.sdisabilities |= MUTE

	S.handle_dna(character)

	if(character.dna.dirtySE)
		character.dna.UpdateSE()
	domutcheck(character)

	// Wheelchair necessary?
	var/obj/item/organ/external/l_foot = character.get_organ("l_foot")
	var/obj/item/organ/external/r_foot = character.get_organ("r_foot")
	if((!l_foot || l_foot.status & ORGAN_DESTROYED) && (!r_foot || r_foot.status & ORGAN_DESTROYED))
		var/obj/structure/stool/bed/chair/wheelchair/W = new /obj/structure/stool/bed/chair/wheelchair (character.loc)
		character.buckled = W
		character.update_canmove()
		W.dir = character.dir
		W.buckled_mob = character
		W.add_fingerprint(character)

	character.underwear = underwear
	character.undershirt = undershirt
	character.socks = socks

	if(character.species.bodyflags & HAS_HEAD_ACCESSORY)
		character.r_headacc = r_headacc
		character.g_headacc = g_headacc
		character.b_headacc = b_headacc
		character.ha_style = ha_style
	if(character.species.bodyflags & HAS_MARKINGS)
		character.r_markings = r_markings
		character.g_markings = g_markings
		character.b_markings = b_markings
		character.m_style = m_style

	if(body_accessory)
		character.body_accessory = body_accessory_by_name["[body_accessory]"]

	if(backbag > 4 || backbag < 1)
		backbag = 1 //Same as above
	character.backbag = backbag

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.gender in list(PLURAL, NEUTER))
		if(isliving(src)) //Ghosts get neuter by default
			message_admins("[key_name_admin(character)] has spawned with their gender as plural or neuter. Please notify coders.")
			character.change_gender(MALE)

	character.dna.ready_dna(character, flatten_SE = 0)
	character.sync_organ_dna(assimilate=1)
	character.UpdateAppearance()

	// Do the initial caching of the player's body icons.
	character.force_update_limbs()
	character.update_eyes()
	character.regenerate_icons()

/datum/preferences/proc/open_load_dialog(mob/user)

	var/DBQuery/query = dbcon.NewQuery("SELECT slot,real_name FROM [format_table_name("characters")] WHERE ckey='[user.ckey]' ORDER BY slot")

	var/dat = "<body>"
	dat += "<tt><center>"
	dat += "<b>Select a character slot to load</b><hr>"
	var/name

	for(var/i=1, i<=max_save_slots, i++)
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
			message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
			return
		while(query.NextRow())
			if(i==text2num(query.item[1]))
				name =  query.item[2]
		if(!name)	name = "Character[i]"
		if(i==default_slot)
			name = "<b>[name]</b>"
		dat += "<a href='?_src_=prefs;preference=changeslot;num=[i];'>[name]</a><br>"
		name = null

	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[user];preference=close_load_dialog'>Close</a><br>"
	dat += "</center></tt>"
//		user << browse(dat, "window=saves;size=300x390")
	var/datum/browser/popup = new(user, "saves", "<div align='center'>Character Saves</div>", 300, 390)
	popup.set_content(dat)
	popup.open(0)

/datum/preferences/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")
