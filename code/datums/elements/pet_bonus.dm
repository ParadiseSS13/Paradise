/**
 * # Pet bonus element!
 *
 * Bespoke element that plays a fun message, and sends a heart out when you pet this animal.
 */
/datum/element/pet_bonus
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	///string key of the emote to do when pet.
	var/emote_name

/datum/element/pet_bonus/Attach(datum/target, emote_name)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.emote_name = emote_name
	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))

/datum/element/pet_bonus/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_ATTACK_HAND)

/datum/element/pet_bonus/proc/on_attack_hand(mob/living/pet, mob/living/petter, list/modifiers)
	SIGNAL_HANDLER

	if(pet.stat != CONSCIOUS || petter.intent != INTENT_HELP || LAZYACCESS(modifiers, RIGHT_CLICK))
		return

	new /obj/effect/temp_visual/heart(get_turf(pet))
	if(emote_name && prob(33))
		pet.emote("me", EMOTE_VISIBLE, emote_name)
