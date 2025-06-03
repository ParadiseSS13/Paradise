/obj/effect/spawner/themed_mess
	name = "mess spawner"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "questionmark"

	/// The number of tiles to spread to. Each new chosen tile receives this
	/// value decremented by one, ensuring the maximum size of the mess is limited
	/// by the original spawner's value.
	var/remaining_tiles

/obj/effect/spawner/themed_mess/proc/drop_mess()
	return

/obj/effect/spawner/themed_mess/proc/drop_object()
	return

/obj/effect/spawner/themed_mess/proc/make_next_spawner(turf/T)
	new type(T, remaining_tiles - 1)

/obj/effect/spawner/themed_mess/New(loc, size = 10)
	. = ..()
	remaining_tiles = size
	var/turf/T = get_turf(src)
	if(!T)
		stack_trace("Spawner placed in nullspace!")
		return
	randspawn(T)

/obj/effect/spawner/themed_mess/proc/randspawn(turf/T)
	drop_mess(T)

	if(prob(25))
		drop_object(T)

	if(remaining_tiles > 0)
		var/dirs = GLOB.alldirs.Copy()
		shuffle_inplace(dirs)
		for(var/dir in dirs)
			var/turf/next = get_step(src, dir)
			// Just check for plasteel turf to avoid walls and areas under windows
			// findEventArea excludes maintenance anyway so we don't care about missing plating
			if(istype(next, /turf/simulated/floor/plasteel) && !(locate(/obj/effect/decal/cleanable) in next))
				make_next_spawner(next)
				break
	qdel(src)

/obj/effect/spawner/themed_mess/party
	name = "party mess spawner"

/obj/effect/spawner/themed_mess/party/drop_mess(turf/T)
	if(prob(50))
		new /obj/effect/decal/cleanable/vomit(T)
	else
		new /obj/effect/decal/cleanable/confetti(T)

/obj/effect/spawner/themed_mess/party/drop_object(turf/T)
	if(prob(50))
		new /obj/item/cigbutt(T) // does its own random placement transforms
	else if(prob(20))
		new /obj/item/cigbutt/roach(T)
	else
		var/trash_type = pick(
			/obj/item/broken_bottle,
			/obj/item/shard,
		)
		var/obj/trash = new trash_type(T)
		trash.pixel_x = rand(-10, 10)
		trash.pixel_y = rand(-10, 10)
		trash.transform = turn(transform, rand(0, 360))

/obj/effect/spawner/themed_mess/bloody
	name = "bloody mess spawner"
	var/bloodcolor

/obj/effect/spawner/themed_mess/bloody/New(loc, size = 10, blood = null)
	bloodcolor = blood ? blood : pick(
		"#004400",
		"#0064c8",
		"#1d2cbf",
		"#2299fc",
		"#a10808",
		"#a200ff",
		"#a3d4eb",
		"#b9ae9c",
		"#fb9800")
	return ..()

/obj/effect/spawner/themed_mess/bloody/make_next_spawner(turf/T)
	new type(T, remaining_tiles - 1, bloodcolor)

/obj/effect/spawner/themed_mess/bloody/drop_mess(turf/T)
	var/blood_decal_type = pick(
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/blood/splatter,
		/obj/effect/decal/cleanable/blood/drip,
		/obj/effect/decal/cleanable/blood/gibs,
	)
	var/obj/effect/decal/cleanable/blood/decal = new blood_decal_type(T)
	decal.basecolor = bloodcolor
	decal.update_icon()

/obj/effect/spawner/themed_mess/bloody/drop_object(turf/T)
	if(prob(50))
		var/organ_type = pick(
			/obj/item/organ/internal/ears,
			/obj/item/organ/internal/eyes,
			/obj/item/organ/internal/kidneys,
			/obj/item/organ/internal/liver,
			/obj/item/organ/internal/lungs,
			/obj/item/organ/internal/appendix,
		)
		var/obj/organ = new organ_type(T)
		organ.pixel_x = rand(-10, 10)
		organ.pixel_y = rand(-10, 10)

/obj/effect/spawner/themed_mess/robotic
	name = "robotic themed mess"

/obj/effect/spawner/themed_mess/robotic/drop_mess(turf/T)
	var/blood_decal_type = pick(
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/blood/splatter,
		/obj/effect/decal/cleanable/blood/drip,
		/obj/effect/decal/cleanable/blood/gibs,
	)
	var/obj/effect/decal/cleanable/blood/decal = new blood_decal_type(T)
	decal.basecolor = COLOR_BLOOD_MACHINE
	decal.update_icon()

	if(prob(10))
		new /obj/effect/decal/cleanable/blood/gibs/robot(T)

/obj/effect/spawner/themed_mess/engineering
	name = "engineering themed mess"

/obj/effect/spawner/themed_mess/engineering/drop_mess(turf/T)
	var/turf/simulated/floor/floor = T
	if(istype(floor))
		if(prob(50))
			floor.burn_tile()
		else if(prob(25))
			floor.break_tile()
		else if(!istype(floor, /turf/simulated/floor/grass)) // Just because grass isn't *as* easy to replace
			floor.remove_tile(null, silent = TRUE, make_tile = TRUE)

/obj/effect/spawner/themed_mess/engineering/drop_object(turf/T)
	var/obj_type = pick(
		/obj/effect/decal/cleanable/glass,
		/obj/item/stack/cable_coil/cut,
		/obj/item/stack/rods,
		/obj/item/stack/tile/plasteel,
	)
	new obj_type(T)

/obj/effect/spawner/themed_mess/dirty
	name = "dirt themed mess"

/obj/effect/spawner/themed_mess/dirty/drop_mess(turf/T)
	new /obj/effect/decal/cleanable/dirt(T)

/obj/effect/spawner/themed_mess/dirty/drop_object(turf/T)
	var extra_trash = pick(
		/obj/effect/decal/cleanable/generic,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/shreds,
		/obj/effect/decal/cleanable/molten_object,
	)
	new extra_trash(T)

/obj/effect/spawner/themed_mess/cooking
	name = "cooking themed mess"

/obj/effect/spawner/themed_mess/cooking/drop_mess(turf/T)
	var mess_type = pick(
		/obj/effect/decal/cleanable/egg_smudge,
		/obj/effect/decal/cleanable/flour,
		/obj/effect/decal/cleanable/blood/oil/cooking,
		/obj/effect/decal/cleanable/ants,
	)
	new mess_type(T)

/obj/effect/spawner/themed_mess/cooking/drop_object(turf/T)
	var/extra_trash = pick(
		/obj/item/trash/plate,
		/obj/item/food/meat,
		/obj/item/trash/snack_bowl,
	)
	var/obj/trash = new extra_trash(T)
	trash.pixel_x = rand(-10, 10)
	trash.pixel_y = rand(-10, 10)
	trash.transform = turn(transform, rand(0, 360))

/proc/generate_themed_messes(themed_mess_types)
	var/mess_count = rand(5, 10)
	for(var/i in 1 to mess_count)
		var/area/target_area = findEventArea()
		if(!target_area)
			log_debug("Failed to generate themed messes: No valid event areas were found.")
			return
		var/list/turfs = get_area_turfs(target_area)
		while(length(turfs))
			var/turf/T = pick_n_take(turfs)
			// Just check for plasteel turf to avoid walls and areas under windows
			// findEventArea excludes maintenance anyway so we don't care about missing plating
			if(!istype(T, /turf/simulated/floor/plasteel))
				continue
			var/spawner_type = pick(themed_mess_types)
			new spawner_type(T, rand(10, 20))
			break
