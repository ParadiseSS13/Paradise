/**
 * Component which lets ghosts click on a mob to take control of it
 */
/datum/component/ghost_direct_control
	/// Message to display upon successful possession
	var/assumed_control_message
	/// Type of ban you can get to prevent you from accepting this role
	var/ban_type
	/// Any extra checks which need to run before we take over
	var/datum/callback/extra_control_checks
	/// Callback run after someone successfully takes over the body
	var/datum/callback/after_assumed_control
	/// If we're currently awaiting the results of a ghost poll
	var/awaiting_ghosts = FALSE
	/// Is this an antagonist spawner, so we check ROLE_SYNDICATE
	var/is_antag_spawner

/datum/component/ghost_direct_control/Initialize(
			ban_type = ROLE_SENTIENT,
			role_name = null,
			poll_question = null,
			poll_candidates = TRUE,
			poll_length = 10 SECONDS,
			assumed_control_message = null,
			datum/callback/extra_control_checks,
			datum/callback/after_assumed_control,
			is_antag_spawner = TRUE,
		)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.ban_type = ban_type
	src.assumed_control_message = assumed_control_message || "You are [parent]!"
	src.extra_control_checks = extra_control_checks
	src.after_assumed_control = after_assumed_control
	src.is_antag_spawner = is_antag_spawner


	if(poll_candidates)
		INVOKE_ASYNC(src, PROC_REF(request_ghost_control), poll_question, role_name || "[parent]", poll_length)

/datum/component/ghost_direct_control/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_ghost_clicked))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(on_login))

/datum/component/ghost_direct_control/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_GHOST, COMSIG_PARENT_EXAMINE, COMSIG_MOB_LOGIN))
	return ..()

/datum/component/ghost_direct_control/Destroy(force)
	extra_control_checks = null
	after_assumed_control = null
	return ..()

/// Inform ghosts that they can possess this
/datum/component/ghost_direct_control/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER //COMSIG_PARENT_EXAMINE
	if(!isobserver(user))
		return
	var/mob/living/our_mob = parent
	if(our_mob.stat == DEAD || our_mob.key || awaiting_ghosts)
		return
	examine_text += "<span class='boldnotice'>You could take control of this mob by clicking on it.</span>"

/// Send out a request for a brain
/datum/component/ghost_direct_control/proc/request_ghost_control(poll_question, role_name, poll_length)
	awaiting_ghosts = TRUE
	var/list/candidates = SSghost_spawns.poll_candidates(
		question = poll_question,
		role = ban_type,
		poll_time = poll_length,
		source = parent,
		role_cleanname = role_name,
		flash_window = FALSE,
		dont_play_notice_sound = TRUE
	)
	awaiting_ghosts = FALSE
	var/mob/chosen_one = null
	if(length(candidates))
		chosen_one = pick(candidates)

	if(isnull(chosen_one))
		return
	assume_direct_control(chosen_one)

/// A ghost clicked on us, they want to get in this body
/datum/component/ghost_direct_control/proc/on_ghost_clicked(mob/our_mob, mob/dead/observer/hopeful_ghost)
	SIGNAL_HANDLER // COMSIG_ATOM_ATTACK_GHOST
	if(our_mob.key)
		qdel(src)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!hopeful_ghost.client)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(awaiting_ghosts)
		to_chat(hopeful_ghost, "<span class='warning'>Ghost candidate selection currently in progress!</span>")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!SSticker.HasRoundStarted())
		to_chat(hopeful_ghost, "<span class='warning'>You cannot assume control of this until after the round has started!</span>")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	INVOKE_ASYNC(src, PROC_REF(attempt_possession), our_mob, hopeful_ghost)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// We got far enough to establish that this mob is a valid target, let's try to posssess it
/datum/component/ghost_direct_control/proc/attempt_possession(mob/our_mob, mob/dead/observer/hopeful_ghost)
	var/ghost_asked = tgui_alert(usr, "Become [our_mob]?", "Are you sure?", list("Yes", "No"))
	if(ghost_asked != "Yes" || QDELETED(our_mob))
		return
	assume_direct_control(hopeful_ghost)

/// Grant possession of our mob, component is now no longer required
/datum/component/ghost_direct_control/proc/assume_direct_control(mob/harbinger)
	if(QDELETED(src))
		to_chat(harbinger, "<span class='warning'>Offer to possess creature has expired!</span>")
		return
	if(jobban_isbanned(harbinger, ban_type) || jobban_isbanned(harbinger, ROLE_SENTIENT) || (is_antag_spawner && jobban_isbanned(harbinger, ROLE_SYNDICATE)))
		to_chat(harbinger, "<span class='warning'>You are banned from playing as this role!</span>")
		return
	var/mob/living/new_body = parent
	if(new_body.stat == DEAD)
		to_chat(harbinger, "<span class='warning'>This body has passed away, it is of no use!</span>")
		return
	if(new_body.key)
		to_chat(harbinger, "<span class='warning'>[parent] has already become sapient!</span>")
		qdel(src)
		return
	if(extra_control_checks && !extra_control_checks.Invoke(harbinger))
		return

	// doesn't transfer mind because that transfers antag datum as well
	new_body.key = harbinger.key

	// Already qdels due to below proc but just in case
	if(!QDELETED(src))
		qdel(src)

/// When someone assumes control, get rid of our component
/datum/component/ghost_direct_control/proc/on_login(mob/harbinger)
	SIGNAL_HANDLER //COMSIG_MOB_LOGIN
	// This proc is called the very moment .key is set, so we need to force mind to initialize here if we want the invoke to affect the mind of the mob
	if(isnull(harbinger.mind))
		harbinger.mind_initialize()
	to_chat(harbinger, "<span class='boldnotice'>[assumed_control_message]</span>")
	after_assumed_control?.Invoke(harbinger)
	qdel(src)
