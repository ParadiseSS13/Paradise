/*

TODO:
give money an actual use (QM stuff, vending machines)
send money to people (might be worth attaching money to custom database thing for this, instead of being in the ID)
log transactions

*/

#define NO_SCREEN 0
#define CHANGE_SECURITY_LEVEL 1
#define TRANSFER_FUNDS 2
#define VIEW_TRANSACTION_LOGS 3
#define PRINT_DELAY 100

/obj/machinery/atm
	name = "Nanotrasen automatic teller machine"
	desc = "For all your monetary needs!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "atm"
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	var/obj/machinery/computer/account_database/linked_db
	var/datum/money_account/authenticated_account
	var/number_incorrect_tries = 0
	var/previous_account_number = 0
	var/max_pin_attempts = 3
	var/ticks_left_locked_down = 0
	var/ticks_left_timeout = 0
	var/machine_id = ""
	var/obj/item/card/held_card
	var/editing_security_level = 0
	var/view_screen = NO_SCREEN
	var/lastprint = 0 // Printer needs time to cooldown

/obj/machinery/atm/New()
	..()
	machine_id = "[station_name()] RT #[GLOB.num_financial_terminals++]"

/obj/machinery/atm/Initialize()
	..()
	reconnect_database()

/obj/machinery/atm/process()
	if(stat & NOPOWER)
		return

	if(linked_db && ((linked_db.stat & NOPOWER) || !linked_db.activated))
		linked_db = null
		authenticated_account = null
		visible_message("[bicon(src)]<span class='warning'>[src] buzzes rudely, \"Connection to remote database lost.\"</span>")
		SSnanoui.update_uis(src)

	if(ticks_left_timeout > 0)
		ticks_left_timeout--
		if(ticks_left_timeout <= 0)
			authenticated_account = null
	if(ticks_left_locked_down > 0)
		ticks_left_locked_down--
		if(ticks_left_locked_down <= 0)
			number_incorrect_tries = 0

	if(authenticated_account)
		var/turf/T = get_turf(src)
		if(istype(T) && locate(/obj/item/stack/spacecash) in T)
			var/cash_amount = 0
			for(var/obj/item/stack/spacecash/S in T)
				cash_amount += S.amount
			if(cash_amount)
				playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 50, 1)
				for(var/obj/item/stack/spacecash/S in T)
					S.use(S.amount)
				authenticated_account.charge(-cash_amount, null, "Credit deposit", machine_id, "Terminal")

/obj/machinery/atm/proc/reconnect_database()
	for(var/obj/machinery/computer/account_database/DB in GLOB.machines)
		if(DB.z == z && !(DB.stat & NOPOWER) && DB.activated)
			linked_db = DB
			break

/obj/machinery/atm/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card))
		if(!powered())
			return

		if(!held_card)
			user.drop_item()
			I.forceMove(src)
			held_card = I
			if(authenticated_account && held_card.associated_account_number != authenticated_account.account_number)
				authenticated_account = null
			SSnanoui.update_uis(src)
	else if(authenticated_account)
		if(istype(I, /obj/item/stack/spacecash))
			//consume the money
			if(!powered())
				return
			var/obj/item/stack/spacecash/C = I
			playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 50, 1)

			authenticated_account.credit(C.amount, "Credit deposit", machine_id, authenticated_account.owner_name)

			to_chat(user, "<span class='info'>You insert [C] into [src].</span>")
			SSnanoui.update_uis(src)
			C.use(C.amount)
	else
		return ..()

/obj/machinery/atm/attack_hand(mob/user)
	if(..())
		return 1
	if(issilicon(user))
		to_chat(user, "<span class='warning'>Artificial unit recognized. Artificial units do not currently receive monetary compensation, as per Nanotrasen regulation #1005.</span>")
		return
	if(!linked_db)
		reconnect_database()
	ui_interact(user)

/obj/machinery/atm/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atm/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "atm.tmpl", name, 550, 650)
		ui.open()

/obj/machinery/atm/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	data["src"] = UID()
	data["view_screen"] = view_screen
	data["machine_id"] = machine_id
	data["held_card_name"] = held_card ? held_card.name : "------"
	data["ticks_left_locked_down"] = ticks_left_locked_down
	data["linked_db"] = linked_db

	data["authenticated_account"] = authenticated_account
	if(authenticated_account)
		data["owner_name"] = authenticated_account.owner_name
		data["money"] = authenticated_account.money
		data["security_level"] = authenticated_account.security_level

		var/list/trx = list()
		for(var/datum/transaction/T in authenticated_account.transaction_log)
			trx[++trx.len] = list(
				"date" = T.date,
				"time" = T.time,
				"target_name" = T.target_name,
				"purpose" = T.purpose,
				"amount" = T.amount,
				"source_terminal" = T.source_terminal)
		data["transaction_log"] = trx

	return data

/obj/machinery/atm/Topic(href, list/href_list)
	if(href_list["choice"])
		switch(href_list["choice"])
			if("transfer")
				if(authenticated_account && linked_db)
					var/transfer_amount = text2num(href_list["funds_amount"])
					if(transfer_amount <= 0)
						alert("That is not a valid amount.")
					else if(transfer_amount <= authenticated_account.money)
						var/target_account_number = text2num(href_list["target_acc_number"])
						var/transfer_purpose = href_list["purpose"]
						if(linked_db.charge_to_account(target_account_number, authenticated_account, transfer_purpose, machine_id, transfer_amount))
							to_chat(usr, "[bicon(src)]<span class='info'>Funds transfer successful.</span>")
						else
							to_chat(usr, "[bicon(src)]<span class='warning'>Funds transfer failed.</span>")

					else
						to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")
			if("view_screen")
				view_screen = text2num(href_list["view_screen"])
			if("change_security_level")
				if(authenticated_account)
					var/new_sec_level = max( min(text2num(href_list["new_security_level"]), 2), 0)
					authenticated_account.security_level = new_sec_level
			if("attempt_auth")
				if(linked_db)
					if(!ticks_left_locked_down)
						var/tried_account_num = text2num(href_list["account_num"])
						if(!tried_account_num && held_card)
							tried_account_num = held_card.associated_account_number
						var/tried_pin = text2num(href_list["account_pin"])

						authenticated_account = attempt_account_access(tried_account_num, tried_pin, held_card && held_card.associated_account_number == tried_account_num ? 2 : 1)
						if(!authenticated_account)
							number_incorrect_tries++
							if(previous_account_number == tried_account_num)
								if(number_incorrect_tries > max_pin_attempts)
									//lock down the atm
									ticks_left_locked_down = 30
									playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)

									//create an entry in the account transaction log
									var/datum/money_account/failed_account = linked_db.get_account(tried_account_num)
									if(failed_account)
										var/datum/transaction/T = new()
										T.target_name = failed_account.owner_name
										T.purpose = "Unauthorised login attempt"
										T.source_terminal = machine_id
										T.date = GLOB.current_date_string
										T.time = station_time_timestamp()
										failed_account.transaction_log.Add(T)
								else
									to_chat(usr, "[bicon(src)]<span class='warning'>Incorrect pin/account combination entered, [max_pin_attempts - number_incorrect_tries] attempts remaining.</span>")
									previous_account_number = tried_account_num
									playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 1)
							else
								to_chat(usr, "[bicon(src)]<span class='warning'>Incorrect pin/account combination entered.</span>")
								number_incorrect_tries = 0
						else
							playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
							ticks_left_timeout = 120
							view_screen = NO_SCREEN

							//create a transaction log entry
							var/datum/transaction/T = new()
							T.target_name = authenticated_account.owner_name
							T.purpose = "Remote terminal access"
							T.source_terminal = machine_id
							T.date = GLOB.current_date_string
							T.time = station_time_timestamp()
							authenticated_account.transaction_log.Add(T)
							to_chat(usr, "[bicon(src)]<span class='notice'>Access granted. Welcome user '[authenticated_account.owner_name].'</span>")
						previous_account_number = tried_account_num
			if("withdrawal")
				var/amount = max(text2num(href_list["funds_amount"]),0)
				if(amount <= 0)
					alert("That is not a valid amount.")
				else if(authenticated_account && amount > 0)
					if(amount <= authenticated_account.money)
						playsound(src, 'sound/machines/chime.ogg', 50, 1)

						//remove the money
						if(amount > 10000) // prevent crashes
							to_chat(usr, "<span class='notice'>The ATM's screen flashes, 'Maximum single withdrawl limit reached, defaulting to 10,000.'</span>")
							amount = 10000
						withdraw_arbitrary_sum(amount)
						authenticated_account.charge(amount, null, "Credit withdrawal", machine_id, authenticated_account.owner_name)
					else
						to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")
			if("balance_statement")
				if(authenticated_account)
					if(world.timeofday < lastprint + PRINT_DELAY)
						to_chat(usr, "<span class='notice'>The [name] flashes an error on its display.</span>")
						return
					lastprint = world.timeofday
					playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
					var/obj/item/paper/R = new(loc)
					R.name = "Account balance: [authenticated_account.owner_name]"
					R.info = {"<b>NT Automated Teller Account Statement</b><br><br>
						<i>Account holder:</i> [authenticated_account.owner_name]<br>
						<i>Account number:</i> [authenticated_account.account_number]<br>
						<i>Balance:</i> $[authenticated_account.money]<br>
						<i>Date and time:</i> [station_time_timestamp()], [GLOB.current_date_string]<br><br>
						<i>Service terminal ID:</i> [machine_id]<br>"}

					//stamp the paper
					var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
					stampoverlay.icon_state = "paper_stamp-cent"
					if(!R.stamped)
						R.stamped = new()
					R.stamped += /obj/item/stamp
					R.overlays += stampoverlay
					R.stamps += "<HR><i>This paper has been stamped by the Automatic Teller Machine.</i>"

				playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 50, 1)
			if("insert_card")
				if(held_card)
					held_card.forceMove(loc)
					authenticated_account = null
					if(ishuman(usr) && !usr.get_active_hand())
						usr.put_in_hands(held_card)
					held_card = null
				else
					var/obj/item/I = usr.get_active_hand()
					if(istype(I, /obj/item/card/id))
						usr.drop_item()
						I.forceMove(src)
						held_card = I
			if("logout")
				authenticated_account = null

	SSnanoui.update_uis(src)
	return 1

//create the most effective combination of notes to make up the requested amount
/obj/machinery/atm/proc/withdraw_arbitrary_sum(arbitrary_sum)
	new /obj/item/stack/spacecash(get_step(get_turf(src), turn(dir, 180)), arbitrary_sum)
