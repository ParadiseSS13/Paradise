/obj/machinery/computer/shuttle/ert
	name = "specops shuttle console"
	req_access = list(ACCESS_CENT_GENERAL)
	shuttleId = "specops"
	possible_destinations = "specops_home;specops_away;specops_custom"
	resistance_flags = INDESTRUCTIBLE
	flags = NODECONSTRUCT

/obj/machinery/computer/shuttle/ert/can_call_shuttle(mob/user, action)
	if(action == "move")
		var/authorized_roles = list(SPECIAL_ROLE_ERT, SPECIAL_ROLE_DEATHSQUAD)
		if(!((user.mind?.assigned_role in authorized_roles) || is_admin(user)))
			message_admins("Potential ERT shuttle hijack, ERT shuttle moved by unauthorized user: [key_name_admin(user)]")
	return TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/ert
	name = "specops navigation computer"
	desc = "Used to designate a precise transit location for the specops shuttle."
	shuttleId = "specops"
	shuttlePortId = "specops_custom"
	view_range = 13
	resistance_flags = INDESTRUCTIBLE
	flags = NODECONSTRUCT
	access_mining = FALSE
