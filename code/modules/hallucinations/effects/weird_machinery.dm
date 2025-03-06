
/obj/effect/hallucination/trait_applier
	/// The trait to apply
	var/trait_applied


/obj/effect/hallucination/trait_applier/Initialize(mapload, mob/living/carbon/hallucination_target)
	. = ..()
	// add a single one per datum in case it gets invoked multiple times
	ADD_TRAIT(hallucination_target, trait_applied, UNIQUE_TRAIT_SOURCE(src))

/obj/effect/hallucination/trait_applier/Destroy()
	REMOVE_TRAIT(target, trait_applied, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/obj/effect/hallucination/trait_applier/medical_machinery
	duration = list(40 SECONDS, 60 SECONDS)
	trait_applied = TRAIT_MED_MACHINE_HALLUCINATING
