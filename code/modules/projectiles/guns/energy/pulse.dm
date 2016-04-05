/obj/item/weapon/gun/energy/pulse_rifle
	name = "pulse rifle"
	desc = "A heavy-duty, pulse-based energy weapon, preferred by front-line combat personnel."
	icon_state = "pulse"
	item_state = null	//so the human update icon uses the icon_state instead.
	force = 10
	fire_sound = 'sound/weapons/pulse.ogg'
	charge_cost = 200
	projectile_type = "/obj/item/projectile/beam/pulse"
	cell_type = "/obj/item/weapon/stock_parts/cell/super"
	var/mode = 2
	slot_flags = SLOT_BACK
	w_class = 4.0

	emp_act()
		return

	attack_self(mob/living/user as mob)
		switch(mode)
			if(2)
				mode = 0
				charge_cost = 50
				fire_sound = 'sound/weapons/Taser.ogg'
				to_chat(user, "\red [src.name] is now set to stun.")
				projectile_type = "/obj/item/projectile/energy/electrode"
			if(0)
				mode = 1
				charge_cost = 100
				fire_sound = 'sound/weapons/Laser.ogg'
				to_chat(user, "\red [src.name] is now set to kill.")
				projectile_type = "/obj/item/projectile/beam"
			if(1)
				mode = 2
				charge_cost = 200
				fire_sound = 'sound/weapons/pulse.ogg'
				to_chat(user, "\red [src.name] is now set to DESTROY.")
				projectile_type = "/obj/item/projectile/beam/pulse"
		return

	isHandgun()
		return 0

/obj/item/weapon/gun/energy/pulse_rifle/cyborg/process_chambered()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(charge_cost)
			in_chamber = new projectile_type(src)
			return 1
	return 0


/obj/item/weapon/gun/energy/pulse_rifle/destroyer
	name = "pulse destroyer"
	desc = "A heavy-duty, pulse-based energy weapon."
	cell_type = "/obj/item/weapon/stock_parts/cell/infinite"

	attack_self(mob/living/user as mob)
		to_chat(user, "\red [src.name] has three settings, and they are all DESTROY.")

/obj/item/weapon/gun/energy/pulse_rifle/carbine
	name = "pulse carbine"
	desc = "A compact variant of the pulse rifle with less firepower but easier storage."
	w_class = 3
	slot_flags = SLOT_BELT
	icon_state = "pulse_carbine"
	item_state = "pulse"
	cell_type = "/obj/item/weapon/stock_parts/cell/pulse/carbine"
	can_flashlight = 1


/obj/item/weapon/gun/energy/pulse_rifle/pistol
	name = "pulse pistol"
	desc = "A pulse rifle in an easily concealed handgun package with low capacity."
	w_class = 2
	slot_flags = SLOT_BELT
	icon_state = "pulse_pistol"
	item_state = "gun"
	cell_type = "/obj/item/weapon/stock_parts/cell/pulse/pistol"

/obj/item/weapon/gun/energy/pulse_rifle/pistol/isHandgun()
	return 1

/obj/item/weapon/gun/energy/pulse_rifle/pistol/m1911
	name = "\improper M1911-P"
	desc = "A compact pulse core in a classic handgun frame for Nanotrasen officers. It's not the size of the gun, it's the size of the hole it puts through people."
	icon_state = "m1911-p"
	item_state = "gun"
	cell_type = "/obj/item/weapon/stock_parts/cell/infinite"
	isHandgun()
		return 1