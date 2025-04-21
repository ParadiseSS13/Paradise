/**
 * This element registers to a shitload of signals which can signify "someone attacked me".
 * If anyone does it sends a single "someone attacked me" signal containing details about who done it.
 * This prevents other components and elements from having to register to the same list of a million signals, should be more maintainable in one place.
 */
/datum/element/relay_attackers

/datum/element/relay_attackers/Attach(datum/target)
	. = ..()
	if(!HAS_TRAIT(target, TRAIT_RELAYING_ATTACKER)) // Little bit gross but we want to just apply this shit from a bunch of places
		// Boy this sure is a lot of ways to tell us that someone tried to attack us
		RegisterSignal(target, COMSIG_AFTER_ATTACKED_BY, PROC_REF(on_after_attacked_by))
		RegisterSignals(target, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW), PROC_REF(on_attack_generic))
		RegisterSignals(target, list(COMSIG_ATOM_ATTACK_BASIC_MOB, COMSIG_ATOM_ATTACK_ANIMAL), PROC_REF(on_attack_npc))
		RegisterSignal(target, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
		RegisterSignal(target, COMSIG_ATOM_HITBY, PROC_REF(on_hitby))
		RegisterSignal(target, COMSIG_ATOM_HULK_ATTACK, PROC_REF(on_attack_hulk))
	ADD_TRAIT(target, TRAIT_RELAYING_ATTACKER, UID())

/datum/element/relay_attackers/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(
		COMSIG_AFTER_ATTACKED_BY,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_ATOM_ATTACK_BASIC_MOB,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_HITBY,
		COMSIG_ATOM_HULK_ATTACK,
	))
	REMOVE_TRAIT(source, TRAIT_RELAYING_ATTACKER, UID())

/datum/element/relay_attackers/proc/on_after_attacked_by(atom/target, obj/item/weapon, mob/attacker, proximity_flag, click_parameters)
	SIGNAL_HANDLER // COMSIG_AFTER_ATTACKED_BY
	if(!proximity_flag) // we don't care about someone clicking us with a piece of metal from across the room
		return
	if(weapon.force)
		relay_attacker(target, attacker, weapon.damtype == STAMINA ? ATTACKER_STAMINA_ATTACK : ATTACKER_DAMAGING_ATTACK)

/datum/element/relay_attackers/proc/on_attack_generic(atom/target, mob/living/attacker, list/modifiers)
	SIGNAL_HANDLER

	// Check for a shove.
	if(attacker.a_intent == INTENT_DISARM)
		relay_attacker(target, attacker, ATTACKER_SHOVING)
		return

	// Else check for harm intent.
	if(attacker.a_intent == INTENT_HARM)
		relay_attacker(target, attacker, ATTACKER_DAMAGING_ATTACK)
		return

/datum/element/relay_attackers/proc/on_attack_npc(atom/target, mob/living/attacker)
	SIGNAL_HANDLER // COMSIG_ATOM_ATTACK_BASIC_MOB + COMSIG_ATOM_ATTACK_ANIMAL
	// both simple animals and basic mobs have the same var name here but we have to check both types
	if(isanimal(attacker))
		var/mob/living/simple_animal/SA = attacker
		if(SA.melee_damage_upper > 0)
			relay_attacker(target, attacker, ATTACKER_DAMAGING_ATTACK)
			return
	if(isbasicmob(attacker))
		var/mob/living/basic/B = attacker
		if(B.melee_damage_upper > 0)
			relay_attacker(target, attacker, ATTACKER_DAMAGING_ATTACK)
			return

/// Even if another component blocked this hit, someone still shot at us
/datum/element/relay_attackers/proc/on_bullet_act(atom/target, obj/item/projectile/hit_projectile)
	SIGNAL_HANDLER // COMSIG_ATOM_BULLET_ACT
	if(!hit_projectile.is_hostile_projectile())
		return
	if(!ismob(hit_projectile.firer))
		return
	relay_attacker(target, hit_projectile.firer, hit_projectile.damage_type == STAMINA ? ATTACKER_STAMINA_ATTACK : ATTACKER_DAMAGING_ATTACK)

/// Even if another component blocked this hit, someone still threw something
/datum/element/relay_attackers/proc/on_hitby(atom/target, atom/movable/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER // COMSIG_ATOM_HITBY
	if(!isitem(hit_atom))
		return
	var/obj/item/hit_item = hit_atom
	if(!hit_item.throwforce)
		return
	var/mob/thrown_by = locateUID(hit_item.thrownby)
	if(!ismob(thrown_by))
		return
	relay_attacker(target, thrown_by, hit_item.damtype == STAMINA ? ATTACKER_STAMINA_ATTACK : ATTACKER_DAMAGING_ATTACK)

/datum/element/relay_attackers/proc/on_attack_hulk(atom/target, mob/attacker)
	SIGNAL_HANDLER
	relay_attacker(target, attacker, ATTACKER_DAMAGING_ATTACK)

/// Send out a signal identifying whoever just attacked us (usually a mob but sometimes a mech or turret)
/datum/element/relay_attackers/proc/relay_attacker(atom/victim, atom/attacker, attack_flags)
	SEND_SIGNAL(victim, COMSIG_ATOM_WAS_ATTACKED, attacker, attack_flags)
