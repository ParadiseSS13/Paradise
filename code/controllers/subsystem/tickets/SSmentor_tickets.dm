GLOBAL_REAL(SSmentor_tickets, /datum/controller/subsystem/tickets/mentor_tickets)

/datum/controller/subsystem/tickets/mentor_tickets/New()
	NEW_SS_GLOBAL(SSmentor_tickets)
	PreInit()
	ss_id = "mentor_tickets"

/datum/controller/subsystem/tickets/mentor_tickets
	name = "Mentor Tickets"
	offline_implications = "Mentor tickets will no longer be marked as stale. No immediate action is needed."
	ticket_system_name = "Mentor Tickets"
	ticket_name = "Mentor Ticket"
	span_class = "mentorhelp"
	anchor_link_extra = ";is_mhelp=1"
	ticket_help_type = "Mentorhelp"
	ticket_help_span = "mentorhelp"
	other_ticket_name = "Admin"
	other_ticket_permission = R_ADMIN
	close_rights = R_MENTOR | R_ADMIN
	rights_needed = R_MENTOR | R_ADMIN | R_MOD
	db_save_id = "MENTOR"

/datum/controller/subsystem/tickets/mentor_tickets/Initialize()
	..()
	close_messages = list("<font color='red' size='3'><b>- [ticket_name] Closed -</b></font>",
				"<span class='boldmessage'>Please try to be as descriptive as possible in mentor helps. Mentors do not know the full situation you're in and need more information to give you a helpful response.</span>",
				"<span class='[span_class]'>Your [ticket_name] has now been closed.</span>")

	response_phrases = list("Known Bug" = "Unfortunately, that's a known bug. Hopefully it gets fixed soon.",
		"TM Bug" = "Unfortunately, that's a bug with a current test merge. It should go away when the test merge is removed or fixed.",
		"Clear Cache" = "To fix a blank screen, go to the 'Special Verbs' tab and press 'Reload UI Resources'. If that fails, clear your BYOND cache (instructions provided with 'Reload UI Resources'). If that still fails, please ask for help again, stating you have already done these steps.",
		"Experiment!" = "Experiment! Part of the joy of this game is trying out various things, and dealing with the consequences if/when they go horribly wrong.",
		"How to Objectives" = "There are lots of ways to accomplish your objectives as an antagonist. A direct frontal assault may work, provided you can get in and out before backup arrives. Sneaking in can work, too, as long as you're quick and avoid prying eyes. But don't forget roleplaying methods!  Tricking your target into a maze of bear traps is much more interesting than just shooting them with a gun. Even if it fails, you and your target (or its guardians) are likely to have more fun this way, and that's the most important part.",
		"MHelp was in Russian" = "Привет! Ты попал на английский Paradise сервер. Возможно, ты ошибся. Русский имеет такое название: SS220\[RU].",
		"NCT Dispatch" = "A Nanotrasen Career Trainer will be assisting you in-game. You should be able to identify them by their green uniform and black coat."
	)

	if(GLOB.configuration.url.github_url)
		response_phrases["New Bug"] = "That sounds like a bug! To report it, please go to our <a href='[GLOB.configuration.url.github_url]'>Github page</a>. Then go to 'Issues', click 'New Issue', and fill out the report form. If the report would reveal current-round information, file it after the round ends."

	var/unsorted_responses = list()
	for(var/key in response_phrases)        //build a new list based on the short descriptive keys of the master list so we can send this as the input instead of the full paragraphs to the admin choosing which autoresponse
		unsorted_responses += key
	sorted_responses = sortTim(unsorted_responses, GLOBAL_PROC_REF(cmp_text_asc)) //use sortTim and cmp_text_asc to sort alphabetically


/datum/controller/subsystem/tickets/mentor_tickets/message_staff(msg, prefix_type = NONE, important = FALSE)
	message_mentorTicket(chat_box_mhelp(msg), important)

/datum/controller/subsystem/tickets/mentor_tickets/create_other_system_ticket(datum/ticket/T)
	SStickets.newTicket(get_client_by_ckey(T.client_ckey), T.first_raw_response, T.title)

/datum/controller/subsystem/tickets/mentor_tickets/sendFollowupToDiscord(datum/ticket/T, who, message)
	GLOB.discord_manager.send2discord_simple_mentor("Ticket [T.ticketNum], [who]: [message]")

/datum/controller/subsystem/tickets/mentor_tickets/sendAmbiguousFollowupToDiscord(list/ticket_numbers, who, message)
	GLOB.discord_manager.send2discord_simple_mentor("Ticket [ticket_numbers.Join(", ")] (ambiguous), [who]: [message]")

/datum/controller/subsystem/tickets/mentor_tickets/autoRespond(N)
	if(!check_rights(rights_needed))
		return

	var/datum/ticket/T = allTickets[N]
	var/client/C = usr.client
	if((T.staffAssigned && T.staffAssigned != C) || (T.lastStaffResponse && T.lastStaffResponse != C) || ((T.ticketState != TICKET_OPEN) && (T.ticketState != TICKET_STALE))) //if someone took this ticket, is it the same mentor who is autoresponding? if so, then skip the warning
		if(alert(usr, "[T.ticketState == TICKET_OPEN ? "Another mentor appears to already be handling this." : "This ticket is already marked as closed or resolved"] Are you sure you want to continue?", "Confirmation", "Yes", "No") != "Yes")
			return
	T.assignStaff(C)

	var/message_key = input("Select an autoresponse. This will mark the ticket as resolved.", "Autoresponse") as null|anything in sortTim(sorted_responses, GLOBAL_PROC_REF(cmp_text_asc)) //use sortTim and cmp_text_asc to sort alphabetically
	var/client/ticket_owner = get_client_by_ckey(T.client_ckey)
	if(message_key == null)
		T.staffAssigned = null //if they cancel we dont need to hold this ticket anymore
		return
	if(message_key == "NCT Dispatch")
		var/nct_active = list()
		for(var/mob/living/carbon/human/trainer as anything in GLOB.human_list) // Let's check if we have any active NCTs
			if(trainer.mind?.assigned_role != "Nanotrasen Career Trainer")
				continue
			nct_active += trainer
		if(!length(nct_active))
			to_chat(usr, "There are no active NCTs. Autoresponse canceled.") // If we don't, don't solve the ticket and then send feedback.
			return
		var/mob/living/carbon/human/trainee = get_mob_by_ckey(T.client_ckey)
		for(var/mob/living/carbon/human/nct as anything in nct_active)
			if(!locate(/obj/item/radio/headset) in list(nct.l_ear, nct.r_ear)) // If the NCT doesn't have a headset, ignore it.
				continue
			to_chat(nct, "<span class='notice'>Incoming priority transmission from Nanotrasen Training Center. Request information as follows: </span><span class='specialnotice'>Career Trainer, we've received a request from an employee. [trainee.p_their(TRUE)] name is [trainee.real_name], [trainee.p_theyre()] a [trainee.mind.assigned_role]. See if [trainee.p_they()] need [trainee.p_s()] any help.</span>")
			SEND_SOUND(nct, 'sound/effects/headset_message.ogg')

	SEND_SOUND(returnClient(N), sound('sound/effects/adminhelp.ogg'))
	to_chat_safe(returnClient(N), "<span class='[span_class]'>[key_name_hidden(C)] is autoresponding with:</span> <span class='adminticketalt'>[response_phrases[message_key]]</span>") //for this we want the full value of whatever key this is to tell the player so we do response_phrases[message_key]
	message_staff("[C] has auto responded to [ticket_owner]\'s mentorhelp with:<span class='adminticketalt'> [message_key]</span>") //we want to use the short named keys for this instead of the full sentence which is why we just do message_key
	T.lastStaffResponse = "Autoresponse: [message_key]"
	resolveTicket(N)
	log_game("[C] has auto responded to [ticket_owner]\'s mentorhelp with: [response_phrases[message_key]]")
