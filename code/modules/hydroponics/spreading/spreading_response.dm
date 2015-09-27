/obj/effect/plant/HasProximity(var/atom/movable/AM)

	if(!is_mature() || seed.get_trait(TRAIT_SPREAD) != 2)
		return

	var/mob/living/M = AM
	if(!istype(M))
		return

	if(!buckled_mob && !M.buckled && !M.anchored && (M.small || prob(round(seed.get_trait(TRAIT_POTENCY)/6))))
		//wait a tick for the Entered() proc that called HasProximity() to finish (and thus the moving animation),
		//so we don't appear to teleport from two tiles away when moving into a turf adjacent to vines.
		spawn(1)
			entangle(M)

/obj/effect/plant/attack_hand(mob/user as mob)
	// Todo, cause damage.
	user_unbuckle_mob(user, user)

/obj/effect/plant/proc/trodden_on(var/mob/living/victim)
	if(!is_mature())
		return
	var/mob/living/carbon/human/H = victim
	if(istype(H) && H.shoes)
		return
	seed.do_thorns(victim,src)
	seed.do_sting(victim,src,pick("r_foot","l_foot","r_leg","l_leg"))


/obj/effect/plant/proc/entangle(var/mob/living/victim)

	if(buckled_mob)
		return

	if(victim.buckled)
		return

	//grabbing people
	if(!victim.anchored && Adjacent(victim) && victim.loc != get_turf(src))
		var/can_grab = 1
		if(istype(victim, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = victim
			if(istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.flags & NOSLIP))
				can_grab = 0
		if(can_grab)
			src.visible_message("<span class='danger'>Tendrils lash out from \the [src] and drag \the [victim] in!</span>")
			victim.loc = src.loc

	//entangling people
	if(victim.loc == src.loc)
		victim << "<span class='danger'>Tendrils [pick("wind", "tangle", "tighten")] around you!</span>"
		can_buckle = 1
		buckle_mob(victim)