/datum/spell/infinite_guns
	name = "Lesser Summon Guns"
	desc = "Why reload when you have infinite guns? Summons an unending stream of bolt action rifles. Requires both hands free to use."

	base_cooldown = 600
	cooldown_min = 10 //Gun wizard
	action_icon_state = "bolt_action"
	var/gun_type = /obj/item/gun/projectile/shotgun/boltaction/enchanted

/datum/spell/infinite_guns/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/infinite_guns/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		C.drop_item()
		C.swap_hand()
		C.drop_item()
		var/obj/item/gun/projectile/shotgun/boltaction/enchanted/GUN = new gun_type()
		C.put_in_hands(GUN)

/datum/spell/infinite_guns/fireball
	name = "Rapid-fire Fireball"
	desc = "Multiple Fireballs. Need I explain more? Requires both hands free to use."

	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	invocation = "ONI SOMA-SOMA-SOMA"
	invocation_type = "shout"
	action_icon_state = "explosion"
	gun_type = /obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball
	name = "small ball of fire"
	desc = "A small flame, ready to launch from your hand."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unathi"
	color = "#e1ff00" // red + yellow = orange
	guns_left = 20
	fire_sound = 'sound/magic/Fireball.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/fireball
	flags = NOBLUDGEON | DROPDEL

/obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/fireball
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/fireball

/obj/item/ammo_casing/magic/arcane_barrage/fireball
	projectile_type = /obj/item/projectile/magic/fireball
	muzzle_flash_effect = null
