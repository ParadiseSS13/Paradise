RESTRICT_TYPE(/datum/antagonist/uplifted_primitive)

/datum/antagonist/uplifted_primitive
	name = "Uplifted Primitive"
	job_rank = ROLE_UPLIFTED_PRIMITIVE
	special_role = SPECIAL_ROLE_UPLIFTED_PRIMITIVE
	antag_hud_name = "huduplifted"
	antag_hud_type = ANTAG_HUD_UPLIFTED_TEAMLESS

	/// The UID of the nest built by the owner.
	var/nest_uid

	/// The species of the owner at the time this datum was added.
	var/datum/species/initial_species

	/// The list of objective types which can be selected from when picking a personal objective.
	var/list/potential_objectives = list(
		/datum/objective/uplifted/collect_items,
		/datum/objective/uplifted/collect_food,
		/datum/objective/uplifted/collect_animals,
		/datum/objective/uplifted/fortify,
	)

/datum/antagonist/uplifted_primitive/give_objectives()
	add_antag_objective(pick(potential_objectives))

/datum/antagonist/uplifted_primitive/apply_innate_effects(mob/living/mob_override)
	var/mob/living/carbon/human/H = ..()
	if(!istype(H))
		return

	if(H.dna.species.is_small)
		ADD_TRAIT(H, TRAIT_GENELESS, UNIQUE_TRAIT_SOURCE(src))

	RegisterSignal(H, COMSIG_LIVING_ENTER_VENTCRAWL, PROC_REF(apply_ventcrawl_effects))
	RegisterSignal(H, COMSIG_LIVING_EXIT_VENTCRAWL, PROC_REF(remove_ventcrawl_effects))

	owner.AddSpell(new /datum/spell/uplifted_make_nest)

/datum/antagonist/uplifted_primitive/remove_innate_effects(mob/living/mob_override)
	var/mob/living/carbon/human/H = ..()
	if(!istype(H))
		return

	REMOVE_TRAIT(H, TRAIT_GENELESS, UNIQUE_TRAIT_SOURCE(src))

	UnregisterSignal(H, COMSIG_LIVING_ENTER_VENTCRAWL)
	UnregisterSignal(H, COMSIG_LIVING_EXIT_VENTCRAWL)

	owner.RemoveSpell(/datum/spell/uplifted_make_nest)

/datum/antagonist/uplifted_primitive/proc/apply_ventcrawl_effects()
	SIGNAL_HANDLER
	var/mob/living/L = owner.current
	ADD_TRAIT(L, TRAIT_RESISTLOWPRESSURE, UNIQUE_TRAIT_SOURCE(src))
	ADD_TRAIT(L, TRAIT_RESISTHIGHPRESSURE, UNIQUE_TRAIT_SOURCE(src))

/datum/antagonist/uplifted_primitive/proc/remove_ventcrawl_effects()
	SIGNAL_HANDLER
	var/mob/living/L = owner.current
	REMOVE_TRAIT(L, TRAIT_RESISTLOWPRESSURE, UNIQUE_TRAIT_SOURCE(src))
	REMOVE_TRAIT(L, TRAIT_RESISTHIGHPRESSURE, UNIQUE_TRAIT_SOURCE(src))

/datum/antagonist/uplifted_primitive/add_antag_hud(mob/living/antag_mob)
	var/datum/team/uplifted_primitive/team = get_team()
	var/datum/atom_hud/antag/global_hud = GLOB.huds[antag_hud_type]

	global_hud.join_hud(antag_mob)
	if(team)
		team.team_hud.join_hud(antag_mob)

	set_antag_hud(antag_mob, antag_hud_name)

/datum/antagonist/uplifted_primitive/remove_antag_hud(mob/living/antag_mob)
	var/datum/team/uplifted_primitive/team = get_team()
	var/datum/atom_hud/antag/global_hud = GLOB.huds[antag_hud_type]

	global_hud.leave_hud(antag_mob)
	if(team)
		team.team_hud.leave_hud(antag_mob)

	set_antag_hud(antag_mob, null)

/datum/antagonist/uplifted_primitive/create_team(datum/team/team)
	var/datum/species/owner_species = get_owner_species()
	if(!owner_species)
		return null

	var/datum/team/uplifted_primitive/existing = SSticker.mode.uplifted_teams[owner_species]
	if(!existing)
		existing = new /datum/team/uplifted_primitive(new_species = owner_species)
	return existing

/datum/antagonist/uplifted_primitive/get_team()
	var/datum/species/owner_species = get_owner_species()
	if(!owner_species)
		return null

	return SSticker.mode.uplifted_teams[owner_species]

/datum/antagonist/uplifted_primitive/add_owner_to_gamemode()
	var/datum/species/owner_species = get_owner_species()

	var/list/minds = SSticker.mode.uplifted_primitives[owner_species]
	if(!minds)
		minds = list()
		SSticker.mode.uplifted_primitives[owner_species] = minds
	minds |= owner

/datum/antagonist/uplifted_primitive/remove_owner_from_gamemode()
	var/datum/species/owner_species = get_owner_species()

	var/list/minds = SSticker.mode.uplifted_primitives[owner_species]
	if(minds)
		minds -= owner
		if(!length(minds))
			SSticker.mode.uplifted_primitives[owner_species] = null
			SSticker.mode.uplifted_primitives -= owner_species

/datum/antagonist/uplifted_primitive/proc/get_owner_species()
	if(initial_species == null)
		var/mob/living/carbon/human/H = owner.current
		if(istype(H))
			initial_species = H.dna.species.type
		else
			initial_species = FALSE
	return initial_species
