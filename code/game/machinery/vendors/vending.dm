/**
 *  Datum used to hold information about a product in a vending machine
 */
/datum/data/vending_product
	name = "generic"
	///Typepath of the product that is created when this record "sells"
	var/product_path = null
	///How many of this product we currently have
	var/amount = 0
	///How many we can store at maximum
	var/max_amount = 0
	/// Price to buy one
	var/price = 0

/obj/machinery/economy/vending
	name = "\improper Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	face_while_pulling = TRUE
	max_integrity = 300
	integrity_failure = 100
	armor = list(melee = 20, bullet = 0, laser = 0, energy = 0, bomb = 0, rad = 0, fire = 50, acid = 70)

	/// Icon_state when vending
	var/icon_vend
	/// Icon_state when denying access
	var/icon_deny
	/// Icon to be an overlay over the base sprite
	var/icon_addon
	/// Icon for the broken overlay, defaults to icon_state + _broken
	var/icon_broken
	/// Icon for the off overlay, defaults to icon_state + _off
	var/icon_off
	/// Icon for the panel overlay, defaults to icon_state + _panel
	var/icon_panel
	/// Icon for the lightmask, defaults to icon_state + _off, _lightmask if one is defined.
	var/icon_lightmask
	// Power
	idle_power_consumption = 10
	var/vend_power_usage = 150

	var/light_range_on = 1
	var/light_power_on = 0.5

	// Vending-related
	/// No sales pitches if off
	var/active = TRUE
	/// If off, vendor is busy and unusable until current action finishes
	var/vend_ready = TRUE
	/// How long vendor takes to vend one item.
	var/vend_delay = 10
	/// Item currently being bought
	var/datum/data/vending_product/currently_vending

	// To be filled out at compile time
	var/list/products	= list()	// For each, use the following pattern:
	var/list/contraband	= list()	// list(/type/path = amount,/type/path2 = amount2)
	var/list/prices     = list()	// Prices for each item, list(/type/path = price), items not in the list don't have a price.

	// List of vending_product items available.
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/imagelist = list()

	/// Unimplemented list of ads that are meant to show up somewhere, but don't.
	var/list/ads_list = list()

	// Stuff relating vocalizations
	/// List of slogans the vendor will say, optional
	var/list/slogan_list = list()
	var/vend_reply				//Thank you for shopping!
	/// If true, prevent saying sales pitches
	var/shut_up = FALSE
	///can we access the hidden inventory?
	var/extended_inventory = FALSE
	var/last_reply = 0
	var/last_slogan = 0			//When did we last pitch?
	var/slogan_delay = 10 MINUTES		//How long until we can pitch again?

	//The type of refill canisters used by this machine.
	var/obj/item/vending_refill/refill_canister

	// Things that can go wrong
	/// Allows people to access a vendor that's normally access restricted.
	emagged = FALSE
	/// Shocks people like an airlock
	var/seconds_electrified = 0
	/// Fire items at customers! We're broken!
	var/shoot_inventory = FALSE
	/// How hard are we firing the items?
	var/shoot_speed = 3
	/// How often are we firing the items? (prob(...))
	var/shoot_chance = 2

	/// If true, enforce access checks on customers. Disabled by messing with wires.
	var/scan_id = TRUE

	var/datum/wires/vending/wires

	/// boolean, whether this vending machine can accept people inserting items into it, used for coffee vendors
	var/item_slot = FALSE
	/// the actual item inserted
	var/obj/item/inserted_item

	/// blocks further flickering while true
	var/flickering = FALSE
	/// do I look unpowered, even when powered?
	var/force_no_power_icon_state = FALSE

	///the money account that is tethered to this vendor
	var/datum/money_account/vendor_account

	/// If this vending machine can be tipped or not
	var/tiltable = TRUE
	/// If this vendor is currently tipped
	var/tilted = FALSE
	/// Amount of damage to deal when tipped
	var/squish_damage = 40  // yowch
	/// Factor of extra damage to deal when triggering a crit
	var/crit_damage_factor = 2
	/// Factor of extra damage to deal when you knock it over onto yourself
	var/self_knockover_factor = 1.5
	/// number of shards to apply when a crit embeds
	var/num_shards = 7
	/// Last time the machine was punched
	var/last_hit_time = 0
	/// How long to wait before resetting the warning cooldown
	var/hit_warning_cooldown_length = 10 SECONDS

	/// If the vendor should tip on anyone who walks by. Mainly used for brand intelligence
	var/aggressive = FALSE

	/// How often slogans will be used by vendors if they're aggressive.
	var/aggressive_slogan_delay = (1 MINUTES)

	/// The category of this vendor. Used for announcing brand intelligence.
	var/category = VENDOR_TYPE_GENERIC

/obj/machinery/economy/vending/Initialize(mapload)
	. = ..()
	var/build_inv = FALSE
	if(!refill_canister)
		build_inv = TRUE
	else
		component_parts = list()
		var/obj/item/circuitboard/vendor/V = new
		V.set_type(replacetext(initial(name), "\improper", ""))
		component_parts += V
		component_parts += new refill_canister
		RefreshParts()

	wires = new(src)
	if(build_inv) //non-constructable vending machine
		build_inventory(products, product_records)
		build_inventory(contraband, hidden_records)
	for(var/datum/data/vending_product/R in (product_records + hidden_records))
		var/obj/item/I = R.product_path
		var/pp = replacetext(replacetext("[R.product_path]", "/obj/item/", ""), "/", "-")
		imagelist[pp] = "[icon2base64(icon(initial(I.icon), initial(I.icon_state), SOUTH, 1))]"

	if(LAZYLEN(slogan_list))
		// So not all machines speak at the exact same time.
		// The first time this machine says something will be at slogantime + this random value,
		// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is created.
		last_slogan = world.time + rand(0, slogan_delay)

	if(account_database)
		vendor_account = account_database.vendor_account

	update_icon(UPDATE_OVERLAYS)
	reconnect_database()
	power_change()
	RegisterSignal(src, COMSIG_MOVABLE_UNTILTED, PROC_REF(on_untilt))
	RegisterSignal(src, COMSIG_MOVABLE_TRY_UNTILT, PROC_REF(on_try_untilt))

/obj/machinery/economy/vending/Destroy()
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	QDEL_NULL(inserted_item)
	return ..()

/obj/machinery/economy/vending/examine(mob/user)
	. = ..()
	if(aggressive)
		. += "<span class='warning'>Its product lights seem to be blinking ominously...</span>"

/obj/machinery/economy/vending/RefreshParts()         //Better would be to make constructable child
	if(!component_parts)
		return

	product_records = list()
	hidden_records = list()
	if(refill_canister)
		build_inventory(products, product_records, start_empty = TRUE)
		build_inventory(contraband, hidden_records, start_empty = TRUE)
	for(var/obj/item/vending_refill/VR in component_parts)
		restock(VR)

/obj/machinery/economy/vending/update_overlays()
	. = ..()
	underlays.Cut()
	if(panel_open)
		. += "[icon_panel ? "[icon_panel]_panel" : "[icon_state]_panel"]"
	if(icon_addon)
		. += "[icon_addon]"
	if((stat & (BROKEN|NOPOWER)) || force_no_power_icon_state)
		. += "[icon_off ? "[icon_off]_off" : "[icon_state]_off"]"
		if(stat & BROKEN)
			. += "[icon_broken ? "[icon_broken]_broken" : "[icon_state]_broken"]"
		return
	if(light)
		underlays += emissive_appearance(icon, "[icon_lightmask ? "[icon_lightmask]_lightmask" : "[icon_state]_off"]")

/*
 * Reimp, flash the screen on and off repeatedly.
 */
/obj/machinery/economy/vending/flicker()
	if(flickering)
		return FALSE

	if(stat & (BROKEN|NOPOWER))
		return FALSE

	flickering = TRUE
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/economy/vending, flicker_event))

	return TRUE

/*
 * Proc to be called by invoke_async in the above flicker() proc.
 */
/obj/machinery/economy/vending/proc/flicker_event()
	var/amount = rand(5, 15)

	for(var/i in 1 to amount)
		force_no_power_icon_state = TRUE
		set_light(0)
		update_icon(UPDATE_OVERLAYS)
		sleep(rand(1, 3))

		force_no_power_icon_state = FALSE
		set_light(light_range_on, light_power_on)
		update_icon(UPDATE_OVERLAYS)
		sleep(rand(1, 10))
	update_icon(UPDATE_OVERLAYS)
	flickering = FALSE

/**
 *  Build src.produdct_records from the products lists
 *
 *  src.products, src.contraband, src.premium, and src.prices allow specifying
 *  products that the vending machine is to carry without manually populating
 *  src.product_records.
 */
/obj/machinery/economy/vending/proc/build_inventory(list/productlist, list/recordlist, start_empty = FALSE)
	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		if(isnull(amount))
			amount = 0

		var/atom/temp = typepath
		var/datum/data/vending_product/R = new /datum/data/vending_product()
		R.name = initial(temp.name)
		R.product_path = typepath
		if(!start_empty)
			R.amount = amount
		R.max_amount = amount
		R.price = (typepath in prices) ? prices[typepath] : 0
		recordlist += R
/**
  * Refill a vending machine from a refill canister
  *
  * This takes the products from the refill canister and then fills the products,contraband and premium product categories
  *
  * Arguments:
  * * canister - the vending canister we are refilling from
  */
/obj/machinery/economy/vending/proc/restock(obj/item/vending_refill/canister)
	if(!canister.products)
		canister.products = products.Copy()
	if(!canister.contraband)
		canister.contraband = contraband.Copy()
	. = 0
	. += refill_inventory(canister.products, product_records)
	. += refill_inventory(canister.contraband, hidden_records)
/**
  * Refill our inventory from the passed in product list into the record list
  *
  * Arguments:
  * * productlist - list of types -> amount
  * * recordlist - existing record datums
  */
/obj/machinery/economy/vending/proc/refill_inventory(list/productlist, list/recordlist)
	. = 0
	for(var/datum/data/vending_product/record as anything in recordlist)
		var/diff = min(record.max_amount - record.amount, productlist[record.product_path])
		if(diff)
			productlist[record.product_path] -= diff
			record.amount += diff
			. += diff
/**
  * Set up a refill canister that matches this machines products
  *
  * This is used when the machine is deconstructed, so the items aren't "lost"
  */
/obj/machinery/economy/vending/proc/update_canister()
	if(!component_parts)
		return

	var/obj/item/vending_refill/R = locate() in component_parts
	if(!R)
		CRASH("Constructible vending machine did not have a refill canister")

	R.products = unbuild_inventory(product_records)
	R.contraband = unbuild_inventory(hidden_records)

/**
  * Given a record list, go through and and return a list of type -> amount
  */
/obj/machinery/economy/vending/proc/unbuild_inventory(list/recordlist)
	. = list()
	for(var/datum/data/vending_product/record as anything in recordlist)
		.[record.product_path] += record.amount

/obj/machinery/economy/vending/deconstruct(disassembled = TRUE)
	eject_item()
	if(!refill_canister) //the non constructable vendors drop metal instead of a machine frame.
		new /obj/item/stack/sheet/metal(loc, 3)
		qdel(src)
	else
		..()

/obj/machinery/economy/vending/proc/on_try_untilt(atom/source, mob/user)
	if(user && (!Adjacent(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)))
		return COMPONENT_BLOCK_UNTILT

/obj/machinery/economy/vending/attackby(obj/item/I, mob/user, params)
	if(tilted)
		if(user.a_intent == INTENT_HELP)
			to_chat(user, "<span class='warning'>[src] is tipped over and non-functional! You'll need to right it first.</span>")
			return
		return ..()

	if(isspacecash(I))
		insert_cash(I, user)
		return
	if(istype(I, /obj/item/coin))
		to_chat(user, "<span class='warning'>[src] does not accept coins.</span>")
		return
	if(refill_canister && istype(I, refill_canister))
		if(stat & (BROKEN|NOPOWER))
			to_chat(user, "<span class='notice'>[src] does not respond.</span>")
			return

		var/obj/item/vending_refill/canister = I
		var/transferred = restock(canister)
		if(!transferred && !canister.get_part_rating()) // It transferred no products and has no products left, thus it is empty
			to_chat(user, "<span class='warning'>[canister] is empty!</span>")
		else if(transferred) // We transferred some items
			to_chat(user, "<span class='notice'>You loaded [transferred] items in [src].</span>")
		else // Nothing transferred, parts are still left, nothing to restock!
			to_chat(user, "<span class='warning'>There's nothing to restock!</span>")
		return

	if(item_slot_check(user, I))
		insert_item(user, I)
		return
	. = ..()
	if(tiltable && !tilted && I.force)
		if(resistance_flags & INDESTRUCTIBLE)
			// no goodies, but also no tilts
			return
		var/should_warn = world.time > last_hit_time + hit_warning_cooldown_length
		last_hit_time = world.time
		if(should_warn)
			visible_message("<span class='warning'>[src] seems to sway a bit!</span>")
			to_chat(user, "<span class='danger'>You might want to think twice about doing that again, [src] looks like it could come crashing down!</span>")
			return

		switch(rand(1, 100))
			if(1 to 5)
				freebie(user, 3)
			if(6 to 15)
				freebie(user, 2)
			if(16 to 25)
				freebie(user, 1)
			if(26 to 75)
				return
			if(76 to 90)
				tilt(user)
			if(91 to 100)
				tilt(user, crit = TRUE)


/obj/machinery/economy/vending/proc/freebie(mob/user, num_freebies)
	visible_message("<span class='notice'>[num_freebies] free goodie\s tumble[num_freebies > 1 ? "" : "s"] out of [src]!</span>")

	for(var/i in 1 to num_freebies)
		for(var/datum/data/vending_product/R in shuffle(product_records))

			if(R.amount <= 0)
				continue

			var/dump_path = R.product_path
			if(!dump_path)
				continue
			new dump_path(get_turf(src))
			R.amount--
			break

/obj/machinery/economy/vending/HasProximity(atom/movable/AM)
	if(!aggressive || tilted || !tiltable)
		return

	if(isliving(AM) && prob(25))
		AM.visible_message(
			"<span class='danger'>[src] suddenly topples over onto [AM]!</span>",
			"<span class='userdanger'>[src] topples over onto you without warning!</span>"
		)
		tilt(AM, prob(5), FALSE)
		aggressive = FALSE
		// NOTE: AFTER THE GREAT MASSACRE OF 4/22/23 IT HAS BECOME INCREDIBLY CLEAR THAT NOT SETTING AGGRESSIVE TO FALSE HERE IS A BAD BAD IDEA
		// ALSO DEAR GOD DO NOT MAKE IT MORE LIKELY FOR THEM TO CRIT OR NOT

/obj/machinery/economy/vending/crowbar_act(mob/user, obj/item/I)
	if(!component_parts)
		return
	. = TRUE
	if(tilted)
		to_chat(user, "<span class='warning'>You'll need to right it first!</span>")
		return
	default_deconstruction_crowbar(user, I)

/obj/machinery/economy/vending/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(tilted)
		to_chat(user, "<span class='warning'>You'll need to right it first!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	wires.Interact(user)

/obj/machinery/economy/vending/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(tilted)
		to_chat(user, "<span class='warning'>You'll need to right it first!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!anchored)
		return
	panel_open = !panel_open

	if(panel_open)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE

	update_icon(UPDATE_OVERLAYS)
	SStgui.update_uis(src)

/obj/machinery/economy/vending/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(tilted)
		to_chat(user, "<span class='warning'>You'll need to right it first!</span>")
		return
	if(I.use_tool(src, user, 0, volume = 0))
		wires.Interact(user)

/obj/machinery/economy/vending/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(tilted)
		to_chat(user, "<span class='warning'>The fastening bolts aren't on the ground, you'll need to right it first!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	default_unfasten_wrench(user, I, time = 6 SECONDS)

//Override this proc to do per-machine checks on the inserted item, but remember to call the parent to handle these generic checks before your logic!
/obj/machinery/economy/vending/proc/item_slot_check(mob/user, obj/item/I)
	if(!item_slot)
		return FALSE
	if(inserted_item)
		to_chat(user, "<span class='warning'>There is something already inserted!</span>")
		return FALSE
	return TRUE

/* Example override for item_slot_check proc:
/obj/machinery/economy/vending/example/item_slot_check(mob/user, obj/item/I)
	if(!..())
		return FALSE
	if(!istype(I, /obj/item/toy))
		to_chat(user, "<span class='warning'>[I] isn't compatible with this machine's slot.</span>")
		return FALSE
	return TRUE
*/

/obj/machinery/economy/vending/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W))
		return FALSE
	if(!W.works_from_distance)
		return FALSE
	if(!component_parts || !refill_canister)
		return FALSE

	var/moved = 0
	if(panel_open || W.works_from_distance)
		if(W.works_from_distance)
			to_chat(user, display_parts(user))
		for(var/I in W)
			if(istype(I, refill_canister))
				moved += restock(I)
	else
		to_chat(user, display_parts(user))
	if(moved)
		to_chat(user, "[moved] items restocked.")
		W.play_rped_sound()
	return TRUE

/obj/machinery/economy/vending/on_deconstruction()
	update_canister()
	. = ..()

/obj/machinery/economy/vending/proc/insert_item(mob/user, obj/item/I)
	if(!item_slot || inserted_item)
		return
	if(!user.drop_item())
		to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't seem to put it down!</span>")
		return
	inserted_item = I
	I.forceMove(src)
	to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
	SStgui.update_uis(src)

/obj/machinery/economy/vending/proc/eject_item(mob/user)
	if(!item_slot || !inserted_item)
		return
	var/put_on_turf = TRUE
	if(user && iscarbon(user) && user.Adjacent(src))
		if(user.put_in_hands(inserted_item))
			put_on_turf = FALSE
	if(put_on_turf)
		var/turf/T = get_turf(src)
		inserted_item.forceMove(T)
	inserted_item = null
	SStgui.update_uis(src)

/obj/machinery/economy/vending/emag_act(mob/user)
	emagged = TRUE
	to_chat(user, "You short out the product lock on [src]")

/obj/machinery/economy/vending/ex_act(severity)
	. = ..()
	if(QDELETED(src) || (resistance_flags & INDESTRUCTIBLE) || tilted || !tiltable)
		return
	var/tilt_prob = 0
	switch(severity)
		if(EXPLODE_LIGHT)
			tilt_prob = 10
		if(EXPLODE_HEAVY)
			tilt_prob = 50
		if(EXPLODE_DEVASTATE)
			tilt_prob = 80

	if(prob(tilt_prob))
		tilt()

/obj/machinery/economy/vending/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/economy/vending/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/economy/vending/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(tilted)
		to_chat(user, "<span class='warning'>[src] is tipped over and non-functional! <b>Alt-Click</b> to right it first.</span>")
		return

	if(seconds_electrified != 0 && shock(user, 100))
		return

	ui_interact(user)
	wires.Interact(user)

/obj/machinery/economy/vending/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/estimated_height = 100 + min(length(product_records) * 34, 500)
		if(length(prices) > 0)
			estimated_height += 100 // to account for the "current user" interface
		ui = new(user, src, ui_key, "Vending",  name, 470, estimated_height, master_ui, state)
		ui.open()

/obj/machinery/economy/vending/ui_data(mob/user)
	var/list/data = list()

	data["usermoney"] = 0
	data["inserted_cash"] = cash_transaction
	data["user"] = null
	if(ishuman(user))
		var/obj/item/card/id/C
		var/mob/living/carbon/human/H = user
		C = H.get_idcard(TRUE)
		if(!C && istype(H.wear_pda, /obj/item/pda))
			var/obj/item/pda/P = H.wear_pda
			if(istype(P.id, /obj/item/card/id))
				C = P.id
		if(istype(C))
			var/datum/money_account/A = C.get_card_account()
			if(A)
				data["user"] = list()
				data["user"]["name"] = A.account_name
				data["usermoney"] = A.credit_balance
				data["user"]["job"] = C.rank ? C.rank : "No Job"

	data["stock"] = list()
	for(var/datum/data/vending_product/R in product_records + hidden_records)
		data["stock"][R.name] = R.amount
	data["extended_inventory"] = extended_inventory
	data["vend_ready"] = vend_ready
	data["panel_open"] = panel_open ? TRUE : FALSE
	data["speaker"] = shut_up ? FALSE : TRUE
	data["item_slot"] = item_slot // boolean
	data["inserted_item_name"] = inserted_item ? inserted_item.name : FALSE
	return data


/obj/machinery/economy/vending/ui_static_data(mob/user)
	var/list/data = list()
	data["chargesMoney"] = length(prices) > 0 ? TRUE : FALSE
	data["product_records"] = list()
	var/i = 1
	for(var/datum/data/vending_product/R in product_records)
		var/list/data_pr = list(
			path = replacetext(replacetext("[R.product_path]", "/obj/item/", ""), "/", "-"),
			name = R.name,
			price = (R.product_path in prices) ? prices[R.product_path] : 0,
			max_amount = R.max_amount,
			is_hidden = FALSE,
			inum = i++
		)
		data["product_records"] += list(data_pr)
	data["hidden_records"] = list()
	for(var/datum/data/vending_product/R in hidden_records)
		var/list/data_hr = list(
			path = replacetext(replacetext("[R.product_path]", "/obj/item/", ""), "/", "-"),
			name = R.name,
			price = (R.product_path in prices) ? prices[R.product_path] : 0,
			max_amount = R.max_amount,
			is_hidden = TRUE,
			inum = i++,
			premium = TRUE
		)
		data["hidden_records"] += list(data_hr)
	data["imagelist"] = imagelist
	return data

/obj/machinery/economy/vending/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/living/user = ui.user

	if(issilicon(user) && !isrobot(user))
		to_chat(user, "<span class='warning'>The vending machine refuses to interface with you, as you are not in its target demographic!</span>")
		return
	switch(action)
		if("toggle_voice")
			if(panel_open)
				shut_up = !shut_up
				. = TRUE
		if("eject_item")
			eject_item(user)
			. = TRUE
		if("change")
			. = TRUE
			give_change(user)
		if("vend")
			var/key = text2num(params["inum"])
			try_vend(key, user)
	if(.)
		add_fingerprint(user)

/obj/machinery/economy/vending/proc/try_vend(key, mob/user)
	if(!vend_ready)
		to_chat(user, "<span class='warning'>The vending machine is busy!</span>")
		return
	if(panel_open)
		to_chat(user, "<span class='warning'>The vending machine cannot dispense products while its service panel is open!</span>")
		return

	var/list/display_records = product_records
	if(extended_inventory)
		display_records = product_records + hidden_records
	if(key < 1 || key > length(display_records))
		log_debug("invalid inum passed to a [name] vendor.</span>")
		return
	var/datum/data/vending_product/R = display_records[key]
	if(!istype(R))
		log_debug("player attempted to access an unknown vending_product at a [name] vendor.</span>")
		return
	var/list/record_to_check = product_records
	if(extended_inventory)
		record_to_check = product_records + hidden_records
	if(!R.product_path)
		log_debug("player attempted to access an unknown product record at a [name] vendor.</span>")
		return
	if(R in hidden_records)
		if(!extended_inventory)
			// Exploit prevention, stop the user purchasing hidden stuff if they haven't hacked the machine.
			log_debug("player attempted to access a [name] vendor extended inventory when it was not allowed.</span>")
			return
	else if(!(R in record_to_check))
		// Exploit prevention, stop the user
		message_admins("Vending machine exploit attempted by [ADMIN_LOOKUPFLW(user)]!")
		return
	if(R.amount <= 0)
		to_chat(user, "Sold out of [R.name].")
		flick(icon_deny, src)
		return

	vend_ready = FALSE // From this point onwards, vendor is locked to performing this transaction only, until it is resolved.

	if(!ishuman(user) || R.price <= 0)
		// Either the purchaser is not human, or the item is free.
		// Skip all payment logic.
		vend(R, user)
		add_fingerprint(user)
		vend_ready = TRUE
		. = TRUE
		return

	// --- THE REST OF THIS PROC IS JUST PAYMENT LOGIC ---

	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/C = H.get_idcard(TRUE)

	currently_vending = R
	var/paid = FALSE

	if(cash_transaction < currently_vending.price && GLOB.station_money_database.vendor_account?.suspended)
		to_chat(user, "Vendor account offline. Unable to process transaction.")
		flick(icon_deny, src)
		vend_ready = TRUE
		return

	if(cash_transaction >= currently_vending.price)
		paid = pay_with_cash(currently_vending.price, "Vendor Transaction", name, user, GLOB.station_money_database.vendor_account)
	else if(istype(C, /obj/item/card))
		// Because this uses H.get_idcard(TRUE), it will attempt to use:
		// active hand, inactive hand, pda.id, and then wear_id ID in that order
		// this is important because it lets people buy stuff with someone else's ID by holding it while using the vendor
		paid = pay_with_card(C, currently_vending.price, "Vendor transaction", name, user, GLOB.station_money_database.vendor_account)
	else if(user.can_advanced_admin_interact())
		to_chat(user, "<span class='notice'>Vending object due to admin interaction.</span>")
		paid = TRUE
	else
		to_chat(user, "<span class='warning'>Payment failure: you have no ID or other method of payment.")
		vend_ready = TRUE
		flick(icon_deny, src)
		. = TRUE // we set this because they shouldn't even be able to get this far, and we want the UI to update.
		return
	if(paid)
		SSeconomy.total_vendor_transactions++
		vend(currently_vending, user)
		. = TRUE
	else
		to_chat(user, "<span class='warning'>Payment failure: unable to process payment.")
		vend_ready = TRUE

/obj/machinery/economy/vending/proc/vend(datum/data/vending_product/R, mob/user)
	if(!allowed(user) && !user.can_admin_interact() && !emagged && scan_id)	//For SECURE VENDING MACHINES YEAH
		to_chat(user, "<span class='warning'>Access denied.</span>")//Unless emagged of course
		flick(icon_deny, src)
		vend_ready = TRUE
		return

	if(!R.amount)
		to_chat(user, "<span class='warning'>The vending machine has ran out of that product.</span>")
		vend_ready = TRUE
		return

	vend_ready = FALSE //One thing at a time!!

	R.amount--

	if(last_reply + vend_delay + 200 <= world.time && vend_reply)
		speak(vend_reply)
		last_reply = world.time

	use_power(vend_power_usage)	//actuators and stuff
	if(icon_vend) //Show the vending animation if needed
		flick(icon_vend, src)
	playsound(get_turf(src), 'sound/machines/machine_vend.ogg', 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(delayed_vend), R, user), vend_delay)

/obj/machinery/economy/vending/proc/delayed_vend(datum/data/vending_product/R, mob/user)
	do_vend(R, user)
	vend_ready = TRUE
	currently_vending = null

//override this proc to add handling for what to do with the vended product when you have a inserted item and remember to include a parent call for this generic handling
/obj/machinery/economy/vending/proc/do_vend(datum/data/vending_product/R, mob/user)
	if(!item_slot || !inserted_item)
		var/put_on_turf = TRUE
		var/obj/vended = new R.product_path()
		if(user && iscarbon(user) && user.Adjacent(src))
			if(user.put_in_hands(vended))
				put_on_turf = FALSE
		if(put_on_turf)
			var/turf/T = get_turf(src)
			vended.forceMove(T)
			vended.pixel_x = rand(-5, 5)
			vended.pixel_y = rand(-5, 5)
		return TRUE
	return FALSE

/* Example override for do_vend proc:
/obj/machinery/economy/vending/example/do_vend(datum/data/vending_product/R)
	if(..())
		return
	var/obj/item/vended = new R.product_path()
	if(inserted_item.force == initial(inserted_item.force)
		inserted_item.force += vended.force
	inserted_item.damtype = vended.damtype
	qdel(vended)
*/

/obj/machinery/economy/vending/process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(!active)
		return

	if(seconds_electrified > 0)
		seconds_electrified--

	//Pitch to the people!  Really sell it!
	// especially if we want to tip over onto them!
	if((last_slogan + slogan_delay <= world.time || (aggressive && last_slogan + aggressive_slogan_delay <= world.time)) && LAZYLEN(slogan_list) && !shut_up && prob(5))
		var/slogan = pick(slogan_list)
		speak(slogan)
		last_slogan = world.time

	if(shoot_inventory && prob(shoot_chance))
		throw_item()

/obj/machinery/economy/vending/extinguish_light(force = FALSE)
	set_light(0)
	underlays.Cut()

/obj/machinery/economy/vending/proc/speak(message)
	if(stat & NOPOWER)
		return
	if(!message)
		return

	atom_say(message)

/obj/machinery/economy/vending/power_change()
	. = ..()
	if(stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		set_light(light_range_on, light_power_on)
	if(.)
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/economy/vending/obj_break(damage_flag)
	if(stat & BROKEN)
		return
	stat |= BROKEN
	set_light(0)
	update_icon(UPDATE_OVERLAYS)

	if(aggressive)
		aggressive = FALSE  // the evil is defeated

	if(cash_transaction)
		new /obj/item/stack/spacecash(get_turf(src), cash_transaction)
		cash_transaction = 0

	var/dump_amount = 0
	var/found_anything = TRUE
	while(found_anything)
		found_anything = FALSE
		for(var/record in shuffle(product_records))
			var/datum/data/vending_product/R = record
			if(R.amount <= 0) //Try to use a record that actually has something to dump.
				continue
			var/dump_path = R.product_path
			if(!dump_path)
				continue
			R.amount--
			// busting open a vendor will destroy some of the contents
			if(found_anything && prob(80))
				continue

			var/obj/O = new dump_path(loc)
			step(O, pick(GLOB.alldirs))
			found_anything = TRUE
			dump_amount++
			if(dump_amount >= 16)
				return

/obj/machinery/economy/vending/proc/on_untilt(atom/source, mob/user)
	SIGNAL_HANDLER  // COMSIG_MOVABLE_UNTILTED
	tilted = FALSE

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/economy/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7, src)
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
		return
	throw_item.throw_at(target, 16, 3)
	visible_message("<span class='danger'>[src] launches [throw_item.name] at [target.name]!</span>")

/obj/machinery/economy/vending/onTransitZ()
	return

/obj/machinery/economy/vending/proc/tilt(atom/victim, crit = FALSE, from_combat = FALSE, from_anywhere = FALSE)
	if(QDELETED(src) || !has_gravity(src) || !tiltable || tilted)
		return


	if(from_anywhere)
		forceMove(get_turf(victim))


	if(Adjacent(victim))
		var/damage = squish_damage
		var/picked_angle = pick(90, 270)
		var/should_crit = !from_combat && crit
		if(!crit && !from_combat)
			// only deal this extra bit of damage if they wouldn't otherwise be taking the double damage from critting
			damage *= self_knockover_factor

		. = fall_and_crush(get_turf(victim), damage, should_crit, crit_damage_factor, null, from_combat ? 4 SECONDS : 6 SECONDS, 12 SECONDS, FALSE, picked_angle)
		if(.)
			tilted = TRUE
			layer = ABOVE_MOB_LAYER

	var/should_throw_at_target = TRUE

	. = FALSE


	if(get_turf(victim) != get_turf(src))
		throw_at(get_turf(victim), 1, 1, spin = FALSE)

	tilt_over(should_throw_at_target ? victim : null)

/obj/machinery/economy/vending/shove_impact(mob/living/target, mob/living/attacker)
	if(HAS_TRAIT(target, TRAIT_FLATTENED))
		return

	if(!HAS_TRAIT(attacker, TRAIT_PACIFISM))
		add_attack_logs(attacker, target, "shoved into a vending machine ([src])")
		tilt(target, from_combat = TRUE)
	else if(HAS_TRAIT_FROM(attacker, TRAIT_PACIFISM, GHOST_ROLE))  // should only apply to the ghost bar
		add_attack_logs(attacker, target, "shoved into a vending machine ([src]), but flattened themselves.")
		tilt(attacker, crit = TRUE, from_anywhere = TRUE) // get fucked
	else
		attacker.visible_message("<span class='notice'>[attacker] lightly presses [target] against [src].</span>", "<span class='warning'>You lightly press [target] against [src], you don't want to hurt [target.p_them()]!</span>")
	return TRUE

/obj/machinery/economy/vending/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	if(HAS_TRAIT(C, TRAIT_FLATTENED))
		return ..()
	tilt(C, from_combat = TRUE)
	mob_hurt = TRUE
	return ..()


/*
 * Vending machine types
 */

/*

/obj/machinery/economy/vending/[vendors name here]   // --vending machine template   :)
	name = ""
	desc = ""
	icon = ''
	icon_state = ""
	vend_delay = 15
	products = list()
	contraband = list()
	premium = list()

*/
