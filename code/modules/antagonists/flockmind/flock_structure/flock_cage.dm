/obj/structure/flock/cage
	name = "energy cage"
	desc = "A digitized energy structure that appears to turn matter into gnesis."
	icon_state = "cage"
	alpha = 190

	anchored = FALSE
	max_integrity = 30

	flock_desc = "Converts organic creatures into Flockdrones."
	flock_id = "Matter reprocessor"

	var/tmp/mob/living/victim

	/// Has the nest spewed forth mobs?
	var/hatched = FALSE

	/// Timer until you can ghost from your body without penalty
	var/ghost_timer

	COOLDOWN_DECLARE(flock_message_cd)
	COOLDOWN_DECLARE(relaymove_cd)

/obj/structure/flock/cage/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	create_reagents(100)
	reagents.add_reagent("gnesis_tox", 100)
	AddComponent(/datum/component/flock_protection)

/obj/structure/flock/cage/Destroy()
	QDEL_NULL(victim)
	return ..()

/obj/structure/flock/cage/deconstruct(disassembled)
	reagents.reaction(get_turf(src), REAGENT_TOUCH)

	if(victim)
		visible_message(SPAN_WARNING("[victim] breaks free from [src]."))
		set_victim(null)

	var/drop_loc = drop_location()
	for(var/atom/movable/AM as anything in contents)
		AM.forceMove(drop_loc)

	. = ..()

/obj/structure/flock/cage/process(seconds_per_tick)

	if(victim && flock)
		flock.update_enemy(victim)

	if(isanimal_or_basicmob(victim))
		victim.gib()
		var/obj/structure/flock/egg/bit/B = new /obj/structure/flock/egg/bit(get_turf(src), flock)
		qdel(src)
		return

	victim.adjustCloneLoss(rand(2,6))

	if(victim && COOLDOWN_FINISHED(src, flock_message_cd))
		COOLDOWN_START(src, flock_message_cd, rand(10, 25) SECONDS)
		playsound(src, 'sound/goonstation/weapons/nano-blade-1.ogg', 50, TRUE)
		to_chat(victim, SPAN_FLOCKSAY("<i>[pick(strings("flock.json", "conversion"))]</i>"))

	if(victim.stat == DEAD && !hatched) // Victim killed. Make flock mobs
		hatched = TRUE
		var/num_bits = rand(1, 2)
		var/num_drones = rand(1, 2)
		for(var/i in 1 to num_bits)
			var/obj/structure/flock/egg/bit/B = new /obj/structure/flock/egg/bit(get_turf(src), flock)
			B.throw_at(get_random_perimeter_turf(get_turf(src), 10), 10, 3, spin = FALSE)
		for(var/i in 1 to num_drones)
			var/obj/structure/flock/egg/D = new /obj/structure/flock/egg(get_turf(src), flock)
			D.throw_at(get_random_perimeter_turf(get_turf(src), 10), 10, 3, spin = FALSE)

/obj/structure/flock/cage/container_resist(mob/living/user)
	to_chat(victim, SPAN_WARNING("You resist against the confines of the cage!"))
	if(!do_after_once(user, 3 SECONDS, FALSE, src, interaction_key = "flock_cage_resist"))
		return

	audible_message("[src] [pick("cracks","bends","shakes","groans")].")
	playsound(
		src,
		pick('sound/goonstation/flockmind/flockdrone_grump1.ogg', 'sound/goonstation/flockmind/flockdrone_grump2.ogg', 'sound/goonstation/flockmind/flockdrone_grump3.ogg'),
		50,
		TRUE
	)
	take_damage(7, BRUTE)

/obj/structure/flock/cage/relaymove(mob/living/user, direction)
	if(!COOLDOWN_FINISHED(src, relaymove_cd))
		return

	COOLDOWN_START(src, relaymove_cd, 1 SECONDS)

	if(!prob(80))
		return

	if(prob(20))
		audible_message("[src] [pick("cracks", "bends", "shakes", "groans")].")

	take_damage(1, BRUTE)

// INTO THE CAGE
/obj/structure/flock/cage/proc/cage_mob(mob/living/L)
	L.forceMove(src)
	set_victim(L)
	victim.visible_message(SPAN_DANGER("A [name] materializes around [victim],"))
	ghost_timer = addtimer(CALLBACK(src, PROC_REF(ghost_check), L), 15 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/// Setter for victim, no side effects.
/obj/structure/flock/cage/proc/set_victim(mob/living/new_victim)
	if(victim)
		UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
		victim.clear_fullscreen("flock_convert")

	victim = new_victim

	if(!victim)
		STOP_PROCESSING(SSobj, src)
		return

	START_PROCESSING(SSobj, src)
	RegisterSignal(victim, COMSIG_MOVABLE_MOVED, PROC_REF(victim_gone))
	victim.overlay_fullscreen("flock_convert", /atom/movable/screen/fullscreen/flock_convert)

/obj/structure/flock/cage/proc/victim_gone(datum/source)
	SIGNAL_HANDLER
	if(!QDELING(src))
		deconstruct(FALSE)

/obj/structure/flock/cage/proc/ghost_check(mob/user)
	victim.throw_alert("ghost_cage", /atom/movable/screen/alert/ghost/flock)
	to_chat(victim, SPAN_GHOSTALERT("You may now click on the ghost prompt on your screen to leave your body. You will be alerted when you're removed from the cage."))
	if(tgui_alert(victim, "You may now ghost and keep respawnability. You will be notified if you leave the cage, would you like to do so?", "Ghosting", list("Yes", "No")) != "Yes")
		return
	victim.ghostize(GHOST_FLAGS_DEFAULT, ghost_color = "#19b299")

/mob/living/proc/test_cage()
	var/obj/structure/flock/cage/cage = new(get_turf(src))
	cage.cage_mob(src)
