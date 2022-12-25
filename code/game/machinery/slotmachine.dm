/obj/machinery/economy/slot_machine
	name = "slot machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots-off"
	anchored = TRUE
	density = TRUE

	var/plays = 0
	var/working = FALSE
	var/result
	var/resultlvl

	var/datum/money_account/user_account

/obj/machinery/economy/slot_machine/Initialize(mapload)
	. = ..()
	reconnect_database()

/obj/machinery/economy/slot_machine/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/machinery/economy/slot_machine/proc/set_user_account(datum/money_account/account)
	if(user_account)
		if(user_account == account)
			return
		clear_user_account()
	user_account = account
	if(user_account)
		RegisterSignal(account, COMSIG_PARENT_QDELETING, PROC_REF(clear_user_account))

/obj/machinery/economy/slot_machine/proc/clear_user_account()
	UnregisterSignal(user_account, COMSIG_PARENT_QDELETING)
	user_account = null

/obj/machinery/economy/slot_machine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SlotMachine", name, 350, 200, master_ui, state)
		ui.open()

/obj/machinery/economy/slot_machine/ui_data(mob/user)
	var/list/data = list()
	// Get account
	set_user_account(user.get_worn_id_account())

	// Send data
	data["working"] = working
	data["money"] = user_account?.credit_balance
	data["plays"] = plays
	data["result"] = result
	data["resultlvl"] = resultlvl
	return data

/obj/machinery/economy/slot_machine/ui_act(action, params)
	if(..())
		return
	add_fingerprint(usr)

	if(action == "spin")
		if(working)
			return
		if(!user_account || user_account.credit_balance < 10)
			return
		if(!account_database.charge_account(user_account, 10, "Slot Machine Charge", "DonkBook Betting", FALSE, TRUE))
			return //we want to surpress transaction logs here in-case someone uses the slot machine 100+ times
		account_database.credit_account(account_database.vendor_account, 10, "Slot Machine Charge", "DonkBook Betting", TRUE)
		plays++
		working = TRUE
		icon_state = "slots-on"
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
		addtimer(CALLBACK(src, PROC_REF(spin_slots), usr.name), 25)

/obj/machinery/economy/slot_machine/proc/spin_slots(userName)
	switch(rand(1, 5000))
		if(1)
			atom_say("JACKPOT! [userName] has won two thousand credits!")
			GLOB.minor_announcement.Announce("Congratulations to [userName] on winning the Jackpot of TWO THOUSAND CREDITS!", "Jackpot Winner")
			result = "JACKPOT! You win two thousand credits!"
			resultlvl = "teal"
			win_money(2000, 'sound/goonstation/misc/airraid_loop.ogg')
		if(2 to 20)
			atom_say("Big Winner! [userName] has won two hundred credits!")
			result = "You win a two hundred credits!"
			resultlvl = "green"
			win_money(200, 'sound/goonstation/misc/klaxon.ogg')
		if(21 to 100)
			atom_say("Winner! [userName] has won a hundred credits!")
			result = "You win a hundred credits!"
			resultlvl = "green"
			win_money(100, 'sound/goonstation/misc/bell.ogg')
		if(101 to 500)
			atom_say("Winner! [userName] has won forty credits!")
			result = "You win forty credits!"
			resultlvl = "green"
			win_money(40)
		if(501 to 1000)
			atom_say("Winner! [userName] has won ten credits!")
			result = "You win ten credits!"
			resultlvl = "green"
			win_money(10)
		else
			result = "No luck!"
			resultlvl = "orange"
	working = FALSE
	icon_state = "slots-off"
	SStgui.update_uis(src) // Push a UI update

/obj/machinery/economy/slot_machine/proc/win_money(amount, sound = 'sound/machines/ping.ogg')
	if(sound)
		playsound(loc, sound, 55, 1)
	if(!user_account)
		return
	account_database.charge_account(account_database.vendor_account, amount, "Slot Machine Payout", "DonkBook Betting", TRUE, FALSE)
	account_database.credit_account(user_account, amount, "Slot Machine Winnings Deposit", "DonkBook Betting", FALSE)

/obj/machinery/economy/slot_machine/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)
