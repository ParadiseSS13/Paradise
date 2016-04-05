/obj/item/weapon/gun/energy/blueshield
	name = "advanced stun revolver"
	desc = "An advanced stun revolver with the capacity to shoot both electrodes and lasers."
	icon_state = "bsgun_stun"
	item_state = "gun"
	modifystate = "bsgun_stun"
	force = 7
	fire_sound = 'sound/weapons/gunshot.ogg'
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

		to_chat(user, "<span class = 'warning'>You adjust [src.name] to the kill setting.</span>")


	else
		fire_mode = 0
		charge_cost = 2000
		fire_delay = 15

		projectile_type = "/obj/item/projectile/energy/electrode"
		fire_sound = 'sound/weapons/gunshot.ogg'
		modifystate = "bsgun_stun"

		to_chat(user, "<span class = 'info'>You adjust [src.name] to the stun setting.</span>")


	update_icon()