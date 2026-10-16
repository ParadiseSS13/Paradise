/**
 * The Hood Component
 *
 * When applied to an item it will grant it a hood.
 *
 */
/datum/component/hood_component
	/// The hood that the hood component is operating.
	var/obj/item/clothing/head/hood = null
	/// The action the hood component reacts to.
	var/datum/action/item_action/act = null
	/// Does the suit icon get changed depending on the hood.
	/// If TRUE, the items icon NEEDS to have a valid icon state ending with '_hood'.
	var/adjust_icon = FALSE
	/// Track the state of the hood.
	var/deployed = FALSE
	/// Whether NODROP hoods can be taken off.
	var/respects_nodrop = FALSE

/datum/component/hood_component/Initialize(obj/item/clothing/head/hood_type, adjust_icon = FALSE, respects_nodrop = FALSE)
	if(!isclothing(parent) || !ispath(hood_type))
		return COMPONENT_INCOMPATIBLE

	src.hood = new hood_type(parent)
	src.adjust_icon = adjust_icon
	src.respects_nodrop = respects_nodrop
	src.act = new(parent)

	// Old hooded items are referencing each each other.
	if(istype(hood, /obj/item/clothing/head/hooded))
		var/obj/item/clothing/head/hooded/h = hood
		h.suit = parent
	if(istype(parent, /obj/item/clothing/suit/hooded))
		var/obj/item/clothing/suit/hooded/s = parent
		s.hood = hood

/datum/component/hood_component/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_suit_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_suit_drop))
	RegisterSignal(parent, COMSIG_ITEM_CLEAN, PROC_REF(on_suit_clean))
	RegisterSignal(parent, COMSIG_HOOD_TOGGLE, PROC_REF(on_suit_toggle))

	RegisterSignal(hood, COMSIG_ITEM_EQUIPPED, PROC_REF(on_hood_equip))
	RegisterSignal(hood, COMSIG_ITEM_DROPPED, PROC_REF(on_hood_drop))

	RegisterSignal(act, COMSIG_ACTION_TRIGGER, PROC_REF(on_trigger))

/datum/component/hood_component/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_ITEM_CLEAN, COMSIG_HOOD_TOGGLE))
	UnregisterSignal(hood, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	UnregisterSignal(act, COMSIG_ACTION_TRIGGER)

// No component, no hood.
/datum/component/hood_component/Destroy(force, silent)
	. = ..()
	QDEL_NULL(hood)
	QDEL_NULL(act)

// MARK: SUIT SIGNAL HANDLERS
/datum/component/hood_component/proc/on_suit_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER  // COMSIG_ITEM_EQUIPPED
	if(slot != ITEM_SLOT_OUTER_SUIT && deployed)
		remove_hood()

/datum/component/hood_component/proc/on_suit_drop(datum/source, mob/user)
	SIGNAL_HANDLER  // COMSIG_ITEM_DROPPED
	if(deployed)
		remove_hood()

/datum/component/hood_component/proc/on_suit_clean(datum/source, radiation_clean)
	SIGNAL_HANDLER // COMSIG_ITEM_CLEAN
	hood.clean_blood(radiation_clean)

/datum/component/hood_component/proc/on_suit_toggle(datum/source)
	SIGNAL_HANDLER // COMSIG_HOOD_TOGGLE
	toggle_hood()

// MARK: HOOD SIGNAL HANDLERS
/datum/component/hood_component/proc/on_hood_equip(datum/source, mob/user, slot)
	if(slot != ITEM_SLOT_HEAD && deployed)
		remove_hood()

/datum/component/hood_component/proc/on_hood_drop(datum/source, mob/user)
	if(deployed)
		remove_hood()

// MARK: GENERIC OPERATION
/datum/component/hood_component/proc/on_trigger(datum/action/source)
	SIGNAL_HANDLER  // COMSIG_ACTION_TRIGGER
	toggle_hood()

/datum/component/hood_component/proc/toggle_hood()
	if(!deployed)
		put_hood()
	else
		if((hood.flags & NODROP) && respects_nodrop)
			var/obj/item/clothing/suit = parent
			if(ishuman(suit.loc))
				var/mob/living/carbon/human/H = suit.loc
				to_chat(H, SPAN_WARNING("[hood] is stuck to your head!"))
			return
		remove_hood()

/datum/component/hood_component/proc/put_hood()
	var/obj/item/clothing/suit = parent
	if(!ishuman(suit.loc))
		return

	var/mob/living/carbon/human/H = suit.loc
	if(H.wear_suit != suit)
		to_chat(H, SPAN_WARNING("You must be wearing [parent] to put up the hood!"))
		return
	if(H.head)
		to_chat(H, SPAN_WARNING("You're already wearing something on your head!"))
		return
	if(!H.equip_to_slot_if_possible(hood, ITEM_SLOT_HEAD))
		return
	if(adjust_icon)
		suit.icon_state = "[initial(suit.icon_state)]_hood"
		H.update_inv_wear_suit()
	deployed = TRUE

/datum/component/hood_component/proc/remove_hood()
	if(ishuman(hood.loc))
		var/mob/living/carbon/human/H = hood.loc
		H.transfer_item_to(hood, parent, TRUE)
		if(adjust_icon)
			var/obj/item/clothing/suit = parent
			suit.icon_state = "[initial(suit.icon_state)]"
			H.update_inv_wear_suit()
	else
		hood.forceMove(parent)
	deployed = FALSE
