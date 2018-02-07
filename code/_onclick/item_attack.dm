
// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	return

// No comment
/atom/proc/attackby(obj/item/W, mob/living/user, params)
	return

/atom/movable/attackby(obj/item/W, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(!(W.flags&NOBLUDGEON))
		visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")

/mob/living/attackby(obj/item/I, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(attempt_harvest(I, user))
		return
	I.attack(src, user)

/mob/living/proc/attacked_by(obj/item/I, mob/living/user, def_zone)
	apply_damage(I.force, I.damtype)
	if(I.damtype == "brute")
		if(prob(33) && I.force)
			add_splatter_floor()

	var/showname = "."
	if(user)
		showname = " by [user]!"
		user.do_attack_animation(src)
	if(!(user in viewers(I, null)))
		showname = "."

	if(I.attack_verb && I.attack_verb.len)
		visible_message("<span class='combat danger'>[src] has been [pick(I.attack_verb)] with [I][showname]</span>",
		"<span class='userdanger'>[src] has been [pick(I.attack_verb)] with [I][showname]</span>")
	else if(I.force)
		visible_message("<span class='combat danger'>[src] has been attacked with [I][showname]</span>",
		"<span class='userdanger'>[src] has been attacked with [I][showname]</span>")
	if(!showname && user)
		if(user.client)
			to_chat(user, "<span class='combat danger'>You attack [M] with [src]. </span>")

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return


/obj/item/proc/attack(mob/living/M, mob/living/user, def_zone)

	if(!istype(M)) // not sure if this is the right thing...
		return 0

	if(can_operate(M))  //Checks if mob is lying down on table for surgery
		if(istype(src,/obj/item/robot_parts))//popup override for direct attach
			if(!attempt_initiate_surgery(src, M, user,1))
				return 0
			else
				return 1
		if(istype(src,/obj/item/organ/external))
			var/obj/item/organ/external/E = src
			if(E.robotic == 2) // Robot limbs are less messy to attach
				if(!attempt_initiate_surgery(src, M, user,1))
					return 0
				else
					return 1

		if(isscrewdriver(src) && M.get_species() == "Machine")
			if(!attempt_initiate_surgery(src, M, user))
				return 0
			else
				return 1
		if(is_sharp(src))
			if(!attempt_initiate_surgery(src, M, user))
				return 0
			else
				return 1

	if(hitsound && force > 0) //If an item's hitsound is defined and the item's force is greater than zero...
		playsound(loc, hitsound, get_clamped_volume(), 1, -1) //...play the item's hitsound at get_clamped_volume() with varying frequency and -1 extra range.
	else if(force == 0)//Otherwise, if the item's force is zero...
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)//...play tap.ogg at get_clamped_volume()
	/////////////////////////
	user.lastattacked = M
	M.lastattacker = user
	add_logs(user, M, "attacked", name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])", print_attack_log = (force > 0))//print it if stuff deals damage

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	/////////////////////////

	M.attacked_by(src, user, def_zone)
	add_fingerprint(user)
	return 1

/obj/item/proc/get_clamped_volume()
	if(w_class)
		if(force)
			return Clamp((force + w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		else
			return Clamp(w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100