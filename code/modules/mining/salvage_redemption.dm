/obj/machinery/salvage_redemption
	name = "salvage redemption machine"
	desc = "An electronic deposit bin that scans recovered salvage for useful information, and dispenses credit tickets based on the salvage's value."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "salvage_redemption"
	anchored = TRUE
	density = TRUE
	/// Access to claim points
	var/list/req_access_claim = list(ACCESS_MINING_STATION, ACCESS_FREE_GOLEMS, ACCESS_EXPEDITION)
	/// The number of unclaimed points.
	var/points = 0
	/// Point multiplier
	var/point_upgrade = 1
	/// List of salvage yet to process
	var/list/obj/item/salvage/salvage_buffer = list()
	/// If TRUE, [/obj/machinery/salvage_redemption/var/req_access_claim] is ignored and any ID may be used to claim points.
	var/anyone_claim = FALSE
	/// Current animation state
	var/animating = FALSE

/obj/machinery/salvage_redemption/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/salvage_redemption(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/salvage_redemption/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There are currently [points] claimable points. [points ? "Swipe your ID to claim them." : ""]</span>"

/obj/machinery/salvage_redemption/update_icon_state()
	. = ..()
	icon_state = "salvage_redemption"
	if(panel_open)
		icon_state += "-open"
		return

/obj/machinery/salvage_redemption/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/salvage_redemption/RefreshParts()
	var/point_mult = SALVAGE_REDEMPTION_BASE_POINT_MULT
	for(var/obj/item/stock_parts/component in component_parts)
		point_mult += SALVAGE_REDEMPTION_POINT_MULT_ADD_PER_RATING * component.rating
	// Update our values
	point_upgrade = point_mult
	SStgui.update_uis(src)

// Interactions
/obj/machinery/salvage_redemption/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(!has_power() || panel_open)
		return ..()

	if(animating)
		to_chat(user, "<span class='warning'>The machine is currently processing salvage at the moment.</span>");
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/card/id))
		var/obj/item/card/id/ID = used
		if(!points)
			to_chat(user, "<span class='warning'>There are no points to claim.</span>");
			return ITEM_INTERACT_COMPLETE
		var/claimed = FALSE
		for(var/access in req_access_claim)
			if(anyone_claim || (access in ID.access))
				ID.mining_points += points
				ID.total_mining_points += points
				to_chat(user, "<span class='notice'><b>[points] Salvage Points</b> claimed. You have earned a total of <b>[ID.total_mining_points] Salvage Points</b> this Shift!</span>")
				points = 0
				claimed = TRUE
				break
		if(!claimed)
			to_chat(user, "<span class='warning'>Required access not found.</span>")
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/storage/bag/expedition))
		var/obj/item/storage/bag/expedition/bag = used
		if(!length(bag.contents))
			to_chat(user, "<span class='warning'>You have no salvage to redeem.</span>");
			return ITEM_INTERACT_COMPLETE
		for(var/obj/item/salvage/loot in bag.contents)
			salvage_buffer |= loot
			loot.forceMove(src)
		process_salvage(user)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/salvage))
		if(used.flags & NODROP || !user.drop_item() || !used.forceMove(src))
			to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		var/obj/item/salvage/loot = used
		salvage_buffer |= loot
		process_salvage(user)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/salvage_redemption/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/salvage_redemption/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

/obj/machinery/salvage_redemption/Destroy()
	if(salvage_buffer)
		for(var/obj/item/salvage/loot in salvage_buffer)
			loot.forceMove(src.loc)
	return ..()

/obj/machinery/salvage_redemption/proc/process_salvage(mob/user)
	var/total_value = 0
	for(var/obj/item/salvage/loot in salvage_buffer)
		// Award points
		points += loot.value * point_upgrade
		total_value += loot.value
		// Delete the salvage
		salvage_buffer -= loot
		qdel(loot)
	// Do a little animation. It delays the slip slightly, but it looks cool
	animating = TRUE
	flick("salvage_redemption-active", src)
	addtimer(CALLBACK(src, PROC_REF(print_slip), total_value, user), 2.5 SECONDS)

/obj/machinery/salvage_redemption/proc/print_slip(total_value, mob/user)
	animating = FALSE
	// Print the credit slip
	playsound(src, 'sound/machines/banknote_counter.ogg', 30, FALSE)
	var/obj/item/credit_redemption_slip/slip = new /obj/item/credit_redemption_slip(src, total_value)
	if(ishuman(user) && Adjacent(user))
		var/mob/living/carbon/human/H = user
		H.put_in_hands(slip)
	else
		slip.forceMove(get_turf(src))

/// Credit redemption slip
/obj/item/credit_redemption_slip
	name = "credit redemption slip"
	desc = "A coupon worth a pre-determined amount of credits. Use this on an ATM to redeem them to your account."
	icon = 'icons/obj/card.dmi'
	icon_state = "credit_redemption"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	/// How much is it worth?
	var/value = 100
	/// Percent given to department
	var/department_cut = 0.75
	/// Department to award
	var/datum/money_account/department_account

/obj/item/credit_redemption_slip/Initialize(mapload, new_value, department = DEPARTMENT_SUPPLY)
	. = ..()
	value = new_value
	name += " ([value * (1- department_cut)])"
	department_account = GLOB.station_money_database.get_account_by_department(department)
