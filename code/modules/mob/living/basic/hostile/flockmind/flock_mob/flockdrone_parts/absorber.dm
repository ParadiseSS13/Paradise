/datum/flockdrone_part/absorber
	var/obj/item/held_item

	var/absorption_rate = 4
	/// Per point of integrity, generate this much substrate.
	var/integrity_substrate_ratio = 4

/datum/flockdrone_part/absorber/Destroy(force, ...)
	QDEL_NULL(held_item)
	return ..()

/datum/flockdrone_part/absorber/left_click_on(atom/target, in_reach)
	var/obj/item/I = target
	if(!in_reach || !istype(I) || !isturf(I.loc))
		return

	return try_pickup_item(I)

/datum/flockdrone_part/absorber/process(delta_time)
	var/added = 0
	var/obj/item/eating = held_item

	if(istype(eating, /obj/item/flock_cube))
		var/obj/item/flock_cube/cube = eating
		added = cube.substrate
		drone.substrate.add_points(added)
		qdel(cube)
		to_chat(drone, span_notice("We decompile the resource cache, adding <b>[added]</b> substrate to our reserves."))
	else
		added = eating.take_damage(absorption_rate * delta_time, BRUTE, ACID, sound_effect = FALSE, armor_penetration = 100)
		drone.substrate.add_points(added * integrity_substrate_ratio)

	if(!held_item) // if take_damage qdeletes it, it becomes null due to signal stuff.
		to_chat(drone, span_notice("We finish converting [eating] into substrate."))
		return

	playsound(drone, SFX_SPARKS, 30, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)

/datum/flockdrone_part/absorber/proc/try_pickup_item(obj/item/I)
	if(held_item)
		return FALSE

	if(I.item_flags & ABSTRACT)
		return FALSE

	drone.face_atom(I)
	I.do_pickup_animation(drone, I.loc)
	I.forceMove(drone)
	if(QDELETED(I))
		return FALSE

	held_item = I
	RegisterSignal(I, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING), PROC_REF(held_item_moved))
	START_PROCESSING(SSprocessing, src)

	var/matrix/first_matrix = matrix()
	first_matrix.Turn(-45)
	first_matrix.Scale(1.2, 0.6)
	var/matrix/second_matrix = matrix()
	first_matrix.Turn(45)
	first_matrix.Scale(0.6, 1.2)
	animate(held_item, loop= -1, color="#00ffd7", transform= first_matrix, time = 2 SECONDS, tag = "flockdrone_eat")
	animate(color = "#ffffff", transform = second_matrix, time = 2 SECONDS)

	screen_obj?.vis_contents += held_item
	return TRUE

/datum/flockdrone_part/absorber/proc/try_drop_item(move = TRUE)
	if(!held_item)
		return FALSE

	UnregisterSignal(held_item, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))

	var/obj/item/old_item = held_item
	animate(held_item, tag = "flockdrone_eat")
	held_item = null

	STOP_PROCESSING(SSprocessing, src)
	screen_obj?.vis_contents -= old_item

	if(!move)
		return TRUE

	var/turf/drop_loc = drone.drop_location()
	if(drop_loc)
		old_item.forceMove(drop_loc)
	else
		qdel(old_item)

	return TRUE

/datum/flockdrone_part/absorber/proc/held_item_moved(datum/source)
	SIGNAL_HANDLER

	try_drop_item(FALSE)
