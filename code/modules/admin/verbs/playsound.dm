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
		var/client/C = M.client
		C?.tgui_panel?.stop_music()

/client/proc/play_sound(S as sound)
	set category = "Event"
	set name = "Legacy Play Global Sound"
	if(!check_rights(R_SOUNDS))	return

	if(alert("WARNING: Legacy Play Global Sound does not support CDN asset sending. Sounds will have to be sent directly to players, which may freeze the game for long durations. Are you SURE?", "Really use Legacy Play Global Sound?", "Yes", "No") == "No")
		return

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
	playsound(get_turf(src.mob), S, 50, FALSE, 0)
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

/client/proc/stop_sounds_global()
	set category = "Debug"
	set name = "Stop Sounds Global"
	set desc = "Stop all playing sounds globally."
	if(!check_rights(R_SOUNDS))
		return

	log_admin("[key_name(src)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(src)] stopped all currently playing sounds.")
	for(var/mob/M in GLOB.player_list)
		SEND_SOUND(M, sound(null))
		var/client/C = M.client
		C?.tgui_panel?.stop_music()

/client/proc/play_sound_tgchat()
	set category = "Event"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))
		return

	var/sound_mode = tgui_alert(src, "Play a sound from which source?", "Select Source", list("Web", "Upload MP3"))
	if(!sound_mode)
		return

	var/web_sound_input
	var/asset_name
	var/must_send_assets = FALSE
	var/web_sound_url = ""
	var/list/music_extra_data = list()
	var/list/data = list()

	if(sound_mode == "Web")
		if(!GLOB.configuration.system.ytdlp_url)
			to_chat(src, "<span class='boldwarning'>yt-dlp was not configured, action unavailable</span>") //Check config
			return

		web_sound_input = tgui_input_text(src, "Enter content URL", "Play Internet Sound", null)
		if(!length(web_sound_input))
			return

		web_sound_input = trim(web_sound_input)

		if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
			to_chat(src, "<span class='boldwarning'>Non-http(s) URIs are not allowed.</span>")
			to_chat(src, "<span class='warning'>For yt-dlp shortcuts like ytsearch: please use the appropriate full url from the website.</span>")
			return

		// Prepare the body
		var/list/request_body = list("url" = web_sound_input)
		// Send the request off
		var/datum/http_request/media_poll_request = new()
		// The fact we are using GET with a body offends me
		media_poll_request.prepare(RUSTLIBS_HTTP_METHOD_GET, GLOB.configuration.system.ytdlp_url, json_encode(request_body))
		// Start it off and wait
		media_poll_request.begin_async()
		UNTIL(media_poll_request.is_complete())
		var/datum/http_response/media_poll_response = media_poll_request.into_response()

		if(media_poll_response.status_code == 200)
			try
				data = json_decode(media_poll_response.body)
			catch(var/exception/e)
				to_chat(src, "<span class='boldwarning'>yt-dlp JSON parsing FAILED:</span>")
				to_chat(src, "<span class='warning'>[e]: [media_poll_response.body]</span>")
				return
		else
			to_chat(src, "<span class='boldwarning'>yt-dlp URL retrieval FAILED:</span>")
			to_chat(src, "<span class='warning'>[media_poll_response.body]</span>")
			return

	else if(sound_mode == "Upload MP3")
		if(GLOB.configuration.asset_cache.asset_transport == "simple")
			if(tgui_alert(src, "WARNING: Your server is using simple asset transport. Sounds will have to be sent directly to players, which may freeze the game for long durations. Are you SURE?", "Really play direct sound?", list("Yes", "No")) != "Yes")
				return
			must_send_assets = TRUE

		var/soundfile = input(src, "Choose an MP3 file to play", "Upload Sound") as null|file
		if(!soundfile)
			return

		var/static/regex/only_extension = regex(@{"^.*\.([a-z0-9]{1,5})$"}, "gi")
		var/extension = only_extension.Replace("[soundfile]", "$1")
		if(!length(extension) || extension != "mp3")
			to_chat(src, "<span class='boldwarning'>Invalid filename extension.</span>")
			return

		var/static/playsound_notch = 1
		asset_name = "admin_sound_[playsound_notch++].[extension]"
		SSassets.transport.register_asset(asset_name, soundfile)
		log_admin("[key_name_admin(src)] uploaded admin sound '[soundfile]' to asset transport.")
		message_admins("[key_name_admin(src)] uploaded admin sound '[soundfile]' to asset transport.")

		var/static/regex/remove_extension = regex(@{"\.[a-z0-9]+$"}, "gi")
		data["title"] = remove_extension.Replace("[soundfile]", "")
		data["sound_url"] = SSassets.transport.get_asset_url(asset_name)
		web_sound_input = "[soundfile]"

	if(data["sound_url"])
		web_sound_url = data["sound_url"]
		var/title = "[data["title"]]"
		var/webpage_url = title
		if(data["webpage_url"])
			webpage_url = "<a href=\"[data["webpage_url"]]\">[title]</a>"
		music_extra_data["start"] = data["start"]
		music_extra_data["end"] = data["end"]
		music_extra_data["link"] = data["webpage_url"]
		music_extra_data["title"] = data["title"]

		var/res = tgui_alert(src, "Show the title of and link to this song to the players?\n[title]", "Show Info?", list("Yes", "No"))
		if(!res)
			return
		if(res == "Yes")
			log_admin("[key_name(src)] played sound: [web_sound_input]")
			message_admins("[key_name(src)] played sound: [web_sound_input]")
			to_chat(world, "<span class='boldannounceooc'>[src.ckey] played: [webpage_url]</span>")
		else if(res == "No")
			music_extra_data["link"] = "Song Link Hidden"
			music_extra_data["title"] = "Song Title Hidden"
			music_extra_data["artist"] = "Song Artist Hidden"
			log_admin("[key_name(src)] played sound: [web_sound_input]")
			message_admins("[key_name(src)] played sound: [web_sound_input]")
			to_chat(world, "<span class='boldannounceooc'>[src.ckey] played a sound</span>")

		SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Global Sound TGchat")

	if(!must_send_assets && web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
		to_chat(src, "<span class='boldwarning'>BLOCKED: Content URL not using http(s) protocol</span>", confidential = TRUE)
		to_chat(src, "<span class='warning'>The media provider returned a content URL that isn't using the HTTP or HTTPS protocol</span>", confidential = TRUE)
		return

	if(web_sound_url)
		for(var/mob/M in GLOB.player_list)
			var/client/C = M.client
			var/player_uid = M.client.UID()
			if(C.prefs.sound & SOUND_MIDI)
				if(ckey in M.client.prefs.admin_sound_ckey_ignore)
					to_chat(C, "<span class='warning'>But [src.ckey] is muted locally in preferences!</span>")
					continue
				else
					if(must_send_assets)
						SSassets.transport.send_assets(C, asset_name)
					C.tgui_panel?.play_music(web_sound_url, music_extra_data)
					to_chat(C, "<span class='warning'>(<a href='byond://?src=[player_uid];action=silenceSound'>SILENCE</a>) (<a href='byond://?src=[player_uid];action=muteAdmin&a=[ckey]'>ALWAYS SILENCE THIS ADMIN</a>)</span>")
			else
				to_chat(C, "<span class='warning'>But Admin MIDIs are disabled in preferences!</span>")
	return
