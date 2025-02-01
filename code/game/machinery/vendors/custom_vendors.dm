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

/obj/machinery/economy/vending/custom/locked()
	return isnull(linked_pos) || linked_pos.transaction_locked

/obj/machinery/economy/vending/custom/get_vendor_account()
	return linked_pos?.linked_account || ..()

/obj/machinery/economy/vending/custom/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/eftpos))
		visible_message("<span class='notice'>[src] beeps as [user] links it to [used].</span>", "<span class='notice'>You hear something beep.</span>")
		if(!isnull(linked_pos))
			linked_pos.linked_vendors -= src
		linked_pos = used
		var/obj/item/eftpos/pos = used
		pos.linked_vendors += src
		return ITEM_INTERACT_COMPLETE
	else if(isnull(linked_pos))
		to_chat(user, "<span class='warning'>You need to link a point of sale device first!</span>")
		return ITEM_INTERACT_COMPLETE
	else if(locked())
		return ..()
	if(!user.canUnEquip(used, FALSE))
		to_chat(user, "<span class='warning'>\The [used] is stuck to your hand!</span>")
		return ITEM_INTERACT_COMPLETE

	for(var/datum/data/vending_product/physical/record in physical_product_records)
		if(record.get_amount_left() == 0)
			physical_product_records -= record
			qdel(record)
		else if(isitem(record.items[1]))
			var/obj/item/existing = record.items[1]
			if(existing.should_stack_with(used))
				record.items += used
				user.unequip(used)
				used.moveToNullspace()
				user.visible_message("<span class='notice'>[user] puts [used] into [src].</span>", "<span class='notice>'You put [used] into [src].</span>")
				return ITEM_INTERACT_COMPLETE

	var/price = tgui_input_number(user, "How much do you want to sell [used] for?")
	if(!isnum(price))
		return ITEM_INTERACT_COMPLETE
	if(!Adjacent(user))
		to_chat(user, "<span class='warning'>You can't reach [src] from here!</span>")
		return ITEM_INTERACT_COMPLETE
	if(!user.is_holding(used))
		to_chat(user, "<span class='warning'>\The [used] isn't in your hand anymore!</span>")
		return ITEM_INTERACT_COMPLETE
	if(!user.canUnEquip(used, FALSE))
		to_chat(user, "<span class='warning'>\The [used] is stuck to your hand!</span>")
		return ITEM_INTERACT_COMPLETE

	var/datum/data/vending_product/physical/record = new(used.name, used.icon, used.icon_state)
	record.items += used
	record.price = price
	physical_product_records += record
	SStgui.update_uis(src, TRUE)
	user.unequip(used)
	used.moveToNullspace()
	user.visible_message("[user] puts [used] into [src].", "You put [used] into [src].")
	return ITEM_INTERACT_COMPLETE

/obj/machinery/economy/vending/custom/crowbar_act(mob/user, obj/item/I)
	if(!isnull(linked_pos) && linked_pos.transaction_locked)
		user.visible_message("<span class='notice'>[user] tries to pry [src] apart, but fails.</span>", "<span class='notice'>The lock on [src] resists your efforts to pry it apart.</span>")
		return TRUE
	return ..()

/obj/machinery/economy/vending/custom/delayed_vend(datum/data/vending_product/R, mob/user)
	. = ..()
	if(istype(R, /datum/data/vending_product/physical) && R.get_amount_left() == 0)
		physical_product_records -= R
		physical_hidden_records -= R
		SStgui.update_uis(src, TRUE)
