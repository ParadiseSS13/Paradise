

/datum/action/changeling
	name = "Prototype Sting"
	desc = "" // Fluff
	background_icon_state = "bg_changeling"
	/// A reference to the changeling's changeling antag datum.
	var/datum/antagonist/changeling/cling
	/// Datum path used to determine the location and name of the power in changeling evolution menu UI
	var/datum/changeling_power_category/category
	/// Determines whether the power is always given to the changeling or if it must be purchased.
	var/power_type = CHANGELING_UNOBTAINABLE_POWER
	/// A description of what the power does.
	var/helptext = ""
	/// Chemical cost to use this power.
	var/chemical_cost = 0
	/// The cost of purchasing the power.
	var/dna_cost = 0
	/// The amount of victims the changeling needs to absorb before they can use this power. Changelings always start with a value of 1.
	var/req_dna = 0
	/// If you need to be in human form to activate this power.
	var/req_human = FALSE
	/// What `stat` value the changeling needs to have to use this power. Will be CONSCIOUS, UNCONSCIOUS or DEAD.
	var/req_stat = CONSCIOUS
	/// If this power is active or not. Used for toggleable abilities.
	var/active = FALSE
	/// If this power can be used while the changeling has the `TRAIT_FAKEDEATH` trait.
	var/bypass_fake_death = FALSE

/*
 * Changeling code relies on on_purchase to grant powers.
 * The same goes for Remove(). if you override Remove(), call parent or else your power wont be removed on respec
 */
/datum/action/changeling/proc/on_purchase(mob/user, datum/antagonist/changeling/C)
	SHOULD_CALL_PARENT(TRUE)
	if(!user || !user.mind || !C)
		qdel(src)
		return
	cling = C
	Grant(user)
	return TRUE

/datum/action/changeling/Destroy(force, ...)
	cling.acquired_powers -= src
	cling = null
	return ..()

/datum/action/changeling/Trigger(left_click)
	try_to_sting(owner)

/datum/action/changeling/proc/try_to_sting(mob/user, mob/target)
	. = TRUE // Value doesn't appear to matter here, but it matters for the middle-click override in AltClickOn inside click.dm
	user.changeNext_click(5)
	if(!can_sting(user, target))
		return
	if(sting_action(user, target))
		sting_feedback(user, target)
		take_chemical_cost()

/datum/action/changeling/proc/sting_action(mob/user, mob/target)
	return FALSE

/datum/action/changeling/proc/sting_feedback(mob/user, mob/target)
	return FALSE

/datum/action/changeling/proc/take_chemical_cost()
	cling.chem_charges -= chemical_cost
	cling.update_chem_charges_ui()

/datum/action/changeling/proc/can_sting(mob/user, mob/target)
	SHOULD_CALL_PARENT(TRUE)
	if(req_human && (!ishuman(user) || issmall(user)))
		to_chat(user, "<span class='warning'>We cannot do that in this form!</span>")
		return FALSE
	if(cling.chem_charges < chemical_cost)
		to_chat(user, "<span class='warning'>We require at least [chemical_cost] unit\s of chemicals to do that!</span>")
		return FALSE
	if(cling.absorbed_count < req_dna)
		to_chat(user, "<span class='warning'>We require at least [req_dna] sample\s of compatible DNA.</span>")
		return FALSE
	if(req_stat < user.stat)
		to_chat(user, "<span class='warning'>We are incapacitated.</span>")
		return FALSE
	if(HAS_TRAIT(user, TRAIT_FAKEDEATH) && !bypass_fake_death)
		to_chat(user, "<span class='warning'>We are incapacitated.</span>")
		return FALSE
	return TRUE

// Transform the target to the chosen dna. Used in transform.dm and tiny_prick.dm (handy for changes since it's the same thing done twice)
/datum/action/changeling/proc/transform_dna(mob/living/carbon/human/H, datum/dna/D)
	var/internals_on = H.internal
	if(!D)
		return
	var/changes_species = TRUE
	if(H.dna.species.name == D.species.name)
		changes_species = FALSE
	H.change_dna(D, changes_species)
	if(internals_on)
		H.internal = internals_on
