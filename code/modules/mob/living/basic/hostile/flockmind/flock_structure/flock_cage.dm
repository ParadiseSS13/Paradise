/obj/structure/flock/cage
	name = "weird energy cage"

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
		reagents.expose(get_turf(src), TOUCH)

	if(victim)
		visible_message(span_warning("[victim] breaks free from [src]."))
		set_victim(null)

	var/drop_loc = drop_location()
	for(var/atom/movable/AM as anything in contents)
		AM.forceMove(drop_loc)

	. = ..()

/obj/structure/flock/cage/process(delta_time)
	spend_gnesis()

	if(victim && flock)
		flock.update_enemy(victim)

	if(!eating)
		var/obj/item/edibles = list()
		for(var/obj/item/edible in src)
			edibles += edible

		if(length(edibles))
			set_eating_target(pick(edibles))
			playsound(src, 'goon/sounds/weapons/nano-blade-1.ogg', 50, TRUE)

			if(victim?.stat == CONSCIOUS)
				to_chat(victim, span_warning("[eating] begins to melt away."))

		else
			chew_on_mob(delta_time)

	else
		eating.take_damage(absorption_rate * delta_time * 25, BRUTE, armor_penetration = 100)
		reagents.add_reagent(/datum/reagent/toxin/gnesis, absorption_rate * delta_time)
		if(eating.is_destroyed())
			QDEL_NULL(eating)

	if(victim && COOLDOWN_FINISHED(src, flock_message_cd))
		COOLDOWN_START(src, flock_message_cd, rand(10, 25) SECONDS)
		to_chat(victim, span_flocksay("<i>[pick(strings("flock.json", "conversion"))]</i>"))

	if(!victim) // Victim gibbed
		deconstruct(TRUE)

/obj/structure/flock/cage/container_resist_act(mob/living/user)
	if(!COOLDOWN_FINISHED(src, resist_cd))
		return

	COOLDOWN_START(src, resist_cd, 3 SECONDS)

	audible_message("[src] [pick("cracks","bends","shakes","groans")].", hearing_distance = COMBAT_MESSAGE_RANGE)
	take_damage(6, BRUTE)

	playsound(
		src,
		pick('goon/sounds/flockmind/flockdrone_grump1.ogg', 'goon/sounds/flockmind/flockdrone_grump2.ogg', 'goon/sounds/flockmind/flockdrone_grump3.ogg'),
		50,
		TRUE
	)

	take_damage(1, BRUTE)
	do_hurt_animation()

/obj/structure/flock/cage/relaymove(mob/living/user, direction)
	if(SEND_SIGNAL(src, COMSIG_ATOM_RELAYMOVE, user, direction) & COMSIG_BLOCK_RELAYMOVE)
		return

	if(!COOLDOWN_FINISHED(src, relaymove_cd))
		return

	COOLDOWN_START(src, relaymove_cd, 1 SECOND)

	if(!prob(80))
		return

	playsound(src, 'goon/sounds/Crystal_Hit_1.ogg', 50, TRUE)
	if(prob(20))
		audible_message("[src] [pick("cracks","bends","shakes","groans")].", hearing_distance = COMBAT_MESSAGE_RANGE)

	take_damage(1, BRUTE)
	do_hurt_animation()

/obj/structure/flock/cage/flock_structure_examine(mob/user)
	return list(
		span_flocksay("<b>Volume:</b> [reagents.get_reagent_amount(/datum/reagent/toxin/gnesis)]"),
		span_flocksay("<b>Needed volume:</b> [egg_gnesis_cost]<br>"),
	)

/// Picks an item, organ, or bodypart, to munch on.
/obj/structure/flock/cage/proc/chew_on_mob(delta_time)
	if(!ishuman(victim))
		victim.adjustBruteLoss(absorption_rate * delta_time)
		if(victim.stat == DEAD)
			visible_message(span_danger("[src] rips apart what remains of [victim]."))
			set_victim(null)
			victim.gib(TRUE, TRUE, TRUE)
		return

	var/mob/living/carbon/human/human_victim = victim
	var/list/items = list_clear_nulls(human_victim.get_all_worn_items())
	if(length(items))
		while(length(items) && !eating)
			var/obj/item/candidate = pick_n_take(items)
			human_victim.transferItemToLoc(candidate, src, TRUE, TRUE)
			if(!QDELETED(candidate))
				set_eating_target(candidate)

		if(eating)
			visible_message(span_warning("[src] pulls [eating] from [human_victim] and begins ripping it apart."))
			playsound(src, 'goon/sounds/weapons/nano-blade-1.ogg', 50, TRUE)
		return

	var/list/bodyparts = human_victim.bodyparts.Copy()
	for(var/obj/item/bodypart/BP in bodyparts)
		if(BP.body_part & (HEAD | CHEST))
			bodyparts -= BP

	if(length(bodyparts))
		var/obj/item/bodypart/chest/chest = human_victim.get_bodypart(BODY_ZONE_CHEST)
		var/obj/item/bodypart/yummy_appendage = pick(bodyparts)

		human_victim.notify_pain(PAIN_AMT_AGONIZING, "A surge of pain eminates from where your [yummy_appendage.plaintext_zone] used to be.", ignore_cd = TRUE)
		yummy_appendage.dismember(DROPLIMB_EDGE, FALSE)
		set_eating_target(yummy_appendage)
		eating.forceMove(src)

		chest.clamp_wounds() // Haha bitch

		visible_message(span_danger("[src] tears [eating] from [human_victim] and begins ripping it apart."))
		return

	var/list/organs = human_victim.processing_organs.Copy()
	var/list/skip_organs = list(ORGAN_SLOT_BRAIN, ORGAN_SLOT_HEART, ORGAN_SLOT_TONGUE, ORGAN_SLOT_EYES, ORGAN_SLOT_EARS)
	for(var/obj/item/organ/O in organs)
		if(O.slot in skip_organs)
			organs -= O

	/// We dont want it to tear out their lungs and have them instantly pass out and die of brain damage shortly after.
	var/obj/item/organ/lungs/lungs = locate() in organs
	if(lungs && length(organs) > 1)
		organs -= lungs

	if(length(organs))
		var/obj/item/organ/yummy_organ = pick(organs)
		var/organ_loc_str = yummy_organ.ownerlimb.plaintext_zone

		human_victim.notify_pain(PAIN_AMT_AGONIZING, "Pain explodes from your [organ_loc_str].", ignore_cd = TRUE)
		yummy_organ.Remove(human_victim)
		if(!QDELING(yummy_organ))
			set_eating_target(yummy_organ)
			eating.forceMove(src)

		visible_message(span_danger("[src] tears [eating] from [human_victim]'s [organ_loc_str] and begins ripping it apart."))
		return

	visible_message(span_danger("[src] rips apart what remains of [human_victim]."))
	set_victim(null)
	human_victim.gib(TRUE, TRUE, TRUE)

// INTO THE CAGE
/obj/structure/flock/cage/proc/cage_mob(mob/living/L)
	L.forceMove(src)
	set_victim(L)
	victim.visible_message(span_danger("A [name] materializes around [victim],"))

/// Spends gnesis on eggs or a cube. Only spends on eggs by default.
/obj/structure/flock/cage/proc/spend_gnesis(all = FALSE)
	var/egg_spawn_count = 0
	var/spend_on_cube = 0

	// Get egg count and spend the gnesis.
	while(reagents.has_reagent(/datum/reagent/toxin/gnesis, egg_gnesis_cost))
		reagents.remove_reagent(/datum/reagent/toxin/gnesis, egg_gnesis_cost)
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
		spend_on_cube += reagents.get_reagent_amount(/datum/reagent/toxin/gnesis)

	// Cube
	if(spend_on_cube)
		reagents.remove_reagent(/datum/reagent/toxin/gnesis, spend_on_cube)

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

/mob/living/proc/test_cage()
	var/obj/structure/flock/cage/cage = new(get_turf(src))
	cage.cage_mob(src)
