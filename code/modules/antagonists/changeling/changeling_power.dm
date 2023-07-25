/// List of all items changeling can get through his powers. Update if needed.
GLOBAL_LIST_INIT(changeling_mutations, list(
	/obj/item/melee/arm_blade,
	/obj/item/gun/magic/tentacle,
	/obj/item/shield/changeling,
	/obj/item/clothing/suit/space/changeling,
	/obj/item/clothing/head/helmet/space/changeling,
	/obj/item/clothing/suit/armor/changeling,
	/obj/item/clothing/head/helmet/changeling,
	/obj/item/organ/internal/cyberimp/eyes/shield/ling,
	/obj/item/organ/internal/cyberimp/eyes/thermals/ling

))

/datum/action/changeling
	name = "Prototype Sting"
	desc = "" // Fluff
	background_icon_state = "bg_changeling"
	/// A description of what the power does.
	var/helptext = ""
	/// A reference to the changeling's changeling antag datum.
	var/datum/antagonist/changeling/cling
	/// Determines whether the power is always given to the changeling or if it must be purchased.
	var/power_type = CHANGELING_UNOBTAINABLE_POWER
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
	/// Genetic damage caused by using the sting. Nothing to do with cloneloss.
	var/genetic_damage = 0
	/// Hard counter for spamming abilities.
	var/max_genetic_damage = 100
	// For passive abilities like hivemind that dont need a button
	//var/needs_button = TRUE
	/// If this power is active or not. Used for toggleable abilities.
	var/active = FALSE
	/// If this power can be used while the changeling has the `TRAIT_FAKE_DEATH` trait.
	var/bypass_fake_death = FALSE


/**
 * Changeling code relies on on_purchase to grant powers.
 * The same goes for Remove(). if you override Remove(), call parent or else your power wont be removed on respec
 */
/datum/action/changeling/proc/on_purchase(mob/user, datum/antagonist/changeling/antag)
	SHOULD_CALL_PARENT(TRUE)
	if(!user || !user.mind || !antag)
		qdel(src)
		return FALSE

	cling = antag
	Grant(user)
	return TRUE


/datum/action/changeling/Remove(mob/user)
	user?.update_action_buttons(TRUE)
	..()


/datum/action/changeling/Destroy(force, ...)
	owner?.update_action_buttons(TRUE)
	cling.acquired_powers -= src
	cling = null
	return ..()


/datum/action/changeling/Trigger()
	try_to_sting(owner)


/datum/action/changeling/proc/try_to_sting(mob/user, mob/target)
	user.changeNext_click(5)
	if(!can_sting(user, target))
		return

	if(sting_action(user, target))
		sting_feedback(user, target)
		take_chemical_cost()


/datum/action/changeling/proc/sting_action(mob/user)
	return FALSE


/datum/action/changeling/proc/sting_feedback(mob/user, mob/target)
	return FALSE


/datum/action/changeling/proc/take_chemical_cost()
	cling.chem_charges -= chemical_cost
	cling.genetic_damage += genetic_damage


/**
 * Fairly important to remember to return `TRUE` on success >.<
 */
/datum/action/changeling/proc/can_sting(mob/user, mob/target)
	SHOULD_CALL_PARENT(TRUE)

	if(req_human && (!ishuman(user) || issmall(user)))
		to_chat(user, span_warning("We cannot do that in this form!"))
		return FALSE

	if(cling.chem_charges < chemical_cost)
		to_chat(user, span_warning("We require at least [chemical_cost] unit\s of chemicals to do that!"))
		return FALSE

	if(cling.absorbed_count < req_dna)
		to_chat(user, span_warning("We require at least [req_dna] sample\s of compatible DNA."))
		return FALSE

	if(req_stat < user.stat)
		to_chat(user, span_warning("We are incapacitated."))
		return FALSE

	if(cling.genetic_damage > max_genetic_damage)
		to_chat(user, span_warning("Our genomes are still reassembling. We need time to recover first."))
		return FALSE

	if(HAS_TRAIT(user, TRAIT_FAKEDEATH) && !bypass_fake_death)
		to_chat(user, span_warning("We are incapacitated."))
		return FALSE

	return TRUE


/**
 * Transform the target to the chosen dna. Used in transform.dm and tiny_prick.dm (handy for changes since it's the same thing done twice)
 */
/datum/action/changeling/proc/transform_dna(mob/living/carbon/human/user, datum/dna/DNA)
	if(!DNA)
		return

	var/changes_species = TRUE
	if(user.dna.species.name == DNA.species.name)
		changes_species = FALSE

	user.change_dna(DNA, changes_species)

