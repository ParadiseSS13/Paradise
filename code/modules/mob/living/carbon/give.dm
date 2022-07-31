/**
 * Toggles the [/datum/click_intercept/give] on or off for the src mob.
 */
/mob/living/carbon/proc/toggle_give()
	if(has_status_effect(STATUS_EFFECT_OFFERING_ITEM))
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
 * # Offering Item status effect
 *
 * Status effect given to mobs after they've offered an item to another player using the Give Item action ([/datum/click_intercept/give]).
 */
/datum/status_effect/offering_item
	id = "offering item"
	duration = 10 SECONDS
	alert_type = /obj/screen/alert/status_effect/offering_item

/obj/screen/alert/status_effect/offering_item
	name = "Offering Item"
	desc = "You're currently offering an item someone. Make sure to keep the item in your hand so they can accept it!"
	icon_state = "offering_item"

/**
 * # Give click intercept
 *
 * While a mob has this intercept, left clicking on a carbon mob will attempt to offer their currently held item to that mob.
 */
/datum/click_intercept/give
	/// If the intercept user has succesfully offered the item to another player.
	var/item_offered = FALSE

/datum/click_intercept/give/New(client/C)
	..()
	holder.mouse_pointer_icon = file("icons/mouse_icons/give_item.dmi")
	to_chat(holder, "<span class='info'>You can now left click on someone to give them your held item.</span>")
	RegisterSignal(holder.mob.get_active_hand(), list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), /datum/proc/signal_qdel)
	RegisterSignal(holder.mob, list(SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), COMSIG_CARBON_SWAP_HANDS), /datum/proc/signal_qdel)


/datum/click_intercept/give/Destroy(force = FALSE, ...)
	holder.mouse_pointer_icon = initial(holder.mouse_pointer_icon)
	holder.mob.give_icon.icon_state = "act_give_off"
	if(!item_offered)
		to_chat(holder.mob, "<span class='info'>You're no longer trying to give someone your held item.</span>")
	UnregisterSignal(holder.mob.get_active_hand(), list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	UnregisterSignal(holder.mob, list(SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), COMSIG_CARBON_SWAP_HANDS))
	return ..()


/datum/click_intercept/give/InterceptClickOn(mob/user, params, atom/object)
	if(user == object || !iscarbon(object))
		return
	var/mob/living/carbon/receiver = object
	if(receiver.stat != CONSCIOUS)
		to_chat(user, "<span class='warning'>[receiver] can't accept any items because they're [receiver == UNCONSCIOUS ? "unconscious" : "dead"]!</span>")
		return
	var/obj/item/I = user.get_active_hand()
	if(!user.Adjacent(receiver))
		to_chat(user, "<span class='warning'>You need to be closer to [receiver] to offer them [I].</span>")
		return
	if(!receiver.client)
		to_chat(user, "<span class='warning'>You offer [I] to [receiver], but they don't seem to respond...</span>")
		return
	// We use UID() here so that the receiver can have more then one give request at one time.
	// Otherwise, throwing a new "give item" alert would override any current one also named "give item".
	receiver.throw_alert("give item [I.UID()]", /obj/screen/alert/take_item, alert_args = list(user, receiver, I))
	item_offered = TRUE // TRUE so we don't give them the default chat message in Destroy.
	to_chat(user, "<span class='info'>You offer [I] to [receiver].</span>")
	qdel(src)


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
	/// If the receiver succesfully took the item or not.
	var/item_taken = FALSE


/obj/screen/alert/take_item/Initialize(mapload, mob/living/giver, mob/living/receiver, obj/item/I)
	. = ..()
	desc = "[giver] wants to hand you \a [I]. Click here to accept it!"
	giver_UID = giver.UID()
	receiver_UID = receiver.UID()
	item_UID = I.UID()
	giver.apply_status_effect(STATUS_EFFECT_OFFERING_ITEM)
	add_overlay(icon(I.icon, I.icon_state, SOUTH))
	add_overlay("alert_flash")
	RegisterSignal(I, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/cancel_give)
	RegisterSignal(giver, list(SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), COMSIG_CARBON_SWAP_HANDS), .proc/cancel_give)
	// If any one of these atoms should be deleted, we need to cancel everything. Also saves having to do null checks before interacting with these atoms.
	RegisterSignal(I, COMSIG_PARENT_QDELETING, /datum/proc/signal_qdel)
	RegisterSignal(giver, COMSIG_PARENT_QDELETING, /datum/proc/signal_qdel)
	RegisterSignal(receiver, COMSIG_PARENT_QDELETING, /datum/proc/signal_qdel)


/obj/screen/alert/take_item/Destroy()
	var/mob/living/giver = locateUID(giver_UID)
	giver.remove_status_effect(STATUS_EFFECT_OFFERING_ITEM)
	if(!item_taken)
		unregister_signals()
	return ..()


/obj/screen/alert/take_item/proc/unregister_signals()
	var/mob/living/giver = locateUID(giver_UID)
	var/obj/item/I = locateUID(item_UID)
	UnregisterSignal(I, list(COMSIG_PARENT_QDELETING, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	UnregisterSignal(giver, list(COMSIG_PARENT_QDELETING, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), COMSIG_CARBON_SWAP_HANDS))
	UnregisterSignal(locateUID(receiver_UID), COMSIG_PARENT_QDELETING)


/obj/screen/alert/take_item/proc/cancel_give()
	SIGNAL_HANDLER
	var/mob/living/giver = locateUID(giver_UID)
	to_chat(giver, "<span class='warning'>You need to keep the item in your active hand if you want to hand it to someone!</span>")
	to_chat(locateUID(receiver_UID), "<span class='warning'>[giver] seems to have given up on giving you [locateUID(item_UID)].</span>")
	qdel(src)


/obj/screen/alert/take_item/Click(location, control, params)
	var/mob/living/receiver = locateUID(receiver_UID)
	if(receiver.stat != CONSCIOUS)
		return
	var/obj/item/I = locateUID(item_UID)
	if(HAS_TRAIT(receiver, TRAIT_HANDS_BLOCKED) || receiver.r_hand && receiver.l_hand)
		to_chat(receiver, "<span class='warning'>You need to have your hands free to accept [I]!</span>")
		return
	var/mob/living/giver = locateUID(giver_UID)
	if(!giver.Adjacent(receiver))
		to_chat(receiver, "<span class='warning'>You need to stay in reaching distance of [giver] to take [I]!</span>")
		return
	if((I.flags & NODROP))
		to_chat(giver, "<span class='warning'>[I] stays stuck to your hand when [receiver] tries to take it!</span>")
		to_chat(receiver, "<span class='warning'>[I] stays stuck to [giver]'s hand when you try to take it!</span>")
		return
	unregister_signals() // Give is successful at this point, unregister signals so the dropped signal doesn't fire and call `cancel_give()`.
	item_taken = TRUE // This way we don't call `unregister_signals` again in Destroy.
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
