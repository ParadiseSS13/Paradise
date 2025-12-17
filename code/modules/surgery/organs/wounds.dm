// Datumized wounds. Can be applied to either internal or external organs

/datum/wound
	/// What is this wound called
	var/name = ABSTRACT_TYPE_DESC
	/// Reference to the parent organ
	var/obj/item/organ/parent

/datum/wound/New(obj/item/organ/_parent)
	. = ..()
	if(!_parent) // So many things will runtime without a parent organ
		INVOKE_ASYNC(src, GLOBAL_PROC_REF(qdel), src)
		return
	parent = _parent
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(remove_and_destroy))

/datum/wound/Destroy(force, ...)
	. = ..()
	if(parent) // Someone directly deleted this
		parent.wound_list -= src
		parent = null

/datum/wound/proc/remove_and_destroy()
	parent.wound_list -= src
	parent = null
	qdel(src)

/// A proc that will do an effect from the wound
/datum/wound/proc/do_effect()
	return

/// The cure wounds proc. Just deletes the wound by default, but can be used to apply additional effects upon cure
/datum/wound/proc/cure_wound()
	SHOULD_CALL_PARENT(TRUE)
	remove_and_destroy()

// MARK: Fractures
/datum/wound/fracture
	name = "hairline fracture"

// One day these will be more than just renamed variants
/datum/wound/fracture/spiral
	name = "spiral fracture"

/datum/wound/fracture/transverse
	name = "transverse fracture"

/datum/wound/facture/linear
	name = "linear fracture"

// MARK: Ruptured lungs
/datum/wound/ruptured_lungs
	name = "ruptured lungs"

/datum/wound/ruptured_lungs/do_effect()
	if(prob(2) && !(NO_BLOOD in parent.owner.dna.species.species_traits))
		parent.owner.custom_emote(EMOTE_VISIBLE, "coughs up blood!")
		parent.owner.bleed(1)
	if(prob(4))
		parent.owner.custom_emote(EMOTE_VISIBLE, "gasps for air!")
		parent.owner.AdjustLoseBreath(10 SECONDS)
