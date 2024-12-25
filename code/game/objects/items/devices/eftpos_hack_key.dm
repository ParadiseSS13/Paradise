/obj/item/eftpos_hack_key
	name = "EFTPOS Hacking Key"
	desc = "A small key for hacking EFTPOS diveses to steal clints personal information" // TODO
	icon = 'icons/obj/radio.dmi'
	icon_state = "cypherkey"
	item_state = ""
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "engineering=2;bluespace=1" // TODO
	var/list/access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_COMMAND, ACCESS_EXTERNAL_AIRLOCKS) // TODO
	var/list/stolen_data = list()


/obj/item/eftpos_hack_key/proc/read_agent_card(card, mob/living/user)
	if(istype(card, /obj/item/card/id/syndicate))
		var/obj/item/card/id/syndicate/agent_card = card
		if(isliving(user) && user?.mind?.special_role)
			to_chat(usr, "<span class='notice'>The card's microscanners activate as you pass it throw terminal, adding access.</span>")
			var/list/new_access = access - (agent_card.access & access)
			for(var/i = 3, i<3, i++)
				agent_card.access += pick(new_access)

/obj/item/eftpos_hack_key/proc/generate_print_text()

	var/victim_number = length(stolen_data)
	var/victim_text

	switch(victim_number)
		if(0)       	victim_text = "GO WORK AGENT!"
		if(1 to 3)      victim_text = "Ok, it's working, now you can start doing your job!"
		if(4 to 9)    	victim_text = "Good start, agent"
		if(10 to 20) 	victim_text = "Keep up the good work"
		if(21 to 50) 	victim_text = "Maybe...maybe you are usfull after all"
		if(50 to 100) 	victim_text = "You did not forget, you have actial job to do?"
		if(101 to 150) 	victim_text = "At this point, i just don't beleave you"
		else       		victim_text = "AGENT, STOP BRAKING MY STUF!!!"

	var/victim_rank
	var/rank_text


	if(ACCESS_CENT_COMMANDER in access)
		rank_text = "Эээ, разве у них вообще есть банковские аккаунты?"
		victim_rank = "Центральное командование"

	else if(ACCESS_CENT_SPECOPS in access)
		rank_text = "Откуда у них только свободное время на тебя."
		victim_rank = "ERT"

	else if(ACCESS_CAPTAIN in access)
		rank_text = "Крупный улов, неплохо."
		victim_rank = "Капитан"

	else if(ACCESS_BLUESHIELD in access)
		rank_text = "Ещё ода бестрашная гора мышц"
		victim_rank = "Blueshield"

	else if(ACCESS_MAGISTRATE in access)
		rank_text = "\"Закон - лишь цепь, для тех кто не принадлежит к элите\""
		victim_rank = "Судья"

	else if(ACCESS_NTREP in access)
		rank_text = "Кажется, он тут, чтобы наблюдать за их рабами."
		victim_rank = "Представитель нанотрейзен"

	else if(ACCESS_QM in access)
		rank_text = "Старый добрый, рабочий класс."
		victim_rank = "Квартирмейстер"

	else if(ACCESS_CE in access)
		rank_text = "Он вообще делает перерывы от работы?"
		victim_rank = "Главный инженер"

	else if(ACCESS_HOP in access)
		rank_text = "Мы оба знаем – он был лёгкой добычей."
		victim_rank = "Глава персонала"

	else if(ACCESS_CMO in access)
		rank_text = "Простите, док, сегодня мы будем вредить по полной."
		victim_rank = "Главный врач"

	else if(ACCESS_RD in access)
		rank_text = "Судя по базе... Его докторская скука смертная."
		victim_rank = "Директор Исследований"

	else if(ACCESS_HOS in access)
		rank_text = "Если бы он только знал, что ты с ним только что сделал."
		victim_rank = "Глава службы безопасности"

	else if(ACCESS_CLOWN in access)
		rank_text = "Mission has been failed successfully."
		victim_rank = "Клоун"

	else if(ACCESS_MIME in access)
		rank_text = "Как насчет: \"Говорить не умею, но взгляд у меня убийственный!\""
		victim_rank = "Мим"

	else if((ACCESS_BAR  in access) || (ACCESS_LIBRARY  in access) || (ACCESS_KITCHEN  in access) || (ACCESS_HYDROPONICS  in access))
		rank_text = "You were my brother, Anakin! I loved you!"
		victim_rank = "Сотрудник сервиса"

	else if(ACCESS_VIROLOGY in access)
		rank_text = "О да! о Да! Кажется, я знаю, что ты задумал!"
		victim_rank = "Вирусолог"

	else if((ACCESS_ENGINE_EQUIP  in access) || (ACCESS_ATMOSPHERICS  in access))
		rank_text = "В наше время так сложно найти рукастых парней."
		victim_rank = "Инженер"

	else if(ACCESS_MEDICAL in access)
		rank_text = "Знаешь? Ничего не имею против - этих ребят."
		victim_rank = "Медик"

	else if(ACCESS_RESEARCH in access)
		rank_text = "Недостаточно умен, чтобы заметить обман, хах!"
		victim_rank = "Учёный"

	else if(ACCESS_SECURITY in access)
		rank_text = "Теперь не такая безопасная, благодаря тебе."
		victim_rank = "Сотрудник безопасности"

	else if(ACCESS_CARGO in access)
		rank_text = "Кажется, у вас много общего! Например, вам обоим пора за работу!"
		victim_rank = "Грузчик"

	else
		rank_text = "Не уверен как это поможет тебе"
		victim_rank = "Не уверен кто это"

	var/text_to_print = {"
		<b>N@m3 Er0r r3f3r3nc3</b><br>
		<b>4cc3ss c0d3: @#_#@ </b><br>
		<b>Do n0t l0s3 or m1spl@ce this c0d3.</b><br>
		<center>Glory to syndicate! Here is your report agent</center>
		<center>Agent, you have stolen data [victim_number] times </center>
		<center>[victim_text]</center>
		<br>
		<center>Your most important target was: [victim_rank]</center>
		<center>[rank_text]</center>
		<br>
		<center>Here is your victims accounts details:</center><br>
		"}

	for(var/i = 1, length(stolen_data) >= i, i++)
		text_to_print += "[stolen_data[i]]<BR>"

	text_to_print+="Do not forget to tell you agent friends how useful my gadget is!"

	return text_to_print


/obj/item/eftpos_hack_key/proc/on_key_insert()


/obj/item/paper/eftpos_hack_key
	name = "EFTPOS Hack Key Guide"
	icon_state = "paper"
	info = {"<b>Hello, agent! You made a great purchase, I already like you!</b><br>
	<br>
	First, find a working EFTPOS terminal, then insert the hacking key into it.<br>
	<br>
	Now, whenever someone makes a transaction with their card, my device will steal their account information and provide access to up to three areas.<br>
	<br>
	<b>To copy all the accesses, just use your agent card and swipe it. Yep, those are sold separately!</b><br>
	<br>
	You can also use a screwdriver to remove the key if that wasn't obvious.<br>
	<br><hr>
"}
