/**
  * Returns a DB-friendly version of a volume mixer list.
  *
  * Arguments
  * * vm - The volume mixer list to serialize.
  */
/datum/preferences/proc/serialize_volume_mixer(list/vm)
	var/list/temp = list()
	for(var/channel in vm)
		if(!get_channel_name(text2num(channel)))
			continue
		temp["[channel]"] = vm[channel]
	return json_encode(temp)

/**
  * Returns a volume mixer list from text, usually from the DB.
  *
  * Failure to deserialize will return the current value.
  *
  * Arguments
  * * vmt - The volume mixer list to deserialize.
  */
/datum/preferences/proc/deserialize_volume_mixer(vmt)
	if(!istext(vmt))
		return volume_mixer
	var/list/vm = json_decode(vmt)
	if(!islist(vm))
		return volume_mixer
	var/list/temp = list()
	// Ensure the default values are present
	for(var/channel in volume_mixer)
		temp[channel] = volume_mixer[channel]
	for(var/channel in vm)
		if(!get_channel_name(text2num(channel)))
			continue
		temp[channel] = vm[channel]
	return temp

/**
  * Changes a channel's volume then queues it for DB save.
  *
  * Arguments:
  * * channel - The channel whose volume to change.
  * * volume - The new volume, clamped between 0 and 100.
  * * debounce_save - Whether to debounce the save call to prevent spamming of DB calls.
  */
/datum/preferences/proc/set_channel_volume(channel, volume, debounce_save = TRUE)
	if(!get_channel_name(channel))
		return
	// Set the volume
	volume = clamp(volume, 0, 100)
	volume_mixer["[channel]"] = volume
	var/sound/S
	var/channel_already_updated = FALSE
	// special handling for looping sounds, especially if they're decreasing
	for(var/datum/looping_sound/D in GLOB.looping_sounds)
		if(channel == D.channel)
			S = sound(null, channel = channel, volume = D.volume * volume / 100)
			S.status = SOUND_UPDATE
			SEND_SOUND(parent, S)
			channel_already_updated = TRUE

	if(!channel_already_updated)
		// Update the currently playing sound to update its volume
		S = sound(null, channel = channel, volume = volume)
		S.status = SOUND_UPDATE
		SEND_SOUND(parent, S)
	// Save it
	if(debounce_save)
		volume_mixer_saving = addtimer(CALLBACK(src, PROC_REF(save_volume_mixer)), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
	else
		if(volume_mixer_saving)
			deltimer(volume_mixer_saving)
		save_volume_mixer()

/**
  * Returns a volume multiplier for the given channel, from 0 to 1 (default).
  *
  * Arguments:
  * * channel - The channel whose volume to get.
  */
/datum/preferences/proc/get_channel_volume(channel)
	if(!istext(channel))
		channel = "[channel]"
	if(isnull(volume_mixer[channel]))
		return 1
	return clamp(volume_mixer[channel] / 100, 0, 1)

/client/verb/volume_mixer()
	set name = "Open Volume Mixer"
	set category = "Preferences"
	set hidden = TRUE

	var/datum/ui_module/volume_mixer/VM = new()
	VM.ui_interact(usr)
