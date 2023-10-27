//Beretta M9//

/obj/item/gun/projectile/automatic/pistol/beretta
	name = "Беретта M9"
	desc = "Один из самых распространенных и узнаваемых пистолетов во вселенной. Старая добрая классика."
	icon = 'modular_ss220/objects/icons/guns.dmi'
	icon_state = "beretta"
	item_state = "beretta"
	mag_type = /obj/item/ammo_box/magazine/beretta
	fire_sound = 'modular_ss220/objects/sound/weapons/gunshots/beretta_shot.ogg'

/obj/item/ammo_box/magazine/beretta
	name = "beretta rubber 9x19mm magazine"
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "berettar"
	multi_sprite_step = 2
	ammo_type = /obj/item/ammo_casing/beretta/mmrub919
	max_ammo = 10
	caliber = "919mmr"

/obj/item/ammo_box/magazine/beretta/mm919
	name = "beretta lethal 9x19mm magazine"
	icon_state = "berettal"
	ammo_type = /obj/item/ammo_casing/beretta/mm919
	caliber = "919mm"

/obj/item/ammo_box/magazine/beretta/mmbsp919
	name = "beretta bluespace 9x19mm magazine"
	icon_state = "berettab"
	ammo_type = /obj/item/ammo_casing/beretta/mmbsp919
	caliber = "919bmm"

/obj/item/ammo_box/magazine/beretta/mmap919
	name = "beretta armor-piercing 9x19mm magazine"
	icon_state = "berettaap"
	ammo_type = /obj/item/ammo_casing/beretta/mmap919
	caliber = "919apmm"

/obj/item/ammo_casing/beretta/mmbsp919
	caliber = "919bmm"
	name = "9x19mm bluespace bullet casing"
	desc = "A 9x19mm bluespace bullet casing."
	projectile_type = /obj/item/projectile/bullet/mmbsp919

/obj/item/projectile/bullet/mmbsp919
	name = "9x19 bluespace bullet"
	damage = 18
	speed = 0.2

/obj/item/ammo_casing/beretta/mmap919
	caliber = "919apmm"
	name = "9x19mm armor-piercing bullet casing"
	desc = "A 9x19 armor-piercing bullet casing."
	projectile_type = /obj/item/projectile/bullet/mmap919

/obj/item/projectile/bullet/mmap919
	name = "9x19mm armor-piercing bullet"
	damage = 18
	armour_penetration_percentage = 35
	armour_penetration_flat = 15

/obj/item/ammo_casing/beretta/mmrub919
	caliber = "919mmr"
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "casingmm919"
	projectile_type = /obj/item/projectile/bullet/weakbullet4

/obj/item/ammo_casing/beretta/mm919
	caliber = "919mm"
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "casingmm919"
	projectile_type = /obj/item/projectile/bullet/weakbullet3

/obj/item/ammo_box/beretta
	name = "box of rubber 9x19mm cartridges"
	desc = "Contains up to 30 rubber 9x19mm cartridges."
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = /obj/item/ammo_casing/beretta/mmrub919
	max_ammo = 30
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "9mmr_box"

/obj/item/ammo_box/beretta/mm919
	name = "box of lethal 9x19mm cartridges"
	desc = "Contains up to 20 9x19mm cartridges."
	ammo_type = /obj/item/ammo_casing/beretta/mm919
	max_ammo = 20
	icon_state = "9mm_box"

/obj/item/ammo_box/beretta/mmbsp919
	name = "box of bluespace 9x19mm cartridges"
	desc = "Contains up to 20 bluespace 9x19mm cartridges."
	ammo_type = /obj/item/ammo_casing/beretta/mmbsp919
	max_ammo = 20
	icon_state = "9mmb_box"

/obj/item/ammo_box/beretta/mmap919
	name = "box of armor-penetration 9x19mm cartridges"
	desc = "Contains up to 20 armor-penetration 9x19mm cartridges."
	ammo_type = /obj/item/ammo_casing/beretta/mmap919
	max_ammo = 20
	icon_state = "9mmap_box"

/datum/supply_packs/security/armory/beretta
	name = "Beretta M9 Crate"
	contains = list(/obj/item/gun/projectile/automatic/pistol/beretta,
					/obj/item/gun/projectile/automatic/pistol/beretta)
	cost = 450
	containername = "beretta m9 pack"

/datum/supply_packs/security/armory/berettarubberammo
	name = "Beretta M9 Rubber Ammunition Crate"
	contains = list(/obj/item/ammo_box/beretta,
					/obj/item/ammo_box/beretta,
					/obj/item/ammo_box/beretta,
					/obj/item/ammo_box/beretta,
					/obj/item/ammo_box/magazine/beretta,
					/obj/item/ammo_box/magazine/beretta)
	cost = 350
	containername = "beretta rubber ammunition pack"

/datum/supply_packs/security/armory/berettalethalammo
	name = "Beretta M9 Lethal Ammunition Crate"
	contains = list(/obj/item/ammo_box/beretta/mm919,
					/obj/item/ammo_box/beretta/mm919,
					/obj/item/ammo_box/beretta/mm919,
					/obj/item/ammo_box/beretta/mm919,
					/obj/item/ammo_box/magazine/beretta/mm919,
					/obj/item/ammo_box/magazine/beretta/mm919)
	cost = 400
	containername = "beretta lethal ammunition pack"

/datum/supply_packs/security/armory/berettaexperimentalammo
	name = "Beretta M9 Bluespace Ammunition Crate"
	contains = list(/obj/item/ammo_box/beretta/mmbsp919,
					/obj/item/ammo_box/beretta/mmbsp919,
					/obj/item/ammo_box/beretta/mmbsp919,
					/obj/item/ammo_box/beretta/mmbsp919,
					/obj/item/ammo_box/magazine/beretta/mmbsp919,
					/obj/item/ammo_box/magazine/beretta/mmbsp919)
	cost = 650
	containername = "beretta bluespace ammunition pack"

/datum/supply_packs/security/armory/berettaarmorpiercingammo
	name = "Beretta M9 Armor-piercing Ammunition Crate"
	contains = list(/obj/item/ammo_box/beretta/mmap919,
					/obj/item/ammo_box/beretta/mmap919,
					/obj/item/ammo_box/beretta/mmap919,
					/obj/item/ammo_box/beretta/mmap919,
					/obj/item/ammo_box/magazine/beretta/mmap919,
					/obj/item/ammo_box/magazine/beretta/mmap919)
	cost = 500
	containername = "beretta AP ammunition pack"

/datum/design/box_beretta/lethal
	name = "Beretta M9 Lethal Ammo Box (9mm)"
	desc = "A box of 20 lethal rounds for Beretta M9"
	id = "box_beretta"
	req_tech = list("combat" = 2, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_SILVER = 600)
	build_path = /obj/item/ammo_box/beretta/mm919
	category = list("Weapons")

/datum/design/box_beretta/ap
	name = "Beretta M9 AP Ammo Box (9mm)"
	desc = "A box of 20 armor-piercing rounds for Beretta M9"
	id = "box_beretta"
	req_tech = list("combat" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_SILVER = 600, MAT_GLASS = 1000)
	build_path = /obj/item/ammo_box/beretta/mmap919
	category = list("Weapons")

/datum/design/box_beretta/bluespace
	name = "Beretta M9 Bluespace Ammo Box (9mm)"
	desc = "A box of 20 high velocity bluespace rounds for Beretta M9"
	id = "box_beretta"
	req_tech = list("combat" = 6, "materials" = 5, "bluespace" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_SILVER = 600, MAT_BLUESPACE = 1000)
	build_path = /obj/item/ammo_box/beretta/mmbsp919
	category = list("Weapons")

