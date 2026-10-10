/obj/item/gun/rocketlauncher
	name = "rocket launcher"
	desc = "A rocket propelled grenade launcher. Holds one rocket at a time."
	icon_state = "rocket"
	inhand_icon_state = "rocket"
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
	. += SPAN_NOTICE("It is currently [chambered ? "" : "un"]loaded.")

/obj/item/gun/rocketlauncher/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/ammo_casing/rocket))
		return ..()

	if(chambered)
		to_chat(user, SPAN_NOTICE("[src] cannot hold another rocket!"))
		return ITEM_INTERACT_COMPLETE

	user.transfer_item_to(used, src)
	chambered = used
	to_chat(user, SPAN_NOTICE("You put the rocket in [src]."))
	return ITEM_INTERACT_COMPLETE

/obj/item/gun/rocketlauncher/process_chamber()
	QDEL_NULL(chambered)

/obj/item/gun/rocketlauncher/can_shoot()
	return chambered
