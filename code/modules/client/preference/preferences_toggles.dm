//toggles
/client/verb/toggle_ghost_ears()
	set name = "GhostEars"
	set category = "Preferences.Show/Hide"
	set desc = "Toggle Between seeing all mob speech, and only speech of nearby mobs"
	prefs.toggles ^= PREFTOGGLE_CHAT_GHOSTEARS
	to_chat(src, "As a ghost, you will now [(prefs.toggles & PREFTOGGLE_CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"].")
	prefs.save_preferences(src)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle GhostEars") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_sight()
	set name = "GhostSight"
	set category = "Preferences.Show/Hide"
	set desc = "Toggle Between seeing all mob emotes, and only emotes of nearby mobs"
	prefs.toggles ^= PREFTOGGLE_CHAT_GHOSTSIGHT
	to_chat(src, "As a ghost, you will now [(prefs.toggles & PREFTOGGLE_CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"].")
	prefs.save_preferences(src)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle GhostSight") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_radio()
	set name = "GhostRadio"
	set category = "Preferences.Show/Hide"
	set desc = "Toggle between hearing all radio chatter, or only from nearby speakers"
	prefs.toggles ^= PREFTOGGLE_CHAT_GHOSTRADIO
	to_chat(src, "As a ghost, you will now [(prefs.toggles & PREFTOGGLE_CHAT_GHOSTRADIO) ? "hear all radio chat in the world" : "only hear from nearby speakers"].")
	prefs.save_preferences(src)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle GhostRadio")

/client/proc/toggle_hear_radio()
	set name = "RadioChatter"
	set category = "Preferences.Show/Hide"
	set desc = "Toggle seeing radiochatter from radios and speakers"
	if(!check_rights(R_ADMIN))
		return
	prefs.toggles ^= PREFTOGGLE_CHAT_RADIO
	prefs.save_preferences(src)
	to_chat(usr, "You will [(prefs.toggles & PREFTOGGLE_CHAT_RADIO) ? "now" : "no longer"] see radio chatter from radios or speakers")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle RadioChatter") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ai_voice_annoucements()
	set name = "AI Voice Announcements"
	set category = "Preferences.Hear/Silence"
	set desc = "Toggle hearing AI annoucements in voice form or in text form"
	prefs.sound ^= SOUND_AI_VOICE
	prefs.save_preferences(src)
	to_chat(usr, "[(prefs.sound & SOUND_AI_VOICE) ? "You will now hear AI announcements." : "AI annoucements will now be converted to text."] ")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle AI Voice") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleadminhelpsound()
	set name = "Admin Bwoinks"
	set category = "Preferences.Hear/Silence"
	set desc = "Toggle hearing a notification when admin PMs are received"
	if(!check_rights(R_ADMIN))
		return
	prefs.sound ^= SOUND_ADMINHELP
	prefs.save_preferences(src)
	to_chat(usr, "You will [(prefs.sound & SOUND_ADMINHELP) ? "now" : "no longer"] hear a sound when adminhelps arrive.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Admin Bwoinks") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/togglementorhelpsound()
	set name = "Mentorhelp Bwoinks"
	set category = "Preferences.Hear/Silence"
	set desc = "Toggle hearing a notification when mentorhelps are received"
	if(!check_rights(R_ADMIN|R_MENTOR))
		return
	prefs.sound ^= SOUND_MENTORHELP
	prefs.save_preferences(src)
	to_chat(usr, "You will [(prefs.sound & SOUND_MENTORHELP) ? "now" : "no longer"] hear a sound when mentorhelps arrive.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Mentor Bwoinks") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/deadchat() // Deadchat toggle is usable by anyone.
	set name = "Deadchat"
	set category = "Preferences.Show/Hide"
	set desc ="Toggles seeing deadchat"
	prefs.toggles ^= PREFTOGGLE_CHAT_DEAD
	prefs.save_preferences(src)

	if(src.holder)
		to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_CHAT_DEAD) ? "now" : "no longer"] see deadchat.")
	else
		to_chat(src, "As a ghost, you will [(prefs.toggles & PREFTOGGLE_CHAT_DEAD) ? "now" : "no longer"] see deadchat.")

	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Deadchat") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set name = "Prayers"
	set category = "Preferences.Show/Hide"
	set desc = "Toggles seeing prayers"
	prefs.toggles ^= PREFTOGGLE_CHAT_PRAYER
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_CHAT_PRAYER) ? "now" : "no longer"] see prayerchat.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Prayers") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggleprayernotify()
	set name = "Prayer Notification Sound"
	set category = "Preferences.Hear/Silence"
	set desc = "Toggles hearing when prayers are made"
	prefs.sound ^= SOUND_PRAYERNOTIFY
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.sound & SOUND_PRAYERNOTIFY) ? "now" : "no longer"] hear when prayers are made.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Prayer Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglescoreboard()
	set name = "End Round Scoreboard"
	set category = "Preferences.Show/Hide"
	set desc = "Toggles displaying end of round scoreboard"
	prefs.toggles ^= PREFTOGGLE_DISABLE_SCOREBOARD
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_DISABLE_SCOREBOARD) ? "no longer" : "now"] see the end of round scoreboard.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Scoreboard") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggletitlemusic()
	set name = "LobbyMusic"
	set category = "Preferences.Hear/Silence"
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
	set name = "Midis"
	set category = "Preferences.Hear/Silence"
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
	set name = "OOC (Out of Character)"
	set category = "Preferences.Show/Hide"
	set desc = "Toggles seeing OutOfCharacter chat"
	prefs.toggles ^= PREFTOGGLE_CHAT_OOC
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle OOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/listen_looc()
	set name = "LOOC (Local Out of Character)"
	set category = "Preferences.Show/Hide"
	set desc = "Toggles seeing Local OutOfCharacter chat"
	prefs.toggles ^= PREFTOGGLE_CHAT_LOOC
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_CHAT_LOOC) ? "now" : "no longer"] see messages on the LOOC channel.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle LOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/Toggle_Soundscape() //All new ambience should be added here so it works with this verb until someone better at things comes up with a fix that isn't awful
	set name = "Ambience"
	set category = "Preferences.Hear/Silence"
	set desc = "Toggles hearing ambient sound effects"
	prefs.sound ^= SOUND_AMBIENCE
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_AMBIENCE)
		to_chat(src, "You will now hear ambient sounds.")
	else
		to_chat(src, "You will no longer hear ambient sounds.")
		usr.stop_sound_channel(CHANNEL_AMBIENCE)
	update_ambience_pref()
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Ambience") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/Toggle_Parallax_Dark() //All new ambience should be added here so it works with this verb until someone better at things comes up with a fix that isn't awful
	set name = "Parallax in darkness"
	set category = "Preferences.Show/Hide"
	set desc = "If enabled, drawing parallax if you see in dark instead of black tiles."
	prefs.toggles2 ^= PREFTOGGLE_2_PARALLAX_IN_DARKNESS
	prefs.save_preferences(src)
	if(prefs.toggles2 & PREFTOGGLE_2_PARALLAX_IN_DARKNESS)
		to_chat(src, "You will now see parallax in dark with nightvisions.")
	else
		to_chat(src, "You will no longer see parallax in dark with nightvisions.")
	usr.hud_used?.update_parallax_pref()
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Parallax Darkness") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/Toggle_Buzz() //No more headaches because headphones bump up shipambience.ogg to insanity levels.
	set name = "White Noise"
	set category = "Preferences.Hear/Silence"
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
	set name = "Heartbeat"
	set category = "Preferences.Hear/Silence"
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
	set name = "Instruments"
	set category = "Preferences.Hear/Silence"
	set desc = "Toggles hearing musical instruments like the violin and piano"
	prefs.sound ^= SOUND_INSTRUMENTS
	prefs.save_preferences(src)
	if(prefs.sound & SOUND_INSTRUMENTS)
		to_chat(src, "You will now hear people playing musical instruments.")
	else
		to_chat(src, "You will no longer hear musical instruments.")
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Instruments") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_input()
	set name = "TGUI Input"
	set category = "Preferences.Toggle"
	set desc = "Switches inputs between the TGUI and the standard one"
	prefs.toggles2 ^= PREFTOGGLE_2_DISABLE_TGUI_INPUT
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles2 & PREFTOGGLE_2_DISABLE_TGUI_INPUT) ? "no longer" : "now"] use TGUI Inputs.")

/client/verb/Toggle_disco() //to toggle off the disco machine locally, in case it gets too annoying
	set name = "Dance Machine"
	set category = "Preferences.Hear/Silence"
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

/client/verb/toggle_ghost_pda()
	set name = "GhostPDA"
	set category = "Preferences.Show/Hide"
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
	set name = "Runechat"
	set category = "Preferences.Toggle"
	set desc = "Toggle runechat messages"
	prefs.toggles2 ^= PREFTOGGLE_2_RUNECHAT
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles2 & PREFTOGGLE_2_RUNECHAT) ? "now see" : "no longer see"] floating chat messages.")

/client/verb/toggle_death_messages()
	set name = "Death Notifications"
	set category = "Preferences.Toggle"
	set desc = "Toggle player death notifications"
	prefs.toggles2 ^= PREFTOGGLE_2_DEATHMESSAGE
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles2 & PREFTOGGLE_2_DEATHMESSAGE) ? "now" : "no longer"] see a notification in deadchat when a player dies.")

/client/verb/toggle_reverb()
	set name = "Reverb"
	set category = "Preferences.Toggle"
	set desc = "Toggle ingame reverb effects"
	prefs.toggles2 ^= PREFTOGGLE_2_REVERB_DISABLE
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles2 & PREFTOGGLE_2_REVERB_DISABLE) ? "no longer" : "now"] get reverb on ingame sounds.")

/client/verb/toggle_forced_white_runechat()
	set name = "Runechat Colour Forcing"
	set category = "Preferences.Toggle"
	set desc = "Toggles forcing your runechat colour to white"
	prefs.toggles2 ^= PREFTOGGLE_2_FORCE_WHITE_RUNECHAT
	prefs.save_preferences(src)
	to_chat(src, "Your runechats will [(prefs.toggles2 & PREFTOGGLE_2_FORCE_WHITE_RUNECHAT) ? "now" : "no longer"] be forced to be white.")

/client/verb/toggle_item_outlines()
	set name = "Item Outlines"
	set category = "Preferences.Toggle"
	set desc = "Toggles seeing item outlines on hover."
	prefs.toggles2 ^= PREFTOGGLE_2_SEE_ITEM_OUTLINES
	prefs.save_preferences(src)
	to_chat(usr, "You will [(prefs.toggles2 & PREFTOGGLE_2_SEE_ITEM_OUTLINES) ? "now" : "no longer"] see item outlines on hover.")

/client/verb/toggle_item_tooltips()
	set name = "Hover-over Item Tooltips"
	set category = "Preferences.Toggle"
	set desc = "Toggles textboxes with the item descriptions after hovering on them in your inventory."
	prefs.toggles2 ^= PREFTOGGLE_2_HIDE_ITEM_TOOLTIPS
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles2 & PREFTOGGLE_2_HIDE_ITEM_TOOLTIPS) ? "no longer" : "now"] see item tooltips when you hover over items on your HUD.")

/mob/verb/toggle_anonmode()
	set name = "Anonymous Mode"
	set category = "Preferences.Toggle"
	set desc = "Toggles showing your key in various parts of the game (deadchat, end round, etc)."
	client.prefs.toggles2 ^= PREFTOGGLE_2_ANON
	to_chat(src, "Your key will [(client.prefs.toggles2 & PREFTOGGLE_2_ANON) ? "no longer" : "now"] be shown in certain events (end round reports, deadchat, etc).</span>")
	client.prefs.save_preferences(src)

/client/verb/toggle_dance()
	set name = "Disco Machine Dancing"
	set category = "Preferences.Toggle"
	set desc = "Toggles automatic dancing from the radiant dance machine"
	prefs.toggles2 ^= PREFTOGGLE_2_DANCE_DISCO
	prefs.save_preferences(src)
	to_chat(usr, "You will [(prefs.toggles2 & PREFTOGGLE_2_DANCE_DISCO) ? "now" : "no longer"] dance to the radiant dance machine.")

/client/verb/manage_adminsound_mutes()
	set name = "Manage Admin Sound Mutes"
	set category = "Preferences"
	set desc = "Manage admins that you wont hear played audio from"

	if(!length(prefs.admin_sound_ckey_ignore))
		to_chat(usr, "You have no admins with muted sounds.")
		return

	var/choice  = input(usr, "Select an admin to unmute sounds from.", "Pick an admin") as null|anything in prefs.admin_sound_ckey_ignore
	if(!choice)
		return

	prefs.admin_sound_ckey_ignore -= choice
	to_chat(usr, "You will now hear sounds from <code>[choice]</code> again.")
	prefs.save_preferences(src)

/client/proc/toggle_mctabs()
	set name = "MC Tab"
	set category = "Preferences.Show/Hide"
	set desc = "Shows or hides the MC tab."
	prefs.toggles2 ^= PREFTOGGLE_2_MC_TAB
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles2 & PREFTOGGLE_2_MC_TAB) ? "now" : "no longer"] see the MC tab on the top right.")
