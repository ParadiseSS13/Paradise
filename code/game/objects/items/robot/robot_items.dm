/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
//Might want to move this into several files later but for now it works here
/obj/item/borg/stun
	name = "electrified arm"
	icon = 'icons/obj/items.dmi'
	icon_state = "elecarm"
	var/charge_cost = 30

/obj/item/borg/stun/attack(mob/living/M, mob/living/silicon/robot/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.check_shields(0, "[M]'s [name]", src, MELEE_ATTACK))
			playsound(M, 'sound/weapons/Genhit.ogg', 50, 1)
			return 0

	if(!handlecharge())
		M.visible_message("<span class='warning'>[user] has poked [M] with [src], which does let out a quiet sizzling. Sounds like the power for it has run out.</span>", \
						"<span class='warning'>[user] has poked you with [src], which does let out a quiet sizzling. Sounds like the power for it has run out.</span>")
		return

	user.do_attack_animation(M)
	M.Weaken(5)
	M.apply_effect(STUTTER, 5)
	M.Stun(5)

	M.visible_message("<span class='danger'>[user] has prodded [M] with [src]!</span>", \
					"<span class='userdanger'>[user] has prodded you with [src]!</span>")

	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

	add_logs(user, M, "stunned", src, "(INTENT: [uppertext(user.a_intent)])")

/obj/item/borg/stun/proc/handlecharge(var/mob/living/silicon/robot/user)
	return user.cell.use(charge_cost)

/obj/item/borg/stun/implant
	var/obj/item/weapon/stock_parts/cell/bcell = null
	var/charge_tick = 0
	var/charge_delay = 6
	charge_cost = 100

/obj/item/borg/stun/implant/New()
	..()
	bcell = new(src)
	processing_objects.Add(src)

/obj/item/borg/stun/implant/Destroy()
	processing_objects.Remove(src)
	QDEL_NULL(bcell)
	return ..()

/obj/item/borg/stun/implant/handlecharge()
	return bcell.use(charge_cost)

/obj/item/borg/stun/implant/process()
	charge_tick++
	if(charge_tick < charge_delay)
		return
	charge_tick = 0
	bcell.give(100)

/obj/item/borg/overdrive
	name = "Overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
