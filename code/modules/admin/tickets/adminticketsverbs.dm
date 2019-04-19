//Verbs

/client/proc/openAdminTicketUI()

	set name = "Open Admin Ticket Interface"
	set category = "Admin"

	if(!holder || !check_rights(R_ADMIN))
		return

	SStickets.showUI(usr)

/client/proc/resolveAllAdminTickets()
	set name = "Resolve All Open Admin Tickets"
	set category = "Admin"

	if(!holder || !check_rights(R_ADMIN))
		return

	if(alert("Are you sure you want to resolve ALL open tickets?","Resolve all open tickets?","Yes","No") != "Yes")
		return

	SStickets.resolveAllOpenTickets()

/client/verb/openAdminUserUI()
	set name = "My Admin Tickets"
	set category = "Admin"
	SStickets.userDetailUI(usr)
