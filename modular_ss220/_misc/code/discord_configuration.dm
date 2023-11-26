/datum/configuration_section/discord_configuration
	/// Admin role to ping if no admins are online. Disables if empty string
	var/new_round_waiting_role = ""

/datum/configuration_section/discord_configuration/load_data(list/data)
	. = ..()

	CONFIG_LOAD_STR(new_round_waiting_role, data["new_round_waiting_role_id"])
