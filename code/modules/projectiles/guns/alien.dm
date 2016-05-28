//This gun only functions for armalis. The on-sprite is too huge to render properly on other sprites.
/obj/item/weapon/gun/energy/noisecannon
	name = "alien heavy cannon"
	desc = "It's some kind of enormous alien weapon, as long as a man is tall."

	icon = 'icons/obj/gun.dmi' //Actual on-sprite is handled by icon_override.
	icon_state = "noisecannon"
	item_state = "noisecannon"
	recoil = 1
	force = 10
	ammo_type = "/obj/item/projectile/energy/sonic"
	cell_type = "/obj/item/weapon/stock_parts/cell/super"
	fire_sound = 'sound/effects/basscannon.ogg'

/obj/item/weapon/gun/energy/noisecannon/attack_hand(mob/user as mob)
	if(loc != user)
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(H.species.name == "Vox Armalis")
				..()
				return
		to_chat(user, "<span class='warning'>\The [src] is far too large for you to pick up.</span>")
		return

/obj/item/weapon/gun/energy/noisecannon/update_icon()
	return

//Casing
/obj/item/ammo_casing/energy/sonic
	projectile_type = /obj/item/projectile/energy/sonic
	fire_sound = 'sound/effects/basscannon.ogg'
	delay = 40

//Projectile.
/obj/item/projectile/energy/sonic
	name = "distortion"
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"
	damage = 60
	damage_type = BRUTE
	flag = "bullet"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

	embed = 0
	weaken = 5
	stun = 5

/obj/item/projectile/energy/sonic/proc/split()
	//TODO: create two more projectiles to either side of this one, fire at targets to the side of target turf.
	return
