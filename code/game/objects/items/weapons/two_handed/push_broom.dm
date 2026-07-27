/// Max number of atoms a broom can sweep at once.
#define BROOM_PUSH_LIMIT 20

/obj/item/push_broom
	name = "push broom"
	desc = "This is my BROOMSTICK! It can be used manually or braced with two hands to sweep items as you move. It has a telescopic handle for compact storage."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "broom0"
	base_icon_state = "broom"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 8
	throwforce = 10
	throw_speed = 3
	attack_verb = list("swept", "brushed off", "bludgeoned", "whacked")
	resistance_flags = FLAMMABLE
	new_attack_chain = TRUE

/obj/item/push_broom/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, \
		_stamina_constant = 2, \
		_stamina_coefficient = 0.75, \
		_parryable_attack_types = MELEE_ATTACK, \
		_parry_cooldown = (7 / 3) SECONDS, \
		_requires_two_hands = TRUE)
	AddComponent(/datum/component/two_handed, \
		force_wielded = 12, \
		force_unwielded = force, \
		icon_wielded = "[base_icon_state]1", \
		wield_callback = CALLBACK(src, PROC_REF(wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(unwield)))

/obj/item/push_broom/update_icon_state()
	icon_state = "[base_icon_state]0"

/obj/item/push_broom/proc/wield(obj/item/source, mob/user)
	to_chat(user, SPAN_NOTICE("You brace [src] against the ground in a firm sweeping stance."))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(sweep))

/obj/item/push_broom/proc/unwield(obj/item/source, mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/obj/item/push_broom/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(isturf(target) || isitem(target))
		return ..()
	sweep(user, target, FALSE)
	add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/push_broom/proc/sweep(mob/user, atom/A, moving = TRUE)
	SIGNAL_HANDLER
	var/turf/current_item_loc = moving ? user.loc : (isturf(A) ? A : A.loc)
	if(!isturf(current_item_loc))
		return
	var/turf/new_item_loc = get_step(current_item_loc, user.dir)
	var/obj/machinery/disposal/target_bin = locate(/obj/machinery/disposal) in new_item_loc.contents
	var/obj/structure/janitorialcart/jani_cart = locate(/obj/structure/janitorialcart) in new_item_loc.contents
	var/obj/vehicle/janicart/jani_vehicle = locate(/obj/vehicle/janicart) in new_item_loc.contents
	var/trash_amount = 1
	for(var/obj/item/garbage in current_item_loc.contents)
		if(garbage.anchored)
			continue
		var/obj/item/storage/bag/trash/bag = jani_vehicle?.mybag || jani_cart?.my_bag
		var/obj/trashed_into
		if(bag?.can_be_inserted(garbage, TRUE))
			bag.handle_item_insertion(garbage, user, TRUE)
			trashed_into = bag
		else if(target_bin)
			move_into_storage(user, target_bin, garbage)
			trashed_into = target_bin
		else
			garbage.Move(new_item_loc, user.dir)
		if(trashed_into)
			to_chat(user, SPAN_NOTICE("You sweep the pile of garbage into [trashed_into]."))
		trash_amount++
		if(trash_amount > BROOM_PUSH_LIMIT)
			break
	if(trash_amount > 1)
		playsound(loc, 'sound/weapons/sweeping.ogg', 70, TRUE, -1)

/obj/item/push_broom/proc/move_into_storage(mob/user, obj/storage, obj/trash)
	trash.forceMove(storage)
	storage.update_icon()

/obj/item/push_broom/traitor
	name = "titanium push broom"
	desc = "This is my BROOMSTICK! All of the functionality of a normal broom, but at least half again more robust."
	attack_verb = list("smashed", "slammed", "whacked", "thwacked", "swept")
	force = 10

/obj/item/push_broom/traitor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, \
		_stamina_constant = 2, \
		_stamina_coefficient = 0.25, \
		_parryable_attack_types = ALL_ATTACK_TYPES, \
		_parry_cooldown = (4 / 3) SECONDS, \
		_requires_two_hands = TRUE) // 0.3333 seconds of cooldown for 75% uptime
	// parent component handles this
	AddComponent(/datum/component/two_handed, force_wielded = 25, force_unwielded = force)

/obj/item/push_broom/traitor/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += SPAN_WARNING("When wielded, the broom has different effects depending on your intent, similar to a martial art. \
			Help intent will sweep foes away from you, disarm intent sweeps their legs from under them, grab intent confuses \
			and minorly fatigues them, and harm intent hits them normally.")

/obj/item/push_broom/traitor/attack__legacy__attackchain(mob/target, mob/living/user)
	if(!HAS_TRAIT(src, TRAIT_WIELDED) || !ishuman(target))
		return ..()

	var/mob/living/carbon/human/human_target = target

	switch(user.a_intent)
		if(INTENT_HELP)
			human_target.visible_message(
				SPAN_DANGER("[user] sweeps [human_target] away!"),
				SPAN_USERDANGER("[user] sweeps you away!"),
				SPAN_HEAR("You hear sweeping.")
			)
			playsound(loc, 'sound/weapons/sweeping.ogg', 70, TRUE, -1)

			var/atom/throw_target = get_edge_target_turf(human_target, get_dir(src, get_step_away(human_target, src)))
			human_target.throw_at(throw_target, 3, 1)

			add_attack_logs(user, human_target, "Swept away with titanium push broom", ATKLOG_ALL)

		if(INTENT_DISARM)
			if(human_target.stat || IS_HORIZONTAL(human_target))
				return ..()

			human_target.visible_message(
				SPAN_DANGER("[user] sweeps [human_target]'s legs out from under [human_target.p_them()]!"),
				SPAN_USERDANGER("[user] sweeps your legs out from under you!"),
				SPAN_HEAR("You hear sweeping.")
			)

			user.do_attack_animation(human_target, ATTACK_EFFECT_KICK)
			playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
			human_target.apply_damage(5, BRUTE)
			human_target.KnockDown(4 SECONDS)

			add_attack_logs(user, human_target, "Leg swept with titanium push broom", ATKLOG_ALL)

		if(INTENT_GRAB)
			human_target.visible_message(
				SPAN_DANGER("[user] smacks [human_target] with the brush of [user.p_their()] broom!"),
				SPAN_USERDANGER("[user] smacks you with the brush of [user.p_their()] broom!"),
				SPAN_HEAR("You hear a smacking noise.")
			)

			user.do_attack_animation(human_target, ATTACK_EFFECT_DISARM)
			playsound(get_turf(user), 'sound/effects/woodhit.ogg', 50, TRUE, -1)
			human_target.AdjustConfused(4 SECONDS, 0, 4 SECONDS) // No stacking infinitely.
			human_target.apply_damage(15, STAMINA)

			add_attack_logs(user, human_target, "Swept with the brush of the titanium push broom", ATKLOG_ALL)

		if(INTENT_HARM)
			return ..()

#undef BROOM_PUSH_LIMIT
