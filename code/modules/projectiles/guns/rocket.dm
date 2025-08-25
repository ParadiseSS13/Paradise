/obj/item/gun/rocketlauncher
	var/projectile
	name = "rocket launcher"
	desc = "A rocket propelled grenade launcher. Holds one shell at a time."
	icon_state = "rocket"
	item_state = "rocket"
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 3
	force = 15
	origin_tech = "combat=6;syndicate=7"
	fire_sound = 'sound/weapons/blastcannon.ogg'
	fire_delay = 40
	recoil = 2
	var/missile_speed = 2
	var/missile_range = 30


/obj/item/gun/rocketlauncher/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 2, flags = SCOPE_TURF_ONLY | SCOPE_NEED_ACTIVE_HAND)

/obj/item/gun/rocketlauncher/examine(mob/user)
	. = ..()
	. += span_notice("It is currently [chambered ? "" : "un"]loaded.")


/obj/item/gun/rocketlauncher/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/ammo_casing/rocket))
		return ..()
	if(!chambered)
		user.transfer_item_to(I, src)
		chambered = I
		to_chat(user, span_notice("You put the rocket in [src]."))
	else
		to_chat(user, span_notice("[src] cannot hold another rocket."))

/obj/item/gun/rocketlauncher/process_chamber()
	QDEL_NULL(chambered)

/obj/item/gun/rocketlauncher/can_shoot()
	return chambered
