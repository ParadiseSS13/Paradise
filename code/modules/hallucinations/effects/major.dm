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
