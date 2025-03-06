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

	target.visible_message("<span class='danger'>[user] has prodded [target] with [src]!</span>", \
					"<span class='userdanger'>[user] has prodded you with [src]!</span>")

	playsound(loc, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	add_attack_logs(user, target, "Stunned with [src] ([uppertext(user.a_intent)])")
