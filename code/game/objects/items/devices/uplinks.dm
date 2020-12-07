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
	var/uplink_owner = null//text-only
	var/used_TC = 0

	var/job = null
	var/temp_category
	var/uplink_type = "traitor"

/obj/item/uplink/ui_host()
	return loc

/obj/item/uplink/New()
	..()
	uses = SSticker.mode.uplink_uses
	uplink_items = get_uplink_items()

	GLOB.world_uplinks += src

/obj/item/uplink/Destroy()
	GLOB.world_uplinks -= src
	return ..()

/**
  * Build the item lists for use with the UI
  *
  * Generates a list of items for use in the UI, based on job and other parameters
  *
  * Arguments:
  * * user - User to check
  */
/obj/item/uplink/proc/generate_item_lists(mob/user)
	if(!job)
		job = user.mind.assigned_role

	var/list/cats = list()

	for(var/category in uplink_items)
		cats[++cats.len] = list("cat" = category, "items" = list())
		for(var/datum/uplink_item/I in uplink_items[category])
			if(I.job && I.job.len)
				if(!(I.job.Find(job)))
					continue
			cats[cats.len]["items"] += list(list("name" = sanitize(I.name), "desc" = sanitize(I.description()),"cost" = I.cost, "hijack_only" = I.hijack_only, "obj_path" = I.reference, "refundable" = I.refundable))
			uplink_items[I.reference] = I

	uplink_cats = cats

//If 'random' was selected
/obj/item/uplink/proc/chooseRandomItem()
	if(uses <= 0)
		return

	var/list/random_items = list()

	for(var/IR in uplink_items)
		var/datum/uplink_item/UI = uplink_items[IR]
		if(UI.cost <= uses && UI.limited_stock != 0)
			random_items += UI

	return pick(random_items)

/obj/item/uplink/proc/buy(var/datum/uplink_item/UI, var/reference)
	if(!UI)
		return
	if(UI.limited_stock == 0)
		to_chat(usr, "<span class='warning'>You have redeemed this discount already.</span>")
		return
	UI.buy(src,usr)
	if(UI.limited_stock > 0) // only decrement it if it's actually limited
		UI.limited_stock--
	SStgui.update_uis(src)

	return TRUE

/obj/item/uplink/proc/refund(mob/user as mob)
	var/obj/item/I = user.get_active_hand()
	if(I) // Make sure there's actually something in the hand before even bothering to check
		for(var/category in uplink_items)
			for(var/item in uplink_items[category])
				var/datum/uplink_item/UI = item
				var/path = UI.refund_path || UI.item
				var/cost = UI.refund_amount || UI.cost
				if(I.type == path && UI.refundable && I.check_uplink_validity())
					uses += cost
					used_TC -= cost
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
	var/active = 0

// The hidden uplink MUST be inside an obj/item's contents.
/obj/item/uplink/hidden/New()
	spawn(2)
		if(!istype(src.loc, /obj/item))
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
/obj/item/uplink/hidden/proc/check_trigger(mob/user as mob, var/value, var/target)
	if(value == target)
		trigger(user)
		return TRUE
	return FALSE

/obj/item/uplink/hidden/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Uplink", name, 900, 600, master_ui, state)
		ui.open()

/obj/item/uplink/hidden/ui_data(mob/user)
	var/list/data = list()

	data["crystals"] = uses

	return data

/obj/item/uplink/hidden/ui_static_data(mob/user)
	var/list/data = list()

	// Actual items
	if(!uplink_cats || !uplink_items)
		generate_item_lists(user)
	data["cats"] = uplink_cats

	// Exploitable info
	var/list/exploitable = list()
	for(var/datum/data/record/L in GLOB.data_core.general)
		exploitable += list(list(
			"name" = html_encode(L.fields["name"]),
			"sex" = html_encode(L.fields["sex"]),
			"age" = html_encode(L.fields["age"]),
			"species" = html_encode(L.fields["species"]),
			"rank" = html_encode(L.fields["rank"]),
			"fingerprint" = html_encode(L.fields["fingerprint"])
		))

	data["exploitable"] = exploitable

	return data


// Interaction code. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
/obj/item/uplink/hidden/interact(mob/user)
	ui_interact(user)

// The purchasing code.
/obj/item/uplink/hidden/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("lock")
			toggle()
			uses += hidden_crystals
			hidden_crystals = 0
			SStgui.close_uis(src)

		if("refund")
			refund(usr)

		if("buyRandom")
			var/datum/uplink_item/UI = chooseRandomItem()
			return buy(UI, "RN")

		if("buyItem")
			var/datum/uplink_item/UI = uplink_items[params["item"]]
			return buy(UI, UI ? UI.reference : "")


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

/obj/item/radio/uplink/attack_self(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/radio/uplink/nuclear/New()
	..()
	if(hidden_uplink)
		hidden_uplink.uplink_type = "nuclear"
	GLOB.nuclear_uplink_list += src

/obj/item/radio/uplink/nuclear/Destroy()
	GLOB.nuclear_uplink_list -= src
	return ..()

/obj/item/radio/uplink/sst/New()
	..()
	if(hidden_uplink)
		hidden_uplink.uplink_type = "sst"

/obj/item/multitool/uplink/New()
	..()
	hidden_uplink = new(src)

/obj/item/multitool/uplink/attack_self(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/radio/headset/uplink
	traitor_frequency = 1445

/obj/item/radio/headset/uplink/New()
	..()
	hidden_uplink = new(src)
	hidden_uplink.uses = 20
