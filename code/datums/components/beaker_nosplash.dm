/*
	This component should be used for machinery and other datums that take a beaker/reagent container
	for processing, where splashing the beaker is generally *not* what you want to do.

	Essentially tells the item attacking to not apply any sort of after-attack, which in glass beakers
	tends to be splashing or changing reagent levels.
*/

/datum/component/beaker_nosplash

/datum/component/beaker_nosplash/Initialize(obj/item/I)
	if(!isatom(parent) || ismob(parent))
		return COMPONENT_INCOMPATIBLE
