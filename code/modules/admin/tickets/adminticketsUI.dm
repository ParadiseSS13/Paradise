/datum/adminTicketHolder/proc/returnUI(var/tab = ADMIN_TICKET_OPEN)
  set name = "Open Ticket Interface"
  set category = "Tickets"

//dat
  var/trStyle = "border:3px solid;"
  var/tdStyle = "border:2px solid"
  var/datum/admin_ticket/ticket
  var/dat
  dat += "<head><style>.adminticket{border:2px solid}</style></head>"
  dat += "<body><h1>Admin Tickets</h1>"

  dat +="<a href='?src=[UID()];refresh=1'>Refresh</a><br /><a href='?src=[UID()];showopen=1'>Open Tickets</a><a href='?src=[UID()];showresolved=1'>Resolved Tickets</a><a href='?src=[UID()];showclosed=1'>Closed Tickets</a>"
  if(tab == ADMIN_TICKET_OPEN)
    dat += "<h2>Open Tickets</h2>"
  dat += "<table style='width:1100px; border: 3px solid;''>"
  dat +="<tr style='border-top:2px solid; border-below: 2px solid; padding-top: 5px; padding-bottom: 5px;'><th>Control</th><th>Ticket</th><th>Detail</th></tr>"
  if(tab == ADMIN_TICKET_OPEN)
    for(var/T in allTickets)
      ticket = T
      if(ticket.ticketState == ADMIN_TICKET_OPEN || ticket.ticketState == ADMIN_TICKET_STALE)
        dat += "<tr style='[trStyle]'><td style ='[tdStyle]'><a href='?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a></td> <td style='border:2px solid'><b>#[ticket.ticketNum]: ([ticket.timeOpened]): [ticket.content]</td> <td style ='[tdStyle]'><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a></td></tr>"
      else
        continue
  else  if(tab == ADMIN_TICKET_RESOLVED)
    dat += "<h2>Resolved Tickets</h2>"
    for(var/T in allTickets)
      ticket = T
      if(ticket.ticketState == ADMIN_TICKET_RESOLVED)
        dat += "<tr style='[trStyle]'><td style='[tdStyle]'><a href='?src=[UID()];detailreopen=[ticket.ticketNum]'>Re-open</a></td> <td style ='[tdStyle]'><b>#[ticket.ticketNum] ([ticket.timeOpened]): [ticket.content]</td> <td style ='[tdStyle]'><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a></td></tr>"
      else
        continue
  else if(tab == ADMIN_TICKET_CLOSED)
    dat += "<h2>Closed Tickets</h2>"
    for(var/T in allTickets)
      ticket = T
      if(ticket.ticketState == ADMIN_TICKET_CLOSED)
        dat += "<tr style='[trStyle]'><td style ='[tdStyle]'><td style='[tdStyle]''><a href='?src=[UID()];detailreopen=[ticket.ticketNum]'>Re-open</a></td> <td style ='[tdStyle]'><b>Ticket #[ticket.ticketNum]: at [ticket.timeOpened]: [ticket.content]</td> <td style ='[tdStyle]'><a href='?src=[UID()];details=[ticket.ticketNum]'>Details</a></td></tr>"
      else
        continue

  dat += "</table></body>"

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

  dat +="<a href='?src=[UID()];refresh=1>Show All</a><a href='?src=[UID()];refreshdetail=[T.ticketNum]'>Refresh</a>"

  dat += "<h2>Ticket #[T.ticketNum]</h2>"

  dat += "<h3>[T.clientName] / [T.mobControlled] opened this ticket at [T.timeOpened] at location [T.locationSent]</h3>"
  dat += "<h4>Ticket Status: <font color='red'>[status]</font>"
  dat += "<p>[T.content]</p>"

  dat += "<a href='?src=[UID()];detailreopen=[T.ticketNum]'>Re-Open</a><a href='?src=[UID()];detailresolve=[T.ticketNum]'>Resolve</a><br />"

  if(!T.adminAssigned)
    dat += "No admin assigned to this ticket - <a href='?src=[UID()];assignadmin=[T.ticketNum]'>Take Ticket</a><br />"
  else
    dat += "[T.adminAssigned] is assigned to this Ticket. - <a href='?src=[UID()];assignadmin=[T.ticketNum]'>Take Ticket</a><br />"

  if(T.lastAdminResponse)
    dat += "<b>Last Admin Response:</b> [T.lastAdminResponse] at [T.lastResponseTime]"
  else
    dat +="<font color='red'>No Admin Response</font>"

  dat += "<br />"

  dat += "<a href='?src=[UID()];detailclose=[T.ticketNum]'>Close</a>"

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
    if(globAdminTicketHolder.resolveTicket(indexNum))
      message_adminTicket("[usr.client] / ([usr]) resolved admin ticket number [indexNum]")
      to_chat(returnClient(indexNum), "<span class='adminticket'>Your admin ticket has now been resolved.</span>")
      showUI(usr)

  if(href_list["close"])

    var/indexNum = text2num(href_list["close"])
    if(alert("Are you sure? This will send a negative message.",,"Yes","No") != "Yes")
      return
    if(globAdminTicketHolder.closeTicket(indexNum))
      message_adminTicket("[usr.client] / ([usr]) closed admin ticket number [indexNum]")
      to_chat(returnClient(indexNum), "<font color='red' size='4'><b>- AdminHelp Rejected! -</b></font>")
      to_chat(returnClient(indexNum), "<span class='adminticket'>Please try to be calm, clear, and descriptive in admin helps, do not assume the admin has seen any related events, and clearly state the names of anybody you are reporting. If you asked a question, please ensure it was clear what you were asking.</span>")
      to_chat(returnClient(indexNum), "<span class='adminticket'>Your ticket has now been closed.</span>")
      showUI(usr)

  if(href_list["detailresolve"])
    var/indexNum = text2num(href_list["detailresolve"])
    if(globAdminTicketHolder.resolveTicket(indexNum))
      message_adminTicket("[usr.client] / ([usr]) resolved admin ticket number [indexNum]")
      to_chat(returnClient(indexNum), "<span class='adminticket'>Your admin ticket has now been resolved.</span>")
      showDetailUI(usr, indexNum)

  if(href_list["detailclose"])
    var/indexNum = text2num(href_list["detailclose"])
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
      to_chat(returnClient(indexNum), "<span class='adminticket'>Your ticket is being handled by ")
