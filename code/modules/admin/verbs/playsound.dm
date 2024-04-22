GLOBAL_LIST_EMPTY(sounds_cache)

/client/proc/stop_global_admin_sounds()
	set category = "Event"
	set name = "Stop Global Admin Sounds"
	if(!check_rights(R_SOUNDS))
		return

	var/sound/awful_sound = sound(null, repeat = 0, wait = 0, channel = CHANNEL_ADMIN)

	log_admin("[key_name(src)] stopped admin sounds.")
	message_admins("[key_name_admin(src)] stopped admin sounds.", 1)
	for(var/mob/M in GLOB.player_list)
		M << awful_sound

/client/proc/play_sound(S as sound)
	set category = "Event"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))	return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = CHANNEL_ADMIN)
	uploaded_sound.priority = 250

	GLOB.sounds_cache += S

	if(alert("Are you sure?\nSong: [S]\nNow you can also play this sound using \"Play Server Sound\".", "Confirmation request" ,"Play", "Cancel") == "Cancel")
		return

	if(holder.fakekey)
		if(alert("Playing this sound will expose your real ckey despite being in stealth mode. You sure?", "Double check" ,"Play", "Cancel") == "Cancel")
			return


	log_admin("[key_name(src)] played sound [S]")
	message_admins("[key_name_admin(src)] played sound [S]", 1)

	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.sound & SOUND_MIDI)
			if(ckey in M.client.prefs.admin_sound_ckey_ignore)
				continue // This player has this admin muted
			if(isnewplayer(M) && (M.client.prefs.sound & SOUND_LOBBY))
				M.stop_sound_channel(CHANNEL_LOBBYMUSIC)
			uploaded_sound.volume = 100 * M.client.prefs.get_channel_volume(CHANNEL_ADMIN)

			var/this_uid = M.client.UID()
			to_chat(M, "<span class='boldannounceic'>[ckey] played <code>[S]</code> (<a href='byond://?src=[this_uid];action=silenceSound'>SILENCE</a>) (<a href='byond://?src=[this_uid];action=muteAdmin&a=[ckey]'>ALWAYS SILENCE THIS ADMIN</a>)</span>")
			SEND_SOUND(M, uploaded_sound)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Global Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound(S as sound)
	set category = "Event"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))	return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]", 1)
	playsound(get_turf(src.mob), S, 50, 0, 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Local Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_server_sound()
	set category = "Event"
	set name = "Play Server Sound"
	if(!check_rights(R_SOUNDS))	return

	var/list/sounds = file2list("sound/serversound_list.txt")
	sounds += GLOB.sounds_cache

	var/melody = input("Select a sound from the server to play", "Server sound list") as null|anything in sounds
	if(!melody)	return

	play_sound(melody)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Server Sound") //If you are copy-pasting this, ensure the 2nd paramter is unique to the new proc!

/client/proc/play_intercomm_sound()
	set category = "Event"
	set name = "Play Sound via Intercomms"
	set desc = "Plays a sound at every intercomm on the station z level. Works best with small sounds."
	if(!check_rights(R_SOUNDS))	return

	var/A = alert("This will play a sound at every intercomm, are you sure you want to continue? This works best with short sounds, beware.","Warning","Yep","Nope")
	if(A != "Yep")	return

	var/list/sounds = file2list("sound/serversound_list.txt")
	sounds += GLOB.sounds_cache

	var/melody = input("Select a sound from the server to play", "Server sound list") as null|anything in sounds
	if(!melody)	return

	var/cvol = 35
	var/inputvol = input("How loud would you like this to be? (1-70)", "Volume", "35") as num | null
	if(!inputvol)	return
	if(inputvol && inputvol >= 1 && inputvol <= 70)
		cvol = inputvol

	//Allows for override to utilize intercomms on all z-levels
	var/B = alert("Do you want to play through intercomms on ALL Z-levels, or just the station?", "Override", "All", "Station")
	var/ignore_z = 0
	if(B == "All")
		ignore_z = 1

	//Allows for override to utilize incomplete and unpowered intercomms
	var/C = alert("Do you want to play through unpowered / incomplete intercomms, so the crew can't silence it?", "Override", "Yep", "Nope")
	var/ignore_power = 0
	if(C == "Yep")
		ignore_power = 1

	for(var/O in GLOB.global_intercoms)
		var/obj/item/radio/intercom/I = O
		if(!is_station_level(I.z) && !ignore_z)
			continue
		if(!I.on && !ignore_power)
			continue
		playsound(I, melody, cvol)
