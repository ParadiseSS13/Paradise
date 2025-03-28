/**
 * ## basic eating element!
 *
 * Small behavior for non-carbons to eat certain stuff they interact with
 */
/datum/element/basic_eating
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Amount to heal
	var/heal_amt
	/// Amount to hurt
	var/damage_amount
	/// Type of hurt to apply
	var/damage_type
	/// Whether to flavor it as drinking rather than eating.
	var/drinking
	/// If true, we put food in our tummy instead of deleting it
	var/add_to_contents
	/// Types the animal can eat.
	var/list/food_types

/datum/element/basic_eating/Attach(datum/target, heal_amt_ = 0, damage_amount_ = 0, damage_type_ = null, drinking_ = FALSE, add_to_contents_ = FALSE, food_types_ = list())
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target, TRAIT_MOB_EATER, UID())
	heal_amt = heal_amt_
	damage_amount = damage_amount_
	damage_type = damage_type_
	drinking = drinking_
	add_to_contents = add_to_contents_
	food_types = food_types_

	RegisterSignal(target, COMSIG_INTERACT_TARGET, PROC_REF(try_feed))
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarm_attack))

/datum/element/basic_eating/Detach(datum/target)
	REMOVE_TRAIT(target, TRAIT_MOB_EATER, UID())

	UnregisterSignal(target, list(
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_INTERACT_TARGET,
	))
	return ..()

/datum/element/basic_eating/proc/try_feed(atom/source, mob/living/user, atom/possible_food)
	SIGNAL_HANDLER
	if(!is_type_in_list(possible_food, food_types))
		return NONE
	var/mob/living/living_source = source
	if(living_source.stat != CONSCIOUS)
		return NONE
	return try_eating(source, possible_food, user) ? ITEM_INTERACT_COMPLETE : NONE

/datum/element/basic_eating/proc/on_unarm_attack(mob/living/eater, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(!proximity)
		return NONE

	if(try_eating(eater, target))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/datum/element/basic_eating/proc/try_eating(mob/living/eater, atom/target, mob/living/feeder)
	if(!is_type_in_list(target, food_types))
		return FALSE
	if(SEND_SIGNAL(eater, COMSIG_MOB_PRE_EAT, target, feeder) & COMSIG_MOB_CANCEL_EAT)
		return FALSE
	if(add_to_contents && !ismovable(target))
		return FALSE
	var/eat_verb
	if(drinking)
		eat_verb = pick("slurp","sip","guzzle","drink","quaff")
	else
		eat_verb = pick("bite","chew","nibble","gnaw","gobble","chomp")

	if(heal_amt > 0)
		var/healed = heal_amt && eater.health < eater.maxHealth
		eater.heal_overall_damage(heal_amt)
		eater.visible_message(
			"<span class='notice'>[eater] [eat_verb]s [target].</span>",
			"<span class='notice'>You [eat_verb] [target][healed ? ", restoring some health" : ""].</span>")

	else if(damage_amount > 0 && damage_type)
		eater.apply_damage(damage_amount, damage_type)
		eater.visible_message(
			"<span class='notice'>[eater] [eat_verb]s [target], and seems to hurt itself.</span>",
			"<span class='notice'>You [eat_verb] [target], hurting yourself in the process.</span>")

	else
		eater.visible_message(
			"<span class='notice'>[eater] [eat_verb]s [target].</span>",
			"<span class='notice'>You [eat_verb] [target].</span>")

	finish_eating(eater, target, feeder)
	return TRUE

/datum/element/basic_eating/proc/finish_eating(mob/living/eater, atom/target, mob/living/feeder)
	if(drinking)
		playsound(eater.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	else
		playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	var/atom/final_target = target
	if(SEND_SIGNAL(eater, COMSIG_MOB_ATE, final_target, feeder) & COMSIG_MOB_TERMINATE_EAT)
		return
	if(isstack(target))
		var/obj/item/stack/food_stack = target
		final_target = food_stack.split(eater, 1)

	add_attack_logs(eater, target, "eaten, [add_to_contents ? "consuming it" : "destroying it"]")

	if(add_to_contents)
		var/atom/movable/movable_target = final_target
		movable_target.forceMove(eater)
	else
		qdel(final_target)
