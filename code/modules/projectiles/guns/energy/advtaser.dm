/obj/item/weapon/gun/energy/advtaser
	name = "hybrid taser"
	desc = "A hybrid taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon_state = "advtaser"
	item_state = null	//so the human update icon uses the icon_state instead.
	icon_override = 'icons/mob/in-hand/guns.dmi'
	cell_type = "/obj/item/weapon/stock_parts/cell"
	origin_tech = null
	fire_sound = 'sound/weapons/Taser.ogg'
	projectile_type = "/obj/item/projectile/energy/electrode"
	charge_cost = 2000
	modifystate = "advtaserstun"
	can_flashlight = 1
	fire_delay = 15

	var/mode = 0 //0 = stun, 1 = disable


/obj/item/weapon/gun/energy/advtaser/attack_self(mob/living/user as mob)
	switch(mode)
		if(0)
			make_disabler()
			user << "\red [src.name] is now set to Disable."

		if(1)
			make_taser()
			user << "\red [src.name] is now set to stun."

	update_icon()
	if(user.l_hand == src)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()

/obj/item/weapon/gun/energy/advtaser/proc/make_disabler()
	charge_cost = 500
	fire_sound = 'sound/weapons/taser2.ogg'
	projectile_type = "/obj/item/projectile/beam/disabler"
	modifystate = "advtaserdisable"
	fire_delay = 0

	mode = 1

/obj/item/weapon/gun/energy/advtaser/proc/make_taser()
	charge_cost = 2000
	fire_sound = 'sound/weapons/Taser.ogg'
	projectile_type = "/obj/item/projectile/energy/electrode"
	modifystate = "advtaserstun"
	fire_delay = 15

	mode = 0