/obj/item/gun/grenadelauncher
	name = "grenade launcher"
	desc = "a terrible, terrible thing. It's really awful!"
	icon_state = "riotgun"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 10
	var/list/grenades = list()
	var/max_grenades = 3

	materials = list(MAT_METAL = 2000)

/obj/item/gun/grenadelauncher/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		. += SPAN_NOTICE("[length(grenades)] / [max_grenades] grenades.")

/obj/item/gun/grenadelauncher/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/grenade))
		return ..()

	if(length(grenades) >= max_grenades)
		to_chat(user, SPAN_WARNING("[src] cannot hold more grenades!"))

	if(!user.transfer_item_to(used, src))
		to_chat(user, SPAN_WARNING("[used] is stuck to your hand!"))
		return ITEM_INTERACT_COMPLETE

	grenades += used
	to_chat(user, SPAN_NOTICE("You put [used] in [src]."))
	to_chat(user, SPAN_NOTICE("[length(grenades)] / [max_grenades] grenades."))
	return ITEM_INTERACT_COMPLETE

/obj/item/gun/grenadelauncher/try_to_shoot_gun(atom/target, mob/living/user, proximity)
	if(target == user)
		return

	if(length(grenades))
		fire_grenade(target,user)
	else
		to_chat(user, SPAN_DANGER("[src] is empty."))

/obj/item/gun/grenadelauncher/proc/fire_grenade(atom/target, mob/user)
	user.visible_message(
		SPAN_DANGER("[user] fires a grenade!"),
		SPAN_DANGER("You fire the grenade launcher!"),
		SPAN_DANGER("You hear a grenade launcher!")
	)
	var/obj/item/grenade/chem_grenade/F = grenades[1] //Now with less copypasta!
	grenades -= F
	F.loc = user.loc
	F.throw_at(target, 30, 2, user)
	message_admins("[key_name_admin(user)] fired a grenade ([F.name]) from a grenade launcher ([name]).")
	log_game("[key_name(user)] fired a grenade ([F.name]) from a grenade launcher ([name]).")
	F.active = TRUE
	F.icon_state = initial(icon_state) + "_active"
	playsound(user.loc, 'sound/weapons/armbomb.ogg', 75, TRUE, -3)
	spawn(15)
		F.prime()
