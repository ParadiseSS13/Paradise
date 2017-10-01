//Verbs

/client/proc/startadmintickets()
  set name = "Restart Admin Ticket System"
  set category = "Tickets"

  if(!globAdminTicketHolder)
    var/global/datum/adminTicketHolder/globAdminTicketHolder = new /datum/adminTicketHolder
  else
    to_chat(world, "Already one running.")

/client/proc/vvadmintickets()
  set name = "Debug Admin Tickets"
  set category = "Tickets"

  debug_variables(globAdminTicketHolder)

/client/proc/openTicketUI()

  set name = "Open Ticket Interface"
  set category = "Tickets"

  if(!holder)
    return
  if(!check_rights(R_ADMIN))
    return

  globAdminTicketHolder.showUI()

/client/proc/generateTickets()
  set name = "Generate Ticket"
  set category = "Tickets"
  var/testmsg = pick("REEEEEEE", "HELP ME I'm NOOB!!", "PLEASE ADMIN REVIVE ME", "IS THIS LEGIT?", "some1 killed me 4noraisen", "birdtalon is powergaming again")

  globAdminTicketHolder.newTicket(src, testmsg)
