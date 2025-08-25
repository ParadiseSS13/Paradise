#define INSERT_FAIL 0
#define INSERT_DONE 1
#define INSERT_NEEDS_INPUT 2

/obj/machinery/economy/vending/custom
	name = "\improper CrewVend 3000"
	refill_canister = null
	always_deconstruct = TRUE
	var/obj/item/eftpos/linked_pos

/obj/machinery/economy/vending/custom/Destroy()
	if(!isnull(linked_pos))
		linked_pos.linked_vendors -= src
		linked_pos = null
	return ..()

/obj/machinery/economy/vending/custom/locked(mob/user)
	if(isnull(linked_pos))
		return VENDOR_LOCKED
	if(!linked_pos.transaction_locked)
		return VENDOR_UNLOCKED
	// We check loc instead of calling is_holding so that it works in a pocket.
	if(linked_pos.loc == user)
		return VENDOR_LOCKED_FOR_OTHERS
	return VENDOR_LOCKED

/obj/machinery/economy/vending/custom/get_vendor_account()
	return linked_pos?.linked_account || ..()

/obj/machinery/economy/vending/custom/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(user.a_intent == INTENT_HARM || (used.flags & ABSTRACT))
		return ..()

	if((isnull(linked_pos) || locked(user) != VENDOR_LOCKED) && istype(used, /obj/item/eftpos))
		visible_message(span_notice("[src] beeps as [user] links it to [used]."), span_notice("You hear something beep."))
		if(!isnull(linked_pos))
			linked_pos.linked_vendors -= src
		linked_pos = used
		var/obj/item/eftpos/pos = used
		pos.linked_vendors += src
		return ITEM_INTERACT_COMPLETE
	else if(isnull(linked_pos))
		to_chat(user, span_warning("You need to link a point of sale device first!"))
		return ITEM_INTERACT_COMPLETE
	else if(locked(user) == VENDOR_LOCKED)
		return ..()

	try_add_stock(user, used)
	return ITEM_INTERACT_COMPLETE

/// Tries to add something to the vendor. can_wait returns INSERT_NEEDS_INPUT if it would wait for user input, quiet suppresses success messages, and bag is used when the item is being transferred from a storage item.
/obj/machinery/economy/vending/custom/proc/try_add_stock(mob/living/user, obj/item/used, can_wait = TRUE, quiet = FALSE, obj/item/storage/bag = null)
	if(istype(used, /obj/item/holder))
		to_chat(user, span_warning("[used] wriggles out of your hands!"))
		user.drop_item_to_ground(used)
		return INSERT_FAIL
	if(isnull(bag) && !user.canUnEquip(used, FALSE))
		to_chat(user, span_warning("\The [used] is stuck to your hand!"))
		return INSERT_FAIL
	else if(bag)
		if(!Adjacent(user))
			to_chat(user, span_warning("You can't reach [src] from here!"))
			return INSERT_FAIL
		if(!user.is_holding(bag))
			to_chat(user, span_warning("\The [bag] isn't in your hand anymore!"))
			return INSERT_FAIL
		if(used.loc != bag)
			to_chat(user, span_warning("\The [used] isn't in [bag] anymore!"))
			return INSERT_FAIL

	for(var/datum/data/vending_product/physical/record in physical_product_records)
		if(record.get_amount_left() == 0)
			physical_product_records -= record
			qdel(record)
		else if(isitem(record.items[1]))
			var/obj/item/existing = record.items[1]
			if(existing.should_stack_with(used))
				record.items += used
				if(isnull(bag))
					user.unequip(used)
				else
					bag.remove_from_storage(used)
				used.forceMove(src)
				if(!quiet)
					user.visible_message(span_notice("[user] puts [used] into [src]."), "<span class='notice>'You put [used] into [src].</span>")
				return INSERT_DONE

	if(!can_wait)
		return INSERT_NEEDS_INPUT

	var/price = tgui_input_number(user, "How much do you want to sell [used] for?")
	if(!isnum(price))
		return INSERT_FAIL
	if(!Adjacent(user))
		to_chat(user, span_warning("You can't reach [src] from here!"))
		return INSERT_FAIL
	if(isnull(bag))
		if(!user.is_holding(used))
			to_chat(user, span_warning("\The [used] isn't in your hand anymore!"))
			return INSERT_FAIL
		if(!user.canUnEquip(used, FALSE))
			to_chat(user, span_warning("\The [used] is stuck to your hand!"))
			return INSERT_FAIL
	else
		if(!user.is_holding(bag))
			to_chat(user, span_warning("\The [bag] isn't in your hand anymore!"))
			return INSERT_FAIL
		if(used.loc != bag)
			to_chat(user, span_warning("\The [used] isn't in [bag] anymore!"))
			return INSERT_FAIL

	var/datum/data/vending_product/physical/record = new(used.name, used.icon, used.icon_state)
	record.items += used
	record.price = price
	physical_product_records += record
	SStgui.update_uis(src, TRUE)
	if(isnull(bag))
		user.unequip(used)
	else
		bag.remove_from_storage(used)
	used.forceMove(src)
	if(!quiet)
		user.visible_message(span_notice("[user] puts [used] into [src]."), span_notice("You put [used] into [src]."))
	return INSERT_DONE

/obj/machinery/economy/vending/custom/MouseDrop_T(atom/dragged, mob/user, params)
	if(locked(user) == VENDOR_LOCKED)
		return ..()
	if(!istype(dragged, /obj/item/storage))
		return ..()

	var/obj/item/storage/bag = dragged
	var/inserted = FALSE
	for(var/obj/item/thing in bag.contents.Copy())
		var/result = try_add_stock(user, thing, can_wait = FALSE, quiet = TRUE, bag = bag)
		if(result == INSERT_FAIL)
			break
		if(result == INSERT_DONE)
			inserted = TRUE
			continue

		// result == INSERT_NEEDS_INPUT
		if(inserted)
			user.visible_message(span_notice("[user] transfers some things from [bag] into [src]."), span_notice("You transfer some things from [bag] into [src]."))
			// We've reported on our insertions so far, don't repeat it.
			inserted = FALSE

		// Try again, this time expecting it to wait.
		result = try_add_stock(user, thing, bag = bag)
		if(result == INSERT_FAIL)
			break

	if(inserted)
		user.visible_message(span_notice("[user] transfers everything from [bag] into [src]."), span_notice("You transfer everything from [bag] into [src]."))

	return TRUE

/obj/machinery/economy/vending/custom/crowbar_act(mob/user, obj/item/I)
	if(!isnull(linked_pos) && locked(user) == VENDOR_LOCKED)
		user.visible_message(span_notice("[user] tries to pry [src] apart, but fails."), span_warning("The lock on [src] resists your efforts to pry it apart."))
		return TRUE
	return ..()

/obj/machinery/economy/vending/custom/wrench_act(mob/user, obj/item/I)
	if(!isnull(linked_pos) && locked(user) == VENDOR_LOCKED)
		user.visible_message(span_notice("[user] tries to loosen the bolts on [src], but fails."), span_warning("The lock on [src] is covering its bolts."))
		return TRUE
	return ..()

/obj/machinery/economy/vending/custom/delayed_vend(datum/data/vending_product/R, mob/user)
	. = ..()
	if(istype(R, /datum/data/vending_product/physical) && R.get_amount_left() == 0)
		physical_product_records -= R
		physical_hidden_records -= R
		SStgui.update_uis(src, TRUE)

#undef INSERT_FAIL
#undef INSERT_DONE
#undef INSERT_NEEDS_INPUT
