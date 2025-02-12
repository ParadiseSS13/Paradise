/datum/admins/Topic(href, href_list)
	. = ..()
	if(href_list["ai_respond"])
		var/datum/controller/subsystem/tickets/ticketSystem
		if(href_list["is_mhelp"])
			ticketSystem = SSmentor_tickets
		else
			ticketSystem = SStickets

		if(!check_rights(ticketSystem.rights_needed))
			return
		var/index = text2num(href_list["ai_respond"])
		ticketSystem.ai_respond(index)

/datum/controller/subsystem/tickets/proc/ai_respond(N)
	if(!check_rights(rights_needed))
		return

	if(tgui_alert(usr, "Вы действительно хотите использовать авто-ответ с помощью ИИ? Он может дать некорректный ответ.", "Предупреждение", list("Да", "Нет")) != "Да")
		return

	var/datum/ticket/T = allTickets[N]
	var/client/C = usr.client
	var/client/ticket_owner = get_client_by_ckey(T.client_ckey)
	T.assignStaff(C)

	SEND_SOUND(returnClient(N), sound('sound/effects/adminhelp.ogg'))
	message_staff("[C] has auto responded to [ticket_owner]\'s adminhelp with:<span class='adminticketalt'> AI </span>")
	log_game("[C] has auto responded to [ticket_owner]\'s adminhelp with AI")
	sendFollowupToDiscord(T, C, "*Autoresponded with AI*")

	var/static/system_message = file2text('strings/ahelp_system_message.txt')
	var/question = T.title

	GLOB.gpt220.request_completition(system_message, question, CALLBACK(src, PROC_REF(ai_respond_callback), N, TRUE))

/datum/controller/subsystem/tickets/proc/ai_respond_callback(N, resolve_ticket = FALSE, datum/http_response/response)
	if(response.errored)
		CRASH("AI failed to respond with code: [response.status_code]")

	response = json_decode(response.body)
	var/ai_response = response["choices"][1]["message"]["content"]
	var/datum/ticket/T = allTickets[N]

	to_chat_safe(returnClient(N), "<span class='[span_class]'>AI is autoresponding with:<span/><span class='adminticketalt'> [ai_response] </span>")
	message_staff("AI autoresponded with: [ai_response]")
	T.lastStaffResponse = "AI Autoresponse: [ai_response]"

	if(resolve_ticket)
		resolveTicket(N)

/datum/controller/subsystem/tickets/mentor_tickets/newTicket(client/C, passedContent, title)
	. = ..()
	var/datum/ticket/T = .
	var/list/mentorcounter = staff_countup(R_MENTOR)
	var/mentor_count = mentorcounter[1]
	if(mentor_count > 0)
		return

	SEND_SOUND(C, sound('sound/effects/adminhelp.ogg'))
	to_chat(C, "<span class='[span_class]'>Сейчас на сервере нет свободных менторов. На ваш вопрос ответит ИИ. Он может быть неточным и давать неправильные ответы.</span>")

	var/static/system_message = file2text('strings/ahelp_system_message.txt')
	var/question = T.title
	GLOB.gpt220.request_completition(system_message, question, CALLBACK(src, PROC_REF(ai_respond_callback), T.ticketNum, FALSE))
