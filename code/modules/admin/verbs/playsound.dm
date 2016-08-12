var/list/sounds_cache = list()

/client/proc/play_sound(S as sound)
	set category = "Event"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))	return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = 777)
	uploaded_sound.priority = 250

	sounds_cache += S

	if(alert("Are you sure?\nSong: [S]\nNow you can also play this sound using \"Play Server Sound\".", "Confirmation request" ,"Play", "Cancel") == "Cancel")
		return

	log_admin("[key_name(src)] played sound [S]")
	message_admins("[key_name_admin(src)] played sound [S]", 1)
	for(var/mob/M in player_list)
		if(M.client.prefs.sound & SOUND_MIDI)
			M << uploaded_sound

	feedback_add_details("admin_verb","PGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound(S as sound)
	set category = "Event"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))	return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]", 1)
	playsound(get_turf(src.mob), S, 50, 0, 0)
	feedback_add_details("admin_verb","PLS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_server_sound()
	set category = "Event"
	set name = "Play Server Sound"
	if(!check_rights(R_SOUNDS))	return

	var/list/sounds = file2list("sound/serversound_list.txt");
	sounds += sounds_cache

	var/melody = input("Select a sound from the server to play", "Server sound list") as null|anything in sounds
	if(!melody)	return

	play_sound(melody)
	feedback_add_details("admin_verb","PSS") //If you are copy-pasting this, ensure the 2nd paramter is unique to the new proc!

/client/proc/play_intercomm_sound()
	set category = "Event"
	set name = "Play Sound via Intercomms"
	set desc = "Plays a sound at every intercomm on the station z level. Works best with small sounds."
	if(!check_rights(R_SOUNDS))	return

	var/A = alert("This will play a sound at every intercomm, are you sure you want to continue? This works best with short sounds, beware.","Warning","Yep","Nope")
	if(A != "Yep")	return

	var/list/sounds = file2list("sound/serversound_list.txt");
	sounds += sounds_cache

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

	for(var/O in global_intercoms)
		var/obj/item/device/radio/intercom/I = O
		if(!is_station_level(I.z) && !ignore_z)
			continue
		if(!I.on && !ignore_power)
			continue
		playsound(I, melody, cvol)

/*
/client/proc/cuban_pete()
	set category = "Event"
	set name = "Cuban Pete Time"

	message_admins("[key_name_admin(usr)] has declared Cuban Pete Time!", 1)
	for(var/mob/M in world)
		if(M.client)
			if(M.client.midis)
				M << 'cubanpetetime.ogg'

	for(var/mob/living/carbon/human/CP in world)
		if(CP.real_name=="Cuban Pete" && CP.key!="Rosham")
			C << "Your body can't contain the rhumba beat"
			CP.gib()


/client/proc/bananaphone()
	set category = "Event"
	set name = "Banana Phone"

	message_admins("[key_name_admin(usr)] has activated Banana Phone!", 1)
	for(var/mob/M in world)
		if(M.client)
			if(M.client.midis)
				M << 'bananaphone.ogg'


client/proc/space_asshole()
	set category = "Event"
	set name = "Space Asshole"

	message_admins("[key_name_admin(usr)] has played the Space Asshole Hymn.", 1)
	for(var/mob/M in world)
		if(M.client)
			if(M.client.midis)
				M << 'sound/music/space_asshole.ogg'


client/proc/honk_theme()
	set category = "Event"
	set name = "Honk"

	message_admins("[key_name_admin(usr)] has creeped everyone out with Blackest Honks.", 1)
	for(var/mob/M in world)
		if(M.client)
			if(M.client.midis)
				M << 'honk_theme.ogg'*/
