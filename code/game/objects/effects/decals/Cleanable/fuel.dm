/obj/effect/decal/cleanable/liquid_fuel
	//Liquid fuel is used for things that used to rely on volatile fuels or plasma being contained to a couple tiles.
	icon = 'icons/effects/effects.dmi'
	icon_state = "fuel"
	layer = TURF_LAYER+0.2
	anchored = 1
	var/amount = 1 //Basically moles
	var/newprocess = 1
	var/processing = 0


/obj/effect/decal/cleanable/liquid_fuel/New(newLoc,amt=1)
	src.amount = amt

	//Be absorbed by any other liquid fuel in the tile.
	for(var/obj/effect/decal/cleanable/liquid_fuel/other in newLoc)
		if(other != src)
			other.amount += src.amount
			spawn other.Spread()
			qdel(src)

	Spread()
	. = ..()

/obj/effect/decal/cleanable/liquid_fuel/proc/Spread()
	//Allows liquid fuels to sometimes flow into other tiles.
	if(amount < 0.5) return
	var/turf/simulated/S = loc
	if(!istype(S)) return
	for(var/d in cardinal)
		if(rand(25))
			var/turf/simulated/target = get_step(src,d)
			var/turf/simulated/origin = get_turf(src)
			if(origin.CanPass(null, target, 0, 0) && target.CanPass(null, origin, 0, 0))
				if(!locate(/obj/effect/decal/cleanable/liquid_fuel) in target)
					new/obj/effect/decal/cleanable/liquid_fuel(target, amount*0.25)
					amount *= 0.75

/obj/effect/decal/cleanable/liquid_fuel/fire_act(null, temperature, volume)
	if(processing)
		return
	processing_objects.Add(src)
	process()
	processing = 1

/obj/effect/decal/cleanable/liquid_fuel/process()
	if(newprocess)
		newprocess = 0
		return
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, amount * 50)
		amount--
		if(amount <= 0)
			processing_objects.Remove(src)
			qdel(src)
			for(var/obj/effect/hotspot/H in location)
				qdel(H)
			return
		for(var/direction in cardinal)
			if(!(location.atmos_adjacent_turfs & direction))
				continue
			var/turf/simulated/T = get_step(src, direction)
			if(istype(T) && !T.active_hotspot)
				for(var/obj/effect/decal/cleanable/liquid_fuel/F in T)
					T.hotspot_expose(700, F.amount * 50)