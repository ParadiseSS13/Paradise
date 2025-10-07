/**
 * ## Item interaction
 *
 * Handles non-combat iteractions of a tool on this atom,
 * such as using a tool on a wall to deconstruct it,
 * or scanning someone with a health analyzer
 */
/atom/proc/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	// We do not have a combat mode or secondary actions like /tg/, so instead
	// I'm unilaterally deciding it here: If you are not on harm intent, tool
	// interactions are not attacks. Shit like the autolathe accepting
	// screwdrivers on harm intent is unintuitive and needs to go away, and there
	// are dozens of ${TOOL}_act procs that do constant harm intent checks.
	var/tool_return = tool_act(user, tool, modifiers)
	if(tool_return)
		return tool_return

	var/early_sig_return = NONE
	/*
	 * This is intentionally using `||` instead of `|` to short-circuit the signal calls
	 * This is because we want to return early if ANY of these signals return a value
	 *
	 * This puts priority on the atom's signals, then the tool's signals, then the user's signals
	 */
	early_sig_return = SEND_SIGNAL(src, COMSIG_INTERACT_TARGET, user, tool, modifiers) \
		|| SEND_SIGNAL(tool, COMSIG_INTERACTING, user, src, modifiers) \
		|| SEND_SIGNAL(user, COMSIG_INTERACT_USER, src, tool, modifiers)

	if(early_sig_return)
		return early_sig_return

	if(new_attack_chain)
		var/self_interaction = item_interaction(user, tool, modifiers)
		if(self_interaction)
			return self_interaction

	if(tool.new_attack_chain)
		var/interact_return = tool.interact_with_atom(src, user, modifiers)
		if(interact_return)
			return interact_return

	return NONE

/**
 *
 * ## Tool Act
 *
 * Handles using specific tools on this atom directly.
 *
 * Handles the tool_acts in particular, such as wrenches and screwdrivers.
 *
 * This can be overriden to handle unique "tool interactions"
 * IE using an item like a tool (when it's not actually one)
 * but otherwise does nothing that [item_interaction] doesn't already do.
 *
 * In other words, use sparingly. It's harder to use (correctly) than [item_interaction].
 */
/atom/proc/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	if(SEND_SIGNAL(src, COMSIG_TOOL_ATTACK, tool, user) & COMPONENT_CANCEL_TOOLACT)
		return FALSE

	var/tool_type = tool.tool_behaviour
	if(!tool_type)
		return NONE

	var/act_result = NONE // or FALSE, or null, as some things may return

	switch(tool_type)
		if(TOOL_CROWBAR)
			act_result = crowbar_act(user, tool)
		if(TOOL_MULTITOOL)
			act_result = multitool_act(user, tool)
		if(TOOL_SCREWDRIVER)
			act_result = screwdriver_act(user, tool)
		if(TOOL_WRENCH)
			act_result = wrench_act(user, tool)
		if(TOOL_WIRECUTTER)
			act_result = wirecutter_act(user, tool)
		if(TOOL_WELDER)
			act_result = welder_act(user, tool)
		if(TOOL_HAMMER)
			act_result = hammer_act(user, tool)

	if(!act_result)
		return NONE

	return ITEM_INTERACT_COMPLETE

/**
 * Called when this atom has an item used on it.
 * IE, a mob is clicking on this atom with an item.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 * Return NONE to allow default interaction / tool handling.
 */
/atom/proc/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	return NONE

/**
 * Called when this item is being used to interact with an atom,
 * IE, a mob is clicking on an atom with this item.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 * Return NONE to allow default interaction / tool handling.
 */
/obj/item/proc/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	return NONE

/**
 * ## Ranged item interaction
 *
 * Handles non-combat ranged interactions of a tool on this atom,
 * such as shooting a gun in the direction of someone*,
 * having a scanner you can point at someone to scan them at any distance,
 * or pointing a laser pointer at something.
 *
 * *While this intuitively sounds combat related, it is not,
 * because a "combat use" of a gun is gun-butting.
 */
/atom/proc/base_ranged_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	// See [base_item_interaction] for defails on why this is using `||` (TL;DR it's short circuiting)
	var/early_sig_return = SEND_SIGNAL(src, COMSIG_INTERACT_RANGED, user, tool, modifiers) \
		|| SEND_SIGNAL(tool, COMSIG_INTERACTING_RANGED, user, src, modifiers)

	if(early_sig_return)
		return early_sig_return

	var/self_interaction = ranged_item_interaction(user, tool, modifiers)
	if(self_interaction)
		return self_interaction

	var/interact_return = tool.ranged_interact_with_atom(src, user, modifiers)
	if(interact_return)
		return interact_return

	return NONE

/**
 * Called when this atom has an item used on it from a distance.
 * IE, a mob is clicking on this atom with an item and is not adjacent.
 *
 * Does NOT include Telekinesis users, they are considered adjacent generally.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 */
/atom/proc/ranged_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return NONE

/**
 * Called when this item is being used to interact with an atom from a distance,
 * IE, a mob is clicking on an atom with this item and is not adjacent.
 *
 * Does NOT include Telekinesis users, they are considered adjacent generally
 * (so long as this item is adjacent to the atom).
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 */
/obj/item/proc/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	return NONE
