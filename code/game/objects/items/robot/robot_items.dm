/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
/obj/item/borg
	icon = 'icons/mob/robot_items.dmi'
	var/powerneeded // Percentage of power remaining required to run item

/*
The old, instant-stun borg arm.
Keeping it in for adminabuse but the malf one is /obj/item/melee/baton/borg_stun_arm
*/
/obj/item/borg/stun
	name = "electrically-charged arm"
	icon_state = "elecarm_active"
	new_attack_chain = TRUE
	var/charge_cost = 30

/obj/item/borg/stun/attack(mob/living/target, mob/living/silicon/robot/user, params)
	if(..())
		return FINISH_ATTACK

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(src, 0, "[target]'s [name]", MELEE_ATTACK))
			playsound(target, 'sound/weapons/genhit.ogg', 50, TRUE)
			return FINISH_ATTACK

	if(isrobot(user))
		if(!user.cell.use(charge_cost))
			return FINISH_ATTACK

	user.do_attack_animation(target)
	target.Weaken(10 SECONDS)
	target.apply_effect(STUTTER, 10 SECONDS)

	target.visible_message(SPAN_DANGER("[user] has prodded [target] with [src]!"), \
					SPAN_USERDANGER("[user] has prodded you with [src]!"))

	playsound(loc, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	add_attack_logs(user, target, "Stunned with [src] ([uppertext(user.a_intent)])")

/obj/item/borg/push_broom
	name = "integrated push broom"
	desc = "This is my BROOMSTICK! This lightweight broom can be used manually or braced to sweep items as you move."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "broom0"
	base_icon_state = "broom"
	force = 6
	attack_verb = list("swept", "brushed off", "bludgeoned", "whacked")
	new_attack_chain = TRUE
	var/braced = FALSE

/obj/item/borg/push_broom/activate_self(mob/user)
	if(..())
		return

	if(!braced)
		to_chat(user, SPAN_NOTICE("You brace [src] against the ground in a firm sweeping stance."))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(sweep))
		RegisterSignal(src, COMSIG_CYBORG_ITEM_DEACTIVATED, PROC_REF(stow_broom))
	else
		to_chat(user, SPAN_NOTICE("You unbrace [src] from the ground and enter a neutral stance."))
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(src, COMSIG_CYBORG_ITEM_DEACTIVATED)
	braced = !braced
	update_icon(UPDATE_ICON_STATE)
	return ITEM_INTERACT_COMPLETE

/obj/item/borg/push_broom/update_icon_state()
	icon_state = "[base_icon_state][braced]"

/obj/item/borg/push_broom/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	// Can we sweep it? No? Violence is the solution.
	if(!isitem(target) && !isturf(target))
		return NONE

	sweep(user, target, FALSE)
	return ITEM_INTERACT_COMPLETE

/obj/item/borg/push_broom/proc/stow_broom(datum/source, mob/user)
	SIGNAL_HANDLER // COMSIG_CYBORG_ITEM_DEACTIVATED
	braced = FALSE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, SPAN_NOTICE("You unbrace [src] and stow it away."))
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(src, COMSIG_CYBORG_ITEM_DEACTIVATED)

/obj/item/borg/push_broom/proc/sweep(mob/user, atom/A, moving = TRUE)
	SIGNAL_HANDLER // COMSIG_MOVABLE_MOVED
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
		if(trash_amount > 20)
			break
	if(trash_amount > 1)
		playsound(loc, 'sound/weapons/sweeping.ogg', 70, TRUE, -1)

/obj/item/borg/push_broom/proc/move_into_storage(mob/user, obj/storage, obj/trash)
	trash.forceMove(storage)
	storage.update_icon()

/obj/item/borg/push_broom/combat
	name = "cyborg combat broom"
	desc = "A steel-core push broom for the hostile cyborg."
	attack_verb = list("smashed", "slammed", "whacked", "thwacked", "swept")
	force = 20

/obj/item/borg/push_broom/combat/attack(mob/living/target, mob/living/user, params)
	if(!ishuman(target))
		return ..()

	var/mob/living/carbon/human/H = target
	if(H.stat != CONSCIOUS || IS_HORIZONTAL(H))
		return ..()

	H.visible_message(
		SPAN_DANGER("[user] sweeps [H]'s legs out from under [H.p_them()]!"),
		SPAN_USERDANGER("[user] sweeps your legs out from under you!"),
		SPAN_ITALICS("You hear sweeping.")
	)
	playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	H.apply_damage(20, BRUTE)
	H.KnockDown(4 SECONDS)
	add_attack_logs(user, H, "Leg swept with cyborg combat broom", ATKLOG_ALL)
