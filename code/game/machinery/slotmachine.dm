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
	ui_interact(user)

/obj/machinery/slot_machine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SlotMachine", name, 350, 200, master_ui, state)
		ui.open()

/obj/machinery/slot_machine/ui_data(mob/user)
	var/list/data = list()
	// Get account
	account = user.get_worn_id_account()
	if(!account)
		if(istype(user.get_active_hand(), /obj/item/card/id))
			account = get_card_account(user.get_active_hand())
		else
			account = null


	// Send data
	data["working"] = working
	data["money"] = account ? account.money : null
	data["plays"] = plays
	data["result"] = result
	data["resultlvl"] = resultlvl
	return data

/obj/machinery/slot_machine/ui_act(action, params)
	if(..())
		return
	add_fingerprint(usr)

	if(action == "spin")
		if(working)
			return
		if(!account || account.money < 50)
			return
		if(!account.charge(50, null, "Bet", "Slot Machine", "Slot Machine"))
			return
		plays++
		working = TRUE
		icon_state = "slots-on"
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
		addtimer(CALLBACK(src, .proc/spin_slots, usr.name), 25)

/obj/machinery/slot_machine/proc/spin_slots(userName)
	switch(rand(1,5000))
		if(1)
			atom_say("JACKPOT! [userName] has won ten thousand credits!")
			GLOB.event_announcement.Announce("Congratulations to [userName] on winning the Jackpot of TEN THOUSAND CREDITS!", "Jackpot Winner")
			result = "JACKPOT! You win ten thousand credits!"
			resultlvl = "teal"
			win_money(10000, 'sound/goonstation/misc/airraid_loop.ogg')
		if(2 to 20)
			atom_say("Big Winner! [userName] has won a thousand credits!")
			result = "You win a thousand credits!"
			resultlvl = "green"
			win_money(1000, 'sound/goonstation/misc/klaxon.ogg')
		if(21 to 100)
			atom_say("Winner! [userName] has won five hundred credits!")
			result = "You win five hundred credits!"
			resultlvl = "green"
			win_money(500, 'sound/goonstation/misc/bell.ogg')
		if(101 to 500)
			atom_say("Winner! [userName] has won two hundred credits!")
			result = "You win two hundred credits!"
			resultlvl = "green"
			win_money(200)
		if(501 to 1000)
			atom_say("Winner! [userName] has won fifty credits!")
			result = "You win fifty credits!"
			resultlvl = "green"
			win_money(50)
		else
			result = "No luck!"
			resultlvl = "orange"
	working = FALSE
	icon_state = "slots-off"
	SStgui.update_uis(src) // Push a UI update

/obj/machinery/slot_machine/proc/win_money(amt, sound='sound/machines/ping.ogg')
	if(sound)
		playsound(loc, sound, 55, 1)
	if(!account)
		return
	account.credit(amt, "Slot Winnings", "Slot Machine", account.owner_name)

/obj/machinery/slot_machine/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)
