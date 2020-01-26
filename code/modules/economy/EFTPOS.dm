/obj/item/eftpos
	name = "EFTPOS scanner"
	desc = "Swipe your ID card to make purchases electronically."
	icon = 'icons/obj/device.dmi'
	icon_state = "eftpos"
	var/machine_name = ""
	var/transaction_locked = 0
	var/transaction_paid = 0
	var/transaction_amount = 0
	var/transaction_purpose = "Default charge"
	var/access_code = 0
	var/obj/machinery/computer/account_database/linked_db
	var/datum/money_account/linked_account

/obj/item/eftpos/New()
	..()
	machine_name = "[station_name()] EFTPOS #[num_financial_terminals++]"
	access_code = rand(1111,111111)
	reconnect_database()
	spawn(0)
		print_reference()

	//by default, connect to the station account
	//the user of the EFTPOS device can change the target account though, and no-one will be the wiser (except whoever's being charged)
	linked_account = station_account

/obj/item/eftpos/proc/print_reference()
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	var/obj/item/paper/R = new(loc)
	R.name = "Reference: [machine_name]"
	R.info = {"<b>[machine_name] reference</b><br><br>
		Access code: [access_code]<br><br>
		<b>Do not lose or misplace this code.</b><br>"}
	//stamp the paper
	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	stampoverlay.icon_state = "paper_stamp-cent"
	if(!R.stamped)
		R.stamped = new
	R.stamped += /obj/item/stamp
	R.overlays += stampoverlay
	R.stamps += "<HR><i>This paper has been stamped by the EFTPOS device.</i>"
	var/obj/item/smallDelivery/D = new(R.loc)
	R.forceMove(D)
	D.wrapped = R
	D.name = "small parcel - 'EFTPOS access code'"

/obj/item/eftpos/proc/reconnect_database()
	var/turf/location = get_turf(src)
	if(!location)
		return

	for(var/obj/machinery/computer/account_database/DB in GLOB.machines)
		if(DB.z == location.z)
			linked_db = DB
			break

/obj/item/eftpos/attack_self(mob/user)
	ui_interact(user)

/obj/item/eftpos/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/card))
		//attempt to connect to a new db, and if that doesn't work then fail
		if(!linked_db)
			reconnect_database()
		if(linked_db)
			if(linked_account)
				scan_card(O, user)
				SSnanoui.update_uis(src)
			else
				to_chat(user, "[bicon(src)]<span class='warning'>Unable to connect to linked account.</span>")
		else
			to_chat(user, "[bicon(src)]<span class='warning'>Unable to connect to accounts database.</span>")
	else
		return ..()

/obj/item/eftpos/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "eftpos.tmpl", name, 790, 310)
		ui.open()

/obj/item/eftpos/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["machine_name"] = machine_name
	data["transaction_locked"] = transaction_locked
	data["transaction_paid"] = transaction_paid
	data["transaction_purpose"] = transaction_purpose
	data["transaction_amount"] = transaction_amount
	data["linked_account"] = linked_account ? linked_account.owner_name : null
	return data

/obj/item/eftpos/Topic(href, list/href_list)
	if(..())
		return 1

	if(href_list["choice"])
		switch(href_list["choice"])
			if("change_code")
				var/attempt_code = input("Re-enter the current EFTPOS access code", "Confirm old EFTPOS code") as num
				if(attempt_code == access_code)
					var/trycode = input("Enter a new access code for this device (4-6 digits, numbers only)", "Enter new EFTPOS code") as num
					if(trycode >= 1000 && trycode <= 999999)
						access_code = trycode
					else
						alert("That is not a valid code!")
					print_reference()
				else
					to_chat(usr, "[bicon(src)]<span class='warning'>Incorrect code entered.</span>")
			if("link_account")
				if(!linked_db)
					reconnect_database()
				if(linked_db)
					var/attempt_account_num = input("Enter account number to pay EFTPOS charges into", "New account number") as num
					var/attempt_pin = input("Enter pin code", "Account pin") as num
					linked_account = attempt_account_access(attempt_account_num, attempt_pin, 1)
				else
					to_chat(usr, "[bicon(src)]<span class='warning'>Unable to connect to accounts database.</span>")
			if("trans_purpose")
				var/purpose = clean_input("Enter reason for EFTPOS transaction", "Transaction purpose", transaction_purpose)
				if(purpose)
					transaction_purpose = purpose
			if("trans_value")
				var/try_num = input("Enter amount for EFTPOS transaction", "Transaction amount", transaction_amount) as num
				if(try_num < 0)
					alert("That is not a valid amount!")
				else
					transaction_amount = try_num
			if("toggle_lock")
				if(transaction_locked)
					var/attempt_code = input("Enter EFTPOS access code", "Reset Transaction") as num
					if(attempt_code == access_code)
						transaction_locked = 0
						transaction_paid = 0
				else if(linked_account)
					transaction_locked = 1
				else
					to_chat(usr, "[bicon(src)]<span class='warning'>No account connected to send transactions to.</span>")
			if("scan_card")
				//attempt to connect to a new db, and if that doesn't work then fail
				if(!linked_db)
					reconnect_database()
				if(linked_db && linked_account)
					var/obj/item/I = usr.get_active_hand()
					if(istype(I, /obj/item/card))
						scan_card(I, usr)
				else
					to_chat(usr, "[bicon(src)]<span class='warning'>Unable to link accounts.</span>")
			if("reset")
				//reset the access code - requires HoP/captain access
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/card))
					var/obj/item/card/id/C = I
					if(access_cent_commander in C.access || access_hop in C.access || access_captain in C.access)
						access_code = 0
						to_chat(usr, "[bicon(src)]<span class='info'>Access code reset to 0.</span>")
				else if(istype(I, /obj/item/card/emag))
					access_code = 0
					to_chat(usr, "[bicon(src)]<span class='info'>Access code reset to 0.</span>")

	SSnanoui.update_uis(src)
	return 1

/obj/item/eftpos/proc/scan_card(obj/item/card/I, mob/user)
	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/C = I
		visible_message("<span class='info'>[user] swipes a card through [src].</span>")

		if(!transaction_locked || transaction_paid)
			return

		if(!linked_account)
			to_chat(user, "[bicon(src)]<span class='warning'>EFTPOS is not connected to an account.</span>")
			return

		var/confirm = alert("Are you sure you want to pay $[transaction_amount] to Account: [linked_account.owner_name] ", "Confirm transaction", "Yes", "No")
		if(confirm == "No")
			return
		var/attempt_pin = input("Enter pin code", "EFTPOS transaction") as num
		var/datum/money_account/D = attempt_account_access(C.associated_account_number, attempt_pin, 2)

		if(!D)
			to_chat(user, "[bicon(src)]<span class='warning'>Unable to access account. Check security settings and try again.</span>")

		if(transaction_amount > D.money)
			to_chat(user, "[bicon(src)]<span class='warning'>You don't have that much money!</span>")
			return

		var/transSuccess = D.charge(transaction_amount, linked_account, transaction_purpose, machine_name, D.owner_name)
		if(transSuccess == TRUE)
			playsound(src, 'sound/machines/chime.ogg', 50, 1)
			visible_message("[bicon(src)] The [src] chimes.")
			transaction_paid = 1

	else
		..()

	//emag?
