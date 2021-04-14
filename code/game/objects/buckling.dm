/atom/movable
	var/can_buckle = FALSE
	var/buckle_lying = -1 //bed-like behaviour, forces mob.lying = buckle_lying if != -1
	var/buckle_requires_restraints = 0 //require people to be handcuffed before being able to buckle. eg: pipes
	var/list/buckled_mobs = null //list()
	var/buckle_offset = 0
	var/max_buckled_mobs = 1
	var/buckle_prevents_pull = FALSE

//Interaction
/atom/movable/attack_hand(mob/living/user)
	. = ..()
	if(can_buckle && has_buckled_mobs())
		if(length(buckled_mobs) > 1)
			var/unbuckled = input(user, "Who do you wish to unbuckle?", "Unbuckle Who?") as null|mob in buckled_mobs
			if(user_unbuckle_mob(unbuckled,user))
				return TRUE
		else
			if(user_unbuckle_mob(buckled_mobs[1], user))
				return TRUE

/atom/movable/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(can_buckle && istype(M) && istype(user))
		if(user_buckle_mob(M, user))
			return TRUE

/atom/movable/proc/has_buckled_mobs()
	return length(buckled_mobs)

/atom/movable/attack_robot(mob/living/user)
	. = ..()
	if(can_buckle && has_buckled_mobs() && Adjacent(user)) // attack_robot is called on all ranges, so the Adjacent check is needed
		if(length(buckled_mobs) > 1)
			var/unbuckled = input(user, "Who do you wish to unbuckle?", "Unbuckle Who?") as null|mob in buckled_mobs
			if(user_unbuckle_mob(unbuckled,user))
				return TRUE
		else
			if(user_unbuckle_mob(buckled_mobs[1], user))
				return TRUE


//procs that handle the actual buckling and unbuckling
/atom/movable/proc/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!buckled_mobs)
		buckled_mobs = list()

	if(!istype(M))
		return FALSE

	if(check_loc && M.loc != loc)
		return FALSE

	if((!can_buckle && !force) || M.buckled || (length(buckled_mobs) >= max_buckled_mobs) || (buckle_requires_restraints && !M.restrained()) || M == src)
		return FALSE
	M.buckling = src
	if(!M.can_buckle() && !force)
		if(M == usr)
			to_chat(M, "<span class='warning'>You are unable to buckle yourself to [src]!</span>")
		else
			to_chat(usr, "<span class='warning'>You are unable to buckle [M] to [src]!</span>")
		M.buckling = null
		return FALSE

	if(M.pulledby)
		if(buckle_prevents_pull)
			M.pulledby.stop_pulling()

	for(var/obj/item/grab/G in M.grabbed_by)
		qdel(G)

	if(!check_loc && M.loc != loc)
		M.forceMove(loc)

	M.buckling = null
	M.buckled = src
	M.setDir(dir)
	buckled_mobs |= M
	M.update_canmove()
	M.throw_alert("buckled", /obj/screen/alert/restrained/buckled)
	post_buckle_mob(M)

	SEND_SIGNAL(src, COMSIG_MOVABLE_BUCKLE, M, force)
	return TRUE

/obj/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	. = ..()
	if(.)
		if(resistance_flags & ON_FIRE) //Sets the mob on fire if you buckle them to a burning atom/movableect
			M.adjust_fire_stacks(1)
			M.IgniteMob()

/atom/movable/proc/unbuckle_mob(mob/living/buckled_mob, force = FALSE)
	if(istype(buckled_mob) && buckled_mob.buckled == src && (buckled_mob.can_unbuckle() || force))
		. = buckled_mob
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.update_canmove()
		buckled_mob.clear_alert("buckled")
		buckled_mobs -= buckled_mob
		SEND_SIGNAL(src, COMSIG_MOVABLE_UNBUCKLE, buckled_mob, force)

		post_unbuckle_mob(.)

/atom/movable/proc/unbuckle_all_mobs(force = FALSE)
	if(!has_buckled_mobs())
		return
	for(var/m in buckled_mobs)
		unbuckle_mob(m, force)

//Handle any extras after buckling
//Called on buckle_mob()
/atom/movable/proc/post_buckle_mob(mob/living/M)
	return

//same but for unbuckle
/atom/movable/proc/post_unbuckle_mob(mob/living/M)
	return

/atom/movable/proc/user_buckle_minorfail(mob/living/M, mob/user)
	M.forceMove(loc)
	M.visible_message("<span class='notice'>[M] fails to pull [M.p_them()]self up onto [src].</span>",\
		"<span class='warning'>You fail to climb onto [src]. Come on, you've got this!</span>",\
		"<span class='italics'>You hear someone grunting.</span>")

/atom/movable/proc/user_buckle_majorfail(mob/living/M, mob/user) //Knocks user out and does minor brute/brain damage
	M.StopResting()
	M.forceMove(loc) //All that effort wasn't for nothing!
	M.visible_message("<span class='warning'>[M]'s hand slips and they slam their forehead on [src]!</span>",\
		"<span class='danger'>SHIT! Your hand slips and you slam your forehead into [src]!</span>",\
		"<span class='italics'>You hear a thwack and a heavy thump.</span>")
	M.StartResting() //could if statement these lines down to playsound if you wanted this only to happen with certain seats
	M.adjustBrainLoss(10)
	M.Paralyse(5)
	M.apply_damage(50, STAMINA)
	M.apply_damage(15, BRUTE, "head")
	M.AdjustSleeping(1)
	playsound(src.loc, 'sound/items/trayhit1.ogg', 50, 0) //bonk

//Allows people to climb onto chairs if they're next to or under them and incapacitated but not stunned
//especially helpful for people with no legs. However it can fail on random chance based on how many hands they have
/atom/movable/proc/user_buckle_incapacitated(mob/living/M, mob/user, check_loc = TRUE)
	M.visible_message("<span class='warning'>[M] looks like they're attempting to pull [M.p_them()]self up onto [src].</span>",\
		"<span class='warning'>You attempt to climb onto [src].</span>",\
		"<span class='italics'>You hear someone grunting.</span>")
	var/buckle_chance = rand(1, 100)
	M.StartResting()
	if (user.has_both_hands())
		if(!in_range(user, src) || !isturf(user.loc) || M.anchored) //chair in range?
			return FALSE
		if (do_after(user, 2 SECONDS, target = src, use_default_checks=FALSE)) //Two hands
			if (buckle_chance <= 5)
				user_buckle_majorfail(M, user)
				return FALSE
			if (buckle_chance <= 25)
				user_buckle_minorfail(M, user)
				return FALSE
	else if (do_after(user, 5 SECONDS, target = src, use_default_checks=FALSE)) //One hand
		if(!in_range(user, src) || !isturf(user.loc) || M.anchored)
			return FALSE
		if (buckle_chance <= 20)
			user_buckle_majorfail(M, user)
			return FALSE
		if (buckle_chance <= 75)
			user_buckle_minorfail(M, user)
			return FALSE
	M.forceMove(loc)
	if (M.get_num_legs()) //people shouldn't go back to resting after unbuckling
		M.StopResting()
	M.visible_message("<span class='notice'>[M] pulls [M.p_them()]self up onto the [src].</span>",\
		"<span class='notice'>You pull yourself onto the [src].</span>",\
		"<span class='italics'>You hear someone grunting.</span>")
	return TRUE

//Wrapper procs that handle sanity and user feedback
/atom/movable/proc/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(!in_range(user, src) || !isturf(user.loc) || M.anchored)
		return FALSE

	if ((user.incapacitated() && !user.IsStunned()) && (user.has_right_hand() || user.has_left_hand()) && M == user)
		if (!user_buckle_incapacitated(M,user,TRUE))
			return FALSE
	else if (user.incapacitated())
		return FALSE
	add_fingerprint(user)
	. = buckle_mob(M, check_loc = check_loc)
	if(.)
		if(M == user)
			M.visible_message("<span class='notice'>[M] buckles [M.p_them()]self to [src].</span>",\
				"<span class='notice'>You buckle yourself to [src].</span>",\
				"<span class='italics'>You hear metal clanking.</span>")
		else
			M.visible_message("<span class='warning'>[user] buckles [M] to [src]!</span>",\
				"<span class='warning'>[user] buckles you to [src]!</span>",\
				"<span class='italics'>You hear metal clanking.</span>")

/atom/movable/proc/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	var/mob/living/M = unbuckle_mob(buckled_mob)
	if(M)
		if(M != user)
			M.visible_message("<span class='notice'>[user] unbuckles [M] from [src].</span>",\
				"<span class='notice'>[user] unbuckles you from [src].</span>",\
				"<span class='italics'>You hear metal clanking.</span>")
		else
			M.visible_message("<span class='notice'>[M] unbuckles [M.p_them()]self from [src].</span>",\
				"<span class='notice'>You unbuckle yourself from [src].</span>",\
				"<span class='italics'>You hear metal clanking.</span>")
		add_fingerprint(user)
	return M

/mob/living/proc/check_buckled()
	if(buckled && !(buckled in loc))
		buckled.unbuckle_mob(src, force = TRUE)
