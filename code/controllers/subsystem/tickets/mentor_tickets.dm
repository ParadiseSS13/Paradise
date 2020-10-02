GLOBAL_REAL(SSmentor_tickets, /datum/controller/subsystem/tickets/mentor_tickets)

/datum/controller/subsystem/tickets/mentor_tickets/New()
    NEW_SS_GLOBAL(SSmentor_tickets)
    PreInit()

/datum/controller/subsystem/tickets/mentor_tickets
	name = "Mentor Tickets"
	offline_implications = "Mentor tickets will no longer be marked as stale. No immediate action is needed."
	ticket_system_name = "Mentor Tickets"
	ticket_name = "Mentor Ticket"
	span_class = "mentorhelp"
	other_ticket_name = "Admin"
	other_ticket_permission = R_ADMIN
	close_rights = R_MENTOR | R_ADMIN
	rights_needed = R_MENTOR | R_ADMIN | R_MOD

/datum/controller/subsystem/tickets/mentor_tickets/Initialize()
	close_messages = list("<font color='red' size='3'><b>- [ticket_name] Closed -</b></font>",
				"<span class='boldmessage'>Please try to be as descriptive as possible in mentor helps. Mentors do not know the full situation you're in and need more information to give you a helpful response.</span>",
				"<span class='[span_class]'>Your [ticket_name] has now been closed.</span>")
	return ..()

/datum/controller/subsystem/tickets/mentor_tickets/message_staff(msg)
	message_mentorTicket(msg)

/datum/controller/subsystem/tickets/mentor_tickets/create_other_system_ticket(datum/ticket/T)
	SStickets.newTicket(get_client_by_ckey(T.client_ckey), T.content, T.title)
