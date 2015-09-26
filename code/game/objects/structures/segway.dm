/obj/structure/stool/bed/chair/segway
	name = "security segway"
	desc = "Gives the illusion of authority."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "sec_seg_idle"
	anchored = 1
	density = 1

	var/health = 100
	var/delay = 3	//Move delay to simulate a speed
	var/allowMove = 1
	var/datum/global_iterator/space_move //Handling space movement (i.e. drift forever)

/obj/structure/stool/bed/chair/segway/New()
	handle_rotation()
	space_move = new /datum/global_iterator/space_movement(null,0)
	return

/obj/structure/stool/bed/chair/segway/user_buckle_mob(mob/living/M, mob/user)
	if(user.incapacitated()) //user can't move the mob on the janicart's turf if incapacitated
		return
	for(var/atom/movable/A in get_turf(src)) //we check for obstacles on the turf.
		if(A.density)
			if(A != src && A != M)
				return
	M.loc = loc //we move the mob on the janicart's turf before checking if we can buckle.
	..()

/obj/structure/stool/bed/chair/segway/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis)
		unbuckle_mob()
		icon_state = "sec_seg_idle"
	if(istype(user.l_hand, /obj/item/sec_seg_key) || istype(user.r_hand, /obj/item/sec_seg_key))
		if(!allowMove)
			return
		if(src.space_move.active())
			return
		allowMove = 0
		icon_state = "sec_seg_move"
		step(src, direction)
		update_mob()
		handle_rotation()
		if(istype(src.loc, /turf/space))
			src.space_move.start(list(src,direction))
		if(istype(src.loc, /turf/simulated))
			var/turf/simulated/T = src.loc
			if(T.wet == 2)	//Lube! Fall off!
				playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
				buckled_mob.Stun(8)
				buckled_mob.Weaken(5)
				unbuckle_mob()
				step(src, dir)
		sleep(delay)
		allowMove = 1
	else
		user << "<span class='notice'>Requires key in hand to drive.</span>"

/obj/structure/stool/bed/chair/segway/Move()
	. = ..()

/obj/structure/stool/bed/chair/segway/Bump(var/atom/obstacle)
	if(istype(obstacle, /mob))
		step(obstacle, src.dir)
	else
		obstacle.Bumped(src)
	return

/obj/structure/stool/bed/chair/segway/post_buckle_mob(mob/living/M)
	update_mob()
	add_fingerprint(M)
	M.pixel_x = 0
	M.pixel_y = 5
	return ..()

/obj/structure/stool/bed/chair/segway/unbuckle_mob()
	var/mob/living/M = ..()
	if(M)
		M.pixel_x = 0
		M.pixel_y = 0
	return M

/obj/structure/stool/bed/chair/segway/handle_rotation()
	if(dir == NORTH)
		layer = OBJ_LAYER
	else
		layer = FLY_LAYER

	update_mob()

/obj/structure/stool/bed/chair/segway/proc/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir

/obj/structure/stool/bed/chair/segway/bullet_act(var/obj/item/projectile/Proj)
	if(buckled_mob)
		return buckled_mob.bullet_act(Proj)
	else if(istype(Proj, /obj/item/projectile/beam))
		damage(Proj.damage)

/obj/structure/stool/bed/chair/segway/proc/damage(amount)
	health -= amount
	if(health <= 0)
		if(buckled_mob)
			buckled_mob << "The [src.name] was destroyed!"
		qdel(src)

/obj/item/sec_seg_key
	name = "security segway key"
	desc = "A key for a security segway. You feel the choice of keyring could be more professional."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys" 	//Needs a proper sprite
	w_class = 1

/datum/global_iterator/space_movement	//moon_theme.mp3
	delay = 5

	process(var/obj/structure/stool/bed/chair/segway/seg as obj,direction)
		if(!step(seg, direction))
			src.stop()


/obj/structure/stool/bed/chair/segway/snowmobile
	name = "red snowmobile"
	desc = "Wheeeeeeeeeeee."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "snowmobile"
	anchored = 1
	density = 1

/obj/structure/stool/bed/chair/segway/snowmobile/blue
	name = "blue snowmobile"
	desc = "Wheeeeeeeeeeee."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "bluesnowmobile"
	anchored = 1
	density = 1

/obj/structure/stool/bed/chair/segway/snowmobile/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis)
		unbuckle_mob()
	if(!allowMove)
		return
	if(src.space_move.active())
		return
	allowMove = 0
	step(src, direction)
	update_mob()
	handle_rotation()
	if(istype(src.loc, /turf/space))
		src.space_move.start(list(src,direction))
	if(istype(src.loc, /turf/simulated))
		damage(5)
		usr << "Your snowmobile takes damage from not being on snow!"
		var/turf/simulated/T = src.loc
		if(T && T.wet == 2)	//Lube! Fall off!
			playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
			buckled_mob.Stun(8)
			buckled_mob.Weaken(5)
			unbuckle_mob()
			step(src, dir)
	sleep(delay)
	allowMove = 1

