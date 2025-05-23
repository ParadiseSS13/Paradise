/**
 * Responds to certain signals and 'explodes' on the person using the item.
 */
/datum/component/direct_explosive_trap
	/// An optional mob to inform about explosions
	var/mob/living/saboteur
	/// Amount of force to apply
	var/explosive_force
	/// Optional additional target checks before we go off
	var/datum/callback/explosive_check
	/// Signals which set off the bomb, must pass a mob as the first non-source argument
	var/list/triggering_signals

/datum/component/direct_explosive_trap/Initialize(
	mob/living/saboteur_,
	explosive_force_ = EXPLODE_HEAVY,
	expire_time_ = 1 MINUTES,
	glow_colour_ = COLOR_RED,
	datum/callback/explosive_check_,
	list/triggering_signals_ = list(
		// TODO: This is where COMSIG_ATTACK_HAND would be
		// if we could actually rely on it to call its parent
		COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY,
		COMSIG_INTERACT_USER,
		COMSIG_ATTACK_BY,
		COMSIG_ATOM_BUMPED,
		COMSIG_CLICK_ALT,
		COMSIG_ATOM_PULLED,
		COMSIG_MOUSEDROP_ONTO,
	)
)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	saboteur = saboteur_
	explosive_force = explosive_force_
	explosive_check = explosive_check_
	triggering_signals = triggering_signals_

	if(expire_time_ > 0)
		addtimer(CALLBACK(src, PROC_REF(bomb_expired)), expire_time_, TIMER_DELETE_ME)

/datum/component/direct_explosive_trap/RegisterWithParent()
	if(!(COMSIG_PARENT_EXAMINE in triggering_signals)) // Maybe you're being extra mean with this one
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examined))
	RegisterSignals(parent, triggering_signals, PROC_REF(explode))
	if(!isnull(saboteur))
		RegisterSignal(saboteur, COMSIG_PARENT_QDELETING, PROC_REF(on_bomber_deleted))

/datum/component/direct_explosive_trap/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE) + triggering_signals)
	if(!isnull(saboteur))
		UnregisterSignal(saboteur, COMSIG_PARENT_QDELETING)

/datum/component/direct_explosive_trap/Destroy(force)
	if(isnull(saboteur))
		return ..()
	UnregisterSignal(saboteur, COMSIG_PARENT_QDELETING)
	saboteur = null
	return ..()

/// Let people know something is up
/datum/component/direct_explosive_trap/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER // COMSIG_PARENT_EXAMINE
	if(get_dist(source, user) <= 2)
		examine_text += "<span class='notice'>Looks odd!</span>"

/// Blow up
/datum/component/direct_explosive_trap/proc/explode(atom/source, mob/living/victim)
	SIGNAL_HANDLER // triggering_signals
	if(!isliving(victim))
		return
	if(!isnull(explosive_check))
		var/result = explosive_check.Invoke(source, victim)
		if(result == DIRECT_EXPLOSIVE_TRAP_DEFUSE)
			qdel(src)
			return
		else if(result == DIRECT_EXPLOSIVE_TRAP_IGNORE)
			return
	to_chat(victim, "<span class='danger'>[source] was boobytrapped!</span>")
	if(!isnull(saboteur))
		to_chat(saboteur, "<span class='danger'>Success! Your trap on [source] caught [victim.name]!</span>")
	playsound(source, 'sound/effects/explosion2.ogg', 200, TRUE)
	victim.ex_act(explosive_force)
	// A bomb went off in your hands. Actually lets people follow up with it if
	// they bait someone, right now it is unreliable.
	victim.Stun(3 SECONDS)
	qdel(src)

/// Called if we sit too long without going off
/datum/component/direct_explosive_trap/proc/bomb_expired()
	if(!isnull(saboteur))
		to_chat(saboteur, "<span class='danger'>Failure! Your trap on [parent] didn't catch anyone this time.</span>")
	qdel(src)

/// Don't hang a reference to the person who placed the bomb
/datum/component/direct_explosive_trap/proc/on_bomber_deleted()
	SIGNAL_HANDLER
	saboteur = null
