//Verbs

/client/proc/openTicketUI()

	set name = "Open Ticket Interface"
	set category = "Admin"

	if(!holder || !check_rights(R_ADMIN))
		return

	SStickets.showUI(usr)

/client/proc/resolveAllTickets()
	set name = "Resolve All Open Tickets"
	set category = "Admin"

	if(!holder || !check_rights(R_ADMIN))
		return

	if(alert("Are you sure you want to resolve ALL open tickets?","Resolve all open tickets?","Yes","No") != "Yes")
		return

	SStickets.resolveAllOpenTickets()

/client/proc/openUserUI()

	set name = "My Tickets"
	set category = "Admin"

	if(!holder || !check_rights(R_ADMIN))
		return

	SStickets.userDetailUI(usr)
