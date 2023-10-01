#define NO_CHANGE -1

/**
 * Two Handed Component
 *
 * When applied to an item it will make it two handed
 *
 */
/datum/component/two_handed
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS // Only one of the component can exist on an item
	/// Are we holding the two handed item properly
	var/wielded = FALSE
	/// The multiplier applied to force when wielded, does not work with force_wielded, and force_unwielded
	var/force_multiplier = 0
	/// The force of the item when weilded
	var/force_wielded = 0
	/// The force of the item when unweilded
	var/force_unwielded = 0
	/// Play sound when wielded
	var/wieldsound = FALSE
	/// Play sound when unwielded
	var/unwieldsound = FALSE
	/// Play sound on attack when wielded
	var/attacksound = FALSE
	/// Does it have to be held in both hands
	var/require_twohands = FALSE
	/// The icon that will be used when wielded
	var/icon_wielded = FALSE
	/// Reference to the offhand created for the item
	var/obj/item/offhand/offhand_item = null
	/// The amount of increase recived from sharpening the item
	var/sharpened_increase = 0
	/// A callback on the parent to be called when the item is wielded
	var/datum/callback/wield_callback
	/// A callback on the parent to be called when the item is unwielded
	var/datum/callback/unwield_callback
	/// Whether or not the object is only sharp when wielded. If it's never sharp, ignore this.
	var/only_sharp_when_wielded = FALSE

/**

 * Two Handed component
 *
 * vars:
 * * require_twohands (optional) Does the item need both hands to be carried
 * * wieldsound (optional) The sound to play when wielded
 * * unwieldsound (optional) The sound to play when unwielded
 * * attacksound (optional) The sound to play when wielded and attacking
 * * force_multiplier (optional) The force multiplier when wielded, do not use with force_wielded, and force_unwielded
 * * force_wielded (optional) The force setting when the item is wielded, do not use with force_multiplier
 * * force_unwielded (optional) The force setting when the item is unwielded, do not use with force_multiplier
 * * icon_wielded (optional) The icon to be used when wielded
 * * only_sharp_when_wielded (optional) Is the item only sharp when held in both hands?
 */
/datum/component/two_handed/Initialize(require_twohands = FALSE, wieldsound = FALSE, unwieldsound = FALSE, attacksound = FALSE, \
										force_multiplier = 0, force_wielded = 0, force_unwielded = 0, icon_wielded = FALSE, \
										only_sharp_when_wielded = FALSE, datum/callback/wield_callback, datum/callback/unwield_callback)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.require_twohands = require_twohands
	src.wieldsound = wieldsound
	src.unwieldsound = unwieldsound
	src.attacksound = attacksound
	src.force_multiplier = force_multiplier
	src.force_wielded = force_wielded
	src.force_unwielded = force_unwielded
	src.icon_wielded = icon_wielded
	src.wield_callback = wield_callback
	src.unwield_callback = unwield_callback
	src.only_sharp_when_wielded = only_sharp_when_wielded


// Inherit the new values passed to the component
/datum/component/two_handed/InheritComponent(datum/component/two_handed/new_comp, original, require_twohands = NO_CHANGE, wieldsound = NO_CHANGE, unwieldsound = NO_CHANGE, \
											force_multiplier = NO_CHANGE, force_wielded = NO_CHANGE, force_unwielded = NO_CHANGE, icon_wielded = NO_CHANGE, \
											only_sharp_when_wielded = NO_CHANGE, datum/callback/wield_callback = NO_CHANGE, datum/callback/unwield_callback = NO_CHANGE)
	if(!original)
		return
	if(require_twohands != NO_CHANGE)
		src.require_twohands = require_twohands
	if(wieldsound != NO_CHANGE)
		src.wieldsound = wieldsound
	if(unwieldsound != NO_CHANGE)
		src.unwieldsound = unwieldsound
	if(attacksound != NO_CHANGE)
		src.attacksound = attacksound
	if(force_multiplier != NO_CHANGE)
		src.force_multiplier = force_multiplier
	if(force_wielded != NO_CHANGE)
		src.force_wielded = force_wielded
	if(force_unwielded != NO_CHANGE)
		src.force_unwielded = force_unwielded
	if(icon_wielded != NO_CHANGE)
		src.icon_wielded = icon_wielded
	if(wield_callback != NO_CHANGE)
		src.wield_callback = wield_callback
	if(unwield_callback != NO_CHANGE)
		src.unwield_callback = unwield_callback
	if(only_sharp_when_wielded != NO_CHANGE)
		src.only_sharp_when_wielded = only_sharp_when_wielded

// register signals withthe parent item
/datum/component/two_handed/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON, PROC_REF(on_update_icon))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, PROC_REF(on_sharpen))
	RegisterSignal(parent, COMSIG_CARBON_UPDATE_HANDCUFFED, PROC_REF(on_handcuff_user))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))

// Remove all siginals registered to the parent item
/datum/component/two_handed/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED,
								COMSIG_ITEM_DROPPED,
								COMSIG_ITEM_ATTACK_SELF,
								COMSIG_ITEM_ATTACK,
								COMSIG_ATOM_UPDATE_ICON,
								COMSIG_MOVABLE_MOVED,
								COMSIG_ITEM_SHARPEN_ACT))

/// Triggered on equip of the item containing the component
/datum/component/two_handed/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER  // COMSIG_ITEM_EQUIPPED

	if(require_twohands && (slot == SLOT_HUD_LEFT_HAND || slot == SLOT_HUD_RIGHT_HAND)) // force equip the item
		INVOKE_ASYNC(src, PROC_REF(wield), user)
	if(!user.is_holding(parent) && wielded && !require_twohands)
		INVOKE_ASYNC(src, PROC_REF(unwield), user)

/// Triggered on drop of item containing the component
/datum/component/two_handed/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER  // COMSIG_ITEM_DROPPED

	if(require_twohands) //Don't let the item fall to the ground and cause bugs if it's actually being equipped on another slot.
		INVOKE_ASYNC(src, PROC_REF(unwield), user, FALSE, FALSE)
	if(wielded)
		INVOKE_ASYNC(src, PROC_REF(unwield), user)
	if(source == offhand_item && !QDELETED(source))
		offhand_item = null
		qdel(source)

/// Triggered on destroy of the component's offhand
/datum/component/two_handed/proc/on_destroy(datum/source)
	SIGNAL_HANDLER
	offhand_item = null


/// Triggered on attack self of the item containing the component
/datum/component/two_handed/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER  // COMSIG_ITEM_ATTACK_SELF

	if(require_twohands)
		return
	if(wielded)
		INVOKE_ASYNC(src, PROC_REF(unwield), user)
	else if(user.is_holding(parent))
		INVOKE_ASYNC(src, PROC_REF(wield), user)

/datum/component/two_handed/proc/on_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER  // COMSIG_ATOM_ATTACK_HAND if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
	if(require_twohands && user.get_inactive_hand())
		to_chat(user, "<span class='notice'>[parent] is too cumbersome to carry in one hand!</span>")
		return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Wield the two handed item in both hands
 *
 * vars:
 * * user The mob/living/carbon that is wielding the item
 */
/datum/component/two_handed/proc/wield(mob/living/carbon/user)
	if(wielded)
		return
	if(ismonkeybasic(user))
		if(require_twohands)
			to_chat(user, "<span class='notice'>[parent] is too heavy and cumbersome for you to carry!</span>")
			user.unEquip(parent, force = TRUE)
		else
			to_chat(user, "<span class='notice'>[parent] too heavy for you to wield fully.</span>")
		return
	if(user.get_inactive_hand())
		if(require_twohands)
			to_chat(user, "<span class='notice'>[parent] is too cumbersome to carry in one hand!</span>")
			user.unEquip(parent, force = TRUE)
		else
			to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return
	if(!user.has_both_hands())
		if(require_twohands)
			user.unEquip(parent, force = TRUE)
		to_chat(user, "<span class='warning'>You don't have enough intact hands.</span>")
		return

	// wield update status
	if(SEND_SIGNAL(parent, COMSIG_TWOHANDED_WIELD, user) & COMPONENT_TWOHANDED_BLOCK_WIELD)
		return // blocked wield from item
	wielded = TRUE
	ADD_TRAIT(parent, TRAIT_WIELDED, "[\ref(src)]")
	RegisterSignal(user, COMSIG_MOB_SWAPPING_HANDS, PROC_REF(on_swapping_hands))
	if(only_sharp_when_wielded)
		var/obj/O = parent
		O.set_sharpness(TRUE)
	wield_callback?.Invoke(parent, user)

	// update item stats and name
	var/obj/item/parent_item = parent
	if(force_multiplier)
		parent_item.force *= force_multiplier
	else if(force_wielded)
		parent_item.force = force_wielded
	if(sharpened_increase && only_sharp_when_wielded)
		parent_item.force += sharpened_increase
	parent_item.name = "[parent_item.name] (Wielded)"
	parent_item.update_appearance()

	if(isrobot(user))
		to_chat(user, "<span class='notice'>You dedicate your module to [parent].</span>")
	else
		to_chat(user, "<span class='notice'>You grab [parent] with both hands.</span>")

	// Play sound if one is set
	if(wieldsound)
		playsound(parent_item.loc, wieldsound, 50, TRUE)

	// Let's reserve the other hand
	offhand_item = new(user)
	offhand_item.name = "[parent_item.name] - offhand"
	offhand_item.desc = "Your second grip on [parent_item]."
	offhand_item.wielded = TRUE
	RegisterSignal(offhand_item, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(offhand_item, COMSIG_PARENT_QDELETING, PROC_REF(on_destroy))
	user.put_in_inactive_hand(offhand_item)

/**
 * Unwield the two handed item
 *
 * vars:
 * * user The mob/living/carbon that is unwielding the item
 * * show_message (option) show a message to chat on unwield
 * * can_drop (option) whether 'dropItemToGround' can be called or not.
 */
/datum/component/two_handed/proc/unwield(mob/living/carbon/user, show_message=TRUE, can_drop=TRUE)
	if(!wielded)
		return

	// wield update status
	wielded = FALSE
	UnregisterSignal(user, COMSIG_MOB_SWAPPING_HANDS)
	SEND_SIGNAL(parent, COMSIG_TWOHANDED_UNWIELD, user)
	REMOVE_TRAIT(parent, TRAIT_WIELDED, "[\ref(src)]")
	unwield_callback?.Invoke(parent, user)
	if(only_sharp_when_wielded)
		var/obj/O = parent
		O.set_sharpness(FALSE)

	// update item stats
	var/obj/item/parent_item = parent
	if(sharpened_increase && only_sharp_when_wielded)
		parent_item.force -= sharpened_increase
	if(force_multiplier)
		parent_item.force /= force_multiplier
	else if(force_unwielded)
		parent_item.force = force_unwielded

	// update the items name to remove the wielded status
	var/sf = findtext(parent_item.name, " (Wielded)", -10) // 10 == length(" (Wielded)")
	if(sf)
		parent_item.name = copytext(parent_item.name, 1, sf)
	else
		parent_item.name = "[initial(parent_item.name)]"

	// Update icons
	parent_item.update_appearance()

	if(istype(user)) // tk showed that we might not have a mob here
		if(user.get_item_by_slot(SLOT_HUD_BACK) == parent)
			user.update_inv_back()
		else
			user.update_inv_l_hand()
			user.update_inv_r_hand()

		// if the item requires two handed drop the item on unwield
		if(require_twohands && can_drop)
			user.unEquip(parent, force = TRUE)

		// Show message if requested
		if(show_message)
			if(isrobot(user))
				to_chat(user, "<span class='notice'>You free up your module.</span>")
			else if(require_twohands)
				to_chat(user, "<span class='notice'>You drop [parent].</span>")
			else
				to_chat(user, "<span class='notice'>You are now carrying [parent] with one hand.</span>")

	// Play sound if set
	if(unwieldsound)
		playsound(parent_item.loc, unwieldsound, 50, TRUE)

	// Remove the object in the offhand
	if(offhand_item)
		UnregisterSignal(offhand_item, list(COMSIG_ITEM_DROPPED, COMSIG_PARENT_QDELETING))
		qdel(offhand_item)
	// Clear any old refrence to an item that should be gone now
	offhand_item = null

/**
 * on_attack triggers on attack with the parent item
 */
/datum/component/two_handed/proc/on_attack(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER  // COMSIG_ITEM_ATTACK
	if(wielded && attacksound)
		var/obj/item/parent_item = parent
		playsound(parent_item.loc, attacksound, 50, TRUE)

/**
 * on_update_icon triggers on call to update parent items icon
 *
 * Updates the icon using icon_wielded if set
 */
/datum/component/two_handed/proc/on_update_icon(obj/item/source)
	SIGNAL_HANDLER
	if(!wielded)
		return NONE
	if(!icon_wielded)
		return NONE
	source.icon_state = icon_wielded
	return COMSIG_ATOM_NO_UPDATE_ICON_STATE

/**
 * on_moved Triggers on item moved
 */
/datum/component/two_handed/proc/on_moved(datum/source, mob/user, dir)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(unwield), user, FALSE, FALSE)

/**
 * on_swap_hands Triggers on swapping hands, blocks swap if the other hand is busy
 */
/datum/component/two_handed/proc/on_swapping_hands(mob/user, obj/item/held_item)
	SIGNAL_HANDLER

	if(!held_item)
		return
	if(held_item == parent)
		return COMPONENT_BLOCK_SWAP

/**
 * on_sharpen Triggers on usage of a sharpening stone on the item
 */
/datum/component/two_handed/proc/on_sharpen(obj/item/item, amount, max_amount)
	SIGNAL_HANDLER

	if(!item)
		return COMPONENT_BLOCK_SHARPEN_BLOCKED
	if(sharpened_increase)
		return COMPONENT_BLOCK_SHARPEN_ALREADY
	if(force_wielded >= max_amount)
		return COMPONENT_BLOCK_SHARPEN_MAXED
	var/wielded_val = 0
	if(force_multiplier)
		var/obj/item/parent_item = parent
		if(wielded)
			wielded_val = parent_item.force
		else
			wielded_val = parent_item.force * force_multiplier
	else
		wielded_val = force_wielded
	if(wielded_val > max_amount)
		return COMPONENT_BLOCK_SHARPEN_MAXED
	sharpened_increase = min(amount, (max_amount - wielded_val))
	var/obj/item/I = parent
	if(!only_sharp_when_wielded)
		force_unwielded += sharpened_increase
		I.force += sharpened_increase  // todo double check this logic is correct
	else if(wielded)
		I.force += sharpened_increase
	// also update force_wielded so this still gets applied after re-wielding
	force_wielded += sharpened_increase
	return COMPONENT_SHARPEN_APPLIED  // don't return the "sharpened applied" signal since we probably wanna sharpen the base form too

/datum/component/two_handed/proc/on_handcuff_user(mob/user, handcuff_status)
	SIGNAL_HANDLER  // COMSIG_CARBON_UPDATE_HANDCUFFED
	if(handcuff_status)
		if(require_twohands)
			INVOKE_ASYNC(src, PROC_REF(try_drop_item), user)
		else
			user.visible_message("<span class='notice'>[user] unwields [parent] as the handcuffs make it too hard to hold properly.</span>")
			INVOKE_ASYNC(src, PROC_REF(unwield), user)

/datum/component/two_handed/proc/try_drop_item(mob/user)
	if(user.unEquip(parent))
		user.visible_message("<span class='notice'>[user] loses [user.p_their()] grip on [parent]!</span>")

/**
 * The offhand dummy item for two handed items
 *
 */
/obj/item/offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	flags = ABSTRACT | NODROP
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/wielded = FALSE // Off Hand tracking of wielded status

/obj/item/offhand/Destroy()
	wielded = FALSE
	return ..()

/obj/item/offhand/equipped(mob/user, slot)
	. = ..()
	if(wielded && !user.is_holding(src) && !QDELETED(src))
		qdel(src)

#undef NO_CHANGE
