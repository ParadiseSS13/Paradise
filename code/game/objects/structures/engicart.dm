/obj/structure/engineeringcart
	name = "engineering cart"
	desc = "A cart for storing engineering items."
	icon = 'icons/obj/engicart.dmi'
	icon_state = "cart"
	face_while_pulling = FALSE
	anchored = FALSE
	density = TRUE
	var/obj/item/stack/sheet/glass/stored_glass = null
	var/obj/item/stack/sheet/metal/stored_metal = null
	var/obj/item/stack/sheet/plasteel/stored_plasteel = null
	var/obj/item/flashlight/stored_flashlight = null
	var/obj/item/storage/toolbox/mechanical/stored_bluetoolbox = null
	var/obj/item/storage/toolbox/electrical/stored_yellowtoolbox = null
	var/obj/item/storage/toolbox/emergency/stored_redtoolbox = null

/obj/structure/engineeringcart/Destroy()
	QDEL_NULL(stored_glass)
	QDEL_NULL(stored_metal)
	QDEL_NULL(stored_plasteel)
	QDEL_NULL(stored_flashlight)
	QDEL_NULL(stored_bluetoolbox)
	QDEL_NULL(stored_yellowtoolbox)
	QDEL_NULL(stored_redtoolbox)
	return ..()

/obj/structure/engineeringcart/proc/put_in_cart(obj/item/I, mob/user)
	user.drop_item()
	I.forceMove(src)
	updateUsrDialog()
	update_icon(UPDATE_OVERLAYS)
	to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
	return

/obj/structure/engineeringcart/attackby(obj/item/I, mob/user, params)
	var/fail_msg = "<span class='notice'>There is already one of those in [src].</span>"

	if(!I.is_robot_module())
		if(istype(I, /obj/item/stack/sheet/glass))
			if(!stored_glass)
				stored_glass = I
				put_in_cart(I, user)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/stack/sheet/metal))
			if(!stored_metal)
				stored_metal = I
				put_in_cart(I, user)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/stack/sheet/plasteel))
			if(!stored_plasteel)
				stored_plasteel = I
				put_in_cart(I, user)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/flashlight))
			if(!stored_flashlight)
				stored_flashlight = I
				put_in_cart(I, user)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/storage/toolbox/mechanical))
			if(!stored_bluetoolbox)
				stored_bluetoolbox = I
				put_in_cart(I, user)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/storage/toolbox/electrical))
			if(!stored_yellowtoolbox)
				stored_yellowtoolbox = I
				put_in_cart(I, user)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/storage/toolbox))
			if(!stored_redtoolbox)
				stored_redtoolbox = I
				put_in_cart(I, user)
			else
				to_chat(user, fail_msg)
		update_icon(UPDATE_OVERLAYS)
	else
		to_chat(usr, "<span class='warning'>You cannot interface your modules [src]!</span>")

/obj/structure/engineeringcart/attack_hand(mob/user)
	user.set_machine(src)
	var/dat
	if(stored_glass)
		dat += "<a href='?src=[UID()];glass=1'>[stored_glass.name]</a><br>"
	if(stored_metal)
		dat += "<a href='?src=[UID()];metal=1'>[stored_metal.name]</a><br>"
	if(stored_plasteel)
		dat += "<a href='?src=[UID()];plasteel=1'>[stored_plasteel.name]</a><br>"
	if(stored_flashlight)
		dat += "<a href='?src=[UID()];flashlight=1'>[stored_flashlight.name]</a><br>"
	if(stored_bluetoolbox)
		dat += "<a href='?src=[UID()];bluetoolbox=1'>[stored_bluetoolbox.name]</a><br>"
	if(stored_redtoolbox)
		dat += "<a href='?src=[UID()];redtoolbox=1'>[stored_redtoolbox.name]</a><br>"
	if(stored_yellowtoolbox)
		dat += "<a href='?src=[UID()];yellowtoolbox=1'>[stored_yellowtoolbox.name]</a><br>"
	var/datum/browser/popup = new(user, "engicart", name, 240, 160)
	popup.set_content(dat)
	popup.open()

/obj/structure/engineeringcart/wrench_act(mob/user, obj/item/I)
	if(isinspace())
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(I.use_tool(src, user, 0, volume = I.tool_volume))
		anchored = !anchored
		user.visible_message( \
		"[user] [anchored ? "tightens" : "loosens"] \the [src]'s casters.", \
		"<span class='notice'> You have [anchored ? "tightened" : "loosened"] \the [src]'s casters.</span>", \
		"You hear ratchet.")

/obj/structure/engineeringcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["glass"])
		if(stored_glass)
			user.put_in_hands(stored_glass)
			to_chat(user, "<span class='notice'>You take [stored_glass] from [src].</span>")
			stored_glass = null
	if(href_list["metal"])
		if(stored_metal)
			user.put_in_hands(stored_metal)
			to_chat(user, "<span class='notice'>You take [stored_metal] from [src].</span>")
			stored_metal = null
	if(href_list["plasteel"])
		if(stored_plasteel)
			user.put_in_hands(stored_plasteel)
			to_chat(user, "<span class='notice'>You take [stored_plasteel] from [src].</span>")
			stored_plasteel = null
	if(href_list["flashlight"])
		if(stored_flashlight)
			user.put_in_hands(stored_flashlight)
			to_chat(user, "<span class='notice'>You take [stored_flashlight] from [src].</span>")
			stored_flashlight = null
	if(href_list["bluetoolbox"])
		if(stored_bluetoolbox)
			user.put_in_hands(stored_bluetoolbox)
			to_chat(user, "<span class='notice'>You take [stored_bluetoolbox] from [src].</span>")
			stored_bluetoolbox = null
	if(href_list["redtoolbox"])
		if(stored_redtoolbox)
			user.put_in_hands(stored_redtoolbox)
			to_chat(user, "<span class='notice'>You take [stored_redtoolbox] from [src].</span>")
			stored_redtoolbox = null
	if(href_list["yellowtoolbox"])
		if(stored_yellowtoolbox)
			user.put_in_hands(stored_yellowtoolbox)
			to_chat(user, "<span class='notice'>You take [stored_yellowtoolbox] from [src].</span>")
			stored_yellowtoolbox = null
	update_icon(UPDATE_OVERLAYS)
	updateUsrDialog()

/obj/structure/engineeringcart/update_overlays()
	. = ..()
	if(stored_glass)
		. += "cart_glass"
	if(stored_metal)
		. += "cart_metal"
	if(stored_plasteel)
		. += "cart_plasteel"
	if(stored_flashlight)
		. += "cart_flashlight"
	if(stored_bluetoolbox)
		. += "cart_bluetoolbox"
	if(stored_redtoolbox)
		. += "cart_redtoolbox"
	if(stored_yellowtoolbox)
		. += "cart_yellowtoolbox"
