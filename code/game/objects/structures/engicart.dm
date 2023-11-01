/obj/structure/engineeringcart
	name = "engineering cart"
	desc = "A cart for storing engineering items."
	icon = 'icons/obj/engicart.dmi'
	icon_state = "cart"
	face_while_pulling = FALSE
	anchored = FALSE
	density = TRUE
	var/obj/item/stack/sheet/glass/myglass = null
	var/obj/item/stack/sheet/metal/mymetal = null
	var/obj/item/stack/sheet/plasteel/myplasteel = null
	var/obj/item/flashlight/myflashlight = null
	var/obj/item/storage/toolbox/mechanical/mybluetoolbox = null
	var/obj/item/storage/toolbox/electrical/myyellowtoolbox = null
	var/obj/item/storage/toolbox/emergency/myredtoolbox = null

/obj/structure/engineeringcart/Destroy()
	QDEL_NULL(myglass)
	QDEL_NULL(mymetal)
	QDEL_NULL(myplasteel)
	QDEL_NULL(myflashlight)
	QDEL_NULL(mybluetoolbox)
	QDEL_NULL(myyellowtoolbox)
	QDEL_NULL(myredtoolbox)
	return ..()

/obj/structure/engineeringcart/proc/put_in_cart(obj/item/I, mob/user)
	user.drop_item()
	I.loc = src
	to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
	return

/obj/structure/engineeringcart/attackby(obj/item/I, mob/user, params)
	var/fail_msg = "<span class='notice'>There is already one of those in [src].</span>"
	if(!I.is_robot_module())
		if(istype(I, /obj/item/stack/sheet/glass))
			if(!myglass)
				put_in_cart(I, user)
				myglass=I
				update_icon(UPDATE_OVERLAYS)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/stack/sheet/metal))
			if(!mymetal)
				put_in_cart(I, user)
				mymetal=I
				update_icon(UPDATE_OVERLAYS)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/stack/sheet/plasteel))
			if(!myplasteel)
				put_in_cart(I, user)
				myplasteel=I
				update_icon(UPDATE_OVERLAYS)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/flashlight))
			if(!myflashlight)
				put_in_cart(I, user)
				myflashlight=I
				update_icon(UPDATE_OVERLAYS)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/storage/toolbox/mechanical))
			if(!mybluetoolbox)
				put_in_cart(I, user)
				mybluetoolbox=I
				update_icon(UPDATE_OVERLAYS)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/storage/toolbox/electrical))
			if(!myyellowtoolbox)
				put_in_cart(I, user)
				myyellowtoolbox=I
				update_icon(UPDATE_OVERLAYS)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/storage/toolbox))
			if(!myredtoolbox)
				put_in_cart(I, user)
				myredtoolbox=I
				update_icon(UPDATE_OVERLAYS)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/wrench))
			if(!anchored && !isinspace())
				playsound(src.loc, I.usesound, 50, 1)
				user.visible_message( \
					"[user] tightens \the [src]'s casters.", \
					"<span class='notice'> You have tightened \the [src]'s casters.</span>", \
					"You hear ratchet.")
				anchored = TRUE
			else if(anchored)
				playsound(src.loc, I.usesound, 50, 1)
				user.visible_message( \
					"[user] loosens \the [src]'s casters.", \
					"<span class='notice'> You have loosened \the [src]'s casters.</span>", \
					"You hear ratchet.")
				anchored = FALSE
	else
		to_chat(usr, "<span class='warning'>You cannot interface your modules [src]!</span>")

/obj/structure/engineeringcart/attack_hand(mob/user)
	var/list/engicart_items = list()

	if(myglass)
		engicart_items["Glass"] = image(icon = myglass.icon, icon_state = myglass.icon_state)
	if(mymetal)
		engicart_items["Metal"] = image(icon = mymetal.icon, icon_state = mymetal.icon_state)
	if(myplasteel)
		engicart_items["Plasteel"] = image(icon = myplasteel.icon, icon_state = myplasteel.icon_state)
	if(myflashlight)
		engicart_items["Flashlight"] = image(icon = myflashlight.icon, icon_state = myflashlight.icon_state)
	if(mybluetoolbox)
		engicart_items["Mechanical Toolbox"] = image(icon = mybluetoolbox.icon, icon_state = mybluetoolbox.icon_state)
	if(myredtoolbox)
		engicart_items["Emergency Toolbox"] = image(icon = myredtoolbox.icon, icon_state = myredtoolbox.icon_state)
	if(myyellowtoolbox)
		engicart_items["Electrical Toolbox"] = image(icon = myyellowtoolbox.icon, icon_state = myyellowtoolbox.icon_state)

	if(!length(engicart_items))
		return

	var/pick = show_radial_menu(user, src, engicart_items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)

	if(!pick)
		return

	switch(pick)
		if("Glass")
			if(!myglass)
				return
			user.put_in_hands(myglass)
			to_chat(user, "<span class='notice'>You take [myglass] from [src].</span>")
			myglass = null
		if("Metal")
			if(!mymetal)
				return
			user.put_in_hands(mymetal)
			to_chat(user, "<span class='notice'>You take [mymetal] from [src].</span>")
			mymetal = null
		if("Plasteel")
			if(!myplasteel)
				return
			user.put_in_hands(myplasteel)
			to_chat(user, "<span class='notice'>You take [myplasteel] from [src].</span>")
			myplasteel = null
		if("Flashlight")
			if(!myflashlight)
				return
			user.put_in_hands(myflashlight)
			to_chat(user, "<span class='notice'>You take [myflashlight] from [src].</span>")
			myflashlight = null
		if("Mechanical Toolbox")
			if(!mybluetoolbox)
				return
			user.put_in_hands(mybluetoolbox)
			to_chat(user, "<span class='notice'>You take [mybluetoolbox] from [src].</span>")
			mybluetoolbox = null
		if("Emergency Toolbox")
			if(!myredtoolbox)
				return
			user.put_in_hands(myredtoolbox)
			to_chat(user, "<span class='notice'>You take [myredtoolbox] from [src].</span>")
			myredtoolbox = null
		if("Electrical Toolbox")
			if(!myyellowtoolbox)
				return
			user.put_in_hands(myyellowtoolbox)
			to_chat(user, "<span class='notice'>You take [myyellowtoolbox] from [src].</span>")
			myyellowtoolbox = null

	update_icon(UPDATE_OVERLAYS)

/obj/structure/engineeringcart/proc/check_menu(mob/living/user)
	return istype(user) && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)

/obj/structure/engineeringcart/update_overlays()
	. = ..()
	if(myplasteel)
		. += "cart_plasteel"
	if(mymetal)
		. += "cart_metal"
	if(myglass)
		. += "cart_glass"
	if(myflashlight)
		. += "cart_flashlight"
	if(mybluetoolbox)
		. += "cart_bluetoolbox"
	if(myredtoolbox)
		. += "cart_redtoolbox"
	if(myyellowtoolbox)
		. += "cart_yellowtoolbox"
