// This file contains stuff regarding the karma holder datum
// This is attached to a client and holds their info
/datum/karma_holder
	/// List of karma packages this user has purchased
	var/list/purchased_packages = list()
	/// List of packages where a refund is due
	var/list/refundable_packages = list()
	/// Amount of karma earned total
	var/karma_earned = 0
	/// Amount of karma spent total
	var/karma_spent = 0

// Safety stuff
/datum/karma_holder/vv_edit_var(var_name, var_value)
	return FALSE // no

/datum/karma_holder/CanProcCall(procname)
	return FALSE // no

/datum/karma_holder/proc/addUnlock(package)
	if(!(package in GLOB.karma_packages))
		stack_trace("Someone removed a karma package [package] from the game entirely. This should never happen. Please beat the person who did this.")
		return

	purchased_packages += package
	var/datum/karma_package/KP = GLOB.karma_packages[package]
	if(KP.refundable)
		refundable_packages += package // Put it in the pool of stuff to be refunded

/datum/karma_holder/proc/hasPackage(package)
	return (package in purchased_packages)


/datum/karma_holder/proc/processRefunds(mob/user)
	set waitfor = FALSE
	if(!length(refundable_packages))
		return

	for(var/package_id in refundable_packages)
		var/datum/karma_package/KP = GLOB.karma_packages[package_id]
		make_refund(KP, user)
		to_chat(user, "<span class='notice'>You had the Karma package <b>[KP.friendly_name]</b>, which is no longer a store item. You have been automatically refunded <b>[KP.karma_cost]</b> karma.")

// Reloads the values from the DB to ensure they havnt been gamed
/datum/karma_holder/proc/sync_karma(mob/M = usr)
	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT karma, karmaspent FROM karma_totals WHERE byondkey=:ckey", list(
		"ckey" = M.ckey
	))

	if(!select_query.warn_execute())
		qdel(select_query)
		return

	while(select_query.NextRow())
		karma_earned = select_query.item[1]
		karma_spent = select_query.item[2]

	qdel(select_query)

/datum/karma_holder/proc/make_purchase(datum/karma_package/package)
	sync_karma() // Ensure its up to date

	// INITIAL CHECKS
	var/karma_available = karma_earned - karma_spent

	if(karma_available < package.karma_cost)
		to_chat(usr, "You do not have enough karma!")
		return

	if(alert("Are you sure you want to unlock [package.friendly_name]?", "Confirmation", "No", "Yes") != "Yes")
		return

	if(karma_available < package.karma_cost) // This is repeated for a reason. Someone could queue up 10 windows to buy things.
		to_chat(usr, "You do not have enough karma!")
		return

	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT ckey FROM karma_purchases WHERE purchase=:package_id AND ckey=:ckey", list(
		"package_id" = package.database_id,
		"ckey" = usr.ckey
	))

	if(!select_query.warn_execute())
		qdel(select_query)
		return

	if(select_query.NextRow())
		to_chat(usr, "<span class='notice'>You have already purchased [package.friendly_name]. If you believe this is an error, please contact the server host.</span>")
		qdel(select_query)
		return

	qdel(select_query)


	// Update for this round
	purchased_packages += package.database_id

	// Make the insert
	var/datum/db_query/insert_query = SSdbcore.NewQuery("INSERT INTO karma_purchases (ckey, purchase) VALUES (:ckey, :purchase)", list(
		"ckey" = usr.ckey,
		"purchase" = package.database_id
	))

	if(!insert_query.warn_execute())
		to_chat(usr, "<span class='warning'>Failed to purchase [package.friendly_name]. Please contact the server host.</span>")
		qdel(insert_query)
		return

	// Tell them
	to_chat(usr, "<span class='notice'>You have purchased [package.friendly_name]</span>.")
	log_karma("[key_name(usr)] has purchased [package.friendly_name].")
	qdel(insert_query)

	// Charge them
	karma_spent += package.karma_cost

	var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE karma_totals SET karmaspent=:spent WHERE byondkey=:ckey", list(
		"spent" = karma_spent,
		"ckey" = usr.ckey
	))

	if(!update_query.warn_execute())
		qdel(update_query)
		message_admins("[key_name_admin(usr)] just bought something with karma but didnt get a balance deduction. Inform the host please.")
		return

	// Inform them
	to_chat(usr, "You have been charged [package.karma_cost] karma.")
	qdel(update_query)

// This is automatically invoked when a user logs in.
/datum/karma_holder/proc/make_refund(datum/karma_package/package, mob/user)
	sync_karma(user) // Ensure its up to date

	if(!(package.database_id in purchased_packages))
		to_chat(user, "You do not own [package.friendly_name]!")
		message_admins("[key_name_admin(user)] attempted to refund a karma package they do not have. Potential href exploit.")
		return

	// Do the delete
	var/datum/db_query/insert_query = SSdbcore.NewQuery("DELETE FROM karma_purchases WHERE ckey=:ckey AND purchase=:purchase", list(
		"ckey" = user.ckey,
		"purchase" = package.database_id
	))

	if(!insert_query.warn_execute())
		to_chat(user, "<span class='warning'>Failed to refund [package.friendly_name]. Please contact the server host.</span>")
		qdel(insert_query)
		return

	// Update for this round
	purchased_packages -= package.database_id

	// Refund them
	karma_spent -= package.karma_cost

	var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE karma_totals SET karmaspent=:spent WHERE byondkey=:ckey", list(
		"spent" = karma_spent,
		"ckey" = user.ckey
	))

	if(!update_query.warn_execute())
		qdel(update_query)
		message_admins("[key_name_admin(user)] just tried to refund a karma purchase but didnt get a balance deduction. Inform the host please.")
		return

	qdel(update_query)

/datum/karma_holder/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "KarmaShop", "Karma Shop", 400, 700, master_ui, state)
		ui.open()

// Packages they have + Balance
/datum/karma_holder/ui_data(mob/user)
	var/list/data = list()

	data["purchased_packages"] = purchased_packages.Copy() // Do I need to copy here? Probably
	data["karma_balance"] = (karma_earned - karma_spent)

	return data

// All the packages
/datum/karma_holder/ui_static_data(mob/user)
	var/list/data = list()

	var/list/packages = list()

	for(var/kp_id in GLOB.karma_packages)
		var/datum/karma_package/KP = GLOB.karma_packages[kp_id]
		if(KP.refundable)
			continue
		var/list/package_data = list()
		package_data["id"] = KP.database_id
		package_data["name"] = KP.friendly_name
		package_data["cat"] = KP.category
		package_data["cost"] = KP.karma_cost

		// Remember, TGUI lists need to be 2 layers deep because BYOND JSON memes
		packages += list(package_data)

	data["all_packages"] = packages

	return data

// UI callback
/datum/karma_holder/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("makepurchase")
			var/purchase_id = params["id"]
			if(!(purchase_id in GLOB.karma_packages))
				to_chat(usr, "<span class='warning'>That isnt a purchaseable package. What the heck? Please make an issue report.</span>")
				return FALSE
			var/datum/karma_package/kp = GLOB.karma_packages[purchase_id]
			if(kp.refundable)
				to_chat(usr, "<span class='warning'>That isnt a purchaseable package. What the heck? Please make an issue report.</span>")
				return FALSE

			make_purchase(kp)

	return TRUE
