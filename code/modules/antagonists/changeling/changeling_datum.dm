/// Time before changeling can revive himself.
#define LING_FAKEDEATH_TIME					60 SECONDS
/// The lowest value of genetic_damage [/datum/antagonist/changeling/process()] can take it to while dead.
#define LING_DEAD_GENETIC_DAMAGE_HEAL_CAP	50
/// The amount of recent spoken lines to gain on absorbing a mob
#define LING_ABSORB_RECENT_SPEECH			8
/// Denotes that this power is free and should be given to all changelings by default.
#define CHANGELING_INNATE_POWER			"changeling_innate_power"
/// Denotes that this power can only be obtained by purchasing it.
#define CHANGELING_PURCHASABLE_POWER	"changeling_purchasable_power"
/// Denotes that this power can not be obtained normally. Primarily used for base types such as [/datum/action/changeling/weapon].
#define CHANGELING_UNOBTAINABLE_POWER	"changeling_unobtainable_power"

/// Changeling aliases.
GLOBAL_LIST_INIT(possible_changeling_IDs, list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega"))

/datum/antagonist/changeling
	name = "Changeling"
	roundend_category = "changelings"
	job_rank = ROLE_CHANGELING
	special_role = SPECIAL_ROLE_CHANGELING
	antag_hud_name = "hudchangeling"
	antag_hud_type = ANTAG_HUD_CHANGELING
	clown_gain_text = "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself."
	clown_removal_text = "As your changeling nature fades, you return to your own clumsy, clownish self."
	/// List of [/datum/dna] which have been absorbed through the DNA sting or absorb power.
	var/list/absorbed_dna
	/// DNA that is not lost when capacity is otherwise full.
	var/list/protected_dna
	/// List of [/datum/language] UIDs, learned from absorbed victims.
	var/list/absorbed_languages
	/// A list of instanced [/datum/action/changeling] the changeling has aquired.
	var/list/acquired_powers
	/// A list of [/datum/action/changeling] typepaths with a `power_type` of `CHANGELING_INNATE_POWER`.
	var/static/list/innate_powers
	/// A list of [/datum/action/changeling] typepaths with a `power_type` of `CHANGELING_PURCHASABLE_POWER`.
	var/static/list/purchaseable_powers
	/// How many total DNA strands the changeling can store for transformation.
	var/dna_max = 5
	/// Number of victims the changeling has absorbed.
	var/absorbed_count = 1
	/// The current amount of chemicals the changeling has stored.
	var/chem_charges = 20
	/// The amount of chemicals that recharges per `Life()` call.
	var/chem_recharge_rate = 1
	/// Amount of chemical recharge slowdown, calculated as `chem_recharge_rate - chem_recharge_slowdown`
	var/chem_recharge_slowdown = 0
	/// The total amount of chemicals able to be stored.
	var/chem_storage = 75
	/// The range of changeling stings.
	var/sting_range = 2
	/// The changeling's identifier when speaking in the hivemind, i.e. "Mr. Delta 123".
	var/changelingID = "Changeling"
	/// The current amount of genetic damage incurred from power use.
	var/genetic_damage = 0
	/// This variable is applied to default [LING_FAKEDEATH_TIME]
	var/fakedeath_delay = 0 SECONDS
	/// If the changeling is in the process of absorbing someone.
	var/is_absorbing = FALSE
	/// If the changeling is in the process of linking with someone.
	var/is_linking = FALSE
	/// The amount of points available to purchase changeling abilities.
	var/genetic_points = 10
	/// If the changeling can respec their purchased abilities.
	var/can_respec = FALSE
	/// Currently chosen DNA
	var/datum/dna/chosen_dna
	/// The current sting power the changeling has active.
	var/datum/action/changeling/sting/chosen_sting
	/// If the changeling is in the process of regenerating from their fake death.
	var/regenerating = FALSE
	/// A name that will display in place of the changeling's real name when speaking.
	var/mimicking = ""
	/// TTS seed used in mimic voice ability.
	var/tts_mimicking = ""


/datum/antagonist/changeling/New()
	..()
	if(!length(innate_powers))
		innate_powers = get_powers_of_type(CHANGELING_INNATE_POWER)
	if(!length(purchaseable_powers))
		purchaseable_powers = get_powers_of_type(CHANGELING_PURCHASABLE_POWER)


/datum/antagonist/changeling/on_gain()
	SSticker.mode.changelings |= owner
	var/honorific = owner.current.gender == FEMALE ? "Ms." : "Mr."
	if(length(GLOB.possible_changeling_IDs))
		changelingID = pick(GLOB.possible_changeling_IDs)
		GLOB.possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"

	absorbed_dna = list()
	protected_dna = list()
	acquired_powers = list()
	absorbed_languages = list()

	store_dna(owner.current.dna.Clone())

	..()


/datum/antagonist/changeling/Destroy()
	SSticker.mode.changelings -= owner
	chosen_sting = null
	QDEL_LIST(acquired_powers)
	STOP_PROCESSING(SSobj, src)
	return ..()


/datum/antagonist/changeling/greet()
	..()
	SEND_SOUND(owner.current, 'sound/ambience/antag/ling_aler.ogg')
	//to_chat(owner.current, span_changeling("Remember: you get all of the absorbed DNA points from other changelings if you absorb them."))


/datum/antagonist/changeling/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("You have been robotized!"))
		to_chat(owner.current, span_danger("You must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead."))
	else
		to_chat(owner.current, "<FONT color='red' size = 3><B>You lose your powers! You are no longer a changeling and are stuck in your current form!</B></FONT>")


/datum/antagonist/changeling/apply_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()

	if(ishuman(user))
		START_PROCESSING(SSobj, src)

	add_new_languages(user.languages) // Absorb the languages of the new body.
	update_languages() // But also, give the changeling the languages they've already absorbed before this.

	// If there's a mob_override, this is a body transfer, and therefore we should give them back their powers they had while in the old body.
	if(mob_override)
		for(var/datum/action/changeling/power in acquired_powers)
			power.Grant(user)

	// Else, this is their first time gaining the datum, or they're transfering from a headslug into a monkey.
	else
		for(var/power_type in innate_powers)
			give_power(new power_type, user)

	RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(on_death))

	var/mob/living/carbon/carbon_user = user
	if(!istype(carbon_user))
		return

	// Brains are optional for changelings.
	var/obj/item/organ/internal/brain/ling_brain = carbon_user.get_organ_slot("brain")
	ling_brain?.decoy_brain = TRUE


/datum/antagonist/changeling/remove_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()

	if(!ishuman(user))
		STOP_PROCESSING(SSobj, src) // This is to handle when they transfer into a headslug (simple animal). We shouldn't process in that case.

	if(user.hud_used?.lingstingdisplay)
		user.hud_used.lingstingdisplay.invisibility = INVISIBILITY_ABSTRACT
		user.hud_used.lingchemdisplay.invisibility = INVISIBILITY_ABSTRACT

	remove_changeling_mutations(user)
	remove_unnatural_languages(user)
	UnregisterSignal(user, COMSIG_MOB_DEATH)

	// If there's a mob_override, this is a body transfer, and therefore we should only remove their powers from the old body.
	if(mob_override)
		for(var/datum/action/changeling/power in acquired_powers)
			power.Remove(user)
	// Else, they're losing the datum, or transferring into a headslug. Fully remove and delete all powers.
	else
		respec(FALSE, FALSE)

	var/mob/living/carbon/carbon_user = user
	if(!istype(carbon_user))
		return

	// If they get de-clinged, make sure they can't just chop their own head off for the hell of it
	var/obj/item/organ/internal/brain/former_ling_brain = carbon_user.get_organ_slot("brain")
	if(former_ling_brain && former_ling_brain.decoy_brain != initial(former_ling_brain.decoy_brain))
		former_ling_brain.decoy_brain = FALSE


/**
 * OBJECTIVES - Always absorb 5 genomes, plus random traitor objectives.
 * If they have two objectives as well as absorb, they must survive rather than escape.
 * No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting.
 * If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone.
 */
/datum/antagonist/changeling/give_objectives()
	var/datum/objective/absorb/absorb = new
	absorb.gen_amount_goal(6, 8)
	absorb.owner = owner
	objectives += absorb

	if(prob(60))
		add_objective(/datum/objective/steal)
	else
		add_objective(/datum/objective/debrain)

	var/list/active_ais = active_ais()
	if(length(active_ais) && prob(4)) // Leaving this at a flat chance for now, problems with the num_players() proc due to latejoin antags.
		add_objective(/datum/objective/destroy)
	else
		var/datum/objective/maroon/maroon_objective = add_objective(/datum/objective/maroon)
		var/mob/living/carbon/human/maroon_target = maroon_objective.target?.current

		if(!(locate(/datum/objective/escape) in owner.get_all_objectives()) && maroon_target && !has_no_DNA(maroon_target))
			var/datum/objective/escape/escape_with_identity/identity_theft = new(special_objective = maroon_objective)
			identity_theft.owner = owner
			objectives += identity_theft

	if(!(locate(/datum/objective/escape) in owner.get_all_objectives()))
		if(prob(70))
			add_objective(/datum/objective/escape)
		else
			add_objective(/datum/objective/escape/escape_with_identity) // If our kill target has no genes, 30% time pick someone else to steal the identity of


/datum/antagonist/changeling/process()
	if(!owner || !owner.current)
		return PROCESS_KILL

	var/mob/living/carbon/human/h_owner = owner.current
	if(h_owner.hud_used?.lingchemdisplay)
		h_owner.hud_used.lingchemdisplay.invisibility = 0
		h_owner.hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color='#dd66dd'>[round(chem_charges)]</font></div>"

	if(h_owner.stat == DEAD)
		chem_charges = clamp(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown, chem_storage * 0.5)
		genetic_damage = directional_bounded_sum(genetic_damage, -1, LING_DEAD_GENETIC_DAMAGE_HEAL_CAP, 0)

	else // Not dead? no chem/genetic_damage caps.
		chem_charges = clamp(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown, chem_storage)
		genetic_damage = max(0, genetic_damage - 1)


/**
 * Respec the changeling's powers after first checking if they're able to respec.
 */
/datum/antagonist/changeling/proc/try_respec()
	var/mob/living/carbon/human/user = owner.current
	if(!istype(user) || issmall(user))
		to_chat(user, span_danger("We can't readapt our evolutions in this form!"))
		return FALSE
	if(can_respec)
		to_chat(user, span_changeling("We have removed our evolutions from this form, and are now ready to readapt."))
		remove_changeling_mutations(user)
		respec()
		can_respec = FALSE
		return TRUE
	else
		to_chat(user, span_danger("You lack the power to readapt your evolutions!"))
		return FALSE


/**
 * Resets a changeling to the point they were when they first became a changeling, i.e no genetic points to spend, no non-innate powers, etc.
 */
/datum/antagonist/changeling/proc/respec(keep_innate_powers = TRUE, reset_genetic_points = TRUE)
	remove_changeling_powers(keep_innate_powers)
	chosen_sting = null
	if(reset_genetic_points)
		genetic_points = initial(genetic_points)
	sting_range = initial(sting_range)
	chem_storage = initial(chem_storage)
	chem_recharge_rate = initial(chem_recharge_rate)
	chem_charges = min(chem_charges, chem_storage)
	chem_recharge_slowdown = initial(chem_recharge_slowdown)
	genetic_damage = initial(genetic_damage)
	mimicking = ""
	tts_mimicking = ""


/**
 * Removes a changeling's abilities.
 *
 * Arguments:
 * * keep_innate_powers - set to TRUE if changeling actions with a `power_type` of `CHANGELING_INNATE_POWER` should be kept.
 */
/datum/antagonist/changeling/proc/remove_changeling_powers(keep_innate_powers = FALSE)
	for(var/datum/action/changeling/power in acquired_powers)
		if(keep_innate_powers && (power.power_type == CHANGELING_INNATE_POWER))
			continue
		acquired_powers -= power
		qdel(power)

	if(owner?.current)
		owner.current.update_action_buttons(TRUE)


/**
 * Gets a list of changeling action typepaths based on the passed in `power_type`.
 *
 * Arguments:
 * * power_type - should be a define related to [/datum/action/changeling/var/power_type].
 */
/datum/antagonist/changeling/proc/get_powers_of_type(power_type)
	var/list/powers = list()
	for(var/power_path in subtypesof(/datum/action/changeling))
		var/datum/action/changeling/power = power_path
		if(initial(power.power_type) != power_type)
			continue
		powers += power_path
	return powers


/**
 * Gives the changeling the passed in `power`. Subtracts the cost of the power from our genetic points.
 *
 * Arugments:
 * * datum/action/changeling/power - the power to give to the changeling.
 * * mob/living/changeling - the changeling who owns this datum. Optional argument.
 * * take_cost - if we should spend genetic points when giving the power
 */
/datum/antagonist/changeling/proc/give_power(datum/action/changeling/power, mob/living/changeling, take_cost = TRUE)
	if(take_cost)
		genetic_points -= power.dna_cost
	acquired_powers += power
	power.on_purchase(changeling || owner.current, src)


/**
 * Store the languages from the `new_languages` list into the `absorbed_languages` list. Teaches the changeling the new languages.
 *
 * Arguments:
 * * list/new_languages - a list of [/datum/language] to be added
 */
/datum/antagonist/changeling/proc/add_new_languages(list/new_languages)
	for(var/datum/language/language in new_languages)
		if(is_type_in_UID_list(language, absorbed_languages))
			continue
		owner.current.add_language("[language.name]")
		absorbed_languages += language.UID()


/**
 * Teach the changeling every language in the `absorbed_language` list. Already known languages will be ignored.
 */
/datum/antagonist/changeling/proc/update_languages()
	for(var/lang_UID in absorbed_languages)
		var/datum/language/lang = locateUID(lang_UID)
		owner.current.add_language("[lang.name]")


/**
 * Removes all the languages the mob `user` has absorbed throughout their life as a changeling and should no longer have.
 *
 * Ignores languages the player has chosen from character creation, and species languages from the changeling mob's current species.
 *
 * Arguments:
 * * mob/living/user - the changeling mob to remove languages from
 */
/datum/antagonist/changeling/proc/remove_unnatural_languages(mob/living/user)
	var/list/ignored_languages = list()

	// Check if user is actually that player's character or just someone they transformed into.
	if(user.client?.prefs.real_name == user.real_name)
		ignored_languages += user.client.prefs.language

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		ignored_languages += human_user.dna.species.default_language
		ignored_languages += human_user.dna.species.language
		ignored_languages += human_user.dna.species.secondary_langs

	for(var/lang_UID in absorbed_languages)
		var/datum/language/lang = locateUID(lang_UID)
		if(lang.name in ignored_languages)
			continue
		user.remove_language("[lang.name]")


/**
 * Absorb the the target's DNA and their languages.
 *
 * Arguments:
 * * mob/living/carbon/user - the mob to absorb DNA from
 */
/datum/antagonist/changeling/proc/absorb_dna(mob/living/carbon/user)
	user.dna.real_name = user.real_name // Set this again, just to be sure that it's properly set.
	store_dna(user.dna.Clone())
	add_new_languages(user.languages)
	absorbed_count++


/**
 * Store the target DNA. If the DNA belongs to one of the changeling's "escape with identity" objectives, make the DNA protected.
 *
 * Arguments:
 * * datum/dna/new_dna - the DNA to store
 */
/datum/antagonist/changeling/proc/store_dna(datum/dna/new_dna)
	for(var/datum/objective/escape/escape_with_identity/objective in objectives)
		if(objective.target_real_name == new_dna.real_name)
			protected_dna |= new_dna
			return

	absorbed_dna |= new_dna
	trim_dna()


/**
 * Prompt the changeling with a list of names associated with their stored DNA. Return a [/datum/dna] based on the name chosen.
 *
 * Arguments:
 * * message - the message of the `input()` window
 * * title - the title of the `input()` window
 * * not_in_bank - if we should filter out DNA that's already in the hivemind bank
 */
/datum/antagonist/changeling/proc/select_dna(message, title, not_in_bank = FALSE)
	var/list/names = list()
	for(var/datum/dna/DNA in (absorbed_dna + protected_dna))
		if(not_in_bank && (DNA in GLOB.hivemind_bank))
			continue
		names[DNA.real_name] = DNA

	var/chosen_name = input(message, title, null) as null|anything in names
	if(!chosen_name)
		return

	return names[chosen_name]


/**
 * Gets a [/datum/dna] that matches the passed in `tDNA`. Also used as a check to see if the changeling has this DNA already stored.
 *
 * Arguments:
 * * datum/dna/tDNA - a reference to a DNA datum that we want to find
 */
/datum/antagonist/changeling/proc/get_dna(datum/dna/tDNA)
	for(var/datum/dna/DNA in (absorbed_dna + protected_dna))
		if(tDNA.unique_enzymes == DNA.unique_enzymes && tDNA.uni_identity == DNA.uni_identity && tDNA.species.type == DNA.species.type)
			return DNA


/**
 * Determines if the changeling's current DNA is stale.
 */
/datum/antagonist/changeling/proc/using_stale_dna()
	var/datum/dna/current_dna = get_dna(owner.current.dna)
	if(length(absorbed_dna) < dna_max)
		return FALSE // Still more room for DNA.

	if(!current_dna || !(current_dna in absorbed_dna))
		return TRUE // Oops, our current DNA was somehow not absorbed; force a transformation.

	if(absorbed_dna[1] == current_dna)
		return TRUE // The oldest DNA is the current DNA, which means it's "stale".

	return FALSE


/**
 * Clears the most "stale" DNA from the `absorbed_dna` list.
 */
/datum/antagonist/changeling/proc/trim_dna()
	listclearnulls(absorbed_dna)
	if(length(absorbed_dna) > dna_max)
		absorbed_dna.Cut(1, 2)


/**
 * Returns TRUE if the changeling can absorb the target mob's DNA.
 *
 * Arguments:
 * * mob/living/carbon/target - the mob's DNA we're trying to absorb
 */
/datum/antagonist/changeling/proc/can_absorb_dna(mob/living/carbon/target)
	var/mob/living/carbon/user = owner.current
	if(using_stale_dna())	//If our current DNA is the stalest, we gotta ditch it.
		to_chat(user, span_warning("The DNA we are wearing is stale. Transform and try again."))
		return FALSE

	if(!target || !target.dna)
		to_chat(user, span_warning("This creature does not have any DNA."))
		return FALSE

	var/mob/living/carbon/human/human_target = target
	if(!istype(human_target) || issmall(human_target))
		to_chat(user, span_warning("[human_target] is not compatible with our biology."))
		return FALSE

	if((NOCLONE || SKELETON || HUSK) in human_target.mutations)
		to_chat(user, span_warning("DNA of [target] is ruined beyond usability!"))
		return FALSE

	if(has_no_DNA(human_target))
		to_chat(user, span_warning("This creature does not have DNA!"))
		return FALSE

	if(get_dna(target.dna))
		to_chat(user, span_warning("We already have this DNA in storage!"))
		return FALSE

	return TRUE


/**
 * Takes path or action datum and checks if it presents on changeling powers.
 */
/datum/antagonist/changeling/proc/has_sting(datum/action/changeling/path_or_datum)
	if(!path_or_datum)
		return FALSE

	if(!ispath(path_or_datum) && (path_or_datum in acquired_powers))
		return TRUE

	for(var/datum/action/changeling/check in acquired_powers)
		if(istype(check, path_or_datum))
			return TRUE

	return FALSE


/datum/antagonist/changeling/proc/on_death(mob/living/user, gibbed)
	SIGNAL_HANDLER
	if(QDELETED(user) || gibbed)  // they were probably incinerated or gibbed, no coming back from that.
		return

	var/mob/living/carbon/human/h_user = user
	if(!istype(h_user))
		return

	addtimer(CALLBACK(src, PROC_REF(calculate_stasis_delay), user), 0)	// We need this timer to register missing head

	if(!h_user.get_organ_slot("brain"))
		to_chat(user, span_changeling("The brain is a useless organ to us, we are able to regenerate!"))
	else
		to_chat(user, span_changeling("While our current form may be lifeless, this is not the end for us as we can still regenerate!"))


/**
 * Additional stasis delay from different sources.
 */
/datum/antagonist/changeling/proc/calculate_stasis_delay(mob/living/user)

	if(QDELETED(src) || QDELETED(user) || !istype(user))
		return

	// 1 SECOND for each point of genetic damage.
	fakedeath_delay = genetic_damage * 1 SECONDS

	// 20 SECONDS delay if cling was on fire while dying and 2 SECONDS for each fire stack.
	// 60 SECONDS of delay overall.
	if(user.on_fire)
		fakedeath_delay += 20 SECONDS
		fakedeath_delay += round(user.fire_stacks) * 2 SECONDS

	if(!ishuman(user))
		return

	// 12 SECONDS for each missing major limb: head, any arm (not hand), any leg (not foot).
	// 60 SECONDS of delay overall.
	var/mob/living/carbon/human/h_user = user
	var/missing_limbs = 5
	for(var/obj/item/organ/external/limb in h_user.bodyparts)
		if(istype(limb, /obj/item/organ/external/head) || \
			istype(limb, /obj/item/organ/external/arm) || \
			istype(limb, /obj/item/organ/external/leg))

			missing_limbs--

	fakedeath_delay += missing_limbs * 12 SECONDS


/**
 * Removes all mutated items on owner: armblade, tentacle, chitin suit etc.
 * Global proc since we might need to delete mutated parts on any user.
 */
/proc/remove_changeling_mutations(mob/living/carbon/human/user)

	if(!istype(user) || QDELETED(user))
		return

	for(var/path in GLOB.changeling_mutations)
		var/obj/item/mutation = locate(path) in user
		if(mutation)
			user.temporarily_remove_item_from_inventory(mutation, force = TRUE)
			qdel(mutation)


/**
 * Takes any datum `source` and checks it for changeling datum.
 */
/proc/ischangeling(datum/source)
	if(!source)
		return FALSE

	if(!has_variable(source, "mind"))
		if(has_variable(source, "antag_datums"))
			var/datum/mind/our_mind = source
			return our_mind.has_antag_datum(/datum/antagonist/changeling)

		return FALSE

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/changeling)


/proc/has_no_DNA(mob/living/carbon/user)
	if(!istype(user) || !user.dna)
		return TRUE
	return NO_DNA in user.dna.species.species_traits
