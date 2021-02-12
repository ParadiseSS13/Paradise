/datum/ui_module/volume_mixer
	name = "Volume Mixer"

/datum/ui_module/volume_mixer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "VolumeMixer", name, 400, clamp(80 + 50 * length(user.client.prefs.volume_mixer), 300, 600), master_ui, state)
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
