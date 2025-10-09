//Verbs

ADMIN_VERB(open_mentor_tickets, R_MENTOR|R_ADMIN, "Open Mentor Ticket Interface", "Opens the mhelp panel", VERB_CATEGORY_ADMIN)
	SSmentor_tickets.showUI(user)

ADMIN_VERB(resolve_all_mentor_tickets, R_ADMIN, "Resolve All Open Mentor Tickets", "Resolves all open mhelps", VERB_CATEGORY_HIDDEN)
	if(alert(user, "Are you sure you want to resolve ALL open mentor tickets?","Resolve all open mentor tickets?","Yes","No") != "Yes")
		return

	SSmentor_tickets.resolveAllOpenTickets()

/client/verb/openMentorUserUI()
	set name = "My Mentor Tickets"
	set category = VERB_CATEGORY_ADMIN
	SSmentor_tickets.userDetailUI(usr)
