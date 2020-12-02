/obj/item/shield/attack(mob/target, mob/living/user)
	if(user.a_intent == INTENT_DISARM)
		if(!target.incapacitated() || !target.lying)
			var/atom/throw_target = get_edge_target_turf(target, user.dir)
			target.throw_at(throw_target, 1, 14, user, FALSE)
			user.do_attack_animation(target)
			playsound(get_turf(target), 'sound//weapons/baseball_hit.ogg', 80, 1, -1)
			target.visible_message("<span class='warning'>[user] pushed away [target] with the [src]!</span>", \
						  "<span class='userdanger'>[user] bashs with his [src] shoving you away!</span>")
			return
	..()
