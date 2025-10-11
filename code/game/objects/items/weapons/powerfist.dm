/obj/item/melee/powerfist
	name = "power-fist"
	desc = "A metal gauntlet with a piston-powered ram ontop for that extra 'ompfh' in your punch."
	icon_state = "powerfist"
	flags = CONDUCT
	attack_verb = list("whacked", "fisted", "power-punched")
	force = 12
	throwforce = 10
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 40)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=5;powerstorage=3;syndicate=3"
	var/click_delay = 1.5
	var/fisto_setting = 1
	/// Base pressure in kpa used by the powerfist per hit
	var/gasperfist = 17.5
	var/obj/item/tank/internals/tank = null //Tank used for the gauntlet's piston-ram.

/obj/item/melee/powerfist/Destroy()
	QDEL_NULL(tank)
	return ..()

/obj/item/melee/powerfist/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		. += "<span class='notice'>You'll need to get closer to see any more.</span>"
	else if(tank)
		. += "<span class='notice'>[bicon(tank)] It has [tank] mounted onto it.</span>"

/obj/item/melee/powerfist/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank/internals))
		if(!user.is_holding(src))
			to_chat(user, "<span class='warning'>You have to hold [src] in your hand!</span>")
			return
		if(!tank)
			var/obj/item/tank/internals/IT = W
			if(IT.volume <= 3)
				to_chat(user, "<span class='warning'>[IT] is too small for [src].</span>")
				return
			updateTank(W, 0, user)
			return
	return ..()

/obj/item/melee/powerfist/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(fisto_setting)
		if(1)
			fisto_setting = 2
		if(2)
			fisto_setting = 3
		if(3)
			fisto_setting = 1
	to_chat(user, "<span class='notice'>You tweak [src]'s piston valve to [fisto_setting].</span>")

/obj/item/melee/powerfist/screwdriver_act(mob/user, obj/item/I)
	if(!tank)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	updateTank(tank, 1, user)

/obj/item/melee/powerfist/proc/updateTank(obj/item/tank/thetank, removing = 0, mob/living/carbon/human/user)
	if(removing)
		if(!tank)
			to_chat(user, "<span class='notice'>[src] currently has no tank attached to it.</span>")
			return
		to_chat(user, "<span class='notice'>As you detach [thetank] from [src], the fist unlocks.</span>")
		set_nodrop(FALSE, user)
		tank.forceMove(get_turf(user))
		user.put_in_hands(tank)
		tank = null
	if(!removing)
		if(tank)
			to_chat(user, "<span class='warning'>[src] already has a tank.</span>")
			return
		if(!user.unequip(thetank))
			return
		to_chat(user, "<span class='notice'>As you hook [thetank] up to [src], the fist locks into place around your arm.</span>")
		tank = thetank
		thetank.forceMove(src)
		set_nodrop(TRUE, user)

/obj/item/melee/powerfist/attack__legacy__attackchain(mob/living/target, mob/living/user)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
		return
	if(!tank)
		to_chat(user, "<span class='warning'>[src] can't operate without a source of gas!</span>")
		return
	if(!use_air())
		to_chat(user, "<span class='warning'>[src]'s piston-ram lets out a weak hiss, it needs more gas!</span>")
		playsound(loc, 'sound/effects/refill.ogg', 50, 1)
		return

	user.do_attack_animation(target)

	var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
	if(!affecting)
		affecting = target.get_organ("chest")

	var/armor_block = target.run_armor_check(affecting, MELEE)
	target.apply_damage(force * fisto_setting, BRUTE, affecting, armor_block)

	target.visible_message("<span class='danger'>[user]'s powerfist lets out a loud hiss as [user.p_they()] punch[user.p_es()] [target.name]!</span>", \
		"<span class='userdanger'>You cry out in pain as [user]'s punch flings you backwards!</span>")
	new /obj/effect/temp_visual/kinetic_blast(target.loc)
	playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, 1)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, 1)

	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))

	target.throw_at(throw_target, 5 * fisto_setting, 3 * fisto_setting)

	add_attack_logs(user, target, "POWER FISTED with [src]")

	user.changeNext_move(CLICK_CD_MELEE * click_delay)

/obj/item/melee/powerfist/proc/use_air()
	if(!tank)
		return FALSE

	var/amount_to_remove = gasperfist * fisto_setting
	var/pressure_in_tank = tank.air_contents.return_pressure()

	// So this check is here to see if the amount of pressure currently in the tank is higher than 10 atmospheres
	// If it is higher, we instead take 10% out of the tank so it'll deplete a lot faster, but is still a bit more ammo
	if(pressure_in_tank > (ONE_ATMOSPHERE * 10))
		amount_to_remove = 0.1 * pressure_in_tank

	var/moles_to_remove = (amount_to_remove * tank.air_contents.volume) / (R_IDEAL_GAS_EQUATION * tank.air_contents.temperature())
	return tank.air_contents.boolean_remove(moles_to_remove)
