// None of these are really complex enough to merit their own file

/**
 * # Pet Command: Idle
 * Tells a pet to resume its idle behaviour, usually staying put where you leave it
 */
/datum/pet_command/idle
	command_name = "Stay"
	command_desc = "Command your pet to stay idle in this location."
	speech_commands = list("sit", "stay", "stop")
	command_feedback = "sits."

/datum/pet_command/idle/execute_action(datum/ai_controller/controller)
	return SUBTREE_RETURN_FINISH_PLANNING // This cancels further AI planning

/datum/pet_command/idle/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to stay idle!"

/**
 * # Pet Command: Stop
 * Tells a pet to exit command mode and resume its normal behaviour, which includes regular target-seeking and what have you
 */
/datum/pet_command/free
	command_name = "Loose"
	command_desc = "Allow your pet to resume its natural behaviours."
	speech_commands = list("free", "loose")
	command_feedback = "relaxes."

/datum/pet_command/free/execute_action(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return // Just move on to the next planning subtree.

/datum/pet_command/free/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to go free!"

/**
 * # Pet Command: Follow
 * Tells a pet to follow you until you tell it to do something else
 */
/datum/pet_command/follow
	command_name = "Follow"
	command_desc = "Command your pet to accompany you."
	speech_commands = list("heel", "follow")
	///the behavior we use to follow
	var/follow_behavior = /datum/ai_behavior/pet_follow_friend
	/// should we activate immediately if we're doing nothing else and gain a friend?
	var/activate_on_befriend = FALSE

/datum/pet_command/follow/set_command_active(mob/living/parent, mob/living/commander)
	. = ..()
	set_command_target(parent, commander)

/datum/pet_command/follow/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to follow!"

/datum/pet_command/follow/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(follow_behavior, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/follow/add_new_friend(mob/living/tamer)
	. = ..()
	var/mob/living/parent = locateUID(parent_uid)
	if(!parent)
		return
	if(activate_on_befriend && !parent.ai_controller.blackboard_key_exists(BB_ACTIVE_PET_COMMAND))
		try_activate_command(tamer)

/// Like follow but start active
/datum/pet_command/follow/start_active
	activate_on_befriend = TRUE
/**
 * # Pet Command: Use ability
 * Use an an ability that does not require any targets
 */
/datum/pet_command/untargeted_ability
	///untargeted ability we will use
	var/ability_key

/datum/pet_command/untargeted_ability/execute_action(datum/ai_controller/controller)
	var/datum/action/ability = controller.blackboard[ability_key]
	if(!ability?.IsAvailable())
		return
	controller.queue_behavior(/datum/ai_behavior/use_mob_ability, ability_key)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/untargeted_ability/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to use an ability!"

/**
 * # Pet Command: Attack
 * Tells a pet to chase and bite the next thing you point at
 */
/datum/pet_command/attack
	command_name = "Attack"
	command_desc = "Command your pet to attack things that you point out to it."
	requires_pointing = TRUE
	speech_commands = list("attack", "sic", "kill")
	command_feedback = "growls."
	pointed_reaction = "and growls"
	/// Balloon alert to display if providing an invalid target
	var/refuse_reaction = "shakes head"
	/// Attack behaviour to use
	var/attack_behaviour = /datum/ai_behavior/basic_melee_attack

// Refuse to target things we can't target, chiefly other friends
/datum/pet_command/attack/set_command_target(mob/living/parent, atom/target)
	if(!target)
		return FALSE
	var/mob/living/living_parent = parent
	if(!living_parent.ai_controller)
		return FALSE
	var/datum/targeting_strategy/targeter = GET_TARGETING_STRATEGY(living_parent.ai_controller.blackboard[targeting_strategy_key])
	if(!targeter)
		return FALSE
	if(!targeter.can_attack(living_parent, target))
		refuse_target(parent, target)
		return FALSE
	return ..()

/datum/pet_command/attack/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "signals [living_pet] to attack [target]!"

/// Display feedback about not targeting something
/datum/pet_command/attack/proc/refuse_target(mob/living/parent, atom/target)
	var/mob/living/living_parent = parent
	living_parent.custom_emote(EMOTE_VISIBLE, refuse_reaction)
	living_parent.visible_message("<span class='notice'>[living_parent] refuses to attack [target].</span>")

/datum/pet_command/attack/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(attack_behaviour, BB_CURRENT_PET_TARGET, targeting_strategy_key)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/protect_owner
	command_name = "Protect owner"
	command_desc = "Your pet will run to your aid."
	hidden = TRUE
	/// The range our owner needs to be in for us to protect him
	var/protect_range = 9
	/// The behavior we will use when he is attacked
	var/protect_behavior = /datum/ai_behavior/basic_melee_attack
	/// Message cooldown to prevent too many people from telling you not to commit suicide
	COOLDOWN_DECLARE(self_harm_message_cooldown)
	/// Message cooldown to prevent spamming apologies
	COOLDOWN_DECLARE(friendly_fire_message_cooldown)

/datum/pet_command/protect_owner/add_new_friend(mob/living/tamer)
	RegisterSignal(tamer, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(set_attacking_target))
	if(!HAS_TRAIT(tamer, TRAIT_RELAYING_ATTACKER))
		tamer.AddElement(/datum/element/relay_attackers)

/datum/pet_command/protect_owner/remove_friend(mob/living/unfriended)
	UnregisterSignal(unfriended, COMSIG_ATOM_WAS_ATTACKED)

/datum/pet_command/protect_owner/execute_action(datum/ai_controller/controller)
	var/mob/living/victim = controller.blackboard[BB_CURRENT_PET_TARGET]
	if(QDELETED(victim))
		controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)
		return
	// cancel the action if they're below our given crit stat, OR if we're trying to attack ourselves (this can happen on tamed mobs w/ protect subtree rarely)
	if(victim.stat > controller.blackboard[BB_TARGET_MINIMUM_STAT] || victim == controller.pawn)
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return
	controller.queue_behavior(protect_behavior, BB_CURRENT_PET_TARGET, BB_PET_TARGETING_STRATEGY)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/protect_owner/set_command_active(mob/living/parent, mob/living/victim)
	. = ..()
	set_command_target(parent, victim)

/datum/pet_command/protect_owner/proc/set_attacking_target(atom/source, mob/living/attacker)
	SIGNAL_HANDLER // COMSIG_ATOM_WAS_ATTACKED

	var/mob/living/basic/owner = locateUID(parent_uid)
	if(isnull(owner))
		return

	// TODO: Be smarter about handling signals when our AI controller isn't active
	// This should definitely be handled somewhere higher up
	if(owner.ai_controller.ai_status != AI_STATUS_ON)
		return

	if(source == attacker)
		var/list/interventions = owner.ai_controller?.blackboard[BB_OWNER_SELF_HARM_RESPONSES] || list()
		if(length(interventions) && COOLDOWN_FINISHED(src, self_harm_message_cooldown) && prob(30))
			COOLDOWN_START(src, self_harm_message_cooldown, 5 SECONDS)
			var/chosen_statement = pick(interventions)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom, atom_say), chosen_statement)
		return
	if(owner == attacker)
		var/list/apologies = owner.ai_controller?.blackboard[BB_OWNER_FRIENDLY_FIRE_APOLOGIES] || list()
		if(length(apologies) && COOLDOWN_FINISHED(src, friendly_fire_message_cooldown))
			COOLDOWN_START(src, friendly_fire_message_cooldown, 5 SECONDS)
			var/chosen_statement = pick(apologies)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom, atom_say), chosen_statement)
		return

	var/mob/living/current_target = owner.ai_controller?.blackboard[BB_CURRENT_PET_TARGET]
	if(attacker == current_target) // we are already dealing with this target
		return
	if(isliving(attacker) && can_see(owner, attacker, protect_range))
		set_command_active(owner, attacker)

/datum/pet_command/move
	command_name = "Move"
	command_desc = "Command your pet to move to a location!"
	requires_pointing = TRUE
	speech_commands = list("move", "walk")
	/// the behavior we use to walk towards targets
	var/datum/ai_behavior/walk_behavior = /datum/ai_behavior/travel_towards

/datum/pet_command/move/set_command_target(mob/living/parent, atom/target)
	if(isnull(target) || !can_see(parent, target, 9))
		return FALSE
	return ..()

/datum/pet_command/move/execute_action(datum/ai_controller/controller)
	if(controller.blackboard_key_exists(BB_CURRENT_PET_TARGET))
		controller.queue_behavior(walk_behavior, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/move/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to move!"
