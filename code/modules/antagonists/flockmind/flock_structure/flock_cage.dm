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
	/// Current item being munched on.
	var/tmp/obj/item/eating

	/// With this much gnesis, create an egg.
	var/egg_gnesis_cost = 100
	/// Per second, how much gnesis is generated.
	var/absorption_rate = 2
	/// Timer until you can ghost from your body without penalty
	var/ghost_timer

	COOLDOWN_DECLARE(flock_message_cd)
	COOLDOWN_DECLARE(resist_cd)
	COOLDOWN_DECLARE(relaymove_cd)

/obj/structure/flock/cage/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	create_reagents(200)

/obj/structure/flock/cage/Destroy()
	QDEL_NULL(victim)
	QDEL_NULL(eating)
	return ..()

/obj/structure/flock/cage/deconstruct(disassembled)
	if(disassembled)
		spend_gnesis(TRUE)
	else
		reagents.reaction(get_turf(src), REAGENT_TOUCH)

	if(victim)
		visible_message(SPAN_WARNING("[victim] breaks free from [src]."))
		set_victim(null)

	var/drop_loc = drop_location()
	for(var/atom/movable/AM as anything in contents)
		AM.forceMove(drop_loc)

	. = ..()

/obj/structure/flock/cage/process(seconds_per_tick)
	spend_gnesis()

	if(victim && flock)
		flock.update_enemy(victim)

	if(QDELETED(eating))
		eating = null

	if(!eating)
		var/obj/item/edibles = list()
		for(var/obj/item/edible in src)
			edibles += edible

		if(length(edibles))
			set_eating_target(pick(edibles))
			playsound(src, 'sound/goonstation/weapons/nano-blade-1.ogg', 50, TRUE)

			if(victim?.stat == CONSCIOUS)
				to_chat(victim, SPAN_WARNING("[eating] begins to melt away."))

		else
			chew_on_mob(seconds_per_tick)

	else
		eating.take_damage(absorption_rate * seconds_per_tick * 25, ACID, armor_penetration_percentage = 100)
		reagents.add_reagent(/datum/reagent/gnesis, absorption_rate * seconds_per_tick)

	if(victim && COOLDOWN_FINISHED(src, flock_message_cd))
		COOLDOWN_START(src, flock_message_cd, rand(10, 25) SECONDS)
		to_chat(victim, SPAN_FLOCKSAY("<i>[pick(strings("flock.json", "conversion"))]</i>"))

	if(!victim) // Victim gibbed
		deconstruct(TRUE)

/obj/structure/flock/cage/container_resist(mob/living/user)
	if(!COOLDOWN_FINISHED(src, resist_cd))
		return

	COOLDOWN_START(src, resist_cd, 3 SECONDS)

	audible_message("[src] [pick("cracks","bends","shakes","groans")].")
	take_damage(6, BRUTE)

	playsound(
		src,
		pick('sound/goonstation/flockmind/flockdrone_grump1.ogg', 'sound/goonstation/flockmind/flockdrone_grump2.ogg', 'sound/goonstation/flockmind/flockdrone_grump3.ogg'),
		50,
		TRUE
	)

	take_damage(1, BRUTE)

/obj/structure/flock/cage/relaymove(mob/living/user, direction)
	if(!COOLDOWN_FINISHED(src, relaymove_cd))
		return

	COOLDOWN_START(src, relaymove_cd, 1 SECONDS)

	if(!prob(80))
		return

	if(prob(20))
		audible_message("[src] [pick("cracks", "bends", "shakes", "groans")].")

	take_damage(1, BRUTE)

/obj/structure/flock/cage/flock_structure_examine(mob/user)
	return list(
		SPAN_FLOCKSAY("<b>Volume:</b> [reagents.get_reagent_amount(/datum/reagent/gnesis)]"),
		SPAN_FLOCKSAY("<b>Needed volume:</b> [egg_gnesis_cost]<br>"),
	)

/// Picks an item, organ, or bodypart, to munch on.
/obj/structure/flock/cage/proc/chew_on_mob(seconds_per_tick)
	if(!ishuman(victim))
		victim.adjustBruteLoss(absorption_rate * seconds_per_tick)
		if(victim.stat == DEAD)
			visible_message(SPAN_DANGER("[src] rips apart what remains of [victim]."))
			set_victim(null)
			victim.gib()
		return

	var/mob/living/carbon/human/human_victim = victim
	var/list/items = human_victim.get_equipped_items()
	if(length(items))
		while(length(items) && !eating)
			var/obj/item/candidate = pick_n_take(items)
			if(candidate.resistance_flags & INDESTRUCTIBLE)
				candidate.forceMove(get_turf(src))
				visible_message(SPAN_WARNING("[src] pulls [eating] from [human_victim] and drops it!"))
				continue
			candidate.forceMove(src)
			if(!QDELETED(candidate))
				set_eating_target(candidate)

		if(eating)
			visible_message(SPAN_WARNING("[src] pulls [eating] from [human_victim] and begins ripping it apart."))
			playsound(src, 'sound/goonstation/weapons/nano-blade-1.ogg', 50, TRUE)
		return

	var/list/bodyparts = human_victim.bodyparts.Copy()
	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.body_part in list(HEAD, UPPER_TORSO, LOWER_TORSO))
			bodyparts -= BP

	if(length(bodyparts))
		var/obj/item/organ/external/yummy_appendage = pick(bodyparts)

		human_victim.pain(yummy_appendage.name, 85)
		yummy_appendage.droplimb(FALSE)
		set_eating_target(yummy_appendage)
		eating.forceMove(src)

		visible_message(SPAN_DANGER("[src] tears [eating] from [human_victim] and begins ripping it apart."))
		return

	var/list/skip_organs = list("eyes", "ears", "brain", "heart", "lungs")
	for(var/obj/item/organ/internal/O in bodyparts)
		if(O.slot in skip_organs)
			bodyparts -= O

	if(length(bodyparts))
		var/obj/item/organ/internal/yummy_organ = pick(bodyparts)
		var/organ_loc_str = yummy_organ.parent_organ
		human_victim.pain(organ_loc_str, 85)
		yummy_organ.remove(human_victim)
		if(!QDELING(yummy_organ))
			set_eating_target(yummy_organ)
			eating.forceMove(src)

		visible_message(SPAN_DANGER("[src] tears [eating] from [human_victim]'s [organ_loc_str] and begins ripping it apart."))
		return

	visible_message(SPAN_DANGER("[src] rips apart what remains of [human_victim]."))
	set_victim(null)
	human_victim.gib(TRUE, TRUE, TRUE)

// INTO THE CAGE
/obj/structure/flock/cage/proc/cage_mob(mob/living/L)
	L.forceMove(src)
	set_victim(L)
	victim.visible_message(SPAN_DANGER("A [name] materializes around [victim],"))
	ghost_timer = addtimer(CALLBACK(src, PROC_REF(ghost_check), L), 15 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/// Spends gnesis on eggs or a cube. Only spends on eggs by default.
/obj/structure/flock/cage/proc/spend_gnesis(all = FALSE)
	var/egg_spawn_count = 0
	var/spend_on_cube = 0

	// Get egg count and spend the gnesis.
	while(reagents.has_reagent(/datum/reagent/gnesis, egg_gnesis_cost))
		reagents.remove_reagent(/datum/reagent/gnesis, egg_gnesis_cost)
		egg_spawn_count++

	// Spawn eggs or pool it to the cube
	for(var/i in 1 to egg_spawn_count)
		if(length(flock?.drones) <= FLOCK_DRONE_LIMIT)
			var/obj/structure/flock/egg/egg = new(drop_location(), flock)
			egg.throw_at(get_edge_target_turf(egg, pick(GLOB.alldirs)), 6, 3)
		else
			spend_on_cube += egg_gnesis_cost

	// If we're dumping it all, collect the remaining gnesis
	if(all)
		spend_on_cube += reagents.get_reagent_amount(/datum/reagent/gnesis)

	// Cube
	if(spend_on_cube)
		reagents.remove_reagent(/datum/reagent/gnesis, spend_on_cube)

		var/obj/item/flock_cube/cube = new
		cube.substrate = spend_on_cube
		cube.forceMove(drop_location())

/// Setter for eating, no side effects.
/obj/structure/flock/cage/proc/set_eating_target(obj/item/new_eating)
	if(eating)
		UnregisterSignal(eating, COMSIG_MOVABLE_MOVED)

	eating = new_eating

	if(!eating)
		return

	RegisterSignal(eating, COMSIG_MOVABLE_MOVED, PROC_REF(target_gone))

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

/obj/structure/flock/cage/proc/target_gone(datum/source)
	SIGNAL_HANDLER
	set_eating_target(null)

/obj/structure/flock/cage/proc/ghost_check(mob/user)
	victim.throw_alert("ghost_cage", /atom/movable/screen/alert/ghost/flock)
	to_chat(victim, SPAN_GHOSTALERT("You may now click on the ghost prompt on your screen to leave your body. You will be alerted when you're removed from the cage."))
	if(tgui_alert(victim, "You may now ghost and keep respawnability, you will be notified if you leave the cage, would you like to do so?", "Ghosting", list("Yes", "No")) != "Yes")
		return
	victim.ghostize()

/mob/living/proc/test_cage()
	var/obj/structure/flock/cage/cage = new(get_turf(src))
	cage.cage_mob(src)
