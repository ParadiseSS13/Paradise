/obj/item/gun/projectile/bow
	name = "bow"
	desc = "A sturdy bow made out of wood and reinforced with iron."
	icon_state = "bow"
	item_state = "bow"
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	flags = HANDSLOW
	weapon_weight = WEAPON_HEAVY
	trigger_guard = TRIGGER_GUARD_NONE
	var/draw_sound = 'sound/weapons/draw_bow.ogg'
	var/ready_to_fire = 0
	var/slowdown_when_ready = 2

/obj/item/gun/projectile/bow/ashen //better than wooden
	name = "bone bow"
	desc = "A primitive bow with a sinew bowstring. Typically used by tribal hunters and warriors. Due to the specific design of the bow, it's able to shoot only bone arrows."
	icon_state = "ashenbow"
	item_state = "ashenbow"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/ashen //you can't shoot wooden arrows from bone bow!
	flags = 0
	force = 10
	slowdown_when_ready = 1

/obj/item/gun/projectile/bow/update_icon()
	if(magazine.ammo_count() && !ready_to_fire)
		icon_state = "[initial(icon_state)]_loaded"
	else if(ready_to_fire)
		icon_state = "[initial(icon_state)]_firing"
		slowdown = slowdown_when_ready
	else
		icon_state = initial(icon_state)
		slowdown = initial(slowdown)

/obj/item/gun/projectile/bow/dropped(mob/user)
	if(magazine && magazine.ammo_count())
		magazine.empty_magazine()
		ready_to_fire = FALSE
		update_icon()

	. = ..()

/obj/item/gun/projectile/bow/attack_self(mob/living/user)
	if(!ready_to_fire && magazine.ammo_count())
		ready_to_fire = TRUE
		playsound(user, draw_sound, 100, 1)
		update_icon()
	else
		ready_to_fire = FALSE
		update_icon()

/obj/item/gun/projectile/bow/attackby(obj/item/A, mob/user, params)
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You ready \the [A] into \the [src].</span>")
		update_icon()
		chamber_round()

/obj/item/gun/projectile/bow/can_shoot()
	. = ..()
	if(!ready_to_fire)
		return FALSE

/obj/item/gun/projectile/bow/shoot_with_empty_chamber(mob/living/user as mob|obj)
	return

/obj/item/gun/projectile/bow/process_chamber(eject_casing = 0, empty_chamber = 1)
	. = ..()
	ready_to_fire = FALSE
	update_icon()

// ammo
/obj/item/ammo_box/magazine/internal/bow
	name = "bow internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	caliber = "arrow"
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/bow/ashen
	name = "ashen bow internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone_tipped
	caliber = "bone_arrow"
	max_ammo = 1

/obj/item/projectile/bullet/reusable/arrow //only for wooden bow!
	name = "arrow"
	icon_state = "arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	range = 10
	damage = 25
	damage_type = BRUTE

/obj/item/projectile/bullet/reusable/arrow/bone //A fully upgraded normal arrow; it's got the stats to show. Still *less* damage than a slug, slower, and with negative AP. Only for bone bow!
	name = "bone-tipped arrow"
	icon_state = "bone_arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone_tipped
	range = 12
	damage = 45
	armour_penetration = -10

/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Stab, stab, stab."
	icon_state = "arrow"
	force = 10
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	muzzle_flash_effect = null
	caliber = "arrow"

/obj/item/ammo_casing/caseless/arrow/bone_tipped
	name = "bone-tipped arrow"
	desc = "An arrow made from bone, wood, and sinew. Sturdy and sharp."
	icon_state = "bone_arrow"
	force = 12
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bone
	caliber = "bone_arrow"

//quiver
/obj/item/storage/backpack/quiver
	name = "quiver"
	desc = "A quiver for holding arrows."
	icon_state = "quiver"
	item_state = "quiver"
	storage_slots = 20
	display_contents_with_number = TRUE
	can_hold = list(
		/obj/item/ammo_casing/caseless/arrow
		)

/obj/item/storage/backpack/quiver/full/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow(src)
	update_icon()

/obj/item/storage/backpack/quiver/update_icon()
	if(length(contents) > 0)
		icon_state = "quiver_[clamp(length(contents),1,5)]"
	else
		icon_state = initial(icon_state)

/obj/item/storage/belt/quiver_weaver //belt slot
	name = "weaver chitin quiver"
	desc = "A fireproof quiver made from the chitin of a marrow weaver. Used to hold arrows."
	icon_state = "quiver_weaver"
	item_state = "quiver_weaver"
	storage_slots = 20
	display_contents_with_number = TRUE
	can_hold = list(
		/obj/item/ammo_casing/caseless/arrow
		)
	resistance_flags = FIRE_PROOF

/obj/item/storage/belt/quiver_weaver/full/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow/bone_tipped(src)
