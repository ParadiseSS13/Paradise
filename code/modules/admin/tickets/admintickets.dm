/*
Admin ticket system by Birdtalon
*/
//Global holder

var/global/datum/adminTicketHolder/globAdminTicketHolder = new /datum/adminTicketHolder

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

//Datum holding all tickets
/datum/adminTicketHolder
	var/ticketCounter = 1 // Counts the tickets and used to assign the id number
	var/list/allTickets = list()

//Return the current ticket number ready to be called off.
/datum/adminTicketHolder/proc/getTicketCounter()
	return ticketCounter

//Return the ticket counter and increment
/datum/adminTicketHolder/proc/getTicketCounterAndInc()
	. = ticketCounter
	ticketCounter++
	return

/datum/adminTicketHolder/proc/resolveAllOpenTickets() // Resolve all open tickets
	for(var/i in allTickets)
		var/datum/admin_ticket/T = i
		resolveTicket(T.ticketNum)

//Open a new ticket and populate details then add to the list of open tickets
/datum/adminTicketHolder/proc/newTicket(var/client/C, var/passedContent, var/title)
	if(!C || !passedContent)
		return

  //Check if the user has an open ticket already within the cooldown period, if so we don't create a new one and re-set the cooldown period
	var/datum/admin_ticket/existingTicket = checkForOpenTicket(C)
	if(existingTicket)
		existingTicket.setCooldownPeriod()
		to_chat(C, "<span class='adminticket'>Your ticket #[existingTicket.ticketNum] remains open! Visit \"My tickets\" under the Admin Tab to view it.</span>")
		return

	if(!title)
		title = passedContent

	var/datum/admin_ticket/T =  new /datum/admin_ticket
	T.clientName = C
	T.timeOpened = worldtime2text()
	T.title = title
	T.content += passedContent
	T.locationSent = C.mob.loc.loc.name
	T.mobControlled = C.mob
	T.ticketState = ADMIN_TICKET_OPEN
	T.timeUntilStale = world.time + ADMIN_TICKET_TIMEOUT
	T.setCooldownPeriod()
	T.ticketNum = getTicketCounterAndInc()
	allTickets += T

	//Inform the user that they have opened a ticket
	to_chat(C, "<span class='adminticket'>You have opened admin ticket number #[(globAdminTicketHolder.getTicketCounter() - 1)]! Please be patient and we will help you soon!</span>")

	//Begin the stale count for this ticket.
	spawn(0)
		T.beginStaleCount()

//Set ticket state with key N to open
/datum/adminTicketHolder/proc/openTicket(var/N)
	var/datum/admin_ticket/T = globAdminTicketHolder.allTickets[N]
	if(T.ticketState != ADMIN_TICKET_OPEN)
		T.ticketState = ADMIN_TICKET_OPEN
		return TRUE

//Set ticket state with key N to resolved
/datum/adminTicketHolder/proc/resolveTicket(var/N)
	var/datum/admin_ticket/T = globAdminTicketHolder.allTickets[N]
	if(T.ticketState != ADMIN_TICKET_RESOLVED)
		T.ticketState = ADMIN_TICKET_RESOLVED
		return TRUE

//Set ticket state with key N to closed
/datum/adminTicketHolder/proc/closeTicket(var/N)
	var/datum/admin_ticket/T = globAdminTicketHolder.allTickets[N]
	if(T.ticketState != ADMIN_TICKET_CLOSED)
		T.ticketState = ADMIN_TICKET_CLOSED
		return TRUE

//Check if the user already has a ticket open and within the cooldown period.
/datum/adminTicketHolder/proc/checkForOpenTicket(var/client/C)
	for(var/datum/admin_ticket/T in allTickets)
		if(T.clientName == C && T.ticketState == ADMIN_TICKET_OPEN && (T.ticketCooldown > world.time))
			return T
	return FALSE

//Check if the user has ANY ticket not resolved or closed.
/datum/adminTicketHolder/proc/checkForTicket(var/client/C)
	var/list/tickets = list()
	for(var/datum/admin_ticket/T in allTickets)
		if(T.clientName == C && T.ticketState == ADMIN_TICKET_OPEN || T.ticketState == ADMIN_TICKET_STALE)
			tickets += T
	if(tickets.len)
		return tickets
	return FALSE

//return the client of a ticket number
/datum/adminTicketHolder/proc/returnClient(var/N)
	var/datum/admin_ticket/T = globAdminTicketHolder.allTickets[N]
	return T.clientName

/datum/adminTicketHolder/proc/assignAdminToTicket(var/client/C, var/N)
	var/datum/admin_ticket/T = globAdminTicketHolder.allTickets[N]
	T.assignAdmin(C)
	return TRUE

//Single admin ticket

/datum/admin_ticket
	var/ticketNum // Ticket number
	var/clientName // Client which opened the ticket
	var/timeOpened // Time the ticket was opened
	var/title //The initial message with links
	var/list/content = list() // content of the admin help
	var/lastAdminResponse // Last admin who responded
	var/lastResponseTime // When the admin last responded
	var/locationSent // Location the player was when they send the ticket
	var/mobControlled // Mob they were controlling
	var/ticketState // State of the ticket, open, closed, resolved etc
	var/timeUntilStale // When the ticket goes stale
	var/ticketCooldown // Cooldown before allowing the user to open another ticket.
	var/adminAssigned // Admin who has assigned themselves to this ticket

//Ticker called when a ticket is created, checks for stale-ness.
/datum/admin_ticket/proc/beginStaleCount()
	while(world.time < timeUntilStale || !lastAdminResponse || !adminAssigned) // While within the stale period OR no admin responded OR no admin assigned.

		if(!src)
			return

		sleep(200) // Check every 20 seconds.
		if(ticketState == ADMIN_TICKET_OPEN && world.time > timeUntilStale)
			message_adminTicket("<span class='adminticket'>Ticket #[ticketNum] has been open for [ADMIN_TICKET_TIMEOUT * 0.1] seconds. Changing status to stale.</span>")
			ticketState = ADMIN_TICKET_STALE
			break

//Set the cooldown period for the ticket. The time when it's created plus the defined cooldown time.
/datum/admin_ticket/proc/setCooldownPeriod()
	ticketCooldown = world.time + ADMIN_TICKET_DUPLICATE_COOLDOWN

//Set the last admin who responded as the client passed as an arguement.
/datum/admin_ticket/proc/setLastAdminResponse(var/client/C)
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
/datum/admin_ticket/proc/assignAdmin(var/client/C, var/N)
	if(!C)
		return
	adminAssigned = C
	return TRUE

/datum/admin_ticket/proc/addResponse(var/client/C, var/M as text)
	if(C.holder)
		setLastAdminResponse(C)
	M = "[C]: [M]"
	content += M