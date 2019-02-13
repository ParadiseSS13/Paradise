/**
 *  Datum used to hold information about a product in a vending machine
 */
/datum/data/vending_product
	var/product_name = "generic" // Display name for the product
	var/product_path = null
	var/amount = 0  // Amount held in the vending machine
	var/max_amount = 0
	var/price = 0  // Price to buy one
	var/display_color = null  // Display color for vending machine listing
	var/category = CAT_NORMAL  // CAT_HIDDEN for contraband, CAT_COIN for premium

/datum/data/vending_product/New(var/path, var/name = null, var/amount = 1, var/price = 0, var/color = null, var/category = CAT_NORMAL)
	..()

	product_path = path

	if(!name)
		var/atom/tmp = new path
		product_name = initial(tmp.name)
		qdel(tmp)
	else
		product_name = name

	amount = amount
	price = price
	display_color = color
	category = category

/**
 *  A vending machine
 */
/obj/machinery/vending
	name = "\improper Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	layer = 2.9
	anchored = 1
	density = 1
	armor = list(melee = 20, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	var/icon_vend //Icon_state when vending
	var/icon_deny //Icon_state when denying access

	// Power
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	var/vend_power_usage = 150

	// Vending-related
	var/active = 1 //No sales pitches if off!
	var/vend_ready = 1 //Are we ready to vend?? Is it time??
	var/vend_delay = 10 //How long does it take to vend?
	var/categories = CAT_NORMAL // Bitmask of cats we're currently showing
	var/datum/data/vending_product/currently_vending = null // What we're requesting payment for right now
	var/status_message = "" // Status screen messages like "insufficient funds", displayed in NanoUI
	var/status_error = 0 // Set to 1 if status_message is an error

	// To be filled out at compile time
	var/list/products	= list()	// For each, use the following pattern:
	var/list/contraband	= list()	// list(/type/path = amount,/type/path2 = amount2)
	var/list/premium 	= list()	// No specified amount = only one in stock
	var/list/prices     = list()	// Prices for each item, list(/type/path = price), items not in the list don't have a price.

	// List of vending_product items available.
	var/list/product_records = list()
	var/list/hidden_records = list()

	// // Variables used to initialize advertising
	var/product_slogans = ""	//String of slogans separated by semicolons, optional
	var/product_ads = ""		//String of small ad messages in the vending screen - random chance

	var/list/ads_list = list()

	// Stuff relating vocalizations
	var/list/slogan_list = list()
	var/vend_reply				//Thank you for shopping!
	var/shut_up = 0				//Stop spouting those godawful pitches!
	var/last_reply = 0
	var/last_slogan = 0			//When did we last pitch?
	var/slogan_delay = 6000		//How long until we can pitch again?

	var/obj/item/vending_refill/refill_canister = null    //The type of refill canisters used by this machine.

	// Things that can go wrong
	emagged = 0			//Ignores if somebody doesn't have card access to that machine.
	var/seconds_electrified = 0	//Shock customers like an airlock.
	var/shoot_inventory = 0		//Fire items at customers! We're broken!
	var/shoot_speed = 3			//How hard are we firing the items?
	var/shoot_chance = 2		//How often are we firing the items?

	var/scan_id = 1
	var/obj/item/coin/coin
	var/datum/wires/vending/wires = null

	var/item_slot = FALSE
	var/obj/item/inserted_item = null

/obj/machinery/vending/New()
	..()
	wires = new(src)
	spawn(50)
		if(product_slogans)
			slogan_list += splittext(product_slogans, ";")

			// So not all machines speak at the exact same time.
			// The first time this machine says something will be at slogantime + this random value,
			// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
			last_slogan = world.time + rand(0, slogan_delay)

		if(product_ads)
			ads_list += splittext(product_ads, ";")

		build_inventory()
		power_change()

		return

	return

/obj/machinery/vending/Destroy()
	eject_item()
	return ..()

/**
 *  Build src.produdct_records from the products lists
 *
 *  src.products, src.contraband, src.premium, and src.prices allow specifying
 *  products that the vending machine is to carry without manually populating
 *  src.product_records.
 */
/obj/machinery/vending/proc/build_inventory()
	var/list/all_products = list(
		list(products, CAT_NORMAL),
		list(contraband, CAT_HIDDEN),
		list(premium, CAT_COIN))

	for(var/current_list in all_products)
		var/category = current_list[2]

		for(var/entry in current_list[1])
			var/datum/data/vending_product/product = new/datum/data/vending_product(entry)

			product.price = (entry in prices) ? prices[entry] : 0
			product.amount = (current_list[1][entry]) ? current_list[1][entry] : 1
			product.max_amount = product.amount
			product.category = category

			product_records.Add(product)

/obj/machinery/vending/Destroy()
	QDEL_NULL(wires)
	QDEL_NULL(coin)
	return ..()

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				malfunction()

/obj/machinery/vending/RefreshParts()         //Better would be to make constructable child
	if(component_parts)
		for(var/obj/item/vending_refill/VR in component_parts)
			refill_inventory(VR, product_records, usr)

/obj/machinery/vending/blob_act()
	if(prob(75))
		malfunction()
	else
		qdel(src)

/obj/machinery/vending/proc/refill_inventory(obj/item/vending_refill/refill, list/machine, mob/user)
	var/total = 0

	var/to_restock = 0
	for(var/datum/data/vending_product/machine_content in machine)
		to_restock += machine_content.max_amount - machine_content.amount

	if(to_restock <= refill.charges)
		for(var/datum/data/vending_product/machine_content in machine)
			if(machine_content.amount != machine_content.max_amount)
				if(user)
					to_chat(user, "<span class='notice'>[machine_content.max_amount - machine_content.amount] of [machine_content.product_name]</span>")
				machine_content.amount = machine_content.max_amount
		refill.charges -= to_restock
		total = to_restock
	else
		var/tmp_charges = refill.charges
		for(var/datum/data/vending_product/machine_content in machine)
			var/restock = Ceiling(((machine_content.max_amount - machine_content.amount)/to_restock)*tmp_charges)
			if(restock > refill.charges)
				restock = refill.charges
			machine_content.amount += restock
			refill.charges -= restock
			total += restock
			if(restock)
				if(user)
					to_chat(user, "<span class='notice'>[restock] of [machine_content.product_name]</span>")
			if(refill.charges == 0) //due to rounding, we ran out of refill charges, exit.
				break
	return total

/obj/machinery/vending/attackby(obj/item/I, mob/user, params)
	if(currently_vending && vendor_account && !vendor_account.suspended)
		var/paid = 0
		var/handled = 0
		if(istype(I, /obj/item/card/id))
			var/obj/item/card/id/C = I
			paid = pay_with_card(C)
			handled = 1
		if(istype(I, /obj/item/pda))
			var/obj/item/pda/PDA = I
			if(PDA.id)
				paid = pay_with_card(PDA.id)
				handled = 1
		else if(istype(I, /obj/item/stack/spacecash))
			var/obj/item/stack/spacecash/C = I
			paid = pay_with_cash(C, user)
			handled = 1

		if(paid)
			vend(currently_vending, usr)
			return
		else if(handled)
			SSnanoui.update_uis(src)
			return // don't smack that machine with your 2 thalers

	if(default_unfasten_wrench(user, I, time = 60))
		return

	if(istype(I, /obj/item/screwdriver) && anchored)
		playsound(loc, I.usesound, 50, 1)
		panel_open = !panel_open
		to_chat(user, "You [panel_open ? "open" : "close"] the maintenance panel.")
		overlays.Cut()
		if(panel_open)
			overlays += image(icon, "[initial(icon_state)]-panel")
		SSnanoui.update_uis(src)  // Speaker switch is on the main UI, not wires UI
		return

	if(panel_open)
		if(istype(I, /obj/item/multitool)||istype(I, /obj/item/wirecutters))
			return attack_hand(user)
		if(component_parts && istype(I, /obj/item/crowbar))
			var/datum/data/vending_product/machine = product_records
			for(var/datum/data/vending_product/machine_content in machine)
				while(machine_content.amount !=0)
					for(var/obj/item/vending_refill/VR in component_parts)
						VR.charges++
						machine_content.amount--
						if(!machine_content.amount)
							break
			default_deconstruction_crowbar(I)
	if(istype(I, /obj/item/coin) && premium.len > 0)
		user.drop_item()
		I.loc = src
		coin = I
		categories |= CAT_COIN
		to_chat(user, "<span class='notice'>You insert the [I] into the [src]</span>")
		SSnanoui.update_uis(src)
		return
	else if(istype(I, refill_canister) && refill_canister != null)
		if(stat & (BROKEN|NOPOWER))
			to_chat(user, "<span class='notice'>It does nothing.</span>")
		else if(panel_open)
			//if the panel is open we attempt to refill the machine
			var/obj/item/vending_refill/canister = I
			if(canister.charges == 0)
				to_chat(user, "<span class='notice'>This [canister.name] is empty!</span>")
			else
				var/transfered = refill_inventory(canister,product_records,user)
				if(transfered)
					to_chat(user, "<span class='notice'>You loaded [transfered] items in \the [name].</span>")
				else
					to_chat(user, "<span class='notice'>The [name] is fully stocked.</span>")
			return;
		else
			to_chat(user, "<span class='notice'>You should probably unscrew the service panel first.</span>")
	else if(item_slot_check(user, I))
		insert_item(user, I)
		return
	else
		return ..()

//Override this proc to do per-machine checks on the inserted item, but remember to call the parent to handle these generic checks before your logic!
/obj/machinery/vending/proc/item_slot_check(mob/user, obj/item/I)
	if(!item_slot)
		return FALSE
	if(alert(user, "Do you want to attempt to insert [I]?", "","Yes", "No") == "No")
		return FALSE
	if(inserted_item)
		to_chat(user, "<span class='warning'>There is something already inserted!</span>")
		return FALSE
	return TRUE

/* Example override for item_slot_check proc:
/obj/machinery/vending/example/item_slot_check(mob/user, obj/item/I)
	if(!..())
		return FALSE
	if(!istype(I, /obj/item/toy))
		to_chat(user, "<span class='warning'>[I] isn't compatible with this machine's slot.</span>")
		return FALSE
	return TRUE
*/

/obj/machinery/vending/proc/insert_item(mob/user, obj/item/I)
	if(!item_slot || inserted_item)
		return
	if(!user.canUnEquip(I))
		to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't seem to put it down!</span>")
		return

	user.unEquip(I)
	inserted_item = I
	I.forceMove(src)

	to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
	SSnanoui.update_uis(src)

/obj/machinery/vending/proc/eject_item()
	if(!item_slot || !inserted_item)
		return
	inserted_item.forceMove(get_turf(src))
	inserted_item = null
	SSnanoui.update_uis(src)

/obj/machinery/vending/emag_act(user as mob)
	emagged = 1
	to_chat(user, "You short out the product lock on [src]")
	return

/**
 *  Receive payment with cashmoney.
 *
 *  usr is the mob who gets the change.
 */
/obj/machinery/vending/proc/pay_with_cash(obj/item/stack/spacecash/cashmoney, mob/user)
	if(currently_vending.price > cashmoney.amount)
		// This is not a status display message, since it's something the character
		// themselves is meant to see BEFORE putting the money in
		to_chat(usr, "[bicon(cashmoney)] <span class='warning'>That is not enough money.</span>")
		return 0

	// Bills (banknotes) cannot really have worth different than face value,
	// so we have to eat the bill and spit out change in a bundle
	// This is really dirty, but there's no superclass for all bills, so we
	// just assume that all spacecash that's not something else is a bill

	visible_message("<span class='info'>[usr] inserts a credit chip into [src].</span>")
	cashmoney.use(currently_vending.price)

	// Vending machines have no idea who paid with cash
	credit_purchase("(cash)")
	return 1

/**
 * Scan a card and attempt to transfer payment from associated account.
 *
 * Takes payment for whatever is the currently_vending item. Returns 1 if
 * successful, 0 if failed
 */
/obj/machinery/vending/proc/pay_with_card(var/obj/item/card/id/I)
	visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
	return pay_with_account(get_card_account(I))

/obj/machinery/vending/proc/pay_with_account(var/datum/money_account/customer_account)
	if(!customer_account)
		src.status_message = "Error: Unable to access account. Please contact technical support if problem persists."
		src.status_error = 1
		return 0

	if(customer_account.suspended)
		src.status_message = "Unable to access account: account suspended."
		src.status_error = 1
		return 0

	// Have the customer punch in the PIN before checking if there's enough money. Prevents people from figuring out acct is
	// empty at high security levels
	if(customer_account.security_level != 0) //If card requires pin authentication (ie seclevel 1 or 2)
		var/attempt_pin = input("Enter pin code", "Vendor transaction") as num

		if(!attempt_account_access(customer_account.account_number, attempt_pin, 2))
			src.status_message = "Unable to access account: incorrect credentials."
			src.status_error = 1
			return 0

	if(currently_vending.price > customer_account.money)
		src.status_message = "Insufficient funds in account."
		src.status_error = 1
		return 0
	else
		// Okay to move the money at this point
		var/paid = customer_account.charge(currently_vending.price, vendor_account,
			"Purchase of [currently_vending.product_name]", name, vendor_account.owner_name,
			"Sale of [currently_vending.product_name]", customer_account.owner_name)

		if(paid)
			// Give the vendor the money. We use the account owner name, which means
			// that purchases made with stolen/borrowed card will look like the card
			// owner made them
			credit_purchase(customer_account.owner_name)
		return paid

/**
 *  Add money for current purchase to the vendor account.
 *
 *  Called after the money has already been taken from the customer.
 */
/obj/machinery/vending/proc/credit_purchase(var/target as text)
	vendor_account.money += currently_vending.price
	vendor_account.credit(currently_vending.price, "Sale of [currently_vending.product_name]",
	name, target)

/obj/machinery/vending/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/vending/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/vending/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(src.seconds_electrified != 0)
		if(src.shock(user, 100))
			return

	ui_interact(user)
	wires.Interact(user)

/**
 *  Display the NanoUI window for the vending machine.
 *
 *  See NanoUI documentation for details.
 */
/obj/machinery/vending/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "vending_machine.tmpl", src.name, 440, 600)
		ui.open()

/obj/machinery/vending/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/list/data = list()
	if(currently_vending)
		data["mode"] = 1
		data["product"] = sanitize(currently_vending.product_name)
		data["price"] = currently_vending.price
		data["message_err"] = 0
		data["message"] = src.status_message
		data["message_err"] = src.status_error
	else
		data["mode"] = 0
		var/list/listed_products = list()

		for(var/key = 1 to src.product_records.len)
			var/datum/data/vending_product/I = src.product_records[key]

			if(!(I.category & src.categories))
				continue

			listed_products.Add(list(list(
				"key" = key,
				"name" = sanitize(I.product_name),
				"price" = I.price,
				"color" = I.display_color,
				"amount" = I.amount)))

		data["products"] = listed_products

	if(coin)
		data["coin"] = coin.name

	if(item_slot)
		data["item_slot"] = 1
		if(inserted_item)
			data["inserted_item"] = inserted_item
		else
			data["inserted_item"] = null
	else
		data["item_slot"] = 0

	if(panel_open)
		data["panel"] = 1
		data["speaker"] = shut_up ? 0 : 1
	else
		data["panel"] = 0
	return data

/obj/machinery/vending/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["remove_coin"] && !istype(usr,/mob/living/silicon))
		if(!coin)
			to_chat(usr, "There is no coin in this machine.")
			return

		usr.put_in_hands(coin)
		coin = null
		to_chat(usr, "<span class='notice'>You remove [coin] from [src].</span>")
		categories &= ~CAT_COIN

	if(href_list["remove_item"])
		eject_item()

	if(href_list["pay"])
		if(currently_vending && vendor_account && !vendor_account.suspended)
			var/paid = 0
			var/handled = 0
			var/datum/money_account/A = usr.get_worn_id_account()
			if(A)
				paid = pay_with_account(A)
				handled = 1
			else if(istype(usr.get_active_hand(), /obj/item/card))
				paid = pay_with_card(usr.get_active_hand())
				handled = 1
			else if(usr.can_admin_interact())
				paid = 1
				handled = 1
			if(paid)
				vend(currently_vending, usr)
				return
			else if(handled)
				SSnanoui.update_uis(src)
				return // don't smack that machine with your 2 credits

	if((href_list["vend"]) && vend_ready && !currently_vending)

		if(issilicon(usr) && !isrobot(usr))
			to_chat(usr, "<span class='warning'>The vending machine refuses to interface with you, as you are not in its target demographic!</span>")
			return

		if(!allowed(usr) && !usr.can_admin_interact() && !emagged && scan_id) //For SECURE VENDING MACHINES YEAH
			to_chat(usr, "<span class='warning'>Access denied.</span>") //Unless emagged of course
			flick(icon_deny,src)
			return

		var/key = text2num(href_list["vend"])
		var/datum/data/vending_product/R = product_records[key]

		// This should not happen unless the request from NanoUI was bad
		if(!(R.category & categories))
			return

		if(R.price <= 0)
			vend(R, usr)
		else
			currently_vending = R
			if(!vendor_account || vendor_account.suspended)
				status_message = "This machine is currently unable to process payments due to problems with the associated account."
				status_error = 1
			else
				status_message = "Please swipe a card or insert cash to pay for the item."
				status_error = 0

	else if(href_list["cancelpurchase"])
		currently_vending = null

	else if(href_list["togglevoice"] && panel_open)
		shut_up = !src.shut_up

	add_fingerprint(usr)
	SSnanoui.update_uis(src)

/obj/machinery/vending/proc/vend(datum/data/vending_product/R, mob/user)
	if(!allowed(usr) && !usr.can_admin_interact() && !emagged && scan_id)	//For SECURE VENDING MACHINES YEAH
		to_chat(usr, "<span class='warning'>Access denied.</span>")//Unless emagged of course
		flick(icon_deny,src)
		return

	if(!R.amount)
		to_chat(user, "<span class='warning'>The vending machine has ran out of that product.</span>")
		return

	vend_ready = 0 //One thing at a time!!
	status_message = "Vending..."
	status_error = 0
	SSnanoui.update_uis(src)

	if(R.category & CAT_COIN)
		if(!coin)
			to_chat(user, "<span class='notice'>You need to insert a coin to get this item.</span>")
			return
		if(coin.string_attached)
			if(prob(50))
				to_chat(user, "<span class='notice'>You successfully pull the coin out before the [src] could swallow it.</span>")
			else
				to_chat(user, "<span class='notice'>You weren't able to pull the coin out fast enough, the machine ate it, string and all.</span>")
				QDEL_NULL(coin)
				categories &= ~CAT_COIN
		else
			QDEL_NULL(coin)
			categories &= ~CAT_COIN

	R.amount--

	if(((last_reply + (vend_delay + 200)) <= world.time) && vend_reply)
		spawn(0)
			speak(src.vend_reply)
			last_reply = world.time

	use_power(vend_power_usage)	//actuators and stuff
	if(icon_vend) //Show the vending animation if needed
		flick(icon_vend,src)
	spawn(vend_delay)
		do_vend(R)
		status_message = ""
		status_error = 0
		vend_ready = 1
		currently_vending = null
		SSnanoui.update_uis(src)

//override this proc to add handling for what to do with the vended product when you have a inserted item and remember to include a parent call for this generic handling
/obj/machinery/vending/proc/do_vend(datum/data/vending_product/R)
	if(!item_slot || !inserted_item)
		new R.product_path(get_turf(src))
		return TRUE
	return FALSE

/* Example override for do_vend proc:
/obj/machinery/vending/example/do_vend(datum/data/vending_product/R)
	if(..())
		return
	var/obj/item/vended = new R.product_path()
	if(inserted_item.force == initial(inserted_item.force)
		inserted_item.force += vended.force
	inserted_item.damtype = vended.damtype
	qdel(vended)
*/

/obj/machinery/vending/proc/stock(var/datum/data/vending_product/R, var/mob/user)
	if(panel_open)
		to_chat(user, "<span class='notice'>You stock the [src] with \a [R.product_name]</span>")
		R.amount++
	updateUsrDialog()


/obj/machinery/vending/process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(!active)
		return

	if(src.seconds_electrified > 0)
		src.seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(((last_slogan + src.slogan_delay) <= world.time) && (slogan_list.len > 0) && (!shut_up) && prob(5))
		var/slogan = pick(src.slogan_list)
		speak(slogan)
		last_slogan = world.time

	if(shoot_inventory && prob(shoot_chance))
		throw_item()

	return

/obj/machinery/vending/proc/speak(message)
	if(stat & NOPOWER)
		return
	if(!message)
		return

	atom_say(message)

/obj/machinery/vending/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				icon_state = "[initial(icon_state)]-off"
				stat |= NOPOWER

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	for(var/datum/data/vending_product/R in product_records)
		if(R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if(!dump_path)
			continue

		while(R.amount>0)
			new dump_path(loc)
			R.amount--
		break

	stat |= BROKEN
	icon_state = "[initial(icon_state)]-broken"
	return

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for(var/datum/data/vending_product/R in product_records)
		if(R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if(!dump_path)
			continue

		R.amount--
		throw_item = new dump_path(loc)
		break
	if(!throw_item)
		return 0
	spawn(0)
		throw_item.throw_at(target, 16, 3, src)
	visible_message("<span class='danger'>[src] launches [throw_item.name] at [target.name]!</span>")
	return 1

/*
 * Vending machine types
 */

/*

/obj/machinery/vending/[vendors name here]   // --vending machine template   :)
	name = ""
	desc = ""
	icon = ''
	icon_state = ""
	vend_delay = 15
	products = list()
	contraband = list()
	premium = list()

*/

/*
/obj/machinery/vending/atmospherics //Commenting this out until someone ponies up some actual working, broken, and unpowered sprites - Quarxink
	name = "\improper Tank Vendor"
	desc = "A vendor with a wide variety of masks and gas tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	product_paths = "/obj/item/tank/oxygen;/obj/item/tank/plasma;/obj/item/tank/emergency_oxygen;/obj/item/tank/emergency_oxygen/engi;/obj/item/clothing/mask/breath"
	product_amounts = "10;10;10;5;25"
	vend_delay = 0
*/

/obj/machinery/vending/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat-deny"
	products = list(/obj/item/reagent_containers/food/drinks/bottle/gin = 5,
					/obj/item/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/reagent_containers/food/drinks/bottle/tequila = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vermouth = 5,
					/obj/item/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/reagent_containers/food/drinks/bottle/wine = 5,
					/obj/item/reagent_containers/food/drinks/bag/goonbag = 3,
					/obj/item/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/reagent_containers/food/drinks/bottle/kahlua = 5,
					/obj/item/reagent_containers/food/drinks/cans/beer = 6,
					/obj/item/reagent_containers/food/drinks/cans/ale = 6,
					/obj/item/reagent_containers/food/drinks/cans/synthanol = 15,
					/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/tomatojuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/limejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/cream = 4,
					/obj/item/reagent_containers/food/drinks/cans/tonic = 8,
					/obj/item/reagent_containers/food/drinks/cans/cola = 8,
					/obj/item/reagent_containers/food/drinks/cans/sodawater = 15,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 30,
					/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass = 30,
					/obj/item/reagent_containers/food/drinks/ice = 9)
	contraband = list(/obj/item/reagent_containers/food/drinks/tea = 10)
	vend_delay = 15
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"
	refill_canister = /obj/item/vending_refill/boozeomat

/obj/machinery/vending/assist
	products = list(	/obj/item/assembly/prox_sensor = 5,/obj/item/assembly/igniter = 3,/obj/item/assembly/signaler = 4,
						/obj/item/wirecutters = 1, /obj/item/cartridge/signal = 4)
	contraband = list(/obj/item/flashlight = 5,/obj/item/assembly/timer = 2, /obj/item/assembly/voice = 2, /obj/item/assembly/health = 2)
	product_ads = "Only the finest!;Have some tools.;The most robust equipment.;The finest gear in space!"
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/boozeomat/New()
	..()
	component_parts = list()
	var/obj/item/circuitboard/vendor/V = new(null)
	V.set_type(type)
	component_parts += V
	component_parts += new /obj/item/vending_refill/boozeomat(0)
	component_parts += new /obj/item/vending_refill/boozeomat(0)
	component_parts += new /obj/item/vending_refill/boozeomat(0)


/obj/machinery/vending/coffee
	name = "\improper Hot Drinks machine"
	desc = "A vending machine which dispenses hot drinks."
	product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	item_slot = TRUE
	vend_delay = 34
	products = list(/obj/item/reagent_containers/food/drinks/coffee = 25,/obj/item/reagent_containers/food/drinks/tea = 25,/obj/item/reagent_containers/food/drinks/h_chocolate = 25,
					/obj/item/reagent_containers/food/drinks/chocolate = 10, /obj/item/reagent_containers/food/drinks/chicken_soup = 10,/obj/item/reagent_containers/food/drinks/weightloss = 10,
					/obj/item/reagent_containers/food/drinks/mug = 15)
	contraband = list(/obj/item/reagent_containers/food/drinks/ice = 10)
	premium = list(/obj/item/reagent_containers/food/drinks/mug/novelty = 5)
	prices = list(/obj/item/reagent_containers/food/drinks/coffee = 25, /obj/item/reagent_containers/food/drinks/tea = 25, /obj/item/reagent_containers/food/drinks/h_chocolate = 25, /obj/item/reagent_containers/food/drinks/chocolate = 25,
				  /obj/item/reagent_containers/food/drinks/chicken_soup = 30,/obj/item/reagent_containers/food/drinks/weightloss = 50, /obj/item/reagent_containers/food/drinks/mug = 50)
	refill_canister = /obj/item/vending_refill/coffee

/obj/machinery/vending/coffee/free
	prices = list()

/obj/machinery/vending/coffee/New()
	..()
	component_parts = list()
	var/obj/item/circuitboard/vendor/V = new(null)
	V.set_type(type)
	component_parts += V
	component_parts += new /obj/item/vending_refill/coffee(0)
	component_parts += new /obj/item/vending_refill/coffee(0)
	component_parts += new /obj/item/vending_refill/coffee(0)

/obj/machinery/vending/coffee/item_slot_check(mob/user, obj/item/I)
	if(!..())
		return FALSE
	if(!(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks)))
		to_chat(user, "<span class='warning'>[I] is not compatible with this machine.</span>")
		return FALSE
	if(!I.is_open_container())
		to_chat(user, "<span class='warning'>You need to open [I] before you insert it.</span>")
		return FALSE
	return TRUE

/obj/machinery/vending/coffee/do_vend(datum/data/vending_product/R)
	if(..())
		return
	var/obj/item/reagent_containers/food/drinks/vended = new R.product_path()

	if(istype(vended, /obj/item/reagent_containers/food/drinks/mug))
		vended.forceMove(get_turf(src))
		return

	vended.reagents.trans_to(inserted_item, vended.reagents.total_volume)
	if(vended.reagents.total_volume)
		vended.forceMove(get_turf(src))
	else
		qdel(vended)


/obj/machinery/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snack"
	products = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 6,/obj/item/reagent_containers/food/drinks/dry_ramen = 6,/obj/item/reagent_containers/food/snacks/chips =6,
					/obj/item/reagent_containers/food/snacks/sosjerky = 6,/obj/item/reagent_containers/food/snacks/no_raisin = 6,/obj/item/reagent_containers/food/snacks/pistachios =6,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 6,/obj/item/reagent_containers/food/snacks/cheesiehonkers = 6,/obj/item/reagent_containers/food/snacks/tastybread = 6)
	contraband = list(/obj/item/reagent_containers/food/snacks/syndicake = 6)
	prices = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 20,/obj/item/reagent_containers/food/drinks/dry_ramen = 30,
					/obj/item/reagent_containers/food/snacks/chips =25,/obj/item/reagent_containers/food/snacks/sosjerky = 30,/obj/item/reagent_containers/food/snacks/no_raisin = 20,
					/obj/item/reagent_containers/food/snacks/pistachios = 35, /obj/item/reagent_containers/food/snacks/spacetwinkie = 30,/obj/item/reagent_containers/food/snacks/cheesiehonkers = 25,/obj/item/reagent_containers/food/snacks/tastybread = 30)
	refill_canister = /obj/item/vending_refill/snack

/obj/machinery/vending/snack/free
	prices = list()

/obj/machinery/vending/snack/New()
	..()
	component_parts = list()
	var/obj/item/circuitboard/vendor/V = new(null)
	V.set_type(type)
	component_parts += V
	component_parts += new /obj/item/vending_refill/snack(0)
	component_parts += new /obj/item/vending_refill/snack(0)
	component_parts += new /obj/item/vending_refill/snack(0)

/obj/machinery/vending/chinese
	name = "\improper Mr. Chang"
	desc = "A self-serving Chinese food machine, for all your Chinese food needs."
	product_slogans = "Taste 5000 years of culture!;Mr. Chang, approved for safe consumption in over 10 sectors!;Chinese food is great for a date night, or a lonely night!;You can't go wrong with Mr. Chang's authentic Chinese food!"
	icon_state = "chang"
	products = list(/obj/item/reagent_containers/food/snacks/chinese/chowmein = 6, /obj/item/reagent_containers/food/snacks/chinese/tao = 6, /obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball = 6, /obj/item/reagent_containers/food/snacks/chinese/newdles = 6,
					/obj/item/reagent_containers/food/snacks/chinese/rice = 6)
	prices = list(/obj/item/reagent_containers/food/snacks/chinese/chowmein = 50, /obj/item/reagent_containers/food/snacks/chinese/tao = 50, /obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball = 50, /obj/item/reagent_containers/food/snacks/chinese/newdles = 50,
					/obj/item/reagent_containers/food/snacks/chinese/rice = 50)
	refill_canister = /obj/item/vending_refill/chinese

/obj/machinery/vending/chinese/free
	prices = list()

/obj/machinery/vending/chinese/New()
	..()
	component_parts = list()
	var/obj/item/circuitboard/vendor/V = new(null)
	V.set_type(type)
	component_parts += V
	component_parts += new /obj/item/vending_refill/chinese(0)
	component_parts += new /obj/item/vending_refill/chinese(0)
	component_parts += new /obj/item/vending_refill/chinese(0)

/obj/machinery/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "A soft drink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!"
	product_ads = "Refreshing!;Hope you're thirsty!;Over 1 million drinks sold!;Thirsty? Why not cola?;Please, have a drink!;Drink up!;The best drinks in space."
	products = list(/obj/item/reagent_containers/food/drinks/cans/cola = 10,/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 10,
					/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 10,/obj/item/reagent_containers/food/drinks/cans/starkist = 10,
					/obj/item/reagent_containers/food/drinks/cans/space_up = 10,/obj/item/reagent_containers/food/drinks/cans/grape_juice = 10)
	contraband = list(/obj/item/reagent_containers/food/drinks/cans/thirteenloko = 5)
	prices = list(/obj/item/reagent_containers/food/drinks/cans/cola = 20,/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 20,
					/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 20,/obj/item/reagent_containers/food/drinks/cans/starkist = 20,
					/obj/item/reagent_containers/food/drinks/cans/space_up = 20,/obj/item/reagent_containers/food/drinks/cans/grape_juice = 20)
	refill_canister = /obj/item/vending_refill/cola

/obj/machinery/vending/cola/free
	prices = list()

/obj/machinery/vending/cola/New()
	..()
	component_parts = list()
	var/obj/item/circuitboard/vendor/V = new(null)
	V.set_type(type)
	component_parts += V
	component_parts += new /obj/item/vending_refill/cola(0)
	component_parts += new /obj/item/vending_refill/cola(0)
	component_parts += new /obj/item/vending_refill/cola(0)


//This one's from bay12
/obj/machinery/vending/cart
	name = "\improper PTech"
	desc = "Cartridges for PDA's."
	product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	products = list(/obj/item/pda =10,/obj/item/cartridge/mob_hunt_game = 25,/obj/item/cartridge/medical = 10,/obj/item/cartridge/chemistry = 10,
					/obj/item/cartridge/engineering = 10,/obj/item/cartridge/atmos = 10,/obj/item/cartridge/janitor = 10,
					/obj/item/cartridge/signal/toxins = 10,/obj/item/cartridge/signal = 10)
	contraband = list(/obj/item/cartridge/clown = 1,/obj/item/cartridge/mime = 1)
	prices = list(/obj/item/pda =300,/obj/item/cartridge/mob_hunt_game = 50,/obj/item/cartridge/medical = 200,/obj/item/cartridge/chemistry = 150,/obj/item/cartridge/engineering = 100,
					/obj/item/cartridge/atmos = 75,/obj/item/cartridge/janitor = 100,/obj/item/cartridge/signal/toxins = 150,
					/obj/item/cartridge/signal = 75)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/cart/free
	prices = list()

/obj/machinery/vending/liberationstation
	name = "\improper Liberation Station"
	desc = "An overwhelming amount of <b>ancient patriotism</b> washes over you just by looking at the machine."
	icon_state = "liberationstation"
	req_access_txt = "1"
	product_slogans = "Liberation Station: Your one-stop shop for all things second amendment!;Be a patriot today, pick up a gun!;Quality weapons for cheap prices!;Better dead than red!"
	product_ads = "Float like an astronaut, sting like a bullet!;Express your second amendment today!;Guns don't kill people, but you can!;Who needs responsibilities when you have guns?"
	vend_reply = "Remember the name: Liberation Station!"
	products = list(/obj/item/gun/projectile/automatic/pistol/deagle/gold = 2,/obj/item/gun/projectile/automatic/pistol/deagle/camo = 2,
					/obj/item/gun/projectile/automatic/pistol/m1911 = 2,/obj/item/gun/projectile/automatic/proto = 2,
					/obj/item/gun/projectile/shotgun/automatic/combat = 2,/obj/item/gun/projectile/automatic/gyropistol = 1,
					/obj/item/gun/projectile/shotgun = 2,/obj/item/gun/projectile/automatic/ar = 2)
	premium = list(/obj/item/ammo_box/magazine/smgm9mm = 2,/obj/item/ammo_box/magazine/m50 = 4,/obj/item/ammo_box/magazine/m45 = 2,/obj/item/ammo_box/magazine/m75 = 2)
	contraband = list(/obj/item/clothing/under/patriotsuit = 1,/obj/item/bedsheet/patriot = 3)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/cigarette
	name = "cigarette machine"
	desc = "If you want to get cancer, might as well do it in style."
	product_slogans = "Space cigs taste good like a cigarette should.;I'd rather toolbox than switch.;Smoke!;Don't believe the reports - smoke today!"
	product_ads = "Probably not bad for you!;Don't believe the scientists!;It's good for you!;Don't quit, buy more!;Smoke!;Nicotine heaven.;Best cigarettes since 2150.;Award-winning cigs."
	vend_delay = 34
	icon_state = "cigs"
	products = list(/obj/item/storage/fancy/cigarettes = 5,/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,/obj/item/storage/fancy/cigarettes/cigpack_robust = 2,/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,/obj/item/storage/fancy/cigarettes/cigpack_midori = 1,/obj/item/storage/fancy/cigarettes/cigpack_random = 2, /obj/item/reagent_containers/food/pill/patch/nicotine = 10, /obj/item/storage/box/matches = 10,/obj/item/lighter/random = 4,/obj/item/storage/fancy/rollingpapers = 5)
	contraband = list(/obj/item/lighter/zippo = 4)
	premium = list(/obj/item/clothing/mask/cigarette/cigar/havana = 2,/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1)
	prices = list(/obj/item/storage/fancy/cigarettes = 60,/obj/item/storage/fancy/cigarettes/cigpack_uplift = 60,/obj/item/storage/fancy/cigarettes/cigpack_robust = 60,/obj/item/storage/fancy/cigarettes/cigpack_carp = 60,/obj/item/storage/fancy/cigarettes/cigpack_midori = 60,/obj/item/storage/fancy/cigarettes/cigpack_random = 150, /obj/item/reagent_containers/food/pill/patch/nicotine = 15, /obj/item/storage/box/matches = 10,/obj/item/lighter/random = 60, /obj/item/storage/fancy/rollingpapers = 20)
	refill_canister = /obj/item/vending_refill/cigarette

/obj/machinery/vending/cigarette/free
	prices = list()

/obj/machinery/vending/cigarette/New()
	..()
	component_parts = list()
	var/obj/item/circuitboard/vendor/V = new(null)
	V.set_type(type)
	component_parts += V
	component_parts += new /obj/item/vending_refill/cigarette(0)
	component_parts += new /obj/item/vending_refill/cigarette(0)
	component_parts += new /obj/item/vending_refill/cigarette(0)

/obj/machinery/vending/medical
	name = "\improper NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access_txt = "5"
	products = list(/obj/item/reagent_containers/glass/bottle/charcoal = 4,/obj/item/reagent_containers/glass/bottle/morphine = 4,/obj/item/reagent_containers/glass/bottle/ether = 4,/obj/item/reagent_containers/glass/bottle/epinephrine = 4,
					/obj/item/reagent_containers/glass/bottle/toxin = 4,/obj/item/reagent_containers/syringe/antiviral = 6,/obj/item/reagent_containers/syringe/insulin = 4,
					/obj/item/reagent_containers/syringe = 12,/obj/item/healthanalyzer = 5,/obj/item/healthupgrade = 5,/obj/item/reagent_containers/glass/beaker = 4, /obj/item/reagent_containers/hypospray/safety = 2,
					/obj/item/reagent_containers/dropper = 2,/obj/item/stack/medical/bruise_pack/advanced = 3, /obj/item/stack/medical/ointment/advanced = 3,
					/obj/item/stack/medical/bruise_pack = 3,/obj/item/stack/medical/splint = 4, /obj/item/sensor_device = 2, /obj/item/reagent_containers/hypospray/autoinjector = 4,
					/obj/item/pinpointer/crew = 2)
	contraband = list(/obj/item/reagent_containers/glass/bottle/pancuronium = 1,/obj/item/reagent_containers/glass/bottle/sulfonal = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

//This one's from bay12
/obj/machinery/vending/plasmaresearch
	name = "\improper Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	products = list(/obj/item/clothing/under/rank/scientist = 6,/obj/item/clothing/suit/bio_suit = 6,/obj/item/clothing/head/bio_hood = 6,
					/obj/item/transfer_valve = 6,/obj/item/assembly/timer = 6,/obj/item/assembly/signaler = 6,
					/obj/item/assembly/prox_sensor = 6,/obj/item/assembly/igniter = 6)
	contraband = list(/obj/item/assembly/health = 3)

/obj/machinery/vending/wallmed1
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?"
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	req_access_txt = "5"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/stack/medical/bruise_pack = 2,/obj/item/stack/medical/ointment = 2,/obj/item/reagent_containers/hypospray/autoinjector = 4,/obj/item/healthanalyzer = 1)
	contraband = list(/obj/item/reagent_containers/syringe/charcoal = 4,/obj/item/reagent_containers/syringe/antiviral = 4,/obj/item/reagent_containers/food/pill/tox = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/wallmed2
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	req_access_txt = "5"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/reagent_containers/hypospray/autoinjector = 5,/obj/item/reagent_containers/syringe/charcoal = 3,/obj/item/stack/medical/bruise_pack = 3,
					/obj/item/stack/medical/ointment =3,/obj/item/healthanalyzer = 3)
	contraband = list(/obj/item/reagent_containers/food/pill/tox = 3)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/wallmed1/syndicate
	name = "\improper SyndiMed Plus"
	desc = "<b>EVIL</b> wall-mounted Medical Equipment dispenser."
	icon_state = "syndimed"
	icon_deny = "syndimed-deny"
	product_ads = "Go end some lives!;The best stuff for your ship.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access_txt = "150"
	products = list(/obj/item/stack/medical/bruise_pack = 2,/obj/item/stack/medical/ointment = 2,/obj/item/reagent_containers/hypospray/autoinjector = 4,/obj/item/healthanalyzer = 1)
	contraband = list(/obj/item/reagent_containers/syringe/charcoal = 4,/obj/item/reagent_containers/syringe/antiviral = 4,/obj/item/reagent_containers/food/pill/tox = 1)

/obj/machinery/vending/security
	name = "\improper SecTech"
	desc = "A security equipment vendor."
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	icon_deny = "sec-deny"
	req_access_txt = "1"
	products = list(/obj/item/restraints/handcuffs = 8,/obj/item/restraints/handcuffs/cable/zipties = 8,/obj/item/grenade/flashbang = 4,/obj/item/flash = 5,
					/obj/item/reagent_containers/food/snacks/donut = 12,/obj/item/storage/box/evidence = 6,/obj/item/flashlight/seclite = 4,/obj/item/restraints/legcuffs/bola/energy = 7,
					/obj/item/clothing/mask/muzzle/safety = 4)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,/obj/item/storage/fancy/donut_box = 2,/obj/item/hailer = 5)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/hydronutrients
	name = "\improper NutriMax"
	desc = "A plant nutrients vendor"
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	products = list(/obj/item/reagent_containers/glass/bottle/nutrient/ez = 30,/obj/item/reagent_containers/glass/bottle/nutrient/l4z = 20,/obj/item/reagent_containers/glass/bottle/nutrient/rh = 10,/obj/item/reagent_containers/spray/pestspray = 20,
					/obj/item/reagent_containers/syringe = 5,/obj/item/storage/bag/plants = 5,/obj/item/cultivator = 3,/obj/item/shovel/spade = 3,/obj/item/plant_analyzer = 4)
	contraband = list(/obj/item/reagent_containers/glass/bottle/ammonia = 10,/obj/item/reagent_containers/glass/bottle/diethylamine = 5)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

///obj/item/beezeez = 45,

/obj/machinery/vending/hydroseeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	products = list(/obj/item/seeds/aloe =3, /obj/item/seeds/ambrosia = 3, /obj/item/seeds/apple = 3, /obj/item/seeds/banana = 3, /obj/item/seeds/berry = 3,
						/obj/item/seeds/cabbage = 3, /obj/item/seeds/carrot = 3, /obj/item/seeds/cherry = 3, /obj/item/seeds/chanter = 3,
						/obj/item/seeds/chili = 3, /obj/item/seeds/cocoapod = 3, /obj/item/seeds/coffee = 3, /obj/item/seeds/comfrey =3, /obj/item/seeds/corn = 3,
						/obj/item/seeds/nymph =3, /obj/item/seeds/eggplant = 3, /obj/item/seeds/grape = 3, /obj/item/seeds/grass = 3, /obj/item/seeds/lemon = 3,
						/obj/item/seeds/lime = 3, /obj/item/seeds/onion = 3, /obj/item/seeds/orange = 3, /obj/item/seeds/peanuts = 3, /obj/item/seeds/pineapple = 3, /obj/item/seeds/potato = 3, /obj/item/seeds/poppy = 3,
						/obj/item/seeds/pumpkin = 3, /obj/item/seeds/replicapod = 3, /obj/item/seeds/wheat/rice = 3, /obj/item/seeds/soya = 3, /obj/item/seeds/sunflower = 3, /obj/item/seeds/sugarcane = 3,
						/obj/item/seeds/tea = 3, /obj/item/seeds/tobacco = 3, /obj/item/seeds/tomato = 3,
						/obj/item/seeds/tower = 3, /obj/item/seeds/watermelon = 3, /obj/item/seeds/wheat = 3, /obj/item/seeds/whitebeet = 3)
	contraband = list(/obj/item/seeds/amanita = 2, /obj/item/seeds/glowshroom = 2, /obj/item/seeds/liberty = 2, /obj/item/seeds/nettle = 2,
						/obj/item/seeds/plump = 2, /obj/item/seeds/reishi = 2, /obj/item/seeds/cannabis = 3, /obj/item/seeds/starthistle = 2, /obj/item/seeds/fungus = 3, /obj/item/seeds/random = 2)
	premium = list(/obj/item/reagent_containers/spray/waterflower = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/**
 *  Populate hydroseeds product_records
 *
 *  This needs to be customized to fetch the actual names of the seeds, otherwise
 *  the machine would simply list "packet of seeds" times 20
 */
/obj/machinery/vending/hydroseeds/build_inventory()
	var/list/all_products = list(
		list(products, CAT_NORMAL),
		list(contraband, CAT_HIDDEN),
		list(premium, CAT_COIN))

	for(var/current_list in all_products)
		var/category = current_list[2]

		for(var/entry in current_list[1])
			var/obj/item/seeds/S = new entry(src)
			var/name = S.name
			var/datum/data/vending_product/product = new/datum/data/vending_product(entry, name)

			product.price = (entry in prices) ? prices[entry] : 0
			product.amount = (current_list[1][entry]) ? current_list[1][entry] : 1
			product.max_amount = product.amount
			product.category = category

			product_records.Add(product)

/obj/machinery/vending/magivend
	name = "\improper MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	vend_delay = 15
	vend_reply = "Have an enchanted evening!"
	product_ads = "FJKLFJSD;AJKFLBJAKL;1234 LOONIES LOL!;>MFW;Kill them fuckers!;GET DAT FUKKEN DISK;HONK!;EI NATH;Destroy the station!;Admin conspiracies since forever!;Space-time bending hardware!"
	products = list(/obj/item/clothing/head/wizard = 1,
					/obj/item/clothing/suit/wizrobe = 1,
					/obj/item/clothing/head/wizard/red = 1,
					/obj/item/clothing/suit/wizrobe/red = 1,
					/obj/item/clothing/shoes/sandal = 1,
					/obj/item/clothing/suit/wizrobe/clown = 1,
					/obj/item/clothing/head/wizard/clown = 1,
					/obj/item/clothing/mask/gas/clownwiz = 1,
					/obj/item/clothing/shoes/clown_shoes/magical = 1,
					/obj/item/twohanded/staff = 2)
	contraband = list(/obj/item/reagent_containers/glass/bottle/wizarditis = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/autodrobe
	name = "\improper AutoDrobe"
	desc = "A vending machine for costumes."
	icon_state = "theater"
	icon_deny = "theater-deny"
	product_slogans = "Dress for success!;Suited and booted!;It's show time!;Why leave style up to fate? Use AutoDrobe!"
	vend_delay = 15
	vend_reply = "Thank you for using AutoDrobe!"
	products = list(/obj/item/clothing/suit/chickensuit = 1,/obj/item/clothing/head/chicken = 1,/obj/item/clothing/under/gladiator = 1,
					/obj/item/clothing/head/helmet/gladiator = 1,/obj/item/clothing/under/gimmick/rank/captain/suit = 1,/obj/item/clothing/head/flatcap = 1,
					/obj/item/clothing/suit/storage/labcoat/mad = 1,/obj/item/clothing/glasses/gglasses = 1,/obj/item/clothing/shoes/jackboots = 1,
					/obj/item/clothing/under/schoolgirl = 1,/obj/item/clothing/head/kitty = 1,/obj/item/clothing/under/blackskirt = 1,
					/obj/item/clothing/suit/toggle/owlwings = 1, /obj/item/clothing/under/owl = 1,/obj/item/clothing/mask/gas/owl_mask = 1,
					/obj/item/clothing/suit/toggle/owlwings/griffinwings = 1, /obj/item/clothing/under/griffin = 1, /obj/item/clothing/shoes/griffin = 1, /obj/item/clothing/head/griffin = 1,
					/obj/item/clothing/accessory/waistcoat = 1,/obj/item/clothing/under/suit_jacket = 1,/obj/item/clothing/head/that =1,/obj/item/clothing/under/kilt = 1,/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/glasses/monocle =1,/obj/item/clothing/head/bowlerhat = 1,/obj/item/cane = 1,/obj/item/clothing/under/sl_suit = 1,
					/obj/item/clothing/mask/fakemoustache = 1,/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 1,/obj/item/clothing/head/plaguedoctorhat = 1,/obj/item/clothing/mask/gas/plaguedoctor = 1,
					/obj/item/clothing/suit/apron = 1,/obj/item/clothing/under/waiter = 1,/obj/item/clothing/suit/jacket/miljacket = 1,
					/obj/item/clothing/suit/jacket/miljacket/white = 1, /obj/item/clothing/suit/jacket/miljacket/desert = 1, /obj/item/clothing/suit/jacket/miljacket/navy = 1,
					/obj/item/clothing/under/pirate = 1,/obj/item/clothing/suit/pirate_brown = 1,/obj/item/clothing/suit/pirate_black =1,/obj/item/clothing/under/pirate_rags =1,/obj/item/clothing/head/pirate = 1,/obj/item/clothing/head/bandana = 1,
					/obj/item/clothing/head/bandana = 1,/obj/item/clothing/under/soviet = 1,/obj/item/clothing/head/ushanka = 1,/obj/item/clothing/suit/imperium_monk = 1,
					/obj/item/clothing/mask/gas/cyborg = 1,/obj/item/clothing/suit/holidaypriest = 1,/obj/item/clothing/head/wizard/marisa/fake = 1,
					/obj/item/clothing/suit/wizrobe/marisa/fake = 1,/obj/item/clothing/under/sundress = 1,/obj/item/clothing/head/witchwig = 1,/obj/item/twohanded/staff/broom = 1,
					/obj/item/clothing/suit/wizrobe/fake = 1,/obj/item/clothing/head/wizard/fake = 1,/obj/item/twohanded/staff = 3,/obj/item/clothing/mask/gas/clown_hat/sexy = 1,
					/obj/item/clothing/under/rank/clown/sexy = 1,/obj/item/clothing/mask/gas/sexymime = 1,/obj/item/clothing/under/sexymime = 1,
					/obj/item/clothing/mask/face/bat = 1,/obj/item/clothing/mask/face/bee = 1,/obj/item/clothing/mask/face/bear = 1,/obj/item/clothing/mask/face/raven = 1,/obj/item/clothing/mask/face/jackal = 1,/obj/item/clothing/mask/face/fox = 1,/obj/item/clothing/mask/face/tribal = 1,/obj/item/clothing/mask/face/rat = 1,
					/obj/item/clothing/suit/apron/overalls = 1,
					/obj/item/clothing/head/rabbitears =1, /obj/item/clothing/head/sombrero = 1, /obj/item/clothing/suit/poncho = 1,
					/obj/item/clothing/suit/poncho/green = 1, /obj/item/clothing/suit/poncho/red = 1, /obj/item/clothing/accessory/blue = 1, /obj/item/clothing/accessory/red = 1, /obj/item/clothing/accessory/black = 1, /obj/item/clothing/accessory/horrible = 1,
					/obj/item/clothing/under/maid = 1, /obj/item/clothing/under/janimaid = 1,
					/obj/item/clothing/under/jester = 1, /obj/item/clothing/head/jester = 1,
					/obj/item/clothing/under/pants/camo = 1, /obj/item/clothing/mask/bandana = 1, /obj/item/clothing/mask/bandana/black = 1,
					/obj/item/clothing/shoes/singery = 1,/obj/item/clothing/under/singery = 1,
					/obj/item/clothing/shoes/singerb = 1,/obj/item/clothing/under/singerb = 1,
					/obj/item/clothing/suit/hooded/carp_costume = 1,/obj/item/clothing/suit/hooded/bee_costume = 1,
					/obj/item/clothing/suit/snowman = 1,/obj/item/clothing/head/snowman = 1,
					/obj/item/clothing/head/cueball = 1,/obj/item/clothing/under/scratch = 1,
					/obj/item/clothing/under/victdress = 1, /obj/item/clothing/under/victdress/red = 1, /obj/item/clothing/suit/victcoat = 1, /obj/item/clothing/suit/victcoat/red = 1,
					/obj/item/clothing/under/victsuit = 1, /obj/item/clothing/under/victsuit/redblk = 1, /obj/item/clothing/under/victsuit/red = 1, /obj/item/clothing/suit/tailcoat = 1,
					/obj/item/clothing/suit/draculacoat = 1, /obj/item/clothing/head/zepelli = 1)
	contraband = list(/obj/item/clothing/suit/judgerobe = 1,/obj/item/clothing/head/powdered_wig = 1,/obj/item/gun/magic/wand = 1, /obj/item/clothing/mask/balaclava=1, /obj/item/clothing/mask/horsehead = 2)
	premium = list(/obj/item/clothing/suit/hgpirate = 1, /obj/item/clothing/head/hgpiratecap = 1, /obj/item/clothing/head/helmet/roman = 1, /obj/item/clothing/head/helmet/roman/legionaire = 1, /obj/item/clothing/under/roman = 1, /obj/item/clothing/shoes/roman = 1, /obj/item/shield/riot/roman = 1)
	refill_canister = /obj/item/vending_refill/autodrobe

/obj/machinery/vending/autodrobe/New()
	..()
	component_parts = list()
	var/obj/item/circuitboard/vendor/V = new(null)
	V.set_type(type)
	component_parts += V
	component_parts += new /obj/item/vending_refill/autodrobe(0)
	component_parts += new /obj/item/vending_refill/autodrobe(0)
	component_parts += new /obj/item/vending_refill/autodrobe(0)

/obj/machinery/vending/dinnerware
	name = "\improper Plasteel Chef's Dinnerware Vendor"
	desc = "A kitchen and restaurant equipment vendor."
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	products = list(/obj/item/storage/bag/tray = 8,/obj/item/kitchen/utensil/fork = 6,
					/obj/item/kitchen/knife = 3,/obj/item/kitchen/rollingpin = 2,
					/obj/item/kitchen/sushimat = 3,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 8, /obj/item/clothing/suit/chef/classic = 2,
					/obj/item/reagent_containers/food/condiment/pack/ketchup = 5,
					/obj/item/reagent_containers/food/condiment/pack/hotsauce = 5,
					/obj/item/reagent_containers/food/condiment/saltshaker =5,
					/obj/item/reagent_containers/food/condiment/peppermill =5,
					/obj/item/whetstone = 2, /obj/item/mixing_bowl = 10,
					/obj/item/kitchen/mould/bear = 1, /obj/item/kitchen/mould/worm = 1,
					/obj/item/kitchen/mould/bean = 1, /obj/item/kitchen/mould/ball = 1,
					/obj/item/kitchen/mould/cane = 1, /obj/item/kitchen/mould/cash = 1,
					/obj/item/kitchen/mould/coin = 1, /obj/item/kitchen/mould/loli = 1,
					/obj/item/kitchen/cutter = 2)
	contraband = list(/obj/item/kitchen/rollingpin = 2, /obj/item/kitchen/knife/butcher = 2)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/sovietsoda
	name = "\improper BODA"
	desc = "Old sweet water vending machine."
	icon_state = "sovietsoda"
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	products = list(/obj/item/reagent_containers/food/drinks/drinkingglass/soda = 30)
	contraband = list(/obj/item/reagent_containers/food/drinks/drinkingglass/cola = 20)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	//req_access_txt = "12" //Maintenance access
	products = list(/obj/item/stack/cable_coil/random = 10,/obj/item/crowbar = 5,/obj/item/weldingtool = 3,/obj/item/wirecutters = 5,
					/obj/item/wrench = 5,/obj/item/analyzer = 5,/obj/item/t_scanner = 5,/obj/item/screwdriver = 5)
	contraband = list(/obj/item/weldingtool/hugetank = 2,/obj/item/clothing/gloves/color/fyellow = 2)
	premium = list(/obj/item/clothing/gloves/color/yellow = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/engivend
	name = "\improper Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	icon_deny = "engivend-deny"
	req_access_txt = "11" //Engineering Equipment access
	products = list(/obj/item/clothing/glasses/meson = 2,/obj/item/multitool = 4,/obj/item/airlock_electronics = 10,/obj/item/firelock_electronics = 10,/obj/item/firealarm_electronics = 10,/obj/item/apc_electronics = 10,/obj/item/airalarm_electronics = 10,/obj/item/stock_parts/cell/high = 10,/obj/item/camera_assembly = 10)
	contraband = list(/obj/item/stock_parts/cell/potato = 3)
	premium = list(/obj/item/storage/belt/utility = 3)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

//This one's from bay12
/obj/machinery/vending/engineering
	name = "\improper Robco Tool Maker"
	desc = "Everything you need for do-it-yourself station repair."
	icon_state = "engi"
	icon_deny = "engi-deny"
	req_access_txt = "11"
	products = list(/obj/item/clothing/under/rank/chief_engineer = 4,/obj/item/clothing/under/rank/engineer = 4,/obj/item/clothing/shoes/workboots = 4,/obj/item/clothing/head/hardhat = 4,
					/obj/item/storage/belt/utility = 4,/obj/item/clothing/glasses/meson = 4,/obj/item/clothing/gloves/color/yellow = 4, /obj/item/screwdriver = 12,
					/obj/item/crowbar = 12,/obj/item/wirecutters = 12,/obj/item/multitool = 12,/obj/item/wrench = 12,/obj/item/t_scanner = 12,
					/obj/item/stack/cable_coil/heavyduty = 8, /obj/item/stock_parts/cell = 8, /obj/item/weldingtool = 8,/obj/item/clothing/head/welding = 8,
					/obj/item/light/tube = 10,/obj/item/clothing/suit/fire = 4, /obj/item/stock_parts/scanning_module = 5,/obj/item/stock_parts/micro_laser = 5,
					/obj/item/stock_parts/matter_bin = 5,/obj/item/stock_parts/manipulator = 5,/obj/item/stock_parts/console_screen = 5)
	// There was an incorrect entry (cablecoil/power).  I improvised to cablecoil/heavyduty.
	// Another invalid entry, /obj/item/circuitry.  I don't even know what that would translate to, removed it.
	// The original products list wasn't finished.  The ones without given quantities became quantity 5.  -Sayu
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

//This one's from bay12
/obj/machinery/vending/robotics
	name = "\improper Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access_txt = "29"
	products = list(/obj/item/clothing/suit/storage/labcoat = 4,/obj/item/clothing/under/rank/roboticist = 4,/obj/item/stack/cable_coil = 4,/obj/item/flash = 4,
					/obj/item/stock_parts/cell/high = 12, /obj/item/assembly/prox_sensor = 3,/obj/item/assembly/signaler = 3,/obj/item/healthanalyzer = 3,
					/obj/item/scalpel = 2,/obj/item/circular_saw = 2,/obj/item/tank/anesthetic = 2,/obj/item/clothing/mask/breath/medical = 5,
					/obj/item/screwdriver = 5,/obj/item/crowbar = 5)
	//everything after the power cell had no amounts, I improvised.  -Sayu
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/sustenance
	name = "\improper Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	product_slogans = "Enjoy your meal.;Enough calories to support strenuous labor."
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "sustenance"
	products = list(/obj/item/reagent_containers/food/snacks/tofu = 24,
					/obj/item/reagent_containers/food/drinks/ice = 12,
					/obj/item/reagent_containers/food/snacks/candy/candy_corn = 6)
	contraband = list(/obj/item/kitchen/knife = 6)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0)

/obj/machinery/vending/hatdispenser
	name = "\improper Hatlord 9000"
	desc = "It doesn't seem the slightest bit unusual. This frustrates you immensely."
	icon_state = "hats"
	product_ads = "Warning, not all hats are dog/monkey compatible. Apply forcefully with care.;Apply directly to the forehead.;Who doesn't love spending cash on hats?!;From the people that brought you collectable hat crates, Hatlord!"
	products = list(/obj/item/clothing/head/bowlerhat = 10,
					/obj/item/clothing/head/beaverhat = 10,
					/obj/item/clothing/head/boaterhat = 10,
					/obj/item/clothing/head/fedora = 10,
					/obj/item/clothing/head/fez = 10,
					/obj/item/clothing/head/beret = 10)
	contraband = list(/obj/item/clothing/head/bearpelt = 5)
	premium = list(/obj/item/clothing/head/soft/rainbow = 1)
	refill_canister = /obj/item/vending_refill/hatdispenser

/obj/machinery/vending/suitdispenser
	name = "\improper Suitlord 9000"
	desc = "You wonder for a moment why all of your shirts and pants come conjoined. This hurts your head and you stop thinking about it."
	icon_state = "suits"
	product_ads = "Pre-Ironed, Pre-Washed, Pre-Wor-*BZZT*;Blood of your enemies washes right out!;Who are YOU wearing?;Look dapper! Look like an idiot!;Dont carry your size? How about you shave off some pounds you fat lazy- *BZZT*"
	products = list(/obj/item/clothing/under/color/black = 10,/obj/item/clothing/under/color/blue = 10,/obj/item/clothing/under/color/green = 10,/obj/item/clothing/under/color/grey = 10,/obj/item/clothing/under/color/pink = 10,/obj/item/clothing/under/color/red = 10,
					/obj/item/clothing/under/color/white = 10, /obj/item/clothing/under/color/yellow = 10,/obj/item/clothing/under/color/lightblue = 10,/obj/item/clothing/under/color/aqua = 10,/obj/item/clothing/under/color/purple = 10,/obj/item/clothing/under/color/lightgreen = 10,
					/obj/item/clothing/under/color/lightblue = 10,/obj/item/clothing/under/color/lightbrown = 10,/obj/item/clothing/under/color/brown = 10,/obj/item/clothing/under/color/yellowgreen = 10,/obj/item/clothing/under/color/darkblue = 10,/obj/item/clothing/under/color/lightred = 10, /obj/item/clothing/under/color/darkred = 10)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 5,/obj/item/clothing/under/color/orange = 5)
	premium = list(/obj/item/clothing/under/rainbow = 1)
	refill_canister = /obj/item/vending_refill/suitdispenser

/obj/machinery/vending/shoedispenser
	name = "\improper Shoelord 9000"
	desc = "Wow, hatlord looked fancy, suitlord looked streamlined, and this is just normal. The guy who designed these must be an idiot."
	icon_state = "shoes"
	product_ads = "Put your foot down!;One size fits all!;IM WALKING ON SUNSHINE!;No hobbits allowed.;NO PLEASE WILLY, DONT HURT ME- *BZZT*"
	products = list(/obj/item/clothing/shoes/black = 10,/obj/item/clothing/shoes/brown = 10,/obj/item/clothing/shoes/blue = 10,/obj/item/clothing/shoes/green = 10,/obj/item/clothing/shoes/yellow = 10,/obj/item/clothing/shoes/purple = 10,/obj/item/clothing/shoes/red = 10,/obj/item/clothing/shoes/white = 10,/obj/item/clothing/shoes/sandal=10)
	contraband = list(/obj/item/clothing/shoes/orange = 5)
	premium = list(/obj/item/clothing/shoes/rainbow = 1)
	refill_canister = /obj/item/vending_refill/shoedispenser

/obj/machinery/vending/syndicigs
	name = "\improper Suspicious Cigarette Machine"
	desc = "Smoke 'em if you've got 'em."
	product_slogans = "Space cigs taste good like a cigarette should.;I'd rather toolbox than switch.;Smoke!;Don't believe the reports - smoke today!"
	product_ads = "Probably not bad for you!;Don't believe the scientists!;It's good for you!;Don't quit, buy more!;Smoke!;Nicotine heaven.;Best cigarettes since 2150.;Award-winning cigs."
	vend_delay = 34
	icon_state = "cigs"
	products = list(/obj/item/storage/fancy/cigarettes/syndicate = 10,/obj/item/lighter/random = 5)

/obj/machinery/vending/syndisnack
	name = "\improper Getmore Chocolate Corp"
	desc = "A modified snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars"
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snack"
	products = list(/obj/item/reagent_containers/food/snacks/chips =6,/obj/item/reagent_containers/food/snacks/sosjerky = 6,
					/obj/item/reagent_containers/food/snacks/syndicake = 6, /obj/item/reagent_containers/food/snacks/cheesiehonkers = 6)
	refill_canister = /obj/item/vending_refill/snack

//This one's from NTstation
//don't forget to change the refill size if you change the machine's contents!
/obj/machinery/vending/clothing
	name = "\improper  ClothesMate" //renamed to make the slogan rhyme
	desc = "A vending machine for clothing."
	icon_state = "clothes"
	product_slogans = "Dress for success!;Prepare to look swagalicious!;Look at all this free swag!;Why leave style up to fate? Use the ClothesMate!"
	vend_delay = 15
	vend_reply = "Thank you for using the ClothesMate!"
	products = list(/obj/item/clothing/head/that=2,/obj/item/clothing/head/fedora=1,/obj/item/clothing/glasses/monocle=1,
	/obj/item/clothing/under/suit_jacket/navy=2,/obj/item/clothing/under/kilt=1,/obj/item/clothing/under/overalls=1,
	/obj/item/clothing/under/suit_jacket/really_black=2,/obj/item/clothing/suit/storage/lawyer/blackjacket=2,/obj/item/clothing/under/pants/jeans=3,/obj/item/clothing/under/pants/classicjeans=2,
	/obj/item/clothing/under/pants/camo = 1,/obj/item/clothing/under/pants/blackjeans=2,/obj/item/clothing/under/pants/khaki=2,
	/obj/item/clothing/under/pants/white=2,/obj/item/clothing/under/pants/red=1,/obj/item/clothing/under/pants/black=2,
	/obj/item/clothing/under/pants/tan=2,/obj/item/clothing/under/pants/blue=1,/obj/item/clothing/under/pants/track=1,/obj/item/clothing/suit/jacket/miljacket = 1,
	/obj/item/clothing/accessory/scarf/red=1,/obj/item/clothing/accessory/scarf/green=1,/obj/item/clothing/accessory/scarf/darkblue=1,
	/obj/item/clothing/accessory/scarf/purple=1,/obj/item/clothing/accessory/scarf/yellow=1,/obj/item/clothing/accessory/scarf/orange=1,
	/obj/item/clothing/accessory/scarf/lightblue=1,/obj/item/clothing/accessory/scarf/white=1,/obj/item/clothing/accessory/scarf/black=1,
	/obj/item/clothing/accessory/scarf/zebra=1,/obj/item/clothing/accessory/scarf/christmas=1,/obj/item/clothing/accessory/stripedredscarf=1,
	/obj/item/clothing/accessory/stripedbluescarf=1,/obj/item/clothing/accessory/stripedgreenscarf=1,/obj/item/clothing/accessory/waistcoat=1,
	/obj/item/clothing/under/sundress=2,/obj/item/clothing/under/stripeddress = 1, /obj/item/clothing/under/sailordress = 1, /obj/item/clothing/under/redeveninggown = 1, /obj/item/clothing/under/blacktango=1,/obj/item/clothing/suit/jacket=3,
	/obj/item/clothing/glasses/regular=2,/obj/item/clothing/glasses/sunglasses/fake=2,/obj/item/clothing/head/sombrero=1,/obj/item/clothing/suit/poncho=1,
	/obj/item/clothing/suit/ianshirt=1,/obj/item/clothing/shoes/laceup=2,/obj/item/clothing/shoes/black=4,
	/obj/item/clothing/shoes/sandal=1, /obj/item/clothing/gloves/fingerless=2,
	/obj/item/storage/belt/fannypack=1, /obj/item/storage/belt/fannypack/blue=1, /obj/item/storage/belt/fannypack/red=1)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool=1,/obj/item/clothing/mask/balaclava=1,/obj/item/clothing/head/ushanka=1,/obj/item/clothing/under/soviet=1,/obj/item/storage/belt/fannypack/black=1)
	premium = list(/obj/item/clothing/under/suit_jacket/checkered=1,/obj/item/clothing/head/mailman=1,/obj/item/clothing/under/rank/mailman=1,/obj/item/clothing/suit/jacket/leather=1,/obj/item/clothing/under/pants/mustangjeans=1)
	refill_canister = /obj/item/vending_refill/clothing

/obj/machinery/vending/clothing/New()
	..()
	component_parts = list()
	var/obj/item/circuitboard/vendor/V = new(null)
	V.set_type(type)
	component_parts += V
	component_parts += new /obj/item/vending_refill/clothing(0)
	component_parts += new /obj/item/vending_refill/clothing(0)
	component_parts += new /obj/item/vending_refill/clothing(0)

/obj/machinery/vending/artvend
	name = "\improper ArtVend"
	desc = "A vending machine for art supplies."
	product_slogans = "Stop by for all your artistic needs!;Color the floors with crayons, not blood!;Don't be a starving artist, use ArtVend. ;Don't fart, do art!"
	product_ads = "Just like Kindergarten!;Now with 1000% more vibrant colors!;Screwing with the janitor was never so easy!;Creativity is at the heart of every spessman."
	vend_delay = 15
	icon_state = "artvend"
	products = list(/obj/item/stack/cable_coil/random = 10,/obj/item/camera = 4,/obj/item/camera_film = 6,
	/obj/item/storage/photo_album = 2,/obj/item/stack/wrapping_paper = 4,/obj/item/stack/tape_roll = 5,/obj/item/stack/packageWrap = 4,
	/obj/item/storage/fancy/crayons = 4,/obj/item/hand_labeler = 4,/obj/item/paper = 10,
	/obj/item/c_tube = 10,/obj/item/pen = 5,/obj/item/pen/blue = 5,
	/obj/item/pen/red = 5)
	contraband = list(/obj/item/toy/crayon/mime = 1,/obj/item/toy/crayon/rainbow = 1)
	premium = list(/obj/item/poster/random_contraband = 5)

/obj/machinery/vending/crittercare
	name = "\improper CritterCare"
	desc = "A vending machine for pet supplies."
	product_slogans = "Stop by for all your animal's needs!;Cuddly pets deserve a stylish collar!;Pets in space, what could be more adorable?;Freshest fish eggs in the system!;Rocks are the perfect pet, buy one today!"
	product_ads = "House-training costs extra!;Now with 1000% more cat hair!;Allergies are a sign of weakness!;Dogs are man's best friend. Remember that Vulpkanin!; Heat lamps for Unathi!; Vox-y want a cracker?"
	vend_delay = 15
	icon_state = "crittercare"
	products = list(/obj/item/clothing/accessory/petcollar = 5, /obj/item/storage/firstaid/aquatic_kit/full =5, /obj/item/fish_eggs/goldfish = 5,
					/obj/item/fish_eggs/clownfish = 5, /obj/item/fish_eggs/shark = 5, /obj/item/fish_eggs/feederfish = 10,
					/obj/item/fish_eggs/salmon = 5, /obj/item/fish_eggs/catfish = 5, /obj/item/fish_eggs/glofish = 5,
					/obj/item/fish_eggs/electric_eel = 5, /obj/item/fish_eggs/shrimp = 10, /obj/item/toy/pet_rock = 5,
					)
	prices = list(/obj/item/clothing/accessory/petcollar = 50, /obj/item/storage/firstaid/aquatic_kit/full = 60, /obj/item/fish_eggs/goldfish = 10,
					/obj/item/fish_eggs/clownfish = 10, /obj/item/fish_eggs/shark = 10, /obj/item/fish_eggs/feederfish = 5,
					/obj/item/fish_eggs/salmon = 10, /obj/item/fish_eggs/catfish = 10, /obj/item/fish_eggs/glofish = 10,
					/obj/item/fish_eggs/electric_eel = 10, /obj/item/fish_eggs/shrimp = 5, /obj/item/toy/pet_rock = 100,
					)
	contraband = list(/obj/item/fish_eggs/babycarp = 5)
	premium = list(/obj/item/toy/pet_rock/fred = 1, /obj/item/toy/pet_rock/roxie = 1)
	refill_canister = /obj/item/vending_refill/crittercare

/obj/machinery/vending/crittercare/free
	prices = list()

/obj/machinery/vending/crittercare/New()
	..()
	component_parts = list()
	var/obj/item/circuitboard/vendor/V = new(null)
	V.set_type(type)
	component_parts += V
	component_parts += new /obj/item/vending_refill/crittercare(0)
	component_parts += new /obj/item/vending_refill/crittercare(0)
	component_parts += new /obj/item/vending_refill/crittercare(0)
