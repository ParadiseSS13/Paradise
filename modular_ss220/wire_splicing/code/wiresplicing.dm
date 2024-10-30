#define MAX_MESSINESS 10
#define WALKING_REDUCE_PROBABILITY 50

/obj/effect/spawner/wire_splicing
	name = "wiring splicing spawner"
	icon = 'modular_ss220/wire_splicing/icons/structures_spawners.dmi'
	icon_state = "wire_splicing"
	/// From 0 to 100
	var/spawn_probability = 100

/obj/effect/spawner/wire_splicing/Initialize(mapload)
	. = ..()
	if(prob(spawn_probability))
		new /obj/structure/wire_splicing(get_turf(src))
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/wire_splicing/thirty
	name = "wiring splicing spawner 30%"
	spawn_probability = 30

/obj/structure/wire_splicing
	name = "wire splicing"
	desc = "Looks like someone was very drunk when doing this, or just didn't care. This can be removed by wirecutters."
	icon = 'modular_ss220/wire_splicing/icons/traps.dmi'
	icon_state = "wire_splicing1"
	density = FALSE
	anchored = TRUE
	flags = CONDUCT
	layer = WIRE_TERMINAL_LAYER
	/// How bad the splicing was, determines the chance of shock
	var/messiness = 0
	var/shock_chance_per_messiness = 10

/obj/structure/wire_splicing/Initialize(mapload)
	. = ..()
	messiness = rand(1, MAX_MESSINESS)
	update_icon(UPDATE_ICON_STATE)

	// At messiness of 2 or below, triggering when walking on a catwalk is impossible
	// Above that it becomes possible, so we will change the layer to make it poke through catwalks
	if(messiness > 2)
		layer = LOW_OBJ_LAYER  // I wont do such stuff on splicing "reinforcement". Take it as nasty feature

	// Wire splice can only exist on a cable. Lets try to place it in a good location
	if(locate(/obj/structure/cable) in get_turf(src)) // If we're already in a good location, no problem!
		return

	// Make a list of turfs with cables in them
	var/list/candidates = list()

	// We will give each turf a score to determine its suitability
	var/best_score = -INFINITY
	for(var/obj/structure/cable/C in range(3, get_turf(src)))
		var/turf/simulated/floor/T = get_turf(C)

		// Wire inside a wall? can't splice there
		if(!istype(T))
			continue

		// We already checked this one
		if(T in candidates)
			continue

		var/turf_score = 0

		// Nobody walks on underplating so we don't want to place traps there

		var/turf/space/W = get_turf(C)
		if(!istype(W))
			continue //No traps in space

		/*
		// Catwalks are made for walking on, we definitely want traps there
		if(locate(/obj/structure/catwalk) in T)
			turf_score += 2
		*/

		// If its below the threshold ignore it
		if(turf_score < best_score)
			continue

		// If it sets a new threshold, discard everything before
		else if(turf_score > best_score)
			best_score = turf_score
			candidates.Cut()

		candidates.Add(T)

	// No nearby cables? Cancel
	if(!length(candidates))
		return INITIALIZE_HINT_QDEL

	loc = pick(candidates)

/obj/structure/wire_splicing/update_icon_state()
	icon_state = "wire_splicing[messiness]"

/obj/structure/wire_splicing/examine(mob/user)
	. = ..()
	. += span_warning("It has [messiness] wire[messiness > 1 ? "s" : ""] dangling around.")

/obj/structure/wire_splicing/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM))
		var/chance_to_shock = messiness * shock_chance_per_messiness
		/*
		var/turf/T = get_turf(src)
		if(locate(/obj/structure/catwalk) in T)
			chance_to_shock -= 20
		*/
		shock(AM, chance_to_shock)

/obj/structure/wire_splicing/proc/shock(mob/living/user, prb, siemens_coeff = 1)
	. = FALSE
	// To prevent TK and mech users from getting shocked
	if(!in_range(src, user))
		return
	// To prevent simple mobs to be shocked
	if(!ishuman(user))
		return
	// Walk slowly to try to step over
	if(user.m_intent == MOVE_INTENT_WALK)
		prb = max(prb - WALKING_REDUCE_PROBABILITY, 0)
	if(!prob(prb))
		return
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = locate(/obj/structure/cable) in T
	if(!C)
		return
	if(electrocute_mob(user, C.powernet, src, siemens_coeff))
		do_sparks(5, TRUE, src)
		. = TRUE

/obj/structure/wire_splicing/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return
	if(shock(user, 50))
		return
	user.visible_message(
		span_notice("[user] cuts the splicing."),
		span_notice("You cut the splicing."))
	investigate_log("was cut by [key_name(usr)] in [AREACOORD(src)]", "wires")
	qdel(src)

/obj/structure/wire_splicing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/cable_coil) && user.a_intent == INTENT_HARM)
		var/obj/item/stack/cable_coil/coil = I
		reinforce(user, coil)
		return
	. = ..()

/obj/structure/wire_splicing/proc/reinforce(mob/user, obj/item/stack/cable_coil/coil)
	if(messiness >= MAX_MESSINESS)
		to_chat(user, span_warning("You can't seem to jam more cable into the splicing!"))
		return
	if(!do_after(user, 2 SECONDS, target = src, progress = TRUE))
		return
	if(messiness >= MAX_MESSINESS)
		return
	messiness = min(messiness + 1, MAX_MESSINESS)
	coil.use(1)
	update_icon(UPDATE_ICON_STATE)
	investigate_log("was reinforced to [messiness] by [key_name(usr)] in [AREACOORD(src)]", "wires")

#undef MAX_MESSINESS
#undef WALKING_REDUCE_PROBABILITY
