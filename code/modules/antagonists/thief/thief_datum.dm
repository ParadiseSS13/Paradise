/datum/antagonist/thief
	name = "Thief"
	job_rank = ROLE_THIEF
	special_role = SPECIAL_ROLE_THIEF
	antag_hud_type = ANTAG_HUD_THIEF
	antag_hud_name = "hudthief"
	clown_gain_text = "Вы превзошли свою клоунскую натуру, ваши ловкие пальцы нивелировали былую неуклюжесть!"
	clown_removal_text = "Ваша клоунская натура возвращается..."
	/// Whether our thief should get a special equipment box
	var/give_kit = TRUE


/datum/antagonist/thief/add_owner_to_gamemode()
	SSticker.mode.thieves |= owner


/datum/antagonist/thief/remove_owner_from_gamemode()
	SSticker.mode.thieves -= owner


/datum/antagonist/thief/give_objectives()
	//Hard objective
	if(prob(30))
		add_objective(/datum/objective/steal)
	else
		add_objective(/datum/objective/steal/hard)

	//Medium objective
	if(prob(50))
		add_objective(/datum/objective/steal/animal)
	else if(prob(70))
		add_objective(/datum/objective/steal/medium)
	else
		add_objective(/datum/objective/steal/structure)

	//Collect objective
	if(prob(70))
		add_objective(/datum/objective/steal/collect)
	else
		var/datum/objective/get_money/money_objective = add_objective(/datum/objective/get_money)
		money_objective.new_cash(accounts_procent = 50)

	//Escape objective
	var/list/all_objectives = owner.get_all_objectives()
	if(!(locate(/datum/objective/escape) in all_objectives) && !(locate(/datum/objective/survive) in all_objectives))
		add_objective(/datum/objective/escape)


/datum/antagonist/thief/greet()
	SEND_SOUND(owner.current, 'sound/ambience/antag/thiefalert.ogg')
	to_chat(owner.current, span_userdanger("Вы член гильдии воров!"))
	to_chat(owner.current, span_danger("Гильдия воров прислала новые заказы для кражи. Пора заняться старым добрым ремеслом, пока цели не украли конкуренты!"))


/datum/antagonist/thief/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("Вы киборгизированы!"))
		to_chat(owner.current, span_danger("Вы должны подчиняться своим законам и подчиняться мастеру ИИ. Ваши цели более недействительны."))
	else
		to_chat(owner.current, "<FONT color='red' size = 3><B>Вы встали на праведный путь и Гильдия Воров изгнала вас! Вы больше не вор!</B></FONT>")


/datum/antagonist/thief/finalize_antag()
	if(give_kit)
		equip_thief_kit()


/datum/antagonist/thief/proc/equip_thief_kit()
	if(!ishuman(owner.current))
		return
	var/obj/item/thief_kit/kit = new(null)
	if(!kit.equip_to_best_slot(owner.current))
		qdel(kit)
		log_admin("Failed to spawn thief kit for [owner.current.real_name].")
		message_admins("[ADMIN_LOOKUPFLW(owner.current)] Failed to spawn thief kit.")
		return
	to_chat(owner.current, span_notice("Набор гильдии воров [isstorage(kit.loc) ? "положен Вам в [kit.loc]" : "находится у Вас в инвентаре"]."))
