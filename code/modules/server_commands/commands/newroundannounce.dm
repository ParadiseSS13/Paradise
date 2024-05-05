/datum/server_command/new_round_announce
	command_name = "new_round_announce"

/datum/server_command/new_round_announce/execute(source, command_args)
	var/server_name = command_args["sname"]
	var/map_name = command_args["mname"]
	var/map_fluff = command_args["mfluff"]

	var/startup_msg = "The server <code>[server_name] ([source])</code> is now starting up. The map is [map_fluff] ([map_name]). You can connect with the <code>Switch Server</code> verb."

	to_chat(world, "<center><span class='boldannounceooc'><big>Attention</big></span></center><hr>[startup_msg]<hr>")
	SEND_SOUND(world, sound('sound/misc/notice2.ogg')) // Same as captains priority announce

/datum/server_command/new_round_announce/custom_dispatch(sname, mname, mfluff)
	var/list/cmd_args = list()
	cmd_args["sname"] = sname
	cmd_args["mname"] = mname
	cmd_args["mfluff"] = mfluff

	dispatch(cmd_args)
