/obj/structure/engineeringcart
	name = "engineering cart"
	desc = "A cart for storing engineering items."
	icon = 'icons/obj/engicart.dmi'
	icon_state = "cart"
	face_while_pulling = FALSE
	density = TRUE
	var/obj/item/stack/sheet/glass/my_glass = null
	var/obj/item/stack/sheet/metal/my_metal = null
	var/obj/item/stack/sheet/plasteel/my_plasteel = null
	var/obj/item/flashlight/my_flashlight = null
	var/obj/item/storage/toolbox/mechanical/my_blue_toolbox = null
	var/obj/item/storage/toolbox/electrical/my_yellow_toolbox = null
	var/obj/item/storage/toolbox/emergency/my_red_toolbox = null

/obj/structure/engineeringcart/full

/obj/structure/engineeringcart/full/Initialize(mapload)
	. = ..()
	my_glass = new /obj/item/stack/sheet/glass/fifty(src)
	my_metal = new /obj/item/stack/sheet/metal/fifty(src)
	my_plasteel = new /obj/item/stack/sheet/plasteel/fifty(src)
	my_flashlight = new /obj/item/flashlight(src)
	my_blue_toolbox = new /obj/item/storage/toolbox/mechanical/(src)
	my_yellow_toolbox = new /obj/item/storage/toolbox/electrical/(src)
	my_red_toolbox = new /obj/item/storage/toolbox/emergency/(src)
	update_icon(UPDATE_OVERLAYS)

/obj/structure/engineeringcart/Destroy()
	QDEL_NULL(my_glass)
	QDEL_NULL(my_metal)
	QDEL_NULL(my_plasteel)
	QDEL_NULL(my_flashlight)
	QDEL_NULL(my_blue_toolbox)
	QDEL_NULL(my_yellow_toolbox)
	QDEL_NULL(my_red_toolbox)
	return ..()

/obj/structure/engineeringcart/proc/put_in_cart(obj/item/used, mob/user)
	if(!user.drop_item())
		to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
		return FALSE

	used.loc = src
	to_chat(user, "<span class='notice'>You put [used] into [src].</span>")
	return TRUE

/obj/structure/engineeringcart/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	. = ITEM_INTERACT_COMPLETE
	var/fail_msg = "<span class='warning'>There is already one of those in [src]!</span>"
	if(used.is_robot_module())
		to_chat(user, "<span class='warning'>You cannot interface your modules with [src]!</span>")
		return

	if(istype(used, /obj/item/stack/sheet/glass))
		if(my_glass)
			to_chat(user, fail_msg)
			return

		if(!put_in_cart(used, user))
			return

		my_glass = used
		update_icon(UPDATE_OVERLAYS)
		return

	if(istype(used, /obj/item/stack/sheet/metal))
		if(my_metal)
			to_chat(user, fail_msg)
			return

		if(!put_in_cart(used, user))
			return

		my_metal = used
		update_icon(UPDATE_OVERLAYS)
		return

	if(istype(used, /obj/item/stack/sheet/plasteel))
		if(my_plasteel)
			to_chat(user, fail_msg)
			return

		if(!put_in_cart(used, user))
			return

		my_plasteel = used
		update_icon(UPDATE_OVERLAYS)
		return

	if(istype(used, /obj/item/flashlight))
		if(my_flashlight)
			to_chat(user, fail_msg)
			return

		if(!put_in_cart(used, user))
			return

		my_flashlight = used
		update_icon(UPDATE_OVERLAYS)
		return

	if(istype(used, /obj/item/storage/toolbox/mechanical))
		if(my_blue_toolbox)
			to_chat(user, fail_msg)
			return

		if(!put_in_cart(used, user))
			return

		my_blue_toolbox = used
		update_icon(UPDATE_OVERLAYS)
		return

	if(istype(used, /obj/item/storage/toolbox/electrical))
		if(my_yellow_toolbox)
			to_chat(user, fail_msg)
			return

		if(!put_in_cart(used, user))
			return

		my_yellow_toolbox = used
		update_icon(UPDATE_OVERLAYS)
		return

	if(istype(used, /obj/item/storage/toolbox))
		if(my_red_toolbox)
			to_chat(user, fail_msg)
			return

		if(!put_in_cart(used, user))
			return

		my_red_toolbox = used
		update_icon(UPDATE_OVERLAYS)
		return

	return ..()

/obj/structure/engineeringcart/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(anchored)
		tool.play_tool_sound(src, tool.tool_volume)
		anchored = FALSE
		user.visible_message(
			"<span class='notice'>[user] loosens [src]'s casters.</span>",
			"<span class='notice'>You have loosened [src]'s casters.</span>",
			"<span class='notice'>You hear ratcheting.</span>"
		)
		return

	if(!anchored && !isinspace())
		tool.play_tool_sound(src, tool.tool_volume)
		anchored = TRUE
		user.visible_message(
			"<span class='notice'>[user] tightens [src]'s casters.</span>",
			"<span class='notice'>You have tightened [src]'s casters.</span>",
			"<span class='notice'>You hear ratcheting.</span>"
		)

/obj/structure/engineeringcart/attack_hand(mob/user)
	var/list/engicart_items = list()

	if(my_glass)
		engicart_items["Glass"] = image(icon = my_glass.icon, icon_state = my_glass.icon_state)
	if(my_metal)
		engicart_items["Metal"] = image(icon = my_metal.icon, icon_state = my_metal.icon_state)
	if(my_plasteel)
		engicart_items["Plasteel"] = image(icon = my_plasteel.icon, icon_state = my_plasteel.icon_state)
	if(my_flashlight)
		engicart_items["Flashlight"] = image(icon = my_flashlight.icon, icon_state = my_flashlight.icon_state)
	if(my_blue_toolbox)
		engicart_items["Mechanical Toolbox"] = image(icon = my_blue_toolbox.icon, icon_state = my_blue_toolbox.icon_state)
	if(my_red_toolbox)
		engicart_items["Emergency Toolbox"] = image(icon = my_red_toolbox.icon, icon_state = my_red_toolbox.icon_state)
	if(my_yellow_toolbox)
		engicart_items["Electrical Toolbox"] = image(icon = my_yellow_toolbox.icon, icon_state = my_yellow_toolbox.icon_state)

	if(!length(engicart_items))
		return

	var/pick = show_radial_menu(user, src, engicart_items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)
	if(!pick)
		return

	switch(pick)
		if("Glass")
			if(!my_glass)
				return

			user.put_in_hands(my_glass)
			to_chat(user, "<span class='notice'>You take [my_glass] from [src].</span>")
			my_glass = null

		if("Metal")
			if(!my_metal)
				return

			user.put_in_hands(my_metal)
			to_chat(user, "<span class='notice'>You take [my_metal] from [src].</span>")
			my_metal = null

		if("Plasteel")
			if(!my_plasteel)
				return

			user.put_in_hands(my_plasteel)
			to_chat(user, "<span class='notice'>You take [my_plasteel] from [src].</span>")
			my_plasteel = null

		if("Flashlight")
			if(!my_flashlight)
				return

			user.put_in_hands(my_flashlight)
			to_chat(user, "<span class='notice'>You take [my_flashlight] from [src].</span>")
			my_flashlight = null

		if("Mechanical Toolbox")
			if(!my_blue_toolbox)
				return

			user.put_in_hands(my_blue_toolbox)
			to_chat(user, "<span class='notice'>You take [my_blue_toolbox] from [src].</span>")
			my_blue_toolbox = null

		if("Emergency Toolbox")
			if(!my_red_toolbox)
				return

			user.put_in_hands(my_red_toolbox)
			to_chat(user, "<span class='notice'>You take [my_red_toolbox] from [src].</span>")
			my_red_toolbox = null

		if("Electrical Toolbox")
			if(!my_yellow_toolbox)
				return

			user.put_in_hands(my_yellow_toolbox)
			to_chat(user, "<span class='notice'>You take [my_yellow_toolbox] from [src].</span>")
			my_yellow_toolbox = null

	update_icon(UPDATE_OVERLAYS)

/obj/structure/engineeringcart/proc/check_menu(mob/living/user)
	return istype(user) && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)

/obj/structure/engineeringcart/update_overlays()
	. = ..()
	if(my_plasteel)
		. += "cart_plasteel"
	if(my_metal)
		. += "cart_metal"
	if(my_glass)
		. += "cart_glass"
	if(my_flashlight)
		. += "cart_flashlight"
	if(my_blue_toolbox)
		. += "cart_bluetoolbox"
	if(my_red_toolbox)
		. += "cart_redtoolbox"
	if(my_yellow_toolbox)
		. += "cart_yellowtoolbox"
