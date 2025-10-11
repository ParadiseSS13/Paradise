/**
 * This is the proc that handles the order of an item_attack.
 *
 * The order of procs called is:
 * * [/atom/proc/base_item_interaction] on the target. If it returns ITEM_INTERACT_COMPLETE, the chain will be stopped.
 *   If it returns ITEM_INTERACT_SKIP_TO_AFTER_ATTACK, all attack chain steps except after-attack will be skipped.
 * * [/obj/item/proc/pre_attack] on `src`. If this returns FINISH_ATTACK, the chain will be stopped.
 * * [/atom/proc/attack_by] on the target. If it returns FINISH_ATTACK, the chain will be stopped.
 * * [/obj/item/proc/after_attack]. The return value does not matter.
 *
 * Currently the return value of this proc is not checked anywhere, and is only used when short-circuiting the rest of the item attack.
 */
/obj/item/proc/melee_attack_chain(mob/user, atom/target, params, proximity_flag = 1)
	// TODO: Look into whether proxy attackers are worth porting from /tg/: https://github.com/tgstation/tgstation/pull/83860
	var/list/modifiers = params2list(params)

	var/item_interact_result = target.base_item_interaction(user, src, modifiers)
	switch(item_interact_result)
		if(ITEM_INTERACT_COMPLETE)
			return
		if(ITEM_INTERACT_SKIP_TO_AFTER_ATTACK)
			__after_attack_core(user, target, params, proximity_flag)
			return

	// Attack phase
	var/pre_attack_result = pre_attack(target, user, params)
	if(pre_attack_result & MELEE_COOLDOWN_PREATTACK)
		user.changeNext_move(CLICK_CD_MELEE)
	if(pre_attack_result & FINISH_ATTACK)
		return

	var/resolved = target.new_attack_chain \
		? target.attack_by(src, user, params) \
		: target.attackby__legacy__attackchain(src, user, params)

	// We were asked to cancel the rest of the attack chain.
	if(resolved)
		return

	// At this point it means the attack was "successful", or at least
	// handled, in some way. This can mean nothing happened, this can mean the
	// target took damage, etc.
	__after_attack_core(user, target, params, proximity_flag)


/// Called when the item is in the active hand, and clicked; alternately, there
/// is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/activate_self(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(SEND_SIGNAL(src, COMSIG_ACTIVATE_SELF, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FINISH_ATTACK

/**
 * Called on ourselves before we hit something. Return TRUE to cancel the remainder of the attack chain.
 *
 * Arguments:
 * * atom/target - The atom about to be hit
 * * mob/living/user - The mob doing the htting
 * * params - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/obj/item/proc/pre_attack(atom/target, mob/living/user, params)
	SHOULD_CALL_PARENT(TRUE)

	if(SEND_SIGNAL(src, COMSIG_PRE_ATTACK, target, user, params) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

	// TODO: Turn this into a component and have a sane implementation instead of extra-specific behavior in a core proc
	var/temperature = get_heat()
	if(temperature && target.reagents && !ismob(target) && !istype(target, /obj/item/clothing/mask/cigarette))
		var/reagent_temp = target.reagents.chem_temp
		var/time = (reagent_temp / 10) / (temperature / 1000)
		if(user.mind && HAS_TRAIT(user.mind, TRAIT_QUICK_HEATER))
			while(do_after_once(user, time, TRUE, user, TRUE, attempt_cancel_message = "You stop heating up [target]."))
				to_chat(user, "<span class='notice'>You heat [target] with [src].</span>")
				target.reagents.temperature_reagents(temperature)
		else
			if(do_after_once(user, time, TRUE, user, TRUE, attempt_cancel_message = "You stop heating up [target]."))
				to_chat(user, "<span class='notice'>You heat [target] with [src].</span>")
				target.reagents.temperature_reagents(temperature)

/**
 * Called when mob `user` is hitting us with an item `attacking`.
 * Part of the [/obj/item/proc/melee_attack_chain].
 *
 * Handles calling [/atom/proc/attack] or [/obj/item/proc/attack_obj] as necessary.
 *
 * Arguments:
 * * obj/item/attacking_item - The item hitting this atom
 * * mob/user - The wielder of this item
 * * params - click params such as alt/shift etc
 *
 * Handles [COMSIG_ATTACK_BY] returning [COMPONENT_SKIP_AFTERATTACK].
 * Returns [FINISH_ATTACK] if the attack chain should stop here.
 */
/atom/proc/attack_by(obj/item/attacking, mob/user, params)
	SHOULD_CALL_PARENT(TRUE)

	if(SEND_SIGNAL(src, COMSIG_ATTACK_BY, attacking, user, params) & COMPONENT_SKIP_AFTERATTACK)
		return FINISH_ATTACK

/obj/attack_by(obj/item/attacking, mob/user, params)
	if(!attacking.new_attack_chain)
		return attackby__legacy__attackchain(attacking, user, params)

	. = ..()

	if(.)
		return FINISH_ATTACK

	if(!can_be_hit)
		return

	return attacking.attack_obj(src, user, params)

/mob/living/attack_by(obj/item/attacking, mob/living/user, params)
	if(..())
		return TRUE
	user.changeNext_move(CLICK_CD_MELEE)

	if(attempt_harvest(attacking, user))
		return TRUE

	if(attacking.new_attack_chain)
		return attacking.attack(src, user, params)

	return attacking.attack__legacy__attackchain(src, user)

/**
 * Called when we are used by `user` to attack the living `target`.
 *
 * Returns `TRUE` if the rest of the attack chain should be cancelled. This may occur if the attack failed for some reason.
 * Returns `FALSE` if the attack was "successful" or "handled" in some way, and the rest of the attack chain should still fire.
 */
/obj/item/proc/attack(mob/living/target, mob/living/user, params)
	SHOULD_CALL_PARENT(TRUE)

	var/signal_return = SEND_SIGNAL(src, COMSIG_ATTACK, target, user, params) \
		|| SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, target, user, params)

	if(signal_return & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FINISH_ATTACK

	if(signal_return & COMPONENT_SKIP_ATTACK)
		return FALSE

	// Legacy attack uses TRUE to signal continuing the chain and FALSE otherwise;
	// New attack chain flips that around. Horrible.
	. = !__attack_core(target, user)
	if(!.)
		target.attacked_by(src, user)

/obj/item/proc/__after_attack_core(mob/user, atom/target, params, proximity_flag = 1)
	PRIVATE_PROC(TRUE)

	// TODO: `target` here should probably be another `!QDELETED` check.
	// Preserved for backwards compatibility, may be fixed post-migration.
	if(target && !QDELETED(src))
		if(new_attack_chain)
			after_attack(target, user, proximity_flag, params)
		else
			afterattack__legacy__attackchain(target, user, proximity_flag, params)

/obj/item/proc/__attack_core(mob/living/target, mob/living/user)
	PRIVATE_PROC(TRUE)

	if(flags & (NOBLUDGEON))
		return FALSE

	// TODO: Migrate all of this to the proper objects so it's not clogging up a core proc and called at irrelevant times
	if((is_surgery_tool_by_behavior(src) || is_organ(src) || tool_behaviour) && user.a_intent == INTENT_HELP && on_operable_surface(target) && target != user)
		to_chat(user, "<span class='notice'>You don't want to harm the person you're trying to help!</span>")
		return FALSE

	if(force && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
		return FALSE

	if(!force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1)
	else
		SEND_SIGNAL(target, COMSIG_ATTACK)
		add_attack_logs(user, target, "Attacked with [name] ([uppertext(user.a_intent)]) ([uppertext(damtype)])", (target.ckey && force > 0 && damtype != STAMINA) ? null : ATKLOG_ALMOSTALL)
		if(hitsound)
			playsound(loc, hitsound, get_clamped_volume(), TRUE, extrarange = stealthy_audio ? SILENCED_SOUND_EXTRARANGE : -1, falloff_distance = 0)

	target.store_last_attacker(user)
	user.do_attack_animation(target)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.check_shields(src, force, "[user]'s [name]", MELEE_ATTACK))
			return FALSE
	add_fingerprint(user)

	return TRUE

/// The equivalent of the standard version of [/obj/item/proc/attack] but for non mob targets.
/obj/item/proc/attack_obj(obj/attacked_obj, mob/living/user, params)
	var/signal_return = SEND_SIGNAL(src, COMSIG_ATTACK_OBJ, attacked_obj, user) | SEND_SIGNAL(user, COMSIG_ATTACK_OBJ_LIVING, attacked_obj)
	if(signal_return & COMPONENT_SKIP_ATTACK)
		return TRUE
	if(signal_return & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FALSE
	if(flags & NOBLUDGEON)
		return FALSE

	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(attacked_obj)

	if(attacked_obj.new_attack_chain)
		attacked_obj.attacked_by(src, user)
	else
		attacked_obj.attacked_by__legacy__attackchain(src, user)

/**
 * Called *after* we have been attacked with the item `attacker` by `user`.
 *
 * Return value is ignored for purposes of the attack chain.
 */
/atom/proc/attacked_by(obj/item/attacker, mob/living/user)
	return

/obj/attacked_by(obj/item/attacker, mob/living/user)
	var/damage = attacker.force
	if(attacker.force)
		user.visible_message(
			"<span class='danger'>[user] has hit [src] with [attacker]!</span>",
			"<span class='danger'>You hit [src] with [attacker]!</span>",
			"<span class='danger'>You hear something being struck by a weapon!</span>"
		)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		damage += H.physiology.melee_bonus
	take_damage(damage, attacker.damtype, MELEE, 1)

/mob/living/attacked_by(obj/item/attacker, mob/living/user, def_zone)
	send_item_attack_message(attacker, user)
	if(attacker.force)
		var/bonus_damage = 0
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			bonus_damage = H.physiology.melee_bonus
		apply_damage(attacker.force + bonus_damage, attacker.damtype, def_zone)
		if(attacker.damtype == BRUTE)
			if(prob(33))
				attacker.add_mob_blood(src)
				var/turf/location = get_turf(src)
				add_splatter_floor(location)
				if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(src)

/mob/living/simple_animal/attacked_by(obj/item/attacker, mob/living/user)
	if(!attacker.force)
		user.visible_message(
			"<span class='notice'>[user] gently taps [src] with [attacker].</span>",
			"<span class='warning'>This weapon is ineffective, it does no damage!</span>",
			"<span class='notice'>You hear a gentle tapping.</span>"
		)

	else if(attacker.force < force_threshold || attacker.damtype == STAMINA)
		visible_message(
			"<span class='warning'>[attacker] bounces harmlessly off of [src].</span>",
			"<span class='warning'>[attacker] bounces harmlessly off of [src]!</span>",
			"<span class='warning'>You hear something being struck by a weapon!</span>"
		)

	else
		return ..()

/**
 * Last proc in the [/obj/item/proc/melee_attack_chain].
 *
 * Arguments:
 * * atom/target - The thing that was hit
 * * mob/user - The mob doing the hitting
 * * proximity_flag - is 1 if this afterattack was called on something adjacent, in your square, or on your person.
 * * click_parameters - is the params string from byond [/atom/proc/Click] code, see that documentation.
 */
/obj/item/proc/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	SHOULD_CALL_PARENT(TRUE)

	SEND_SIGNAL(src, COMSIG_AFTER_ATTACK, target, user, proximity_flag, click_parameters)
	SEND_SIGNAL(target, COMSIG_AFTER_ATTACKED_BY, src, user, proximity_flag, click_parameters)

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

/// Used for signal registrars who wish to completely ignore all behavior
/// in the attack chain from parent types. Should be used sparingly, as
/// subtypes are meant to build on behavior from the parent type.
/datum/proc/signal_cancel_activate_self(mob/user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Used for signal registrars who wish to completely ignore all behavior
/// in the attack chain from parent types calling `attack_by`. Should be
/// used sparingly, as subtypes are meant to build on behavior from the parent
/// type.
/datum/proc/signal_cancel_attack_by(datum/source, obj/item/attacking, mob/user, params)
	return COMPONENT_SKIP_AFTERATTACK
