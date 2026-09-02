/obj/machinery/atmospherics/unary
	initialize_directions = SOUTH
	layer = TURF_LAYER+0.1
	/// The current air contents of this device
	var/datum/gas_mixture/air_contents
	/// Our one pipe node (we're unary)
	var/obj/machinery/atmospherics/node
	/// The pipenet we are plugged into
	var/datum/pipeline/parent

/obj/machinery/atmospherics/unary/Initialize(mapload)
	. = ..()
	initialize_directions = dir
	air_contents = new
	air_contents.volume = 200

/obj/machinery/atmospherics/unary/Destroy()
	if(node)
		node.disconnect(src)
		node = null
		nullifyPipenet(parent)
	return ..()

/obj/machinery/atmospherics/unary/atmos_init()
	..()
	for(var/obj/machinery/atmospherics/target in get_step(src, dir))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if(c)
				target.connected_to = c
				src.connected_to = c
				node = target
				break

	update_icon()
	update_underlays()

/obj/machinery/atmospherics/unary/default_change_direction_wrench(mob/user, obj/item/wrench/W)
	if(..())
		initialize_directions = dir
		if(node)
			node.disconnect(src)
		node = null
		nullifyPipenet(parent)
		atmos_init()
		if(node)
			node.atmos_init()
			node.addMember(src)
		build_network()
		. = 1

/obj/machinery/atmospherics/unary/update_pipe_image()
	. = ..()
	if(parent)
		for(var/mob/crawler in parent.crawlers)
			var/mob/living/current_crawler = crawler
			current_crawler.update_pipe_vision(src)

/obj/machinery/atmospherics/unary/build_network(remove_deferral = FALSE)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	..()

/obj/machinery/atmospherics/unary/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node)
		if(istype(node, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node = null
	update_icon()

/obj/machinery/atmospherics/unary/nullifyPipenet(datum/pipeline/P)
	..()
	if(!P)
		return
	if(P == parent)
		parent.other_airs -= air_contents
		parent = null

/obj/machinery/atmospherics/unary/returnPipenetAir()
	return air_contents

/obj/machinery/atmospherics/unary/pipeline_expansion()
	return list(node)

/obj/machinery/atmospherics/unary/setPipenet(datum/pipeline/P)
	parent = P

/obj/machinery/atmospherics/unary/returnPipenet()
	return parent

/obj/machinery/atmospherics/unary/get_machinery_pipelines()
	return parent

/obj/machinery/atmospherics/unary/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	if(Old == parent)
		parent = New

/obj/machinery/atmospherics/unary/unsafe_pressure_release(mob/user, pressure)
	..()

	var/turf/T = get_turf(src)
	if(!T)
		return

	var/lost = pressure * CELL_VOLUME / (air_contents.temperature() * R_IDEAL_GAS_EQUATION)

	var/datum/gas_mixture/to_release = air_contents.remove(lost)
	T.blind_release_air(to_release)
