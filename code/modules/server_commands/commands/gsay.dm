/datum/server_command/gsay
	command_name = "gsay"

/datum/server_command/gsay/execute(source, command_args)
	var/message = command_args["msg"]
	var/user = command_args["usr"]

	// Send to online admins
	for(var/client/C in GLOB.admins)
		if(C.holder.rights & R_ADMIN)
			to_chat(C, "<span class='admin_channel'>GSAY: [user]@[source]: [message]</span>")

/datum/server_command/gsay/custom_dispatch(ackey, message)
	var/list/cmd_args = list()
	cmd_args["usr"] = ackey
	cmd_args["msg"] = message

	dispatch(cmd_args)
