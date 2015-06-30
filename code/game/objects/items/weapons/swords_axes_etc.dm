/* Weapons
 * Contains:
 *		Banhammer
 *		Sword
 *		Classic Baton
 *		Energy Blade
 *		Energy Axe
 *		Energy Shield
 */

/*
 * Banhammer
 */
/obj/item/weapon/banhammer/attack(mob/M as mob, mob/user as mob)
	M << "<font color='red'><b> You have been banned FOR NO REISIN by [user]<b></font>"
	user << "<font color='red'> You have <b>BANNED</b> [M]</font>"

/*
 * Sword
 */
/obj/item/weapon/melee/energy/sword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/melee/energy/sword/New()
	blade_color = pick("red","blue","green","purple")

/obj/item/weapon/melee/energy/sword/attack_self(mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red You accidentally cut yourself with [src]."
		user.take_organ_damage(5,5)
	active = !active
	if (active)
		force = 30
		throwforce = 20
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass1"
		else
			icon_state = "sword[blade_color]"
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 35, 1)
		hitsound = 'sound/weapons/blade1.ogg'
		user << "\blue [src] is now active."
	else
		force = 3
		throwforce = 5.0
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass0"
		else
			icon_state = "sword0"
		w_class = 2
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)
		hitsound = "swing_hit"
		user << "\blue [src] can now be concealed."
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return

/obj/item/weapon/melee/energy/sword/attackby(obj/item/weapon/W, mob/living/user, params)
	..()
	if(istype(W, /obj/item/weapon/melee/energy/sword))
		if(W == src)
			user << "<span class='notice'>You try to attach the end of the energy sword to... itself. You're not very smart, are you?</span>"
			if(ishuman(user))
				user.adjustBrainLoss(10)
		else
			user << "<span class='notice'>You attach the ends of the two energy swords, making a single double-bladed weapon! You're cool.</span>"
			var/obj/item/weapon/twohanded/dualsaber/newSaber = new /obj/item/weapon/twohanded/dualsaber(user.loc)
			if(src.hacked) // That's right, we'll only check the "original" esword.
				newSaber.hacked = 1
				newSaber.blade_color = "rainbow"
			del(W)
			del(src)

	else if(istype(W, /obj/item/device/multitool))
		if(hacked == 0)
			hacked = 1
			blade_color = "rainbow"
			user << "<span class='warning'>RNBW_ENGAGE</span>"

			if(active)
				icon_state = "swordrainbow"
				// Updating overlays, copied from welder code.
				// I tried calling attack_self twice, which looked cool, except it somehow didn't update the overlays!!
				if(user.r_hand == src)
					user.update_inv_r_hand(0)
				else if(user.l_hand == src)
					user.update_inv_l_hand(0)
		else
			user << "<span class='warning'>It's already fabulous!</span>"

/*
 * Classic Baton
 */

/obj/item/weapon/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = SLOT_BELT
	force = 12 //9 hit crit
	w_class = 3
	var/cooldown = 0
	var/on = 1

/obj/item/weapon/melee/classic_baton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		add_fingerprint(user)
		if((CLUMSY in user.mutations) && prob(50))
			user << "<span class ='danger'>You club yourself over the head.</span>"
			user.Weaken(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2*force, BRUTE, "head")
			else
				user.take_organ_damage(2*force)
			return
		if(isrobot(target))
			..()
			return
		if(!isliving(target))
			return
		if (user.a_intent == "harm")
			if(!..()) return
			if(!isrobot(target)) return
		else
			if(cooldown <= 0)
				playsound(get_turf(src), 'sound/effects/woodhit.ogg', 75, 1, -1)
				target.Weaken(3)
				add_logs(target, user, "stunned", object="[src]")
				src.add_fingerprint(user)
				target.visible_message("<span class ='danger'>[user] has knocked down [target] with \the [src]!</span>", \
					"<span class ='userdanger'>[user] has knocked down [target] with \the [src]!</span>")
				if(!iscarbon(user))
					target.LAssailant = null
				else
					target.LAssailant = user
				cooldown = 1
				spawn(40)
					cooldown = 0
		return
	else
		return ..()

//Telescopic baton
/obj/item/weapon/melee/classic_baton/telescopic
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = null
	slot_flags = SLOT_BELT
	w_class = 2
	force = 0
	on = 0

/obj/item/weapon/melee/classic_baton/telescopic/attack_self(mob/user as mob)
	on = !on
	if(on)
		user << "<span class ='warning'>You extend the baton.</span>"
		icon_state = "telebaton_1"
		item_state = "nullrod"
		w_class = 4 //doesnt fit in backpack when its on for balance
		force = 10 //stunbaton damage
		attack_verb = list("smacked", "struck", "cracked", "beaten")
	else
		user << "<span class ='notice'>You collapse the baton.</span>"
		icon_state = "telebaton_0"
		item_state = null //no sprite for concealment even when in hand
		slot_flags = SLOT_BELT
		w_class = 2
		force = 0 //not so robust now
		attack_verb = list("hit", "poked")

	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	add_fingerprint(user)

/*
 *Energy Blade
 */
//Most of the other special functions are handled in their own files.

/obj/item/weapon/melee/energy/sword/green
	New()
		blade_color = "green"

/obj/item/weapon/melee/energy/sword/red
	New()
		blade_color = "red"

/obj/item/weapon/melee/energy/blade/New()
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	return

/obj/item/weapon/melee/energy/blade/dropped()
	del(src)
	return

/obj/item/weapon/melee/energy/blade/proc/toss()
	del(src)
	return

/*
 * Energy Axe
 */

/obj/item/weapon/melee/energy/axe/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		user << "\blue The axe is now energised."
		src.force = 150
		src.icon_state = "axe1"
		src.w_class = 5
		hitsound = 'sound/weapons/blade1.ogg'
	else
		user << "\blue The axe can now be concealed."
		src.force = 40
		src.icon_state = "axe0"
		src.w_class = 5
		hitsound = "swing_hit"
	src.add_fingerprint(user)
	return