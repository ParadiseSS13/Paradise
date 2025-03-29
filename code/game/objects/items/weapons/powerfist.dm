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
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 40)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=5;powerstorage=3;syndicate=3"
	new_attack_chain = TRUE
	var/click_delay = 1.5
	var/fisto_setting = 1
	/// Base pressure in kpa used by the powerfist per hit
	var/gasperfist = 17.5
	var/obj/item/tank/internals/tank = null //Tank used for the gauntlet's piston-ram.

/obj/item/melee/powerfist/proc/update_tank(obj/item/tank/internals/new_tank, removing = FALSE, mob/living/carbon/human/user)
	if(removing)
		if(!tank)
			to_chat(user, "<span class='notice'>[src] currently has no tank attached to it.</span>")
			return
		to_chat(user, "<span class='notice'>As you detach [new_tank] from [src], the fist unlocks.</span>")
		flags &= ~NODROP
		tank.forceMove(get_turf(user))
		user.put_in_hands(tank)
		tank = null
	else
		if(tank)
			to_chat(user, "<span class='warning'>[src] already has a tank.</span>")
			return
		if(!user.unequip(new_tank))
			return
		to_chat(user, "<span class='notice'>As you hook [new_tank] up to [src], the fist locks into place around your arm.</span>")
		tank = new_tank
		new_tank.forceMove(src)
		flags |= NODROP

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

/obj/item/melee/powerfist/Destroy()
	QDEL_NULL(tank)
	return ..()

/obj/item/melee/powerfist/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		. += "<span class='notice'>You'll need to get closer to see any more.</span>"
	else if(tank)
		. += "<span class='notice'>[bicon(tank)] It has [tank] mounted onto it.</span>"

/obj/item/melee/powerfist/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	. = ..()
	if(istype(used, /obj/item/tank/internals))
		if(!user.is_holding(src))
			to_chat(user, "<span class='warning'>You have to hold [src] in your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		if(!tank)
			var/obj/item/tank/internals/used_tank = used
			if(used_tank.volume <= 3)
				to_chat(user, "<span class='warning'>[used_tank] is too small for [src].</span>")
				return ITEM_INTERACT_COMPLETE
			update_tank(used_tank, FALSE, user)
	return ITEM_INTERACT_COMPLETE

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
	update_tank(tank, TRUE, user)

/obj/item/melee/powerfist/pre_attack(atom/A, mob/living/user, params)
	if(..())
		return FINISH_ATTACK
	if(!tank)
		to_chat(user, "<span class='warning'>[src] can't operate without a source of gas!</span>")
		return FINISH_ATTACK
	if(!use_air())
		to_chat(user, "<span class='warning'>[src]'s piston-ram lets out a weak hiss, it needs more gas!</span>")
		playsound(loc, 'sound/effects/refill.ogg', 50, TRUE)
		return FINISH_ATTACK
	if(ishuman(A))
		var/mob/living/carbon/human/human_target = A
		force *= fisto_setting
		if(human_target.check_shields(src, force, "[user]'s [name]", MELEE_ATTACK))
			user.do_attack_animation(human_target)
			user.changeNext_move(CLICK_CD_MELEE)
			force /= fisto_setting
			return FINISH_ATTACK
		force /= fisto_setting

/obj/item/melee/powerfist/attack(mob/living/target, mob/living/user, params)
	force *= fisto_setting
	. = ..()
	force /= fisto_setting
	new /obj/effect/temp_visual/kinetic_blast(target.loc)
	playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, TRUE)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, TRUE)
	target.visible_message("<span class='danger'>[user]'s powerfist lets out a loud hiss as [user.p_they()] punch[user.p_es()] [target.name]!</span>", \
		"<span class='userdanger'>You cry out in pain as [user]'s punch flings you backwards!</span>")
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 5 * fisto_setting, 3 * fisto_setting)
	user.changeNext_move(CLICK_CD_MELEE * click_delay)
