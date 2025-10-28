//Verbs
USER_VERB(open_admin_tickets, R_ADMIN, "Open Admin Ticket Interface", "Open the ahelp panel.", VERB_CATEGORY_ADMIN)
	SStickets.showUI(client)

USER_VERB(resolve_all_admin_tickets, R_ADMIN, "Resolve All Open Admin Tickets", "Resolve All Open Admin Tickets", VERB_CATEGORY_HIDDEN)
	if(alert(client, "Are you sure you want to resolve ALL open admin tickets?","Resolve all open admin tickets?","Yes","No") != "Yes")
		return

	SStickets.resolveAllOpenTickets()

/client/verb/openAdminUserUI()
	set name = "My Admin Tickets"
	set category = VERB_CATEGORY_ADMIN
	SStickets.userDetailUI(usr)
