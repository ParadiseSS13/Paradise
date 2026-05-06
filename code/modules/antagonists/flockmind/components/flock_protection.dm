/datum/component/flock_protection
	/// Do we get mad if someone punches it?
	var/report_unarmed
	/// Do we get mad if someone hits it with something?
	var/report_attack
	/// Do we get mad if someone throws something at it?
	var/report_thrown
	/// Do we get mad if someone shoots it?
	var/report_proj

/datum/component/flock_protection/Initialize(report_unarmed = TRUE, report_attack = TRUE, report_thrown = TRUE, report_proj = TRUE)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.report_unarmed = report_unarmed
	src.report_attack = report_attack
	src.report_thrown = report_thrown
	src.report_proj = report_proj

/datum/component/flock_protection/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(handle_attackhand))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY,  PROC_REF(handle_attackby))
	RegisterSignal(parent, COMSIG_ATOM_HITBY,  PROC_REF(handle_hitby_thrown))
	RegisterSignal(parent, COMSIG_PROJECTILE_SELF_ON_HIT,  PROC_REF(handle_hitby_proj))

/// Protect against punches/kicks/etc.
/datum/component/flock_protection/proc/handle_attackhand(atom/source, mob/living/user, modifiers)
	SIGNAL_HANDLER
	if(user.combat_mode == TRUE && report_unarmed && trigger(source, user, TRUE))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/// Protect against being hit by something.
/datum/component/flock_protection/proc/handle_attackby(atom/source, obj/item/weapon, mob/user, modifiers)
	SIGNAL_HANDLER
	if(weapon &&  report_attack && trigger(source, user, TRUE))
		return COMPONENT_NO_AFTERATTACK

/// Protect against someone chucking stuff at the parent.
/datum/component/flock_protection/proc/handle_hitby_thrown(atom/source, atom/movable/hitting_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(ismob(throwingdatum.thrower) && report_thrown)
		trigger(source, throwingdatum.thrower, FALSE, null)

/// Protect against someone shooting the parent.
/datum/component/flock_protection/proc/handle_hitby_proj(atom/source, firer, target, Angle, def_zone)
	SIGNAL_HANDLER
	if(ismob(firer) && src.report_proj)
		trigger(source, firer, TRUE, TRUE)

/datum/component/flock_protection/proc/trigger(datum/source, attacker, intentional, projectile_attack)
	return SEND_SIGNAL(source, COMSIG_FLOCK_PROTECTION_TRIGGER, attacker, intentional, projectile_attack)
