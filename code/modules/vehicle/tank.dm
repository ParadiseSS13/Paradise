/obj/vehicle/tank
	name = "tank"
	icon = 'icons/vehicles/tanks.dmi'
	icon_state = "tank_green"
	desc = "A tank belonging to the green army"
	vehicle_move_delay = 3
	var/allow_fire = 0
	var/recoil_delay = 10
	var/resume_move = 10
	var/datum/action/innate/fire_cannon/fire_cannon_action = new


/obj/vehicle/tank/handle_vehicle_layer()
	layer = MOB_LAYER + 0.1


/obj/vehicle/tank/handle_vehicle_offsets()
	..()
	if(buckled_mob)
		switch(buckled_mob.dir)
			if(NORTH, SOUTH)
				buckled_mob.pixel_y = 4
			if(EAST, WEST)
				buckled_mob.pixel_y = 2


/obj/vehicle/tank/proc/GrantActions(mob/living/carbon/buckled_mob)
	if(allow_fire)
		fire_cannon_action.target = src
		fire_cannon_action.Grant(buckled_mob)


/datum/action/innate/fire_cannon
	name = "Fire cannon"
	button_icon_state = "fireball"
	var/next_firetime = 50


/datum/action/innate/fire_cannon/Activate()
	var/obj/vehicle/tank/T = target
	var/bullet_type = /obj/item/projectile/bullet/gyro
	var/turf/curloc = get_turf(target)
	var/fire_delay = 50


	if(next_firetime > world.time)
		to_chat(owner, "<span class='warning'>Your weapons are recharging.</span>")
		return


	var/obj/item/projectile/A = new bullet_type(curloc)
	var/turf/start = get_turf(T)
	var/turf/MT = get_step(T, T.dir)


	A.original = MT
	A.current = start
	A.yo = MT.y - start.y
	A.xo = MT.x - start.x
	A.fire()
	next_firetime = world.time + fire_delay
	T.resume_move = world.time + T.recoil_delay


/obj/vehicle/tank/Move(atom/OldLoc, Dir)
	if(resume_move > world.time)
		return
	..()


/obj/vehicle/tank/buckle_mob(mob/living/M)
	..()
	GrantActions(buckled_mob)


/obj/vehicle/tank/unbuckle_mob(mob/living/M)
	fire_cannon_action.Remove(buckled_mob)
	..()


/obj/vehicle/tank/Destroy()
	fire_cannon_action.Remove(buckled_mob)
	return ..()
