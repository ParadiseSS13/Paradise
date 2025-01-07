// A datum that contains all the fluids currently in here
// I'm getting lost in the sauce chief, get me out

/*
 * So the idea is that the container is incredibly simple and just an intermediary for the pipeline datum and the fluids.
 * For example, all fluid container size should be handled by the fluid pipeline datum, and this should only have procs that do things like return the total volume of all contained fluids
 *
 */
/datum/fluid_container
	/// List with all fluids currently in the container
	var/list/fluids = list()
	/// Reference to owner pipeline datum
	var/datum/fluid_pipe/pipe_datum

/datum/fluid_container/New(datum/fluid_pipe/parent)
	. = ..()
	pipe_datum = parent

/// Returns the total amount of fluids in the container
/datum/fluid_container/proc/get_fluid_volumes()
	. = 0
	for(var/datum/fluid/liquid as anything in fluids)
		if(QDELETED(liquid) || liquid.fluid_amount <= 0)
			continue
		. += liquid.fluid_amount

/**
  * A proc that merges the `container` with `src`
  * Returns the surviving container
  * This proc should not be called often because it scales in O(n^2) and there isn't a limit as to how many fluids can be in pipenets
  */
/datum/fluid_container/proc/merge_containers(datum/fluid_container/container)
	if(!container)
		return src
	if(length(container.fluids) <= 0)
		qdel(container)
		return src
	for(var/datum/fluid/liquid as anything in fluids)
		for(var/datum/fluid/second_liquid as anything in container.fluids)
			if(istype(liquid, second_liquid))
				liquid.fluid_amount += second_liquid.fluid_amount
				container.fluids -= second_liquid
				qdel(second_liquid)
				break

	// Merge the remaining unique fluids with this container
	fluids += container.fluids
	return src

/datum/fluid_container/proc/add_fluid(type, amount)
	if(!ispath(type))
		stack_trace("add_fluid was called with a non-typepath fluid")
		return

	var/datum/fluid/potential = is_type_in_list(type, fluids, TRUE)
	if(!potential)
		fluids += new type(amount)
	else
		potential.fluid_amount += amount
