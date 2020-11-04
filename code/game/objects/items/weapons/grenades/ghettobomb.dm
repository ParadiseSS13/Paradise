//improvised explosives//

/obj/item/grenade/iedcasing
	name = "improvised firebomb"
	desc = "A weak, improvised incendiary device."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "improvised_grenade"
	item_state = "flashbang"
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	slot_flags = SLOT_BELT
	active = 0
	det_time = 50
	display_timer = 0
	var/list/times

/obj/item/grenade/iedcasing/New()
	..()
	overlays += "improvised_grenade_filled"
	overlays += "improvised_grenade_wired"
	times = list("5" = 10, "-1" = 20, "[rand(30, 80)]" = 50, "[rand(65, 180)]" = 20)// "Premature, Dud, Short Fuse, Long Fuse"=[weighting value]
	det_time = text2num(pickweight(times))
	if(det_time < 0) //checking for 'duds'
		det_time = rand(30,80)

/obj/item/grenade/iedcasing/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/food/drinks/cans/can = locate() in contents
	if(can)
		can.pixel_x = 0 //Reset the sprite's position to make it consistent with the rest of the IED
		can.pixel_y = 0
		var/mutable_appearance/can_underlay = new(can)
		can_underlay.layer = FLOAT_LAYER
		can_underlay.plane = FLOAT_PLANE
		underlays += can_underlay


/obj/item/grenade/iedcasing/attack_self(mob/user) //
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='warning'>You light the [name]!</span>")
			active = TRUE
			overlays -= "improvised_grenade_filled"
			icon_state = initial(icon_state) + "_active"
			add_fingerprint(user)
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)

			message_admins("[ADMIN_LOOKUPFLW(user)] has primed a [name] for detonation at [ADMIN_COORDJMP(bombturf)].")
			log_game("[key_name(user)] has primed a [name] for detonation at [A.name] [COORD(bombturf)].")
			investigate_log("[key_name(user)] has primed a [name] for detonation at [A.name] [COORD(bombturf)])", INVESTIGATE_BOMB)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			addtimer(CALLBACK(src, .proc/prime), det_time)

/obj/item/grenade/iedcasing/prime() //Blowing that can up
	update_mob()
	explosion(loc, -1, -1, 2, flame_range = 4)	// small explosion, plus a very large fireball.
	qdel(src)

/obj/item/grenade/iedcasing/examine(mob/user)
	. = ..()
	. += "You can't tell when it will explode!"
