/obj/effect/proc_holder/spell/infinite_guns
	name = "Lesser Summon Guns"
	desc = "Why reload when you have infinite guns? Summons an unending stream of bolt action rifles. Requires both hands free to use."
	invocation_type = "none"

	school = "conjuration"
	base_cooldown = 600
	clothes_req = TRUE
	cooldown_min = 10 //Gun wizard
	action_icon_state = "bolt_action"
	var/gun_type = /obj/item/gun/projectile/shotgun/boltaction/enchanted

/obj/effect/proc_holder/spell/infinite_guns/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/infinite_guns/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		C.drop_item()
		C.swap_hand()
		C.drop_item()
		var/obj/item/gun/projectile/shotgun/boltaction/enchanted/GUN = new gun_type()
		C.put_in_hands(GUN)

/obj/effect/proc_holder/spell/infinite_guns/fireball
	name = "Rapid-fire Fireball"
	desc = "Multiple Fireballs. Need I explain more? Requires both hands free to use."

	school = "evocation"
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
	item_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	color = "#e1ff00" // red + yellow = orange
	guns_left = 20
	fire_sound = 'sound/magic/Fireball.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/fireball
	flags = NOBLUDGEON | DROPDEL | ABSTRACT

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/customised_abstract_text(mob/living/carbon/owner)
	. = ..()
	return "<span class='warning'>[owner.p_their(TRUE)] [owner.l_hand == src ? "left hand" : "right hand"] is burning in magic fire.</span>"

/obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/fireball
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/fireball

/obj/item/ammo_casing/magic/arcane_barrage/fireball
	projectile_type = /obj/item/projectile/magic/fireball
	muzzle_flash_effect = null

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/linked
	var/obj/effect/proc_holder/spell/infinite_guns/fireball/basic/source

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/linked/Initialize(mapload, new_source)
	. = ..()
	source = new_source

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/linked/Destroy()
	source = null
	return ..()

/obj/effect/proc_holder/spell/infinite_guns/fireball/basic
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."
	base_cooldown = 6 SECONDS
	clothes_req = FALSE
	invocation = "ONI SOMA"
	invocation_type = ""
	var/invocation_type_on_shoot = "shout"
	cooldown_min = 2 SECONDS
	gun_type = /obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/linked/basic
	action_icon_state = "fireball0"

/obj/effect/proc_holder/spell/infinite_guns/fireball/basic/cast(list/targets, mob/user)
	revert_cast() // to disable cooldown

	var/mob/living/carbon/C = targets[1]
	if(C.l_hand?.type == gun_type || C.r_hand?.type == gun_type)
		remove_weapon(any_hand = TRUE)
		return FALSE

	if(!C.drop_item())
		to_chat(user, "[user.get_active_hand()] is stuck to your hand, you cannot invoke a fireball over it!")
		return FALSE

	var/obj/item/gun/projectile/shotgun/boltaction/enchanted/GUN = new gun_type(FALSE, src)
	C.put_in_hands(GUN)
	RegisterSignal(C, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(remove_weapon), override = TRUE)
	C.changeNext_click(0) // allows to get fireball and instantly shoot it

/obj/effect/proc_holder/spell/infinite_guns/fireball/basic/proc/remove_weapon(any_hand = FALSE)
	SIGNAL_HANDLER
	var/mob/owner = action.owner
	if(!any_hand && !(owner.get_active_hand()?.type ==  gun_type))
		return

	if(owner.l_hand?.type == gun_type)
		qdel(owner.l_hand)
		owner.update_inv_l_hand()
		return

	if(owner.r_hand?.type == gun_type)
		qdel(owner.r_hand)
		owner.update_inv_r_hand()

/obj/effect/proc_holder/spell/infinite_guns/fireball/basic/proc/yell_on_shoot(mob/user)
	invocation_type = invocation_type_on_shoot
	invocation(user)
	invocation_type = initial(invocation_type)

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/linked/basic
	name = "ball of fire"
	desc = "A flame, ready to launch from your hand."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "fireball"
	guns_left = 0
	flags = NOBLUDGEON | DROPDEL | ABSTRACT | NODROP
	item_state = ""

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/linked/basic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IGNORE_HANDS_RESTRICTIONS, "fireball")

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/linked/basic/Destroy()
	if(source)
		source.UnregisterSignal(source.action.owner, COMSIG_MOB_WILLINGLY_DROP)
	. = ..()

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/linked/basic/shoot_live_shot(mob/living/user, atom/target, pointblank, message)
	if(source)
		source.cooldown_handler.start_recharge()
		source.yell_on_shoot(user)
	. = ..()

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/linked/basic/customised_abstract_text(mob/living/carbon/owner)
	return

/obj/effect/proc_holder/spell/infinite_guns/fireball/basic/greater
	name = "Greater Homing Fireball"
	desc = "This spell fires a strong homing fireball at a target."
	invocation = "ZI-ONI SOMA"
	gun_type = /obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/linked/basic/greater

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/fireball/linked/basic/greater
	name = "huge ball of fire"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/fireball/greater

/obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/fireball/greater
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/fireball/greater

/obj/item/ammo_casing/magic/arcane_barrage/fireball/greater
	projectile_type = /obj/item/projectile/homing/magic/homing_fireball
