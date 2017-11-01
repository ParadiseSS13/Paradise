/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////

/obj/effect/effect/smoke
	name = "smoke"
	icon = 'icons/effects/water.dmi'
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 8.0

/obj/effect/effect/harmless_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/effect/harmless_smoke/New()
	..()
	spawn(100)
		delete()
	return

/obj/effect/effect/harmless_smoke/Move()
	..()
	return

/datum/effect/system/harmless_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effect/system/harmless_smoke_spread/set_up(n = 5, c = 0, loca, direct)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct

/datum/effect/system/harmless_smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/harmless_smoke/smoke = new /obj/effect/effect/harmless_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(75+rand(10,30))
				smoke.delete()
				src.total_smoke--

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/effect/bad_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/effect/bad_smoke/New()
	..()
	spawn(200+rand(10,30))
		delete()
	return

/obj/effect/effect/bad_smoke/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		if(M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
		else
			M.drop_item()
			M.adjustOxyLoss(1)
			if(M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					M.coughedtime = 0
	return

/obj/effect/effect/bad_smoke/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage/2)
	return 1

/obj/effect/effect/bad_smoke/Crossed(mob/living/carbon/M)
	..()
	if(iscarbon(M))
		if(M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
			return
		else
			M.drop_item()
			M.adjustOxyLoss(1)
			if(M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					M.coughedtime = 0
	return

/datum/effect/system/bad_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effect/system/bad_smoke_spread/set_up(n = 5, c = 0, loca, direct)
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

/datum/effect/system/bad_smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/bad_smoke/smoke = new /obj/effect/effect/bad_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(150+rand(10,30))
				smoke.delete()
				src.total_smoke--

/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////

/obj/effect/effect/chem_smoke
	name = "smoke"
	opacity = 0
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0

	icon = 'icons/effects/chemsmoke.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/effect/chem_smoke/New()
	..()
	spawn(200+rand(10,30))
		delete()
	return

/obj/effect/effect/chem_smoke/Move()
	..()

/datum/effect/system/chem_smoke_spread/New()
	..()
	chemholder = new/obj()
	var/datum/reagents/R = new/datum/reagents(500)
	chemholder.reagents = R
	R.my_atom = chemholder

/datum/effect/system/chem_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction
	var/obj/chemholder

/datum/effect/system/chem_smoke_spread/New()
	..()
	chemholder = new/obj()
	var/datum/reagents/R = new/datum/reagents(500)
	chemholder.reagents = R
	R.my_atom = chemholder

/datum/effect/system/chem_smoke_spread/Destroy()
	QDEL_NULL(chemholder)
	return ..()

/datum/effect/system/chem_smoke_spread/set_up(datum/reagents/carry = null, n = 5, c = 0, loca, direct, silent = 0)
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

/datum/effect/system/chem_smoke_spread/start(effect_range = 2)
	var/i = 0

	var/color = mix_color_from_reagents(chemholder.reagents.reagent_list)
	var/obj/effect/effect/chem_smoke/smokeholder = new /obj/effect/effect/chem_smoke(src.location)
	for(var/atom/A in view(effect_range, smokeholder))
		chemholder.reagents.reaction(A)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			if(C.can_breathe_gas())
				chemholder.reagents.copy_to(C, chemholder.reagents.total_volume)
	qdel(smokeholder)
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/chem_smoke/smoke = new /obj/effect/effect/chem_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
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
			spawn(150+rand(10,30))
				if(smoke)
					smoke.delete()
				src.total_smoke--

/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/effect/sleep_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	color = "#9C3636"

/obj/effect/effect/sleep_smoke/New()
	..()
	spawn(200+rand(10,30))
		delete()
	return

/obj/effect/effect/sleep_smoke/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		if(M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
//		if(M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal))  // I'll work on it later
		else
			M.drop_item()
			M.AdjustSleeping(5)
			if(M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return

/obj/effect/effect/sleep_smoke/Crossed(mob/living/carbon/M)
	..()
	if(istype(M, /mob/living/carbon))
		if(M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
//		if(M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal)) // Work on it later
			return
		else
			M.drop_item()
			M.AdjustSleeping(5)
			if(M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return

/datum/effect/system/sleep_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effect/system/sleep_smoke_spread/set_up(n = 5, c = 0, loca, direct)
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

/datum/effect/system/sleep_smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/sleep_smoke/smoke = new /obj/effect/effect/sleep_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(150+rand(10,30))
				smoke.delete()
				src.total_smoke--
