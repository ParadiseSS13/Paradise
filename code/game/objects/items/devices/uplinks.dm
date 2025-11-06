//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message.

*/

GLOBAL_LIST_EMPTY(world_uplinks)

/obj/item/uplink
	var/uses 				// Numbers of crystals
	var/hidden_crystals = 0
	/// List of categories with items inside
	var/list/uplink_cats
	/// List of all items in total (For buying random)
	var/list/uplink_items

	var/purchase_log = ""
	var/uplink_owner = null //text-only
	var/used_TC = 0

	var/job = null
	var/species = null
	var/temp_category
	var/uplink_type = UPLINK_TYPE_TRAITOR
	/// Whether the uplink is jammed and cannot be used to order items.
	var/is_jammed = FALSE
	/// Whether or not the uplink has generated its stock and discounts
	var/items_generated = FALSE

	var/datum/data/record/selected_record

/obj/item/uplink/ui_host()
	return loc

/obj/item/uplink/proc/update_uplink_type(new_uplink_type)
	uplink_type = new_uplink_type

/obj/item/uplink/New()
	..()
	uses = 100
	GLOB.world_uplinks += src

/obj/item/uplink/Destroy()
	GLOB.world_uplinks -= src
	return ..()

/**
  * Build the item lists for use with the UI
  *
  * Generates a list of items for use in the UI, based on job, species and other parameters
  *
  * Arguments:
  * * user - User to check
  */
/obj/item/uplink/proc/generate_item_lists(mob/user)
	if(!job)
		job = user.mind.assigned_role
	if(!species)
		species = user.dna.species.name
	if(!items_generated)
		uplink_items = get_uplink_items(src, user)
		items_generated = TRUE

	var/list/cats = list()

	for(var/category in uplink_items)
		cats[++cats.len] = list("cat" = category, "items" = list())
		for(var/datum/uplink_item/I in uplink_items[category])
			if(I.job && length(I.job))
				if(!(I.job.Find(job)) && uplink_type != UPLINK_TYPE_ADMIN)
					continue
			if(length(I.species))
				if(!(I.species.Find(species)) && uplink_type != UPLINK_TYPE_ADMIN)
					continue
			cats[length(cats)]["items"] += list(list(
				"name" = sanitize(I.name),
				"desc" = sanitize(I.description()),
				"cost" = I.cost,
				"hijack_only" = I.hijack_only,
				"obj_path" = I.reference,
				"refundable" = I.refundable))
			uplink_items[I.reference] = I

	uplink_cats = cats

//If 'random' was selected
/obj/item/uplink/proc/chooseRandomItem()
	if(uses <= 0)
		return

	var/list/random_items = list()

	for(var/uplink_section in uplink_items)
		for(var/datum/uplink_item/UI in uplink_items[uplink_section])
			if(UI.cost <= uses && UI.limited_stock != 0)
				random_items += UI

	return pick(random_items)

/obj/item/uplink/proc/buy(datum/uplink_item/UI, reference)
	if(is_jammed)
		to_chat(usr, "<span class='warning'>[src] seems to be jammed - it cannot be used here!</span>")
		return
	if(!UI)
		return
	if(UI.limited_stock == 0)
		to_chat(usr, "<span class='warning'>You have redeemed this discount already.</span>")
		return
	UI.buy_uplink_item(src,usr)
	SStgui.update_uis(src)

	return TRUE

/obj/item/uplink/proc/mass_purchase(datum/uplink_item/UI, reference, quantity = 1)
	// jamming check happens in ui_act
	if(!UI)
		return
	if(quantity <= 0)
		return
	if(UI.limited_stock == 0)
		return
	if(UI.limited_stock > 0 && UI.limited_stock < quantity)
		quantity = UI.limited_stock
	var/list/bought_things = list()
	for(var/i in 1 to quantity)
		var/item = UI.buy_uplink_item(src, usr, put_in_hands = FALSE)
		if(isnull(item))
			break
		bought_things += item
	return bought_things

/obj/item/uplink/proc/refund(mob/user as mob)
	var/obj/item/I = user.get_active_hand()
	if(!I) // Make sure there's actually something in the hand before even bothering to check
		to_chat(user, "<span class='warning'>[I] is not refundable.</span>")
		return

	for(var/category in uplink_items)
		for(var/item in uplink_items[category])
			var/datum/uplink_item/UI = item
			var/path = UI.refund_path || UI.item
			var/cost = UI.refund_amount || UI.cost

			if(ispath(I.type, path) && UI.refundable && I.check_uplink_validity())
				var/refund_amount = cost
				if(istype(I, /obj/item/guardiancreator/tech))
					var/obj/item/guardiancreator/tech/holopara = I
					if(holopara.is_discounted && cost != holopara.refund_cost) // This has to be done because the normal holopara uplink datum precedes the discounted uplink datum
						continue
					refund_amount = holopara.refund_cost
				uses += refund_amount
				used_TC -= refund_amount
				to_chat(user, "<span class='notice'>[I] refunded.</span>")
				qdel(I)
				return

	// If we are here, we didnt refund
	to_chat(user, "<span class='warning'>[I] is not refundable.</span>")

// HIDDEN UPLINK - Can be stored in anything but the host item has to have a trigger for it.
/* How to create an uplink in 3 easy steps!

 1. All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with "new(src)", it must be in it's contents. Feel free to add "uses".

 2. Code in the triggers. Use check_trigger for this, I recommend closing the item's menu with "usr << browse(null, "window=windowname") if it returns true.
 The var/value is the value that will be compared with the var/target. If they are equal it will activate the menu.

 3. If you want the menu to stay until the users locks his uplink, add an active_uplink_check(mob/user as mob) in your interact/attack_hand proc.
 Then check if it's true, if true return. This will stop the normal menu appearing and will instead show the uplink menu.
*/

/obj/item/uplink/hidden
	name = "hidden uplink"
	desc = "There is something wrong if you're examining this."
	var/active = FALSE
	/// An assoc list of references (the variable called reference on an uplink item) and its value being how many of the item
	var/list/shopping_cart
	/// A cached version of shopping_cart containing all the data for the tgui side
	var/list/cached_cart
	/// A list of 3 categories and item indexes in uplink_cats, to show as recommendedations
	var/list/lucky_numbers

// The hidden uplink MUST be inside an obj/item's contents.
/obj/item/uplink/hidden/New(loc)
	if(!isitem(loc))
		qdel(src)
	..()

// Toggles the uplink on and off. Normally this will bypass the item's normal functions and go to the uplink menu, if activated.
/obj/item/uplink/hidden/proc/toggle()
	active = !active

// Directly trigger the uplink. Turn on if it isn't already.
/obj/item/uplink/hidden/proc/trigger(mob/user as mob)
	if(!active)
		toggle()
	interact(user)

// Checks to see if the value meets the target. Like a frequency being a traitor_frequency, in order to unlock a headset.
// If true, it accesses trigger() and returns 1. If it fails, it returns false. Use this to see if you need to close the
// current item's menu.
/obj/item/uplink/hidden/proc/check_trigger(mob/user, value, target)
	if(is_jammed)
		to_chat(user, "<span class='warning'>[src] seems to be jammed - it cannot be used here!</span>")
		return
	if(value == target)
		trigger(user)
		return TRUE
	return FALSE

/obj/item/uplink/hidden/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/uplink/hidden/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Uplink", name)
		ui.open()

/obj/item/uplink/hidden/ui_data(mob/user)
	var/list/data = list()

	data["crystals"] = uses

	data["cart"] = generate_tgui_cart()
	data["cart_price"] = calculate_cart_tc()
	data["lucky_numbers"] = lucky_numbers
	if(selected_record && GLOB.data_core.general.Find(selected_record))
		data["selected_record"] = list(
				"name" = html_encode(selected_record.fields["name"]),
				"sex" = html_encode(selected_record.fields["sex"]),
				"age" = html_encode(selected_record.fields["age"]),
				"species" = html_encode(selected_record.fields["species"]),
				"rank" = html_encode(selected_record.fields["rank"]),
				"nt_relation" = html_encode(selected_record.fields["nt_relation"]),
				"fingerprint" = html_encode(selected_record.fields["fingerprint"]),
				"has_photos" = (selected_record.fields["photo-south"] || selected_record.fields["photo-west"]) ? TRUE : FALSE,
				"photos" = list(selected_record.fields["photo-south"], selected_record.fields["photo-west"])
			)

	return data

/obj/item/uplink/hidden/ui_static_data(mob/user)
	var/list/data = list()

	// Actual items
	if(!uplink_cats || !uplink_items)
		generate_item_lists(user)
	if(!lucky_numbers) // Make sure these are generated AFTER the categories, otherwise shit will get messed up
		shuffle_lucky_numbers()
	data["cats"] = uplink_cats

	// Exploitable info
	var/list/exploitable = list()
	for(var/datum/data/record/L in GLOB.data_core.general)
		if(isnull(selected_record))
			selected_record = L
		exploitable += list(list(
			"name" = html_encode(L.fields["name"]),
			"uid_gen" = L.UID(),
		))

	data["exploitable"] = exploitable

	return data

/obj/item/uplink/hidden/proc/calculate_cart_tc()
	. = 0
	for(var/reference in shopping_cart)
		var/datum/uplink_item/item = uplink_items[reference]
		var/purchase_amt = shopping_cart[reference]
		. += item.cost * purchase_amt

/obj/item/uplink/hidden/proc/generate_tgui_cart(update = FALSE)
	if(!update)
		return cached_cart

	if(!length(shopping_cart))
		shopping_cart = null
		cached_cart = null
		return cached_cart

	cached_cart = list()
	for(var/reference in shopping_cart)
		var/datum/uplink_item/I = uplink_items[reference]
		cached_cart += list(list(
			"name" = sanitize(I.name),
			"desc" = sanitize(I.description()),
			"cost" = I.cost,
			"hijack_only" = I.hijack_only,
			"obj_path" = I.reference,
			"amount" = shopping_cart[reference],
			"limit" = I.limited_stock))

// Interaction code. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
/obj/item/uplink/hidden/interact(mob/user)
	ui_interact(user)

// The purchasing code.
/obj/item/uplink/hidden/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	. = TRUE

	switch(action)
		if("lock")
			toggle()
			uses += hidden_crystals
			hidden_crystals = 0
			SStgui.close_uis(src)
			for(var/reference in shopping_cart)
				if(shopping_cart[reference] == 0) // I know this isn't lazy, but this should runtime on purpose if we can't access this for some reason
					remove_from_cart(reference)

		if("refund")
			refund(ui.user)

		if("buyRandom")
			var/datum/uplink_item/UI = chooseRandomItem()
			return buy(UI, "RN")

		if("buyItem")
			var/datum/uplink_item/UI = uplink_items[params["item"]]
			return buy(UI, UI ? UI.reference : "")

		if("add_to_cart")
			var/datum/uplink_item/UI = uplink_items[params["item"]]
			if(LAZYIN(shopping_cart, params["item"]))
				to_chat(ui.user, "<span class='warning'>[UI.name] is already in your cart!</span>")
				return
			var/startamount = 1
			if(UI.limited_stock == 0)
				startamount = 0
			LAZYSET(shopping_cart, params["item"], startamount)
			generate_tgui_cart(TRUE)

		if("remove_from_cart")
			remove_from_cart(params["item"])

		if("set_cart_item_quantity")
			var/amount = text2num(params["quantity"])
			LAZYSET(shopping_cart, params["item"], max(amount, 0))
			generate_tgui_cart(TRUE)

		if("purchase_cart")
			if(!LAZYLEN(shopping_cart)) // sanity check
				return
			if(calculate_cart_tc() > uses)
				to_chat(ui.user, "<span class='warning'>[src] buzzes, it doesn't contain enough telecrystals!</span>")
				return
			if(is_jammed)
				to_chat(ui.user, "<span class='warning'>[src] seems to be jammed - it cannot be used here!</span>")
				return

			// Buying of the uplink stuff
			var/list/bought_things = list()
			for(var/reference in shopping_cart)
				var/datum/uplink_item/item = uplink_items[reference]
				var/purchase_amt = shopping_cart[reference]
				if(purchase_amt <= 0)
					continue
				bought_things += mass_purchase(item, item ? item.reference : "", purchase_amt)

			// Check how many of them are items
			var/list/obj/item/items_for_crate = list()
			for(var/obj/item/thing in bought_things)
				// because sometimes you can buy items like crates from surpluses and stuff
				// the crates will already be on the ground, so we dont need to worry about them
				if(isitem(thing))
					items_for_crate += thing

			// If we have more than 2 of them, put them in a crate
			if(length(items_for_crate) > 2)
				var/obj/structure/closet/crate/C = new(get_turf(src))
				for(var/obj/item/item as anything in items_for_crate)
					item.forceMove(C)
			// Otherwise, just put the items in their hands
			else if(length(items_for_crate))
				for(var/obj/item/item as anything in items_for_crate)
					ui.user.put_in_any_hand_if_possible(item)

			empty_cart()
			SStgui.update_uis(src)

		if("empty_cart")
			empty_cart()

		if("shuffle_lucky_numbers")
			// lets see paul allen's random uplink item
			shuffle_lucky_numbers()

		if("view_record") // View Record
			var/datum/data/record/G = locateUID(params["uid_gen"])
			if(!istype(G))
				return
			selected_record = G

/obj/item/uplink/hidden/proc/shuffle_lucky_numbers()
	lucky_numbers = list()
	for(var/i in 1 to 4)
		var/cate_number = rand(1, length(uplink_cats))
		var/item_number = rand(1, length(uplink_cats[cate_number]["items"]))
		lucky_numbers += list(list("cat" = cate_number - 1, "item" = item_number - 1)) // dm lists are 1 based, js lists are 0 based, gotta -1

/obj/item/uplink/hidden/proc/remove_from_cart(item_reference) // i want to make it eventually remove all instances
	LAZYREMOVE(shopping_cart, item_reference)
	generate_tgui_cart(TRUE)

/obj/item/uplink/hidden/proc/empty_cart()
	shopping_cart = null
	generate_tgui_cart(TRUE)

// I placed this here because of how relevant it is.
// You place this in your uplinkable item to check if an uplink is active or not.
// If it is, it will display the uplink menu and return 1, else it'll return false.
// If it returns true, I recommend closing the item's normal menu with "user << browse(null, "window=name")"
/obj/item/proc/active_uplink_check(mob/user as mob)
	// Activates the uplink if it's active
	if(src.hidden_uplink)
		if(src.hidden_uplink.active)
			src.hidden_uplink.trigger(user)
			return 1
	return 0

// PRESET UPLINKS
// A collection of preset uplinks.
//
// Includes normal radio uplink, multitool uplink,
// implant uplink (not the implant tool) and a preset headset uplink.

/obj/item/radio/uplink/New()
	..()
	hidden_uplink = new(src)
	icon_state = "radio"

/obj/item/radio/uplink/AltClick()
	return

/obj/item/radio/uplink/CtrlShiftClick()
	return

/obj/item/radio/uplink/show_examine_hotkeys()
	return list()

/obj/item/radio/uplink/attack_self__legacy__attackchain(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/radio/uplink/nuclear/New()
	..()
	if(hidden_uplink)
		hidden_uplink.update_uplink_type(UPLINK_TYPE_NUCLEAR)
	GLOB.nuclear_uplink_list += src

/obj/item/radio/uplink/nuclear/Destroy()
	GLOB.nuclear_uplink_list -= src
	return ..()

/obj/item/radio/uplink/sst/New()
	..()
	if(hidden_uplink)
		hidden_uplink.update_uplink_type(UPLINK_TYPE_SST)

/obj/item/radio/uplink/admin/New()
	..()
	if(hidden_uplink)
		hidden_uplink.update_uplink_type(UPLINK_TYPE_ADMIN)
		hidden_uplink.uses = 2500

/obj/item/multitool/uplink/New()
	..()
	hidden_uplink = new(src)

/obj/item/multitool/uplink/activate_self(mob/user as mob)
	. = ..()
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/radio/headset/uplink
	traitor_frequency = 1445

/obj/item/radio/headset/uplink/New()
	..()
	hidden_uplink = new(src)
	hidden_uplink.uses = 100
