/obj/item/proc/melee_attack_chain(mob/user, atom/target, params)
	if(!tool_attack_chain(user, target) && pre_attack(target, user, params))
		// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
		var/resolved = target.attackby(src, user, params)
		if(!resolved && target && !QDELETED(src))
			afterattack(target, user, 1, params) // 1: clicking something Adjacent

//Checks if the item can work as a tool, calling the appropriate tool behavior on the target
//Note that if tool_act returns TRUE, then the tool won't call attack_by.
/obj/item/proc/tool_attack_chain(mob/user, atom/target)
	if(!tool_behaviour)
		return FALSE
	if(SEND_SIGNAL(target, COMSIG_TOOL_ATTACK, src, user) & COMPONENT_CANCEL_TOOLACT)
		return FALSE

	return target.tool_act(user, src, tool_behaviour)

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	var/signal_ret = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user)
	if(signal_ret & COMPONENT_NO_INTERACT)
		return
	if(signal_ret & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

/obj/item/proc/pre_attack(atom/A, mob/living/user, params) //do stuff before attackby!
	if(SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK, A, user, params) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

	if(SEND_SIGNAL(A, COMSIG_ITEM_BEING_ATTACKED, src, user, params) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

	var/temperature = get_heat()
	if(temperature && A.reagents && !ismob(A) && !istype(A, /obj/item/clothing/mask/cigarette))
		var/reagent_temp = A.reagents.chem_temp
		var/time = (reagent_temp / 10) / (temperature / 1000)
		if(do_after_once(user, time, TRUE, user, TRUE, attempt_cancel_message = "You stop heating up [A]."))
			to_chat(user, "<span class='notice'>You heat [A] with [src].</span>")
			A.reagents.temperature_reagents(temperature)
	return TRUE //return FALSE to avoid calling attackby after this proc does stuff

// No comment
/atom/proc/attackby(obj/item/W, mob/user, params)
	if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, W, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE

/obj/attackby(obj/item/I, mob/living/user, params)
	return ..() || (can_be_hit && I.attack_obj(src, user, params))

/mob/living/attackby(obj/item/I, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(attempt_harvest(I, user))
		return TRUE
	return I.attack(src, user)

/obj/item/proc/attack(mob/living/M, mob/living/user, def_zone)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, user)
	if(flags & (NOBLUDGEON))
		return FALSE

	if((is_surgery_tool_by_behavior(src) || is_organ(src) || tool_behaviour) && user.a_intent == INTENT_HELP && on_operable_surface(M) && M != user)
		to_chat(user, "<span class='notice'>You don't want to harm the person you're trying to help!</span>")
		return

	if(force && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
		return

	if(!force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1)
	else
		SEND_SIGNAL(M, COMSIG_ITEM_ATTACK)
		add_attack_logs(user, M, "Attacked with [name] ([uppertext(user.a_intent)]) ([uppertext(damtype)])", (M.ckey && force > 0 && damtype != STAMINA) ? null : ATKLOG_ALMOSTALL)
		if(hitsound)
			playsound(loc, hitsound, get_clamped_volume(), TRUE, extrarange = stealthy_audio ? SILENCED_SOUND_EXTRARANGE : -1, falloff_distance = 0)

	M.lastattacker = user.real_name
	M.lastattackerckey = user.ckey

	user.do_attack_animation(M)
	. = M.attacked_by(src, user, def_zone)

	add_fingerprint(user)

//the equivalent of the standard version of attack() but for object targets.
/obj/item/proc/attack_obj(obj/O, mob/living/user, params)
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
	var/damage = I.force
	if(I.force)
		user.visible_message(
			"<span class='danger'>[user] has hit [src] with [I]!</span>",
			"<span class='danger'>You hit [src] with [I]!</span>",
			"<span class='danger'>You hear something being struck by a weapon!</span>"
		)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		damage += H.physiology.melee_bonus
	take_damage(damage, I.damtype, MELEE, 1)

/mob/living/attacked_by(obj/item/I, mob/living/user, def_zone)
	send_item_attack_message(I, user)
	if(I.force)
		var/bonus_damage = 0
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			bonus_damage = H.physiology.melee_bonus
		apply_damage(I.force + bonus_damage, I.damtype, def_zone)
		if(I.damtype == BRUTE)
			if(prob(33))
				I.add_mob_blood(src)
				var/turf/location = get_turf(src)
				add_splatter_floor(location)
				if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(src)

/mob/living/simple_animal/attacked_by(obj/item/I, mob/living/user)
	if(!I.force)
		user.visible_message(
			"<span class='notice'>[user] gently taps [src] with [I].</span>",
			"<span class='warning'>This weapon is ineffective, it does no damage!</span>",
			"<span class='notice'>You hear a gentle tapping.</span>"
		)

	else if(I.force < force_threshold || I.damtype == STAMINA)
		visible_message(
			"<span class='warning'>[I] bounces harmlessly off of [src].</span>",
			"<span class='warning'>[I] bounces harmlessly off of [src]!</span>",
			"<span class='warning'>You hear something being struck by a weapon!</span>"
		)

	else
		return ..()

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)

/obj/item/proc/get_clamped_volume()
	if(w_class)
		if(force)
			return clamp((force + w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		else
			return clamp(w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/mob/living/proc/send_item_attack_message(obj/item/I, mob/living/user, hit_area)
	if(I.discrete)
		return
	var/message_verb = "attacked"
	if(I.attack_verb && length(I.attack_verb))
		message_verb = "[pick(I.attack_verb)]"
	else if(!I.force)
		return
	var/message_hit_area = ""
	if(hit_area)
		message_hit_area = " in the [hit_area]"
	var/attack_message = "[src] has been [message_verb][message_hit_area] with [I]."
	if(user in viewers(src, null))
		attack_message = "[user] has [message_verb] [src][message_hit_area] with [I]!"
	visible_message(
		"<span class='combat danger'>[attack_message]</span>",
		"<span class='combat userdanger'>[attack_message]</span>",
		"<span class='combat danger'>You hear someone being attacked with a weapon!</span>"
	)
	return TRUE
