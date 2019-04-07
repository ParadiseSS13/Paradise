//Verbs

/client/proc/openMentorTicketUI()

	set name = "Open Mentor Ticket Interface"
	set category = "Admin"

	if(!holder || !check_rights(R_MENTOR))
		return

	SSmentor_tickets.showUI(usr)

/client/proc/resolveAllMentorTickets()
	set name = "Resolve All Open Mentor Tickets"
	set category = "Admin"

	if(!holder || !check_rights(R_ADMIN))
		return

	if(alert("Are you sure you want to resolve ALL open tickets?","Resolve all open tickets?","Yes","No") != "Yes")
		return

	SSmentor_tickets.resolveAllOpenTickets()

/client/verb/openMentorUserUI()
	set name = "My Mentor Tickets"
	set category = "Admin"
	SSmentor_tickets.userDetailUI(usr)
