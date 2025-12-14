GENERAL_PROTECT_DATUM(/datum/user_verb)

/**
 * This is the user verb datum. It is used to store the verb's information and handle the verb's functionality.
 * All of this is setup for you, and you should not be defining this manually.
 * That means you reader.
 */
/datum/user_verb
	var/name //! The name of the verb.
	var/description //! The description of the verb.
	var/category //! The category of the verb.
	var/permissions //! The permissions required to use the verb.
	var/visibility_flag //! The flag that determines if the verb is visible.
	VAR_PROTECTED/verb_path //! The path to the verb proc.

/datum/user_verb/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	return ..()

/// Assigns the verb to the user.
/datum/user_verb/proc/assign_to_client(client/user)
	add_verb(user, verb_path)

/// Unassigns the verb from the user.
/datum/user_verb/proc/unassign_from_client(client/user)
	remove_verb(user, verb_path)
