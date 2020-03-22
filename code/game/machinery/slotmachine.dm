/obj/machinery/slot_machine
	name = "slot machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/economy.dmi'
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
		if(istype(user.get_active_hand(), /obj/item/card/id))
			account = get_card_account(user.get_active_hand())
		else
			account = null
	ui_interact(user)

/obj/machinery/slot_machine/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "slotmachine.tmpl", name, 350, 200)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/slot_machine/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	data["working"] = working
	data["money"] = account ? account.money : null
	data["plays"] = plays
	data["result"] = result
	data["resultlvl"] = resultlvl
	return data

/obj/machinery/slot_machine/Topic(href, href_list)
	add_fingerprint(usr)

	if(href_list["ops"])
		if(text2num(href_list["ops"]))	// Play
			if(working)
				return
			if(!account || account.money < 10)
				return
			if(!account.charge(10, null, "Bet", "Slot Machine", "Slot Machine"))
				return
			plays++
			working = 1
			icon_state = "slots-on"
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			addtimer(CALLBACK(src, .proc/spin_slots, usr.name), 25)

/obj/machinery/slot_machine/proc/spin_slots(userName)
	switch(rand(1,4050))
		if(1) // .02%
			atom_say("JACKPOT! [userName] has won a MILLION CREDITS!")
			GLOB.event_announcement.Announce("Congratulations to [userName] on winning the Jackpot of ONE MILLION CREDITS!", "Jackpot Winner")
			result = "JACKPOT! You win one million credits!"
			resultlvl = "highlight"
			win_money(1000000, 'sound/goonstation/misc/airraid_loop.ogg')
		if(2 to 5) // .07%
			atom_say("Big Winner! [userName] has won a hundred thousand credits!")
			GLOB.event_announcement.Announce("Congratulations to [userName] on winning a hundred thousand credits!", "Big Winner")
			result = "Big Winner! You win a hundred thousand credits!"
			resultlvl = "good"
			win_money(100000, 'sound/goonstation/misc/klaxon.ogg')
		if(6 to 50) // 1.08%
			atom_say("Big Winner! [userName] has won ten thousand credits!")
			result = "You win ten thousand credits!"
			resultlvl = "good"
			win_money(10000, 'sound/goonstation/misc/klaxon.ogg')
		if(51 to 100) // 1.21%
			atom_say("Winner! [userName] has won a thousand credits!")
			result = "You win a thousand credits!"
			resultlvl = "good"
			win_money(1000, 'sound/goonstation/misc/bell.ogg')
		if(101 to 200) // 2.44%
			atom_say("Winner! [userName] has won a hundred credits!")
			result = "You win a hundred credits!"
			resultlvl = "good"
			win_money(100, 'sound/goonstation/misc/bell.ogg')
		if(201 to 300) // 2.44%
			atom_say("Winner! [userName] has won fifty credits!")
			result = "You win fifty credits!"
			resultlvl = "good"
			win_money(50)
		if(301 to 1000) // 17.26%
			atom_say("Winner! [userName] has won ten credits!")
			result = "You win ten credits!"
			resultlvl = "good"
			win_money(10)
		else // 75.31%
			result = "<span class='warning'>No luck!</span>"
			resultlvl = "average"
	working = 0
	icon_state = "slots-off"

/obj/machinery/slot_machine/proc/win_money(amt, sound='sound/machines/ping.ogg')
	if(sound)
		playsound(loc, sound, 55, 1)
	if(!account)
		return
	account.credit(amt, "Slot Winnings", "Slot Machine", account.owner_name)
