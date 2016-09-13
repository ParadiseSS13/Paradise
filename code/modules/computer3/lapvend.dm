/obj/machinery/lapvend
	name = "laptop vendor"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "robotics"
	layer = 2.9
	anchored = 1
	density = 1
	var/datum/browser/popup = null
	var/obj/machinery/computer3/laptop/vended/newlap = null
	var/obj/item/device/laptop/relap = null
	var/vendmode = 0


	var/cardreader = 0
	var/floppy = 0
	var/radionet = 0
	var/camera = 0
	var/network = 0
	var/power = 0


/obj/machinery/lapvend/New()
	..()
	spawn(4)
		power_change()
		return
	return


/obj/machinery/lapvend/blob_act()
	if(prob(50))
		spawn(0)
			qdel(src)
		return

	return


/obj/machinery/lapvend/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(vendmode == 1)
		if(istype(W, /obj/item/weapon/card))
			var/obj/item/weapon/card/I = W
			scan_card(I)
			vendmode = 0
	if(vendmode == 3)
		if(istype(W,/obj/item/weapon/card))
			var/obj/item/weapon/card/I = W
			reimburse(I)
			vendmode = 0
	if(vendmode == 0)
		if(istype(W, /obj/item/device/laptop))
			var/obj/item/device/laptop/L = W
			relap = L
			calc_reimburse(L)
			usr.drop_item()
			L.loc = src
			vendmode = 3
			to_chat(usr, "<span class='notice'>You slot your [L.name] into \The [src.name]</span>")
	else
		..()


/obj/machinery/lapvend/attack_hand(mob/user as mob)
	user.set_machine(src)
	var/vendorname = (src.name)  //import the machine's name
	var/dat = "<TT><center><b>[vendorname]</b></center><hr /><br>" //display the name, and added a horizontal rule
	if(vendmode == 0)
		dat += "<center><b>Please choose your laptop customization options</b></center><br>"
		dat += "<center>Your comptuer will automatically be loaded with any programs you can use after the transaction is complete."
		dat += "<center><b>Some programs will require additional components to be installed!</center></b><hr /><br>"
		dat += "<center><b>HDD (Required)</b> : Added</center><br>"
		dat += "<center><b>Card Reader</b> : <A href='?src=[UID()];choice=single_add'>Single (50)</a> | <A href='?src=[UID()];choice=dual_add'>Dual (125)</a><br>"
		dat += "<center><b>Floppy Drive</b>: <A href='?src=[UID()];choice=floppy_add'>Add (50)</a><br>"
		dat += "<center><b>Radio Network card</b> <A href='?src=[UID()];choice=radio_add'>Add (50)</a><br>"
		dat += "<center><b>Camera Card</b> <A href='?src=[UID()];choice=camnet_add'>Add (100)</a><br>"
		dat += "<center><b> Network card</b> <A href='?src=[UID()];choice=area_add'>Area (75)</a> <A href='?src=[UID()];choice=prox_add'>Adjacent (50)</a><A href='?src=[UID()];choice=cable_add'>Powernet (25)</a><br>"
		dat += "<hr /><center> Power source upgrade</center> <A href='?src=[UID()];choice=high_add'>Extended (175)</a> <A href='?src=[UID()];choice=super_add'>Unreal (250)</a>"

	if(vendmode == 0 || vendmode == 1)
		dat += "<hr /><br><center>Cart</center><br>"
		dat += "<b>Total: [total()]</b><br>"
		if(cardreader == 1)
			dat += "<A href='?src=[UID()];choice=single_rem'>Card Reader: (single) (50)</a><br>"
		else if(cardreader == 2)
			dat += "<A href='?src=[UID()];choice=dual_rem'>Card Reader: (double) (125)</a><br>"
		else
			dat += "Card Reader: None<br>"
		if(floppy == 0)
			dat += "Floppy Drive: None<br>"
		else
			dat += "<A href='?src=[UID()];choice=floppy_rem'>Floppy Drive: Added (50)</a><br>"
		if(radionet == 1)
			dat += "<A href='?src=[UID()];choice=radio_rem'>Radio Card: Added (50)</a><br>"
		else
			dat += "Radio Card: None<br>"
		if(camera == 1)
			dat += "<A href='?src=[UID()];choice=camnet_rem'>Camera Card: Added (100)</a><br>"
		else
			dat += "Camera Card: None<br>"
		if(network == 1)
			dat += "<A href='?src=[UID()];choice=area_rem'>Network card: Area (75)</a><br>"
		else if(network == 2)
			dat += "<A href='?src=[UID()];choice=prox_rem'>Network card: Adjacent (50)</a><br>"
		else if(network == 3)
			dat += "<A href='?src=[UID()];choice=cable_rem'>Network card: Powernet (25)</a><br>"
		else
			dat += "Network card: None<br>"
		if(power == 0)
			dat += "Power source: Regular<br>"
		else if(power == 1)
			dat += "<A href='?src=[UID()];choice=high_rem'>Power source: Extended (175)</a><br>"
		else
			dat += "<A href='?src=[UID()];choice=super_rem'>Power source: Unreal (250)</a><br>"

	if(vendmode == 0)
		dat += "<br><A href='?src=[UID()];choice=vend'>Vend Laptop</a>"

	if(vendmode == 1)
		dat += "Please swipe your card to complete the transaction"

	if(vendmode == 3)
		dat += "Please swipe your card to finish returning your computer<br>"
		dat += "<a href='?src=[UID()];choice=cancel'>Cancel</a>"




	popup = new(user, "lapvend", name, 450, 500)
	popup.set_content(dat)
	popup.open()
	return


/obj/machinery/lapvend/Topic(href, href_list)
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_machine(src)
	switch(href_list["choice"])
		if("single_add")
			cardreader = 1
		if("dual_add")
			cardreader = 2
		if("floppy_add")
			floppy = 1
		if("radio_add")
			radionet = 1
		if("camnet_add")
			camera = 1
		if("area_add")
			network = 1
		if("prox_add")
			network = 2
		if("cable_add")
			network = 3
		if("high_add")
			power = 1
		if("super_add")
			power = 2

		if("single_rem" || "dual_rem")
			cardreader = 0
		if("floppy_rem")
			floppy = 0
		if("radio_rem")
			radionet = 0
		if("camnet_rem")
			camera = 0
		if("area_rem" || "prox_rem" || "cable_rem")
			network = 0
		if("high_rem" || "super_rem")
			power = 0

		if("vend")
			vendmode = 1

		if("cancel")
			relap.loc = src.loc
			relap = null
			vendmode = 0

	src.updateUsrDialog()
	return


/obj/machinery/lapvend/proc/vend()
	if(cardreader > 0)
		if(cardreader == 1)
			newlap.spawn_parts += (/obj/item/part/computer/cardslot)
		else
			newlap.spawn_parts += (/obj/item/part/computer/cardslot/dual)
	if(floppy == 1)
		newlap.spawn_parts += (/obj/item/part/computer/storage/removable)
	if(radionet == 1)
		newlap.spawn_parts += (/obj/item/part/computer/networking/radio)
	if(camera == 1)
		newlap.spawn_parts += (/obj/item/part/computer/networking/cameras)
	if(network == 1)
		newlap.spawn_parts += (/obj/item/part/computer/networking/area)
	if(network == 2)
		newlap.spawn_parts += (/obj/item/part/computer/networking/prox)
	if(network == 3)
		newlap.spawn_parts += (/obj/item/part/computer/networking/cable)
	if(power == 1)
		qdel(newlap.battery)
		newlap.battery = new /obj/item/weapon/stock_parts/cell/high(newlap)
	if(power == 2)
		qdel(newlap.battery)
		newlap.battery = new /obj/item/weapon/stock_parts/cell/super(newlap)

	newlap.spawn_parts()

/obj/machinery/lapvend/proc/scan_card(var/obj/item/weapon/card/I)
	if(istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = I
		visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
		if(vendor_account)
			var/datum/money_account/D = attempt_account_access_nosec(C.associated_account_number)
			if(D && D.security_level)
				var/attempt_pin = input("Enter pin code", "Vendor transaction") as num
				D = attempt_account_access(C.associated_account_number, attempt_pin, 2)
			if(D)
				var/transaction_amount = total()
				if(transaction_amount <= D.money)

					//transfer the money
					D.money -= transaction_amount
					vendor_account.money += transaction_amount

					//Transaction logs
					var/datum/transaction/T = new()
					T.target_name = "[vendor_account.owner_name] (via [src.name])"
					T.purpose = "Purchase of Laptop"
					if(transaction_amount > 0)
						T.amount = "([transaction_amount])"
					else
						T.amount = "[transaction_amount]"
					T.source_terminal = src.name
					T.date = current_date_string
					T.time = worldtime2text()
					D.transaction_log.Add(T)
					//
					T = new()
					T.target_name = D.owner_name
					T.purpose = "Purchase of Laptop"
					T.amount = "[transaction_amount]"
					T.source_terminal = src.name
					T.date = current_date_string
					T.time = worldtime2text()
					vendor_account.transaction_log.Add(T)

					newlap = new /obj/machinery/computer3/laptop/vended(src.loc)

					choose_progs(C)
					vend()
					popup.close()
					newlap.close_computer()
					newlap = null
					cardreader = 0
					floppy = 0
					radionet = 0
					camera = 0
					network = 0
					power = 0
				else
					to_chat(usr, "[bicon(src)]<span class='warning'>You don't have that much money!</span>")
			else
				to_chat(usr, "[bicon(src)]<span class='warning'>Unable to access account. Check security settings and try again.</span>")
		else
			to_chat(usr, "[bicon(src)]<span class='warning'>Unable to access vendor account. Please record the machine ID and call CentComm Support.</span>")

/obj/machinery/lapvend/proc/total()
	var/total = 0

	if(cardreader == 1)
		total += 50
	if(cardreader == 2)
		total += 125
	if(floppy == 1)
		total += 50
	if(radionet == 1)
		total += 50
	if(camera == 1)
		total += 100
	if(network == 1)
		total += 75
	if(network == 2)
		total += 50
	if(network == 3)
		total += 25
	if(power == 1)
		total += 175
	if(power == 2)
		total += 250

	return total

/obj/machinery/lapvend/proc/choose_progs(var/obj/item/weapon/card/id/C)
	if((access_security in C.access) || (access_forensics_lockers in C.access))
		newlap.spawn_files += (/datum/file/program/secure_data)
		newlap.spawn_files += (/datum/file/camnet_key)
		newlap.spawn_files += (/datum/file/camnet_key/researchoutpost)
		newlap.spawn_files += (/datum/file/camnet_key/miningoutpost)
		newlap.spawn_files += (/datum/file/camnet_key/telecomms)
		newlap.spawn_files += (/datum/file/program/security)
	if(access_armory in C.access)
		newlap.spawn_files += (/datum/file/program/prisoner)
	if(access_atmospherics in C.access)
		newlap.spawn_files += (/datum/file/program/atmos_alert)
	if(access_change_ids in C.access)
		newlap.spawn_files += (/datum/file/program/card_comp)
	if(access_heads in C.access)
		newlap.spawn_files += (/datum/file/program/communications)
	if((access_medical in C.access) || (access_forensics_lockers in C.access)) //Gives detective the medical records program, but not the crew monitoring one.
		newlap.spawn_files += (/datum/file/program/med_data)
		if(access_medical in C.access)
			newlap.spawn_files += (/datum/file/program/crew)
	if(access_engine in C.access)
		newlap.spawn_files += (/datum/file/program/powermon)
	if(access_research in C.access)
		newlap.spawn_files += (/datum/file/camnet_key/researchoutpost)
		newlap.spawn_files += (/datum/file/camnet_key/research)
		newlap.spawn_files += (/datum/file/camnet_key/anomalyisolation)
		newlap.spawn_files += (/datum/file/camnet_key/toxins)
		newlap.spawn_files += (/datum/file/camnet_key/telepad)
/*	if(access_rd in C.access)
		newlap.spawn_files += (/datum/file/program/borg_control) */
	if(access_cent_specops in C.access)
		newlap.spawn_files += (/datum/file/camnet_key/ert)
		newlap.spawn_files += (/datum/file/camnet_key/centcom)
		newlap.spawn_files += (/datum/file/camnet_key/thunderdome)
	newlap.spawn_files += (/datum/file/program/arcade)
	newlap.spawn_files += (/datum/file/camnet_key/entertainment)
	//Atlantis: Each laptop gets "invisible" program/security - REQUIRED for camnetkeys to work.
	newlap.spawn_files += (/datum/file/program/security/hidden)
	newlap.update_spawn_files()

/obj/machinery/lapvend/proc/calc_reimburse(var/obj/item/device/laptop/L)
	if(istype(L.stored_computer.cardslot,/obj/item/part/computer/cardslot))
		cardreader = 1
	if(istype(L.stored_computer.cardslot,/obj/item/part/computer/cardslot/dual))
		cardreader = 2
	if(istype(L.stored_computer.floppy,/obj/item/part/computer/storage/removable))
		floppy = 1
	if(istype(L.stored_computer.radio,/obj/item/part/computer/networking/radio))
		radionet = 1
	if(istype(L.stored_computer.camnet,/obj/item/part/computer/networking/cameras))
		camera = 1
	if(istype(L.stored_computer.net,/obj/item/part/computer/networking/area))
		network = 1
	if(istype(L.stored_computer.net,/obj/item/part/computer/networking/prox))
		network = 2
	if(istype(L.stored_computer.net,/obj/item/part/computer/networking/cable))
		network = 3
	if(istype(L.stored_computer.battery, /obj/item/weapon/stock_parts/cell/high))
		power = 1
	if(istype(L.stored_computer.battery, /obj/item/weapon/stock_parts/cell/super))
		power = 2



/obj/machinery/lapvend/proc/reimburse(var/obj/item/weapon/card/I)
	if(istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = I
		visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
		if(vendor_account)
			var/attempt_pin = input("Enter pin code", "Vendor transaction") as num
			var/datum/money_account/D = attempt_account_access(C.associated_account_number, attempt_pin, 2)
			if(D)
				var/transaction_amount = total()

				//transfer the money
				D.money += transaction_amount
				vendor_account.money -= transaction_amount

				//Transaction logs
				var/datum/transaction/T = new()
				T.target_name = "[vendor_account.owner_name] (via [src.name])"
				T.purpose = "Return purchase of Laptop"
				if(transaction_amount > 0)
					T.amount = "([transaction_amount])"
				else
					T.amount = "[transaction_amount]"
				T.source_terminal = src.name
				T.date = current_date_string
				T.time = worldtime2text()
				D.transaction_log.Add(T)
				//
				T = new()
				T.target_name = D.owner_name
				T.purpose = "Return purchase of Laptop"
				T.amount = "[transaction_amount]"
				T.source_terminal = src.name
				T.date = current_date_string
				T.time = worldtime2text()
				vendor_account.transaction_log.Add(T)

				qdel(relap)

				vendmode = 0
				cardreader = 0
				floppy = 0
				radionet = 0
				camera = 0
				network = 0
				power = 0

			else
				to_chat(usr, "[bicon(src)]<span class='warning'>Unable to access account. Check security settings and try again.</span>")
		else
			to_chat(usr, "[bicon(src)]<span class='warning'>Unable to access vendor account. Please record the machine ID and call CentComm Support.</span>")
