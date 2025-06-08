#define TICKET_STAFF_MESSAGE_ADMIN_CHANNEL 1
#define TICKET_STAFF_MESSAGE_PREFIX 2

SUBSYSTEM_DEF(tickets)
	name = "Админ Тикет"
	init_order = INIT_ORDER_TICKETS
	wait = 300
	priority = FIRE_PRIORITY_TICKETS
	offline_implications = "Admin tickets will no longer be marked as stale. No immediate action is needed."
	flags = SS_BACKGROUND

	var/span_class = "adminticket"
	var/ticket_system_name = "Admin Tickets"
	var/ticket_name = "Админ тикет"
	var/close_rights = R_ADMIN
	var/rights_needed = R_ADMIN | R_MOD

	/// Text that will be added to the anchor link
	var/anchor_link_extra = ""

	var/ticket_help_type = "Adminhelp"
	var/ticket_help_span = "adminhelp"
	/// The name of the other ticket type to convert to
	var/other_ticket_name = "Ментор"
	/// Which permission to look for when seeing if there is staff available for the other ticket type
	var/other_ticket_permission = R_MENTOR
	var/list/close_messages
	var/list/allTickets = list()	//make it here because someone might ahelp before the system has initialized

	var/ticketCounter = 1

	/// DB ID for these tickets to be logged with
	var/db_save_id = "ADMIN"

	// Autoresponse phrases.
	var/response_phrases
	// Autoresponse keys, in sorted order.
	var/sorted_responses

	/// Who has what tickets open? Maps client -> open ticket number.
	var/list/open_detail_uis = list()

/datum/controller/subsystem/tickets/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["tickets"] = length(allTickets) // Not a perf metric but I want to see a graph where SSair usage spikes and 20 tickets come in
	.["custom"] = cust

/datum/controller/subsystem/tickets/Initialize()
	close_messages = list("<font color='red' size='4'><b>- [ticket_name] Отклонён! -</b></font>",
			"<span class='boldmessage'>Пожалуйста, постарайтесь сохранять спокойствие в админ-хелпе, не предполагайте, что администратор видел какие-либо действия, о которых вы хотите сообщить, чётко называйте имена тех, на кого вы жалуетесь, и описывайте ситуацию. Если вы задали вопрос, пожалуйста, убедитесь, что вам ясно, о чём вы вообще спросили.</span>",
			"<span class='[span_class]'>Ваш [ticket_name] был закрыт.</span>")

	response_phrases = list("Спасибо" = "Спасибо за сигнал!",
		"Разбираемся" = "Вопрос изучается, спасибо.",
		"Уже решено" = "Проблема уже решена.",
		"Ментор-хелп" = "Пожалуйста, перенаправьте свой вопрос в ментор-хелп, так как они лучше разбираются в этом вопросе.",
		"Сообщите, если это продолжится" = "Спасибо, дайте нам знать если это будет продолжаться.",
		"Почисти Кэш" = "Чтобы исправить пустой экран, перейдите во вкладку 'Special Verbs' и нажмите 'Reload UI Resources'. Если это не поможет, очистите Кэш Byond, для этого закройте все процессы 'Dream Maker', перейдите в Byond, нажмите шестерёнку и выберите 'Preferences', во вкладке 'Games' будет кнопка 'Clear Cache'. Если ни один из этих способов не помог, советуем обратиться в 'paradise-help' чат на дискорд сервере.",
		"IC Issue" = "Это игровой момент (IC), и он не будет рассматриваться администрацией. Вы можете обратиться в службу безопасности, к агенту внутренних дел, главе отдела, представителю Нанотрейзен или к любому другому представителю власти, который находится на станции.",
		"Отклонить" = "Reject",
		"Man Up" = "Man Up",
	)

	/* if(GLOB.configuration.url.banappeals_url)
		response_phrases["Appeal on the Forums"] = "Appealing a ban must occur on the forums. Privately messaging, or adminhelping about your ban will not resolve it. To appeal your ban, please head to <a href='[GLOB.configuration.url.banappeals_url]'>[GLOB.configuration.url.banappeals_url]</a>"*/

	if(GLOB.configuration.url.github_url)
		response_phrases["Новый баг"] = "Звучит как баг! Чтобы сообщить о нём, пожалуйста, перейдите на наш <a href='[GLOB.configuration.url.github_url]'>GitHub</a>. После чего перейдите в 'Issues', нажмите 'New Issue' и заполните форму. Если в репорте будет информация с текущего раунда, отправьте ее только после его окончания. В качестве альтернативы вы можете написать в канал 'ss13-трекер' нашего дискорд сервера, однако репорты с GitHub обрабатываются быстрее!"

	/*if(GLOB.configuration.url.exploit_url)
		response_phrases["Exploit Report"] = "To report an exploit, please go to our <a href='[GLOB.configuration.url.exploit_url]'>Exploit Report page</a>. Then 'Start New Topic'. Then fill out the topic with as much information about the exploit that you can. If possible, add steps taken to reproduce the exploit. The Development Team will be informed automatically of the post."*/

	var/unsorted_responses = list()
	for(var/key in response_phrases)	//build a new list based on the short descriptive keys of the master list so we can send this as the input instead of the full paragraphs to the admin choosing which autoresponse
		unsorted_responses += key
	sorted_responses = sortTim(unsorted_responses, GLOBAL_PROC_REF(cmp_text_asc)) //use sortTim and cmp_text_asc to sort alphabetically

/datum/controller/subsystem/tickets/fire()
	var/stales = checkStaleness()
	if(LAZYLEN(stales))
		var/report
		for(var/num in stales)
			report += "[num], "
		message_staff("<span class='[span_class]'>Тикеты [report] были открыты более [TICKET_TIMEOUT / (60 SECONDS)] минут. Изменения статуса на устаревший.</span>")

/datum/controller/subsystem/tickets/get_stat_details()
	return "Тикеты: [LAZYLEN(allTickets)]"

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

/**
 * Will either make a new ticket using the given text or will add the text to an existing ticket.
 * Staff will get a message
 * Arguments:
 * C - The client who requests help
 * text - The text the client send
 */
/datum/controller/subsystem/tickets/proc/newHelpRequest(client/C, text)
	var/ticketNum // Holder for the ticket number
	var/datum/ticket/T
	// Get the open ticket assigned to the client and add a response. If no open tickets then make a new one
	if((T = checkForOpenTicket(C)))
		ticketNum = T.ticketNum
		T.addResponse(C, text)
		T.setCooldownPeriod()
		to_chat(C.mob, "<span class='[span_class]'>Ваш [ticket_name] #[ticketNum] остаётся открытым! Откройте \"My tickets\" во вкладке Admin для просмотра.</span>")
		var/url_message = makeUrlMessage(C, text, ticketNum)
		message_staff(url_message, NONE, TRUE)
		return T
	else
		return newTicket(C, text, text)

/**
 * Will add the URLs usable by staff to the message and return it
 * Arguments:
 * C - The client who send the message
 * msg - The raw message
 * ticketNum - Which ticket number the ticket has
 */
/datum/controller/subsystem/tickets/proc/makeUrlMessage(target, msg, ticketNum, one_line = FALSE)
	var/mob/M
	var/key_and_name
	if(istype(target, /datum/ticket))
		var/datum/ticket/T = target
		M = get_mob_by_ckey(T.client_ckey)
		key_and_name = M ? key_name(M, TRUE, ticket_help_type, ticket_id = T.ticketNum) : "[T.client_ckey] (DC)/(DELETED)"
		msg = T.title
		ticketNum = T.ticketNum
	else if(isclient(target))
		var/client/C = target
		M = C.mob
		key_and_name = key_name(M, TRUE, ticket_help_type, ticket_id = ticketNum)

	var/list/L = list()
	L += "<span class='[ticket_help_span]'>[ticket_help_type]: </span><span class='boldnotice'>[key_and_name][one_line ? " " : "<br>"]</span>"
	if(M)
		L += "([ADMIN_QUE(M,"?")]) ([ADMIN_PP(M,"PP")]) ([ADMIN_VV(M,"VV")]) ([ADMIN_TP(M,"TP")]) ([ADMIN_SM(M,"SM")]) ([admin_jump_link(M)])"
	L += "(<a href='byond://?_src_=holder;openticket=[ticketNum][anchor_link_extra]'>ТИКЕТ</a>) "
	L += "[is_ai(M) ? "(<a href='byond://?_src_=holder;adminchecklaws=[M.UID()]'>ЗАКОНЫ</a>)" : ""] (<a href='byond://?_src_=holder;take_question=[ticketNum][anchor_link_extra]'>ВЗЯТЬ</a>) "
	L += "(<a href='byond://?_src_=holder;resolve=[ticketNum][anchor_link_extra]'>РЕШИТЬ</a>) (<a href='byond://?_src_=holder;autorespond=[ticketNum][anchor_link_extra]'>АВТО</a>) "
	// SS220 ADDTITION START
	if(GLOB.configuration.gpt.gpt_enabled)
		L += "(<a href='byond://?_src_=holder;ai_respond=[ticketNum][anchor_link_extra]'>АВТО(ИИ)</a>) "
	// SS220 ADDTITION END
	L += "(<a href='byond://?_src_=holder;convert_ticket=[ticketNum][anchor_link_extra]'>КОНВЕРТ</a>) :</span> <span class='[ticket_help_span]'>[one_line ? " " : "<br><br>"][msg]</span>"
	return L.Join()

//Open a new ticket and populate details then add to the list of open tickets
/datum/controller/subsystem/tickets/proc/newTicket(client/C, passedContent, title)
	if(!C || !passedContent)
		return

	if(!title)
		title = passedContent

	var/new_ticket_num = getTicketCounterAndInc()
	var/url_title = makeUrlMessage(C, title, new_ticket_num)

	var/datum/ticket/T = new(title, passedContent, new_ticket_num, C.ckey)
	allTickets += T
	T.locationSent = C.mob.loc.name
	T.mobControlled = C.mob

	//Inform the user that they have opened a ticket
	to_chat(C, "<span class='[span_class]'>Вы открыли [ticket_name] номер #[(getTicketCounter() - 1)]! Ожидайте, мы вам поможем!</span>")
	SEND_SOUND(C, sound('sound/effects/adminticketopen.ogg'))

	message_staff(url_title, NONE, TRUE)
	open_ticket_count_updated()
	return T

//Set ticket state with key N to open
/datum/controller/subsystem/tickets/proc/openTicket(N)
	var/datum/ticket/T = allTickets[N]
	if(T.ticketState != TICKET_OPEN)
		message_staff("<span class='[span_class]'>[usr.client] / ([usr]) переоткрыл [ticket_name] номер [N]</span>")
		sendFollowupToDiscord(T, usr.client, "*Ticket reopened.*")
		to_chat_safe(returnClient(N), "<span class='[span_class]'>Ваш [ticket_name] был переоткрыт.</span>")
		T.ticketState = TICKET_OPEN
		open_ticket_count_updated()
		return TRUE

//Set ticket state with key N to resolved
/datum/controller/subsystem/tickets/proc/resolveTicket(N)
	var/datum/ticket/T = allTickets[N]
	if(T.ticketState != TICKET_RESOLVED)
		T.ticketState = TICKET_RESOLVED
		message_staff("<span class='[span_class]'>[usr.client] / ([usr]) решил [ticket_name] номер [N]</span>")
		sendFollowupToDiscord(T, usr.client, "*Ticket resolved.*")
		to_chat_safe(returnClient(N), "<span class='[span_class]'>Ваш [ticket_name] был решён.</span>")
		open_ticket_count_updated()
		return TRUE

/datum/controller/subsystem/tickets/proc/refresh_tickets(list/tickets)
	for(var/datum/ticket/T in tickets)
		for(var/client/client in open_detail_uis)
			if(client && open_detail_uis[client] == T.ticketNum)
				showDetailUI(client.mob, T.ticketNum)

/datum/controller/subsystem/tickets/proc/addResponse(list/tickets, who, message)
	var/list/ticket_numbers = list()
	for(var/datum/ticket/T in tickets)
		ticket_numbers += T.ticketNum
		T.addResponse(who, message)
	refresh_tickets(tickets)

	if(length(ticket_numbers) == 1)
		for(var/datum/ticket/only_ticket in tickets)
			sendFollowupToDiscord(only_ticket, who, message)
	else if(length(ticket_numbers) > 1)
		sendAmbiguousFollowupToDiscord(ticket_numbers, who, message)
	else
		CRASH("addResponse on [ticket_system_name] called with no tickets")

/datum/controller/subsystem/tickets/proc/sendFollowupToDiscord(datum/ticket/T, who, message)
	GLOB.discord_manager.send2discord_simple_noadmins("**\[Adminhelp]** Ticket [T.ticketNum], [who]: [message]", check_send_always = TRUE)

/datum/controller/subsystem/tickets/proc/sendAmbiguousFollowupToDiscord(list/ticket_numbers, who, message)
	GLOB.discord_manager.send2discord_simple_noadmins("**\[Adminhelp]** Ticket [ticket_numbers.Join(", ")] (ambiguous), [who]: [message]", check_send_always = TRUE)

/datum/controller/subsystem/tickets/proc/convert_to_other_ticket(ticketId)
	if(!check_rights(rights_needed))
		return
	if(alert("Вы уверены что хотите конвертировать в '[other_ticket_name]' тикет?", null,"Да","Нет") != "Да")
		return
	if(!other_ticket_system_staff_check())
		return
	var/datum/ticket/T = allTickets[ticketId]
	if(T.ticket_converted)
		to_chat(usr, "<span class='warning'>Этот тикет уже конвертирован!</span>")
		return
	convert_ticket(T)
	message_staff("<span class='[span_class]'>[usr.client] / ([usr]) конвертировал [ticket_name] номер [ticketId]</span>")
	sendFollowupToDiscord(T, usr.client, "*Ticket converted.*")

/datum/controller/subsystem/tickets/proc/other_ticket_system_staff_check()
	var/list/staff = staff_countup(other_ticket_permission)
	if(!staff[1])
		if(alert("Нет активных администраторов/менторов. Вы уверены что хотите конвертировать?", null, "Нет", "Да") != "Да")
			return FALSE
	return TRUE

/datum/controller/subsystem/tickets/proc/convert_ticket(datum/ticket/T)
	var/client/C = usr.client
	var/client/owner = get_client_by_ckey(T.client_ckey)
	if(!owner)
		to_chat(C, "<span class='notice'Невозможно конвертировать тикет отключённого игрока.")
		return
	T.ticketState = TICKET_CLOSED
	T.ticket_converted = TRUE
	to_chat_safe(owner, list("<span class='[span_class]'>[key_name_hidden(C)] конвертировал ваш тикет в [other_ticket_name] тикет.</span>",\
									"<span class='[span_class]'>Постарайтесь использовать правильный тикет в следующий раз!</span>"))
	message_staff("<span class='[span_class]'>[C] конвертировал тикет номер [T.ticketNum] в [other_ticket_name] тикет.</span>")
	log_game("[C] конвертировал тикет номер [T.ticketNum] в [other_ticket_name] тикет.")
	create_other_system_ticket(T)
	open_ticket_count_updated()

/datum/controller/subsystem/tickets/proc/create_other_system_ticket(datum/ticket/T)
	var/client/C = get_client_by_ckey(T.client_ckey)
	SSmentor_tickets.newTicket(C, T.first_raw_response, T.title)

/datum/controller/subsystem/tickets/proc/autoRespond(N)
	if(!check_rights(rights_needed))
		return

	var/datum/ticket/T = allTickets[N]
	var/client/C = usr.client
	if((T.staffAssigned && T.staffAssigned != C) || (T.lastStaffResponse && T.lastStaffResponse != C) || ((T.ticketState != TICKET_OPEN) && (T.ticketState != TICKET_STALE))) //if someone took this ticket, is it the same admin who is autoresponding? if so, then skip the warning
		if(alert(usr, "[T.ticketState == TICKET_OPEN ? "Другой администратор уже разбирается." : "Этот тикет уже помечен как решённый или закрытый."] Вы уверены что хотите продолжить?", "Подтверждение", "Да", "Нет") != "Да")
			return
	T.assignStaff(C)


	var/message_key = input("Выберите автоответ. Это пометит тикет как решённый.", "Автоответ") as null|anything in sorted_responses
	var/client/ticket_owner = get_client_by_ckey(T.client_ckey)
	if(!ticket_owner)
		to_chat(C, "<span class='notice'>Невозможно ответить на тикет отключённого игрока.")
		return
	switch(message_key)
		if(null) //they cancelled
			T.staffAssigned = null //if they cancel we dont need to hold this ticket anymore
			return
		if("Отклонить")
			if(!closeTicket(N))
				to_chat(C, "Невозможно закрыть тикет")
		if("Man Up")
			C.man_up(returnClient(N))
			T.lastStaffResponse = "Автоответ: [message_key]"
			resolveTicket(N)
			message_staff("[C] ипользовал автоответ в админ-тикете [ticket_owner]:<span class='adminticketalt'> [message_key]</span>")
			sendFollowupToDiscord(T, C, "*Autoresponded with [message_key]*")
			log_game("[C] ипользовал автоответ в админ-тикете [T.client_ckey]: [response_phrases[message_key]]")
		if("Ментор-хелп")
			convert_ticket(T)
		else
			SEND_SOUND(returnClient(N), sound('sound/effects/adminhelp.ogg'))
			to_chat_safe(returnClient(N), "<span class='[span_class]'>[key_name_hidden(C)] использует автоответ:<span/> <span class='adminticketalt'>[response_phrases[message_key]]</span>")//for this we want the full value of whatever key this is to tell the player so we do response_phrases[message_key]
			message_staff("[C] ипользовал автоответ в админ-тикете [ticket_owner]:<span class='adminticketalt'> [message_key]</span>") //we want to use the short named keys for this instead of the full sentence which is why we just do message_key
			sendFollowupToDiscord(T, C, "*Autoresponded with [message_key]*")
			T.lastStaffResponse = "Автоответ: [message_key]"
			resolveTicket(N)
			log_game("[C] ипользовал автоответ в админ-тикете [ticket_owner]: [response_phrases[message_key]]")

//Set ticket state with key N to closed
/datum/controller/subsystem/tickets/proc/closeTicket(N)
	var/datum/ticket/T = allTickets[N]
	if(T.ticketState != TICKET_CLOSED)
		message_staff("<span class='[span_class]'>[usr.client] / ([usr]) закрыл [ticket_name] номер [N]</span>")
		sendFollowupToDiscord(T, usr.client, "*Ticket closed.*")
		to_chat_safe(returnClient(N), close_messages)
		T.ticketState = TICKET_CLOSED
		open_ticket_count_updated()
		return TRUE

//Check if the user already has a ticket open and within the cooldown period.
/datum/controller/subsystem/tickets/proc/checkForOpenTicket(client/C)
	for(var/datum/ticket/T in allTickets)
		if(T.client_ckey == C.ckey && T.ticketState == TICKET_OPEN && (T.ticketCooldown > world.time))
			return T
	return FALSE

//Check if the user has ANY ticket not resolved or closed.
//If ticket_id is valid, will return that ticket regardless of state.
/datum/controller/subsystem/tickets/proc/checkForTicket(client/C, ticket_id = -1)
	if(ticket_id > 0 && ticket_id <= length(allTickets))
		return list(allTickets[ticket_id])
	var/list/tickets = list()
	for(var/datum/ticket/T in allTickets)
		if(T.client_ckey == C.ckey && (T.ticketState == TICKET_OPEN || T.ticketState == TICKET_STALE))
			tickets += T
	if(length(tickets))
		return tickets
	return FALSE

//return the client of a ticket number
/datum/controller/subsystem/tickets/proc/returnClient(N)
	var/datum/ticket/T = allTickets[N]
	return get_client_by_ckey(T.client_ckey)

/datum/controller/subsystem/tickets/proc/assignStaffToTicket(client/C, N)
	var/datum/ticket/T = allTickets[N]
	if(T.staffAssigned != null && T.staffAssigned != C && alert("Тикет уже взял [T.staffAssigned.ckey]. Вы уверены что хотите взять его?", "Взять тикет", "Да", "Нет") != "Да")
		return FALSE
	T.assignStaff(C)
	return TRUE

//Single staff ticket

/datum/ticket
	/// Ticket number.
	var/ticketNum
	/// ckey of the client who opened the ticket.
	var/client_ckey
	/// Real time the ticket was opened.
	var/real_time_opened
	/// Ingame time the ticket was opened
	var/ingame_time_opened
	/// The initial message from the user.
	var/title
	/// Content of the staff help.
	var/list/datum/ticket_response/ticket_responses
	/// Last staff member who responded.
	var/lastStaffResponse
	/// When the staff last responded.
	var/lastResponseTime
	/// The location the player was when they sent the ticket.
	var/locationSent
	/// The mob the player was controlling when they sent the ticket.
	var/mobControlled
	/// State of the ticket, open, closed, resolved etc.
	var/ticketState
	/// Has the ticket been converted to another type? (Mhelp to Ahelp, etc.)
	var/ticket_converted = FALSE
	/// When the ticket goes stale.
	var/timeUntilStale
	/// Cooldown before allowing the user to open another ticket.
	var/ticketCooldown
	/// Staff member who has assigned themselves to this ticket.
	var/client/staffAssigned
	/// The first raw response. Used for ticket conversions
	var/first_raw_response
	/// Staff member ckey who took it
	var/staff_ckey
	/// The time the staff member took the ticket
	var/staff_take_time
	/// List of adminwho data
	var/list/adminwho_data = list()


/datum/ticket/New(tit, cont, num, the_ckey)
	title = tit
	client_ckey = the_ckey
	first_raw_response = cont
	ticket_responses = list()
	ticket_responses += new /datum/ticket_response(cont, the_ckey)
	real_time_opened = SQLtime()
	ingame_time_opened = (ROUND_TIME ? time2text(ROUND_TIME, "hh:mm:ss") : 0)
	timeUntilStale = world.time + TICKET_TIMEOUT
	setCooldownPeriod()
	ticketNum = num
	ticketState = TICKET_OPEN

	for(var/client/C in GLOB.admins)
		var/list/this_data = list()
		this_data["ckey"] = C.ckey
		this_data["rank"] = C.holder.rank
		this_data["afk"] = C.inactivity

		adminwho_data += list(this_data)

//Set the cooldown period for the ticket. The time when it's created plus the defined cooldown time.
/datum/ticket/proc/setCooldownPeriod()
	ticketCooldown = world.time + TICKET_DUPLICATE_COOLDOWN

//Set the last staff who responded as the client passed as an arguement.
/datum/ticket/proc/setLastStaffResponse(client/C)
	lastStaffResponse = C
	lastResponseTime = worldtime2text()

//Return the ticket state as a colour coded text string.
/datum/ticket/proc/state2text()
	if(ticket_converted)
		return "<font color='yellow'>CONVERTED</font>"
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
	staff_ckey = C.ckey
	staff_take_time = SQLtime()
	return TRUE

/datum/ticket/proc/addResponse(client/C, msg)
	if(C.holder)
		setLastStaffResponse(C)
	ticket_responses += new /datum/ticket_response(msg, C.ckey)

/datum/ticket/proc/makeStale()
	ticketState = TICKET_STALE
	return ticketNum

// Staff ticket response
/datum/ticket_response
	/// Text of this response
	var/response_text
	/// Who made the response
	var/response_user
	/// The time of the response
	var/response_time

/datum/ticket_response/New(the_text, the_ckey)
	response_text = the_text
	response_user = the_ckey
	response_time = SQLtime()

/datum/ticket_response/proc/to_string()
	return "[response_user]: [response_text]"

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

	dat +="<a href='byond://?src=[UID()];refresh=1'>Refresh</a><br /><a href='byond://?src=[UID()];showopen=1'>Open Tickets</a><a href='byond://?src=[UID()];showresolved=1'>Resolved Tickets</a><a href='byond://?src=[UID()];showclosed=1'>Closed Tickets</a>"
	if(tab == TICKET_OPEN)
		dat += "<h2>Open Tickets</h2>"
	dat += "<table style='width:1300px; border: 3px solid;'>"
	dat +="<tr style='[trStyle]'><th style='[tdStyleleft]'>Control</th><th style='[tdStyle]'>Ticket</th></tr>"
	if(tab == TICKET_OPEN)
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == TICKET_OPEN || ticket.ticketState == TICKET_STALE)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='byond://?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='byond://?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.ingame_time_opened]) [ticket.ticketState == TICKET_STALE ? "<font color='red'><b>STALE</b></font>" : ""] </td><td style='[tdStyle]'><b>[makeUrlMessage(ticket, one_line = TRUE)]</b></td></tr>"
			else
				continue
	else  if(tab == TICKET_RESOLVED)
		dat += "<h2>Resolved Tickets</h2>"
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == TICKET_RESOLVED)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='byond://?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='byond://?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.ingame_time_opened]) </td><td style='[tdStyle]'><b>[makeUrlMessage(ticket, one_line = TRUE)]</b></td></tr>"
			else
				continue
	else if(tab == TICKET_CLOSED)
		dat += "<h2>Closed Tickets</h2>"
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == TICKET_CLOSED)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='byond://?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='byond://?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.ingame_time_opened]) </td><td style='[tdStyle]'><b>[makeUrlMessage(ticket, one_line = TRUE)]</b></td></tr>"
			else
				continue

	dat += "</table>"
	dat += "<h1>Resolve All</h1>"
	if(ticket_system_name == "Mentor Tickets")
		dat += "<a href='byond://?src=[UID()];resolveall=1'>Resolve All Open Mentor Tickets</a></body>"
	else
		dat += "<a href='byond://?src=[UID()];resolveall=1'>Resolve All Open Admin Tickets</a></body>"

	return dat

/datum/controller/subsystem/tickets/proc/showUI(mob/user, tab)
	var/dat = null
	dat = returnUI(tab)
	var/datum/browser/popup = new(user, ticket_system_name, ticket_system_name, 1400, 800)
	popup.set_content(dat)
	popup.open()
	// This isn't the detail tab, stop listening for the user's typing.
	open_detail_uis -= user.client

/datum/controller/subsystem/tickets/proc/showDetailUI(mob/user, ticketID)
	var/datum/ticket/T = allTickets[ticketID]
	var/status = "[T.state2text()]"

	var/dat = "<h1>[ticket_system_name]</h1>"

	dat +="<a href='byond://?src=[UID()];refresh=1'>Show All</a><a href='byond://?src=[UID()];refreshdetail=[T.ticketNum]'>Refresh</a>"

	dat += "<h2>Ticket #[T.ticketNum]</h2>"

	dat += "<h3>[T.client_ckey] / [T.mobControlled] opened this [ticket_name] at [T.ingame_time_opened] at location [T.locationSent]</h3>"
	dat += "<h4>Ticket Status: [status]"
	dat += "<div id='msgs' style='width:950px; border: 3px solid; overflow-y: scroll; height: 350px;'>"
	dat += "<table style='width:100%;'>"
	dat += "<tr><td>[makeUrlMessage(T, one_line = TRUE)]</td></tr>"

	if(length(T.ticket_responses) > 1)
		for(var/i in 2 to length(T.ticket_responses))
			var/datum/ticket_response/TR = T.ticket_responses[i]
			dat += "<tr><td>[TR.to_string()]</td></tr>"

	dat += "</table></div>"
	var/client/C = get_client_by_ckey(T.client_ckey)
	for(var/key in C?.pm_tracker.pms)
		var/datum/pm_convo/convo = C.pm_tracker.pms[key]
		if(convo.typing)
			dat += "<i><span class='typing'>[key] is typing</span></i><br />"

	var/found_typing = FALSE
	for(var/client/X in GLOB.admins)
		if(ckey(X.ckey) == ckey(T.client_ckey))
			continue
		if(!check_rights_for(X, rights_needed))
			continue
		for(var/key in X.pm_tracker.pms)
			if(ckey(key) != ckey(T.client_ckey))
				continue
			var/datum/pm_convo/convo = X.pm_tracker.pms[key]
			if(convo.typing)
				dat += "<i><span class='typing'>[key] is typing</span></i><br />"
				found_typing = TRUE
				break
		if(found_typing)
			break

	dat += "<br />"
	dat += "<a href='byond://?src=[UID()];detailreopen=[T.ticketNum]'>Re-Open</a>[check_rights(rights_needed, 0) ? "<a href='byond://?src=[UID()];autorespond=[T.ticketNum]'>Auto</a>": ""]<a href='byond://?src=[UID()];detailresolve=[T.ticketNum]'>Resolve</a><br /><br />"

	if(!T.staffAssigned)
		dat += "No staff member assigned to this [ticket_name] - <a href='byond://?src=[UID()];assignstaff=[T.ticketNum]'>Take Ticket</a><br />"
	else
		dat += "[T.staffAssigned] is assigned to this Ticket. - <a href='byond://?src=[UID()];assignstaff=[T.ticketNum]'>Take Ticket</a> - <a href='byond://?src=[UID()];unassignstaff=[T.ticketNum]'>Unassign Ticket</a><br />"

	if(T.lastStaffResponse)
		dat += "<b>Last Staff response Response:</b> [T.lastStaffResponse] at [T.lastResponseTime]"
	else
		dat +="<font color='red'>No Staff Response</font>"

	dat += "<br /><br />"

	dat += "<a href='byond://?src=[UID()];detailclose=[T.ticketNum]'>Close Ticket</a>"
	dat += "<a href='byond://?src=[UID()];convert_ticket=[T.ticketNum]'>Convert Ticket</a>"

	var/datum/browser/popup = new(user, "[ticket_system_name]detail", "[ticket_system_name] #[T.ticketNum]", 1000, 800, src)
	popup.add_head_content(@{"<script type='text/javascript'>
		window.onload = function () {
			var msgs = document.getElementById('msgs');
			msgs.scrollTop = msgs.scrollHeight;
		}
		</script>"})
	popup.set_content(dat)
	popup.open()
	open_detail_uis[user.client] = T.ticketNum

/datum/controller/subsystem/tickets/proc/onCloseDetailUI(mob/user)
	open_detail_uis -= user.client

/datum/controller/subsystem/tickets/proc/userDetailUI(mob/user)
//dat
	var/tickets = checkForTicket(user.client)
	var/dat
	dat += "<h1>Your open [ticket_system_name]</h1>"
	dat += "<table>"
	for(var/datum/ticket/T in tickets)
		dat += "<tr><td><h2>Ticket #[T.ticketNum]</h2></td></tr>"
		for(var/i in 1 to length(T.ticket_responses))
			var/datum/ticket_response/TR = T.ticket_responses[i]
			dat += "<tr><td>[TR.to_string()]</td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "[ticket_system_name]userticketsdetail", ticket_system_name, 1000, 800)
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

/**
 * Sends a message to the designated staff
 * Arguments:
 * msg - The message being send
 * alt - If an alternative prefix should be used or not. Defaults to TICKET_STAFF_MESSAGE_PREFIX
 * important - If the message is important. If TRUE it will ignore the CHAT_NO_TICKETLOGS preferences,
 *             send a sound and flash the window. Defaults to FALSE
 */
/datum/controller/subsystem/tickets/proc/message_staff(msg, prefix_type = TICKET_STAFF_MESSAGE_PREFIX, important = FALSE)
	switch(prefix_type)
		if(TICKET_STAFF_MESSAGE_ADMIN_CHANNEL)
			msg = "<span class='admin_channel'>ADMIN TICKET: [msg]</span>"
		if(TICKET_STAFF_MESSAGE_PREFIX)
			msg = "<span class='adminticket'><span class='prefix'>ADMIN TICKET:</span> [msg]</span>"
	message_adminTicket(chat_box_ahelp(msg), important)

/datum/controller/subsystem/tickets/Topic(href, href_list)
	if(!check_rights(rights_needed))
		return

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
		if(alert("Are you sure? This will send a negative message.", null,"Yes","No") != "Yes")
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

	if(href_list["convert_ticket"])
		var/indexNum = text2num(href_list["convert_ticket"])
		convert_to_other_ticket(indexNum)

	if(href_list["resolveall"])
		if(ticket_system_name == "Mentor Tickets")
			usr.client.resolveAllMentorTickets()
		else
			usr.client.resolveAllAdminTickets()

	if(href_list["close"])
		onCloseDetailUI(usr)

/datum/controller/subsystem/tickets/proc/takeTicket(index)
	if(assignStaffToTicket(usr.client, index))
		if(span_class == "mentorhelp")
			message_staff("<span class='[span_class]'>[usr.client] / ([usr]) has taken [ticket_name] number [index]</span>")
		else
			message_staff("<span class='admin_channel'>[usr.client] / ([usr]) has taken [ticket_name] number [index]</span>", TICKET_STAFF_MESSAGE_ADMIN_CHANNEL)
		to_chat_safe(returnClient(index), "<span class='[span_class]'>Your [ticket_name] is being handled by [usr.client].</span>")

/datum/controller/subsystem/tickets/proc/unassignTicket(index)
	var/datum/ticket/T = allTickets[index]
	if(T.staffAssigned != null && (T.staffAssigned == usr.client || alert("Ticket is already assigned to [T.staffAssigned]. Do you want to unassign it?","Unassign ticket","No","Yes") == "Yes"))
		T.staffAssigned = null
		to_chat_safe(returnClient(index), "<span class='[span_class]'>Your [ticket_name] has been unassigned. Another staff member will help you soon.</span>")
		if(span_class == "mentorhelp")
			message_staff("<span class='[span_class]'>[usr.client] / ([usr]) has unassigned [ticket_name] number [index]</span>")
		else
			message_staff("<span class='admin_channel'>[usr.client] / ([usr]) has unassigned [ticket_name] number [index]</span>", TICKET_STAFF_MESSAGE_ADMIN_CHANNEL)


/datum/controller/subsystem/tickets/Shutdown()
	// Lets get saving these tickets
	var/list/datum/db_query/all_queries = list()

	for(var/datum/ticket/T in allTickets)
		var/end_state_txt = "UNKNOWN"

		switch(T.ticketState)
			if(TICKET_OPEN)
				end_state_txt = "OPEN"
			if(TICKET_CLOSED)
				end_state_txt = "CLOSED"
			if(TICKET_RESOLVED)
				end_state_txt = "RESOLVED"
			if(TICKET_STALE)
				end_state_txt = "STALE"

		// Lets sort our responses out
		var/list/raw_responses = list()
		for(var/datum/ticket_response/TR in T.ticket_responses)
			var/list/this_response = list()
			this_response["ckey"] = TR.response_user
			this_response["text"] = html_decode(strip_html_tags(TR.response_text)) // Dont want to save HTML stuff to the DB
			this_response["time"] = TR.response_time

			raw_responses += list(this_response)

		var/all_responses_txt = json_encode(raw_responses)

		var/datum/db_query/Q = SSdbcore.NewQuery({"INSERT INTO tickets
			(ticket_num, ticket_type, real_filetime, relative_filetime, ticket_creator, ticket_topic, ticket_taker, ticket_take_time, all_responses, end_round_state, awho)
			VALUES
			(:tnum, :ttype, :realt, :relativet, :tcreator, :ttopic, :ttaker, :ttaketime, :allresponses, :endstate, :awho)"},
			list(
				"tnum" = T.ticketNum,
				"ttype" = db_save_id,
				"realt" = T.real_time_opened,
				"relativet" = T.ingame_time_opened,
				"tcreator" = T.client_ckey,
				"ttopic" = T.title,
				"ttaker" = T.staff_ckey,
				"ttaketime" = T.staff_take_time,
				"allresponses" = all_responses_txt,
				"endstate" = end_state_txt,
				"awho" = json_encode(T.adminwho_data),
			))

		all_queries += Q

	SSdbcore.MassExecute(all_queries, TRUE, TRUE, FALSE, TRUE)

/datum/controller/subsystem/tickets/can_vv_get(var_name)
	var/static/list/protected_vars = list(
		"allTickets"
	)
	if(!check_rights(R_ADMIN, FALSE, usr) && (var_name in protected_vars))
		return FALSE
	return TRUE

/datum/controller/subsystem/tickets/proc/open_ticket_count_updated()
	var/ticket_count = 0
	for(var/datum/ticket/T in allTickets)
		if(T.ticketState == TICKET_OPEN || T.ticketState == TICKET_STALE)
			ticket_count++
	SEND_SIGNAL(src, COMSIGN_TICKET_COUNT_UPDATE, ticket_count)

#undef TICKET_STAFF_MESSAGE_ADMIN_CHANNEL
#undef TICKET_STAFF_MESSAGE_PREFIX

#undef TICKET_TIMEOUT
#undef TICKET_DUPLICATE_COOLDOWN
#undef TICKET_OPEN
#undef TICKET_CLOSED
#undef TICKET_RESOLVED
#undef TICKET_STALE
