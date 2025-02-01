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
	var/charge_cost = 30

/obj/item/borg/stun/attack__legacy__attackchain(mob/living/M, mob/living/silicon/robot/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.check_shields(src, 0, "[M]'s [name]", MELEE_ATTACK))
			playsound(M, 'sound/weapons/genhit.ogg', 50, 1)
			return 0

	if(isrobot(user))
		if(!user.cell.use(charge_cost))
			return

	user.do_attack_animation(M)
	M.Weaken(10 SECONDS)
	M.apply_effect(STUTTER, 10 SECONDS)

	M.visible_message("<span class='danger'>[user] has prodded [M] with [src]!</span>", \
					"<span class='userdanger'>[user] has prodded you with [src]!</span>")

	playsound(loc, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	add_attack_logs(user, M, "Stunned with [src] ([uppertext(user.a_intent)])")
