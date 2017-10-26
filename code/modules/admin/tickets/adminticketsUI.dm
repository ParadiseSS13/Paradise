/datum/adminTicketHolder/proc/returnUI(var/tab = ADMIN_TICKET_OPEN)
	set name = "Open Ticket Interface"
	set category = "Tickets"

//dat
	var/trStyle = "border-top:2px solid; border-bottom:2px solid; padding-top: 5px; padding-bottom: 5px;"
	var/tdStyleleft = "border-top:2px solid; border-bottom:2px solid; width:150px; text-align:center;"
	var/tdStyle = "border-top:2px solid; border-bottom:2px solid;"
	var/datum/admin_ticket/ticket
	var/dat
	dat += "<head><style>.adminticket{border:2px solid}</style></head>"
	dat += "<body><h1>Admin Tickets</h1>"

	dat +="<a href='?src=[UID()];refresh=1'>Refresh</a><br /><a href='?src=[UID()];showopen=1'>Open Tickets</a><a href='?src=[UID()];showresolved=1'>Resolved Tickets</a><a href='?src=[UID()];showclosed=1'>Closed Tickets</a>"
	if(tab == ADMIN_TICKET_OPEN)
		dat += "<h2>Open Tickets</h2>"
	dat += "<table style='width:1300px; border: 3px solid;'>"
	dat +="<tr style='[trStyle]'><th style='[tdStyleleft]'>Control</th><th style='[tdStyle]'>Ticket</th></tr>"
	if(tab == ADMIN_TICKET_OPEN)
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == ADMIN_TICKET_OPEN || ticket.ticketState == ADMIN_TICKET_STALE)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.timeOpened]) [ticket.ticketState == ADMIN_TICKET_STALE ? "<font color='red'><b>STALE</font>" : ""] </td><td style='[tdStyle]'><b>[ticket.title]</td></tr>"
			else
				continue
	else  if(tab == ADMIN_TICKET_RESOLVED)
		dat += "<h2>Resolved Tickets</h2>"
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == ADMIN_TICKET_RESOLVED)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.timeOpened]) </td><td style='[tdStyle]'><b>[ticket.title]</td></tr>"
			else
				continue
	else if(tab == ADMIN_TICKET_CLOSED)
		dat += "<h2>Closed Tickets</h2>"
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == ADMIN_TICKET_CLOSED)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.timeOpened]) </td><td style='[tdStyle]'><b>[ticket.title]</td></tr>"
			else
				continue

	dat += "</table></body>"

	return dat

/datum/adminTicketHolder/proc/showUI(var/client/user, var/tab)
	var/dat = null
	dat = returnUI(tab)
	var/datum/browser/popup = new(user, "admintickets", "Admin Tickets", 1400, 600)
	popup.set_content(dat)
	popup.open()

/datum/adminTicketHolder/proc/showDetailUI(var/client/user, var/ticketID)
	var/datum/admin_ticket/T = globAdminTicketHolder.allTickets[ticketID]
	var/status = "[T.state2text()]"

	var/dat = "<h1>Admin Tickets</h1>"

	dat +="<a href='?src=[UID()];refresh=1'>Show All</a><a href='?src=[UID()];refreshdetail=[T.ticketNum]'>Refresh</a>"

	dat += "<h2>Ticket #[T.ticketNum]</h2>"

	dat += "<h3>[T.clientName] / [T.mobControlled] opened this ticket at [T.timeOpened] at location [T.locationSent]</h3>"
	dat += "<h4>Ticket Status: <font color='red'>[status]</font>"
	dat += "<table style='width:950px; border: 3px solid;'>"
	dat += "<tr><td>[T.title]</td></tr>"

	if(T.content.len > 1)
		for(var/i = 2, i <= T.content.len, i++)
			dat += "<tr><td>[T.content[i]]</td></tr>"

	dat += "</table><br /><br />"
	dat += "<a href='?src=[UID()];detailreopen=[T.ticketNum]'>Re-Open</a><a href='?src=[UID()];detailresolve=[T.ticketNum]'>Resolve</a><br /><br />"

	if(!T.adminAssigned)
		dat += "No admin assigned to this ticket - <a href='?src=[UID()];assignadmin=[T.ticketNum]'>Take Ticket</a><br />"
	else
		dat += "[T.adminAssigned] is assigned to this Ticket. - <a href='?src=[UID()];assignadmin=[T.ticketNum]'>Take Ticket</a><br />"

	if(T.lastAdminResponse)
		dat += "<b>Last Admin Response:</b> [T.lastAdminResponse] at [T.lastResponseTime]"
	else
		dat +="<font color='red'>No Admin Response</font>"

	dat += "<br /><br />"

	dat += "<a href='?src=[UID()];detailclose=[T.ticketNum]'>Close Ticket</a>"

	var/datum/browser/popup = new(user, "adminticketsdetail", "Admin Ticket #[T.ticketNum]", 1000, 600)
	popup.set_content(dat)
	popup.open()

/datum/adminTicketHolder/proc/userDetailUI(var/client/user)
//dat
	var/tickets = checkForTicket(user)
	var/dat
	dat += "<h1>Your open tickets</h1>"
	dat += "<table>"
	for(var/datum/admin_ticket/T in tickets)
		dat += "<tr><td><h2>Ticket #[T.ticketNum]</h2></td></tr>"
		for(var/i = 1, i <= T.content.len, i++)
			dat += "<tr><td>[T.content[i]]</td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "userticketsdetail", "Tickets", 1000, 600)
	popup.set_content(dat)
	popup.open()

/datum/adminTicketHolder/Topic(href, href_list)

	if(href_list["refresh"])
		showUI(usr)
		return

	if(href_list["refreshdetail"])
		var/indexNum = text2num(href_list["refreshdetail"])
		showDetailUI(usr, indexNum)
		return

	if(href_list["showopen"])
		showUI(usr, ADMIN_TICKET_OPEN)
		return
	if(href_list["showresolved"])
		showUI(usr, ADMIN_TICKET_RESOLVED)
		return
	if(href_list["showclosed"])
		showUI(usr, ADMIN_TICKET_CLOSED)
		return

	if(href_list["details"])
		var/indexNum = text2num(href_list["details"])
		showDetailUI(usr.client, indexNum)
		return

	if(href_list["resolve"])
		var/indexNum = text2num(href_list["resolve"])
		if(globAdminTicketHolder.resolveTicket(indexNum))
			message_adminTicket("[usr.client] / ([usr]) resolved admin ticket number [indexNum]")
			to_chat(returnClient(indexNum), "<span class='adminticket'>Your admin ticket has now been resolved.</span>")
			showUI(usr)

	if(href_list["detailresolve"])
		var/indexNum = text2num(href_list["detailresolve"])
		if(globAdminTicketHolder.resolveTicket(indexNum))
			message_adminTicket("[usr.client] / ([usr]) resolved admin ticket number [indexNum]")
			to_chat(returnClient(indexNum), "<span class='adminticket'>Your admin ticket has now been resolved.</span>")
			showDetailUI(usr, indexNum)

	if(href_list["detailclose"])
		var/indexNum = text2num(href_list["detailclose"])
		if(alert("Are you sure? This will send a negative message.",,"Yes","No") != "Yes")
			return
		if(globAdminTicketHolder.closeTicket(indexNum))
			message_adminTicket("[usr.client] / ([usr]) closed admin ticket number [indexNum]")
			to_chat(returnClient(indexNum), "<font color='red' size='4'><b>- AdminHelp Rejected! -</b></font>")
			to_chat(returnClient(indexNum), "<span class='boldmessage'>Please try to be calm, clear, and descriptive in admin helps, do not assume the admin has seen any related events, and clearly state the names of anybody you are reporting. If you asked a question, please ensure it was clear what you were asking.</span>")
			to_chat(returnClient(indexNum), "<span class='adminticket'>Your ticket has now been closed.</span>")
			showDetailUI(usr, indexNum)

	if(href_list["detailreopen"])
		var/indexNum = text2num(href_list["detailreopen"])
		if(globAdminTicketHolder.openTicket(indexNum))
			message_adminTicket("[usr.client] / ([usr]) re-opened admin ticket number [indexNum]")
			showDetailUI(usr, indexNum)

	if(href_list["assignadmin"])
		var/indexNum = text2num(href_list["assignadmin"])
		if(globAdminTicketHolder.assignAdminToTicket(usr.client, indexNum))
			message_adminTicket("[usr.client] / ([usr]) has taken ticket number [indexNum]")
			to_chat(returnClient(indexNum), "<span class='adminticket'>Your ticket is being handled by [usr.client].")
		showDetailUI(usr, indexNum)