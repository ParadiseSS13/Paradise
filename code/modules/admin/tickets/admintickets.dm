/*
Admin ticket system by Birdtalon
*/
//Global holder

var/global/datum/adminTicketHolder/globAdminTicketHolder = new /datum/adminTicketHolder

//Defines
//Deciseconds until timeout
#define ADMIN_TICKET_TIMEOUT 3000
//Decisecions before opening another ticket
#define ADMIN_TICKET_DUPLICATE_COOLDOWN 300

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
  var/C = ticketCounter
  ticketCounter++
  return C

//Set the ticket counter to a value
/datum/adminTicketHolder/proc/setTicketCounter(var/N as num)
  ticketCounter = N

/datum/adminTicketHolder/proc/purgeAllTickets() // Delete ALL tickets
  QDEL_LIST(allTickets)
  message_admins("<span class='adminticket'>[usr.client] purged all admin tickets!</span>")
  ticketCounter = 1

/datum/adminTicketHolder/proc/closeAllOpenTickets() // Close all open tickets
  for(var/i in allTickets)
    var/datum/admin_ticket/T = i
    T.ticketState = ADMIN_TICKET_CLOSED

//Open a new ticket and populate details then add to the list of open tickets
/datum/adminTicketHolder/proc/newTicket(var/client/C, var/passedContent)
  if(!C || !passedContent)
    return

  //Check if the user has an open ticket already within the cooldown period, if so we don't create a new one and re-set the cooldown period
  var/datum/admin_ticket/existingTicket = checkForOpenTicket(C)
  if(existingTicket)
    existingTicket.setCooldownPeriod()
    to_chat(C, "<span class='adminticket'>Your ticket #[existingTicket.ticketNum] remains open!</span>")
    return

  var/datum/admin_ticket/T =  new /datum/admin_ticket
  T.ticketNum = getTicketCounterAndInc()
  T.clientName = C
  T.timeOpened = worldtime2text()
  T.content = passedContent
  T.locationSent = C.mob.loc
  T.mobControlled = C.mob
  T.ticketState = ADMIN_TICKET_OPEN
  T.timeUntilStale = world.time + ADMIN_TICKET_TIMEOUT
  T.setCooldownPeriod()
  allTickets += T

  //Inform the user that they have opened a ticket
  to_chat(C, "<span class='adminticket'>You have opened admin ticket number #[(globAdminTicketHolder.getTicketCounter() - 1)]! Please be patient and we will help you soon!</span>")

  spawn()
  T.beginStaleCount()

//Set ticket state with key N to open
/datum/adminTicketHolder/proc/openTicket(var/N as num)
  var/datum/admin_ticket/T = globAdminTicketHolder.allTickets[N]
  T.ticketState = ADMIN_TICKET_OPEN

//Set ticket state with key N to resolved
/datum/adminTicketHolder/proc/resolveTicket(var/N as num)
  var/datum/admin_ticket/T = globAdminTicketHolder.allTickets[N]
  T.ticketState = ADMIN_TICKET_RESOLVED

//Set ticket state with key N to closed
/datum/adminTicketHolder/proc/closeTicket(var/N as num)
  var/datum/admin_ticket/T = globAdminTicketHolder.allTickets[N]
  T.ticketState = ADMIN_TICKET_CLOSED

//List Open Tickets in chat
/datum/adminTicketHolder/proc/listOpenTicketsToChat()
  for(var/T in allTickets)
    var/datum/admin_ticket/ticket = T
    message_admins("<span class='adminticket'>Ticket #[ticket.ticketNum]: Opened by [ticket.clientName] at [ticket.timeOpened]: [ticket.content]</span>")

//Check if the user already has a ticket open and within the cooldown period.
/datum/adminTicketHolder/proc/checkForOpenTicket(var/client/C)
  for(var/datum/admin_ticket/T in allTickets)
    if(T.clientName == C && T.ticketState == ADMIN_TICKET_OPEN && (T.ticketCooldown > world.time))
      return T
  return FALSE

//Single admin ticket

/datum/admin_ticket
  var/ticketNum // Ticket number
  var/clientName // Client which opened the ticket
  var/timeOpened // Time the ticket was opened
  var/content // content of the admin help
  var/lastAdminResponse // Last admin who responded
  var/lastResponseTime // When the admin last responded
  var/locationSent // Location the player was when they send the ticket
  var/mobControlled // Mob they were controlling
  var/ticketState // State of the ticket, open, closed, resolved etc
  var/timeUntilStale // When the ticket goes stale
  var/ticketCooldown // Cooldown before allowing the user to open another ticket.

/datum/admin_ticket/proc/beginStaleCount()
  if(!src)
    return
  while(world.time < timeUntilStale)
    sleep(200)
    if(ticketState == ADMIN_TICKET_OPEN && world.time > timeUntilStale)
      message_admins("<span class='adminticket'>Ticket #[ticketNum] has been open for [ADMIN_TICKET_TIMEOUT * 0.1] seconds. Changing status to stale.</span>")
      ticketState = ADMIN_TICKET_STALE
      break

/datum/admin_ticket/proc/setCooldownPeriod()
  ticketCooldown = world.time + ADMIN_TICKET_DUPLICATE_COOLDOWN

/datum/admin_ticket/proc/setLastAdminResponse(var/client/C)
  lastAdminResponse = C
  lastResponseTime = worldtime2text()

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