//Defines
//Deciseconds until ticket becomes stale if unanswered. Alerts admins.
#define TICKET_TIMEOUT 6000 // 10 minutes
//Decisecions before the user is allowed to open another ticket while their existing one is open.
#define TICKET_DUPLICATE_COOLDOWN 3000 // 5 minutes

//Status defines
#define TICKET_OPEN       1
#define TICKET_CLOSED     2
#define TICKET_RESOLVED   3
#define TICKET_STALE      4

SUBSYSTEM_DEF(tickets)
	name = "Admin Tickets"
	var/span_class = "adminticket"
	var/ticket_system_name = "Admin Tickets"
	var/ticket_name = "Admin Ticket"
	var/close_rights = R_ADMIN
	var/list/close_messages
	init_order = INIT_ORDER_TICKETS
	wait = 300
	priority = FIRE_PRIORITY_TICKETS
	
	flags = SS_BACKGROUND
	
	var/list/allTickets = list()	//make it here because someone might ahelp before the system has initialized

	var/ticketCounter = 1

/datum/controller/subsystem/tickets/Initialize()
	close_messages = list("<font color='red' size='4'><b>- [ticket_name] Rejected! -</b></font>",
				"<span class='boldmessage'>Please try to be calm, clear, and descriptive in admin helps, do not assume the staff member has seen any related events, and clearly state the names of anybody you are reporting. If you asked a question, please ensure it was clear what you were asking.</span>", 
				"<span class='[span_class]'>Your [ticket_name] has now been closed.</span>")
	return ..()

/datum/controller/subsystem/tickets/fire()
	var/stales = checkStaleness()
	if(LAZYLEN(stales))
		var/report
		for(var/num in stales)
			report += "[num], "
		message_staff("<span class='[span_class]'>Tickets [report] have been open for over [TICKET_TIMEOUT / 600] minutes. Changing status to stale.</span>")

/datum/controller/subsystem/tickets/stat_entry()
	..("Tickets: [LAZYLEN(allTickets)]")

/datum/controller/subsystem/tickets/proc/checkStaleness()
	var/stales = list()
	for(var/T in allTickets)
		var/datum/ticket/ticket = T
		if(!(ticket.ticketState == TICKET_OPEN))
			continue
		if(world.time > ticket.timeUntilStale && (!ticket.lastStaffResponse || !ticket.staffAssigned))
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
		var/datum/ticket/T = i
		resolveTicket(T.ticketNum)

//Open a new ticket and populate details then add to the list of open tickets
/datum/controller/subsystem/tickets/proc/newTicket(client/C, passedContent, title)
	if(!C || !passedContent)
		return

  //Check if the user has an open ticket already within the cooldown period, if so we don't create a new one and re-set the cooldown period
	var/datum/ticket/existingTicket = checkForOpenTicket(C)
	if(existingTicket)
		existingTicket.setCooldownPeriod()
		to_chat(C.mob, "<span class='[span_class]'>Your [ticket_name] #[existingTicket.ticketNum] remains open! Visit \"My tickets\" under the Admin Tab to view it.</span>")
		return

	if(!title)
		title = passedContent

	var/datum/ticket/T =  new(title, passedContent, getTicketCounterAndInc())
	allTickets += T
	T.clientName = C
	T.locationSent = C.mob.loc.name
	T.mobControlled = C.mob

	//Inform the user that they have opened a ticket
	to_chat(C, "<span class='[span_class]'>You have opened [ticket_name] number #[(getTicketCounter() - 1)]! Please be patient and we will help you soon!</span>")
	var/ticket_open_sound = sound('sound/effects/adminticketopen.ogg')
	SEND_SOUND(C, ticket_open_sound)

//Set ticket state with key N to open
/datum/controller/subsystem/tickets/proc/openTicket(N)
	var/datum/ticket/T = allTickets[N]
	if(T.ticketState != TICKET_OPEN)
		message_staff("<span class='[span_class]'>[usr.client] / ([usr]) re-opened [ticket_name] number [N]</span>")
		T.ticketState = TICKET_OPEN
		return TRUE

//Set ticket state with key N to resolved
/datum/controller/subsystem/tickets/proc/resolveTicket(N)
	var/datum/ticket/T = allTickets[N]
	if(T.ticketState != TICKET_RESOLVED)
		T.ticketState = TICKET_RESOLVED
		message_staff("<span class='[span_class]'>[usr.client] / ([usr]) resolved [ticket_name] number [N]</span>")
		to_chat_safe(returnClient(N), "<span class='[span_class]'>Your [ticket_name] has now been resolved.</span>")
		return TRUE
		

/datum/controller/subsystem/tickets/proc/autoRespond(N)
	if(!check_rights(R_ADMIN|R_MOD))
		return

	var/datum/ticket/T = allTickets[N]
	var/client/C = usr.client
	if((T.staffAssigned && T.staffAssigned != C) || (T.lastStaffResponse && T.lastStaffResponse != C) || ((T.ticketState != TICKET_OPEN) && (T.ticketState != TICKET_STALE))) //if someone took this ticket, is it the same admin who is autoresponding? if so, then skip the warning
		if(alert(usr, "[T.ticketState == TICKET_OPEN ? "Another admin appears to already be handling this." : "This ticket is already marked as closed or resolved"] Are you sure you want to continue?", "Confirmation", "Yes", "No") != "Yes")
			return
	T.assignStaff(C)
	
	var/response_phrases = list("Thanks" = "Thanks, have a Paradise day!", 
		"Handling It" = "The issue is being looked into, thanks.",
		"Already Resolved" = "The problem has been resolved already.",
		"Mentorhelp" = "Please redirect your question to Mentorhelp, as they are better experienced with these types of questions.",
		"Happens Again" = "Thanks, let us know if it continues to happen.",
		"Clear Cache" = "To fix a blank screen, please leave the game and clear your Byond Cache. To clear your Byond Cache, there is a Settings icon in the top right of the launcher. After you click that, go into the Games tab and hit the Clear Cache button. If the issue persists a few minutes after rejoining and doing this, please adminhelp again and state you cleared your cache." ,
		"IC Issue" = "This is an In Character (IC) issue and will not be handled by admins. You could speak to Security, Internal Affairs, a Departmental Head, Nanotrasen Representetive, or any other relevant authority currently on station.",
		"Reject" = "Reject",
		"Man Up" = "Man Up",
		"Appeal on the Forums" = "Appealing a ban must occur on the forums. Privately messaging, or adminhelping about your ban will not resolve it. To appeal your ban, please head to <a href='[config.banappeals]'>[config.banappeals]</a>"
		)
		
	var/sorted_responses = list()
	for(var/key in response_phrases)	//build a new list based on the short descriptive keys of the master list so we can send this as the input instead of the full paragraphs to the admin choosing which autoresponse
		sorted_responses += key

	var/message_key = input("Select an autoresponse. This will mark the ticket as resolved.", "Autoresponse") as null|anything in sortTim(sorted_responses, /proc/cmp_text_asc) //use sortTim and cmp_text_asc to sort alphabetically

	switch(message_key)
		if(null) //they cancelled
			T.staffAssigned = initial(T.staffAssigned) //if they cancel we dont need to hold this ticket anymore
			return
		if("Reject")
			if(!closeTicket(N))
				to_chat(C, "Unable to close ticket")
		if("Man Up")
			C.man_up(returnClient(N))
			T.lastStaffResponse = "Autoresponse: [message_key]"
			resolveTicket(N)
			message_staff("[C] has auto responded to [T.clientName]\'s adminhelp with:<span class='adminticketalt'> [message_key] </span>")
			log_game("[C] has auto responded to [T.clientName]\'s adminhelp with: [response_phrases[message_key]]")
		else
			var/msg_sound = sound('sound/effects/adminhelp.ogg')
			SEND_SOUND(returnClient(N), msg_sound)
			to_chat(returnClient(N), "<span class='[span_class]'>[key_name_hidden(C)] is autoresponding with: <span/> <span class='adminticketalt'>[response_phrases[message_key]]</span>")//for this we want the full value of whatever key this is to tell the player so we do response_phrases[message_key]
			message_staff("[C] has auto responded to [T.clientName]\'s adminhelp with:<span class='adminticketalt'> [message_key] </span>") //we want to use the short named keys for this instead of the full sentence which is why we just do message_key
			T.lastStaffResponse = "Autoresponse: [message_key]"
			resolveTicket(N)
			log_game("[C] has auto responded to [T.clientName]\'s adminhelp with: [response_phrases[message_key]]")
//Set ticket state with key N to closed
/datum/controller/subsystem/tickets/proc/closeTicket(N)
	var/datum/ticket/T = allTickets[N]
	if(T.ticketState != TICKET_CLOSED)
		message_staff("<span class='[span_class]'>[usr.client] / ([usr]) closed [ticket_name] number [N]</span>")
		to_chat_safe(returnClient(N), close_messages)
		T.ticketState = TICKET_CLOSED
		return TRUE

//Check if the user already has a ticket open and within the cooldown period.
/datum/controller/subsystem/tickets/proc/checkForOpenTicket(client/C)
	for(var/datum/ticket/T in allTickets)
		if(T.clientName == C && T.ticketState == TICKET_OPEN && (T.ticketCooldown > world.time))
			return T
	return FALSE

//Check if the user has ANY ticket not resolved or closed.
/datum/controller/subsystem/tickets/proc/checkForTicket(client/C)
	var/list/tickets = list()
	for(var/datum/ticket/T in allTickets)
		if(T.clientName == C && (T.ticketState == TICKET_OPEN || T.ticketState == TICKET_STALE))
			tickets += T
	if(tickets.len)
		return tickets
	return FALSE

//return the client of a ticket number
/datum/controller/subsystem/tickets/proc/returnClient(N)
	var/datum/ticket/T = allTickets[N]
	return T.clientName

/datum/controller/subsystem/tickets/proc/assignStaffToTicket(client/C, N)
	var/datum/ticket/T = allTickets[N]
	if(T.staffAssigned != null && T.staffAssigned != C && alert("Ticket is already assigned to [T.staffAssigned.ckey]. Are you sure you want to take it?","Take ticket","No","Yes") != "Yes")
		return FALSE
	T.assignStaff(C)
	return TRUE

//Single staff ticket

/datum/ticket
	var/ticketNum // Ticket number
	var/clientName // Client which opened the ticket
	var/timeOpened // Time the ticket was opened
	var/title //The initial message with links
	var/list/content // content of the staff help
	var/lastStaffResponse // Last staff member who responded
	var/lastResponseTime // When the staff last responded
	var/locationSent // Location the player was when they send the ticket
	var/mobControlled // Mob they were controlling
	var/ticketState // State of the ticket, open, closed, resolved etc
	var/timeUntilStale // When the ticket goes stale
	var/ticketCooldown // Cooldown before allowing the user to open another ticket.
	var/client/staffAssigned // Staff member who has assigned themselves to this ticket

/datum/ticket/New(tit, cont, num)
	title = tit
	content = list()
	content += cont
	timeOpened = worldtime2text()
	timeUntilStale = world.time + TICKET_TIMEOUT
	setCooldownPeriod()
	ticketNum = num
	ticketState = TICKET_OPEN

//Set the cooldown period for the ticket. The time when it's created plus the defined cooldown time.
/datum/ticket/proc/setCooldownPeriod()
	ticketCooldown = world.time + TICKET_DUPLICATE_COOLDOWN

//Set the last staff who responded as the client passed as an arguement.
/datum/ticket/proc/setLastStaffResponse(client/C)
	lastStaffResponse = C
	lastResponseTime = worldtime2text()

//Return the ticket state as a colour coded text string.
/datum/ticket/proc/state2text()
	switch(ticketState)
		if(TICKET_OPEN)
			return "<font color='green'>OPEN</font>"
		if(TICKET_RESOLVED)
			return "<font color='blue'>RESOLVED</font>"
		if(TICKET_CLOSED)
			return "<font color='red'>CLOSED</font>"
		if(TICKET_STALE)
			return "<font color='orange'>STALE</font>"

//Assign the client passed to var/staffAsssigned
/datum/ticket/proc/assignStaff(client/C)
	if(!C)
		return
	staffAssigned = C
	return TRUE

/datum/ticket/proc/addResponse(client/C, msg)
	if(C.holder)
		setLastStaffResponse(C)
	msg = "[C]: [msg]"
	content += msg

/datum/ticket/proc/makeStale()
	ticketState = TICKET_STALE
	return ticketNum

/*

UI STUFF

*/

/datum/controller/subsystem/tickets/proc/returnUI(tab = TICKET_OPEN)
	set name = "Open Ticket Interface"
	set category = "Tickets"

//dat
	var/trStyle = "border-top:2px solid; border-bottom:2px solid; padding-top: 5px; padding-bottom: 5px;"
	var/tdStyleleft = "border-top:2px solid; border-bottom:2px solid; width:150px; text-align:center;"
	var/tdStyle = "border-top:2px solid; border-bottom:2px solid;"
	var/datum/ticket/ticket
	var/dat
	dat += "<head><style>.adminticket{border:2px solid}</style></head>"
	dat += "<body><h1>[ticket_system_name]</h1>"

	dat +="<a href='?src=[UID()];refresh=1'>Refresh</a><br /><a href='?src=[UID()];showopen=1'>Open Tickets</a><a href='?src=[UID()];showresolved=1'>Resolved Tickets</a><a href='?src=[UID()];showclosed=1'>Closed Tickets</a>"
	if(tab == TICKET_OPEN)
		dat += "<h2>Open Tickets</h2>"
	dat += "<table style='width:1300px; border: 3px solid;'>"
	dat +="<tr style='[trStyle]'><th style='[tdStyleleft]'>Control</th><th style='[tdStyle]'>Ticket</th></tr>"
	if(tab == TICKET_OPEN)
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == TICKET_OPEN || ticket.ticketState == TICKET_STALE)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.timeOpened]) [ticket.ticketState == TICKET_STALE ? "<font color='red'><b>STALE</font>" : ""] </td><td style='[tdStyle]'><b>[ticket.title]</td></tr>"
			else
				continue
	else  if(tab == TICKET_RESOLVED)
		dat += "<h2>Resolved Tickets</h2>"
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == TICKET_RESOLVED)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.timeOpened]) </td><td style='[tdStyle]'><b>[ticket.title]</td></tr>"
			else
				continue
	else if(tab == TICKET_CLOSED)
		dat += "<h2>Closed Tickets</h2>"
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == TICKET_CLOSED)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.timeOpened]) </td><td style='[tdStyle]'><b>[ticket.title]</td></tr>"
			else
				continue

	dat += "</table>"
	dat += "<h1>Resolve All</h1>"
	if(ticket_system_name == "Mentor Tickets")
		dat += "<a href='?src=[UID()];resolveall=1'>Resolve All Open Mentor Tickets</a></body>"
	else
		dat += "<a href='?src=[UID()];resolveall=1'>Resolve All Open Admin Tickets</a></body>"

	return dat

/datum/controller/subsystem/tickets/proc/showUI(mob/user, tab)
	var/dat = null
	dat = returnUI(tab)
	var/datum/browser/popup = new(user, ticket_system_name, ticket_system_name, 1400, 600)
	popup.set_content(dat)
	popup.open()

/datum/controller/subsystem/tickets/proc/showDetailUI(mob/user, ticketID)
	var/datum/ticket/T = allTickets[ticketID]
	var/status = "[T.state2text()]"

	var/dat = "<h1>[ticket_system_name]</h1>"

	dat +="<a href='?src=[UID()];refresh=1'>Show All</a><a href='?src=[UID()];refreshdetail=[T.ticketNum]'>Refresh</a>"

	dat += "<h2>Ticket #[T.ticketNum]</h2>"

	dat += "<h3>[T.clientName] / [T.mobControlled] opened this [ticket_name] at [T.timeOpened] at location [T.locationSent]</h3>"
	dat += "<h4>Ticket Status: <font color='red'>[status]</font>"
	dat += "<table style='width:950px; border: 3px solid;'>"
	dat += "<tr><td>[T.title]</td></tr>"

	if(T.content.len > 1)
		for(var/i = 2, i <= T.content.len, i++)
			dat += "<tr><td>[T.content[i]]</td></tr>"

	dat += "</table><br /><br />"
	dat += "<a href='?src=[UID()];detailreopen=[T.ticketNum]'>Re-Open</a>[check_rights(R_ADMIN|R_MOD, 0) ? "<a href='?src=[UID()];autorespond=[T.ticketNum]'>Auto</a>": ""]<a href='?src=[UID()];detailresolve=[T.ticketNum]'>Resolve</a><br /><br />" 

	if(!T.staffAssigned)
		dat += "No staff member assigned to this [ticket_name] - <a href='?src=[UID()];assignstaff=[T.ticketNum]'>Take Ticket</a><br />"
	else
		dat += "[T.staffAssigned] is assigned to this Ticket. - <a href='?src=[UID()];assignstaff=[T.ticketNum]'>Take Ticket</a> - <a href='?src=[UID()];unassignstaff=[T.ticketNum]'>Unassign Ticket</a><br />"

	if(T.lastStaffResponse)
		dat += "<b>Last Staff response Response:</b> [T.lastStaffResponse] at [T.lastResponseTime]"
	else
		dat +="<font color='red'>No Staff Response</font>"

	dat += "<br /><br />"

	dat += "<a href='?src=[UID()];detailclose=[T.ticketNum]'>Close Ticket</a>"

	var/datum/browser/popup = new(user, "[ticket_system_name]detail", "[ticket_system_name] #[T.ticketNum]", 1000, 600)
	popup.set_content(dat)
	popup.open()

/datum/controller/subsystem/tickets/proc/userDetailUI(mob/user)
//dat
	var/tickets = checkForTicket(user.client)
	var/dat
	dat += "<h1>Your open [ticket_system_name]</h1>"
	dat += "<table>"
	for(var/datum/ticket/T in tickets)
		dat += "<tr><td><h2>Ticket #[T.ticketNum]</h2></td></tr>"
		for(var/i = 1, i <= T.content.len, i++)
			dat += "<tr><td>[T.content[i]]</td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "[ticket_system_name]userticketsdetail", ticket_system_name, 1000, 600)
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

//Sends a message to the designated staff
/datum/controller/subsystem/tickets/proc/message_staff(var/msg, var/alt = FALSE)
	message_adminTicket(msg, alt)

/datum/controller/subsystem/tickets/Topic(href, href_list)

	if(href_list["refresh"])
		showUI(usr)
		return

	if(href_list["refreshdetail"])
		var/indexNum = text2num(href_list["refreshdetail"])
		showDetailUI(usr, indexNum)
		return

	if(href_list["showopen"])
		showUI(usr, TICKET_OPEN)
		return
	if(href_list["showresolved"])
		showUI(usr, TICKET_RESOLVED)
		return
	if(href_list["showclosed"])
		showUI(usr, TICKET_CLOSED)
		return

	if(href_list["details"])
		var/indexNum = text2num(href_list["details"])
		showDetailUI(usr, indexNum)
		return

	if(href_list["resolve"])
		var/indexNum = text2num(href_list["resolve"])
		if(resolveTicket(indexNum))
			showUI(usr)

	if(href_list["detailresolve"])
		var/indexNum = text2num(href_list["detailresolve"])
		if(resolveTicket(indexNum))
			showDetailUI(usr, indexNum)

	if(href_list["detailclose"])
		var/indexNum = text2num(href_list["detailclose"])
		if(!check_rights(close_rights))
			to_chat(usr, "<span class='warning'>Not enough rights to close this ticket.</span>")
			return
		if(alert("Are you sure? This will send a negative message.",,"Yes","No") != "Yes")
			return
		if(closeTicket(indexNum))
			showDetailUI(usr, indexNum)
			

	if(href_list["detailreopen"])
		var/indexNum = text2num(href_list["detailreopen"])
		if(openTicket(indexNum))
			showDetailUI(usr, indexNum)

	if(href_list["assignstaff"])
		var/indexNum = text2num(href_list["assignstaff"])
		takeTicket(indexNum)
		showDetailUI(usr, indexNum)

	if(href_list["unassignstaff"])
		var/indexNum = text2num(href_list["unassignstaff"])
		unassignTicket(indexNum)
		showDetailUI(usr, indexNum)

	if(href_list["autorespond"])
		var/indexNum = text2num(href_list["autorespond"])
		autoRespond(indexNum)

	if(href_list["resolveall"])
		if(ticket_system_name == "Mentor Tickets")
			usr.client.resolveAllMentorTickets()
		else
			usr.client.resolveAllAdminTickets()

/datum/controller/subsystem/tickets/proc/takeTicket(var/index)
	if(assignStaffToTicket(usr.client, index))
		if(span_class == "mentorhelp")
			message_staff("<span class='[span_class]'>[usr.client] / ([usr]) has taken [ticket_name] number [index]</span>")
		else
			message_staff("<span class='admin_channel'>[usr.client] / ([usr]) has taken [ticket_name] number [index]</span>", TRUE)
		to_chat_safe(returnClient(index), "<span class='[span_class]'>Your [ticket_name] is being handled by [usr.client].</span>")

/datum/controller/subsystem/tickets/proc/unassignTicket(index)
	var/datum/ticket/T = allTickets[index]
	if(T.staffAssigned != null && (T.staffAssigned == usr.client || alert("Ticket is already assigned to [T.staffAssigned]. Do you want to unassign it?","Unassign ticket","No","Yes") == "Yes"))
		T.staffAssigned = null
		to_chat_safe(returnClient(index), "<span class='[span_class]'>Your [ticket_name] has been unassigned. Another staff member will help you soon.</span>")
		if(span_class == "mentorhelp")
			message_staff("<span class='[span_class]'>[usr.client] / ([usr]) has unassigned [ticket_name] number [index]</span>")
		else
			message_staff("<span class='admin_channel'>[usr.client] / ([usr]) has unassigned [ticket_name] number [index]</span>", TRUE)
