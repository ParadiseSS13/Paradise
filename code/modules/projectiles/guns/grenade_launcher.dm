/obj/item/gun/grenadelauncher
	name = "grenade launcher"
	desc = "a terrible, terrible thing. it's really awful!"
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 10
	var/list/grenades = list()
	var/max_grenades = 3

	materials = list(MAT_METAL=2000)

/obj/item/gun/grenadelauncher/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		. += span_notice("[length(grenades)] / [max_grenades] grenades.")

/obj/item/gun/grenadelauncher/attackby__legacy__attackchain(obj/item/I as obj, mob/user as mob, params)
	if((istype(I, /obj/item/grenade)))
		if(length(grenades) < max_grenades)
			if(!user.unequip(I))
				return
			I.forceMove(src)
			grenades += I
			to_chat(user, span_notice("You put the grenade in [src]."))
			to_chat(user, span_notice("[length(grenades)] / [max_grenades] grenades."))
		else
			to_chat(user, span_warning("The grenade launcher cannot hold more grenades."))
	else
		return ..()

/obj/item/gun/grenadelauncher/afterattack__legacy__attackchain(obj/target, mob/user , flag)
	if(target == user)
		return

	if(length(grenades))
		fire_grenade(target,user)
	else
		to_chat(user, span_danger("The grenade launcher is empty."))

/obj/item/gun/grenadelauncher/proc/fire_grenade(atom/target, mob/user)
	user.visible_message(span_danger("[user] fired a grenade!"), \
						span_danger("You fire the grenade launcher!"))
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
