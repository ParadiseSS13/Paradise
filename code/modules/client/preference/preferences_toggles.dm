//toggles
/client/verb/toggle_ghost_ears()
	set name = "Show/Hide GhostEars"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob speech, and only speech of nearby mobs"
	prefs.toggles ^= PREFTOGGLE_CHAT_GHOSTEARS
	to_chat(src, "As a ghost, you will now [(prefs.toggles & PREFTOGGLE_CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"].")
	prefs.save_preferences(src)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle GhostEars") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_sight()
	set name = "Show/Hide GhostSight"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob emotes, and only emotes of nearby mobs"
	prefs.toggles ^= PREFTOGGLE_CHAT_GHOSTSIGHT
	to_chat(src, "As a ghost, you will now [(prefs.toggles & PREFTOGGLE_CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"].")
	prefs.save_preferences(src)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle GhostSight") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_radio()
	set name = "Enable/Disable GhostRadio"
	set category = "Preferences"
	set desc = ".Toggle between hearing all radio chatter, or only from nearby speakers"
	prefs.toggles ^= PREFTOGGLE_CHAT_GHOSTRADIO
	to_chat(src, "As a ghost, you will now [(prefs.toggles & PREFTOGGLE_CHAT_GHOSTRADIO) ? "hear all radio chat in the world" : "only hear from nearby speakers"].")
	prefs.save_preferences(src)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle GhostRadio")

/client/proc/toggle_hear_radio()
	set name = "Show/Hide RadioChatter"
	set category = "Preferences"
	set desc = "Toggle seeing radiochatter from radios and speakers"
	if(!check_rights(R_ADMIN))
		return
	prefs.toggles ^= PREFTOGGLE_CHAT_RADIO
	prefs.save_preferences(src)
	to_chat(usr, "You will [(prefs.toggles & PREFTOGGLE_CHAT_RADIO) ? "now" : "no longer"] see radio chatter from radios or speakers")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle RadioChatter") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ai_voice_annoucements()
	set name = "Hear/Silence AI Voice Announcements"
	set category = "Preferences"
	set desc = "Toggle hearing AI annoucements in voice form or in text form"
	prefs.sound ^= SOUND_AI_VOICE
	prefs.save_preferences(src)
	to_chat(usr, "[(prefs.sound & SOUND_AI_VOICE) ? "You will now hear AI announcements." : "AI annoucements will now be converted to text."] ")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle AI Voice") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleadminhelpsound()
	set name = "Hear/Silence Admin Bwoinks"
	set category = "Preferences"
	set desc = "Toggle hearing a notification when admin PMs are recieved"
	if(!check_rights(R_ADMIN))
		return
	prefs.sound ^= SOUND_ADMINHELP
	prefs.save_preferences(src)
	to_chat(usr, "You will [(prefs.sound & SOUND_ADMINHELP) ? "now" : "no longer"] hear a sound when adminhelps arrive.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Admin Bwoinks") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/togglementorhelpsound()
	set name = "Hear/Silence Mentorhelp Bwoinks"
	set category = "Preferences"
	set desc = "Toggle hearing a notification when mentorhelps are recieved"
	if(!check_rights(R_ADMIN|R_MENTOR))
		return
	prefs.sound ^= SOUND_MENTORHELP
	prefs.save_preferences(src)
	to_chat(usr, "You will [(prefs.sound & SOUND_MENTORHELP) ? "now" : "no longer"] hear a sound when mentorhelps arrive.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Mentor Bwoinks") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/deadchat() // Deadchat toggle is usable by anyone.
	set name = "Show/Hide Deadchat"
	set category = "Preferences"
	set desc ="Toggles seeing deadchat"
	prefs.toggles ^= PREFTOGGLE_CHAT_DEAD
	prefs.save_preferences(src)

	if(src.holder)
		to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_CHAT_DEAD) ? "now" : "no longer"] see deadchat.")
	else
		to_chat(src, "As a ghost, you will [(prefs.toggles & PREFTOGGLE_CHAT_DEAD) ? "now" : "no longer"] see deadchat.")

	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Deadchat") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set name = "Show/Hide Prayers"
	set category = "Preferences"
	set desc = "Toggles seeing prayers"
	prefs.toggles ^= PREFTOGGLE_CHAT_PRAYER
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_CHAT_PRAYER) ? "now" : "no longer"] see prayerchat.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Prayers") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggleprayernotify()
	set name = "Hear/Silence Prayer Notification Sound"
	set category = "Preferences"
	set desc = "Toggles hearing when prayers are made"
	prefs.sound ^= SOUND_PRAYERNOTIFY
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.sound & SOUND_PRAYERNOTIFY) ? "now" : "no longer"] hear when prayers are made.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Prayer Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglescoreboard()
	set name = "Hide/Display End Round Scoreboard"
	set category = "Preferences"
	set desc = "Toggles displaying end of round scoreboard"
	prefs.toggles ^= PREFTOGGLE_DISABLE_SCOREBOARD
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_DISABLE_SCOREBOARD) ? "no longer" : "now"] see the end of round scoreboard.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Scoreboard") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglekarmareminder()
	set name = "Hide/Display End Round Karma Reminder"
	set category = "Preferences"
	set desc = "Toggles displaying end of round karma reminder"
	prefs.toggles ^= PREFTOGGLE_DISABLE_KARMA_REMINDER
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_DISABLE_KARMA_REMINDER) ? "no longer" : "now"] see the end of round karma reminder.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Karma Reminder") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggletitlemusic()
	set name = "Hear/Silence LobbyMusic"
	set category = "Preferences"
	set desc = "Toggles hearing the GameLobby music"
	prefs.sound ^= SOUND_LOBBY
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_LOBBY)
		to_chat(src, "You will now hear music in the game lobby.")
		if(isnewplayer(usr))
			usr.client.playtitlemusic()
	else
		to_chat(src, "You will no longer hear music in the game lobby.")
		usr.stop_sound_channel(CHANNEL_LOBBYMUSIC)

	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Lobby Music") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglemidis()
	set name = "Hear/Silence Midis"
	set category = "Preferences"
	set desc = "Toggles hearing sounds uploaded by admins"
	prefs.sound ^= SOUND_MIDI
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_MIDI)
		to_chat(src, "You will now hear any sounds uploaded by admins.")
	else
		usr.stop_sound_channel(CHANNEL_ADMIN)

		to_chat(src, "You will no longer hear sounds uploaded by admins; any currently playing midis have been disabled.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle MIDIs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/listen_ooc()
	set name = "Show/Hide OOC"
	set category = "Preferences"
	set desc = "Toggles seeing OutOfCharacter chat"
	prefs.toggles ^= PREFTOGGLE_CHAT_OOC
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle OOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/listen_looc()
	set name = "Show/Hide LOOC"
	set category = "Preferences"
	set desc = "Toggles seeing Local OutOfCharacter chat"
	prefs.toggles ^= PREFTOGGLE_CHAT_LOOC
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_CHAT_LOOC) ? "now" : "no longer"] see messages on the LOOC channel.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle LOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/Toggle_Soundscape() //All new ambience should be added here so it works with this verb until someone better at things comes up with a fix that isn't awful
	set name = "Hear/Silence Ambience"
	set category = "Preferences"
	set desc = "Toggles hearing ambient sound effects"
	prefs.sound ^= SOUND_AMBIENCE
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_AMBIENCE)
		to_chat(src, "You will now hear ambient sounds.")
	else
		to_chat(src, "You will no longer hear ambient sounds.")
		usr.stop_sound_channel(CHANNEL_AMBIENCE)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Ambience") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/Toggle_Buzz() //No more headaches because headphones bump up shipambience.ogg to insanity levels.
	set name = "Hear/Silence White Noise"
	set category = "Preferences"
	set desc = "Toggles hearing ambient white noise"
	prefs.sound ^= SOUND_BUZZ
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_BUZZ)
		to_chat(src, "You will now hear ambient white noise.")
	else
		to_chat(src, "You will no longer hear ambient white noise.")
		usr.stop_sound_channel(CHANNEL_BUZZ)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Whitenoise") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/Toggle_Heartbeat() //to toggle off heartbeat sounds, in case they get too annoying
	set name = "Hear/Silence Heartbeat"
	set category = "Preferences"
	set desc = "Toggles hearing heart beating sound effects"
	prefs.sound ^= SOUND_HEARTBEAT
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_HEARTBEAT)
		to_chat(src, "You will now hear heartbeat sounds.")
	else
		to_chat(src, "You will no longer hear heartbeat sounds.")
		usr.stop_sound_channel(CHANNEL_HEARTBEAT)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Hearbeat") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

// This needs a toggle because you people are awful and spammed terrible music
/client/verb/toggle_instruments()
	set name = "Hear/Silence Instruments"
	set category = "Preferences"
	set desc = "Toggles hearing musical instruments like the violin and piano"
	prefs.sound ^= SOUND_INSTRUMENTS
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_INSTRUMENTS)
		to_chat(src, "You will now hear people playing musical instruments.")
	else
		to_chat(src, "You will no longer hear musical instruments.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Instruments") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/Toggle_disco() //to toggle off the disco machine locally, in case it gets too annoying
	set name = "Hear/Silence Dance Machine"
	set category = "Preferences"
	set desc = "Toggles hearing and dancing to the radiant dance machine"
	prefs.sound ^= SOUND_DISCO
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_DISCO)
		to_chat(src, "You will now hear and dance to the radiant dance machine.")
	else
		to_chat(src, "You will no longer hear or dance to the radiant dance machine.")
		usr.stop_sound_channel(CHANNEL_JUKEBOX)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Dance Machine") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/setup_character()
	set name = "Game Preferences"
	set category = "Preferences"
	set desc = "Allows you to access the Setup Character screen. Changes to your character won't take effect until next round, but other changes will."
	prefs.current_tab = 1
	prefs.ShowChoices(usr)

/client/verb/toggle_darkmode()
	set name = "Toggle Darkmode"
	set category = "Preferences"
	set desc = "Toggles UI style between dark and light"
	prefs.toggles ^= PREFTOGGLE_UI_DARKMODE
	prefs.save_preferences(src)
	if(prefs.toggles & PREFTOGGLE_UI_DARKMODE)
		activate_darkmode()
	else
		deactivate_darkmode()
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Darkmode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_karma()
	set name = "Toggle Karma Gains"
	set category = "Special Verbs"
	set desc = "This button will allow you to stop other people giving you karma."
	prefs.toggles ^= PREFTOGGLE_DISABLE_KARMA
	prefs.save_preferences(src)
	if(prefs.toggles & PREFTOGGLE_DISABLE_KARMA)
		to_chat(usr, "<span class='notice'>You have disabled karma gains.")
	else
		to_chat(usr, "<span class='notice'>You have enabled karma gains.")

/client/verb/toggle_popup_limiter()
	set name = "Toggle Text Popup Limiter"
	set category = "Preferences"
	set desc = "Will let you limit the text input popups to one at a time."
	prefs.toggles ^= PREFTOGGLE_TYPING_ONCE
	prefs.save_preferences(src)
	if(prefs.toggles & PREFTOGGLE_TYPING_ONCE)
		to_chat(usr, "<span class='notice'>You have enabled text popup limiting.")
	else
		to_chat(usr, "<span class='notice'>You have disabled text popup limiting.")
	return

/client/verb/numpad_target()
	set name = "Toggle Numpad targetting"
	set category = "Preferences"
	set desc = "This button will allow you to enable or disable Numpad Targetting"
	prefs.toggles ^= PREFTOGGLE_NUMPAD_TARGET
	prefs.save_preferences(src)
	if (prefs.toggles & PREFTOGGLE_NUMPAD_TARGET)
		to_chat(usr, "<span class='notice'>You have enabled Numpad Targetting.")
	else
		to_chat(usr, "<span class='notice'>You have disabled Numpad Targetting.")
	return

/client/verb/azerty_toggle()
	set name = "Toggle QWERTY/AZERTY"
	set category = "Preferences"
	set desc = "This button will switch you between QWERTY and AZERTY control sets"
	prefs.toggles ^= PREFTOGGLE_AZERTY
	prefs.save_preferences(src)
	if (prefs.toggles & PREFTOGGLE_AZERTY)
		to_chat(usr, "<span class='notice'>You are now in AZERTY mode.")
	else
		to_chat(usr, "<span class='notice'>You are now in QWERTY mode.")
	return
/client/verb/toggle_ghost_pda()
	set name = "Show/Hide GhostPDA"
	set category = "Preferences"
	set desc = "Toggle seeing PDA messages as an observer."
	prefs.toggles ^= PREFTOGGLE_CHAT_GHOSTPDA
	to_chat(src, "As a ghost, you will now [(prefs.toggles & PREFTOGGLE_CHAT_GHOSTPDA) ? "see all PDA messages" : "no longer see PDA messages"].")
	prefs.save_preferences(src)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Ghost PDA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/silence_current_midi()
	set name = "Silence Current Midi"
	set category = "Preferences"
	set desc = "Silence the current admin midi playing"
	usr.stop_sound_channel(CHANNEL_ADMIN)
	to_chat(src, "The current admin midi has been silenced")


/client/verb/toggle_runechat()
	set name = "Enable/Disable Runechat"
	set category = "Preferences"
	set desc = "Toggle runechat messages"
	prefs.toggles2 ^= PREFTOGGLE_2_RUNECHAT
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles2 & PREFTOGGLE_2_RUNECHAT) ? "now see" : "no longer see"] floating chat messages.")

/client/verb/toggle_death_messages()
	set name = "Show/Hide Death Notifications"
	set category = "Preferences"
	set desc = "Toggle player death notifications"
	prefs.toggles2 ^= PREFTOGGLE_2_DEATHMESSAGE
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles2 & PREFTOGGLE_2_DEATHMESSAGE) ? "now" : "no longer"] see a notification in deadchat when a player dies.")
