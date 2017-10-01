/datum/adminTicketHolder/proc/returnUI(var/tab = ADMIN_TICKET_OPEN)
  set name = "Open Ticket Interface"
  set category = "Tickets"

//dat
  var/dat = "<h1>Admin Tickets</h1>"

  dat +="<a href='?src=[UID()];refresh=1'>Refresh</a><br /><a href='?src=[UID()];showopen=1'>Open Tickets</a><a href='?src=[UID()];showresolved=1'>Resolved Tickets</a><a href='?src=[UID()];showclosed=1'>Closed Tickets</a>"
  if(tab == ADMIN_TICKET_OPEN)
    dat += "<h2>Open Tickets</h2>"
  dat += "<table class='adminticket'>"
  dat +="<tr class='adminticket'><th>Control</th><th>Ticket</th><th>Detail</th></tr>"
  if(tab == ADMIN_TICKET_OPEN)
    for(var/T in allTickets)
      var/datum/admin_ticket/ticket = T
      if(ticket.ticketState == ADMIN_TICKET_OPEN || ticket.ticketState == ADMIN_TICKET_STALE)
        dat += "<tr class='adminticket'><td><a href='?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='?src=[UID()];close=[ticket.ticketNum]'>Close</a></td> <td><b>Ticket #[ticket.ticketNum]: at [ticket.timeOpened]: [ticket.content]</td> <td><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a></td></tr>"
      else
        continue
  else  if(tab == ADMIN_TICKET_RESOLVED)
    dat += "<h2>Resolved Tickets</h2>"
    for(var/T in allTickets)
      var/datum/admin_ticket/ticket = T
      if(ticket.ticketState == ADMIN_TICKET_RESOLVED)
        dat += "<tr><td><a href='?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='?src=[UID()];close=[ticket.ticketNum]'>Close</a></td> <td><b>Ticket #[ticket.ticketNum]: at [ticket.timeOpened]: [ticket.content]</td> <td><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a></td></tr>"
      else
        continue
  else if(tab == ADMIN_TICKET_CLOSED)
    dat += "<h2>Closed Tickets</h2>"
    for(var/T in allTickets)
      var/datum/admin_ticket/ticket = T
      if(ticket.ticketState == ADMIN_TICKET_CLOSED)
        dat += "<tr class='admintickets'><td><a href='?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='?src=[UID()];close=[ticket.ticketNum]'>Close</a></td> <td><b>Ticket #[ticket.ticketNum]: at [ticket.timeOpened]: [ticket.content]</td> <td><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a></td></tr>"
      else
        continue

  dat += "</table>"

  return dat

/datum/adminTicketHolder/proc/showUI(var/client/C, var/tab)
  var/dat = null
  dat = returnUI(tab)
  var/datum/browser/popup = new(usr, "admintickets", "Admin Tickets", 1200, 600)
  popup.set_content(dat)
  popup.open()

/datum/adminTicketHolder/proc/showDetailUI(var/client/C, var/ticketID)
  var/datum/admin_ticket/T = globAdminTicketHolder.allTickets[ticketID]
  var/status = "[T.state2text()]"

  var/dat = "<h1>Admin Tickets</h1>"

  dat +="<a href='?src=[UID()];refreshdetail=[T.ticketNum]'>Refresh</a>"

  dat += "<h2>Ticket #[T.ticketNum]</h2>"

  dat += "<h3>[T.clientName] / [T.mobControlled] opened this ticket at [T.timeOpened] at location [T.locationSent]</h3>"
  dat += "<h4>Ticket Status: <font color='red'>[status]</font>"
  dat += "<p>[T.content]</p>"

  dat += "<a href='?src=[UID()];reopen=[T.ticketNum]'>Re-Open</a><a href='?src=[UID()];resolve=[T.ticketNum]'>Resolve</a><a href='?src=[UID()];close=[T.ticketNum]'>Close</a>"

  dat += "<b>Last Admin Response:</b> [T.lastAdminResponse] at [T.lastResponseTime]"

  var/datum/browser/popup = new(usr, "adminticketsdetail", "Admin Ticket #[T.ticketNum]", 800, 600)
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
    globAdminTicketHolder.resolveTicket(indexNum)
    message_admins("<span class='adminticket'>[usr.client] / ([usr]) resolved admin ticket number [indexNum]</span>")
    showUI(usr)
    return

  if(href_list["close"])
    var/indexNum = text2num(href_list["close"])
    globAdminTicketHolder.closeTicket(indexNum)
    message_admins("<span class='adminticket'>[usr.client] / ([usr]) closed admin ticket number [indexNum]</span>")
    showUI(usr)
    return

  else if(href_list["reopen"])
    var/indexNum = text2num(href_list["reopen"])
    globAdminTicketHolder.openTicket(indexNum)
    message_admins("<span class='adminticket'>[usr.client] / ([usr]) re-opened admin ticket number [indexNum]</span>")