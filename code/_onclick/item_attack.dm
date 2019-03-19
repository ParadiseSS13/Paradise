/obj/item/proc/melee_attack_chain(mob/user, atom/target, params)
	if(pre_attackby(target, user, params))
		// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
		var/resolved = target.attackby(src, user, params)
		if(!resolved && target && !QDELETED(src))
			afterattack(target, user, 1, params) // 1: clicking something Adjacent

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) & COMPONENT_NO_INTERACT)
		return
	return

/obj/item/proc/pre_attackby(atom/A, mob/living/user, params) //do stuff before attackby!
	return TRUE //return FALSE to avoid calling attackby after this proc does stuff

// No comment
/atom/proc/attackby(obj/item/W, mob/user, params)
	if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, W, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE

/obj/attackby(obj/item/I, mob/living/user, params)
	return ..() || (can_be_hit && isitem(I) && I.attack_obj(src, user))

/mob/living/attackby(obj/item/I, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(attempt_harvest(I, user))
		return 1
	return I.attack(src, user)

/obj/item/proc/attack(mob/living/M, mob/living/user, def_zone)
	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, user)
	if(flags & (NOBLUDGEON))
		return 0
	if(check_martial_counter(M, user))
		return 0
	if(can_operate(M))  //Checks if mob is lying down on table for surgery
		if(istype(src,/obj/item/robot_parts))//popup override for direct attach
			if(!attempt_initiate_surgery(src, M, user,1))
				return 0
			else
				return 1
		if(istype(src,/obj/item/organ/external))
			var/obj/item/organ/external/E = src
			if(E.is_robotic()) // Robot limbs are less messy to attach
				if(!attempt_initiate_surgery(src, M, user,1))
					return 0
				else
					return 1

		if(isscrewdriver(src) && ismachine(M) && user.a_intent == INTENT_HELP)
			if(!attempt_initiate_surgery(src, M, user))
				return 0
			else
				return 1
		if(is_sharp(src) && user.a_intent == INTENT_HELP)
			if(!attempt_initiate_surgery(src, M, user))
				return 0
			else
				return 1

	if(!force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)
	else
		SEND_SIGNAL(M, COMSIG_ITEM_ATTACK)
		if(hitsound)
			playsound(loc, hitsound, get_clamped_volume(), 1, -1)

	user.lastattacked = M
	M.lastattacker = user

	user.do_attack_animation(M)
	. = M.attacked_by(src, user, def_zone)

	add_attack_logs(user, M, "Attacked with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])", (M.ckey && force > 0 && damtype != STAMINA) ? null : ATKLOG_ALMOSTALL)

	add_fingerprint(user)


//the equivalent of the standard version of attack() but for object targets.
/obj/item/proc/attack_obj(obj/O, mob/living/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_OBJ, O, user) & COMPONENT_NO_ATTACK_OBJ)
		return
	if(flags & (NOBLUDGEON))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(O)
	O.attacked_by(src, user)

/atom/movable/proc/attacked_by()
	return

/obj/attacked_by(obj/item/I, mob/living/user)
	if(I.force)
		user.visible_message("<span class='danger'>[user] has hit [src] with [I]!</span>", "<span class='danger'>You hit [src] with [I]!</span>")
	take_damage(I.force, I.damtype, "melee", 1)

/mob/living/attacked_by(obj/item/I, mob/living/user, def_zone)
	send_item_attack_message(I, user)
	if(I.force)
		apply_damage(I.force, I.damtype, def_zone)
		if(I.damtype == BRUTE)
			if(prob(33))
				I.add_mob_blood(src)
				var/turf/location = get_turf(src)
				add_splatter_floor(location)
				if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(src)
		return TRUE //successful attack

/mob/living/simple_animal/attacked_by(obj/item/I, mob/living/user)
	if(!I.force)
		user.visible_message("<span class='warning'>[user] gently taps [src] with [I].</span>",\
						"<span class='warning'>This weapon is ineffective, it does no damage!</span>")
	else if(I.force < force_threshold || I.damtype == STAMINA)
		visible_message("<span class='warning'>[I] bounces harmlessly off of [src].</span>",\
					"<span class='warning'>[I] bounces harmlessly off of [src]!</span>")
	else
		return ..()

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return

/obj/item/proc/get_clamped_volume()
	if(w_class)
		if(force)
			return Clamp((force + w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		else
			return Clamp(w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/mob/living/proc/send_item_attack_message(obj/item/I, mob/living/user, hit_area)
	if(I.discrete)
		return
	var/message_verb = "attacked"
	if(I.attack_verb && I.attack_verb.len)
		message_verb = "[pick(I.attack_verb)]"
	else if(!I.force)
		return
	var/message_hit_area = ""
	if(hit_area)
		message_hit_area = " in the [hit_area]"
	var/attack_message = "[src] has been [message_verb][message_hit_area] with [I]."
	if(user in viewers(src, null))
		attack_message = "[user] has [message_verb] [src][message_hit_area] with [I]!"
	visible_message("<span class='combat danger'>[attack_message]</span>",\
		"<span class='combat userdanger'>[attack_message]</span>")
	return 1
