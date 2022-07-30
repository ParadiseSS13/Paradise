/**
 * Toggles the [/datum/click_intercept/give] on or off for the src mob.
 */
/mob/living/carbon/proc/toggle_give()
	if(HAS_TRAIT(src, TRAIT_OFFERING_ITEM))
		to_chat(src, "<span class='warning'>You're already offering an item to someone!</span>")
		return
	if(istype(client.click_intercept, /datum/click_intercept/give))
		give_icon.icon_state = "act_give_off"
		QDEL_NULL(client.click_intercept)
		return
	var/obj/item/I = get_active_hand()
	if(!I)
		to_chat(src, "<span class='warning'>You don't have anything in your hand to give!</span>")
		return
	if(I.flags & NODROP)
		to_chat(src, "<span class='warning'>[I] is stuck to your hand, you can't give it away!</span>")
		return
	if(I.flags & ABSTRACT)
		to_chat(src, "<span class='warning'>That's not exactly something you can give.</span>")
		return

	give_icon.icon_state = "act_give_on"
	new /datum/click_intercept/give(client)

/**
 * # Give click intercept
 *
 * While a mob has this intercept, left clicking on a carbon mob will attempt to offer their currently held item to that mob.
 */
/datum/click_intercept/give

/datum/click_intercept/give/New(client/C)
	..()
	holder.mouse_pointer_icon = file("icons/mouse_icons/give_item.dmi")
	to_chat(holder, "<span class='info'>You can now left click on someone to give them your held item.</span>")
	RegisterSignal(holder.mob.get_active_hand(), list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/cancel_give)
	RegisterSignal(holder.mob, list(SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), COMSIG_CARBON_SWAP_HANDS), .proc/cancel_give)


/datum/click_intercept/give/Destroy(force = FALSE, silent = FALSE)
	holder.mouse_pointer_icon = initial(holder.mouse_pointer_icon)
	holder.mob.give_icon.icon_state = "act_give_off"
	if(!silent)
		to_chat(holder.mob, "<span class='info'>You're no longer trying to give someone your held item.</span>")
	UnregisterSignal(holder.mob.get_active_hand(), list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	UnregisterSignal(holder.mob, list(SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), COMSIG_CARBON_SWAP_HANDS))
	return ..()


/datum/click_intercept/give/proc/cancel_give()
	SIGNAL_HANDLER
	qdel(src)


/datum/click_intercept/give/InterceptClickOn(mob/user, params, atom/object)
	if(user == object || !iscarbon(object))
		return
	var/mob/living/carbon/receiver = object
	var/obj/item/I = user.get_active_hand()
	if(!user.Adjacent(object))
		to_chat(user, "<span class='warning'>You need to be closer to [receiver] to offer them [I]</span>")
		return
	if(!receiver.client)
		to_chat(user, "<span class='warning'>You offer [I] to [receiver], but they don't seem to respond...</span>")
		return
	if((receiver.r_hand && receiver.l_hand) || HAS_TRAIT(receiver, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>[receiver] doesn't have any hands free to accept [I]!</span>")
		return
	// We use UID() here so that the receiver can have more then one give request at one time.
	// Otherwise, throwing a new "give item" alert would override any current one also named "give item".
	receiver.throw_alert("give item [I.UID()]", /obj/screen/alert/take_item, alert_args = list(user, receiver, I))
	to_chat(user, "<span class='info'>You offer [I] to [receiver].</span>")
	qdel(src, FALSE, TRUE) // silent = TRUE so we don't give them the default chat message in Destroy.


/**
 * # Take Item alert
 *
 * Alert which appears for a user when another player is attempting to offer them an item.
 * The user can click the alert to accept, or simply do nothing to not take the item.
 */
/obj/screen/alert/take_item
	name = "Take Item"
	desc = "someone wants to hand you an item!"
	icon_state = "template"
	timeout = 10 SECONDS
	/// UID of the mob offering the receiver an item.
	var/giver_UID
	/// UID of the mob who has this alert.
	var/receiver_UID
	/// UID of the item being given.
	var/item_UID


/obj/screen/alert/take_item/Initialize(mapload, mob/giver, mob/receiver, obj/item/I)
	. = ..()
	desc = "[giver] wants to hand you \a [I]. Click here to accept it!"
	giver_UID = giver.UID()
	receiver_UID = receiver.UID()
	item_UID = I.UID()
	add_overlay(icon(I.icon, I.icon_state, SOUTH))
	add_overlay("alert_flash")
	ADD_TRAIT(giver, TRAIT_OFFERING_ITEM, TRAIT_GENERIC)
	RegisterSignal(I, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/cancel_give)
	RegisterSignal(giver, list(SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), COMSIG_CARBON_SWAP_HANDS), .proc/cancel_give)


/obj/screen/alert/take_item/Destroy()
	var/mob/living/giver = locateUID(giver_UID) // REMOVE_TRAIT needs a direct var reference.
	REMOVE_TRAIT(giver, TRAIT_OFFERING_ITEM, TRAIT_GENERIC)
	unregister_signals()
	return ..()


/obj/screen/alert/take_item/proc/unregister_signals()
	UnregisterSignal(locateUID(giver_UID), list(SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), COMSIG_CARBON_SWAP_HANDS))
	UnregisterSignal(locateUID(item_UID), list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))


/obj/screen/alert/take_item/proc/cancel_give()
	SIGNAL_HANDLER
	var/mob/living/giver = locateUID(giver_UID)
	to_chat(giver, "<span class='warning'>You need to keep the item in your active hand if you want to hand it to someone!</span>")
	to_chat(locateUID(receiver_UID), "<span class='warning'>[giver] seems to have given up on giving you [locateUID(item_UID)].</span>")
	qdel(src)


/obj/screen/alert/take_item/Click(location, control, params)
	var/mob/living/receiver = locateUID(receiver_UID)
	var/obj/item/I = locateUID(item_UID)
	if(HAS_TRAIT(receiver, TRAIT_HANDS_BLOCKED))
		to_chat(receiver, "<span class='warning'>You need to have your hands free to accept [I]!</span>")
		return
	var/mob/living/giver = locateUID(giver_UID)
	if(receiver.r_hand && receiver.l_hand)
		to_chat(receiver, "<span class='warning'>Your hands are full!</span>")
		return
	if(!giver.Adjacent(receiver))
		to_chat(receiver, "<span class='warning'>You need to stay in reaching distance of [giver] to take [I]!</span>")
		return
	if((I.flags & NODROP))
		to_chat(giver, "<span class='warning'>[I] stays stuck to your hand when [receiver] tries to take it!</span>")
		to_chat(receiver, "<span class='warning'>[I] stays stuck to [giver]'s hand when you try to take it!</span>")
		return
	// Give is successful at this point, unregister signals so the dropped signal doesn't fire and call `cancel_give()`.
	unregister_signals()
	giver.unEquip(I)
	receiver.put_in_hands(I)
	I.add_fingerprint(receiver)
	I.on_give(giver, receiver)
	receiver.visible_message("<span class='notice'>[giver] handed [I] to [receiver].</span>")
	receiver.clear_alert("give item [item_UID]")


/obj/screen/alert/take_item/do_timeout(mob/M, category)
	var/mob/living/giver = locateUID(giver_UID)
	var/mob/living/receiver = locateUID(receiver_UID)
	// Make sure we're still nearby. We don't want to show a message if the giver not near us.
	if(get_dist(giver, receiver) <= 3)
		var/obj/item/I = locateUID(item_UID)
		to_chat(giver, "<span class='warning'>You tried to hand [I] to [receiver], but they didn't want it.</span>")
		to_chat(receiver, "<span class='warning'>[giver] seems to have given up on giving you [I].</span>")
	..()
