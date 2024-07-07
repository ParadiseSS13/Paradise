/datum/unit_test/bespoke_element/Run()
	for(var/datum/element/element_type as anything in subtypesof(/datum/element))
		if(initial(element_type.element_flags) & ELEMENT_BESPOKE && initial(element_type.id_arg_index) == INFINITY)
			Fail("Element type [element_type] has ELEMENT_BESPOKE and a default id_arg_index.")
