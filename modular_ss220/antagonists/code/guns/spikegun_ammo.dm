/obj/item/stock_parts/cell/vox_spike
	name = "\improper vox spike power cell"
	desc = "Зарядная пурпурная светящаяся стандартная ячейка для шипометов."
	icon = 'modular_ss220/antagonists/icons/guns/ammo.dmi'
	icon_state = "spike_cell"
	maxcharge = 1000


/obj/item/ammo_casing/energy/vox_spike
	name = "шип"
	desc = "Маленький самозаряжающийся кристаллический шип испускающий энергетический вайб."
	muzzle_flash_effect = null
	e_cost = 100
	delay = 3 //and delay has to be stored here on energy guns
	select_name = "spike"
	fire_sound = 'modular_ss220/antagonists/sound/guns/gun_es4.ogg'
	projectile_type = /obj/item/projectile/bullet/vox_spike
	e_cost = 25	// 1000 / (50*3) = ~13 выстрелов

/obj/item/projectile/bullet/vox_spike
	name = "шип"
	desc = "Маленький самозаряжающийся кристаллический шип испускающий энергетический вайб."
	icon_state = "magspear"
	armour_penetration_flat = 20
	damage = 7
	knockdown = 0
	var/bleed_loss = 5

/obj/item/projectile/bullet/vox_spike/on_hit(atom/target, blocked = 0)
	if((blocked < 100) && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed(bleed_loss)
	. = ..()


/obj/item/ammo_casing/energy/vox_spike/long
	projectile_type = /obj/item/projectile/bullet/vox_spike/long
	e_cost = 50	// 1000 / (50*3) = 6 выстрелов

/obj/item/projectile/bullet/vox_spike/long
	damage = 5
	armour_penetration_flat = 60
	jitter = 1 SECONDS
	forcedodge = 3
	bleed_loss = 3


/obj/item/ammo_casing/energy/vox_spike/big
	projectile_type = /obj/item/projectile/bullet/vox_spike/big
	e_cost = 80	// 1000 / (80*3) = 4 выстрела

/obj/item/projectile/bullet/vox_spike/big
	damage = 15
	stamina = 50
	stutter = 2 SECONDS
	jitter = 4 SECONDS
	speed = 2
	bleed_loss = 10

	tile_dropoff = 1	//how much damage should be decremented as the bullet moves
	tile_dropoff_s = 2.5	//same as above but for stamina

	ricochets_max = 3
	ricochet_chance = 50
