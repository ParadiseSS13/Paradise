/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
//Might want to move this into several files later but for now it works here
/obj/item/borg/stun
	name = "electrified arm"
	icon = 'icons/obj/items.dmi'
	icon_state = "elecarm"
	var/charge_cost = 30
	
/obj/item/borg/stun/attack(mob/M, mob/living/silicon/robot/user)
	var/mob/living/silicon/robot/R = user
	if(R && R.cell && R.cell.charge > 0)
		R.cell.use(charge_cost)
	else
		return

	user.do_attack_animation(M)
	M.Weaken(5)
	if (M.stuttering < 5)
		M.stuttering = 5
	M.Stun(5)

	M.visible_message("<span class='danger'>[user] has prodded [M] with [src]!</span>", \
					  "<span class='userdanger'>[user] has prodded you with [src].</span>")
	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
	
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	add_logs(M, user, "stunned", src, "(INTENT: [uppertext(user.a_intent)])")

/obj/item/borg/overdrive
	name = "Overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/borg/sight
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	var/sight_mode = null

/obj/item/borg/sight/xray
	name = "X-ray Vision"
	sight_mode = BORGXRAY

/obj/item/borg/sight/thermal
	name = "Thermal Vision"
	sight_mode = BORGTHERM
	icon_state = "thermal"
	icon = 'icons/obj/clothing/glasses.dmi'

/obj/item/borg/sight/meson
	name = "Meson Vision"
	sight_mode = BORGMESON
	icon_state = "meson"
	icon = 'icons/obj/clothing/glasses.dmi'

/obj/item/borg/sight/hud
	name = "Hud"
	var/obj/item/clothing/glasses/hud/hud = null

/obj/item/borg/sight/hud/med
	name = "medical hud"
	icon_state = "healthhud"
	icon = 'icons/obj/clothing/glasses.dmi'

/obj/item/borg/sight/hud/med/New()
	..()
	hud = new /obj/item/clothing/glasses/hud/health(src)
	return

/obj/item/borg/sight/hud/sec
	name = "security hud"
	icon_state = "securityhud"
	icon = 'icons/obj/clothing/glasses.dmi'

/obj/item/borg/sight/hud/sec/New()
	..()
	hud = new /obj/item/clothing/glasses/hud/security(src)
	return
