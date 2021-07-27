/datum/game_mode/blob/check_finished()
	if(infected_crew.len > burst)//Some blobs have yet to burst
		return 0
	if(blobwincount <= GLOB.blobs.len)//Blob took over
		return 1
	if(!GLOB.blob_cores.len) // blob is dead
		return 1
	return ..()


/datum/game_mode/blob/declare_completion()
	if(blobwincount <= GLOB.blobs.len)
		SSticker.mode_result = "blob win - blob took over"
		to_chat(world, "<FONT size = 3><B>The blob has taken over the station!</B></FONT>")
		to_chat(world, "<B>The entire station was eaten by the Blob</B>")
		log_game("Blob mode completed with a blob victory.")

	else if(station_was_nuked)
		SSticker.mode_result = "blob halfwin - nuke"
		to_chat(world, "<FONT size = 3><B>Partial Win: The station has been destroyed!</B></FONT>")
		to_chat(world, "<B>Directive 7-12 has been successfully carried out preventing the Blob from spreading.</B>")
		log_game("Blob mode completed with a tie (station destroyed).")

	else if(!GLOB.blob_cores.len)
		SSticker.mode_result = "blob loss - blob eliminated"
		to_chat(world, "<FONT size = 3><B>The staff has won!</B></FONT>")
		to_chat(world, "<B>The alien organism has been eradicated from the station</B>")
		log_game("Blob mode completed with a crew victory.")
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_blob()
	if(GAMEMODE_IS_BLOB)
		var/datum/game_mode/blob/blob_mode = src
		if(blob_mode.infected_crew.len)
			var/text = "<FONT size = 2><B>The blob[(blob_mode.infected_crew.len > 1 ? "s were" : " was")]:</B></FONT>"

			for(var/datum/mind/blob in blob_mode.infected_crew)
				text += "<br><b>[blob.key]</b> was <b>[blob.name]</b>"
			to_chat(world, text)
		return 1
