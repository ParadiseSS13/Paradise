//Defines
//Deciseconds until ticket becomes stale if unanswered. Alerts admins.
#define ADMIN_TICKET_TIMEOUT 6000 // 10 minutes
//Decisecions before the user is allowed to open another ticket while their existing one is open.
#define ADMIN_TICKET_DUPLICATE_COOLDOWN 3000 // 5 minutes

//Status defines
#define ADMIN_TICKET_OPEN       1
#define ADMIN_TICKET_CLOSED     2
#define ADMIN_TICKET_RESOLVED   3
#define ADMIN_TICKET_STALE      4

SUBSYSTEM_DEF(tickets)
	name = "Tickets"
	init_order = INIT_ORDER_TICKETS
	wait = 300
	priority = FIRE_PRIORITY_TICKETS

	flags = SS_BACKGROUND

	var/list/allTickets

	var/ticketCounter = 1

/datum/controller/subsystem/tickets/Initialize()
	LAZYINITLIST(allTickets)
	return ..()

/datum/controller/subsystem/tickets/fire()
	var/stales = checkStaleness()
	if(LAZYLEN(stales))
		var/report
		for(var/num in stales)
			report += "[num], "
		message_adminTicket("<span class='adminticket'>Tickets [report] have been open for over [ADMIN_TICKET_TIMEOUT / 600] minutes. Changing status to stale.</span>")

/datum/controller/subsystem/tickets/stat_entry()
	..("Tickets: [LAZYLEN(allTickets)]")

/datum/controller/subsystem/tickets/proc/checkStaleness()
	var/stales = list()
	for(var/T in allTickets)
		var/datum/admin_ticket/ticket = T
		if(!(ticket.ticketState == ADMIN_TICKET_OPEN))
			continue
		if(world.time > ticket.timeUntilStale && (!ticket.lastAdminResponse || !ticket.adminAssigned))
			var/id = ticket.makeStale()
			stales += id
	return stales

//Return the current ticket number ready to be called off.
/datum/controller/subsystem/tickets/proc/getTicketCounter()
	return ticketCounter

//Return the ticket counter and increment
/datum/controller/subsystem/tickets/proc/getTicketCounterAndInc()
	. = ticketCounter
	ticketCounter++
	return

/datum/controller/subsystem/tickets/proc/resolveAllOpenTickets() // Resolve all open tickets
	for(var/i in allTickets)
		var/datum/admin_ticket/T = i
		resolveTicket(T.ticketNum)

//Open a new ticket and populate details then add to the list of open tickets
/datum/controller/subsystem/tickets/proc/newTicket(client/C, passedContent, title)
	if(!C || !passedContent)
		return

  //Check if the user has an open ticket already within the cooldown period, if so we don't create a new one and re-set the cooldown period
	var/datum/admin_ticket/existingTicket = checkForOpenTicket(C)
	if(existingTicket)
		existingTicket.setCooldownPeriod()
		to_chat(C.mob, "<span class='adminticket'>Your ticket #[existingTicket.ticketNum] remains open! Visit \"My tickets\" under the Admin Tab to view it.</span>")
		return

	if(!title)
		title = passedContent

	var/datum/admin_ticket/T =  new(title, passedContent)
	T.clientName = C
	T.locationSent = C.mob.loc.name
	T.mobControlled = C.mob

	//Inform the user that they have opened a ticket
	to_chat(C, "<span class='adminticket'>You have opened admin ticket number #[(SStickets.getTicketCounter() - 1)]! Please be patient and we will help you soon!</span>")

//Set ticket state with key N to open
/datum/controller/subsystem/tickets/proc/openTicket(N)
	var/datum/admin_ticket/T = SStickets.allTickets[N]
	if(T.ticketState != ADMIN_TICKET_OPEN)
		T.ticketState = ADMIN_TICKET_OPEN
		return TRUE

//Set ticket state with key N to resolved
/datum/controller/subsystem/tickets/proc/resolveTicket(N)
	var/datum/admin_ticket/T = SStickets.allTickets[N]
	if(T.ticketState != ADMIN_TICKET_RESOLVED)
		T.ticketState = ADMIN_TICKET_RESOLVED
		return TRUE

//Set ticket state with key N to closed
/datum/controller/subsystem/tickets/proc/closeTicket(N)
	var/datum/admin_ticket/T = SStickets.allTickets[N]
	if(T.ticketState != ADMIN_TICKET_CLOSED)
		T.ticketState = ADMIN_TICKET_CLOSED
		return TRUE

//Check if the user already has a ticket open and within the cooldown period.
/datum/controller/subsystem/tickets/proc/checkForOpenTicket(client/C)
	for(var/datum/admin_ticket/T in allTickets)
		if(T.clientName == C && T.ticketState == ADMIN_TICKET_OPEN && (T.ticketCooldown > world.time))
			return T
	return FALSE

//Check if the user has ANY ticket not resolved or closed.
/datum/controller/subsystem/tickets/proc/checkForTicket(client/C)
	var/list/tickets = list()
	for(var/datum/admin_ticket/T in allTickets)
		if(T.clientName == C && (T.ticketState == ADMIN_TICKET_OPEN || T.ticketState == ADMIN_TICKET_STALE))
			tickets += T
	if(tickets.len)
		return tickets
	return FALSE

//return the client of a ticket number
/datum/controller/subsystem/tickets/proc/returnClient(N)
	var/datum/admin_ticket/T = SStickets.allTickets[N]
	return T.clientName

/datum/controller/subsystem/tickets/proc/assignAdminToTicket(client/C, var/N)
	var/datum/admin_ticket/T = SStickets.allTickets[N]
	T.assignAdmin(C)
	return TRUE

//Single admin ticket

/datum/admin_ticket
	var/ticketNum // Ticket number
	var/clientName // Client which opened the ticket
	var/timeOpened // Time the ticket was opened
	var/title //The initial message with links
	var/list/content // content of the admin help
	var/lastAdminResponse // Last admin who responded
	var/lastResponseTime // When the admin last responded
	var/locationSent // Location the player was when they send the ticket
	var/mobControlled // Mob they were controlling
	var/ticketState // State of the ticket, open, closed, resolved etc
	var/timeUntilStale // When the ticket goes stale
	var/ticketCooldown // Cooldown before allowing the user to open another ticket.
	var/adminAssigned // Admin who has assigned themselves to this ticket

/datum/admin_ticket/New(tit, cont)
	title = tit
	content = list()
	content += cont
	timeOpened = worldtime2text()
	timeUntilStale = world.time + ADMIN_TICKET_TIMEOUT
	setCooldownPeriod()
	ticketNum = SStickets.getTicketCounterAndInc()
	ticketState = ADMIN_TICKET_OPEN
	SStickets.allTickets += src

//Set the cooldown period for the ticket. The time when it's created plus the defined cooldown time.
/datum/admin_ticket/proc/setCooldownPeriod()
	ticketCooldown = world.time + ADMIN_TICKET_DUPLICATE_COOLDOWN

//Set the last admin who responded as the client passed as an arguement.
/datum/admin_ticket/proc/setLastAdminResponse(client/C)
	lastAdminResponse = C
	lastResponseTime = worldtime2text()

//Return the ticket state as a colour coded text string.
/datum/admin_ticket/proc/state2text()
	switch(ticketState)
		if(ADMIN_TICKET_OPEN)
			return "<font color='green'>OPEN</font>"
		if(ADMIN_TICKET_RESOLVED)
			return "<font color='blue'>RESOLVED</font>"
		if(ADMIN_TICKET_CLOSED)
			return "<font color='red'>CLOSED</font>"
		if(ADMIN_TICKET_STALE)
			return "<font color='orange'>STALE</font>"

//Assign the client passed to var/adminAsssigned
/datum/admin_ticket/proc/assignAdmin(client/C)
	if(!C)
		return
	adminAssigned = C
	return TRUE

/datum/admin_ticket/proc/addResponse(client/C, msg)
	if(C.holder)
		setLastAdminResponse(C)
	msg = "[C]: [msg]"
	content += msg

/datum/admin_ticket/proc/makeStale()
	ticketState = ADMIN_TICKET_STALE
	return ticketNum

/*

UI STUFF

*/

/datum/controller/subsystem/tickets/proc/returnUI(tab = ADMIN_TICKET_OPEN)
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

/datum/controller/subsystem/tickets/proc/showUI(mob/user, tab)
	var/dat = null
	dat = returnUI(tab)
	var/datum/browser/popup = new(user, "admintickets", "Admin Tickets", 1400, 600)
	popup.set_content(dat)
	popup.open()

/datum/controller/subsystem/tickets/proc/showDetailUI(mob/user, ticketID)
	var/datum/admin_ticket/T = SStickets.allTickets[ticketID]
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

/datum/controller/subsystem/tickets/proc/userDetailUI(mob/user)
//dat
	var/tickets = checkForTicket(user.client)
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

//Sends a message to the target safely. If the target left the server it won't throw a runtime. Also accepts lists of text
/datum/controller/subsystem/tickets/proc/to_chat_safe(target, text)
	if(!target)
		return FALSE
	if(istype(text, /list))
		for(var/T in text)
			to_chat(target, T)
	else
		to_chat(target, text)
	return TRUE

/datum/controller/subsystem/tickets/Topic(href, href_list)

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
		showDetailUI(usr, indexNum)
		return

	if(href_list["resolve"])
		var/indexNum = text2num(href_list["resolve"])
		if(SStickets.resolveTicket(indexNum))
			message_adminTicket("[usr.client] / ([usr]) resolved admin ticket number [indexNum]")
			to_chat_safe(returnClient(indexNum), "<span class='adminticket'>Your admin ticket has now been resolved.</span>")
			showUI(usr)

	if(href_list["detailresolve"])
		var/indexNum = text2num(href_list["detailresolve"])
		if(SStickets.resolveTicket(indexNum))
			message_adminTicket("[usr.client] / ([usr]) resolved admin ticket number [indexNum]")
			to_chat_safe(returnClient(indexNum), "<span class='adminticket'>Your admin ticket has now been resolved.</span>")
			showDetailUI(usr, indexNum)

	if(href_list["detailclose"])
		var/indexNum = text2num(href_list["detailclose"])
		if(alert("Are you sure? This will send a negative message.",,"Yes","No") != "Yes")
			return
		if(SStickets.closeTicket(indexNum))
			message_adminTicket("[usr.client] / ([usr]) closed admin ticket number [indexNum]")
			to_chat_safe(returnClient(indexNum), list(
				"<font color='red' size='4'><b>- AdminHelp Rejected! -</b></font>",
				"<span class='boldmessage'>Please try to be calm, clear, and descriptive in admin helps, do not assume the admin has seen any related events, and clearly state the names of anybody you are reporting. If you asked a question, please ensure it was clear what you were asking.</span>",
				"<span class='adminticket'>Your ticket has now been closed.</span>"
				))
			showDetailUI(usr, indexNum)

	if(href_list["detailreopen"])
		var/indexNum = text2num(href_list["detailreopen"])
		if(SStickets.openTicket(indexNum))
			message_adminTicket("[usr.client] / ([usr]) re-opened admin ticket number [indexNum]")
			showDetailUI(usr, indexNum)

	if(href_list["assignadmin"])
		var/indexNum = text2num(href_list["assignadmin"])
		if(SStickets.assignAdminToTicket(usr.client, indexNum))
			message_adminTicket("[usr.client] / ([usr]) has taken ticket number [indexNum]")
			to_chat_safe(returnClient(indexNum), "<span class='adminticket'>Your ticket is being handled by [usr.client].")
		showDetailUI(usr, indexNum)
