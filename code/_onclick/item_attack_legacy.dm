/atom/movable/proc/attacked_by__legacy__attackchain()
	return

/obj/attacked_by__legacy__attackchain(obj/item/I, mob/living/user)
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

/mob/living/attacked_by__legacy__attackchain(obj/item/I, mob/living/user, def_zone)
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

/mob/living/simple_animal/attacked_by__legacy__attackchain(obj/item/I, mob/living/user)
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

/obj/item/proc/attack__legacy__attackchain(mob/living/M, mob/living/user, def_zone)
	if(SEND_SIGNAL(src, COMSIG_ATTACK, M, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
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
		SEND_SIGNAL(M, COMSIG_ATTACK)
		add_attack_logs(user, M, "Attacked with [name] ([uppertext(user.a_intent)]) ([uppertext(damtype)])", (M.ckey && force > 0 && damtype != STAMINA) ? null : ATKLOG_ALMOSTALL)
		if(hitsound)
			playsound(loc, hitsound, get_clamped_volume(), TRUE, extrarange = stealthy_audio ? SILENCED_SOUND_EXTRARANGE : -1, falloff_distance = 0)

	M.lastattacker = user.real_name
	M.lastattackerckey = user.ckey

	user.do_attack_animation(M)
	. = M.attacked_by__legacy__attackchain(src, user, def_zone)

	add_fingerprint(user)

/**
 * Called when `user` attacks us with item `W`.
 *
 * Handles [COMSIG_ATTACK_BY] returning [COMPONENT_SKIP_AFTERATTACK].
 * Returns TRUE if afterattack should not be called, FALSE otherwise.
 *
 * New uses of this proc are prohibited! Use [/atom/proc/attackby] or [/atom/proc/base_item_interaction] instead!
 * If you are modifiying an existing implementation of this proc, it is expected that you replace it with the proper alternative!
 */
/atom/proc/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(SEND_SIGNAL(src, COMSIG_ATTACK_BY, W, user, params) & COMPONENT_SKIP_AFTERATTACK)
		return TRUE
	return FALSE

/obj/attackby__legacy__attackchain(obj/item/I, mob/living/user, params)
	return ..() || (can_be_hit && I.attack_obj__legacy__attackchain(src, user, params))

/mob/living/attackby__legacy__attackchain(obj/item/I, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(attempt_harvest(I, user))
		return TRUE

	if(I.new_attack_chain)
		return I.attack(src, user, params)

	return I.attack__legacy__attackchain(src, user)

/**
 * Called when `user` attacks us with object `O`.
 *
 * Handles [COMSIG_ATTACK_OBJ] returning [COMPONENT_NO_ATTACK_OBJ].
 * Returns FALSE if the attack isn't valid.
 *
 * New uses of this proc are prohibited! Use [/obj/item/proc/attack_atom] or [/atom/proc/base_item_interaction] instead!
 * If you are modifiying an existing implementation of this proc, it is expected that you replace it with the proper alternative!
 */
/obj/item/proc/attack_obj__legacy__attackchain(obj/O, mob/living/user, params)
	if(SEND_SIGNAL(src, COMSIG_ATTACK_OBJ, O, user) & COMPONENT_NO_ATTACK_OBJ)
		return FALSE
	if(flags & (NOBLUDGEON))
		return FALSE
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(O)
	O.attacked_by(src, user)

/**
 * Called when `user` has us in the active hand, and has clicked on us.
 *
 * Handles [COMSIG_ACTIVATE_SELF] returning [COMPONENT_NO_INTERACT].
 * Returns TRUE if a listener has requested the attack chain be cancelled.
 *
 * New uses of this proc are prohibited! Use [/obj/item/proc/activate_self].
 * If you are modifiying an existing implementation of this proc, it is expected that you replace it with the proper alternative!
 */
/obj/item/proc/attack_self__legacy__attackchain(mob/user)
	var/signal_ret = SEND_SIGNAL(src, COMSIG_ACTIVATE_SELF, user)
	if(signal_ret & COMPONENT_NO_INTERACT)
		return
	if(signal_ret & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

/**
 * Last proc in the [/obj/item/proc/melee_attack_chain].
 *
 * Sends [COMSIG_AFTER_ATTACK] and [COMSIG_AFTER_ATTACKED_BY], handling no responses.
 * New uses of this proc are prohibited! attack() calls on mobs and objects handle sending these signals.
 *
 * Arguments:
 * * atom/target - The thing that was hit
 * * mob/user - The mob doing the hitting
 * * proximity_flag - is 1 if this afterattack was called on something adjacent, in your square, or on your person.
 * * click_parameters - is the params string from byond [/atom/proc/Click] code, see that documentation.
 */
/obj/item/proc/afterattack__legacy__attackchain(atom/target, mob/user, proximity_flag, params)
	SEND_SIGNAL(src, COMSIG_AFTER_ATTACK, target, user, proximity_flag, params)
	SEND_SIGNAL(target, COMSIG_AFTER_ATTACKED_BY, src, user, proximity_flag, params)
