//Verbs

/client/proc/openAdminTicketUI()

	set name = "Open Admin Ticket Interface"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	SStickets.showUI(usr)

/client/proc/resolveAllAdminTickets()
	set name = "Resolve All Open Admin Tickets"
	set category = null

	if(!check_rights(R_ADMIN))
		return

	if(alert("Вы уверены что хотите решить ВСЕ Админ Тикеты?","Решить все Админ Тикеты?","Да","Нет") != "Да")
		return

	SStickets.resolveAllOpenTickets()

/client/verb/openAdminUserUI()
	set name = "My Admin Tickets"
	set category = "Admin"
	SStickets.userDetailUI(usr)
