/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/floor/grass
	name = "grass patch"
	icon_state = "grass1"

/turf/unsimulated/floor/grass/New()
	..()
	icon_state = "grass[rand(1,4)]"

/turf/unsimulated/floor/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/unsimulated/floor/chasm
	name = "chasm"
	desc = "It's difficult to see the bottom."
	density = 0
	icon = 'icons/turf/floors/Chasms.dmi'
	icon_state = "Fill"
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/unsimulated/floor/chasm)

/turf/unsimulated/floor/chasm/Entered(mob/living/M, atom/OL, ignoreRest = 0)
	// "fall" south
	if(istype(M))
		spawn(1)
			if(step(M, SOUTH))
				M.emote("scream")

/turf/unsimulated/floor/chasm/dense
	density = 1

/turf/unsimulated/floor/lava
	name = "lava"
	desc = "That looks... a bit dangerous"
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/unsimulated/floor/lava)
	var/lava_damage = 250
	var/lava_fire = 20
	light_range = 2
	light_color = "#FFC040"

/turf/unsimulated/floor/lava/Entered(AM)
	. = 0
	var/thing_to_check = src
	if (AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(isobj(thing))
			var/obj/O = thing
			if((O.resistance_flags & (LAVA_PROOF|ON_FIRE|INDESTRUCTIBLE)) || O.throwing)
				continue
			. = 1
			if(!(O.resistance_flags & FLAMMABLE))
				O.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
				O.resistance_flags = ~FIRE_PROOF
			if(O.armor["fire"] > 50) //obj with 100% fire armor still get slowly burned away.
				O.armor["fire"] = 50
			O.fire_act(10000, 1000)


		else if (isliving(thing))
			. = 1
			var/mob/living/L = thing
			if("lava" in L.weather_immunities)
				continue
			if(L.buckled)
				if(isobj(L.buckled))
					var/obj/O = L.buckled
					if(O.resistance_flags & LAVA_PROOF)
						continue
				if(isliving(L.buckled)) //Goliath riding
					var/mob/living/live = L.buckled
					if("lava" in live.weather_immunities)
						continue

			L.adjustFireLoss(20)
			if(L) //mobs turning into object corpses could get deleted here.
				L.adjust_fire_stacks(20)
				L.IgniteMob()

/turf/unsimulated/floor/lava/dense
	density = 1

/turf/unsimulated/floor/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/unsimulated/floor/abductor/New()
	..()
	icon_state = "alienpod[rand(1,9)]"

/turf/unsimulated/floor/vox
	icon_state = "dark"
	nitrogen = 100
	oxygen = 0

/turf/unsimulated/floor/carpet
	name = "Carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	smooth = SMOOTH_TRUE
	canSmoothWith = null

	footstep_sounds = list(
		"human" = list('sound/effects/footstep/carpet_human.ogg'),
		"xeno"  = list('sound/effects/footstep/carpet_xeno.ogg')
	)

/turf/unsimulated/floor/wood
	icon_state = "wood"

	footstep_sounds = list(
		"human" = list('sound/effects/footstep/wood_all.ogg'), //@RonaldVanWonderen of Freesound.org
		"xeno"  = list('sound/effects/footstep/wood_all.ogg')  //@RonaldVanWonderen of Freesound.org
	)
