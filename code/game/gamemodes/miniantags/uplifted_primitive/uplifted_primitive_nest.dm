/// The amount of integrity to regenerate in exchange for scrap every process().
#define INTEGRITY_REGEN_AMOUNT 5
/// The amount of scrap to consume to regenerate every process().
#define INTEGRITY_REGEN_SCRAP_COST 2000
/// The amount of scrap to consume when spawning a new mobs.
#define SPAWN_SCRAP_COST 5000
/// The amount of food to consume when spawning a new mobs.
#define SPAWN_FOOD_COST 20
/// The minimum amount of time to wait between spawning new mobs.
#define SPAWN_COOLDOWN_TIME (120 SECONDS)
/// The number of percentage points to increase the probability of the next spawned mob being sentient by.
#define SPAWN_SENTIENT_PROB_INCREASE 25
/// The maximum number the spawn count can reach before disabling NPC spawning.
#define SPAWN_MAX_LIMIT 2
/// The number of additional mobs permitted by each extra nearby nest.
#define SPAWN_EXTRA_NEST_MOBS 1

/obj/structure/uplifted_primitive
	icon = 'icons/obj/uplifted_primitive.dmi'
	anchored = TRUE

/obj/structure/uplifted_primitive/nest
	icon_state = "nest"
	desc = "A home for some primitive form of sentient being."

	max_integrity = 200

	/// The species of lesser human to spawn.
	var/datum/species/nest_species = /datum/species/monkey

	/// The amount of scrap (recycled materials) currently stored in the nest.
	var/available_scrap = 0

	/// The amount of food currently stored in the nest.
	var/available_food = 0

	/// The cooldown between successfully spawning new mobs.
	COOLDOWN_DECLARE(spawn_cooldown)

	/// The probability that the next spawned mob will be sentient.
	var/sentient_probability = 5

	/// Whether or not to let ghosts interact with the nest to spawn without a roll.
	var/spawn_on_demand = FALSE

	/// The mapping between the path of a crafting output and a list containing
	/// its scrap and food costs, and an optional argument to be passed to new().
	var/list/crafting_items = alist(
		/obj/item/stack/sheet/wood = list(5000, 0, 5),
		/obj/item/stack/tile/grass = list(5000, 2, 10),
		/obj/item/stack/medical/bruise_pack/comfrey = list(2000, 10, 3),
		/obj/item/stack/medical/ointment/aloe = list(2000, 10, 3),
		/obj/item/grown/bananapeel = list(0, 3),
	)
	var/list/crafting_choices_cache
	var/list/crafting_mapping_cache

/obj/structure/uplifted_primitive/nest/Initialize(mapload)
	. = ..(mapload)
	AddElement(/datum/element/relay_attackers)
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(rally_retaliation))
	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, spawn_cooldown, SPAWN_COOLDOWN_TIME)

/obj/structure/uplifted_primitive/nest/Destroy()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(src, COMSIG_ATOM_WAS_ATTACKED)
	RemoveElement(/datum/element/relay_attackers)
	return ..()

/obj/structure/uplifted_primitive/nest/deconstruct(disassembled)
	if(available_scrap > 0 || available_food > 0)
		new /obj/item/uplifted/nest_bundle(get_turf(src), available_scrap, available_food)

	return ..()

/obj/structure/uplifted_primitive/nest/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("It appears to have been built by [lowertext(nest_species::name_plural)].")

	var/datum/antagonist/uplifted_primitive/antag = user.mind?.has_antag_datum(/datum/antagonist/uplifted_primitive)
	if((antag && user.dna?.species.type == nest_species) || isobserver(user))
		. += SPAN_NOTICE("It contains [available_scrap] units of scrap.")
		. += SPAN_NOTICE("It contains [available_food] units of food.")
		. += SPAN_NOTICE("It needs at least [SPAWN_SCRAP_COST] scrap and [SPAWN_FOOD_COST] food to produce another primitive.")
		. += SPAN_NOTICE("A new primitive can emerge [COOLDOWN_FINISHED(src, spawn_cooldown) \
			? "soon" \
			: "in [round(COOLDOWN_TIMELEFT(src, spawn_cooldown) / (1 SECONDS))] seconds"].")

		if(locateUID(antag?.nest_uid) == src)
			. += SPAN_NOTICE("<b>Alt-Click</b> to deconstruct the nest.")

	if(isobserver(user))
		. += SPAN_NOTICE("<b>Click</b> to spawn as a primitive when this nest is ready.")

/obj/structure/uplifted_primitive/nest/process()
	if(obj_integrity < max_integrity && available_scrap >= INTEGRITY_REGEN_SCRAP_COST)
		available_scrap -= INTEGRITY_REGEN_SCRAP_COST
		obj_integrity = min(obj_integrity + INTEGRITY_REGEN_AMOUNT, max_integrity)

	if(!spawn_on_demand && available_scrap >= SPAWN_SCRAP_COST && available_food >= SPAWN_FOOD_COST && COOLDOWN_FINISHED(src, spawn_cooldown))
		COOLDOWN_START(src, spawn_cooldown, SPAWN_COOLDOWN_TIME)

		var/rolled = roll_sentience()
		if(rolled && try_spawn_uplifted())
			available_scrap -= SPAWN_SCRAP_COST
			available_food -= SPAWN_FOOD_COST
			sentient_probability = initial(sentient_probability)

			if(has_guaranteed_spawn())
				SSticker.mode.uplifted_teams[nest_species].guaranteed_sentient_spawns -= 1
		else
			if(count_spawn_limit() < SPAWN_MAX_LIMIT)
				spawn_npc()
				available_scrap -= SPAWN_SCRAP_COST
				available_food -= SPAWN_FOOD_COST
			else
				spawn_on_demand = rolled
			// accumulating probability ensures a sentient spawn occurs in a finite number of iterations
			sentient_probability = min(sentient_probability + SPAWN_SENTIENT_PROB_INCREASE, 100)

/obj/structure/uplifted_primitive/nest/proc/roll_sentience()
	return has_guaranteed_spawn() || prob(sentient_probability)

/obj/structure/uplifted_primitive/nest/proc/has_guaranteed_spawn()
	var/datum/team/uplifted_primitive/team = SSticker.mode.uplifted_teams[nest_species]
	return team?.guaranteed_sentient_spawns > 0

/obj/structure/uplifted_primitive/nest/proc/spawn_npc()
	if(QDELETED(src))
		return
	var/mob/living/carbon/human/primitive = new(get_turf(src), nest_species)
	primitive.ai_controller = new /datum/ai_controller/monkey/uplifted_npc(primitive)
	visible_message(SPAN_NOTICE("[primitive.name] emerges out of the nest!"))

/// Returns TRUE if a new player mob was successfully spawned, otherwise FALSE.
/obj/structure/uplifted_primitive/nest/proc/try_spawn_uplifted()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as an uplifted primitive?", ROLE_UPLIFTED_PRIMITIVE, TRUE, source = /obj/structure/uplifted_primitive/nest)
	if(!length(candidates) || QDELETED(src))
		return FALSE

	var/mob/C = pick(candidates)
	return incarnate_uplifted_mob(C)

/obj/structure/uplifted_primitive/nest/proc/incarnate_uplifted_mob(mob/target)
	var/key = target.key
	if(!key)
		return FALSE

	dust_if_respawnable(target)

	var/datum/mind/player_mind = new /datum/mind(key)
	var/mob/living/carbon/human/primitive = new(get_turf(src), nest_species)

	player_mind.active = TRUE
	player_mind.transfer_to(primitive)
	player_mind.add_antag_datum(/datum/antagonist/uplifted_primitive)

	visible_message(SPAN_NOTICE("[primitive.name] emerges out of the nest with a curious look!"))
	return TRUE

/// Returns the number of mobs currently contributing to the spawn limit.
/// Currently, any NPC human with the same species as the nest and a monkey ai controller within range is counted.
/obj/structure/uplifted_primitive/nest/proc/count_spawn_limit()
	var/count = 0

	for(var/atom/movable/A in orange(src, 7))
		var/mob/living/carbon/human/H = A
		if(istype(H))
			if(H.dna.species.type != nest_species || H.mind)
				continue
			if(!istype(H.ai_controller, /datum/ai_controller/monkey/uplifted_npc))
				continue
			count += 1

		var/obj/structure/uplifted_primitive/nest/N = A
		if(istype(N))
			if(N.nest_species != nest_species)
				continue
			count -= SPAWN_EXTRA_NEST_MOBS

	return count

/obj/structure/uplifted_primitive/nest/attack_ghost(mob/dead/observer/user)
	if(..() || !istype(user))
		return TRUE

	if(spawn_on_demand \
	&& available_scrap >= SPAWN_SCRAP_COST \
	&& available_food >= SPAWN_FOOD_COST \
	&& COOLDOWN_FINISHED(src, spawn_cooldown))
		if(tgui_alert(user, "Are you sure you want to spawn as an uplifted primitive?", "Are you sure?", list("Yes", "No")) != "Yes")
			return
		incarnate_uplifted_mob(user)
		available_scrap -= SPAWN_SCRAP_COST
		available_food -= SPAWN_FOOD_COST
		sentient_probability = initial(sentient_probability)
		spawn_on_demand = FALSE
	else
		to_chat(user, SPAN_WARNING("This nest is not ready to spawn another primitive!"))

/obj/structure/uplifted_primitive/nest/AltClick(mob/user, modifiers)
	var/datum/antagonist/uplifted_primitive/antag = user.mind.has_antag_datum(/datum/antagonist/uplifted_primitive)

	if(!antag || locateUID(antag.nest_uid) != src)
		return ..()

	to_chat(user, SPAN_NOTICE("You start disassembling the nest."))
	if(!do_after(user, 7 SECONDS, target = src))
		return

	to_chat(user, SPAN_NOTICE("You finish disassembling the nest and collect the remaining scrap and food."))
	deconstruct(TRUE)

/obj/structure/uplifted_primitive/nest/CtrlClick(mob/user, modifiers)
	if(!user.mind?.has_antag_datum(/datum/antagonist/uplifted_primitive))
		return ..()

	if(user.dna?.species.type != nest_species)
		return ..()

	show_crafting_radial(user)

/obj/structure/uplifted_primitive/nest/proc/show_crafting_radial(mob/user)
	if(!crafting_choices_cache || !crafting_mapping_cache)
		build_crafting_caches()

	var/raw_choice = show_radial_menu(user, src, crafting_choices_cache, radius = 48, require_near = TRUE)
	if(!raw_choice)
		return
	var/path = crafting_mapping_cache[raw_choice]
	var/list/data = crafting_items[path]
	var/scrap_cost = data[1]
	var/food_cost = data[2]

	if(available_scrap < scrap_cost || available_food < food_cost)
		to_chat(user, SPAN_WARNING("The nest does not have enough resources to make this!"))
		return

	if(!do_after(user, 5 SECONDS, target = src))
		return

	available_scrap -= scrap_cost
	available_food -= food_cost

	if(data.len >= 3)
		new path(get_turf(src), data[3])
	else
		new path(get_turf(src))

/obj/structure/uplifted_primitive/nest/proc/build_crafting_caches()
	var/choices = list()
	var/mapping = list()
	for(var/path in crafting_items)
		var/list/data = crafting_items[path]
		var/list/costs = list()

		if(data[1] > 0)
			costs += "[data[1]] scrap"
		if(data[2] > 0)
			costs += "[data[2]] food"

		var/key = "[path:name] ([costs.Join(", ")])"
		choices[key] = image(icon = path:icon, icon_state = path:icon_state)
		mapping[key] = path
	crafting_choices_cache = choices
	crafting_mapping_cache = mapping

/obj/structure/uplifted_primitive/nest/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!user.mind || !user.mind.has_antag_datum(/datum/antagonist/uplifted_primitive))
		return NONE

	// mobs of other uplifted species should be able to interact normally
	if(user.dna.species.type != nest_species)
		return NONE

	if(user.a_intent != INTENT_HELP)
		return NONE

	if(used.resistance_flags & INDESTRUCTIBLE)
		to_chat(user, SPAN_WARNING("You don't think it's a good idea to put [used] in the nest."))
		return ITEM_INTERACT_COMPLETE

	var/potential_scrap = 0
	var/potential_food = 0
	if(used.materials && length(used.materials) > 0)
		for(var/mat in used.materials)
			potential_scrap += used.materials[mat]

	if(used.reagents)
		for(var/datum/reagent/consumable/C in used.reagents.reagent_list)
			if(nest_species.dietflags & C.diet_flags)
				potential_food += C.nutriment_factor

	var/obj/item/uplifted/nest_bundle/scrap_ball = used
	if(istype(scrap_ball))
		potential_scrap += scrap_ball.scrap
		potential_food += scrap_ball.food

	var/obj/item/stack/pile = used
	var/multiplier = istype(pile) ? pile.amount : 1

	if(potential_scrap == 0 && potential_food == 0)
		to_chat(user, SPAN_WARNING("[used] does not seem suitable to disassemble or place in the nest."))
		return ITEM_INTERACT_COMPLETE

	user.visible_message(
		SPAN_WARNING("[user] starts finding a place to put [used] in the nest."),
		SPAN_NOTICE("You start finding a place to put [used] in the nest.")
	)

	if(!do_after(user, multiplier SECONDS, target = src))
		return ITEM_INTERACT_COMPLETE

	if(potential_scrap > 0)
		to_chat(user, SPAN_NOTICE("You dismantle [used] and place the scrap around the nest."))
		available_scrap += potential_scrap * multiplier

	if(potential_food > 0)
		to_chat(user, SPAN_NOTICE("You place the edible parts of [used] in the nest."))
		available_food += potential_food * multiplier

	qdel(used)

	return ITEM_INTERACT_COMPLETE

/obj/structure/uplifted_primitive/nest/play_attack_sound(damage_amount, damage_type, damage_flag)
	if(!damage_amount)
		return

	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/weapons/slash.ogg', 80, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/uplifted_primitive/nest/proc/rally_retaliation(atom/source, atom/attacker, flags)
	SIGNAL_HANDLER
	if(!istype(attacker, /mob/living) || !(flags & ATTACKER_DAMAGING_ATTACK))
		return
	for(var/mob/living/carbon/human/defender in oview(src, 7))
		if(defender.mind || defender.dna.species.type != nest_species)
			continue
		if(defender == attacker) // Do not commit suicide attacking yourself
			continue

		var/datum/ai_controller/monkey/M = defender.ai_controller
		if(istype(M))
			M.retaliate(attacker)

#undef INTEGRITY_REGEN_AMOUNT
#undef INTEGRITY_REGEN_SCRAP_COST
#undef SPAWN_SCRAP_COST
#undef SPAWN_FOOD_COST
#undef SPAWN_COOLDOWN_TIME
#undef SPAWN_SENTIENT_PROB_INCREASE
#undef SPAWN_MAX_LIMIT
#undef SPAWN_EXTRA_NEST_MOBS
