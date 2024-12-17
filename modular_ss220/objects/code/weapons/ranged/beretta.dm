// Beretta M9
/obj/item/gun/projectile/automatic/pistol/beretta
	name = "Beretta M9"
	desc = "Один из самых распространенных и узнаваемых пистолетов во вселенной. К сожалению, из-за особенности ствола, на пистолет нельзя приделать глушитель. Старая добрая классика."
	icon = 'modular_ss220/objects/icons/guns.dmi'
	lefthand_file = 'modular_ss220/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/guns_righthand.dmi'
	icon_state = "beretta_modified"
	item_state = "beretta_modified"
	w_class = WEIGHT_CLASS_NORMAL
	can_suppress = FALSE
	can_flashlight = TRUE
	unique_reskin = TRUE
	mag_type = /obj/item/ammo_box/magazine/beretta
	fire_sound = 'modular_ss220/objects/sound/weapons/gunshots/beretta_shot.ogg'

/obj/item/gun/projectile/automatic/pistol/beretta/Initialize(mapload)
	. = ..()
	options["Modified grip"] = "beretta_modified"
	options["Black skin"] = "beretta_black"
	options["Desert skin"] = "beretta_desert"

/obj/item/gun/projectile/automatic/pistol/beretta/update_icon_state()
	if(current_skin)
		icon_state = "[current_skin][chambered ? "" : "-e"]"
	else
		icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/pistol/beretta/update_overlays()
	. = list()
	if(gun_light)
		var/flashlight = "beretta_light"
		if(gun_light.on)
			flashlight = "beretta_light-on"
		. += image(icon = icon, icon_state = flashlight, pixel_x = 0)

/obj/item/gun/projectile/automatic/pistol/beretta/ui_action_click()
	toggle_gunlight()

// Beretta Ammo Boxes
/obj/item/ammo_box/beretta
	name = "box of rubber 9x19mm cartridges"
	desc = "Содержит до 30 резиновых патронов калибра 9x19mm."
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "9mmr_box"
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = /obj/item/ammo_casing/beretta/mmrub919
	max_ammo = 30

/obj/item/ammo_box/beretta/mm919
	name = "box of lethal 9x19mm cartridges"
	desc = "Содержит до 20 летальных патронов калибра 9x19mm."
	icon_state = "9mm_box"
	ammo_type = /obj/item/ammo_casing/beretta/mm919
	max_ammo = 20

/obj/item/ammo_box/beretta/mmbsp919
	name = "box of bluespace 9x19mm cartridges"
	desc = "Содержит до 20 Блюспейс патронов калибра 9x19mm."
	icon_state = "9mmb_box"
	ammo_type = /obj/item/ammo_casing/beretta/mmbsp919
	max_ammo = 20

/obj/item/ammo_box/beretta/mmap919
	name = "box of armor-penetration 9x19mm cartridges"
	desc = "Содержит до 20 бронебойных патронов калибра 9x19mm."
	icon_state = "9mmap_box"
	ammo_type = /obj/item/ammo_casing/beretta/mmap919
	max_ammo = 20

// Beretta Magazines
/obj/item/ammo_box/magazine/beretta
	name = "beretta rubber 9x19mm magazine"
	desc = "Магазин резиновых патронов калибра 9x19mm."
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "berettar"
	multi_sprite_step = 2
	ammo_type = /obj/item/ammo_casing/beretta/mmrub919
	max_ammo = 10
	multiload = 0
	slow_loading = TRUE
	caliber = "919mm"

/obj/item/ammo_box/magazine/beretta/mm919
	name = "beretta lethal 9x19mm magazine"
	desc = "Магазин летальных патронов калибра 9x19mm."
	icon_state = "berettal"
	ammo_type = /obj/item/ammo_casing/beretta/mm919

/obj/item/ammo_box/magazine/beretta/mmbsp919
	name = "beretta bluespace 9x19mm magazine"
	desc = "Магазин экспериментальных Блюспейс патронов калибра 9x19mm. Из-за особенности корпуса вмещает только Блюспейс патроны."
	icon_state = "berettab"
	ammo_type = /obj/item/ammo_casing/beretta/mmbsp919
	caliber = "919bmm"

/obj/item/ammo_box/magazine/beretta/mmap919
	name = "beretta armor-piercing 9x19mm magazine"
	desc = "Магазин бронебойных патронов калибра 9x19mm."
	icon_state = "berettaap"
	ammo_type = /obj/item/ammo_casing/beretta/mmap919

// Beretta Casings
/obj/item/ammo_casing/beretta/mmbsp919
	name = "9x19mm bluespace bullet casing"
	desc = "A 9x19mm bluespace bullet casing."
	caliber = "919bmm"
	projectile_type = /obj/item/projectile/bullet/mmbsp919

/obj/item/ammo_casing/beretta/mmap919
	name = "9x19mm armor-piercing bullet casing"
	desc = "A 9x19 armor-piercing bullet casing."
	caliber = "919mm"
	projectile_type = /obj/item/projectile/bullet/mmap919

/obj/item/ammo_casing/beretta/mmrub919
	name = "9x19mm rubber bullet casing"
	desc = "A 9x19 rubber bullet casing."
	caliber = "919mm"
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "casingmm919"
	projectile_type = /obj/item/projectile/bullet/weakbullet4

/obj/item/ammo_casing/beretta/mm919
	name = "9x19mm lethal bullet casing"
	desc = "A 9x19 lethal bullet casing."
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "casingmm919"
	caliber = "919mm"
	projectile_type = /obj/item/projectile/bullet/weakbullet3

// Beretta Projectiles
/obj/item/projectile/bullet/mmap919
	name = "9x19mm armor-piercing bullet"
	damage = 18
	armour_penetration_percentage = 35
	armour_penetration_flat = 15

/obj/item/projectile/bullet/mmbsp919
	name = "9x19 bluespace bullet"
	damage = 18
	speed = 0.2

// Beretta Supply Packs
/datum/supply_packs/security/armory/beretta
	name = "Beretta M9 Crate"
	contains = list(/obj/item/gun/projectile/automatic/pistol/beretta,
					/obj/item/gun/projectile/automatic/pistol/beretta)
	cost = 650
	containername = "beretta m9 pack"

/datum/supply_packs/security/armory/berettarubberammo
	name = "Beretta M9 Rubber Ammunition Crate"
	contains = list(/obj/item/ammo_box/beretta,
					/obj/item/ammo_box/beretta,
					/obj/item/ammo_box/magazine/beretta,
					/obj/item/ammo_box/magazine/beretta)
	cost = 350
	containername = "beretta rubber ammunition pack"

/datum/supply_packs/security/armory/berettalethalammo
	name = "Beretta M9 Lethal Ammunition Crate"
	contains = list(/obj/item/ammo_box/beretta/mm919,
					/obj/item/ammo_box/beretta/mm919,
					/obj/item/ammo_box/magazine/beretta/mm919,
					/obj/item/ammo_box/magazine/beretta/mm919)
	cost = 400
	containername = "beretta lethal ammunition pack"

/datum/supply_packs/security/armory/berettaexperimentalammo
	name = "Beretta M9 Bluespace Ammunition Crate"
	contains = list(/obj/item/ammo_box/beretta/mmbsp919,
					/obj/item/ammo_box/beretta/mmbsp919,
					/obj/item/ammo_box/magazine/beretta/mmbsp919,
					/obj/item/ammo_box/magazine/beretta/mmbsp919)
	cost = 650
	containername = "beretta bluespace ammunition pack"

/datum/supply_packs/security/armory/berettaarmorpiercingammo
	name = "Beretta M9 Armor-piercing Ammunition Crate"
	contains = list(/obj/item/ammo_box/beretta/mmap919,
					/obj/item/ammo_box/beretta/mmap919,
					/obj/item/ammo_box/magazine/beretta/mmap919,
					/obj/item/ammo_box/magazine/beretta/mmap919)
	cost = 500
	containername = "beretta AP ammunition pack"

// Beretta Designs
/datum/design/box_beretta/lethal
	name = "Beretta M9 Lethal Ammo Box (9mm)"
	desc = "A box of 20 lethal rounds for Beretta M9."
	id = "box_beretta"
	req_tech = list("combat" = 2, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_SILVER = 600)
	build_path = /obj/item/ammo_box/beretta/mm919
	category = list("Weapons")

/datum/design/box_beretta/ap
	name = "Beretta M9 AP Ammo Box (9mm)"
	desc = "A box of 20 armor-piercing rounds for Beretta M9."
	id = "box_beretta_ap"
	req_tech = list("combat" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_SILVER = 600, MAT_GLASS = 1000)
	build_path = /obj/item/ammo_box/beretta/mmap919
	category = list("Weapons")

/datum/design/box_beretta/bluespace
	name = "Beretta M9 Bluespace Ammo Box (9mm)"
	desc = "A box of 20 high velocity bluespace rounds for Beretta M9."
	id = "box_beretta_bsp"
	req_tech = list("combat" = 6, "materials" = 5, "bluespace" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_SILVER = 600, MAT_BLUESPACE = 1000)
	build_path = /obj/item/ammo_box/beretta/mmbsp919
	category = list("Weapons")
