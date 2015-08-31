/obj/machinery/atmospherics/pipe

	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/datum/pipeline/parent

	var/volume = 0
	var/frozen = 0 // used by the pipe freezer
	force = 20

	layer = 2.4 //under wires with their 2.44
	use_power = 0

	var/alert_pressure = 80*ONE_ATMOSPHERE
		//minimum pressure before check_pressure(...) should be called
/obj/machinery/atmospherics/pipe/New()
	..()
	//so pipes under walls are hidden
	if(istype(get_turf(src), /turf/simulated/wall) || istype(get_turf(src), /turf/simulated/shuttle/wall) || istype(get_turf(src), /turf/unsimulated/wall))
		level = 1

/obj/machinery/atmospherics/pipe/proc/pipeline_expansion()
	return null

/obj/machinery/atmospherics/pipe/proc/check_pressure(pressure)
	//Return 1 if parent should continue checking other pipes
	//Return null if parent should stop checking other pipes. Recall: del(src) will by default return null

	return 1

/obj/machinery/atmospherics/pipe/return_air()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.air

/obj/machinery/atmospherics/pipe/build_network()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.return_network()

/obj/machinery/atmospherics/pipe/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.network_expand(new_network, reference)

/obj/machinery/atmospherics/pipe/return_network(obj/machinery/atmospherics/reference)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.return_network(reference)


/obj/machinery/atmospherics/pipe/Destroy()
	qdel(parent)
	if(air_temporary && loc)
		loc.assume_air(air_temporary)

	return ..()

/obj/machinery/atmospherics/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	if (istype(src, /obj/machinery/atmospherics/pipe/tank))
		return ..()
	if (istype(src, /obj/machinery/atmospherics/pipe/vent))
		return ..()

	if(istype(W,/obj/item/device/pipe_painter))
		return 0

	if (istype(W, /obj/item/device/pipe_freezer))
		if(!src.frozen) // If the pipe is not already frozen
			user << "<span class='alert'>You begin to freeze the [src].</span>"
			if (do_after(user, 60, target = src))
				user.visible_message( \
					"[user] freezes \the [src].", \
					"<span class='notice'>You finished freezing \the [src].</span>", \
					"You hear the hiss of gas.")
				src.frozen = 1
				spawn (200)
					src.frozen = 0
					src.visible_message( \
					"\The ice arounds \the [src] melts.", \
					"<span class='notice'>Your frozen [src] has thawed.</span>", \
					"You hear dripping water.")

		add_fingerprint(user)
		return 1

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	var/turf/T = src.loc
	if (level==1 && isturf(T) && T.intact)
		user << "<span class='alert'>You must remove the plating first.</span>"
		return 1

	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		if (!src.frozen) // If the pipe is not frozen
			user << "<span class='alert'>You cannot unwrench \the [src], it is too exerted due to internal pressure.</span>"
			add_fingerprint(user)
			return 1
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user << "<span class='notice'>You begin to unfasten \the [src]...</span>"
	if (do_after(user, 40, target = src))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"<span class='notice'>You have unfastened \the [src].</span>", \
			"You hear a ratchet.")
		var/obj/item/P = new /obj/item/pipe(loc, make_from=src)
		for (var/obj/machinery/meter/meter in T)
			if (meter.target == src)
				new /obj/item/pipe_meter(T)
				qdel(meter)
		if(P)
			transfer_fingerprints_to(P)
			P.add_fingerprint(user)
		qdel(src)
	return 1

/obj/machinery/atmospherics/pipe/color_cache_name(var/obj/machinery/atmospherics/node)
	if(istype(src, /obj/machinery/atmospherics/pipe/tank))
		return ..()

	if(istype(node, /obj/machinery/atmospherics/pipe/manifold) || istype(node, /obj/machinery/atmospherics/pipe/manifold4w))
		if(pipe_color == node.pipe_color)
			return node.pipe_color
		else
			return null
	else if(istype(node, /obj/machinery/atmospherics/pipe/simple))
		return node.pipe_color
	else
		return pipe_color