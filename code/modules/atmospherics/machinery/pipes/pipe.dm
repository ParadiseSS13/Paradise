/obj/machinery/atmospherics/pipe
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/datum/pipeline/parent
	var/volume = 0
	force = 20
	power_state = NO_POWER_USE
	can_unwrench = TRUE
	damage_deflection = 12
	var/alert_pressure = 80*ONE_ATMOSPHERE //minimum pressure before check_pressure(...) should be called

	can_be_undertile = TRUE

	//Buckling
	can_buckle = TRUE
	buckle_requires_restraints = TRUE
	buckle_lying = -1

	flags_2 = NO_MALF_EFFECT_2

/obj/machinery/atmospherics/pipe/Initialize(mapload)
	. = ..()
	//so pipes under walls are hidden
	if(iswallturf(get_turf(src)))
		level = 1

/obj/machinery/atmospherics/pipe/Destroy()
	releaseAirToTurf()
	QDEL_NULL(air_temporary)

	var/turf/T = loc
	for(var/obj/machinery/atmospherics/meter/meter in T)
		if(meter.target == src)
			var/obj/item/pipe_meter/PM = new (T)
			meter.transfer_fingerprints_to(PM)
			qdel(meter)

	// if we're somehow by ourself
	if(parent && !QDELETED(parent) && parent.members.len == 1 && parent.members[1] == src)
		qdel(parent)
	parent = null

	return ..()

/obj/machinery/atmospherics/pipe/returnPipenet(obj/machinery/atmospherics/A)
	return parent

/obj/machinery/atmospherics/pipe/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This pipe can be disconnected from a pipenet using a wrench. If the pipe's pressure is too high, you'll end up flying.</span>"

/obj/machinery/atmospherics/pipe/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/analyzer))
		atmosanalyzer_scan(parent.air, user)
		return
	return ..()

/obj/machinery/atmospherics/proc/pipeline_expansion()
	return null

/obj/machinery/atmospherics/pipe/proc/check_pressure(pressure)
	//Return 1 if parent should continue checking other pipes
	//Return null if parent should stop checking other pipes. Recall: qdel(src) will by default return null

	return 1

/obj/machinery/atmospherics/pipe/proc/releaseAirToTurf()
	if(air_temporary)
		var/turf/T = loc
		T.assume_air(air_temporary)
		air_update_turf()

/obj/machinery/atmospherics/pipe/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	if(!parent)
		return 0
	return parent.air

/obj/machinery/atmospherics/pipe/build_network(remove_deferral = FALSE)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	..()

/obj/machinery/atmospherics/pipe/setPipenet(datum/pipeline/P)
	parent = P

/obj/machinery/atmospherics/pipe/color_cache_name(obj/machinery/atmospherics/node)
	if(istype(node, /obj/machinery/atmospherics/pipe/manifold) || istype(node, /obj/machinery/atmospherics/pipe/manifold4w))
		if(pipe_color == node.pipe_color)
			return node.pipe_color
		else
			return null
	else if(istype(node, /obj/machinery/atmospherics/pipe/simple))
		return node.pipe_color
	else
		return pipe_color

// A check to make sure both nodes exist - self-delete if they aren't present
/obj/machinery/atmospherics/pipe/proc/check_nodes_exist()
	return
