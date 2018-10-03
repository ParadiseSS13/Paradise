/obj/machinery/atmospherics/binary
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	use_power = IDLE_POWER_USE

	var/datum/gas_mixture/air1
	var/datum/gas_mixture/air2

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2

	var/datum/pipeline/parent1
	var/datum/pipeline/parent2

/obj/machinery/atmospherics/binary/New()
	..()
	switch(dir)
		if(NORTH)
			initialize_directions = NORTH|SOUTH
		if(SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST)
			initialize_directions = EAST|WEST
		if(WEST)
			initialize_directions = EAST|WEST

	air1 = new
	air2 = new

	air1.volume = 200
	air2.volume = 200

/obj/machinery/atmospherics/binary/Destroy()
	if(node1)
		node1.disconnect(src)
		node1 = null
		nullifyPipenet(parent1)
	if(node2)
		node2.disconnect(src)
		node2 = null
		nullifyPipenet(parent2)
	return ..()

/obj/machinery/atmospherics/binary/atmos_init()
	..()
	var/node2_connect = dir
	var/node1_connect = turn(dir, 180)

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if(c)
				target.connected_to = c
				connected_to = c
				node1 = target
				break

	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if(c)
				target.connected_to = c
				connected_to = c
				node2 = target
				break

	update_icon()
	update_underlays()

/obj/machinery/atmospherics/binary/build_network(remove_deferral = FALSE)
	if(!parent1)
		parent1 = new /datum/pipeline()
		parent1.build_pipeline(src)

	if(!parent2)
		parent2 = new /datum/pipeline()
		parent2.build_pipeline(src)
	..()

/obj/machinery/atmospherics/binary/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent1)
		node1 = null
	else if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent2)
		node2 = null
	update_icon()

/obj/machinery/atmospherics/binary/nullifyPipenet(datum/pipeline/P)
	..()
	if(!P)
		return
	if(P == parent1)
		parent1.other_airs -= air1
		parent1 = null
	else if(P == parent2)
		parent2.other_airs -= air2
		parent2 = null

/obj/machinery/atmospherics/binary/returnPipenetAir(datum/pipeline/P)
	if(P == parent1)
		return air1
	else if(P == parent2)
		return air2

/obj/machinery/atmospherics/binary/pipeline_expansion(datum/pipeline/P)
	if(P)
		if(parent1 == P)
			return list(node1)
		else if(parent2 == P)
			return list(node2)
	else
		return list(node1, node2)

/obj/machinery/atmospherics/binary/setPipenet(datum/pipeline/P, obj/machinery/atmospherics/A)
	if(A == node1)
		parent1 = P
	else if(A == node2)
		parent2 = P

/obj/machinery/atmospherics/binary/returnPipenet(obj/machinery/atmospherics/A)
	if(A == node1)
		return parent1
	else if(A == node2)
		return parent2

/obj/machinery/atmospherics/binary/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	if(Old == parent1)
		parent1 = New
	else if(Old == parent2)
		parent2 = New

/obj/machinery/atmospherics/binary/unsafe_pressure_release(var/mob/user,var/pressures)
	..()

	var/turf/T = get_turf(src)
	if(T)
		//Remove the gas from air1+air2 and assume it
		var/datum/gas_mixture/environment = T.return_air()
		var/lost = pressures*environment.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)
		lost += pressures*environment.volume/(air2.temperature * R_IDEAL_GAS_EQUATION)
		var/shared_loss = lost/2

		var/datum/gas_mixture/to_release = air1.remove(shared_loss)
		to_release.merge(air2.remove(shared_loss))
		T.assume_air(to_release)
		air_update_turf(1)

/obj/machinery/atmospherics/binary/process_atmos()
	..()
	return parent1 && parent2
