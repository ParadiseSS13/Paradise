/obj/item/weapon/gun/energy/hos
	name = "head of security's energy gun"
	desc = "This is a modern recreation of the captain's antique laser gun. This gun has several unique fire modes, but lacks the ability to recharge over time."
	icon_state = "hoslaser"
	item_state = null	//so the human update icon uses the icon_state instead.
	icon_override = 'icons/mob/in-hand/guns.dmi'
	force = 10
	fire_sound = 'sound/weapons/Taser.ogg'
	origin_tech = "combat=3;magnets=2"
	charge_cost = 2000
	modifystate = "hoslaserstun"
	projectile_type = "/obj/item/projectile/energy/electrode"
	fire_delay = 15
	var/mode = 2

	attack_self(mob/living/user as mob)
		switch(mode)
			if(2)
				mode = 0
				charge_cost = 1000
				fire_sound = 'sound/weapons/Laser.ogg'
				user << "\red [src.name] is now set to kill."
				projectile_type = "/obj/item/projectile/beam"
				modifystate = "hoslaserkill"
				fire_delay = 0
			if(0)
				mode = 1
				charge_cost = 500
				fire_sound = 'sound/weapons/taser2.ogg'
				user << "\red [src.name] is now set to disable."
				projectile_type = "/obj/item/projectile/beam/disabler"
				modifystate = "hoslaserdisable"
				fire_delay = 0
			if(1)
				mode = 2
				charge_cost = 2000
				fire_sound = 'sound/weapons/taser.ogg'
				user << "\red [src.name] is now set to stun."
				projectile_type = "/obj/item/projectile/energy/electrode"
				modifystate = "hoslaserstun"
				fire_delay = 15
		update_icon()
		if(user.l_hand == src)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()