/datum/ui_module/volume_mixer
	name = "Volume Mixer"

/datum/ui_module/volume_mixer/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/volume_mixer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VolumeMixer", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/volume_mixer/ui_data(mob/user)
	var/list/data = list()

	var/list/channels = list()
	for(var/channel in user.client.prefs.volume_mixer)
		channels += list(list(
			"num" = channel,
			"name" = get_channel_name(text2num(channel)),
			"volume" = user.client.prefs.volume_mixer[channel]
		))
	data["channels"] = channels

	return data

/datum/ui_module/volume_mixer/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("volume")
			var/channel = text2num(params["channel"])
			var/volume = text2num(params["volume"])
			if(isnull(channel) || isnull(volume))
				return FALSE
			usr.client.prefs.set_channel_volume(channel, volume)
		else
			return FALSE
