/obj/item/weapon/gun/projectile/automatic/spikethrower
	name = "\improper Vox spike thrower"
	desc = "A vicious alien projectile weapon. Parts of it quiver gelatinously, as though the thing is insectile and alive."
	icon_state = "spikethrower"
	item_state = "spikethrower"
	w_class = 2
	fire_sound_text = "a strange noise"
	mag_type = /obj/item/ammo_box/magazine/internal/spikethrower
	burst_size = 2
	fire_delay = 3
	can_suppress = 0
	var/charge_tick = 0
	var/charge_delay = 15
	restricted_species = list("Vox", "Vox Armalis")

/obj/item/weapon/gun/projectile/automatic/spikethrower/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/gun/projectile/automatic/spikethrower/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/weapon/gun/projectile/automatic/spikethrower/update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/spikethrower/process()
	charge_tick++
	if(charge_tick < charge_delay || !magazine)
		return
	charge_tick = 0
	var/obj/item/ammo_casing/caseless/spike/S = new(get_turf(src))
	magazine.give_round(S)
	return 1

/obj/item/weapon/gun/projectile/automatic/spikethrower/attack_self()
	return

/obj/item/weapon/gun/projectile/automatic/spikethrower/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/ammo_box/magazine/internal/spikethrower
	name = "\improper Vox spikethrower internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/spike
	caliber = "spike"
	max_ammo = 10

/obj/item/ammo_casing/caseless/spike
	name = "alloy spike"
	desc = "A broadhead spike made out of a weird silvery metal."
	projectile_type = /obj/item/projectile/bullet/spike
	sharp = 1
	edge = 0
	throwforce = 5
	w_class = 3
	caliber = "spike"
	icon_state = "bolt"
	fire_sound = 'sound/weapons/bladeslice.ogg'

/obj/item/projectile/bullet/spike
	name = "alloy spike"
	desc = "It's about a foot of weird silvery metal with a wicked point."
	damage = 25
	stun = 1
	armour_penetration = 30
	icon_state = "magspear"

/obj/item/projectile/bullet/spike/on_hit(atom/target, blocked = 0)
	if((blocked != 100) && istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		H.drip(500)
	..()

//This gun only functions for armalis. The on-sprite is too huge to render properly on other sprites.
/obj/item/weapon/gun/energy/noisecannon
	name = "alien heavy cannon"
	desc = "It's some kind of enormous alien weapon, as long as a man is tall."
	icon_state = "noisecannon"
	item_state = "noisecannon"
	recoil = 1
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/sonic)
	cell_type = /obj/item/weapon/stock_parts/cell/super
	restricted_species = list("Vox Armalis")

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
	icon_state = "particle"
	damage = 60
	damage_type = BRUTE
	flag = "bullet"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

	embed = 0
	weaken = 5
	stun = 5
