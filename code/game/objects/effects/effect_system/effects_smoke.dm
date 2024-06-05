/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optionally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke
	name = "smoke"
	icon_state = "smoke"
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	opacity = TRUE
	anchored = FALSE
	plane = SMOKE_PLANE
	layer = FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/steps = 0
	var/lifetime = 10 SECONDS_TO_LIFE_CYCLES
	var/direction
	var/causes_coughing = FALSE

/obj/effect/particle_effect/smoke/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	RegisterSignal(src, list(COMSIG_MOVABLE_CROSSED, COMSIG_CROSSED_MOVABLE), PROC_REF(smoke_mob)) //If someone crosses the smoke or the smoke crosses someone
	GLOB.smokes_active++
	lifetime += rand(-1, 1)
	create_reagents(10)

/obj/effect/particle_effect/smoke/Destroy()
	animate(src, 2 SECONDS, alpha = 0, easing = EASE_IN | CIRCULAR_EASING)
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(src, list(COMSIG_MOVABLE_CROSSED, COMSIG_CROSSED_MOVABLE))
	GLOB.smokes_active--
	return ..()

/obj/effect/particle_effect/smoke/proc/fade_out(frames = 16)
	animate(src, 2 SECONDS, alpha = 0, easing = EASE_IN | CIRCULAR_EASING)

/obj/effect/particle_effect/smoke/proc/kill_smoke()
	STOP_PROCESSING(SSobj, src)
	INVOKE_ASYNC(src, PROC_REF(fade_out))
	QDEL_IN(src, 2 SECONDS)

/obj/effect/particle_effect/smoke/process()
	lifetime--
	if(lifetime < 1)
		kill_smoke()
		return FALSE
	if(steps >= 1)
		step(src,direction)
		steps--
	for(var/mob/living/carbon/M in range(1, src))
		smoke_mob(M)
	return TRUE

/obj/effect/particle_effect/smoke/proc/smoke_mob(mob/living/carbon/breather)
	SIGNAL_HANDLER //COMSIG_MOVABLE_CROSSED and COMSIG_CROSSED_MOVABLE
	if(!istype(breather))
		return FALSE
	if(lifetime < 1)
		return FALSE
	if(!breather.can_breathe_gas())
		return FALSE
	if(breather.smoke_delay)
		addtimer(CALLBACK(src, PROC_REF(remove_smoke_delay), breather), 1 SECONDS) //Sometimes during testing I'd somehow end up with a permanent smoke delay, so this is in case of that
		return FALSE
	if(reagents)
		reagents.trans_to(breather, reagents.total_volume)
	if(causes_coughing)
		breather.drop_item()
		breather.adjustOxyLoss(1)
		INVOKE_ASYNC(breather, TYPE_PROC_REF(/mob/living/carbon, emote), "cough")
	breather.smoke_delay++
	addtimer(CALLBACK(src, PROC_REF(remove_smoke_delay), breather), 1 SECONDS)
	return TRUE

/obj/effect/particle_effect/smoke/proc/remove_smoke_delay(mob/living/carbon/C)
	if(C)
		C.smoke_delay = 0

/datum/effect_system/smoke_spread
	effect_type = /obj/effect/particle_effect/smoke
	var/datum/reagents/chemicals_to_add
	var/units_per_smoke = 0
	var/direction

/datum/effect_system/smoke_spread/set_up(amount = 5, only_cardinals = FALSE, source, desired_direction, datum/reagents/chemicals = null)
	number = clamp(amount, 0, 20)
	cardinals = only_cardinals
	location = get_turf(source)
	if(desired_direction)
		direction = desired_direction
	if(chemicals)
		chemicals_to_add = chemicals
		units_per_smoke = clamp((chemicals_to_add.total_volume / number), 0, 10)

/datum/effect_system/smoke_spread/start()
	var/smoke_budget = GLOBAL_SMOKE_LIMIT - GLOB.smokes_active
	if(smoke_budget < number) //Dream blunt rotation scenario
		return
	for(var/i in 1 to number)
		if(holder)
			location = get_turf(holder)
		var/obj/effect/particle_effect/smoke/S = new effect_type(location, (chemicals_to_add ? TRUE : FALSE))
		if(chemicals_to_add)
			chemicals_to_add.copy_to(S, units_per_smoke)
			S.color = mix_color_from_reagents(chemicals_to_add.reagent_list)
		if(!direction)
			if(cardinals)
				S.direction = pick(GLOB.cardinal)
			else
				S.direction = pick(GLOB.alldirs)
		else
			S.direction = direction
		S.steps = pick(0,1,1,1,2,2,2,3)
		S.process()

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/bad
	lifetime = 16 SECONDS_TO_LIFE_CYCLES
	causes_coughing = TRUE

/obj/effect/particle_effect/smoke/bad/CanPass(atom/movable/mover, turf/target, height = 0)
	if(!height)
		return TRUE
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage / 2)
	return TRUE

/datum/effect_system/smoke_spread/bad
	effect_type = /obj/effect/particle_effect/smoke/bad

/////////////////////////////////////////////
// Nanofrost smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/freezing
	name = "nanofrost smoke"
	color = "#B2FFFF"
	opacity = FALSE

/datum/effect_system/smoke_spread/freezing
	effect_type = /obj/effect/particle_effect/smoke/freezing
	var/blast = FALSE

/datum/effect_system/smoke_spread/freezing/proc/Chilled(atom/A)
	if(issimulatedturf(A))
		var/turf/simulated/T = A
		if(T.air)
			var/datum/gas_mixture/G = T.air
			if(get_dist(T, src) < 2) // Otherwise we'll get silliness like people using Nanofrost to kill people through walls with cold air
				G.temperature = 2
			T.air_update_turf()
			for(var/obj/effect/hotspot/H in T)
				qdel(H)
				if(G.toxins)
					G.nitrogen += (G.toxins)
					G.toxins = 0
		for(var/obj/machinery/atmospherics/unary/vent_pump/V in T)
			if(!isnull(V.welded) && !V.welded) //must be an unwelded vent pump.
				V.welded = TRUE
				V.update_icon()
				V.visible_message("<span class='danger'>[V] was frozen shut!</span>")
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/U in T)
			if(!isnull(U.welded) && !U.welded) //must be an unwelded vent scrubber.
				U.welded = TRUE
				U.update_icon()
				U.visible_message("<span class='danger'>[U] was frozen shut!</span>")
		for(var/mob/living/L in T)
			L.ExtinguishMob()
		for(var/obj/item/Item in T)
			Item.extinguish()

/datum/effect_system/smoke_spread/freezing/set_up(amount = 5, only_cardinals = FALSE, source, desired_direction, datum/reagents/chemicals, blasting = FALSE)
	..()
	blast = blasting

/datum/effect_system/smoke_spread/freezing/start()
	if(blast)
		for(var/turf/T in RANGE_TURFS(2, location))
			Chilled(T)
	..()

/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/sleeping
	color = "#9C3636"
	lifetime = 20 SECONDS_TO_LIFE_CYCLES
	causes_coughing = TRUE

/obj/effect/particle_effect/smoke/sleeping/process()
	if(..())
		for(var/mob/living/carbon/M in range(1,src))
			smoke_mob(M)

/obj/effect/particle_effect/smoke/sleeping/smoke_mob(mob/living/carbon/M)
	if(..())
		M.Sleeping(20 SECONDS)
		return TRUE

/datum/effect_system/smoke_spread/sleeping
	effect_type = /obj/effect/particle_effect/smoke/sleeping

////////////////////////////////////
// See-through smoke
///////////////////////////////////
/obj/effect/particle_effect/smoke/transparent
	opacity = FALSE
	alpha = 125

/datum/effect_system/smoke_spread/transparent
	effect_type = /obj/effect/particle_effect/smoke/transparent
