// A vendor machine for modular computer portable devices - Laptops and Tablets

/obj/machinery/lapvend
	name = "computer vendor"
	desc = "A vending machine with a built-in microfabricator, capable of dispensing various NT-branded computers."
	icon = 'icons/obj/vending.dmi'
	icon_state = "robotics"
	layer = BELOW_OBJ_LAYER
	anchored = 1
	density = 1

	// The actual laptop/tablet
	var/obj/item/modular_computer/laptop/fabricated_laptop = null
	var/obj/item/modular_computer/tablet/fabricated_tablet = null

	// Utility vars
	var/state = 0 							// 0: Select device type, 1: Select loadout, 2: Payment, 3: Thankyou screen
	var/devtype = 0 						// 0: None(unselected), 1: Laptop, 2: Tablet
	var/total_price = 0						// Price of currently vended device.

	// Device loadout
	var/dev_cpu = 1							// 1: Default, 2: Upgraded
	var/dev_battery = 1						// 1: Default, 2: Upgraded, 3: Advanced
	var/dev_disk = 1						// 1: Default, 2: Upgraded, 3: Advanced
	var/dev_netcard = 0						// 0: None, 1: Basic, 2: Long-Range
	var/dev_apc_recharger = 0				// 0: None, 1: Standard (LAPTOP ONLY)
	var/dev_printer = 0						// 0: None, 1: Standard
	var/dev_card = 0						// 0: None, 1: Standard

// Removes all traces of old order and allows you to begin configuration from scratch.
/obj/machinery/lapvend/proc/reset_order()
	state = 0
	devtype = 0
	QDEL_NULL(fabricated_laptop)
	QDEL_NULL(fabricated_tablet)
	dev_cpu = 1
	dev_battery = 1
	dev_disk = 1
	dev_netcard = 0
	dev_apc_recharger = 0
	dev_printer = 0
	dev_card = 0

// Recalculates the price and optionally even fabricates the device.
/obj/machinery/lapvend/proc/fabricate_and_recalc_price(fabricate = 0)
	total_price = 0
	if(devtype == 1) 		// Laptop, generally cheaper to make it accessible for most station roles
		var/obj/item/computer_hardware/battery/battery_module = null
		if(fabricate)
			fabricated_laptop = new /obj/item/modular_computer/laptop/buildable(src)
			fabricated_laptop.install_component(new /obj/item/computer_hardware/battery)
			battery_module = fabricated_laptop.all_components[MC_CELL]
		total_price = 99
		switch(dev_cpu)
			if(1)
				if(fabricate)
					fabricated_laptop.install_component(new /obj/item/computer_hardware/processor_unit/small)
			if(2)
				if(fabricate)
					fabricated_laptop.install_component(new /obj/item/computer_hardware/processor_unit)
				total_price += 299
		switch(dev_battery)
			if(1) // Basic(750C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer)
			if(2) // Upgraded(1100C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer/advanced)
				total_price += 199
			if(3) // Advanced(1500C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer/super)
				total_price += 499
		switch(dev_disk)
			if(1) // Basic(128GQ)
				if(fabricate)
					fabricated_laptop.install_component(new /obj/item/computer_hardware/hard_drive)
			if(2) // Upgraded(256GQ)
				if(fabricate)
					fabricated_laptop.install_component(new /obj/item/computer_hardware/hard_drive/advanced)
				total_price += 99
			if(3) // Advanced(512GQ)
				if(fabricate)
					fabricated_laptop.install_component(new /obj/item/computer_hardware/hard_drive/super)
				total_price += 299
		switch(dev_netcard)
			if(1) // Basic(Short-Range)
				if(fabricate)
					fabricated_laptop.install_component(new /obj/item/computer_hardware/network_card)
				total_price += 99
			if(2) // Advanced (Long Range)
				if(fabricate)
					fabricated_laptop.install_component(new /obj/item/computer_hardware/network_card/advanced)
				total_price += 299
		if(dev_apc_recharger)
			total_price += 399
			if(fabricate)
				fabricated_laptop.install_component(new /obj/item/computer_hardware/recharger/APC)
		if(dev_printer)
			total_price += 99
			if(fabricate)
				fabricated_laptop.install_component(new /obj/item/computer_hardware/printer/mini)
		if(dev_card)
			total_price += 199
			if(fabricate)
				fabricated_laptop.install_component(new /obj/item/computer_hardware/card_slot)

		return total_price
	else if(devtype == 2) 	// Tablet, more expensive, not everyone could probably afford this.
		var/obj/item/computer_hardware/battery/battery_module = null
		if(fabricate)
			fabricated_tablet = new(src)
			fabricated_tablet.install_component(new /obj/item/computer_hardware/battery)
			fabricated_tablet.install_component(new /obj/item/computer_hardware/processor_unit/small)
			battery_module = fabricated_tablet.all_components[MC_CELL]
		total_price = 199
		switch(dev_battery)
			if(1) // Basic(300C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer/nano)
			if(2) // Upgraded(500C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer/micro)
				total_price += 199
			if(3) // Advanced(750C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer)
				total_price += 499
		switch(dev_disk)
			if(1) // Basic(32GQ)
				if(fabricate)
					fabricated_tablet.install_component(new /obj/item/computer_hardware/hard_drive/micro)
			if(2) // Upgraded(64GQ)
				if(fabricate)
					fabricated_tablet.install_component(new /obj/item/computer_hardware/hard_drive/small)
				total_price += 99
			if(3) // Advanced(128GQ)
				if(fabricate)
					fabricated_tablet.install_component(new /obj/item/computer_hardware/hard_drive)
				total_price += 299
		switch(dev_netcard)
			if(1) // Basic(Short-Range)
				if(fabricate)
					fabricated_tablet.install_component(new/obj/item/computer_hardware/network_card)
				total_price += 99
			if(2) // Advanced (Long Range)
				if(fabricate)
					fabricated_tablet.install_component(new/obj/item/computer_hardware/network_card/advanced)
				total_price += 299
		if(dev_printer)
			total_price += 99
			if(fabricate)
				fabricated_tablet.install_component(new/obj/item/computer_hardware/printer)
		if(dev_card)
			total_price += 199
			if(fabricate)
				fabricated_tablet.install_component(new/obj/item/computer_hardware/card_slot)
		return total_price
	return 0


/obj/machinery/lapvend/Topic(href, href_list)
	if(..())
		return 1

	switch(href_list["action"])
		if("pick_device")
			if(state) // We've already picked a device type
				return 0
			devtype = text2num(href_list["pick"])
			state = 1
			fabricate_and_recalc_price(0)
			return 1
		if("clean_order")
			reset_order()
			return 1
	if((state != 1) && devtype) // Following IFs should only be usable when in the Select Loadout mode
		return 0
	switch(href_list["action"])
		if("confirm_order")
			state = 2 // Wait for ID swipe for payment processing
			fabricate_and_recalc_price(0)
			return 1
		if("hw_cpu")
			dev_cpu = text2num(href_list["cpu"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_battery")
			dev_battery = text2num(href_list["battery"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_disk")
			dev_disk = text2num(href_list["disk"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_netcard")
			dev_netcard = text2num(href_list["netcard"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_tesla")
			dev_apc_recharger = text2num(href_list["tesla"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_nanoprint")
			dev_printer = text2num(href_list["print"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_card")
			dev_card = text2num(href_list["card"])
			fabricate_and_recalc_price(0)
			return 1
	return 0

/obj/machinery/lapvend/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/lapvend/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "computer_fabricator.tmpl", "Personal Computer Vendor", 500, 700)
		ui.set_auto_update(1)
		ui.open()

/obj/machinery/lapvend/ui_data(mob/user)
	var/list/data[0]
	data["state"] = state
	if(state == 1)
		data["devtype"] = devtype
		data["hw_battery"] = dev_battery
		data["hw_disk"] = dev_disk
		data["hw_netcard"] = dev_netcard
		data["hw_tesla"] = dev_apc_recharger
		data["hw_nanoprint"] = dev_printer
		data["hw_card"] = dev_card
		data["hw_cpu"] = dev_cpu
	if(state == 1 || state == 2)
		data["totalprice"] = total_price
	return data

obj/machinery/lapvend/attackby(obj/item/I, mob/user)
	var/obj/item/card/id/C
	if(istype(I, /obj/item/card/id))
		C = I
	if(istype(I, /obj/item/pda))
		var/obj/item/pda/PDA = I
		if(PDA.id)
			C = PDA.id

	if(C && istype(C) && state == 2)
		if(process_payment(C, I))
			fabricate_and_recalc_price(1)
			if((devtype == 1) && fabricated_laptop)
				fabricated_laptop.forceMove(loc)
				fabricated_laptop = null
			else if((devtype == 2) && fabricated_tablet)
				fabricated_tablet.update_icon()
				fabricated_tablet.forceMove(loc)
				fabricated_tablet = null
			atom_say("Enjoy your new product!")
			state = 3
			return 1
		return 0
	return ..()


// Simplified payment processing, returns 1 on success.
/obj/machinery/lapvend/proc/process_payment(obj/item/card/id/I, obj/item/ID_container)
	visible_message("<span class='info'>\The [usr] swipes \the [ID_container] through \the [src].</span>")
	var/datum/money_account/customer_account = get_card_account(I)
	if(!customer_account || customer_account.suspended)
		atom_say("Connection error. Unable to connect to account.")
		return 0

	if(customer_account.security_level != 0) //If card requires pin authentication (ie seclevel 1 or 2)
		var/attempt_pin = input("Enter pin code", "Vendor transaction") as num
		customer_account = attempt_account_access(I.associated_account_number, attempt_pin, 2)

		if(!customer_account)
			atom_say("Unable to access account: incorrect credentials.")
			return 0

	if(total_price > customer_account.money)
		atom_say("Insufficient funds in account.")
		return 0
	else
		customer_account.charge(total_price, vendor_account,
		"Purchase of [(devtype == 1) ? "laptop computer" : "tablet microcomputer"].",
		name, customer_account.owner_name, "Sale of [(devtype == 1) ? "laptop computer" : "tablet microcomputer"].",
		customer_account.owner_name)

		return 1
