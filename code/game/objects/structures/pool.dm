/obj/pool
	name = "pool"
	density = 1
	anchored = 1
	icon = 'icons/obj/pool.dmi'
	icon_state = "pool"

/turf/simulated/floor/beach/pool
	name = "pool_water"
	icon = 'icons/obj/pool.dmi'
	icon_state = "poolwaterfloor"

/turf/simulated/floor/beach/pool/New()
	..()
	dir = pick(NORTH,SOUTH)

/obj/poolwater
	name = "water"
	density = 0
	anchored = 1
	icon = 'icons/obj/pool.dmi'
	icon_state = "poolwater"
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = 0

/obj/poolwater/New()
	var/datum/reagents/R = new/datum/reagents(10)
	reagents = R
	R.my_atom = src
	R.add_reagent("cleaner",5)
	R.add_reagent("water",5)

/obj/poolwater/Crossed(atom/A)
	reagents.reaction(A, TOUCH, 2)
	return

/obj/pool_springboard
	name = "springboard"
	density = 0
	anchored = 1
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -16
	icon = 'icons/obj/pool.dmi'
	icon_state = "springboard"
	in_use = 0

/obj/pool_springboard/attackby(obj/item/W as obj, mob/user as mob)
	return attack_hand(user)

/obj/pool_springboard/attack_hand(mob/user as mob)
	if(in_use)
		user.visible_message("<span style=\"color:red\">Its already in use - wait a bit.</span>")
		return
	else
		in_use = 1
		var/range = pick(25;1,2,3)
		var/turf/target = src.loc
		for(var/i = 0, i<range, i++)
			target = get_step(target, WEST)
		user.setDir(WEST)
		user.Stun(4)
		user.pixel_y = 15
		user.layer = ABOVE_ALL_MOB_LAYER
		user.forceMove(get_turf(src.loc))
		sleep(3)
		user.pixel_x = -3
		sleep(3)
		user.pixel_x = -6
		sleep(3)
		user.pixel_x = -9
		sleep(3)
		user.pixel_x = -12
		playsound(user, "sound/effects/spring.ogg", 60, 1)
		sleep(3)
		user.pixel_y = 25
		sleep(5)
		user.pixel_y = 15
		playsound(user, "sound/effects/spring.ogg", 60, 1)
		sleep(5)
		user.pixel_y = 25
		sleep(5)
		user.pixel_y = 15
		playsound(user, "sound/effects/spring.ogg", 60, 1)
		sleep(5)
		user.pixel_y = 25
		playsound(user, "sound/effects/brrp.ogg", 15, 1)
		sleep(2)
		if(range == 1) user.visible_message("<span style=\"color:red\">You slip...</span>")
		user.layer = MOB_LAYER
		user.throw_at(target, 5, 1)
		user:weakened += 2
		user.pixel_y = 0
		user.pixel_x = 0
		playsound(user, "sound/effects/splash.ogg", 60, 1)
		user.Stun(0)
		in_use = 0
