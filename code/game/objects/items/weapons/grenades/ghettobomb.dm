//improvised explosives//

/obj/item/grenade/iedcasing
	name = "improvised firebomb"
	desc = "A sketchy improvised incendiary device."
	icon_state = "improvised_grenade"
	throw_range = 7
	display_timer = FALSE
	modifiable_timer = FALSE
	var/list/times

/obj/item/grenade/iedcasing/examine(mob/user)
	. = ..()
	. += "<span class='warning'>You have no idea how long the fuze will last for until it explodes!</span>"

/obj/item/grenade/iedcasing/Initialize(mapload)
	. = ..()
	overlays += "improvised_grenade_filled"
	overlays += "improvised_grenade_wired"
	times = list("5" = 10, "-1" = 20, "[rand(30, 80)]" = 50, "[rand(65, 180)]" = 20)// "Premature, Dud, Short Fuse, Long Fuse"=[weighting value]
	det_time = text2num(pickweight(times))
	if(det_time < 0) //checking for 'duds'
		det_time = rand(30,80)

/obj/item/grenade/iedcasing/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/drinks/cans/can = locate() in contents
	if(can)
		can.pixel_x = 0 //Reset the sprite's position to make it consistent with the rest of the IED
		can.pixel_y = 0
		var/mutable_appearance/can_underlay = new(can)
		can_underlay.layer = FLOAT_LAYER
		can_underlay.plane = FLOAT_PLANE
		underlays += can_underlay


/obj/item/grenade/iedcasing/attack_self__legacy__attackchain(mob/user) //
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='warning'>You light [src]!</span>")
			active = TRUE
			overlays -= "improvised_grenade_filled"
			icon_state = initial(icon_state) + "_active"
			add_fingerprint(user)
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)

			message_admins("[key_name_admin(user)] has primed a [name] for detonation at [A.name] [ADMIN_JMP(bombturf)]")
			log_game("[key_name(user)] has primed a [name] for detonation at [A.name] [COORD(bombturf)]")
			investigate_log("[key_name(user)] has primed a [name] for detonation at [A.name] [COORD(bombturf)])", INVESTIGATE_BOMB)
			add_attack_logs(user, src, "has primed for detonation", ATKLOG_FEW)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			addtimer(CALLBACK(src, PROC_REF(prime)), det_time)

/obj/item/grenade/iedcasing/prime() //Blowing that can up
	update_mob()
	explosion(loc, -1, -1, 2, flame_range = 4, cause = "IED grenade")	// small explosion, plus a very large fireball.
	qdel(src)
