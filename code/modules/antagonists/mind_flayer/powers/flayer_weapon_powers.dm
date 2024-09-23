/datum/spell/flayer/self/weapon
	name = "Create weapon"
	desc = "This really shouldn't be here"
	power_type = FLAYER_UNOBTAINABLE_POWER
	action_icon = 'icons/mob/robot_items.dmi'
	action_icon_state = "lollipop"
	base_cooldown = 1 SECONDS //This just handles retracting and deploying the weapon, weapon charge will be fully separate
	/// Typepath of the weapon
	var/weapon_type
	/// Reference to the weapon itself, set on cast or on_purchase_upgrade
	var/obj/item/weapon_ref
	/// The object that stores a retracted weapon
	var/obj/weapon_holder

/datum/spell/flayer/self/weapon/Destroy(force, ...)
	. = ..()
	weapon_ref = null
	weapon_holder = null

/datum/spell/flayer/self/weapon/cast(list/targets, mob/living/carbon/human/user)
	if(weapon_ref && (user.l_hand == weapon_ref || user.r_hand == weapon_ref))
		retract(user, TRUE)
		return

	if(!user.drop_item())
		to_chat(user, "[user.get_active_hand()] is stuck to your hand!")
		return FALSE

	if(!weapon_ref)
		weapon_ref = new weapon_type(user, src)
	weapon_ref.flags |= (ABSTRACT | NODROP) // Just in case the item doesn't start with both of these, or somehow loses them.

	SEND_SIGNAL(user, COMSIG_MOB_WEAPON_APPEARS)
	user.put_in_hands(weapon_ref)
	playsound(get_turf(user), 'sound/mecha/mechmove03.ogg', 50, TRUE)
	RegisterSignal(user, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(retract), user)
	RegisterSignal(user, COMSIG_FLAYER_RETRACT_IMPLANTS, PROC_REF(retract), user)
	return weapon_ref

/datum/spell/flayer/self/weapon/proc/retract(mob/owner, any_hand = FALSE)
	SIGNAL_HANDLER // COMSIG_MOB_WILLINGLY_DROP + COMSIG_FLAYER_RETRACT_IMPLANTS
	if(!any_hand && !istype(owner.get_active_hand(), weapon_type))
		return
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, unEquip), weapon_ref, TRUE)
	INVOKE_ASYNC(weapon_ref, TYPE_PROC_REF(/atom/movable, forceMove), weapon_holder)
	owner.update_inv_l_hand()
	owner.update_inv_r_hand()
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)
	UnregisterSignal(owner, COMSIG_MOB_WILLINGLY_DROP)
	UnregisterSignal(owner, COMSIG_FLAYER_RETRACT_IMPLANTS)

/**
	START OF INDIVIDUAL WEAPONS
*/

/datum/spell/flayer/self/weapon/swarmprod
	name = "Swarmprod"
	desc = "We shape our arm into an extended mass of sparking nanites."
	action_icon_state = "elecarm"
	max_level = 3
	base_cost = 60
	upgrade_info = "Increase the rate at which this recharges."
	power_type = FLAYER_INNATE_POWER
	weapon_type = /obj/item/melee/baton/flayerprod

/datum/spell/flayer/self/weapon/swarmprod/on_purchase_upgrade()
	if(!weapon_ref)
		weapon_ref = new weapon_type(flayer.owner.current, src)
	var/obj/item/melee/baton/flayerprod/prod = weapon_ref
	var/obj/item/stock_parts/cell/flayerprod/cell = prod.cell
	cell.chargerate += 200

/datum/spell/flayer/self/weapon/laser
	name = "Laser Arm Augmentation"
	desc = "Our hand melts away, replaced with the barrel of a laser gun."
	action_icon = 'icons/obj/guns/energy.dmi'
	action_icon_state = "laser"
	power_type = FLAYER_PURCHASABLE_POWER
	weapon_type = /obj/item/gun/energy/laser/mounted
	category = FLAYER_CATEGORY_DESTROYER
	base_cost = 100
	max_level = 3
	upgrade_info = "The internal power cell recharges faster."

/datum/spell/flayer/self/weapon/laser/on_purchase_upgrade()
	if(!weapon_ref)
		weapon_ref = new weapon_type(flayer.owner.current, src)
		weapon_ref.flags |= (ABSTRACT | NODROP) // Just in case the item doesn't start with both of these
	var/obj/item/gun/energy/laser/mounted/laser = weapon_ref
	laser.charge_delay -= 1

/datum/spell/flayer/self/weapon/flak_gun //Addressing the lack of FTL references in this game
	name = "Pneumatic Flak Gun"
	desc = "Our hand melts away, replaced with a makeshift cannon that automatically loads with shrapnel."
	action_icon = 'icons/obj/pneumaticCannon.dmi'
	action_icon_state = "pneumaticCannon"
	power_type = FLAYER_PURCHASABLE_POWER
	weapon_type = /obj/item/pneumatic_cannon/flayer
	category = FLAYER_CATEGORY_DESTROYER
	base_cost = 75
	max_level = 3
	upgrade_info = "Reduces the time needed for us to recycle scrap into ammo."

/datum/spell/flayer/self/weapon/flak_gun/on_purchase_upgrade()
	if(!weapon_ref)
		weapon_ref = new weapon_type(flayer.owner.current, src)
		weapon_ref.flags |= (ABSTRACT | NODROP) // Just in case the item doesn't start with both of these
	var/obj/item/pneumatic_cannon/flayer/cannon = weapon_ref
	cannon.charge_time -= 2 SECONDS


/datum/spell/flayer/self/weapon/grapple_arm
	name = "Integrated Grappling Mechanism"
	desc = "Shoot out your arm attached to a cable, then drag yourself over to wherever or whoever it hits."
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

/obj/item/ammo_casing/magic/grapple_ammo/New(obj/item/gun/magic/grapple/grappler)
	. = ..()
	grapple = grappler

/obj/item/ammo_casing/magic/grapple_ammo/Destroy()
	. = ..()
	grapple = null

/obj/item/projectile/tether/flayer
	name = "Grapple Arm"
	range = 10
	damage = 15
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	icon_state = "flayer_claw"
	chain_icon_state = "flayer_tether"
	speed = 3
	yank_speed = 2
	reflectability = REFLECTABILITY_PHYSICAL // This lowkey makes no sense but it's also kinda funny
	/// The ammo this came from
	var/obj/item/ammo_casing/magic/grapple_ammo/ammo

/obj/item/projectile/tether/flayer/New(obj/item/ammo_casing/magic/grapple_ammo/grapple_casing)
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

/datum/spell/flayer/self/weapon/grapple_arm/on_purchase_upgrade()
	cooldown_handler.recharge_duration -= 10 SECONDS
