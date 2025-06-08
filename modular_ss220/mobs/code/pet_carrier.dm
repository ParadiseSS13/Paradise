/obj/item/pet_carrier
	name = "маленькая переноска"
	desc = "Переноска для маленьких животных. "
	icon = 'modular_ss220/mobs/icons/pet_carrier.dmi'
	icon_state = "pet_carrier"
	item_state = "pet_carrier"
	max_integrity = 100
	w_class = WEIGHT_CLASS_SMALL
	var/mob_size = MOB_SIZE_SMALL

	var/list/possible_skins = list("black", "blue", "red", "yellow", "green", "purple")
	var/color_skin

	var/opened = TRUE
	var/contains_pet = FALSE
	var/contains_pet_color_open = "#d8d8d8ff"
	var/contains_pet_color_close = "#949494ff"

/obj/item/pet_carrier/normal
	name = "переноска"
	desc = "Переноска для небольших животных. "
	icon_state = "pet_carrier_normal"
	item_state = "pet_carrier_normal"
	max_integrity = 200
	w_class = WEIGHT_CLASS_NORMAL
	mob_size = MOB_SIZE_LARGE


/obj/item/pet_carrier/Initialize(mapload)
	. = ..()
	if(!color_skin)
		color_skin = pick(possible_skins)
	update_icon()

/obj/item/pet_carrier/Destroy()
	free_content()
	. = ..()

/obj/item/pet_carrier/attack_self__legacy__attackchain(mob/user)
	..()
	change_state()

/obj/item/pet_carrier/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/holder))
		var/obj/item/holder/H = I
		for(var/mob/M in H.contents)
			if(put_in_carrier(M, user))
				qdel(H)
				return TRUE
		return FALSE
	. = ..()

/obj/item/pet_carrier/emp_act(intensity)
	for(var/mob/living/M in contents)
		M.emp_act(intensity)

/obj/item/pet_carrier/ex_act(intensity)
	for(var/mob/living/M in contents)
		M.ex_act(intensity)

/obj/item/pet_carrier/proc/put_in_carrier(mob/living/target, mob/living/user)
	if(!opened)
		to_chat(user, span_warning("Ваша переноска закрыта!"))
		return FALSE
	if(contains_pet)
		to_chat(user, span_warning("Ваша переноска заполнена!"))
		return FALSE
	if(target.mob_size > mob_size)
		to_chat(user, span_warning("Ваша переноска слишком мала!"))
		return FALSE
	if(!istype(target, /mob/living/simple_animal/pet))
		to_chat(user, span_warning("Это существо не очень похоже на ручное животное."))
		return FALSE

	target.forceMove(src)
	name += " ([target.name])"
	if(target.desc)
		desc += "\n\nВнутри [target.name]\n"
		desc += target.desc
	contains_pet = TRUE

	to_chat(user, span_notice("Вы поместили [target.name] в [src.name]."))
	to_chat(target, span_notice("[user.name] поместил [user.gender == FEMALE ? "" : "а"] вас в [src.name]."))
	update_icon()
	return TRUE

/obj/item/pet_carrier/proc/try_free_content(atom/new_location, mob/user)
	if(!opened)
		if(user)
			to_chat(user, span_warning("Ваша переноска закрыта! Содержимое невозможно выгрузить!"))
		return FALSE
	free_content(new_location)

/obj/item/pet_carrier/proc/free_content(atom/new_location)
	if(istype(loc,/turf) || length(contents))
		for(var/mob/M in contents)
			var/atom/movable/mob_container
			mob_container = M
			mob_container.forceMove(new_location ? new_location : get_turf(src))
			contains_pet = FALSE
			name = initial(name)
			desc = initial(desc)
			update_icon()
		return TRUE
	return FALSE

/obj/item/pet_carrier/proc/change_state()
	opened = !opened
	update_icon()

/obj/item/pet_carrier/update_icon()
	overlays.Cut()
	if(contains_pet)
		var/mob/living/M
		for(var/mob/living/temp_M in contents)
			M = temp_M
			break
		var/image/I = image(M.icon, icon_state = M.icon_state)
		I.color = opened ? contains_pet_color_open : contains_pet_color_close
		I.pixel_y = M.mob_size <= MOB_SIZE_TINY ? 6 : 3
		overlays += I

	if(!opened)
		var/image/I = image(icon, icon_state = "[icon_state]_door")
		overlays += I

	if(color_skin)
		var/image/I = image(icon, icon_state = "[icon_state]_[color_skin]")
		overlays += I

	return ..()

/obj/item/pet_carrier/emp_act(intensity)
	for(var/mob/living/M in contents)
		M.emp_act(intensity)

/obj/item/pet_carrier/ex_act(intensity)
	for(var/mob/living/M in contents)
		M.ex_act(intensity)

/obj/item/pet_carrier/container_resist(mob/living/L)
	var/breakout_time = 60 SECONDS //1 minute
	var/breakout_time_open = 5 SECONDS //for escape

	if(do_after(L,(breakout_time_open/2), target = src))
		to_chat(L, span_warning("ТЕСТ 1 - Вы начали вылезать из переноски (это займет [breakout_time_open] секунд, не двигайтесь)"))

	if(do_after(L,(breakout_time_open/2)))
		to_chat(L, span_warning("ТЕСТ 2 - Вы начали вылезать из переноски (это займет [breakout_time_open] секунд, не двигайтесь)"))

	if(do_after(L,(breakout_time_open/2), target = loc))
		to_chat(L, span_warning("ТЕСТ 3 - Вы начали вылезать из переноски (это займет [breakout_time_open] секунд, не двигайтесь)"))

	if(do_after(L,(breakout_time_open/2), target = src.loc))
		to_chat(L, span_warning("ТЕСТ 4 - Вы начали вылезать из переноски (это займет [breakout_time_open] секунд, не двигайтесь)"))

	if(do_after(L,(breakout_time_open/2), target = L))
		to_chat(L, span_warning("ТЕСТ 5 - Вы начали вылезать из переноски (это займет [breakout_time_open] секунд, не двигайтесь)"))

	if(do_after(L,(breakout_time_open/2), target = L.loc))
		to_chat(L, span_warning("ТЕСТ 6 - Вы начали вылезать из переноски (это займет [breakout_time_open] секунд, не двигайтесь)"))



	if(opened && L.loc == src)
		to_chat(L, span_warning("Вы начали вылезать из переноски (это займет [breakout_time_open] секунд, не двигайтесь)"))
		spawn(0)
			if(do_after(L,(breakout_time_open), target = src))
				if(!src || !L || L.stat != CONSCIOUS || L.loc != src || !opened)
					to_chat(L, span_warning("Побег прерван!"))
					return

				free_content()
				visible_message(span_warning("[L.name] вылез из переноски."))
		return

	to_chat(L, span_warning("Вы начали ломиться в закрытую дверцу переноски и пытаетесь её выбить или открыть. (это займет [breakout_time] секунд, не двигайтесь)"))
	for(var/mob/O in viewers(usr.loc))
		O.show_message(span_danger("[src.name] начинает трястись!"), 1)

	spawn(0)
		if(do_after(L,(breakout_time), target = src))
			if(!src || !L || L.stat != CONSCIOUS || L.loc != src || opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
				to_chat(L, span_warning("Побег прерван!"))
				return

			var/mob/M = src.loc
			if(istype(M))
				to_chat(M, "[src.name] вырывается из вашей переноски!")
				to_chat(L, "Вы вырываетесь из переноски [M.name]!")
			else
				to_chat(L, "Вы выбираетесь из переноски.")

			//Free & open
			free_content()
			change_state()
		return

/obj/item/pet_carrier/examine(mob/user)
	. = ..()
	. += span_notice("<b>Alt-Click</b> to unload.")
	. += span_notice("<b>Alt-Shift-Click</b> to toggle lock.")

/obj/item/pet_carrier/AltClick(mob/user)
	unload_content(user)

/obj/item/pet_carrier/AltShiftClick(mob/user)
	open_close(user)

/obj/item/pet_carrier/proc/open_close(mob/user)
	if(user.stat || !ishuman(user) || user.restrained())
		return

	change_state()

/obj/item/pet_carrier/proc/unload_content(mob/user)
	if(user.stat || !ishuman(user) || user.restrained())
		return

	try_free_content()

/obj/item/pet_carrier/MouseDrop(obj/over_object)
	if(ishuman(usr))
		var/mob/M = usr

		if(istype(M.loc,/obj/mecha) || M.incapacitated(FALSE, TRUE, TRUE)) // Stops inventory actions in a mech as well as while being incapacitated
			return

		if(over_object == M && Adjacent(M)) // this must come before the screen objects only block
			try_free_content(M, M)
			return

		if((istype(over_object, /obj/structure/table) || istype(over_object, /turf/simulated/floor)) \
			&& length(contents) && loc == usr && !usr.stat && !usr.restrained() && over_object.Adjacent(usr))
			var/turf/T = get_turf(over_object)
			if(istype(over_object, /turf/simulated/floor))
				if(get_turf(usr) != T)
					return // Can only empty containers onto the floor under you
				if("Да" != alert(usr,"Вытащить питомца из [src.name] на [T.name]?","Подтверждение","Да","Нет"))
					return
				if(!(usr && over_object && contents.len && loc == usr && !usr.stat && !usr.restrained() && get_turf(usr) == T))
					return // Something happened while the player was thinking

			usr.face_atom(over_object)
			usr.visible_message(
				span_notice("[usr] вытащил питомца из [src.name] на [over_object.name]."),
				span_notice("Вы вытащили питомца из [src.name] на [over_object.name]."))

			try_free_content(T, usr)
			return TRUE

		if(!is_screen_atom(over_object))
			return ..()
		if(!(loc == usr) || (loc && loc.loc == usr))
			return
		playsound(loc, "rustle", 50, TRUE, -5)
		if(!(M.restrained()) && !(M.stat))
			switch(over_object.name)
				if("r_hand")
					if(!M.unequip(src))
						return
					M.put_in_r_hand(src)
				if("l_hand")
					if(!M.unequip(src))
						return
					M.put_in_l_hand(src)
			add_fingerprint(usr)
			return
