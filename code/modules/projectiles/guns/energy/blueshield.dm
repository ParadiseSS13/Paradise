/obj/item/weapon/gun/energy/blueshield
	name = "asset protection energy gun"
	desc = "A sidearm designed for use by Blueshields after failed attempts at a less-lethal ballistic option. Can be toggled between stun and kill."
	icon_state = "bsgun_stun"
	item_state = "gun"
	modifystate = "bsgun_stun"
	force = 7
	fire_sound = 'sound/weapons/Taser.ogg'
	charge_cost = 2000
	projectile_type = "/obj/item/projectile/energy/electrode"
	fire_delay = 15
	var/fire_mode = 0 // 0 for taser, 1 for lethals.

/obj/item/weapon/gun/energy/blueshield/attack_self(mob/living/user as mob)
	if(!fire_mode)
		fire_mode = 1
		charge_cost = 1000
		fire_delay = 0

		fire_sound = 'sound/weapons/Laser.ogg'
		projectile_type = "/obj/item/projectile/beam"
		modifystate = "bsgun_kill"

		user << "<span class = 'warning'>You adjust [src.name] to the kill setting.</span>"

	else
		fire_mode = 0
		charge_cost = 2000
		fire_delay = 15

		projectile_type = "/obj/item/projectile/energy/electrode"
		fire_sound = 'sound/weapons/Taser.ogg'
		modifystate = "bsgun_stun"

		user << "<span class = 'info'>You adjust [src.name] to the stun setting.</span>"

	update_icon()