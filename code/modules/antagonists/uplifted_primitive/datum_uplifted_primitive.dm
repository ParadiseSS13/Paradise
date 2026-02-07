RESTRICT_TYPE(/datum/antagonist/uplifted_primitive)

/datum/antagonist/uplifted_primitive
	name = "Uplifted Primitive"
	job_rank = ROLE_UPLIFTED_PRIMITIVE
	special_role = SPECIAL_ROLE_UPLIFTED_PRIMITIVE
	antag_hud_name = "huduplifted"
	antag_hud_type = ANTAG_HUD_UPLIFTED_PRIMITIVE

	/// The UID of the nest built by the owner.
	var/nest_uid

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
