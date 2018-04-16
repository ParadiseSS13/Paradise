//Verbs

/client/proc/startadmintickets()
	set name = "Restart Admin Ticket System"
	set category = "Debug"

	if(!holder && !check_rights(R_DEBUG))
		return

	if(!globAdminTicketHolder)
		var/global/datum/adminTicketHolder/globAdminTicketHolder = new /datum/adminTicketHolder
	else
		if(alert("Are you sure you want to reboot the admin ticket system?","Reboot Admin Tickets?","Yes","No") != "Yes")
			return
		message_admins("<span class='admintickets'>Restarting Admin Ticket System!</span>")
		globAdminTicketHolder = new /datum/adminTicketHolder
		message_admins("<span class='admintickets'>Admin Ticket System Restarted!</span>")

/client/proc/openTicketUI()

	set name = "Open Ticket Interface"
	set category = "Admin"

	if(!holder && !check_rights(R_ADMIN))
		return

	globAdminTicketHolder.showUI(usr)

/client/proc/resolveAllTickets()
	set name = "Resolve All Open Tickets"
	set category = "Admin"

	if(!holder && !check_rights(R_ADMIN))
		return

	if(alert("Are you sure you want to resolve ALL open tickets?","Resolve all open tickets?","Yes","No") != "Yes")
		return

	globAdminTicketHolder.resolveAllOpenTickets()



/client/proc/openUserUI()

	set name = "My Tickets"
	set category = "Admin"

	if(!holder && !check_rights(R_ADMIN))
		return

	globAdminTicketHolder.userDetailUI(usr.client)
