/datum/mutation
	/// Display name
	var/name = "mutation"
	/// Description of the gene
	var/desc = "A mutation."
	///  What gene activates this? Set in initialize()!
	var/block = 0
	/// Chance of the gene to cause adverse effects when active
	var/instability = 0
	/// Trait to give, if any
	var/traits_to_add = list()
	/// Activation probability
	var/activation_prob = 100
	/// Possible activation messages
	var/list/activation_messages = list()
	/// Possible deactivation messages
	var/list/deactivation_messages = list()


// Is the gene active in this mob's DNA?
/datum/mutation/proc/is_active(mob/M)
	return M.active_mutations && (type in M.active_mutations)

// Return TRUE if we can activate.
// HANDLE MUTCHK_FORCED HERE!
/datum/mutation/proc/can_activate(mob/M, flags)
	if(flags & MUTCHK_FORCED)
		return TRUE
	// Probability check
	return prob(activation_prob)

// Called when the gene activates.  Do your magic here.
/datum/mutation/proc/activate(mob/living/M)
	SHOULD_CALL_PARENT(TRUE)
	M.gene_stability -= instability
	M.active_mutations |= type // |= is probably not required but just in case
	for(var/thing in traits_to_add)
		ADD_TRAIT(M, thing, GENETIC_MUTATION)
	if(length(activation_messages))
		var/msg = pick(activation_messages)
		to_chat(M, "<span class='notice'>[msg]</span>")


// Called when the gene deactivates.  Undo your magic here.
// Only called when the block is deactivated.
/datum/mutation/proc/deactivate(mob/living/M)
	SHOULD_CALL_PARENT(TRUE)
	M.gene_stability += instability
	M.active_mutations -= type
	for(var/thing in traits_to_add)
		REMOVE_TRAIT(M, thing, GENETIC_MUTATION)
	if(length(deactivation_messages))
		var/msg = pick(deactivation_messages)
		to_chat(M, "<span class='warning'>[msg]</span>")

// This section inspired by goone's bioEffects.


// Called in each life() tick.
/datum/mutation/proc/on_life(mob/M)
	return


// Called when the mob dies
/datum/mutation/proc/on_death(mob/M)
	return


// Called when the mob says shit
/datum/mutation/proc/on_say(mob/M, message)
	return message


// Called after the mob runs update_icons.
// @params M The subject.
// @params g Gender (m or f)
/datum/mutation/proc/on_draw_underlays(mob/M, g)
	return FALSE
