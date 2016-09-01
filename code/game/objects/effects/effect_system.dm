/* This is an attempt to make some easily reusable "particle" type effect, to stop the code
constantly having to be rewritten. An item like the jetpack that uses the ion_trail_follow system, just has one
defined, then set up when it is created with New(). Then this same system can just be reused each time
it needs to create more trails.A beaker could have a steam_trail_follow system set up, then the steam
would spawn and follow the beaker, even if it is carried or thrown.
*/


/obj/effect/effect
	name = "effect"
	icon = 'icons/effects/effects.dmi'
	mouse_opacity = 0
	unacidable = 1//So effect are not targeted by alien acid.

/obj/effect/effect/New()
	..()
	if(ticker)
		cameranet.updateVisibility(src)

/obj/effect/effect/Destroy()
	if(ticker)
		cameranet.updateVisibility(src)
	return ..()

/datum/effect/proc/fadeOut(var/atom/A, var/frames = 16)
	if(A.alpha == 0) //Handle already transparent case
		return
	if(frames == 0)
		frames = 1 //We will just assume that by 0 frames, the coder meant "during one frame".
	var/step = A.alpha / frames
	for(var/i = 0, i < frames, i++)
		A.alpha -= step
		sleep(world.tick_lag)
	return

/obj/effect/effect/water
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	var/life = 15.0
	mouse_opacity = 0

/obj/effect/effect/smoke
	name = "smoke"
	icon = 'icons/effects/water.dmi'
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 8.0

/obj/effect/proc/delete()
	qdel(src)


/obj/effect/effect/water/New()
	..()
	//var/turf/T = src.loc
	//if(istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX
	spawn( 70 )
		delete()
		return
	return

/obj/effect/effect/water/Move(turf/newloc)
	//var/turf/T = src.loc
	//if(istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX
	if(--src.life < 1)
		//SN src = null
		delete()
	if(newloc.density)
		return 0
	.=..()

/obj/effect/effect/water/Bump(atom/A)
	if(reagents)
		reagents.reaction(A)
	if(istype(A,/atom/movable))
		var/atom/movable/AM = A
		AM.water_act(life, 310.15, src)
	return ..()


/datum/effect/system
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/setup = 0

	Destroy()
		holder = null
		location = null
		return ..()

	proc/set_up(n = 3, c = 0, turf/loc)
		if(n > 10)
			n = 10
		number = n
		cardinals = c
		location = loc
		setup = 1

	proc/attach(atom/atom)
		holder = atom

	proc/start()


/////////////////////////////////////////////
// GENERIC STEAM SPREAD SYSTEM

//Usage: set_up(number of bits of steam, use North/South/East/West only, spawn location)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like a smoking beaker, so then you can just call start() and the steam
// will always spawn at the items location, even if it's moved.

/* Example:
var/datum/effect/system/steam_spread/steam = new /datum/effect/system/steam_spread() -- creates new system
steam.set_up(5, 0, mob.loc) -- sets up variables
OPTIONAL: steam.attach(mob)
steam.start() -- spawns the effect
*/
/////////////////////////////////////////////
/obj/effect/effect/steam
	name = "steam"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	density = 0

/datum/effect/system/steam_spread

	set_up(n = 3, c = 0, turf/loc)
		if(n > 10)
			n = 10
		number = n
		cardinals = c
		location = loc

	start()
		var/i = 0
		for(i=0, i<src.number, i++)
			spawn(0)
				if(holder)
					src.location = get_turf(holder)
				var/obj/effect/effect/steam/steam = new /obj/effect/effect/steam(src.location)
				var/direction
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
				for(i=0, i<pick(1,2,3), i++)
					sleep(5)
					step(steam,direction)
				spawn(20)
					if(steam) steam.delete()

/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/obj/effect/effect/sparks
	name = "sparks"
	desc = "it's a spark what do you need to know?"
	icon_state = "sparks"
	anchored = 1.0
	mouse_opacity = 0

	var/amount = 6.0

/obj/effect/effect/sparks/New()
	..()
	playsound(src.loc, "sparks", 100, 1)
	var/turf/T = loc
	if(istype(T, /turf))
		T.hotspot_expose(1000, 100)
	spawn (100)
		qdel(src)

/obj/effect/effect/sparks/Destroy()
	var/turf/T = src.loc
	if(istype(T, /turf))
		T.hotspot_expose(1000,100)
	return ..()

/obj/effect/effect/sparks/Move()
	..()
	var/turf/T = src.loc
	if(istype(T, /turf))
		T.hotspot_expose(1000,100)
	return

/datum/effect/system/spark_spread
	var/total_sparks = 0 // To stop it being spammed and lagging!

	set_up(n = 3, c = 0, loca)
		if(n > 10)
			n = 10
		number = n
		cardinals = c
		if(istype(loca, /turf/))
			location = loca
		else
			location = get_turf(loca)

	start()
		var/i = 0
		for(i=0, i<src.number, i++)
			if(src.total_sparks > 20)
				return
			spawn(0)
				if(holder)
					src.location = get_turf(holder)
				var/obj/effect/effect/sparks/sparks = new /obj/effect/effect/sparks(src.location)
				src.total_sparks++
				var/direction
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
				for(i=0, i<pick(1,2,3), i++)
					sleep(5)
					step(sparks,direction)
				spawn(20)
					qdel(sparks)
					src.total_sparks--

/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////


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
	spawn (100)
		delete()
	return

/obj/effect/effect/harmless_smoke/Move()
	..()
	return

/datum/effect/system/harmless_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

	set_up(n = 5, c = 0, loca, direct)
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


	start()
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
	spawn (200+rand(10,30))
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
				spawn ( 20 )
					M.coughedtime = 0
	return


/obj/effect/effect/bad_smoke/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage/2)
	return 1


/obj/effect/effect/bad_smoke/Crossed(mob/living/carbon/M as mob )
	..()
	if(istype(M, /mob/living/carbon))
		if(M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
			return
		else
			M.drop_item()
			M.adjustOxyLoss(1)
			if(M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn ( 20 )
					M.coughedtime = 0
	return

/datum/effect/system/bad_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

	set_up(n = 5, c = 0, loca, direct)
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

	start()
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
	spawn (200+rand(10,30))
		delete()
	return

/obj/effect/effect/chem_smoke/Move()
	..()

	return

// Spores
/datum/effect/system/chem_smoke_spread/spores
	var/datum/seed/seed

/datum/effect/system/chem_smoke_spread/spores/New(seed_name)
	if(seed_name && plant_controller)
		seed = plant_controller.seeds[seed_name]
	if(!seed)
		qdel(src)
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

	Destroy()
		qdel(chemholder)
		chemholder = null
		return ..()

	New()
		..()
		chemholder = new/obj()
		var/datum/reagents/R = new/datum/reagents(500)
		chemholder.reagents = R
		R.my_atom = chemholder

	set_up(var/datum/reagents/carry = null, n = 5, c = 0, loca, direct, silent = 0)
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

	start(effect_range = 2)
		var/i = 0

		var/color = mix_color_from_reagents(chemholder.reagents.reagent_list)
		var/obj/effect/effect/chem_smoke/smokeholder = new /obj/effect/effect/chem_smoke(src.location)
		for(var/atom/A in view(effect_range, smokeholder))
			chemholder.reagents.reaction(A)
			if(iscarbon(A))
				var/mob/living/carbon/C = A
				if(C.can_breathe_gas())
					chemholder.reagents.copy_to(C, chemholder.reagents.total_volume)
			if(istype(A, /obj/machinery/portable_atmospherics/hydroponics))
				var/obj/machinery/portable_atmospherics/hydroponics/tray = A
				chemholder.reagents.copy_to(tray, chemholder.reagents.total_volume)
			if(istype(A, /obj/effect/plant))
				var/obj/effect/plant/plant = A
				if(chemholder.reagents.has_reagent("atrazine"))
					plant.die_off()
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
					if(smoke) smoke.delete()
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
	spawn (200+rand(10,30))
		delete()
	return

/obj/effect/effect/sleep_smoke/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		if(M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
//		if(M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal))  // I'll work on it later
		else
			M.drop_item()
			M:sleeping += 5
			if(M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return

/obj/effect/effect/sleep_smoke/Crossed(mob/living/carbon/M as mob )
	..()
	if(istype(M, /mob/living/carbon))
		if(M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
//		if(M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal)) // Work on it later
			return
		else
			M.drop_item()
			M:sleeping += 5
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

	set_up(n = 5, c = 0, loca, direct)
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


	start()
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

/////////////////////////////////////////////
// Mustard Gas
/////////////////////////////////////////////


/obj/effect/effect/mustard_gas
	name = "mustard gas"
	icon_state = "mustard"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0

/obj/effect/effect/mustard_gas/New()
	..()
	spawn (100)
		qdel(src)
	return

/obj/effect/effect/mustard_gas/Move()
	..()
	for(var/mob/living/carbon/human/R in get_turf(src))
		if(R.internal != null && usr.wear_mask && (R.wear_mask.flags & AIRTIGHT) && R.wear_suit != null && !istype(R.wear_suit, /obj/item/clothing/suit/storage/labcoat) && !istype(R.wear_suit, /obj/item/clothing/suit/straight_jacket) && !istype(R.wear_suit, /obj/item/clothing/suit/straight_jacket && !istype(R.wear_suit, /obj/item/clothing/suit/armor)))
		else
			R.adjustFireLoss(0.75)
			if(R.coughedtime != 1)
				R.coughedtime = 1
				R.emote("gasp")
				spawn (20)
					R.coughedtime = 0
			R.updatehealth()
	return

/obj/effect/effect/mustard_gas/Crossed(mob/living/carbon/human/R as mob )
	..()
	if(istype(R, /mob/living/carbon/human))
		if(R.internal != null && usr.wear_mask && (R.wear_mask.flags & AIRTIGHT) && R.wear_suit != null && !istype(R.wear_suit, /obj/item/clothing/suit/storage/labcoat) && !istype(R.wear_suit, /obj/item/clothing/suit/straight_jacket) && !istype(R.wear_suit, /obj/item/clothing/suit/straight_jacket && !istype(R.wear_suit, /obj/item/clothing/suit/armor)))
			return
		R.adjustFireLoss(0.75)
		if(R.coughedtime != 1)
			R.coughedtime = 1
			R.emote("gasp")
			spawn (20)
				R.coughedtime = 0
		R.updatehealth()
	return

/datum/effect/system/mustard_gas_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

	set_up(n = 5, c = 0, loca, direct)
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

	start()
		var/i = 0
		for(i=0, i<src.number, i++)
			if(src.total_smoke > 20)
				return
			spawn(0)
				if(holder)
					src.location = get_turf(holder)
				var/obj/effect/effect/mustard_gas/smoke = new /obj/effect/effect/mustard_gas(src.location)
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
				spawn(100)
					qdel(smoke)
					src.total_smoke--


/////////////////////////////////////////////
//////// Attach an Ion trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/obj/effect/effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = 1.0

/datum/effect/system/ion_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

/datum/effect/system/ion_trail_follow/Destroy()
	oldposition = null
	return ..()

/datum/effect/system/ion_trail_follow/set_up(atom/atom)
	attach(atom)

/datum/effect/system/ion_trail_follow/start() //Whoever is responsible for this abomination of code should become an hero
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		var/turf/T = get_turf(src.holder)
		if(T != src.oldposition)
			if(!has_gravity(T))
				var/obj/effect/effect/ion_trails/I = new /obj/effect/effect/ion_trails(src.oldposition)
				I.dir = src.holder.dir
				flick("ion_fade", I)
				I.icon_state = "blank"
				spawn( 20 )
					if(I)
						I.delete()
			src.oldposition = T
		spawn(2)
			if(src.on)
				src.processing = 1
				src.start()

/datum/effect/system/ion_trail_follow/proc/stop()
	src.processing = 0
	src.on = 0
	oldposition = null

/datum/effect/system/ion_trail_follow/space_trail
	var/turf/oldloc // secondary ion trail loc
	var/turf/currloc

/datum/effect/system/ion_trail_follow/space_trail/Destroy()
	oldloc = null
	currloc = null
	return ..()

/datum/effect/system/ion_trail_follow/space_trail/start()
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		spawn(0)
			var/turf/T = get_turf(src.holder)
			if(currloc != T)
				switch(holder.dir)
					if(NORTH)
						src.oldposition = T
						src.oldposition = get_step(oldposition, SOUTH)
						src.oldloc = get_step(oldposition,EAST)
						//src.oldloc = get_step(oldloc, SOUTH)
					if(SOUTH) // More difficult, offset to the north!
						src.oldposition = get_step(holder,NORTH)
						src.oldposition = get_step(oldposition,NORTH)
						src.oldloc = get_step(oldposition,EAST)
						//src.oldloc = get_step(oldloc,NORTH)
					if(EAST) // Just one to the north should suffice
						src.oldposition = T
						src.oldposition = get_step(oldposition, WEST)
						src.oldloc = get_step(oldposition,NORTH)
						//src.oldloc = get_step(oldloc,WEST)
					if(WEST) // One to the east and north from there
						src.oldposition = get_step(holder,EAST)
						src.oldposition = get_step(oldposition,EAST)
						src.oldloc = get_step(oldposition,NORTH)
						//src.oldloc = get_step(oldloc,EAST)
				if(istype(T, /turf/space))
					var/obj/effect/effect/ion_trails/I = new /obj/effect/effect/ion_trails(src.oldposition)
					var/obj/effect/effect/ion_trails/II = new /obj/effect/effect/ion_trails(src.oldloc)
					//src.oldposition = T
					I.dir = src.holder.dir
					II.dir = src.holder.dir
					flick("ion_fade", I)
					flick("ion_fade", II)
					I.icon_state = "blank"
					II.icon_state = "blank"
					spawn( 20 )
						if(I) I.delete()
						if(II) II.delete()
			spawn(2)
				if(src.on)
					src.processing = 1
					src.start()
			currloc = T


/////////////////////////////////////////////
//////// Attach a steam trail to an object (eg. a reacting beaker) that will follow it
// even if it's carried of thrown.
/////////////////////////////////////////////

/datum/effect/system/steam_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

	Destroy()
		oldposition = null
		return ..()

	set_up(atom/atom)
		attach(atom)
		oldposition = get_turf(atom)

	start()
		if(!src.on)
			src.on = 1
			src.processing = 1
		if(src.processing)
			src.processing = 0
			spawn(0)
				if(src.number < 3)
					var/obj/effect/effect/steam/I = new /obj/effect/effect/steam(src.oldposition)
					src.number++
					src.oldposition = get_turf(holder)
					I.dir = src.holder.dir
					spawn(10)
						if(I) I.delete()
						src.number--
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()
				else
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()

	proc/stop()
		src.processing = 0
		src.on = 0



// Foam
// Similar to smoke, but spreads out more
// metal foams leave behind a foamed metal wall

/obj/effect/effect/foam
	name = "foam"
	icon_state = "foam"
	opacity = 0
	anchored = 1
	density = 0
	layer = OBJ_LAYER + 0.9
	mouse_opacity = 0
	var/amount = 3
	var/expand = 1
	animate_movement = 0
	var/metal = 0


/obj/effect/effect/foam/New(loc, var/ismetal=0)
	..(loc)
	icon_state = "[ismetal ? "m":""]foam"
	if(!ismetal && reagents)
		color = mix_color_from_reagents(reagents.reagent_list)
	metal = ismetal
	playsound(src, 'sound/effects/bubbles2.ogg', 80, 1, -3)
	spawn(3 + metal*3)
		process()
	spawn(120)
		processing_objects.Remove(src)
		sleep(30)

		if(metal)
			var/turf/T = get_turf(src)
			if(istype(T, /turf/space))
				T.ChangeTurf(/turf/simulated/floor/plating/metalfoam)
				var/turf/simulated/floor/plating/metalfoam/MF = get_turf(src)
				MF.metal = metal
				MF.update_icon()

			var/obj/structure/foamedmetal/M = new(src.loc)
			M.metal = metal
			M.updateicon()

		flick("[icon_state]-disolve", src)
		sleep(5)
		delete()
	return

// on delete, transfer any reagents to the floor
/obj/effect/effect/foam/Destroy()
	if(!metal && reagents)
		reagents.handle_reactions()
		for(var/atom/A in oview(1, src))
			if(A == src)
				continue
			if(reagents.total_volume)
				var/fraction = 5 / reagents.total_volume
				reagents.reaction(A, TOUCH, fraction)
	return ..()

/obj/effect/effect/foam/process()
	if(--amount < 0)
		return


	for(var/direction in cardinal)


		var/turf/T = get_step(src,direction)
		if(!T)
			continue

		if(!T.Enter(src))
			continue

		var/obj/effect/effect/foam/F = locate() in T
		if(F)
			continue

		F = new /obj/effect/effect/foam(T, metal)
		F.amount = amount
		if(!metal)
			F.create_reagents(15)
			if(reagents)
				for(var/datum/reagent/R in reagents.reagent_list)
					F.reagents.add_reagent(R.id, min(R.volume, 3), R.data, reagents.chem_temp)
				F.color = mix_color_from_reagents(reagents.reagent_list)

// foam disolves when heated
// except metal foams
/obj/effect/effect/foam/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!metal && prob(max(0, exposed_temperature - 475)))
		flick("[icon_state]-disolve", src)

		spawn(5)
			delete()


/obj/effect/effect/foam/Crossed(var/atom/movable/AM)
	if(metal)
		return

	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M =	AM
		if(M.slip("foam", 5, 2))
			if(reagents)
				for(var/reagent_id in reagents.reagent_list)
					var/amount = M.reagents.get_reagent_amount(reagent_id)
					if(amount < 25)
						M.reagents.add_reagent(reagent_id, min(round(amount / 2), 15))
				if(reagents.total_volume)
					var/fraction = 5 / reagents.total_volume
					reagents.reaction(M, TOUCH, fraction)


/datum/effect/system/foam_spread
	var/amount = 5				// the size of the foam spread.
	var/list/carried_reagents	// the IDs of reagents present when the foam was mixed
	var/metal = 0				// 0=foam, 1=metalfoam, 2=ironfoam
	var/temperature = T0C
	var/list/banned_reagents = list("smoke_powder", "fluorosurfactant", "stimulants")

/datum/effect/system/foam_spread/set_up(amt=5, loca, var/datum/reagents/carry = null, var/metalfoam = 0)
	amount = min(round(amt/5, 1), 7)
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

	carried_reagents = list()
	metal = metalfoam
	temperature = carry.chem_temp

	// bit of a hack here. Foam carries along any reagent also present in the glass it is mixed
	// with (defaults to water if none is present). Rather than actually transfer the reagents,
	// this makes a list of the reagent ids and spawns 1 unit of that reagent when the foam disolves.

	if(carry && !metal)
		for(var/datum/reagent/R in carry.reagent_list)
			carried_reagents[R.id] = R.volume

/datum/effect/system/foam_spread/start()
	spawn(0)
		var/obj/effect/effect/foam/F = locate() in location
		if(F)
			F.amount += amount
			F.amount = min(F.amount, 27)
			return

		F = new /obj/effect/effect/foam(location, metal)
		F.amount = amount

		if(!metal)			// don't carry other chemicals if a metal foam
			F.create_reagents(15)

			if(carried_reagents)
				for(var/id in carried_reagents)
					if(banned_reagents.Find("[id]"))
						continue
					var/datum/reagent/reagent_volume = carried_reagents[id]
					F.reagents.add_reagent(id, min(reagent_volume, 3), null, temperature)
				F.color = mix_color_from_reagents(F.reagents.reagent_list)
			else
				F.reagents.add_reagent("cleaner", 1)
				F.color = mix_color_from_reagents(F.reagents.reagent_list)

// wall formed by metal foams
// dense and opaque, but easy to break


/obj/structure/foamedmetal
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	density = 1
	opacity = 1 	// changed in New()
	anchored = 1
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	var/metal = MFOAM_ALUMINUM

/obj/structure/foamedmetal/initialize()
	..()
	air_update_turf(1)

/obj/structure/foamedmetal/Destroy()
	density = 0
	air_update_turf(1)
	return ..()

/obj/structure/foamedmetal/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/foamedmetal/proc/updateicon()
	if(metal == MFOAM_ALUMINUM)
		icon_state = "metalfoam"
	else
		icon_state = "ironfoam"


/obj/structure/foamedmetal/ex_act(severity)
	qdel(src)

/obj/structure/foamedmetal/blob_act()
	qdel(src)

/obj/structure/foamedmetal/bullet_act()
	if(metal==MFOAM_ALUMINUM || prob(50))
		qdel(src)

/obj/structure/foamedmetal/attack_hand(var/mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if((HULK in user.mutations) || (prob(75 - metal*25)))
		user.visible_message("<span class='warning'>[user] smashes through \the [src].</span>", "<span class='notice'>You smash through \the [src].</span>")
		qdel(src)
	else
		to_chat(user, "<span class='notice'>You hit the metal foam but bounce off it.</span>")

/obj/structure/foamedmetal/attackby(var/obj/item/I, var/mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		G.affecting.loc = src.loc
		user.visible_message("<span class='warning'>[G.assailant] smashes [G.affecting] through the foamed metal wall.</span>")
		qdel(I)
		qdel(src)
		return

	if(prob(I.force*20 - metal*25))
		user.visible_message("<span class='warning'>[user] smashes through the foamed metal with \the [I].</span>", "<span class='notice'>You smash through the foamed metal with \the [I].</span>")
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You hit the metal foam to no effect.</span>")

/obj/structure/foamedmetal/attack_animal(mob/living/simple_animal/M)
	M.do_attack_animation(src)
	if(M.melee_damage_upper == 0)
		M.visible_message("<span class='notice'>[M] nudges \the [src].</span>")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		M.visible_message("<span class='danger'>\The [M] [M.attacktext] [src]!</span>")
		qdel(src)

/obj/structure/foamedmetal/attack_alien(mob/living/carbon/alien/humanoid/M)
	M.visible_message("<span class='danger'>[M] tears apart \the [src]!</span>");
	qdel(src)

/obj/structure/foamedmetal/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group) return 0
	return !density

/obj/structure/foamedmetal/CanAtmosPass()
	return !density

/datum/effect/system/reagents_explosion
	var/amount 						// TNT equivalent
	var/flashing = 0			// does explosion creates flash effect?
	var/flashing_factor = 0		// factor of how powerful the flash effect relatively to the explosion

	set_up (amt, loc, flash = 0, flash_fact = 0)
		amount = amt
		if(istype(loc, /turf/))
			location = loc
		else
			location = get_turf(loc)

		flashing = flash
		flashing_factor = flash_fact

		return

	start()
		if(amount <= 2)
			var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
			s.set_up(2, 1, location)
			s.start()

			for(var/mob/M in viewers(5, location))
				to_chat(M, "\red The solution violently explodes.")
			for(var/mob/M in viewers(1, location))
				if(prob (50 * amount))
					to_chat(M, "\red The explosion knocks you down.")
					M.Weaken(rand(1,5))
			return
		else
			var/devastation = -1
			var/heavy = -1
			var/light = -1
			var/flash = -1

			// Clamp all values to MAX_EXPLOSION_RANGE
			if(round(amount/12) > 0)
				devastation = min (MAX_EX_DEVESTATION_RANGE, devastation + round(amount/12))

			if(round(amount/6) > 0)
				heavy = min (MAX_EX_HEAVY_RANGE, heavy + round(amount/6))

			if(round(amount/3) > 0)
				light = min (MAX_EX_LIGHT_RANGE, light + round(amount/3))

			if(flash && flashing_factor)
				flash += (round(amount/4) * flashing_factor)

			for(var/mob/M in viewers(8, location))
				to_chat(M, "\red The solution violently explodes.")

			explosion(location, devastation, heavy, light, flash)

	proc/holder_damage(var/atom/holder)
		if(holder)
			var/dmglevel = 4

			if(round(amount/8) > 0)
				dmglevel = 1
			else if(round(amount/4) > 0)
				dmglevel = 2
			else if(round(amount/2) > 0)
				dmglevel = 3

			if(dmglevel<4) holder.ex_act(dmglevel)


//////////////////////////////////
//////SPARKLE FIREWORKS
/////////////////////////////////
////////////////////////////
/obj/effect/sparkles
	name = "sparkle"
	icon = 'icons/obj/fireworks.dmi'//findback
	icon_state = "sparkel"
	var/amount = 6.0
	anchored = 1.0
	mouse_opacity = 0

/obj/effect/sparkles/New()
	..()
	var/icon/I = new(src.icon,src.icon_state)
	var/r = rand(0,255)
	var/g = rand(0,255)
	var/b = rand(0,255)
	I.Blend(rgb(r,g,b),ICON_MULTIPLY)
	src.icon = I
	playsound(src.loc, "sparks", 100, 1)
	var/turf/T = src.loc
	if(istype(T, /turf))
		T.hotspot_expose(3000,100)
	spawn (100)
		qdel(src)
	return

/obj/effect/sparkles/Destroy()
	var/turf/T = src.loc
	if(istype(T, /turf))
		T.hotspot_expose(3000,100)
	return ..()

/obj/effect/sparkles/Move()
	..()
	var/turf/T = src.loc
	if(istype(T, /turf))
		T.hotspot_expose(3000,100)
	return


/datum/effect/system/sparkle_spread
	var/total_sparks = 0 // To stop it being spammed and lagging!

/datum/effect/system/sparkle_spread/set_up(n = 3, c = 0, loca)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

/datum/effect/system/sparkle_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_sparks > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/sparkles/sparks = new(src.location)
			src.total_sparks++
			var/direction
			if(src.cardinals)
				direction = pick(cardinal)
			else
				direction = pick(alldirs)
			for(i=0, i<pick(1,2,3), i++)
				sleep(5)
				step(sparks,direction)
			spawn(20)
				qdel(sparks)
				src.total_sparks--
