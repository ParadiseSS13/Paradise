/obj/structure/stool/bed/chair/wheelchair
	name = "wheelchair"
	desc = "You sit in this. Either by will or force."
	icon_state = "wheelchair"
	anchored = 0
	movable = 1

	var/driving = 0
	var/mob/living/pulling = null
	var/bloodiness


/obj/structure/stool/bed/chair/wheelchair/handle_rotation()
	overlays = null
	var/image/O = image(icon = 'icons/obj/objects.dmi', icon_state = "w_overlay", layer = FLY_LAYER, dir = src.dir)
	overlays += O
	if(buckled_mob)
		buckled_mob.dir = dir

/obj/structure/stool/bed/chair/wheelchair/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis || user.lying || user.restrained())
		if(user==pulling)
			pulling = null
			user.pulledby = null
			user << "\red You lost your grip!"
		return
	if(user.pulling && (user == pulling))
		pulling = null
		user.pulledby = null
		return
	if(propelled)
		return
	if(pulling && (get_dist(src, pulling) > 1))
		pulling = null
		user.pulledby = null
		if(user==pulling)
			return
	if(pulling && (get_dir(src.loc, pulling.loc) == direction))
		user << "\red You cannot go there."
		return
	if(pulling && buckled_mob && (buckled_mob == user))
		user << "\red You cannot drive while being pushed."
		return

	// Let's roll
	driving = 1
	var/turf/T = null
	//--1---Move occupant---1--//
	if(buckled_mob)
		buckled_mob.buckled = null
		step(buckled_mob, direction)
		buckled_mob.buckled = src
	//--2----Move driver----2--//
	if(pulling)
		T = pulling.loc
		if(get_dist(src, pulling) >= 1)
			step(pulling, get_dir(pulling.loc, src.loc))
	//--3--Move wheelchair--3--//
	step(src, direction)
	if(buckled_mob) // Make sure it stays beneath the occupant
		Move(buckled_mob.loc)
	dir = direction
	handle_rotation()
	if(pulling) // Driver
		if(pulling.loc == src.loc) // We moved onto the wheelchair? Revert!
			pulling.loc = T
		else
			spawn(0)
			if(get_dist(src, pulling) > 1) // We are too far away? Losing control.
				pulling = null
				user.pulledby = null
			pulling.dir = get_dir(pulling, src) // When everything is right, face the wheelchair
	if(bloodiness)
		create_track()
	driving = 0

/obj/structure/stool/bed/chair/wheelchair/Move()
	..()
	if(buckled_mob)
		var/mob/living/occupant = buckled_mob
		if(!driving)
			occupant.buckled = null
			occupant.Move(src.loc)
			occupant.buckled = src
			if (occupant && (src.loc != occupant.loc))
				if (propelled)
					for (var/mob/O in src.loc)
						if (O != occupant)
							Bump(O)
				else
					unbuckle()
			if (pulling && (get_dist(src, pulling) > 1))
				pulling.pulledby = null
				pulling << "\red You lost your grip!"
				pulling = null
		else
			if (occupant && (src.loc != occupant.loc))
				src.loc = occupant.loc // Failsafe to make sure the wheelchair stays beneath the occupant after driving
	handle_rotation()

/obj/structure/stool/bed/chair/wheelchair/attack_hand(mob/user as mob)
	if (pulling)
		MouseDrop(usr)
	else
		manual_unbuckle(user)
	return

/obj/structure/stool/bed/chair/wheelchair/MouseDrop(over_object, src_location, over_location)
	..()
	if(over_object == usr && in_range(src, usr))
		if(!ishuman(usr))	return
		if(usr == buckled_mob)
			usr << "\red You realize you are unable to push the wheelchair you sit in."
			return
		if(!pulling)
			pulling = usr
			usr.pulledby = src
			if(usr.pulling)
				usr.stop_pulling()
			usr.dir = get_dir(usr, src)
			usr << "You grip \the [name]'s handles."
		else
			if(usr != pulling)
				for(var/mob/O in viewers(pulling, null))
					O.show_message("\red [usr] breaks [pulling]'s grip on the wheelchair.", 1)
			else
				usr << "You let go of \the [name]'s handles."
			pulling.pulledby = null
			pulling = null
		return

/obj/structure/stool/bed/chair/wheelchair/Bump(atom/A)
	..()
	if(!buckled_mob)	return

	if(propelled || (pulling && (pulling.a_intent == "harm")))
		var/mob/living/occupant = buckled_mob
		unbuckle()
		
		if (pulling && (pulling.a_intent == "hurt"))
			occupant.throw_at(A, 3, 3, pulling)
		else if (propelled)
			occupant.throw_at(A, 3, propelled)
		
		occupant.apply_effect(6, STUN, 0)
		occupant.apply_effect(6, WEAKEN, 0)
		occupant.apply_effect(6, STUTTER, 0)
		playsound(src.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
		if(istype(A, /mob/living))
			var/mob/living/victim = A
			victim.apply_effect(6, STUN, 0)
			victim.apply_effect(6, WEAKEN, 0)
			victim.apply_effect(6, STUTTER, 0)
			victim.take_organ_damage(10)
		if(pulling)
			occupant.visible_message("<span class='danger'>[pulling] has thrusted \the [name] into \the [A], throwing \the [occupant] out of it!</span>")

			pulling.attack_log += "\[[time_stamp()]\]<font color='red'> Crashed [occupant.name]'s ([occupant.ckey]) [name] into \a [A]</font>"
			occupant.attack_log += "\[[time_stamp()]\]<font color='orange'> Thrusted into \a [A] by [pulling.name] ([pulling.ckey]) with \the [name]</font>"
			msg_admin_attack("[pulling.name] ([pulling.ckey]) has thrusted [occupant.name]'s ([occupant.ckey]) [name] into \a [A] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[pulling.x];Y=[pulling.y];Z=[pulling.z]'>JMP</a>)")
		else
			occupant.visible_message("<span class='danger'>[occupant] crashed into \the [A]!</span>")

/obj/structure/stool/bed/chair/wheelchair/proc/create_track()
	var/obj/effect/decal/cleanable/blood/tracks/B = new(loc)
	var/newdir = get_dir(get_step(loc, dir), loc)
	if(newdir == dir)
		B.dir = newdir
	else
		newdir = newdir | dir
		if(newdir == 3)
			newdir = 1
		else if(newdir == 12)
			newdir = 4
		B.dir = newdir
	bloodiness--

/obj/structure/stool/bed/chair/wheelchair/buckle_mob(mob/M as mob, mob/user as mob)
	if(M == pulling)
		pulling = null
		usr.pulledby = null
	..()