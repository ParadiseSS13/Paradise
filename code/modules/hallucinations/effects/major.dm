/**
  * # Hallucination - Terror Infestation
  *
  * Creates spider webs and a terror spider near a random vent around the target.
  */
/obj/effect/hallucination/terror_infestation

/obj/effect/hallucination/terror_infestation/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	// Find a vent around us
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/vent in range(world.view, target))
		vents += vent
	if(!length(vents))
		return

	// Spawn webs around a random vent
	var/obj/vent = pick(vents)
	for(var/t in RANGE_TURFS(1, vent))
		var/turf/T = t
		if(!isfloorturf(T))
			continue
		new /obj/effect/hallucination/tripper/spider_web(T, target)

	#warn TODO: create spooder

/**
  * # Hallucination - Spider Web
  *
  * A fake spider web that trips the target if crossed.
  */
/obj/effect/hallucination/tripper/spider_web
	name = "spider web"
	desc = "It's stringy and sticky."
	hallucination_icon = 'icons/effects/effects.dmi'
	hallucination_icon_state = "stickyweb1"
	hallucination_override = TRUE
	hallucination_layer = OBJ_LAYER
	trip_chance = 80

/obj/effect/hallucination/tripper/spider_web/Initialize(mapload, mob/living/carbon/target)
	if(prob(50))
		hallucination_icon_state = "stickyweb2"
	. = ..()

/obj/effect/hallucination/tripper/spider_web/on_crossed()
	target.visible_message("<span class='warning'>[target] trips over nothing.</span>",
					  	   "<span class='userdanger'>You get stuck in [src]!</span>")

/obj/effect/hallucination/tripper/spider_web/attackby(obj/item/W, mob/user, params)
	if(user != target)
		return

	step_towards(target, get_turf(src))
	target.Weaken(4 SECONDS_TO_LIFE_CYCLES)
	target.visible_message("<span class='warning'>[target] flails [target.p_their()] [W.name] as if striking something, only to trip!</span>",
					  	   "<span class='userdanger'>[src] vanishes as you strike it with [W], causing you to stumble forward!</span>")
	qdel(src)

/**
  * # Hallucination - Abduction
  *
  * Sends an abductor agent after the target. On knockdown, spawns an abductor scientist next to the target. Nothing else happens.
  */
/obj/effect/hallucination/abduction
	duration = 45 SECONDS
	/// The abductor agent hallucination.
	var/obj/effect/hallucination/chaser/attacker/abductor/agent = null
	/// The abductor scientist image handle.
	var/image/scientist = null

/obj/effect/hallucination/abduction/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	var/list/locs = list()
	for(var/turf/T in oview(world.view, target))
		if(!is_blocked_turf(T))
			locs += T
	if(!length(locs))
		qdel(src)
		return

	// Spawn agent
	var/turf/T = pick(locs)
	agent = new(T, target)
	agent.owning_hallucination = src

	// Teleport effect
	var/image/teleport_end = image('icons/mob/mob.dmi', T, "uncloak", layer = ABOVE_MOB_LAYER)
	teleport_end.plane = GAME_PLANE
	add_icon(teleport_end)
	clear_icon_in(teleport_end, 0.9 SECONDS)

/obj/effect/hallucination/abduction/Destroy()
	QDEL_NULL(agent)
	QDEL_NULL(scientist)
	return ..()

/**
  * Called when the fake abductor scientist should spawn.
  */
/obj/effect/hallucination/abduction/proc/spawn_scientist()
	// Find a spot for the scientist to spawn
	var/list/locs = list()
	for(var/turf/T in orange(1, target))
		if(!is_blocked_turf(T))
			locs += T
	locs -= get_turf(agent)
	if(!length(locs))
		qdel(src)
		return

	QDEL_IN(src, 10 SECONDS)

	var/turf/T = pick(locs)
	// Spawn the scientist in
	var/image/teleport = image('icons/obj/abductor.dmi', T, "teleport", layer = ABOVE_MOB_LAYER)
	teleport.plane = GAME_PLANE
	add_icon(teleport)
	clear_icon_in(teleport, 4 SECONDS)
	addtimer(CALLBACK(src, .proc/do_spawn_scientist, T), 4 SECONDS)
	playsound(T, "sparks", 100, TRUE)

/**
  * Timer called to actually spawn the scientist.
  *
  * Arguments:
  * * T - Where to spawn the scientist.
  */
/obj/effect/hallucination/abduction/proc/do_spawn_scientist(turf/T)
	if(QDELETED(target))
		qdel(src)
		return
	else if(scientist)
		return

	var/image/teleport_end = image('icons/mob/mob.dmi', T, "uncloak", layer = ABOVE_MOB_LAYER)
	teleport_end.plane = GAME_PLANE
	add_icon(teleport_end)
	clear_icon_in(teleport_end, 0.9 SECONDS)

	scientist = image('icons/mob/simple_human.dmi', T, "abductor_scientist", layer = MOB_LAYER)
	scientist.plane = GAME_PLANE
	scientist.dir = get_dir(T, target)
	add_icon(scientist)

/obj/effect/hallucination/chaser/attacker/abductor
	hallucination_icon = 'icons/mob/simple_human.dmi'
	hallucination_icon_state = "abductor_agent"
	duration = 45 SECONDS
	damage = 100
	/// The hallucination that spawned us.
	var/obj/effect/hallucination/abduction/owning_hallucination = null

/obj/effect/hallucination/chaser/attacker/abductor/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	name = "Unknown"

/obj/effect/hallucination/chaser/attacker/abductor/attack_effects()
	do_attack_animation(target)
	target.playsound_local(get_turf(src), 'sound/weapons/egloves.ogg', 50, TRUE)

/obj/effect/hallucination/chaser/attacker/abductor/on_knockdown()
	target.visible_message("<span class='warning'>[target] recoils as if hit by something, before suddenly collapsing!</span>",
						   "<span class='userdanger'>[name] has stunned you with the advanced baton!</span>")
	if(!QDELETED(owning_hallucination))
		owning_hallucination.spawn_scientist()
	else
		qdel(src)
