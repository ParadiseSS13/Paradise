// TODO: port /datum/callout_option and all the associated shenanigans

/**
 * # Pet Command
 * Set some AI blackboard commands in response to receiving instructions
 * This is abstract and should be extended for actual behaviour
 */
/datum/pet_command
	/// UID of who follows this command
	var/parent_uid
	/// Unique name used for radial selection, should not be shared with other commands on one mob
	var/command_name
	/// Description to display in radial menu
	var/command_desc
	/// If true, command will not appear in radial menu and can only be accessed through speech
	var/hidden = FALSE
	/// Speech strings to listen out for
	VAR_PROTECTED/list/speech_commands = list()
	/// Shown above the mob's head when it hears you
	var/command_feedback
	/// How close a mob needs to be to a target to respond to a command
	var/sense_radius = 7
	/// does this pet command need a point to activate?
	var/requires_pointing = FALSE
	/// Blackboard key for targeting strategy, this is likely going to need it
	var/targeting_strategy_key = BB_PET_TARGETING_STRATEGY
	/// our pointed reaction we play
	var/pointed_reaction
	/// The regex for finding our commands in speech
	VAR_PRIVATE/regex/command_regex

/datum/pet_command/New(mob/living/parent)
	. = ..()
	parent_uid = parent.UID()
	if(length(speech_commands))
		command_regex = regex("\\b([speech_commands.Join("|")])\\b", "i")

/// Register a new guy we want to listen to
/datum/pet_command/proc/add_new_friend(mob/living/tamer)
	RegisterSignal(tamer, COMSIG_MOB_SAY, PROC_REF(respond_to_command))
	RegisterSignal(tamer, COMSIG_MOB_AUTOMUTE_CHECK, PROC_REF(waive_automute))
	if(requires_pointing)
		RegisterSignal(tamer, COMSIG_MOVABLE_POINTED, PROC_REF(point_on_target))

/// Stop listening to a guy
/datum/pet_command/proc/remove_friend(mob/living/unfriended)
	UnregisterSignal(unfriended, list(
		COMSIG_MOB_SAY,
		COMSIG_MOB_AUTOMUTE_CHECK,
		COMSIG_MOVABLE_POINTED,
	))

/// Stop the automute from triggering for commands (unless the spoken text is suspiciously longer than the command)
/datum/pet_command/proc/waive_automute(mob/living/speaker, client/client, last_message, mute_type)
	SIGNAL_HANDLER // COMSIG_MOB_AUTOMUTE_CHECK
	if(mute_type == MUTE_IC && find_command_in_text(last_message, check_verbosity = TRUE))
		return WAIVE_AUTOMUTE_CHECK
	return NONE

/// Respond to something that one of our friends has asked us to do
/datum/pet_command/proc/respond_to_command(mob/living/speaker, speech_args)
	SIGNAL_HANDLER // COMSIG_MOB_SAY
	var/mob/living/parent = locateUID(parent_uid)
	if(!parent)
		return
	if(!can_see(parent, speaker, sense_radius)) // Basically the same rules as hearing
		return

	var/spoken_text = speech_args[SPEECH_MESSAGE]
	if(!find_command_in_text(spoken_text))
		return

	try_activate_command(commander = speaker, radial_command = FALSE)

/**
 * Returns true if we find any of our spoken commands in the text.
 * if check_verbosity is true, skip the match if there spoken_text is way longer than the match
 */
/datum/pet_command/proc/find_command_in_text(spoken_text, check_verbosity = FALSE)
	var/valid_length = check_verbosity ? length(spoken_text) > MAX_NAME_LEN : TRUE
	if(command_regex.Find(spoken_text) && valid_length)
		return TRUE
	return FALSE

/datum/pet_command/proc/pet_able_to_respond()
	var/mob/living/parent = locateUID(parent_uid)
	if(isnull(parent) || isnull(parent.ai_controller))
		return FALSE
	if(parent.stat == DEAD || parent.stat == UNCONSCIOUS) // Probably can't hear them if we're dead
		return FALSE
	return TRUE

/// Apply a command state if conditions are right, return command if successful
/datum/pet_command/proc/try_activate_command(mob/living/commander, radial_command)
	if(!pet_able_to_respond())
		return FALSE
	var/mob/living/parent = locateUID(parent_uid)
	set_command_active(parent, commander, radial_command)
	return TRUE

/datum/pet_command/proc/generate_emote_command(atom/target)
	var/mob/living/living_pet = locateUID(parent_uid)
	return isnull(living_pet) ? null : retrieve_command_text(living_pet, target)

/datum/pet_command/proc/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to spring into action!"

/// Target the pointed atom for actions
/datum/pet_command/proc/look_for_target(mob/living/friend, atom/potential_target)
	var/mob/living/parent = locateUID(parent_uid)
	if(!pet_able_to_respond())
		return FALSE
	if(parent.ai_controller.blackboard[BB_CURRENT_PET_TARGET] == potential_target) // That's already our target
		return FALSE
	if(!can_see(parent, potential_target, sense_radius))
		return FALSE

	parent.ai_controller.cancel_actions()
	set_command_target(parent, potential_target)
	return TRUE

/// Activate the command, extend to add visible messages and the like
/datum/pet_command/proc/set_command_active(mob/living/parent, mob/living/commander, radial_command = FALSE)
	parent.ai_controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)

	parent.ai_controller.cancel_actions() // Stop whatever you're doing and do this instead
	parent.ai_controller.set_blackboard_key(BB_ACTIVE_PET_COMMAND, src)
	if(command_feedback)
		parent.emote("me", EMOTE_VISIBLE, "[command_feedback]")
	if(!radial_command)
		return
	if(!requires_pointing)
		var/manual_emote_text = generate_emote_command()
		commander.emote("me", EMOTE_VISIBLE, manual_emote_text)
		return
	RegisterSignal(commander, COMSIG_MOB_CLICKON, PROC_REF(click_on_target))

/datum/pet_command/proc/click_on_target(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER // COMSIG_MOB_CLICKON
	if(!can_see(source, target, 9))
		return COMSIG_MOB_CANCEL_CLICKON
	var/manual_emote_text = generate_emote_command(target)
	if(on_target_set(source, target) && !isnull(manual_emote_text))
		INVOKE_ASYNC(source, TYPE_PROC_REF(/mob, custom_emote), EMOTE_VISIBLE, manual_emote_text)
	UnregisterSignal(source, COMSIG_MOB_CLICKON)
	return COMSIG_MOB_CANCEL_CLICKON

/datum/pet_command/proc/point_on_target(mob/living/friend, atom/potential_target)
	SIGNAL_HANDLER // COMSIG_MOVABLE_POINTED
	on_target_set(friend, potential_target)

/// Store the target for the AI blackboard
/datum/pet_command/proc/set_command_target(mob/living/parent, atom/target)
	parent.ai_controller.set_blackboard_key(BB_CURRENT_PET_TARGET, target)
	return TRUE

// TODO: Port /datum/pet_command/proc/provide_radial_data

/**
 * Execute an AI action on the provided controller, what we should actually do when this command is active.
 * This should basically always be called from a planning subtree which passes its own controller.
 * Return SUBTREE_RETURN_FINISH_PLANNING to pass that instruction on to the controller, or don't if you don't want that.
 */
/datum/pet_command/proc/execute_action(datum/ai_controller/controller)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Pet command execute action not implemented.")

/// Target the pointed atom for actions
/datum/pet_command/proc/on_target_set(mob/living/friend, atom/potential_target)
	var/mob/living/parent = locateUID(parent_uid)
	if(!parent)
		return FALSE

	parent.ai_controller.cancel_actions()
	if(!look_for_target(friend, potential_target) || !set_command_target(parent, potential_target))
		return FALSE
	var/suffix = pointed_reaction ? " [pointed_reaction]" : ""
	parent.visible_message("<span class='warning'>[parent] follows [friend]'s gesture towards [potential_target][suffix]!</span>")
	return TRUE
