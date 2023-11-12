#define IV_TAKING 0
#define IV_INJECTING 1

/obj/machinery/iv_drip
	name = "\improper IV drip"
	icon = 'icons/goonstation/objects/iv.dmi'
	icon_state = "stand"
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/item/reagent_containers/iv_bag/bag = null

/obj/machinery/iv_drip/Initialize(mapload)
	. = ..()
	if(!mapload || bag) // bag just in case anyone in the future ever adds IV drip subtypes with bags attached
		return
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/iv_drip/LateInitialize()
	var/obj/item/reagent_containers/iv_bag/IV = locate(/obj/item/reagent_containers/iv_bag) in loc
	if(IV)
		IV.forceMove(src)
		bag = IV
		START_PROCESSING(SSmachines, src)
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/iv_drip/process()
	if(istype(bag) && bag.injection_target)
		update_icon(UPDATE_OVERLAYS)
		return
	return PROCESS_KILL

/obj/machinery/iv_drip/update_overlays()
	. = ..()
	if(bag)
		. += "hangingbag"
		if(bag.reagents.total_volume)
			var/image/filling = image('icons/goonstation/objects/iv.dmi', src, "hangingbag-fluid")
			filling.icon += mix_color_from_reagents(bag.reagents.reagent_list)
			. += filling

/obj/machinery/iv_drip/MouseDrop(mob/living/target)
	var/mob/user = usr
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!ishuman(user))
		return

	if(Adjacent(target) && user.Adjacent(target))
		if(!bag)
			to_chat(user, "<span class='warning'>There's no IV bag connected to [src]!</span>")
			return
		bag.afterattack(target, usr, TRUE)
		START_PROCESSING(SSmachines, src)

/obj/machinery/iv_drip/attack_hand(mob/user)
	if(bag)
		user.put_in_hands(bag)
		bag.update_icon(UPDATE_OVERLAYS)
		bag = null
		update_icon(UPDATE_OVERLAYS)

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
		update_icon(UPDATE_OVERLAYS)
		START_PROCESSING(SSmachines, src)
	else if(bag && istype(I, /obj/item/reagent_containers))
		bag.attackby(I)
		I.afterattack(bag, usr, TRUE)
		update_icon(UPDATE_OVERLAYS)
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
