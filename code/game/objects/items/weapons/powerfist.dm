/obj/item/melee/powerfist
	name = "power-fist"
	desc = "A metal gauntlet with a piston-powered ram ontop for that extra 'ompfh' in your punch."
	icon_state = "powerfist"
	item_state = "powerfist"
	flags = CONDUCT
	attack_verb = list("whacked", "fisted", "power-punched")
	force = 12
	throwforce = 10
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=5;powerstorage=3;syndicate=3"
	var/click_delay = 1.5
	var/fisto_setting = 1
	var/gasperfist = 3
	var/obj/item/tank/tank = null //Tank used for the gauntlet's piston-ram.


/obj/item/melee/powerfist/Destroy()
	QDEL_NULL(tank)
	return ..()

/obj/item/melee/powerfist/examine(mob/user)
	..()
	if(!in_range(user, src))
		to_chat(user, "<span class='notice'>You'll need to get closer to see any more.</span>")
		return
	if(tank)
		to_chat(user, "<span class='notice'>[bicon(tank)] It has [tank] mounted onto it.</span>")

/obj/item/melee/powerfist/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank))
		if(!tank)
			var/obj/item/tank/IT = W
			if(IT.volume <= 3)
				to_chat(user, "<span class='warning'>[IT] is too small for [src].</span>")
				return
			updateTank(W, 0, user)
	else if(iswrench(W))
		switch(fisto_setting)
			if(1)
				fisto_setting = 2
			if(2)
				fisto_setting = 3
			if(3)
				fisto_setting = 1
		playsound(loc, W.usesound, 50, 1)
		to_chat(user, "<span class='notice'>You tweak [src]'s piston valve to [fisto_setting].</span>")
	else if(isscrewdriver(W))
		if(tank)
			updateTank(tank, 1, user)


/obj/item/melee/powerfist/proc/updateTank(obj/item/tank/thetank, removing = 0, mob/living/carbon/human/user)
	if(removing)
		if(!tank)
			to_chat(user, "<span class='notice'>[src] currently has no tank attached to it.</span>")
			return
		to_chat(user, "<span class='notice'>You detach [thetank] from [src].</span>")
		tank.forceMove(get_turf(user))
		user.put_in_hands(tank)
		tank = null
	if(!removing)
		if(tank)
			to_chat(user, "<span class='warning'>[src] already has a tank.</span>")
			return
		if(!user.unEquip(thetank))
			return
		to_chat(user, "<span class='notice'>You hook [thetank] up to [src].</span>")
		tank = thetank
		thetank.forceMove(src)


/obj/item/melee/powerfist/attack(mob/living/target, mob/living/user)
	if(!tank)
		to_chat(user, "<span class='warning'>[src] can't operate without a source of gas!</span>")
		return
	if(tank && !tank.air_contents.remove(gasperfist * fisto_setting))
		to_chat(user, "<span class='warning'>[src]'s piston-ram lets out a weak hiss, it needs more gas!</span>")
		playsound(loc, 'sound/effects/refill.ogg', 50, 1)
		return

	user.do_attack_animation(target)

	target.apply_damage(force * fisto_setting, BRUTE)
	target.visible_message("<span class='danger'>[user]'s powerfist lets out a loud hiss as [user.p_they()] punch[user.p_es()] [target.name]!</span>", \
		"<span class='userdanger'>You cry out in pain as [user]'s punch flings you backwards!</span>")
	new /obj/effect/temp_visual/kinetic_blast(target.loc)
	playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, 1)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, 1)

	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))

	target.throw_at(throw_target, 5 * fisto_setting, 0.2)

	add_attack_logs(user, target, "POWER FISTED with [src]")

	user.changeNext_move(CLICK_CD_MELEE * click_delay)
