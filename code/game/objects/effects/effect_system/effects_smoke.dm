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
	opacity = 1
	anchored = 0
	var/steps = 0
	var/lifetime = 5
	var/direction

/obj/effect/particle_effect/smoke/proc/fade_out(frames = 16)
	if(alpha == 0) //Handle already transparent case
		return
	if(frames == 0)
		frames = 1 //We will just assume that by 0 frames, the coder meant "during one frame".
	var/step = alpha / frames
	for(var/i = 0, i < frames, i++)
		alpha -= step
		if(alpha < 160)
			set_opacity(0)
		stoplag()

/obj/effect/particle_effect/smoke/New()
	..()
	processing_objects |= src
	lifetime += rand(-1,1)

/obj/effect/particle_effect/smoke/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/effect/particle_effect/smoke/proc/kill_smoke()
	processing_objects.Remove(src)
	INVOKE_ASYNC(src, .proc/fade_out)
	QDEL_IN(src, 10)

/obj/effect/particle_effect/smoke/process()
	lifetime--
	if(lifetime < 1)
		kill_smoke()
		return 0
	if(steps >= 1)
		step(src,direction)
		steps--
	return 1

/obj/effect/particle_effect/smoke/Crossed(mob/living/M)
	if(!istype(M))
		return
	smoke_mob(M)

/obj/effect/particle_effect/smoke/proc/smoke_mob(mob/living/carbon/C)
	if(!istype(C))
		return FALSE
	if(lifetime<1)
		return FALSE
	if(!C.can_breathe_gas())
		return FALSE
	if(C.smoke_delay)
		return FALSE
	C.smoke_delay++
	addtimer(CALLBACK(src, .proc/remove_smoke_delay, C), 10)
	return TRUE

/obj/effect/particle_effect/smoke/proc/remove_smoke_delay(mob/living/carbon/C)
	if(C)
		C.smoke_delay = 0

/datum/effect_system/smoke_spread
	effect_type = /obj/effect/particle_effect/smoke
	var/direction

/datum/effect_system/smoke_spread/set_up(n = 5, c = 0, loca, direct)
	if(n > 20)
		n = 20
	number = n
	cardinals = c
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct

/datum/effect_system/smoke_spread/start()
	for(var/i=0, i<number, i++)
		if(holder)
			location = get_turf(holder)
		var/obj/effect/particle_effect/smoke/S = new effect_type(location)
		if(!direction)
			if(cardinals)
				S.direction = pick(cardinal)
			else
				S.direction = pick(alldirs)
		else
			S.direction = direction
		S.steps = pick(0,1,1,1,2,2,2,3)
		S.process()

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/bad
	lifetime = 8

/obj/effect/particle_effect/smoke/bad/process()
	if(..())
		for(var/mob/living/carbon/M in range(1,src))
			smoke_mob(M)

/obj/effect/particle_effect/smoke/bad/smoke_mob(mob/living/carbon/M)
	if(..())
		M.drop_item()
		M.adjustOxyLoss(1)
		M.emote("cough")
		return 1

/obj/effect/particle_effect/smoke/bad/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage/2)
	return 1

/datum/effect_system/smoke_spread/bad
	effect_type = /obj/effect/particle_effect/smoke/bad

/////////////////////////////////////////////
// Nanofrost smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/freezing
	name = "nanofrost smoke"
	color = "#B2FFFF"
	opacity = 0

/datum/effect_system/smoke_spread/freezing
	effect_type = /obj/effect/particle_effect/smoke/freezing
	var/blast = 0

/datum/effect_system/smoke_spread/freezing/proc/Chilled(atom/A)
	if(istype(A, /turf/simulated))
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
				V.welded = 1
				V.update_icon()
				V.visible_message("<span class='danger'>[V] was frozen shut!</span>")
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/U in T)
			if(!isnull(U.welded) && !U.welded) //must be an unwelded vent scrubber.
				U.welded = 1
				U.update_icon()
				U.visible_message("<span class='danger'>[U] was frozen shut!</span>")
		for(var/mob/living/L in T)
			L.ExtinguishMob()
		for(var/obj/item/Item in T)
			Item.extinguish()

/datum/effect_system/smoke_spread/freezing/set_up(n = 5, c = 0, loca, direct, blasting = 0)
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
	lifetime = 10

/obj/effect/particle_effect/smoke/sleeping/process()
	if(..())
		for(var/mob/living/carbon/M in range(1,src))
			smoke_mob(M)

/obj/effect/particle_effect/smoke/sleeping/smoke_mob(mob/living/carbon/M)
	if(..())
		M.drop_item()
		M.Sleeping(max(M.sleeping,10))
		M.emote("cough")
		return 1

/datum/effect_system/smoke_spread/sleeping
	effect_type = /obj/effect/particle_effect/smoke/sleeping

/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/chem
	icon = 'icons/effects/chemsmoke.dmi'
	opacity = 0
	lifetime = 10

/datum/effect_system/smoke_spread/chem
	effect_type = /obj/effect/particle_effect/smoke/chem
	var/obj/chemholder

/datum/effect_system/smoke_spread/chem/New()
	..()
	chemholder = new/obj()
	var/datum/reagents/R = new/datum/reagents(500)
	chemholder.reagents = R
	R.my_atom = chemholder

/datum/effect_system/smoke_spread/chem/Destroy()
	QDEL_NULL(chemholder)
	return ..()

/datum/effect_system/smoke_spread/chem/set_up(datum/reagents/carry = null, n = 5, c = 0, loca, direct, silent = 0)
	if(n > 20)
		n = 20
	number = n
	cardinals = c

	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct
	carry.copy_to(chemholder, carry.total_volume)
	if(!silent)
		var/contained = ""
		for(var/reagent in carry.reagent_list)
			contained += " [reagent] "
		if(contained)
			contained = "\[[contained]\]"
		var/area/A = get_area(location)

		var/where = "[A.name] | [location.x], [location.y]"
		var/whereLink = "<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>[where]</a>"

		if(carry && carry.my_atom)
			if(carry.my_atom.fingerprintslast)
				var/mob/M = get_mob_by_key(carry.my_atom.fingerprintslast)
				var/more = ""
				if(M)
					more = " "
				msg_admin_attack("A chemical smoke reaction has taken place in ([whereLink])[contained]. Last associated key is [carry.my_atom.fingerprintslast][more].", ATKLOG_FEW)
				log_game("A chemical smoke reaction has taken place in ([where])[contained]. Last associated key is [carry.my_atom.fingerprintslast].")
			else
				msg_admin_attack("A chemical smoke reaction has taken place in ([whereLink]). No associated key.", ATKLOG_FEW)
				log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key.")
		else
			msg_admin_attack("A chemical smoke reaction has taken place in ([whereLink]). No associated key. CODERS: carry.my_atom may be null.", ATKLOG_FEW)
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key. CODERS: carry.my_atom may be null.")

/datum/effect_system/smoke_spread/chem/start(effect_range = 2)
	var/color = mix_color_from_reagents(chemholder.reagents.reagent_list)
	var/obj/effect/particle_effect/smoke/chem/smokeholder = new effect_type(location)
	for(var/atom/A in view(effect_range, smokeholder))
		chemholder.reagents.reaction(A)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			if(C.can_breathe_gas())
				chemholder.reagents.copy_to(C, chemholder.reagents.total_volume)
	qdel(smokeholder)
	for(var/i=0, i<number, i++)
		if(holder)
			location = get_turf(holder)
		var/obj/effect/particle_effect/smoke/chem/S = new effect_type(location)
		if(!direction)
			if(cardinals)
				S.direction = pick(cardinal)
			else
				S.direction = pick(alldirs)
		else
			S.direction = direction

		S.steps = pick(0,1,1,1,2,2,2,3)

		if(color)
			S.icon += color // give the smoke color, if it has any to begin with
		else
			// if no color, just use the old smoke icon
			S.icon = 'icons/effects/96x96.dmi'
			S.icon_state = "smoke"
		S.process()
