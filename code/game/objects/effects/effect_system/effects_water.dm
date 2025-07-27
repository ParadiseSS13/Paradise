//WATER EFFECTS
/obj/effect/particle_effect/water
	name = "water"
	icon_state = "extinguish"
	var/life = 15

/obj/effect/particle_effect/water/New()
	..()
	QDEL_IN(src, 70)

/obj/effect/particle_effect/water/Move(turf/newloc)
	if(--life < 1)
		qdel()
		return 0
	if(newloc.density)
		return 0
	. = ..()

/obj/effect/particle_effect/water/Bump(atom/A)
	if(reagents)
		reagents.reaction(A)
	if(istype(A,/atom/movable))
		var/atom/movable/AM = A
		AM.water_act(life, COLD_WATER_TEMPERATURE, src)
	return ..()

/obj/effect/particle_effect/water/proc/extinguish_move(turf/target)
	for(var/counter in 1 to 5)
		if(!step_towards(src, target) && counter != 1)
			return
		var/turf/current_turf = get_turf(src)
		reagents.reaction(current_turf)
		for(var/atom/atm in current_turf)
			reagents.reaction(atm)
			if(isliving(atm)) //For extinguishing mobs on fire
				var/mob/living/M = atm
				M.ExtinguishMob()

		if(current_turf == target)
			return
		sleep(2)

/////////////////////////////////////////////
// GENERIC STEAM SPREAD SYSTEM

//Usage: set_up(number of bits of steam, use North/South/East/West only, spawn location)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like a smoking beaker, so then you can just call start() and the steam
// will always spawn at the items location, even if it's moved.

/* Example:
	var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread() -- creates new system
	steam.set_up(5, 0, mob.loc) -- sets up variables
	OPTIONAL: steam.attach(mob)
	steam.start() -- spawns the effect
*/
/////////////////////////////////////////////
/obj/effect/particle_effect/steam
	name = "steam"
	icon_state = "extinguish"

/obj/effect/particle_effect/steam/New()
	..()
	QDEL_IN(src, 20)

/datum/effect_system/steam_spread
	effect_type = /obj/effect/particle_effect/steam
