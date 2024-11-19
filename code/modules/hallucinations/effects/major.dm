/**
  * # Hallucination - Terror Infestation
  *
  * Creates spider webs and a terror spider near a random vent around the target.
  */
/obj/effect/hallucination/terror_infestation
	duration = 30 SECONDS

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

	new /obj/effect/hallucination/chaser/attacker/terror_spider(get_turf(vent), target)

/obj/effect/hallucination/chaser/attacker/terror_spider
	hallucination_icon = 'icons/mob/terrorspider.dmi'
	hallucination_icon_state = "terror_green"
	duration = 30 SECONDS
	damage = 25

/obj/effect/hallucination/chaser/attacker/terror_spider/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	name = "Green Terror spider ([rand(100, 999)])"

/obj/effect/hallucination/chaser/attacker/terror_spider/attack_effects()
	do_attack_animation(target, ATTACK_EFFECT_BITE)
	target.playsound_local(get_turf(src), 'sound/weapons/bite.ogg', 50, TRUE)
	to_chat(target, "<span class='userdanger'>[name] bites you!</span>")

/obj/effect/hallucination/chaser/attacker/terror_spider/on_knockdown()
	target.visible_message("<span class='warning'>[target] recoils as if hit by something, before suddenly collapsing!</span>",
						"<span class='userdanger'>[name] bites you!</span>")

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

/obj/effect/hallucination/tripper/spider_web/attackby(obj/item/I, mob/user, params)
	if(user != target)
		return

	step_towards(target, get_turf(src))
	target.Weaken(4 SECONDS)
	target.visible_message("<span class='warning'>[target] flails [target.p_their()] [I.name] as if striking something, only to trip!</span>",
						"<span class='userdanger'>[src] vanishes as you strike it with [I], causing you to stumble forward!</span>")
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
	addtimer(CALLBACK(src, PROC_REF(do_spawn_scientist), T), 4 SECONDS)
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

/**
  * # Hallucination - Loose Energy Ball
  *
  * A progressive hallucination that begins with intermittent explosions, before displaying an energy ball that shocks the target.
  */
/obj/effect/hallucination/loose_energy_ball
	duration = 30 SECONDS
	/// Length of phase 1 in deciseconds.
	var/length_phase_1 = 10 SECONDS
	/// Length of phase 2 in deciseconds.
	var/length_phase_2 = 10 SECONDS
	/// Length of phase 3 in deciseconds.
	var/length_phase_3 = 6 SECONDS

/obj/effect/hallucination/loose_energy_ball/Initialize(mapload)
	. = ..()
	phase_1()
	addtimer(CALLBACK(src, PROC_REF(phase_2)), length_phase_1)
	addtimer(CALLBACK(src, PROC_REF(phase_3)), length_phase_1 + length_phase_2)

/**
  * First phase of the hallucination: intermittent, far-away explosion sounds.
  */
/obj/effect/hallucination/loose_energy_ball/proc/phase_1()
	for(var/i in 0 to (length_phase_1 / 20) - 1)
		play_sound_in(i * 2 SECONDS, null, 'sound/effects/explosionfar.ogg', min(50 + i * 5, 100))

/**
  * Second phase of the hallucination: closer explosions and zap sounds from a random direction.
  */
/obj/effect/hallucination/loose_energy_ball/proc/phase_2()
	var/turf/source = get_step_rand(get_turf(target))
	for(var/i in 0 to (length_phase_2 / 20) - 1)
		if(prob(33))
			play_sound_in(i * 2 SECONDS, source, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), min(5 + i * 3, 100))
		play_sound_in(i * 2 SECONDS, source, 'sound/magic/lightningbolt.ogg', min(5 + i * 3, 100))

/**
  * Third and final phase of the hallucination: an energy ball that approaches the target before shocking it.
  */
/obj/effect/hallucination/loose_energy_ball/proc/phase_3()
	// Create the image
	var/image/ball = image('icons/obj/tesla_engine/energy_ball.dmi', src, "energy_ball")
	ball.layer = MASSIVE_OBJ_LAYER
	ball.plane = GAME_PLANE
	add_icon(ball)

	var/steps = (length_phase_3 / 20) - 1
	for(var/i in 0 to steps)
		addtimer(CALLBACK(src, PROC_REF(phase_3_inner), ball, steps - i, i), i * 2 SECONDS)

/**
  * Called during phase 3 to approach the energy ball towards the target.
  *
  * Arguments:
  * * ball - The energy ball image.
  * * distance - The remaining distance.
  * * step - The current step.
  */
/obj/effect/hallucination/loose_energy_ball/proc/phase_3_inner(image/ball, distance, step)
	if(QDELETED(ball) || QDELETED(target))
		return

	var/turf/T = get_turf(target)
	var/list/turfs = RANGE_TURFS(distance + 1, T) // expensive?
	var/turf/dest = pick(turfs) || T // uh oh

	ball.loc = dest
	target.playsound_local(dest, 'sound/magic/lightningbolt.ogg', 15 + step * 10)
	target.playsound_local(dest, 'sound/magic/lightningshock.ogg', 15 + step * 10)

	if(distance == 0)
		target.electrocute_act(100, src, flags = SHOCK_ILLUSION)

/**
  * # Hallucination - Assault
  *
  * An imaginary attacker spawns close to the target and attacks them to stamcrit.
  */
/obj/effect/hallucination/assault
	duration = 30 SECONDS
	/// The attacker hallucination.
	var/obj/effect/hallucination/chaser/attacker/assaulter/fake_attacker = null

/obj/effect/hallucination/assault/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	var/list/locs = list()
	for(var/turf/T in oview(world.view / 2, target))
		if(!is_blocked_turf(T))
			locs += T
	if(!length(locs))
		qdel(src)
		return

	// Spawn attacker
	var/turf/T = pick(locs)
	fake_attacker = new(T, target)

/obj/effect/hallucination/chaser/attacker/assaulter
	duration = 30 SECONDS
	damage = 40
	/// The attack verb to display.
	var/attack_verb = "punches"
	/// The attack sound to play. Can be a file or text (passed to [/proc/get_sfx]).
	var/attack_sound = "punch"

/obj/effect/hallucination/chaser/attacker/assaulter/Initialize(mapload, mob/living/carbon/target)
	var/new_name
	// 80% chance to use a simple human sprite
	if(prob(80))
		new_name = "Unknown"
		hallucination_icon = 'icons/mob/simple_human.dmi'
		hallucination_icon_state = pick("arctic_skeleton", "templar", "skeleton", "sovietmelee", "piratemelee", "plasma_miner_tool", "cat_butcher", "syndicate_space_sword", "syndicate_stormtrooper_sword", "zombie", "scary_clown")

		// Adjust the attack verb and sound depending on the "mob"
		switch(hallucination_icon_state)
			if("arctic_skeleton", "templar", "sovietmelee", "plasma_miner_tool")
				attack_verb = "slashed"
				attack_sound = 'sound/weapons/bladeslice.ogg'
			if("cat_butcher")
				attack_verb = "sawed"
				attack_sound = 'sound/weapons/circsawhit.ogg'
			if("piratemelee", "syndicate_space_sword", "syndicate_stormtrooper_sword")
				attack_verb = "slashed"
				attack_sound = 'sound/weapons/blade1.ogg'

	// If nothing else we'll stay a monke
	. = ..()
	name = new_name || name

/obj/effect/hallucination/chaser/attacker/assaulter/attack_effects()
	do_attack_animation(target)
	target.playsound_local(get_turf(src), istext(attack_sound) ? get_sfx(attack_sound) : attack_sound, 25, TRUE)
	to_chat(target, "<span class='userdanger'>[name] has [attack_verb] [target]!</span>")

/obj/effect/hallucination/chaser/attacker/assaulter/on_knockdown()
	target.visible_message("<span class='warning'>[target] recoils as if hit by something, before suddenly collapsing!</span>",
						"<span class='userdanger'>[name] has [attack_verb] [target]!</span>")
	QDEL_IN(src, 3 SECONDS)

/**
  * # Hallucination - Xeno Pounce
  *
  * An imaginary alien hunter pounces towards the target.
  */
/obj/effect/hallucination/xeno_pounce
	duration = 15 SECONDS
	// Settings
	/// Maximum number of times the alien will pounce.
	var/num_pounces = 3
	/// How often to pounce in deciseconds.
	var/pounce_interval = 5 SECONDS
	// Variables
	/// The xeno hallucination reference.
	var/obj/effect/hallucination/xeno_pouncer/xeno = null

/obj/effect/hallucination/xeno_pounce/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	// Find a vent around us
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/vent in range(world.view / 2, target))
		vents += vent
	if(!length(vents))
		return

	var/turf/T = get_turf(pick(vents))
	xeno = new(T, target)
	xeno.dir = get_dir(T, target)
	addtimer(CALLBACK(src, PROC_REF(do_pounce)), pounce_interval)

/obj/effect/hallucination/xeno_pounce/proc/do_pounce()
	if(QDELETED(xeno) || QDELETED(target))
		return

	xeno.leap_to(target)
	if(--num_pounces > 0)
		addtimer(CALLBACK(src, PROC_REF(do_pounce)), pounce_interval)

/obj/effect/hallucination/xeno_pouncer
	hallucination_icon = 'icons/mob/alien.dmi'
	hallucination_icon_state = "alienh_pounce"
	hallucination_override = TRUE

/obj/effect/hallucination/xeno_pouncer/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	name = "\proper alien hunter ([rand(100, 999)])"

/obj/effect/hallucination/xeno_pouncer/throw_impact(A)
	if(A == target)
		forceMove(get_turf(target))
		target.Weaken(10 SECONDS)
		target.visible_message("<span class='danger'>[target] recoils backwards and falls flat!</span>",
							"<span class='userdanger'>[name] pounces on you!</span>")

		to_chat(target, "<span class='notice'>[name] begins climbing into the ventilation system...</span>")
		QDEL_IN(src, 2 SECONDS)

/**
  * Throws the xeno towards the given loc.
  *
  * Arguments:
  * * dest - The loc to leap to.
  */
/obj/effect/hallucination/xeno_pouncer/proc/leap_to(dest)
	if(images && images[1])
		images[1].icon = 'icons/mob/alienleap.dmi'
		images[1].icon_state = "alienh_leap"
	dir = get_dir(get_turf(src), dest)
	throw_at(dest, 7, 1, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, PROC_REF(reset_icon)))

/**
  * Resets the xeno's icon to a resting state.
  */
/obj/effect/hallucination/xeno_pouncer/proc/reset_icon()
	if(images && images[1])
		images[1].icon = 'icons/mob/alien.dmi'
		images[1].icon_state = "alienh_pounce"
