/obj/item/weapon/gun/energy/gun
	name = "energy gun"
	desc = "A basic energy-based gun with two settings: kill and disable."
	icon_state = "energystun100"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/Taser2.ogg'
	charge_cost = 500
	projectile_type = "/obj/item/projectile/beam/disabler"
	origin_tech = "combat=3;magnets=2"
	modifystate = "energystun"
	can_flashlight = 1

	var/mode = 0 //0 = disable, 1 = kill


	attack_self(mob/living/user as mob)
		switch(mode)
			if(0)
				mode = 1
				charge_cost = 1000
				fire_sound = 'sound/weapons/Laser.ogg'
				user << "\red [src.name] is now set to kill."
				projectile_type = "/obj/item/projectile/beam"
				modifystate = "energykill"
			if(1)
				mode = 0
				charge_cost = 500
				fire_sound = 'sound/weapons/Taser2.ogg'
				user << "\red [src.name] is now set to disable."
				projectile_type = "/obj/item/projectile/beam/disabler"
				modifystate = "energystun"
		update_icon()
		if(user.l_hand == src)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()




/obj/item/weapon/gun/energy/gun/nuclear
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	icon_state = "nucgun"
	origin_tech = "combat=3;materials=5;powerstorage=3"
	var/lightfail = 0
	var/charge_tick = 0
	can_flashlight = 0

	New()
		..()
		processing_objects.Add(src)


	Destroy()
		processing_objects.Remove(src)
		return ..()


	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		if((power_supply.charge / power_supply.maxcharge) != 1)
			if(!failcheck())	return 0
			power_supply.give(1000)
			update_icon()
		return 1


	proc
		failcheck()
			lightfail = 0
			if (prob(src.reliability)) return 1 //No failure
			if (prob(src.reliability))
				for (var/mob/living/M in range(0,src)) //Only a minor failure, enjoy your radiation if you're in the same tile or carrying it
					if (src in M.contents)
						M << "\red Your gun feels pleasantly warm for a moment."
					else
						M << "\red You feel a warm sensation."
					M.apply_effect(rand(3,120), IRRADIATE)
				lightfail = 1
			else
				for (var/mob/living/M in range(rand(1,4),src)) //Big failure, TIME FOR RADIATION BITCHES
					if (src in M.contents)
						M << "\red Your gun's reactor overloads!"
					M << "\red You feel a wave of heat wash over you."
					M.apply_effect(300, IRRADIATE)
				crit_fail = 1 //break the gun so it stops recharging
				processing_objects.Remove(src)
				update_icon()
			return 0


		update_charge()
			if (crit_fail)
				overlays += "nucgun-whee"
				return
			var/ratio = power_supply.charge / power_supply.maxcharge
			ratio = round(ratio, 0.25) * 100
			overlays += "nucgun-[ratio]"


		update_reactor()
			if(crit_fail)
				overlays += "nucgun-crit"
				return
			if(lightfail)
				overlays += "nucgun-medium"
			else if ((power_supply.charge/power_supply.maxcharge) <= 0.5)
				overlays += "nucgun-light"
			else
				overlays += "nucgun-clean"


		update_mode()
			if (mode == 0)
				overlays += "nucgun-stun"
			else if (mode == 1)
				overlays += "nucgun-kill"

	emp_act(severity)
		..()
		reliability -= round(15/severity)


	update_icon()
		overlays.Cut()
		update_charge()
		update_reactor()
		update_mode()


/obj/item/weapon/gun/energy/gun/turret
	name = "hybrid turret gun"
	desc = "A heavy hybrid energy cannon with two settings: Stun and kill."
	icon_state = "turretlaser"
	slot_flags = null
	w_class = 5
	heavy_weapon = 1
	can_flashlight = 0
	projectile_type = /obj/item/projectile/energy/electrode
	charge_cost = 1000
	fire_delay = 15

/obj/item/weapon/gun/energy/gun/turret/update_icon()
	icon_state = initial(icon_state)

/obj/item/weapon/gun/energy/gun/turret/attack_self(mob/living/user as mob)
	switch(mode)
		if(0)
			mode = 1
			charge_cost = 500
			fire_sound = 'sound/weapons/Laser.ogg'
			user << "\red [src.name] is now set to kill."
			projectile_type = /obj/item/projectile/beam
			modifystate = "energykill"
			fire_delay = 0
		if(1)
			mode = 0
			charge_cost = 1000
			fire_sound = 'sound/weapons/Taser.ogg'
			user << "\red [src.name] is now set to stun."
			projectile_type = /obj/item/projectile/energy/electrode
			modifystate = "energystun"
			fire_delay = 15
	update_icon()
	if(user.l_hand == src)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()