GLOBAL_REAL(SSmentor_tickets, /datum/controller/subsystem/tickets/mentor_tickets)

/datum/controller/subsystem/tickets/mentor_tickets/New()
    NEW_SS_GLOBAL(SSmentor_tickets);
    PreInit();

/datum/controller/subsystem/tickets/mentor_tickets
	name = "Mentor Tickets"
	ticket_system_name = "Mentor Tickets"
	ticket_name = "Mentor Ticket"
	span_text = "<span class='mentorhelp'>"
	

/datum/controller/subsystem/tickets/mentor_tickets/message_staf(var/msg)
	message_mentorTicket(msg)
