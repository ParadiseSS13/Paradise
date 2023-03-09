///Will execute a single command after the cooldown based on player votes.
#define DEMOCRACY_MODE (1<<0)
///Allows each player to do a single command every cooldown.
#define ANARCHY_MODE (1<<1)
///Mutes the democracy mode messages send to orbiters at the end of each cycle. Useful for when the cooldown is so low it'd get spammy.
#define MUTE_DEMOCRACY_MESSAGES (1<<2)

/**
 * Deadchat Plays Things - The Componenting
 *
 * Allows deadchat to control stuff and things by typing commands into chat.
 * These commands will then trigger callbacks to execute procs!
 */
/datum/component/deadchat_control
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// The id for the DEMOCRACY_MODE looping vote timer.
	var/timerid
	/// Assoc list of key-chat command string, value-callback pairs. list("right" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), src, EAST))
	var/list/datum/callback/inputs = list()
	/// Assoc list of ckey:value pairings. In DEMOCRACY_MODE, value is the player's vote. In ANARCHY_MODE, value is world.time when their cooldown expires.
	var/list/ckey_to_cooldown = list()
	/// List of everything orbitting this component's parent.
	var/orbiters = list()
	/// A bitfield containing the mode which this component uses (DEMOCRACY_MODE or ANARCHY_MODE) and other settings)
	var/deadchat_mode
	/// In DEMOCRACY_MODE, this is how long players have to vote on an input. In ANARCHY_MODE, this is how long between inputs for each unique player.
	var/input_cooldown
	///Set to true if a point of interest was created for an object, and needs to be removed if deadchat control is removed. Needed for preventing objects from having two points of interest.
	var/generated_point_of_interest = FALSE
	/// Callback invoked when this component is Destroy()ed to allow the parent to return to a non-deadchat controlled state.
	var/datum/callback/on_removal

/datum/component/deadchat_control/Initialize(_deadchat_mode, _inputs, _input_cooldown = 12 SECONDS, _on_removal)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_BEGIN, PROC_REF(orbit_begin))
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_STOP, PROC_REF(orbit_stop))
	// RegisterSignal(parent, COMSIG_VV_TOPIC, PROC_REF(handle_vv_topic))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	deadchat_mode = _deadchat_mode
	inputs = _inputs
	input_cooldown = _input_cooldown
	on_removal = _on_removal
	if(deadchat_mode & DEMOCRACY_MODE)
		if(deadchat_mode & ANARCHY_MODE) // Choose one, please.
			stack_trace("deadchat_control component added to [parent.type] with both democracy and anarchy modes enabled.")
		timerid = addtimer(CALLBACK(src, PROC_REF(democracy_loop)), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)

	var/list/input_names = list()
	for(var/item in inputs)
		input_names |= item
	notify_ghosts("[parent] is now deadchat controllable! Possible commands are: [english_list(input_names)]", source = parent, action = NOTIFY_FOLLOW, title="Something Interesting!")
	if(!ismob(parent) && !(parent in GLOB.poi_list))
		GLOB.poi_list |= parent
		// SSpoints_of_interest.make_point_of_interest(parent)
		generated_point_of_interest = TRUE

/datum/component/deadchat_control/Destroy(force, silent)
	on_removal?.Invoke()
	inputs = null
	orbiters = null
	ckey_to_cooldown = null
	if(generated_point_of_interest)
		GLOB.poi_list -= parent
		// SSpoints_of_interest.remove_point_of_interest(parent)
	return ..()

/datum/component/deadchat_control/proc/deadchat_react(mob/source, message)
	SIGNAL_HANDLER

	message = lowertext(message)

	if(!inputs[message])
		return

	if(deadchat_mode & ANARCHY_MODE)
		if(!source || !source.ckey)
			return
		var/cooldown = ckey_to_cooldown[source.ckey] - world.time
		if(cooldown > 0)
			to_chat(source, ("<span class='warning'>Your deadchat control inputs are still on cooldown for another [CEILING(cooldown * 0.1, 1)] second\s.</span>"))
			return MOB_DEADSAY_SIGNAL_INTERCEPT
		ckey_to_cooldown[source.ckey] = world.time + input_cooldown
		addtimer(CALLBACK(src, PROC_REF(end_cooldown), source.ckey), input_cooldown)
		inputs[message].Invoke()
		to_chat(source, ("<span class='notice'>\"[message]\" input accepted. You are now on cooldown for [input_cooldown * 0.1] second\s.</span>"))
		return MOB_DEADSAY_SIGNAL_INTERCEPT

	if(deadchat_mode & DEMOCRACY_MODE)
		ckey_to_cooldown[source.ckey] = message
		to_chat(source, ("<span class='notice'>You have voted for \"[message]\".</span>"))
		return MOB_DEADSAY_SIGNAL_INTERCEPT

/datum/component/deadchat_control/proc/democracy_loop()
	if(QDELETED(parent) || !(deadchat_mode & DEMOCRACY_MODE))
		deltimer(timerid)
		return
	var/result = count_democracy_votes()
	if(!isnull(result))
		inputs[result].Invoke()
		if(!(deadchat_mode & MUTE_DEMOCRACY_MESSAGES))
			var/message = "<span class='deadsay italics bold'>[parent] has done action [result]!<br>New vote started. It will end in [input_cooldown * 0.1] second\s.</span>"
			for(var/M in orbiters)
				to_chat(M, message)
	else if(!(deadchat_mode & MUTE_DEMOCRACY_MESSAGES))
		var/message = "<span class='deadsay italics bold'>No votes were cast this cycle.</span>"
		for(var/M in orbiters)
			to_chat(M, message)

/datum/component/deadchat_control/proc/count_democracy_votes()
	if(!length(ckey_to_cooldown))
		return
	var/list/votes = list()
	for(var/command in inputs)
		votes["[command]"] = 0
	for(var/vote in ckey_to_cooldown)
		votes[ckey_to_cooldown[vote]]++
		ckey_to_cooldown.Remove(vote)

	// Solve which had most votes.
	var/prev_value = 0
	var/result
	for(var/vote in votes)
		if(votes[vote] > prev_value)
			prev_value = votes[vote]
			result = vote

	if(result in inputs)
		return result

/datum/component/deadchat_control/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, deadchat_mode))
		return
	ckey_to_cooldown = list()
	if(var_value == DEMOCRACY_MODE)
		timerid = addtimer(CALLBACK(src, PROC_REF(democracy_loop)), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)
	else
		deltimer(timerid)

/datum/component/deadchat_control/proc/orbit_begin(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	RegisterSignal(orbiter, COMSIG_MOB_DEADSAY, PROC_REF(deadchat_react))
	RegisterSignal(orbiter, COMSIG_MOB_AUTOMUTE_CHECK, PROC_REF(waive_automute))
	orbiters |= orbiter


/datum/component/deadchat_control/proc/orbit_stop(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	if(orbiter in orbiters)
		UnregisterSignal(orbiter, list(
			COMSIG_MOB_DEADSAY,
			COMSIG_MOB_AUTOMUTE_CHECK,
		))
		orbiters -= orbiter

/**
 * Prevents messages used to control the parent from counting towards the automute threshold for repeated identical messages.
 *
 * Arguments:
 * - [speaker][/client]: The mob that is trying to speak.
 * - [client][/client]: The client that is trying to speak.
 * - message: The message that the speaker is trying to say.
 * - mute_type: Which type of mute the message counts towards.
 */
/datum/component/deadchat_control/proc/waive_automute(mob/speaker, client/client, message, mute_type)
	SIGNAL_HANDLER
	if(mute_type == MUTE_DEADCHAT && inputs[lowertext(message)])
		return WAIVE_AUTOMUTE_CHECK
	return NONE


/// Allows for this component to be removed via a dedicated VV dropdown entry.
// /datum/component/deadchat_control/proc/handle_vv_topic(datum/source, mob/user, list/href_list)
// 	SIGNAL_HANDLER
// 	if(!href_list[VV_HK_DEADCHAT_PLAYS] || !check_rights(R_FUN))
// 		return
// 	. = COMPONENT_VV_HANDLED
// 	INVOKE_ASYNC(src, PROC_REF(async_handle_vv_topic), user, href_list)

/// Async proc handling the alert input and associated logic for an admin removing this component via the VV dropdown.
/datum/component/deadchat_control/proc/async_handle_vv_topic(mob/user, list/href_list)
	if(alert(user, "Remove deadchat control from [parent]?", "Deadchat Plays [parent]", list("Remove", "Cancel")) == "Remove")
		// Quick sanity check as this is an async call.
		if(QDELETED(src))
			return

		to_chat(user, "<span class='notice'>Deadchat can no longer control [parent].</span>")
		log_admin("[key_name(user)] has removed deadchat control from [parent]")
		message_admins("<span class='notice'>[key_name(user)] has removed deadchat control from [parent]</span>")

		qdel(src)

/// Informs any examiners to the inputs available as part of deadchat control, as well as the current operating mode and cooldowns.
/datum/component/deadchat_control/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!isobserver(user))
		return

	examine_list += ("<span class='notice'>[A.p_theyre(TRUE)] currently under deadchat control using the [(deadchat_mode & DEMOCRACY_MODE) ? "democracy" : "anarchy"] ruleset!</span>")

	if(deadchat_mode & DEMOCRACY_MODE)
		examine_list += ("<span class='notice'>Type a command into chat to vote on an action. This happens once every [input_cooldown * 0.1] second\s.</span>")
	else if(deadchat_mode & ANARCHY_MODE)
		examine_list += ("<span class='notice'>Type a command into chat to perform. You may do this once every [input_cooldown * 0.1] second\s.</span>")

	var/extended_examine = "<span class='notice'>Command list:"

	for(var/possible_input in inputs)
		extended_examine += " [possible_input]"

	extended_examine += ".</span>"

	examine_list += extended_examine

///Removes the ghost from the ckey_to_cooldown list and lets them know they are free to submit a command for the parent again.
/datum/component/deadchat_control/proc/end_cooldown(ghost_ckey)
	ckey_to_cooldown -= ghost_ckey
	var/mob/ghost = get_mob_by_ckey(ghost_ckey)
	if(!ghost || isliving(ghost))
		return
	to_chat(ghost, "<span class='nicegreen'>Your deadchat control inputs for [parent]([ghost_follow_link(parent, ghost)]) are no longer on cooldown.</span>")

/// Dummy to call since we can't proc reference builtins
/datum/component/deadchat_control/proc/_step(ref, dir)
	step(ref, dir)

/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with all the hottest inputs for a spicy
 * singularity or vomit goose.
 */
/datum/component/deadchat_control/cardinal_movement/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	. = ..()

	inputs["up"] = CALLBACK(src, PROC_REF(_step), parent, NORTH)
	inputs["down"] = CALLBACK(src, PROC_REF(_step), parent, SOUTH)
	inputs["left"] = CALLBACK(src, PROC_REF(_step), parent, WEST)
	inputs["right"] = CALLBACK(src, PROC_REF(_step), parent, EAST)

/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with all the hottest inputs for spicy
 * immovable rod.
 */
/datum/component/deadchat_control/immovable_rod/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!istype(parent, /obj/effect/immovablerod))
		return COMPONENT_INCOMPATIBLE

	. = ..()

	inputs["up"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), NORTH)
	inputs["down"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), SOUTH)
	inputs["left"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), WEST)
	inputs["right"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), EAST)
