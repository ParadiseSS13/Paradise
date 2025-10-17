/datum/spell/flayer/self/weapon
	name = "Create weapon"
	desc = "This really shouldn't be here"
	action_icon = 'icons/mob/robot_items.dmi'
	action_icon_state = "lollipop"
	base_cooldown = 1 SECONDS // This just handles retracting and deploying the weapon, weapon charge will be fully separate
	/// Typepath of the weapon
	var/weapon_type
	/// Reference to the weapon itself, set on create_new_weapon
	var/obj/item/weapon_ref

/datum/spell/flayer/self/weapon/New()
	. = ..()
	if(weapon_type && !weapon_ref)
		create_new_weapon()

/datum/spell/flayer/self/weapon/Destroy(force, ...)
	weapon_ref = null
	return ..()

/datum/spell/flayer/self/weapon/proc/create_new_weapon()
	if(!QDELETED(weapon_ref))
		return
	weapon_ref = new weapon_type(src)
	RegisterSignal(weapon_ref, COMSIG_PARENT_QDELETING, PROC_REF(clear_weapon_ref))
	on_purchase_upgrade()

/datum/spell/flayer/self/weapon/proc/clear_weapon_ref()
	weapon_ref = null

/datum/spell/flayer/self/weapon/cast(list/targets, mob/living/carbon/human/user)
	if(weapon_ref && (user.l_hand == weapon_ref || user.r_hand == weapon_ref))
		retract(user, TRUE)
		return

	if(!weapon_ref)
		create_new_weapon()
	// Just in case the item doesn't start with both of these, or somehow loses them.
	weapon_ref.flags |= ABSTRACT
	weapon_ref.set_nodrop(TRUE, user)

	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || (user.get_active_hand() && !user.drop_item()))
		flayer.send_swarm_message("We cannot manifest [weapon_ref] into our active hand...")
		return FALSE

	SEND_SIGNAL(user, COMSIG_MOB_WEAPON_APPEARS)
	user.put_in_hands(weapon_ref)
	playsound(get_turf(user), 'sound/mecha/mechmove03.ogg', 25, TRUE, ignore_walls = FALSE)
	RegisterSignal(user, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(retract), user)
	RegisterSignal(user, COMSIG_FLAYER_RETRACT_IMPLANTS, PROC_REF(retract), user)
	return weapon_ref

/datum/spell/flayer/self/weapon/proc/retract(mob/owner, any_hand = FALSE)
	SIGNAL_HANDLER // COMSIG_MOB_WILLINGLY_DROP + COMSIG_FLAYER_RETRACT_IMPLANTS
	if(!any_hand && !istype(owner.get_active_hand(), weapon_type))
		return
	owner.transfer_item_to(weapon_ref, owner, force = TRUE, silent = TRUE)
	owner.update_inv_l_hand()
	owner.update_inv_r_hand()
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 25, TRUE, ignore_walls = FALSE)
	UnregisterSignal(owner, COMSIG_MOB_WILLINGLY_DROP)
	UnregisterSignal(owner, COMSIG_FLAYER_RETRACT_IMPLANTS)

/**
	START OF INDIVIDUAL WEAPONS
*/

/datum/spell/flayer/self/weapon/swarmprod
	name = "Swarmprod"
	desc = "We shape our arm into an extended mass of sparking nanites."
	action_icon = 'icons/mob/actions/flayer_actions.dmi'
	action_icon_state = "swarmprod"
	max_level = 3
	base_cost = 50
	current_cost = 50 // Innate abilities HAVE to set `current_cost`
	upgrade_info = "Upgrading it recharges the internal power cell faster."
	power_type = FLAYER_INNATE_POWER
	weapon_type = /obj/item/melee/baton/flayerprod

/datum/spell/flayer/self/weapon/swarmprod/on_apply()
	..()
	if(!weapon_ref)
		create_new_weapon()

	var/obj/item/melee/baton/flayerprod/prod = weapon_ref
	var/obj/item/stock_parts/cell/flayerprod/cell = prod.cell
	cell.chargerate = initial(cell.chargerate) + 200 * level // Innate abilities are wack

/datum/spell/flayer/self/weapon/laser
	name = "Laser Arm Augmentation"
	desc = "Allows us to melt our hand away, replacing it with the barrel of a laser gun."
	action_icon = 'icons/obj/guns/energy.dmi'
	action_icon_state = "laser"
	power_type = FLAYER_PURCHASABLE_POWER
	weapon_type = /obj/item/gun/energy/laser/mounted
	category = FLAYER_CATEGORY_DESTROYER
	base_cost = 75
	max_level = 3
	upgrade_info = "The internal power cell recharges faster."

/datum/spell/flayer/self/weapon/laser/on_apply()
	..()
	if(!weapon_ref)
		create_new_weapon()

	var/obj/item/gun/energy/laser/mounted/laser = weapon_ref
	laser.charge_delay = initial(laser.charge_delay) - 1 * level

/datum/spell/flayer/self/weapon/grapple_arm
	name = "Integrated Grappling Mechanism"
	desc = "Allows us to shoot out our arm attached by a cable. We will drag ourself over to wherever or whoever it hits."
	upgrade_info = "Reduce the time between grapples by 10 seconds."
	action_icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	action_icon_state = "flayer_claw"
	base_cooldown = 25 SECONDS
	category = FLAYER_CATEGORY_DESTROYER
	power_type = FLAYER_PURCHASABLE_POWER
	stage = 2
	max_level = 3
	base_cost = 75
	weapon_type = /obj/item/gun/magic/grapple

/obj/item/gun/magic/grapple
	name = "Grapple launcher"
	desc = "A grapple attached to a cable, launched by your internal pneumatics."
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	icon_state = "flayer_claw"
	ammo_type = /obj/item/ammo_casing/magic/grapple_ammo
	fire_sound = 'sound/weapons/batonextend.ogg'
	fire_sound_text = "unwinding cable"
	recharge_rate = 1 // It'll be limited by cooldown, not these charges

/obj/item/ammo_casing/magic/grapple_ammo
	name = "grapple"
	desc = "a hand"
	projectile_type = /obj/item/projectile/tether/flayer
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	icon_state = "flayer_claw"
	caliber = "grapple"
	muzzle_flash_effect = null
	/// The weapon that shot the hook
	var/obj/item/gun/magic/grapple/grapple

/obj/item/ammo_casing/magic/grapple_ammo/Initialize(mapload, obj/item/gun/magic/grapple/grappler)
	. = ..()
	grapple = grappler

/obj/item/ammo_casing/magic/grapple_ammo/Destroy()
	. = ..()
	grapple = null

/obj/item/projectile/tether/flayer
	name = "Grapple Arm"
	range = 10
	damage = 15
	icon_state = "flayer_claw"
	chain_icon_state = "flayer_tether"
	speed = 3
	yank_speed = 2
	/// The ammo this came from
	var/obj/item/ammo_casing/magic/grapple_ammo/ammo

/obj/item/projectile/tether/flayer/Initialize(mapload, obj/item/ammo_casing/magic/grapple_ammo/grapple_casing)
	. = ..()
	ammo = grapple_casing

/obj/item/projectile/tether/flayer/fire(setAngle)
	. = ..()
	make_chain()
	SEND_SIGNAL(firer, COMSIG_FLAYER_RETRACT_IMPLANTS)

/obj/item/projectile/tether/flayer/Destroy()
	. = ..()
	ammo = null

/obj/item/projectile/tether/flayer/on_hit(atom/target, blocked = 0)
	. = ..()
	playsound(target, 'sound/items/zip.ogg', 75, TRUE)
	if(isliving(target) && blocked < 100)
		var/mob/living/creature = target
		creature.visible_message(
			"<span class='notice'>[firer] uses [creature] to pull [firer.p_themselves()] over!</span>",
			"<span class='danger'>You feel a strong tug as [firer] yanks [firer.p_themselves()] over to you!</span>")
		creature.KnockDown(1 SECONDS)
		return
	target.visible_message("<span class='notice'>[firer] drags [firer.p_themselves()] across the room!</span>")

/datum/spell/flayer/self/weapon/grapple_arm/on_apply()
	..()
	cooldown_handler.recharge_duration = base_cooldown - 10 SECONDS * level //Level 1: 15 seconds, level 2: 5 seconds, level 3: No cooldown, just limited by travel time

/*
 * A slightly slower (5 seconds) version of the basic access tuner
 */
/datum/spell/flayer/self/weapon/access_tuner
	name = "Integrated Access Tuner"
	desc = "Allows us to hack any door remotely."
	upgrade_info = ""
	action_icon = 'icons/obj/device.dmi'
	action_icon_state = "hacktool"
	category = FLAYER_CATEGORY_INTRUDER
	weapon_type = /obj/item/door_remote/omni/access_tuner/flayer

/*
 * Shotgun that reloads itself over time with shells that contain 3 pieces of shrapnel
 */
/datum/spell/flayer/self/weapon/shotgun
	name = "Integrated Shrapnel Cannon"
	desc = "Allows us to propel pieces of shrapnel from our arm."
	upgrade_info = "Upgrading it allows us to reload the cannon faster. At the third level, we gain an extra magazine slot."
	action_icon = 'icons/obj/guns/projectile.dmi'
	action_icon_state = "shell_cannon"
	category = FLAYER_CATEGORY_DESTROYER
	power_type = FLAYER_PURCHASABLE_POWER
	base_cost = 50
	static_upgrade_increase = 25
	max_level = 3
	weapon_type = /obj/item/gun/projectile/revolver/doublebarrel/flayer

/datum/spell/flayer/self/weapon/shotgun/on_apply()
	..()
	if(!weapon_ref)
		create_new_weapon()
	var/obj/item/gun/projectile/revolver/doublebarrel/flayer/gun = weapon_ref
	gun.reload_time = initial(gun.reload_time) - 5 SECONDS * (level - 1)
	if(level > 2)
		var/obj/item/ammo_box/magazine/mag = gun.magazine
		mag.max_ammo = 2

/obj/item/gun/projectile/revolver/doublebarrel/flayer
	name = "integrated shrapnel cannon"
	desc = "Allows us to propel shrapnel at high velocities. Cannot be loaded with conventional shotgun shells."
	icon_state = "shell_cannon"
	righthand_file = 'icons/mob/inhands/implants_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/implants_lefthand.dmi'
	flags = NODROP | ABSTRACT
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	mag_type = /obj/item/ammo_box/magazine/internal/shot/flayer
	unique_reskin = FALSE
	can_sawoff = FALSE
	/// How long does it take to reload
	var/reload_time = 30 SECONDS
	COOLDOWN_DECLARE(recharge_time)

/obj/item/gun/projectile/revolver/doublebarrel/flayer/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/gun/projectile/revolver/doublebarrel/flayer/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/gun/projectile/revolver/doublebarrel/flayer/process()
	if(QDELETED(chambered))
		var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
		chambered = AC

	if(!COOLDOWN_FINISHED(src, recharge_time))
		return
	if(magazine.ammo_count() >= magazine.max_ammo)
		return
	magazine.stored_ammo += new magazine.ammo_type
	COOLDOWN_START(src, recharge_time, reload_time)

	// We do this twice if somehow someone managed to unload their chambered bullet, and it needs reinserting
	if(QDELETED(chambered))
		var/obj/item/ammo_casing/AC = magazine.get_round()
		chambered = AC

/obj/item/gun/projectile/revolver/doublebarrel/flayer/shoot_live_shot(mob/living/user, atom/target, pointblank, message)
	. = ..()
	if(chambered)//We have a shell in the chamber
		QDEL_NULL(chambered)
	if(!magazine.ammo_count())
		return
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC

/obj/item/gun/projectile/revolver/doublebarrel/flayer/attack_self__legacy__attackchain(mob/living/user)
	return FALSE // Not getting those shrapnel rounds out of there.

/obj/item/gun/projectile/revolver/doublebarrel/flayer/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	return FALSE // No loading your gun

/obj/item/gun/projectile/revolver/doublebarrel/flayer/sleight_of_handling(mob/living/carbon/human/user)
	return FALSE // Also no loading like this

/obj/item/ammo_box/magazine/internal/shot/flayer
	name = "shell launch system internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/shrapnel
	max_ammo = 1
