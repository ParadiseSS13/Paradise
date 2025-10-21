//TG style Janicart

/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "This is the alpha and omega of sanitation."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	density = TRUE
	face_while_pulling = FALSE
	container_type = OPENCONTAINER
	//copypaste sorry
	var/maximum_volume = 150
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/my_bag = null
	var/obj/item/mop/my_mop = null
	var/obj/item/push_broom/my_broom = null
	var/obj/item/reagent_containers/spray/cleaner/my_spray = null
	var/obj/item/lightreplacer/my_replacer = null
	var/signs = 0
	var/const/max_signs = 4

/obj/structure/janitorialcart/Initialize(mapload)
	. = ..()
	create_reagents(150)
	GLOB.janitorial_equipment += src

/obj/structure/janitorialcart/full

/obj/structure/janitorialcart/full/Initialize(mapload)
	. = ..()
	my_bag = new /obj/item/storage/bag/trash(src)
	my_mop = new /obj/item/mop(src)
	my_broom = new /obj/item/push_broom(src)
	my_spray = new /obj/item/reagent_containers/spray/cleaner(src)
	my_replacer = new /obj/item/lightreplacer(src)
	new /obj/item/caution(src)
	new /obj/item/caution(src)
	new /obj/item/caution(src)
	new /obj/item/caution(src)
	signs = 4
	reagents.add_reagent("water", 150)

/obj/structure/janitorialcart/Destroy()
	GLOB.janitorial_equipment -= src
	QDEL_NULL(my_bag)
	QDEL_NULL(my_mop)
	QDEL_NULL(my_broom)
	QDEL_NULL(my_spray)
	QDEL_NULL(my_replacer)
	return ..()

/obj/structure/janitorialcart/proc/put_in_cart(mob/user, obj/item/I)
	if(!user.unequip(I)) // We can do this here because everything below wants to
		to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
		return

	I.forceMove(src)
	to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
	update_icon(UPDATE_OVERLAYS)
	return

/obj/structure/janitorialcart/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/janitorialcart/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(user.a_intent != INTENT_HELP)
		return ..()

	if(handle_janitorial_equipment(user, used))
		return ITEM_INTERACT_COMPLETE

	if(my_bag)
		if(my_bag.can_be_inserted(used))
			my_bag.handle_item_insertion(used, user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/structure/janitorialcart/proc/handle_janitorial_equipment(mob/living/user, obj/item/used)
	. = TRUE
	var/robot_module = used.is_robot_module()
	var/item_present = FALSE
	if(istype(used, /obj/item/mop))
		var/obj/item/mop/attacking_mop = used
		if(attacking_mop.reagents.total_volume < attacking_mop.reagents.maximum_volume)
			attacking_mop.wet_mop(src, user, robot_module)
			return

		if(robot_module)
			to_chat(user, "<span class='warning'>You cannot store [used] in [src]!</span>")
			return

		if(!my_mop)
			my_mop = attacking_mop
			put_in_cart(user, attacking_mop)
		else
			to_chat(user, "<span class='notice'>There is already one of those in [src].</span>")
		return

	if(robot_module)
		to_chat(user, "<span class='warning'>You cannot store [used] in [src]!</span>")
		return

	if(istype(used, /obj/item/caution))
		if(signs < max_signs)
			signs++
			put_in_cart(user, used)
		else
			to_chat(user, "<span class='notice'>[src] can't hold any more signs.</span>")
		return

	if(istype(used, /obj/item/push_broom))
		if(!my_broom)
			my_broom = used
			put_in_cart(user, used)
			return
		item_present = TRUE

	if(istype(used, /obj/item/storage/bag/trash))
		if(!my_bag)
			my_bag = used
			put_in_cart(user, used)
			return
		item_present = TRUE

	if(istype(used, /obj/item/reagent_containers/spray/cleaner))
		if(!my_spray)
			my_spray = used
			put_in_cart(user, used)
			return
		item_present = TRUE

	if(istype(used, /obj/item/lightreplacer))
		if(!my_replacer)
			my_replacer = used
			put_in_cart(user, used)
			return
		item_present = TRUE

	if(item_present)
		to_chat(user, "<span class='notice'>There is already one of those in [src].</span>")
		return

	return FALSE

/obj/structure/janitorialcart/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	user.visible_message(
		"<span class='warning'>[user] begins to empty the contents of [src].</span>",
		"<span class='notice'>You begin to empty the contents of [src].</span>",
		"<span class='warning'>You hear a prying sound.</span>"
		)
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return

	user.visible_message(
		"<span class='warning'>[user] empties the contents of [src]'s bucket onto the floor!</span>",
		"<span class='notice'>You empty the contents of [src]'s bucket onto the floor.</span>",
		"<span class='warning'>You hear liquid spilling onto the floor.</span>"
		)
	reagents.reaction(loc)
	reagents.clear_reagents()

/obj/structure/janitorialcart/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!anchored && !isinspace())
		if(!I.use_tool(src, user, volume = I.tool_volume))
			return

		user.visible_message( \
			"<span class='notice'>[user] tightens [src]'s casters.</span>",
			"<span class='notice'>You have tightened [src]'s casters.</span>",
			"<span class='notice'>You hear ratcheting.</span>"
			)
		anchored = TRUE
		return

	if(anchored)
		if(!I.use_tool(src, user, volume = I.tool_volume))
			return

		user.visible_message( \
			"<span class='notice'>[user] loosens [src]'s casters.</span>",
			"<span class='notice'>You have loosened [src]'s casters.</span>",
			"<span class='notice'>You hear ratcheting.</span>"
			)
		anchored = FALSE

/obj/structure/janitorialcart/attack_hand(mob/user)
	var/list/cart_items = list()

	if(my_bag)
		cart_items["Trash Bag"] = image(icon = my_bag.icon, icon_state = my_bag.icon_state)
	if(my_mop)
		cart_items["Mop"] = image(icon = my_mop.icon, icon_state = my_mop.icon_state)
	if(my_broom)
		cart_items["Broom"] = image(icon = my_broom.icon, icon_state = my_broom.icon_state)
	if(my_spray)
		cart_items["Spray Bottle"] = image(icon = my_spray.icon, icon_state = my_spray.icon_state)
	if(my_replacer)
		cart_items["Light Replacer"] = image(icon = my_replacer.icon, icon_state = my_replacer.icon_state)
	var/obj/item/caution/sign = locate() in src
	if(sign)
		cart_items["Sign"] = image(icon = sign.icon, icon_state = sign.icon_state)

	if(!length(cart_items))
		return

	var/pick = show_radial_menu(user, src, cart_items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)

	if(!pick)
		return

	switch(pick)
		if("Trash Bag")
			if(!my_bag)
				return
			user.put_in_hands(my_bag)
			to_chat(user, "<span class='notice'>You take [my_bag] from [src].</span>")
			my_bag = null
		if("Mop")
			if(!my_mop)
				return
			user.put_in_hands(my_mop)
			to_chat(user, "<span class='notice'>You take [my_mop] from [src].</span>")
			my_mop = null
		if("Broom")
			if(!my_broom)
				return
			user.put_in_hands(my_broom)
			to_chat(user, "<span class='notice'>You take [my_broom] from [src].</span>")
			my_broom = null
		if("Spray Bottle")
			if(!my_spray)
				return
			user.put_in_hands(my_spray)
			to_chat(user, "<span class='notice'>You take [my_spray] from [src].</span>")
			my_spray = null
		if("Light Replacer")
			if(!my_replacer)
				return
			user.put_in_hands(my_replacer)
			to_chat(user, "<span class='notice'>You take [my_replacer] from [src].</span>")
			my_replacer = null
		if("Sign")
			if(!signs)
				return
			if(sign)
				user.put_in_hands(sign)
				to_chat(user, "<span class='notice'>You take \a [sign] from [src].</span>")
				signs--
			else
				WARNING("Signs ([signs]) didn't match contents")
				signs = 0

	update_icon(UPDATE_OVERLAYS)

/obj/structure/janitorialcart/proc/check_menu(mob/living/user)
	return (istype(user) && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))

/obj/structure/janitorialcart/update_overlays()
	. = ..()
	if(my_bag)
		. += "cart_garbage"
	if(my_mop)
		. += "cart_mop"
	if(my_broom)
		. += "cart_broom"
	if(my_spray)
		. += "cart_spray"
	if(my_replacer)
		. += "cart_replacer"
	if(signs)
		. += "cart_sign[signs]"
	if(reagents.total_volume > 0)
		var/image/reagentsImage = image(icon,src,"cart_reagents0")
		reagentsImage.alpha = 150
		switch((reagents.total_volume / maximum_volume) * 100)
			if(1 to 37)
				reagentsImage.icon_state = "cart_reagents1"
			if(38 to 75)
				reagentsImage.icon_state = "cart_reagents2"
			if(76 to 112)
				reagentsImage.icon_state = "cart_reagents3"
			if(113 to 150)
				reagentsImage.icon_state = "cart_reagents4"
		reagentsImage.icon += mix_color_from_reagents(reagents.reagent_list)
		. += reagentsImage

/obj/structure/janitorialcart/Move(NewLoc, direct)
	. = ..()
	if(!.)
		return
	playsound(loc, pick('sound/items/cartwheel1.ogg', 'sound/items/cartwheel2.ogg'), 100, TRUE, ignore_walls = FALSE)
