/**
 * # The guardian element
 *
 * An element that is designed to be attached to guardian hosts, which gives them control over the communication, recalling, and the re-rolling of their guardians.
 * The element will only attach to living mobs.
 */
/datum/element/guardian
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// The mob who owns the guardian.
	var/mob/living/host
	/// The guardian.
	var/mob/living/simple_animal/hostile/guardian/guardian

/datum/element/guardian/Attach(datum/target, mob/living/simple_animal/hostile/guardian/_guardian)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	host = target
	guardian = _guardian

	RegisterSignal(host, COMSIG_GUARDIAN_RECALL, .proc/GuardianRecall)
	RegisterSignal(host, COMSIG_GUARDIAN_RESET, .proc/GuardianReroll)
	RegisterSignal(host, COMSIG_GUARDIAN_COMMUNICATION, .proc/Communicate)

/datum/element/guardian/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(host, COMSIG_GUARDIAN_RECALL)
	UnregisterSignal(host, COMSIG_GUARDIAN_RESET)
	UnregisterSignal(host, COMSIG_GUARDIAN_COMMUNICATION)

/**
 * Proc called after the user clicks their "Recall Guardian" verb in the guardian tab. Called via receiving the `COMSIG_GUARDIAN_RECALL` signal.
 *
 * Calls the `Recall()` proc on the `guardian`.
 *
 * Arguments:
 * * source - the `host` mob.
 */
/datum/element/guardian/proc/GuardianRecall(datum/source)
	guardian.Recall()

/**
 * Proc called after the user clicks their "Communicate" verb in the guardian tab. Called via receiving the `COMSIG_GUARDIAN_COMMUNICATION` signal.
 *
 * First, prompt the `host` to enter a message to send.
 * If the message exists and they didn't press cancel, show the message to the `host`, their `guardian`, and any dead players or observers. Also logs the communication.
 * If they pressed cancel, return.
 *
 * Arguemnts:
 * * source - the `host` mob.
 */
/datum/element/guardian/proc/Communicate(datum/source)
	// Prompt the `host` for their message.
	var/message = stripped_input(host, "Please enter a message to tell your guardian.", "Message", "")
	if(!message)
		return

	// Show the message to our guardian and to host. Log the message.
	to_chat(guardian, "<span class='changeling'><i>[host]:</i> [message]</span>")
	to_chat(host, "<span class='changeling'><i>[host]:</i> [message]</span>")
	log_say("(GUARDIAN to [key_name(guardian)]) [message]", host)
	host.create_log(SAY_LOG, "HOST to GUARDIAN: [message]", guardian)

	// Show the message to any ghosts/dead players.
	for(var/observer in GLOB.dead_mob_list)
		var/mob/dead/M = observer
		if(M && M.client && M.stat == DEAD && !isnewplayer(M))
			to_chat(M, "<span class='changeling'><i>Guardian Communication from <b>[host]</b> ([ghost_follow_link(host, ghost=M)]): [message]</i>")

/**
 * Proc called after the user clicks their "Reset Guardian Player (One Use)" verb in the guardian tab. Called via receiving the `COMSIG_GUARDIAN_RESET` signal.
 *
 * Removes the reset verb from the `host`, and attempts to poll ghosts for a replacement.
 * If a ghost is found, place them in control of the `guardian.`
 * If no ghost is found, display an error message and return. Create a callback which re-adds the verb in 5 minutes, so the `host` may try again.
 *
 * Arguemnts:
 * * source - the `host` mob.
 */
/datum/element/guardian/proc/GuardianReroll(datum/source)
	host.verbs -= /mob/living/proc/guardian_reset

	// Poll ghosts for a replacement.
	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [guardian.real_name]?", ROLE_GUARDIAN, 0, 100)
	var/mob/dead/observer/new_stand = null

	// No one accepted. Let them try again in 5 minutes.
	if(!length(candidates))
		to_chat(host, "<span class='userdanger'>There were no ghosts willing to replace your guardian. You can try again in 5 minutes.</span>")
		addtimer(CALLBACK(src, .proc/guardian_reset_callback), 5 MINUTES)
		return

	// Found a ghost. Put them into the guardian and ghost the current guardian player.
	new_stand = pick(candidates)
	to_chat(guardian, "<span class='userdanger'>Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance.</span>")
	to_chat(host, "<span class='boldnotice'>Your guardian has been successfully reset.</span>")
	message_admins("[key_name_admin(new_stand)] has taken control of ([key_name_admin(guardian)])")
	guardian.ghostize()
	guardian.key = new_stand.key

/**
 * Gives the `host` the `guardian_reset()` verb.
 */
/datum/element/guardian/proc/guardian_reset_callback()
	host.verbs |= /mob/living/proc/guardian_reset

/**
 * Gives the guardian host a verb to communicate with their guardian. Sends the `COMSIG_GUARDIAN_COMMUNICATION` signal.
 */
/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	SEND_SIGNAL(src, COMSIG_GUARDIAN_COMMUNICATION)

/**
 * Gives the guardian host a verb to recall their guardian. Sends the `COMSIG_GUARDIAN_RECALL` signal.
 */
/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	SEND_SIGNAL(src, COMSIG_GUARDIAN_RECALL)

/**
 * Gives the guardian host a verb to re-roll their guardian. Sends the `COMSIG_GUARDIAN_RESET` signal.
 */
/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player (One Use)"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian. One use."
	SEND_SIGNAL(src, COMSIG_GUARDIAN_RESET)
