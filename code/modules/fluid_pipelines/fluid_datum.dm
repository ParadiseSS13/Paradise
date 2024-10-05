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

/// Returns the total amount of fluids in the container
/datum/fluid_container/proc/get_fluid_volumes()
	. = 0
	for(var/datum/fluid/liquid as anything in fluids)
		if(QDELETED(liquid) || liquid.fluid_amount <= 0)
			continue
		. += liquid.fluid_amount








/datum/fluid
	/// What is our fluid called
	var/fluid_name = "ant fluid idk" // ants are bugs ... right?
	/// How much of our fluid do we have
	var/fluid_amount = 0

/datum/fluid/raw_plasma
	fluid_name = "unrefined plasma"

/datum/fluid/refined_plasma
	fluid_name = "refined plasma"
