/*
	This component should be used for machinery and other datums that take a single beaker/reagent container
	for processing, such as chem heaters, pandemic machines, etc.

	Mostly serves to prevent beakers and the like from spilling their containers out on harm interact.
	Pretty simple
*/

/datum/component/beaker_nosplash

/datum/component/beaker_nosplash/Initialize(obj/item/I)
	if(!isatom(parent) || !istype(parent, /obj/machinery))
		return COMPONENT_INCOMPATIBLE
