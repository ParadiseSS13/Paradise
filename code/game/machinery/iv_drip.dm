#define IV_TAKING 0
#define IV_INJECTING 1

/obj/machinery/iv_drip
	name = "\improper IV drip"
	icon = 'icons/goonstation/objects/iv.dmi'
	icon_state = "stand"
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/item/reagent_containers/iv_bag/bag = null

/obj/machinery/iv_drip/update_icon()
	cut_overlays()

	if(bag)
		add_overlay("hangingbag")
		if(bag.reagents.total_volume)
			var/image/filling = image('icons/goonstation/objects/iv.dmi', src, "hangingbag-fluid")
			filling.icon += mix_color_from_reagents(bag.reagents.reagent_list)
			add_overlay(filling)

/obj/machinery/iv_drip/MouseDrop(mob/living/target)
	if(usr.incapacitated())
		return

	if(!ishuman(usr) || !iscarbon(target))
		return

	if(Adjacent(target) && usr.Adjacent(target))
		bag.afterattack(target, usr, TRUE)

/obj/machinery/iv_drip/attack_hand(mob/user)
	if(bag)
		user.put_in_hands(bag)
		bag.update_icon()
		bag = null
		update_icon()

/obj/machinery/iv_drip/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/iv_bag))
		if(bag)
			to_chat(user, "<span class='warning'>[src] already has an IV bag!</span>")
			return
		if(!user.drop_item())
			return

		I.forceMove(src)
		bag = I
		to_chat(user, "<span class='notice'>You attach [I] to [src].</span>")
		update_icon()
	else if (bag && istype(I, /obj/item/reagent_containers))
		bag.attackby(I)
		I.afterattack(bag, usr, TRUE)
		update_icon()
	else
		return ..()

/obj/machinery/iv_drip/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc)
	qdel(src)

/obj/machinery/iv_drip/examine(mob/user)
	. = ..()
	if(bag)
		. += bag.examine(user)

/obj/machinery/iv_drip/Move(NewLoc, direct)
	. = ..()
	if(!.) // ..() will return 0 if we didn't actually move anywhere.
		return .
	playsound(loc, pick('sound/items/cartwheel1.ogg', 'sound/items/cartwheel2.ogg'), 100, 1, ignore_walls = FALSE)

#undef IV_TAKING
#undef IV_INJECTING
