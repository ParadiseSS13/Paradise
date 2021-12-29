//Verbs

/client/proc/openMentorTicketUI()

	set name = "Open Mentor Ticket Interface"
	set category = "Admin"

	if(!check_rights(R_MENTOR|R_ADMIN))
		return

	SSmentor_tickets.showUI(usr)

/client/proc/resolveAllMentorTickets()
	set name = "Resolve All Open Mentor Tickets"
	set category = null

	if(!check_rights(R_ADMIN))
		return

	if(alert("Вы уверены что хотите решить ВСЕ Ментор Тикеты?","Решить все Ментор Тикеты?","Да","Нет") != "Да")
		return

	SSmentor_tickets.resolveAllOpenTickets()

/client/verb/openMentorUserUI()
	set name = "My Mentor Tickets"
	set category = "Admin"
	SSmentor_tickets.userDetailUI(usr)
