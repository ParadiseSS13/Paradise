
/atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!isnull(reagents))
		reagents.temperature_reagents(exposed_temperature)

/turf/simulated/temperature_expose(exposed_temperature)
	if(reagents)
		reagents.temperature_reagents(exposed_temperature, 10, 300)

/turf/proc/hotspot_expose(exposed_temperature, exposed_volume)
	return

/turf/simulated/hotspot_expose(exposed_temperature, exposed_volume)
	var/datum/milla_safe/make_hotspot/milla = new()
	milla.invoke_async(src, exposed_temperature, exposed_volume)

/datum/milla_safe/make_hotspot

/datum/milla_safe/make_hotspot/on_run(turf/simulated/tile, exposed_temperature, exposed_volume)
	create_hotspot(tile, exposed_temperature, exposed_volume)

//This is the icon for fire on turfs.
/obj/effect/hotspot
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/goonstation/effects/fire.dmi'
	icon_state = "1"
	layer = MASSIVE_OBJ_LAYER
	alpha = 250
	blend_mode = BLEND_ADD
	light_range = 2

	var/volume = 125
	var/temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	/// The last tick this hotspot should be alive for.
	var/death_timer = 0
	/// How much fuel did we burn this tick?
	var/fuel_burnt = 0
	/// Which tick did we last load data at?
	var/data_tick = 0
	/// Which update tick are we on?
	var/update_tick = 0
	/// How often do we update?
	var/update_interval = 1

/obj/effect/hotspot/New()
	..()
	dir = pick(GLOB.cardinal)

/obj/effect/hotspot/proc/update_visuals(fuel_burnt)
	color = heat2color(temperature)
	var/list/rgb = rgb2num(color)
	if(isnull(light_color))
		light_color = color
		set_light(l_color = color)
	else
		var/list/light_rgb = rgb2num(light_color)
		var/r_delta = abs(rgb[1] - light_rgb[1])
		var/g_delta = abs(rgb[2] - light_rgb[2])
		var/b_delta = abs(rgb[3] - light_rgb[3])
		if(r_delta > 10 || g_delta > 10 || b_delta)
			set_light(l_color = color)

	if(fuel_burnt > 1)
		icon_state = "3"
	else if(fuel_burnt > 0.1)
		icon_state = "2"
	else
		icon_state = "1"


/obj/effect/hotspot/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

// Garbage collect itself by nulling reference to it

/obj/effect/hotspot/Destroy()
	set_light(0)
	var/turf/simulated/T = loc
	if(istype(T) && T.active_hotspot == src)
		T.active_hotspot = null
	return ..()

/obj/effect/hotspot/proc/recolor()
	color = heat2color(temperature)
	set_light(l_color = color)

// TODO: Vestigal, kept temporarily to avoid a merge conflict.
/obj/effect/hotspot/proc/DestroyTurf()
	if(issimulatedturf(loc))
		var/turf/simulated/T = loc
		if(T.to_be_destroyed && !T.changing_turf)
			var/chance_of_deletion
			if(T.heat_capacity) //beware of division by zero
				chance_of_deletion = T.max_fire_temperature_sustained / T.heat_capacity * 8 //there is no problem with prob(23456), min() was redundant --rastaf0
			else
				chance_of_deletion = 100
			if(prob(chance_of_deletion))
				T.ChangeTurf(T.baseturf)
			else
				T.to_be_destroyed = 0
				T.max_fire_temperature_sustained = 0

/obj/effect/hotspot/proc/on_atom_entered(datum/source, mob/living/entered)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED

	if(istype(entered))
		entered.fire_act()

/obj/effect/hotspot/singularity_pull()
	return

/// Largely for the fireflash procs below
/obj/effect/hotspot/fake
	var/burn_time = 3 SECONDS

/obj/effect/hotspot/fake/New()
	..()
	if(burn_time)
		QDEL_IN(src, burn_time)

/proc/fireflash(atom/center, radius, temp)
	if(!temp)
		temp = rand(2800, 3200)
	for(var/turf/T in view(radius, get_turf(center)))
		if(isspaceturf(T))
			continue
		if(locate(/obj/effect/hotspot) in T)
			continue
		if(!can_line(get_turf(center), T, radius + 1))
			continue

		var/obj/effect/hotspot/fake/H = new(T)
		H.temperature = temp
		H.volume = 400
		H.recolor()

		T.hotspot_expose(H.temperature, H.volume)
		for(var/atom/A in T)
			if(isliving(A))
				continue
			if(A != H)
				A.fire_act(null, H.temperature, H.volume)

		if(isfloorturf(T))
			var/turf/simulated/floor/F = T
			F.burn_tile()

		for(var/mob/living/L in T)
			L.adjust_fire_stacks(3)
			L.IgniteMob()
			if(ishuman(L))
				var/mob/living/carbon/human/M = L
				var/heatBlockPercent = 1 - M.get_heat_protection(temp)
				M.bodytemperature += (temp - M.bodytemperature) * heatBlockPercent / 3
			else
				L.bodytemperature = (2 * L.bodytemperature + temp) / 3

/proc/fireflash_s(atom/center, radius, temp, falloff)
	if(temp < T0C + 60)
		return list()
	var/list/open = list()
	var/list/affected = list()
	var/list/closed = list()
	var/turf/Ce = get_turf(center)
	var/max_dist = radius
	if(falloff)
		max_dist = min((temp - (T0C + 60)) / falloff, radius)
	open[Ce] = 0
	while(length(open))
		var/turf/T = open[1]
		var/dist = open[T]
		open -= T
		closed[T] = TRUE

		if(isspaceturf(T))
			continue
		if(dist > max_dist)
			continue
		if(!ff_cansee(Ce, T))
			continue

		var/obj/effect/hotspot/existing_hotspot = locate(/obj/effect/hotspot) in T
		var/prev_temp = 0
		var/need_expose = 0
		var/expose_temp = 0
		if(!existing_hotspot)
			var/obj/effect/hotspot/fake/H = new(T)
			need_expose = TRUE
			H.temperature = temp - dist * falloff
			expose_temp = H.temperature
			H.volume = 400
			H.recolor()
			existing_hotspot = H

		else if(existing_hotspot.temperature < temp - dist * falloff)
			expose_temp = (temp - dist * falloff) - existing_hotspot.temperature
			prev_temp = existing_hotspot.temperature
			if(expose_temp > prev_temp * 3)
				need_expose = TRUE
			existing_hotspot.temperature = temp - dist * falloff
			existing_hotspot.recolor()

		affected[T] = existing_hotspot.temperature
		if(need_expose && expose_temp)
			T.hotspot_expose(expose_temp, existing_hotspot.volume)
			for(var/atom/A in T)
				if(isliving(A))
					continue
				if(A != existing_hotspot)
					A.fire_act(null, expose_temp, existing_hotspot.volume)
		if(isfloorturf(T))
			var/turf/simulated/floor/F = T
			F.burn_tile()
		for(var/mob/living/L in T)
			L.adjust_fire_stacks(3)
			L.IgniteMob()
			if(ishuman(L))
				var/mob/living/carbon/human/M = L
				var/heatBlockPercent = 1 - M.get_heat_protection(temp)
				M.bodytemperature += (temp - M.bodytemperature) * heatBlockPercent / 3
			else
				L.bodytemperature = (2 * L.bodytemperature + temp) / 3

		if(T.density)
			continue

		if(dist == max_dist)
			continue

		for(var/direction in GLOB.cardinal)
			var/turf/link = get_step(T, direction)
			if(!link)
				continue
			// Check if it wasn't already visited and if you can get to that turf
			if(!closed[link] && T.CanAtmosPass(direction) && link.CanAtmosPass(turn(direction, 180)))
				var/dx = link.x - Ce.x
				var/dy = link.y - Ce.y
				var/target_dist = max((dist + 1 + sqrt(dx * dx + dy * dy)) / 2, dist)
				if(link in open)
					if(open[link] > target_dist)
						open[link] = target_dist
				else
					open[link] = target_dist

	return affected

/proc/fireflash_sm(atom/center, radius, temp, falloff, capped = TRUE, bypass_rng = FALSE)
	var/list/affected = fireflash_s(center, radius, temp, falloff)
	for(var/turf/simulated/T in affected)
		var/mytemp = affected[T]
		var/melt = 1643.15 // default steel melting point
		var/divisor = melt
		if(mytemp >= melt * 2)
			var/chance = mytemp / divisor
			if(capped)
				chance = min(chance, 30)
			if(prob(chance) || bypass_rng)
				T.visible_message("<span class='warning'>[T] melts!</span>")
				T.burn_down()
	return affected
