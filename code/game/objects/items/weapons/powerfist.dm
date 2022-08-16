/obj/item/melee/powerfist
	name = "power-fist"
	desc = "A metal gauntlet with a piston-powered ram ontop for that extra 'ompfh' in your punch."
	icon_state = "powerfist"
	item_state = "powerfist"
	flags = CONDUCT
	force = 10
	hitsound = 'sound/weapons/smash.ogg' // You're using it as a makeshift club at this point
	var/hitsound_worn = 'sound/weapons/genhit2.ogg'
	var/attack_verb_worn = list("knuckled", "fisted", "slugged", "power-punched")
	throwforce = 10
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 40)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=5;powerstorage=3;syndicate=3"
	var/clamped = FALSE
	var/powered_knockback = 8
	var/powered_knockback_speed = 2
	var/powered_force_bonus = 5
	var/powered_cost = 2
	var/obj/item/tank/internals/tank = null //Tank used for the gauntlet's piston-ram.

/obj/item/melee/powerfist/Initialize(mapload)
	. = ..()
	if(!tank)
		tank = new /obj/item/tank/internals/oxygen/yellow(src)

/obj/item/melee/powerfist/proc/power_clamp(mob/living/carbon/user)
	flags |= NODROP // Ideally it'd be impossible to drop or disarm, but you could still remove it via the equipment menu. Sadly this capability doesn't exist yet, similarly to how the chainsaw works.
	clamped = TRUE
	attack_verb = attack_verb_worn
	hitsound = hitsound_worn

/obj/item/melee/powerfist/proc/power_unclamp()
	flags &= ~NODROP
	clamped = FALSE
	attack_verb = list()
	hitsound = initial(hitsound)

/obj/item/melee/powerfist/proc/check_powered()
	if(!tank || tank.air_contents.total_moles() < powered_cost)
		return FALSE
	return TRUE // it has a tank, and the tank has enough gas

/obj/item/melee/powerfist/attack_self(mob/user)
	if(clamped)
		to_chat(usr, "<span class='notice'>You operate the release latches and begin to remove [src].</span>")
		if(do_after(user, 30, target = user))
			power_unclamp()
			playsound(get_turf(user), 'sound/mecha/mechmove03.ogg', 50, 1)
			to_chat(usr, "<span class='notice'>[src] comes loose and you slip it off of your arm.</span>")
		else
			return
	else
		power_clamp(user)
		playsound(get_turf(user), 'sound/mecha/mechmove03.ogg', 50, 1)
		to_chat(usr, "<span class='notice'>[src] clamps into place on your arm.</span>")

/obj/item/melee/powerfist/Destroy()
	QDEL_NULL(tank)
	return ..()

/obj/item/melee/powerfist/dropped(mob/user, silent) // for amputations or similar
	..()
	if(clamped)
		power_unclamp()

/obj/item/melee/powerfist/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		. += "<span class='notice'>You'll need to get closer to see any more.</span>"
	else
		if(tank)
			. += "<span class='notice'>[bicon(tank)] It has [tank] mounted onto it. The gauge reads [round(tank.air_contents.return_pressure())] kPa</span>"
		if(clamped)
			. += "<span class='notice'>It's currently clamped firmly onto your forearm."
		else
			. += "<span class='notice'>The clamps are open."

/obj/item/melee/powerfist/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank/internals))
		if(!tank)
			var/obj/item/tank/internals/IT = W
			if(IT.volume <= 3)
				to_chat(user, "<span class='warning'>[IT] is too small for [src].</span>")
				return
			updateTank(W, 0, user)
			return
	return ..()

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
	var/powered = check_powered()

	if(clamped && powered)
		force += powered_force_bonus

	// we want to use a normal 'hit' so that it respects things like the pacifism trait and the vampire blood swell damage boost
	. = ..()

	if(clamped && tank) // we're wearing it and it has a tank
		if(!powered)
			to_chat(user, "<span class='warning'>[src]'s piston-ram lets out a weak hiss, it needs more gas!</span>")
			playsound(loc, 'sound/effects/refill.ogg', 50, 1)

		else
			force -= powered_force_bonus
			tank.air_contents.remove(powered_cost)

			if(isnull(.)) // we hit the target
				new /obj/effect/temp_visual/kinetic_blast(target.loc)
				playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, 1)

				if(target != user) // can't blast yourself away from yourself, as funny as that would be
					var/target_text = "<span class='userdanger'>[user]'s punch flings you backwards with pneumatic force!</span>"
					target.visible_message("<span class='danger'>[user]'s powerfist lets out a loud hiss as pneumatic force flings back [target.name]!</span>", target_text)
					var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
					target.throw_at(throw_target, powered_knockback, powered_knockback_speed)

				else
					var/target_text = "<span class='userdanger'>Your own pneumatic fist slams into you!</span>"
					target.visible_message("<span class='danger'>[user]'s powerfist swings wide, and they hit themself!</span>", target_text)

				target.KnockDown(1 SECONDS)
