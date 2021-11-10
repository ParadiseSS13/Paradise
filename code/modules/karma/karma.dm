// All karma procs that arent confined to the [/datum/karma_holder] are in here
/proc/sql_report_karma(mob/spender, mob/receiver)
	var/receiverrole = "None"
	var/receiverspecial = "None"

	if(receiver.mind)
		if(receiver.mind.special_role)
			receiverspecial = receiver.mind.special_role
		if(receiver.mind.assigned_role)
			receiverrole = receiver.mind.assigned_role

	if(!SSdbcore.IsConnected())
		return

	var/datum/db_query/log_query = SSdbcore.NewQuery({"
		INSERT INTO karma (spendername, spenderkey, receivername, receiverkey, receiverrole, receiverspecial, spenderip, time, server_id)
		VALUES (:sname, :skey, :rname, :rkey, :rrole, :rspecial, :sip, Now(), :server_id)"}, list(
			"sname" = spender.name,
			"skey" = spender.ckey,
			"rname" = receiver.name,
			"rkey" = receiver.ckey,
			"rrole" = receiverrole,
			"rspecial" = receiverspecial,
			"sip" = spender.client.address,
			"server_id" = GLOB.configuration.system.instance_id
		))

	if(!log_query.warn_execute())
		qdel(log_query)
		return

	qdel(log_query)

	var/datum/db_query/select_recv = SSdbcore.NewQuery("SELECT id, karma FROM karmatotals WHERE byondkey=:rkey", list(
		"rkey" = receiver.ckey
	))

	if(!select_recv.warn_execute())
		qdel(select_recv)
		return

	var/karma
	var/id
	while(select_recv.NextRow())
		id = select_recv.item[1]
		karma = text2num(select_recv.item[2])

	qdel(select_recv)

	// They dont exist, lets make them exist
	if(karma == null)
		karma = 1
		var/datum/db_query/insert_query = SSdbcore.NewQuery("INSERT INTO karmatotals (byondkey, karma) VALUES (:rkey, :karma)", list(
			"rkey" = receiver.ckey,
			"karma" = karma
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return

		qdel(insert_query)

	// They do exist. Update it.
	else
		karma++
		var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE karmatotals SET karma=:karma WHERE id=:id", list(
			"karma" = karma,
			"id" = id
		))
		if(!update_query.warn_execute())
			qdel(update_query)
			return

		qdel(update_query)

	receiver?.client.karmaholder.sync_karma(receiver) // Refresh their end

GLOBAL_LIST_EMPTY(karma_spenders)

// Returns TRUE if mob can give karma at all; if not, tells them why
/mob/proc/can_give_karma()
	if(!client)
		to_chat(src, "<span class='warning'>You can't award karma without being connected.</span>")
		return FALSE
	if(!GLOB.configuration.general.enable_karma)
		to_chat(src, "<span class='warning'>Karma is disabled.</span>")
		return FALSE
	if(!SSticker || !GLOB.player_list.len || (SSticker.current_state == GAME_STATE_PREGAME))
		to_chat(src, "<span class='warning'>You can't award karma until the game has started.</span>")
		return FALSE
	if(ckey in GLOB.karma_spenders)
		to_chat(src, "<span class='warning'>You've already spent your karma for the round.</span>")
		return FALSE
	return TRUE

// Returns TRUE if mob can give karma to M; if not, tells them why
/mob/proc/can_give_karma_to_mob(mob/M)
	if(!can_give_karma())
		return FALSE
	if(!istype(M))
		to_chat(src, "<span class='warning'>That's not a mob.</span>")
		return FALSE
	if(!M.client)
		to_chat(src, "<span class='warning'>That mob has no client connected at the moment.</span>")
		return FALSE
	if(M.ckey == ckey)
		to_chat(src, "<span class='warning'>You can't spend karma on yourself!</span>")
		return FALSE
	if(client.address == M.client.address)
		message_admins("<span class='warning'>Illegal karma spending attempt detected from [key] to [M.key]. Using the same IP!</span>")
		log_game("Illegal karma spending attempt detected from [key] to [M.key]. Using the same IP!")
		to_chat(src, "<span class='warning'>You can't spend karma on someone connected from the same IP.</span>")
		return FALSE
	if(M.get_preference(PREFTOGGLE_DISABLE_KARMA))
		to_chat(src, "<span class='warning'>That player has turned off incoming karma.")
		return FALSE
	return TRUE


/mob/verb/spend_karma_list()
	set name = "Award Karma"
	set desc = "Let the gods know whether someone's been nice. Can only be used once per round."
	set category = "Special Verbs"

	if(!can_give_karma())
		return

	var/list/karma_list = list()
	for(var/mob/M in GLOB.player_list)
		if(!(M.client && M.mind))
			continue
		if(M == src)
			continue
		if(M.get_preference(PREFTOGGLE_DISABLE_KARMA))
			continue
		if(!isobserver(src) && isNonCrewAntag(M))
			continue // Don't include special roles for non-observers, because players use it to meta
		karma_list += M

	if(!length(karma_list))
		to_chat(usr, "<span class='warning'>There's no-one to spend your karma on.</span>")
		return

	var/pickedmob = input("Who would you like to award Karma to?", "Award Karma", "Cancel") as null|mob in karma_list

	if(isnull(pickedmob))
		return

	spend_karma(pickedmob)

/mob/verb/spend_karma(mob/M)
	set name = "Award Karma to Player"
	set desc = "Let the gods know whether someone's been nice. Can only be used once per round."
	set category = "Special Verbs"

	if(!M)
		to_chat(usr, "Please right click a mob to award karma directly, or use the 'Award Karma' verb to select a player from the player listing.")
		return
	if(!GLOB.configuration.general.enable_karma) // this is here because someone thought it was a good idea to add an alert box before checking if they can even give a mob karma
		to_chat(usr, "<span class='warning'>Karma is disabled.</span>")
		return
	if(alert("Give [M.name] good karma?", "Karma", "Yes", "No") != "Yes")
		return
	if(!can_give_karma_to_mob(M))
		return // Check again, just in case things changed while the alert box was up

	to_chat(usr, "Good karma spent on [M.name].")
	GLOB.karma_spenders += ckey

	var/special_role = "None"
	var/assigned_role = "None"
	if(M.mind)
		if(M.mind.special_role)
			special_role = M.mind.special_role
		if(M.mind.assigned_role)
			assigned_role = M.mind.assigned_role

	log_karma("Karma awarded to [M.name] ([M.key]) (Role: [assigned_role] | Special: [special_role]) - Awarded by [ckey]")

	sql_report_karma(src, M) // This proc doesnt just report the purchase. It actually updates their balances.

/client/verb/check_karma()
	set name = "Check Karma"
	set desc = "Reports how much karma you have accrued."
	set category = "Special Verbs"

	if(!GLOB.configuration.general.enable_karma)
		to_chat(src, "<span class='warning'>Karma is disabled.</span>")
		return

	var/available_karma = karmaholder.karma_earned - karmaholder.karma_spent
	to_chat(usr, "You have ["<b>[available_karma]</b>" || "a database error. Contact the host if they are"] available.")

/client/verb/karmashop()
	set name = "karmashop"
	set desc = "Spend your karma here"
	set hidden = TRUE

	if(!GLOB.configuration.general.enable_karma)
		to_chat(src, "<span class='warning'>Karma is disabled.</span>")
		return

	karmaholder.open_shop_menu()

