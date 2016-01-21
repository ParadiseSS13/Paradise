var/datum/announcement/minor/slotmachine_announcement = new(do_log = 0)

/obj/machinery/slot_machine
	name = "slot machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/objects.dmi'
	icon_state = "slots-off"
	anchored = 1
	density = 1
	var/plays = 0
	var/working = 0
	var/datum/money_account/account = null
	var/result = null
	var/resultlvl = null

/obj/machinery/slot_machine/attack_hand(mob/user as mob)
	account = user.get_worn_id_account()
	if(!account)
		if(istype(user.get_active_hand(), /obj/item/weapon/card/id))
			account = get_card_account(user.get_active_hand())
		else
			account = null

	ui_interact(user)

/obj/machinery/slot_machine/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data["working"] = working
	data["money"] = account ? account.money : null
	data["plays"] = plays
	data["result"] = result
	data["resultlvl"] = resultlvl

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "slotmachine.tmpl", name, 350, 200)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/slot_machine/Topic(href, href_list)
	add_fingerprint(usr)

	if(href_list["ops"])
		var/operation = text2num(href_list["ops"])
		if(operation == 1) // Play
			if (working == 1)
				return
			if (!account || account.money < 5)
				return
			if(!account.charge(5, transaction_purpose = "Bet", dest_name = name))
				return
			plays += 1
			working = 1
			icon_state = "slots-on"
			var/roll = rand(1,10000)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			spawn(30)
				if (roll == 1)
					visible_message("<b>[src]</b> says, 'JACKPOT! [usr.name] has won two hundred and fifty thousand credits!'")
					slotmachine_announcement.Announce("Congratulations to [usr.name] on winning the jackpot of two hundred and fifty thousand credits!", "Jackpot Winner")
					result = "JACKPOT! You win two hundred and fifty thousand credits!"
					resultlvl = "highlight"
					win_money(250000, 'sound/effects/engine_alert2.ogg')
				else if (roll > 1 && roll <= 10)
					visible_message("<b>[src]</b> says, 'Big Winner! [usr.name] has won five thousand credits!'")
					result = "Big Winner! You win five thousand credits!"
					resultlvl = "good"
					win_money(5000)
				else if (roll > 10 && roll <= 100)
					visible_message("<b>[src]</b> says, 'Winner! [usr.name] has won five hundred credits!'")
					result = "You win five hundred credits!"
					resultlvl = "good"
					win_money(500)
				else if (roll > 100 && roll <= 1000)
					result = "You win 5 credits!"
					resultlvl = "good"
					win_money(5)
				else
					result = "<span class='warning'>No luck!</span>"
					resultlvl = "average"
				working = 0
				icon_state = "slots-off"

/obj/machinery/slot_machine/proc/win_money(amt, sound='sound/machines/ping.ogg')
	if(sound)
		playsound(loc, sound, 50)

	if(!account)
		return
	account.money += amt

	var/datum/transaction/T = new()
	T.target_name = account.owner_name
	T.purpose = "Slot Winnings"
	T.amount = "[amt]"
	T.date = current_date_string
	T.time = worldtime2text()
	account.transaction_log.Add(T)