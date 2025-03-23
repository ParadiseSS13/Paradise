/**
 * Called after `user` has attacked us with item `W`.
 *
 * New uses of this proc are prohibited! Used [/atom/proc/attacked_by].
 * If you are modifiying an existing implementation of this proc, it is expected that you replace it with the proper alternative!
 */
/atom/proc/attacked_by__legacy__attackchain(obj/item/W, mob/living/user)
	return

/atom/movable/attacked_by__legacy__attackchain()
	return

/obj/attacked_by__legacy__attackchain(obj/item/I, mob/living/user)
	return attacked_by(I, user)

/obj/item/proc/attack__legacy__attackchain(mob/living/M, mob/living/user, def_zone)
	if(SEND_SIGNAL(src, COMSIG_ATTACK, M, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, user)

	. = __attack_core(M, user)
	if(.)
		M.attacked_by(src, user, def_zone)

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
	return ..() || (can_be_hit && (I.new_attack_chain \
		? I.attack_obj(src, user, params) \
		: I.attack_obj__legacy__attackchain(src, user, params)))

/**
 * Called when `user` attacks us with object `O`.
 *
 * Handles [COMSIG_ATTACK_OBJ] returning [COMPONENT_NO_ATTACK_OBJ].
 * Returns FALSE if the attack isn't valid.
 *
 * New uses of this proc are prohibited! Use [/obj/item/proc/interact_with_atom]
 * or [/atom/proc/base_item_interaction] if this is not meant to be an attack, and
 * [/obj/item/proc/attack_obj] if it is. If you are modifiying an existing
 * implementation of this proc, it is expected that you replace it with the proper
 * alternative!
 */
/obj/item/proc/attack_obj__legacy__attackchain(obj/O, mob/living/user, params)
	if(SEND_SIGNAL(src, COMSIG_ATTACK_OBJ, O, user) & COMPONENT_NO_ATTACK_OBJ)
		return FALSE
	if(flags & (NOBLUDGEON))
		return FALSE
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(O)

	if(O.new_attack_chain)
		O.attacked_by(src, user)
	else
		O.attacked_by__legacy__attackchain(src, user)

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
