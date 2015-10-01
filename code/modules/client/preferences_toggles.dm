//toggles
/client/verb/toggle_ghost_ears()
	set name = "Show/Hide GhostEars"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob speech, and only speech of nearby mobs"
	prefs.toggles ^= CHAT_GHOSTEARS
	src << "As a ghost, you will now [(prefs.toggles & CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"]."
	prefs.save_preferences(src)
	feedback_add_details("admin_verb","TGE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_sight()
	set name = "Show/Hide GhostSight"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob emotes, and only emotes of nearby mobs"
	prefs.toggles ^= CHAT_GHOSTSIGHT
	src << "As a ghost, you will now [(prefs.toggles & CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"]."
	prefs.save_preferences(src)
	feedback_add_details("admin_verb","TGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_radio()
	set name = "Enable/Disable GhostRadio"
	set category = "Preferences"
	set desc = ".Toggle between hearing all radio chatter, or only from nearby speakers"
	prefs.toggles ^= CHAT_GHOSTRADIO
	src << "As a ghost, you will now [(prefs.toggles & CHAT_GHOSTRADIO) ? "hear all radio chat in the world" : "only hear from nearby speakers"]."
	prefs.save_preferences(src)
	feedback_add_details("admin_verb","TGR")

/client/proc/toggle_hear_radio()
	set name = "Show/Hide RadioChatter"
	set category = "Preferences"
	set desc = "Toggle seeing radiochatter from radios and speakers"
	if(!holder) return
	prefs.toggles ^= CHAT_RADIO
	prefs.save_preferences(src)
	usr << "You will [(prefs.toggles & CHAT_RADIO) ? "now" : "no longer"] see radio chatter from radios or speakers"
	feedback_add_details("admin_verb","THR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggleadminhelpsound()
	set name = "Hear/Silence Adminhelps"
	set category = "Preferences"
	set desc = "Toggle hearing a notification when admin PMs are recieved"
	if(!holder)	return
	prefs.sound ^= SOUND_ADMINHELP
	prefs.save_preferences(src)
	usr << "You will [(prefs.sound & SOUND_ADMINHELP) ? "now" : "no longer"] hear a sound when adminhelps arrive."
	feedback_add_details("admin_verb","AHS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/deadchat() // Deadchat toggle is usable by anyone.
	set name = "Show/Hide Deadchat"
	set category = "Preferences"
	set desc ="Toggles seeing deadchat"
	prefs.toggles ^= CHAT_DEAD
	prefs.save_preferences(src)

	if(src.holder)
		src << "You will [(prefs.toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat."
	else
		src << "As a ghost, you will [(prefs.toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat."

	feedback_add_details("admin_verb","TDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set name = "Show/Hide Prayers"
	set category = "Preferences"
	set desc = "Toggles seeing prayers"
	prefs.toggles ^= CHAT_PRAYER
	prefs.save_preferences(src)
	src << "You will [(prefs.toggles & CHAT_PRAYER) ? "now" : "no longer"] see prayerchat."
	feedback_add_details("admin_verb","TP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglescoreboard()
	set name = "Hide/Display End Round Scoreboard"
	set category = "Preferences"
	set desc = "Toggles displaying end of round scoreboard"
	prefs.toggles ^= DISABLE_SCOREBOARD
	prefs.save_preferences(src)
	src << "You will [(prefs.toggles & DISABLE_SCOREBOARD) ? "no longer" : "now"] see the end of round scoreboard."
	feedback_add_details("admin_verb","TScoreboard") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglekarmareminder()
	set name = "Hide/Display End Round Karma Reminder"
	set category = "Preferences"
	set desc = "Toggles displaying end of round karma reminder"
	prefs.toggles ^= DISABLE_KARMA_REMINDER
	prefs.save_preferences(src)
	src << "You will [(prefs.toggles & DISABLE_KARMA_REMINDER) ? "no longer" : "now"] see the end of round karma reminder."
	feedback_add_details("admin_verb","TKarmabugger") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggletitlemusic()
	set name = "Hear/Silence LobbyMusic"
	set category = "Preferences"
	set desc = "Toggles hearing the GameLobby music"
	prefs.sound ^= SOUND_LOBBY
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_LOBBY)
		src << "You will now hear music in the game lobby."
		if(istype(mob, /mob/new_player))
			playtitlemusic()
	else
		src << "You will no longer hear music in the game lobby."
		if(istype(mob, /mob/new_player))
			src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // stop the jamsz
	feedback_add_details("admin_verb","TLobby") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglemidis()
	set name = "Hear/Silence Midis"
	set category = "Preferences"
	set desc = "Toggles hearing sounds uploaded by admins"
	prefs.sound ^= SOUND_MIDI
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_MIDI)
		src << "You will now hear any sounds uploaded by admins."
	else
		var/sound/break_sound = sound(null, repeat = 0, wait = 0, channel = 777)
		break_sound.priority = 250
		src << break_sound	//breaks the client's sound output on channel 777
		src << "You will no longer hear sounds uploaded by admins; any currently playing midis have been disabled."
	feedback_add_details("admin_verb","TMidi") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/listen_ooc()
	set name = "Show/Hide OOC"
	set category = "Preferences"
	set desc = "Toggles seeing OutOfCharacter chat"
	prefs.toggles ^= CHAT_OOC
	prefs.save_preferences(src)
	src << "You will [(prefs.toggles & CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel."
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/listen_looc()
	set name = "Show/Hide LOOC"
	set category = "Preferences"
	set desc = "Toggles seeing Local OutOfCharacter chat"
	prefs.toggles ^= CHAT_LOOC
	prefs.save_preferences(src)
	src << "You will [(prefs.toggles & CHAT_LOOC) ? "now" : "no longer"] see messages on the LOOC channel."
	feedback_add_details("admin_verb","TLOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/Toggle_Soundscape() //All new ambience should be added here so it works with this verb until someone better at things comes up with a fix that isn't awful
	set name = "Hear/Silence Ambience"
	set category = "Preferences"
	set desc = "Toggles hearing ambient sound effects"
	prefs.sound ^= SOUND_AMBIENCE
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_AMBIENCE)
		src << "You will now hear ambient sounds."
	else
		src << "You will no longer hear ambient sounds."
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 1)
	feedback_add_details("admin_verb","TAmbi") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/Toggle_Buzz() //No more headaches because headphones bump up shipambience.ogg to insanity levels.
	set name = "Hear/Silence White Noise"
	set category = "Preferences"
	set desc = "Toggles hearing ambient white noise"
	prefs.sound ^= SOUND_BUZZ
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_BUZZ)
		src << "You will now hear ambient white noise."
	else
		src << "You will no longer hear ambient white noise."
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 2)
	feedback_add_details("admin_verb","TBuzz") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/Toggle_Heartbeat() //to toggle off heartbeat sounds, in case they get too annoying
	set name = "Hear/Silence Heartbeat"
	set category = "Preferences"
	set desc = "Toggles hearing heart beating sound effects"
	prefs.sound ^= SOUND_HEARTBEAT
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_HEARTBEAT)
		src << "You will now hear heartbeat sounds."
	else
		src << "You will no longer hear heartbeat sounds."
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 1)
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 2)
	feedback_add_details("admin_verb","Thb") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	
// This needs a toggle because you people are awful and spammed terrible music
/client/verb/toggle_instruments()
	set name = "Hear/Silence Instruments"
	set category = "Preferences"
	set desc = "Toggles hearing musical instruments like the violin and piano"
	prefs.toggles ^= SOUND_INSTRUMENTS
	prefs.save_preferences(src)
	if(prefs.toggles & SOUND_INSTRUMENTS)
		src << "You will now hear people playing musical instruments."
	else
		src << "You will no longer hear musical instruments."
	feedback_add_details("admin_verb","TInstru") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//be special
/client/verb/toggle_be_special(role in be_special_flags)
	set name = "Toggle Special Role Candidacy"
	set category = "Preferences"
	set desc = "Toggles which special roles you would like to be a candidate for, during events."
	var/role_flag = be_special_flags[role]
	if(!role_flag)	return
	if(!player_old_enough_antag(src,be_special_flags[role]))
		var/available_in_days_antag = available_in_days_antag(src,be_special_flags[role])
		src << "<span class='warning'>This role is not yet available to you. You need to wait another [available_in_days_antag] days.</span>"
		return
	prefs.be_special ^= role_flag
	prefs.save_preferences(src)
	src << "You will [(prefs.be_special & role_flag) ? "now" : "no longer"] be considered for [role] events (where possible)."
	feedback_add_details("admin_verb","TBeSpecial") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/change_ui()
	set name = "Change UI"
	set category = "Preferences"
	set desc = "Configure your user interface"

	if(!ishuman(usr))
		usr << "This only for human"
		return

	var/UI_style_new = input(usr, "Select a style, we recommend White for customization") in list("White", "Midnight", "Orange", "old")
	if(!UI_style_new) return

	var/UI_style_alpha_new = input(usr, "Select a new alpha (transparency) parameter for UI, between 50 and 255") as num
	if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return

	var/UI_style_color_new = input(usr, "Choose your UI color. Dark colors are not recommended!") as color|null
	if(!UI_style_color_new) return

	//update UI
	var/list/icons = usr.hud_used.adding + usr.hud_used.other +usr.hud_used.hotkeybuttons
	icons.Add(usr.zone_sel)

	for(var/obj/screen/I in icons)
		I.icon = ui_style2icon(UI_style_new)
		I.color = UI_style_color_new
		I.alpha = UI_style_alpha_new

	if(alert("Like it? Save changes?",,"Yes", "No") == "Yes")
		prefs.UI_style = UI_style_new
		prefs.UI_style_alpha = UI_style_alpha_new
		prefs.UI_style_color = UI_style_color_new
		prefs.save_preferences(src)
		usr << "UI was saved"

/client/verb/toggle_media()
	set name = "Hear/Silence Streaming"
	set category = "Preferences"
	set desc = "Toggle hearing streaming media (radios, jukeboxes, etc)"

	prefs.sound ^= SOUND_STREAMING
	prefs.save_preferences(src)
	usr << "You will [(prefs.sound & SOUND_STREAMING) ? "now" : "no longer"] hear streamed media."
	if(!media) return
	if(prefs.toggles & SOUND_STREAMING)
		media.update_music()
	else
		media.stop_music()
		
/client/verb/toggle_member_publicity()
	set name = "Toggle Membership Publicity"
	set category = "Preferences"
	set desc = "Toggles whether other players can see that you are a BYOND member (OOC blag icon/colours)."
	
	prefs.toggles ^= MEMBER_PUBLIC
	prefs.save_preferences(src)
	src << "Others can[(prefs.toggles & MEMBER_PUBLIC) ? "" : " not"] see whether you are a BYOND member."
