/obj/vehicle/tank
	name = "tank"
	icon = 'icons/vehicles/tanks.dmi'
	icon_state = "tank_green"
	vehicle_move_delay = 4
	var/allow_fire = 0
	var/recoil_delay = 10
	var/resume_move = 10
	var/datum/action/innate/fire_cannon/fire_cannon_action = new


/obj/vehicle/tank/New()
	..()


/obj/vehicle/tank/handle_vehicle_layer()
	layer = MOB_LAYER+0.1


/obj/vehicle/tank/proc/GrantActions(mob/living/carbon/buckled_mob)
	if(allow_fire == 1)
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

	else
		var/obj/item/projectile/A = new bullet_type(curloc)
		A.dumbfire(owner.dir)
		next_firetime = world.time+fire_delay
		T.resume_move = world.time+T.recoil_delay


/obj/vehicle/tank/Move(atom/OldLoc, Dir)
	if(resume_move>world.time)
		return
	else
		..()

/obj/vehicle/tank/buckle_mob(mob/living/M)
	..()
	GrantActions(buckled_mob)


/obj/vehicle/tank/unbuckle_mob(mob/living/M)
	fire_cannon_action.Remove(buckled_mob)
	..()

/obj/vehicle/tank/tank_green
	name = "green tank"
	icon_state ="tank_green"
	desc = "A tank belonging to the green army"

/obj/vehicle/tank/tank_grey
	name = "grey tank"
	icon_state = "tank_grey"
	desc = "A tank belonging to the grey army"
