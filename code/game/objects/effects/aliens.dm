/* Alien Effects!
 * Contains:
 *		effect/alien
 *		Resin
 *		Weeds
 *		Acid
 *		Egg
 */

/*
 * effect/alien
 */
/obj/effect/alien
	icon = 'icons/mob/alien.dmi'

/*
 * Resin
 */
/obj/effect/alien/resin
	name = "resin"
	desc = "Looks like some kind of thick resin."
	icon_state = "resin"
	density = 1
	opacity = 1
	anchored = 1
	var/health = 200
	var/resintype = null
	
/obj/effect/alien/resin/New(location)
	relativewall_neighbours()
	..()
	return

/obj/effect/alien/resin/Destroy()
	var/turf/T = loc
	loc = null
	T.relativewall_neighbours()
	..()

/obj/effect/alien/resin/Move()
	..()

/obj/effect/alien/resin/wall
	name = "resin wall"
	desc = "Thick resin solidified into a wall."
	icon_state = "resinwall"	//same as resin, but consistency ho!
	
/obj/effect/alien/resin/wall/New()
	relativewall_neighbours()
	..()


/obj/effect/alien/resin/membrane
	name = "resin membrane"
	desc = "Resin just thin enough to let light pass through."
	icon_state = "resinmembrane"
	opacity = 0
	health = 120

/obj/effect/alien/resin/membrane/New()
	relativewall_neighbours()
	..()

/obj/effect/alien/resin/proc/healthcheck()
	if(health <=0)
		qdel(src)


/obj/effect/alien/resin/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()


/obj/effect/alien/resin/ex_act(severity, target)
	switch(severity)
		if(1.0)
			health -= 150
		if(2.0)
			health -= 100
		if(3.0)
			health -= 50
	healthcheck()


/obj/effect/alien/resin/blob_act()
	health -= 50
	healthcheck()


/obj/effect/alien/resin/hitby(atom/movable/AM)
	..()
	visible_message("<span class='danger'>[src] was hit by [AM].</span>")
	var/tforce = 0
	if(!isobj(AM))
		tforce = 10
	else
		var/obj/O = AM
		tforce = O.throwforce
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health -= tforce
	healthcheck()


/obj/effect/alien/resin/attack_hand(mob/living/user)
	if(M_HULK in user.mutations)

		user.visible_message("<span class='danger'>[user] destroys [src]!</span>")
		health = 0
		healthcheck()


/obj/effect/alien/resin/attack_paw(mob/user)
	return attack_hand(user)


/obj/effect/alien/resin/attack_alien(mob/living/user)
	if(islarva(user))
		return
	user.visible_message("<span class='danger'>[user] claws at the resin!</span>")
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health -= 50
	if(health <= 0)
		user.visible_message("<span class='danger'>[user] slices the [name] apart!</span>")
	healthcheck()


/obj/effect/alien/resin/attackby(obj/item/I, mob/living/user)
	health -= I.force
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	..()


/obj/effect/alien/resin/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density
	
/*
 * Weeds
 */
#define NODERANGE 3

/obj/effect/alien/weeds
	name = "weeds"
	desc = "Strange, alien-looking purple weeds."
	icon_state = "weeds"

	anchored = 1
	density = 0
	layer = 2
	var/health = 15
	var/obj/effect/alien/weeds/node/linked_node = null
	
/obj/effect/alien/weeds/node
	name = "purple sac"
	desc = "A purple sac covering alien weeds."
	icon_state = "weednode"
	layer = 3
	luminosity = NODERANGE
	var/node_range = NODERANGE
	var/list/obj/effect/alien/weeds/connected_weeds
	
/obj/effect/alien/weeds/node/New()
	connected_weeds = new()
	..(src.loc, src)
	
/obj/effect/alien/weeds/node/Destroy()
	for(var/obj/effect/alien/weeds/W in connected_weeds)
		processing_objects.Add(W) // Start processing the weeds so they lose health when there's no connected node
	..()
	
/obj/effect/alien/weeds/process()
	if(!linked_node || (get_dist(linked_node, src) > linked_node.node_range))
		if(prob(50))
			health -= 1
		else if(prob(50))
			health -= 2
		else if(prob(25))
			health -= 3
		healthcheck()		
	
/obj/effect/alien/weeds/New(pos, var/obj/effect/alien/weeds/node/N)
	..()

	if(istype(loc, /turf/space))
		qdel(src)
		return

	linked_node = N
	if(linked_node)
		linked_node.connected_weeds.Add(src)

	if(icon_state == "weeds")icon_state = pick("weeds", "weeds1", "weeds2")
	spawn(rand(150, 200))
		if(src)
			Life()
	return

/obj/effect/alien/weeds/Destroy()
	if(linked_node)
		linked_node.connected_weeds.Remove(src)
		linked_node = null
	processing_objects.Remove(src)
	..()
	
/obj/effect/alien/weeds/proc/Life()	
	set background = BACKGROUND_ENABLED
	var/turf/U = get_turf(src)

	if (istype(U, /turf/space))
		del(src)
		return

	if(!linked_node || (get_dist(linked_node, src) > linked_node.node_range) )
		healthcheck()		
		return

	direction_loop:
		for(var/dirn in cardinal)

			var/turf/T = get_step(src, dirn)

			if (!istype(T) || T.density || locate(/obj/effect/alien/weeds) in T || istype(T.loc, /area/arrival) || istype(T, /turf/space))
				continue

			for(var/obj/O in T)
				if(O.density)
					continue direction_loop

			new /obj/effect/alien/weeds(T, linked_node)
	
/obj/effect/alien/weeds/ex_act(severity,target)	
	qdel(src)
	
/obj/effect/alien/weeds/fire_act(null, temperature, volume)
	if(temperature > T0C+200)
		health -= 1 * temperature
		healthcheck()

/obj/effect/alien/weeds/attackby(obj/item/I, mob/user)
	if(I.attack_verb.len)
		visible_message("<span class='danger'>[user] has [pick(I.attack_verb)] [src] with [I]!</span>")
	else
		visible_message("<span class='danger'>[user] has attacked [src] with [I]!</span>")

	var/damage = I.force / 4.0
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	healthcheck()	
	
/obj/effect/alien/weeds/proc/healthcheck()
	if(health <= 0)
		qdel(src)	
		
/obj/effect/alien/weeds/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()
	
/*
 * Acid
 */
/obj/effect/alien/acid
	name = "acid"
	desc = "Burbling corrossive stuff. I wouldn't want to touch it."
	icon_state = "acid"

	density = 0
	opacity = 0
	anchored = 1

	var/atom/target
	var/ticks = 0
	var/target_strength = 0

/obj/effect/alien/acid/New(loc, target)
	..(loc)
	src.target = target

	if(isturf(target)) // Turf take twice as long to take down.
		target_strength = 8
	else
		target_strength = 4
	tick()

/obj/effect/alien/acid/proc/tick()
	if(!target)
		del(src)

	ticks += 1

	if(ticks >= target_strength)

		for(var/mob/O in hearers(src, null))
			O.show_message("\green <B>[src.target] collapses under its own weight into a puddle of goop and undigested debris!</B>", 1)

		if(istype(target, /turf/simulated/wall)) // I hate turf code.
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else
			del(target)
		del(src)
		return

	switch(target_strength - ticks)
		if(6)
			visible_message("\green <B>[src.target] is holding up against the acid!</B>")
		if(4)
			visible_message("\green <B>[src.target]\s structure is being melted by the acid!</B>")
		if(2)
			visible_message("\green <B>[src.target] is struggling to withstand the acid!</B>")
		if(0 to 1)
			visible_message("\green <B>[src.target] begins to crumble under the acid!</B>")
	spawn(rand(150, 200)) tick()

/*
 * Egg
 */

//for the status var
#define BURST 0
#define BURSTING 1
#define GROWING 2
#define GROWN 3
#define MIN_GROWTH_TIME 1800	//time it takes to grow a hugger
#define MAX_GROWTH_TIME 3000

/obj/effect/alien/egg
	name = "egg"
	desc = "A large mottled egg."
	icon_state = "egg_growing"
	density = 0
	anchored = 1
	var/health = 100
	var/status = GROWING	//can be GROWING, GROWN or BURST; all mutually exclusive


/obj/effect/alien/egg/New()
	new /obj/item/clothing/mask/facehugger(src)
	..()
	spawn(rand(MIN_GROWTH_TIME, MAX_GROWTH_TIME))
		Grow()


/obj/effect/alien/egg/attack_paw(mob/user)
	if(isalien(user))
		switch(status)
			if(BURST)
				user << "<span class='notice'>You clear the hatched egg.</span>"
				playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
				qdel(src)
				return
			if(GROWING)
				user << "<span class='notice'>The child is not developed yet.</span>"
				return
			if(GROWN)
				user << "<span class='notice'>You retrieve the child.</span>"
				Burst(0)
				return
	else
		return attack_hand(user)


/obj/effect/alien/egg/attack_hand(mob/user)
	user << "<span class='notice'>It feels slimy.</span>"

/obj/effect/alien/egg/proc/GetFacehugger()
	return locate(/obj/item/clothing/mask/facehugger) in contents


/obj/effect/alien/egg/proc/Grow()
	icon_state = "egg"
	status = GROWN


/obj/effect/alien/egg/proc/Burst(var/kill = 1)	//drops and kills the hugger if any is remaining
	if(status == GROWN || status == GROWING)
		icon_state = "egg_hatched"
		flick("egg_opening", src)
		status = BURSTING
		spawn(15)
			status = BURST
			var/obj/item/clothing/mask/facehugger/child = GetFacehugger()
			if(child)
				child.loc = get_turf(src)
				if(kill && istype(child))
					child.Die()
				else
					for(var/mob/M in range(1,src))
						if(CanHug(M))
							child.Attach(M)
							break


/obj/effect/alien/egg/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()


/obj/effect/alien/egg/attackby(obj/item/I, mob/user)
	if(I.attack_verb.len)
		visible_message("<span class='danger'>[user] has [pick(I.attack_verb)] [src] with [I]!</span>")
	else
		visible_message("<span class='danger'>[user] has attacked [src] with [I]!</span>")

	var/damage = I.force / 4
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	healthcheck()


/obj/effect/alien/egg/proc/healthcheck()
	if(health <= 0)
		if(status != BURST && status != BURSTING)
			Burst()
		else if(status == BURST && prob(50))
			qdel(src)	//Remove the egg after it has been hit after bursting.


/obj/effect/alien/egg/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		health -= 5
		healthcheck()


/obj/effect/alien/egg/HasProximity(atom/movable/AM)
	if(status == GROWN)
		if(!CanHug(AM))
			return

		var/mob/living/carbon/C = AM
		if(C.stat == CONSCIOUS && C.status_flags & XENO_HOST)
			return

		Burst(0)

#undef BURST
#undef BURSTING
#undef GROWING
#undef GROWN
#undef MIN_GROWTH_TIME
#undef MAX_GROWTH_TIME

