/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////

/obj/effect/effect/smoke
	name = "smoke"
	icon_state = "smoke"
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	opacity = 1
	anchored = 0
	mouse_opacity = 0
	var/time_to_live = 100

/obj/effect/effect/smoke/proc/fade_out(frames = 16)
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

/obj/effect/effect/smoke/New()
	..()
	QDEL_IN(src, time_to_live)
	return

/obj/effect/effect/smoke/Crossed(mob/living/M)
	if(!istype(M))
		return
	smoke_mob(M)

/obj/effect/effect/smoke/proc/smoke_mob(mob/living/carbon/C)
	if(!istype(C))
		return FALSE
	if(!C.can_breathe_gas())
		return FALSE
	return TRUE

/datum/effect/system/smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction
	var/smoke_type = /obj/effect/effect/smoke

/datum/effect/system/smoke_spread/set_up(n = 5, c = 0, loca, direct)
	if(n > 20)
		n = 20
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct

/datum/effect/system/smoke_spread/start()
	for(var/i=0, i<number, i++)
		if(total_smoke > 20)
			return
		spawn(0)
			if(holder)
				location = get_turf(holder)
			var/obj/effect/effect/smoke/S = new smoke_type(location)
			total_smoke++
			var/direction = src.direction
			if(!direction)
				if(cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(S,direction)
			spawn(S.time_to_live*0.75+rand(10,30))
				if(S)
					addtimer(S, "fade_out", 0)
					QDEL_IN(S, 10)
				total_smoke--

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/effect/smoke/bad
	time_to_live = 200

/obj/effect/effect/smoke/bad/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		smoke_mob(M)

/obj/effect/effect/smoke/bad/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage/2)
	return 1

/obj/effect/effect/smoke/bad/smoke_mob(mob/living/carbon/M)
	if(..())
		M.drop_item()
		M.adjustOxyLoss(1)
		if(M.coughedtime != 1)
			M.coughedtime = 1
			M.emote("cough")
			spawn(20)
				M.coughedtime = 0

/datum/effect/system/smoke_spread/bad
	smoke_type = /obj/effect/effect/smoke/bad

/////////////////////////////////////////////
// Nanofrost smoke
/////////////////////////////////////////////

/obj/effect/effect/smoke/freezing
	name = "nanofrost smoke"
	color = "#B2FFFF"
	opacity = 0

/datum/effect/system/smoke_spread/freezing
	smoke_type = /obj/effect/effect/smoke/freezing
	var/blast = 0

/datum/effect/system/smoke_spread/freezing/proc/Chilled(atom/A)
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

/datum/effect/system/smoke_spread/freezing/set_up(n = 5, c = 0, loca, direct, blasting = 0)
	..()
	blast = blasting

/datum/effect/system/smoke_spread/freezing/start()
	if(blast)
		for(var/turf/T in RANGE_TURFS(2, location))
			Chilled(T)
	..()

/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/effect/smoke/sleeping
	color = "#9C3636"
	time_to_live = 200

/obj/effect/effect/smoke/sleeping/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		smoke_mob(M)

/obj/effect/effect/smoke/sleeping/smoke_mob(mob/living/carbon/M)
	if(..())
		M.drop_item()
		M.AdjustSleeping(5)
		if(M.coughedtime != 1)
			M.coughedtime = 1
			M.emote("cough")
			spawn(20)
				if(M && M.loc)
					M.coughedtime = 0

/datum/effect/system/smoke_spread/sleeping
	smoke_type = /obj/effect/effect/smoke/sleeping

/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////

/obj/effect/effect/smoke/chem
	icon = 'icons/effects/chemsmoke.dmi'
	opacity = 0
	time_to_live = 200

/datum/effect/system/smoke_spread/chem
	smoke_type = /obj/effect/effect/smoke/chem
	var/obj/chemholder

/datum/effect/system/smoke_spread/chem/New()
	..()
	chemholder = new/obj()
	var/datum/reagents/R = new/datum/reagents(500)
	chemholder.reagents = R
	R.my_atom = chemholder

/datum/effect/system/smoke_spread/chem/Destroy()
	QDEL_NULL(chemholder)
	return ..()

/datum/effect/system/smoke_spread/chem/set_up(datum/reagents/carry = null, n = 5, c = 0, loca, direct, silent = 0)
	if(n > 20)
		n = 20
	number = n
	cardinals = c
	carry.copy_to(chemholder, carry.total_volume)

	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct
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
				msg_admin_attack("A chemical smoke reaction has taken place in ([whereLink])[contained]. Last associated key is [carry.my_atom.fingerprintslast][more].", 0, 1)
				log_game("A chemical smoke reaction has taken place in ([where])[contained]. Last associated key is [carry.my_atom.fingerprintslast].")
			else
				msg_admin_attack("A chemical smoke reaction has taken place in ([whereLink]). No associated key.", 0, 1)
				log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key.")
		else
			msg_admin_attack("A chemical smoke reaction has taken place in ([whereLink]). No associated key. CODERS: carry.my_atom may be null.", 0, 1)
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key. CODERS: carry.my_atom may be null.")

/datum/effect/system/smoke_spread/chem/start(effect_range = 2)
	var/color = mix_color_from_reagents(chemholder.reagents.reagent_list)
	var/obj/effect/effect/smoke/chem/smokeholder = new smoke_type(location)
	for(var/atom/A in view(effect_range, smokeholder))
		chemholder.reagents.reaction(A)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			if(C.can_breathe_gas())
				chemholder.reagents.copy_to(C, chemholder.reagents.total_volume)
	qdel(smokeholder)
	for(var/i=0, i<number, i++)
		if(total_smoke > 20)
			return
		spawn(0)
			if(holder)
				location = get_turf(holder)
			var/obj/effect/effect/smoke/chem/smoke = new smoke_type(location)
			total_smoke++
			var/direction = src.direction
			if(!direction)
				if(cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)

			if(color)
				smoke.icon += color // give the smoke color, if it has any to begin with
			else
				// if no color, just use the old smoke icon
				smoke.icon = 'icons/effects/96x96.dmi'
				smoke.icon_state = "smoke"
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(smoke.time_to_live*0.75+rand(10,30))
				if(smoke)
					addtimer(smoke, "fade_out", 0)
					QDEL_IN(smoke, 10)
				total_smoke--
