/obj/machinery/economy/slot_machine
	name = "slot machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots-off"

	var/plays = 0
	var/working = FALSE
	var/result
	var/resultlvl

	var/datum/money_account/user_account

	/// Used to handle bolting/unbolting the emagged machine while someone is using it
	var/emagged_game_in_progress = FALSE
	/// The %chance of winning money and resetting the emagged state
	var/emagged_win_chance = 1

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

/obj/machinery/economy/slot_machine/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/economy/slot_machine/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlotMachine", name)
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

/obj/machinery/economy/slot_machine/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	add_fingerprint(ui.user)

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
		playsound(loc, 'sound/machines/ding.ogg', 50, 1)
		addtimer(CALLBACK(src, PROC_REF(spin_slots), ui.user.name), 25)

		if(emagged)
			emagged_spinning(ui.user)

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
	// This prevents the emagged machine to be moved while someone is playing on it.
	if(emagged_game_in_progress)
		return
	default_unfasten_wrench(user, I)

/*
	* Emag behaviour below. When the machine is emagged, it'll stun and anchor its user, spin them, then throw them away.
	* With a chance of "emagged_win_chance", the machine resets its emagged state and throws money at the user.
*/
/obj/machinery/economy/slot_machine/emag_act(user)
	if(emagged)
		to_chat(user, "<span class='notice'>[src] is unresponsive. It is probably already modified.</span>")
		return
	playsound(loc, 'sound/effects/sparks4.ogg', 75, 1)
	emagged = TRUE
	to_chat(user, "<span class='notice'>You engage the reverse-gripping mechanism on the machine's handle.</span>")
	log_game("[key_name(user)] emagged [src]")
	return TRUE

/// The spinning and throwing away is handled here, with a possible call to winning
/obj/machinery/economy/slot_machine/proc/emagged_spinning(mob/living/user)
	to_chat(user, "<span class='danger'>As you grip the handle of the machine, it grips back at you, and starts to wildly spin you around!</span>")
	user.SpinAnimation(speed = 2, loops = 6)
	emagged_game_in_progress = TRUE

	// Make sure the machine is anchored to avoid people cheesing it
	if(!anchored)
		atom_say("Deploying safety bolts.")
		anchored = TRUE

	// Stun them, there is no escape from this unless you get teleported
	user.anchored = TRUE
	user.SetStunned(1.2 SECONDS, TRUE)

	// No cheesing with buckling ourselves, this spinning is too fast for seatbelts
	if(user.buckled)
		user.unbuckle(force = TRUE)

	// Check if the machine and the user are still next to each other
	if(!do_after(user, delay = 1.2 SECONDS, target = src, use_default_checks = FALSE))
		user.anchored = FALSE
		emagged_game_in_progress = FALSE
		return

	// Find the right direction and throw the user away from the machine
	to_chat(user, "<span class='userdanger'>The handle suddenly lets you go!</span>")
	user.anchored = FALSE
	var/user_direction = get_dir(src, user)
	var/turf/throw_direction = get_edge_target_turf(user, user_direction)
	user.throw_at(throw_direction, 6, 10)

	// Reset the machine
	emagged_game_in_progress = FALSE

	// Are we the lucky winner?
	if(prob(emagged_win_chance))
		addtimer(CALLBACK(src, PROC_REF(emagged_winning), user), 1 SECONDS)

/// With a chance of "emagged_win_chance", we win some money and reset the machine to a non-emagged state
/obj/machinery/economy/slot_machine/proc/emagged_winning(user)
	// Notify nearby people
	atom_say("ERROR ERROR ERROR. Entering safe mode. Disabling reverse-gripping mechanism!")
	playsound(loc, 'sound/machines/bell.ogg', 55, 1)

	// This resets us back to normal
	emagged = FALSE

	// Reward the winner
	var/obj/item/reward_to_throw = new /obj/item/stack/spacecash/c100(get_turf(src))
	reward_to_throw.throw_at(user, 6, 10)
