/**
* Gene Datum
*
* domutcheck was getting pretty hairy.  This is the solution.
*
* All genes are stored in a global variable to cut down on memory
* usage.
*
* @author N3X15 <nexisentertainment@gmail.com>
*/

/datum/dna/gene
	// Display name
	var/name = "BASE GENE"

	// Probably won't get used but why the fuck not
	var/desc="Oh god who knows what this does."

	// Set in initialize()!
	//  What gene activates this?
	var/block = 0

	// Any of a number of GENE_ flags.
	var/flags = 0

	// Chance of the gene to cause adverse effects when active
	var/instability = 0

/*
* Is the gene active in this mob's DNA?
*/
/datum/dna/gene/proc/is_active(mob/M)
	return M.active_genes && (type in M.active_genes)

// Return 1 if we can activate.
// HANDLE MUTCHK_FORCED HERE!
/datum/dna/gene/proc/can_activate(mob/M, flags)
	return FALSE

// Called when the gene activates.  Do your magic here.
/datum/dna/gene/proc/activate(mob/living/M, connected, flags)
	M.gene_stability -= instability

/**
* Called when the gene deactivates.  Undo your magic here.
* Only called when the block is deactivated.
*/
/datum/dna/gene/proc/deactivate(mob/living/M, connected, flags)
	M.gene_stability += instability

// This section inspired by goone's bioEffects.

/**
* Called in each life() tick.
*/
/datum/dna/gene/proc/OnMobLife(mob/M)
	return

/**
* Called when the mob dies
*/
/datum/dna/gene/proc/OnMobDeath(mob/M)
	return

/**
* Called when the mob says shit
*/
/datum/dna/gene/proc/OnSay(mob/M, message)
	return message

/**
* Called after the mob runs update_icons.
*
* @params M The subject.
* @params g Gender (m or f)
*/
/datum/dna/gene/proc/OnDrawUnderlays(mob/M, g)
	return FALSE


/////////////////////
// BASIC GENES
//
// These just chuck in a mutation and display a message.
//
// Gene is activated:
//  1. If mutation already exists in mob
//  2. If the probability roll succeeds
//  3. Activation is forced (done in domutcheck)
/////////////////////


/datum/dna/gene/basic
	name = "BASIC GENE"

	// Mutation to give
	var/mutation = 0

	// Activation probability
	var/activation_prob = 100

	// Possible activation messages
	var/list/activation_messages = list()

	// Possible deactivation messages
	var/list/deactivation_messages = list()

/datum/dna/gene/basic/can_activate(mob/M, flags)
	if(flags & MUTCHK_FORCED)
		return TRUE
	// Probability check
	return prob(activation_prob)

/datum/dna/gene/basic/activate(mob/M, connected, flags)
	..()
	M.mutations.Add(mutation)
	if(activation_messages.len)
		var/msg = pick(activation_messages)
		to_chat(M, "<span class='notice'>[msg]</span>")

/datum/dna/gene/basic/deactivate(mob/living/M, connected, flags)
	..()
	M.mutations.Remove(mutation)
	if(deactivation_messages.len)
		var/msg = pick(deactivation_messages)
		to_chat(M, "<span class='warning'>[msg]</span>")
