/obj/item/gun/energy/spikethrower //It's like the cyborg LMG, uses energy to make spikes
	name = "\improper Vox spike thrower"
	desc = "A vicious alien projectile weapon. Parts of it quiver gelatinously, as though the thing is insectile and alive."
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "spikethrower"
	item_state = "spikethrower"
	w_class = WEIGHT_CLASS_SMALL
	fire_sound_text = "a strange noise"
	can_suppress = 0
	burst_size = 2 // burst has to be stored here
	can_charge = FALSE
	selfcharge = TRUE
	charge_delay = 10
	restricted_species = list(/datum/species/vox)
	ammo_type = list(/obj/item/ammo_casing/energy/spike)

/obj/item/gun/energy/spikethrower/emp_act()
	return

/obj/item/ammo_casing/energy/spike
	name = "alloy spike"
	desc = "A broadhead spike made out of a weird silvery metal."
	projectile_type = /obj/item/projectile/bullet/spike
	muzzle_flash_effect = null
	e_cost = 100
	delay = 3 //and delay has to be stored here on energy guns
	select_name = "spike"
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
		H.bleed(50)
	..()

//This gun only functions for armalis. The on-sprite is too huge to render properly on other sprites.
/obj/item/gun/energy/noisecannon
	name = "alien heavy cannon"
	desc = "It's some kind of enormous alien weapon, as long as a man is tall."
	icon_state = "noisecannon"
	item_state = "noisecannon"
	recoil = 1
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/sonic)
	cell_type = /obj/item/stock_parts/cell/super
	restricted_species = list(/datum/species/vox/armalis)
	sprite_sheets_inhand = list("Vox Armalis" = 'icons/mob/species/armalis/held.dmi') //Big guns big birds.

/obj/item/gun/energy/noisecannon/update_icon()
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

	weaken = 5
	stun = 5
