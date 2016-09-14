/obj/structure/engineeringcart
	name = "engineering cart"
	desc = "A cart for storing engineering items."
	icon = 'icons/obj/engicart.dmi'
	icon_state = "cart"
	anchored = 0
	density = 1
	var/obj/item/stack/sheet/glass/myglass = null
	var/obj/item/stack/sheet/metal/mymetal = null
	var/obj/item/stack/sheet/plasteel/myplasteel = null
	var/obj/item/device/flashlight/myflashlight = null
	var/obj/item/weapon/storage/toolbox/mechanical/mybluetoolbox = null
	var/obj/item/weapon/storage/toolbox/electrical/myyellowtoolbox = null
	var/obj/item/weapon/storage/toolbox/emergency/myredtoolbox = null
	var/obj/item/taperoll/engineering/myengitape = null

/obj/structure/engineeringcart/proc/put_in_cart(obj/item/I, mob/user)
	user.drop_item()
	I.loc = src
	updateUsrDialog()
	to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
	return
/obj/structure/engineeringcart/attackby(obj/item/I, mob/user, params)
	var/fail_msg = "<span class='notice'>There is already one of those in [src].</span>"
	if(!I.is_robot_module())
		if(istype(I, /obj/item/stack/sheet/glass))
			if(!myglass)
				put_in_cart(I, user)
				myglass=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/stack/sheet/metal))
			if(!mymetal)
				put_in_cart(I, user)
				mymetal=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/stack/sheet/plasteel))
			if(!myplasteel)
				put_in_cart(I, user)
				myplasteel=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/device/flashlight))
			if(!myflashlight)
				put_in_cart(I, user)
				myflashlight=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/weapon/storage/toolbox/mechanical))
			if(!mybluetoolbox)
				put_in_cart(I, user)
				mybluetoolbox=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/weapon/storage/toolbox/electrical))
			if(!myyellowtoolbox)
				put_in_cart(I, user)
				myyellowtoolbox=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/weapon/storage/toolbox))
			if(!myredtoolbox)
				put_in_cart(I, user)
				myredtoolbox=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/taperoll/engineering/))
			if(!myengitape)
				put_in_cart(I, user)
				myengitape=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/weapon/wrench))
			if(!anchored && !isinspace())
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message( \
					"[user] tightens \the [src]'s casters.", \
					"<span class='notice'> You have tightened \the [src]'s casters.</span>", \
					"You hear ratchet.")
				anchored = 1
			else if(anchored)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message( \
					"[user] loosens \the [src]'s casters.", \
					"<span class='notice'> You have loosened \the [src]'s casters.</span>", \
					"You hear ratchet.")
				anchored = 0
	else
		to_chat(usr, "<span class='warning'>You cannot interface your modules [src]!</span>")

/obj/structure/engineeringcart/attack_hand(mob/user)
	user.set_machine(src)
	var/dat
	if(myglass)
		dat += "<a href='?src=[UID()];glass=1'>[myglass.name]</a><br>"
	if(mymetal)
		dat += "<a href='?src=[UID()];metal=1'>[mymetal.name]</a><br>"
	if(myplasteel)
		dat += "<a href='?src=[UID()];plasteel=1'>[myplasteel.name]</a><br>"
	if(myflashlight)
		dat += "<a href='?src=[UID()];flashlight=1'>[myflashlight.name]</a><br>"
	if(mybluetoolbox)
		dat += "<a href='?src=[UID()];bluetoolbox=1'>[mybluetoolbox.name]</a><br>"
	if(myredtoolbox)
		dat += "<a href='?src=[UID()];redtoolbox=1'>[myredtoolbox.name]</a><br>"
	if(myyellowtoolbox)
		dat += "<a href='?src=[UID()];yellowtoolbox=1'>[myyellowtoolbox.name]</a><br>"
	if(myengitape)
		dat += "<a href='?src=[UID()];engitape=1'>[myengitape.name]</a><br>"
	var/datum/browser/popup = new(user, "engicart", name, 240, 160)
	popup.set_content(dat)
	popup.open()
/obj/structure/engineeringcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["glass"])
		if(myglass)
			user.put_in_hands(myglass)
			to_chat(user, "<span class='notice'>You take [myglass] from [src].</span>")
			myglass = null
	if(href_list["metal"])
		if(mymetal)
			user.put_in_hands(mymetal)
			to_chat(user, "<span class='notice'>You take [mymetal] from [src].</span>")
			mymetal = null
	if(href_list["plasteel"])
		if(myplasteel)
			user.put_in_hands(myplasteel)
			to_chat(user, "<span class='notice'>You take [myplasteel] from [src].</span>")
			myplasteel = null
	if(href_list["flashlight"])
		if(myflashlight)
			user.put_in_hands(myflashlight)
			to_chat(user, "<span class='notice'>You take [myflashlight] from [src].</span>")
			myflashlight = null
	if(href_list["bluetoolbox"])
		if(mybluetoolbox)
			user.put_in_hands(mybluetoolbox)
			to_chat(user, "<span class='notice'>You take [mybluetoolbox] from [src].</span>")
			mybluetoolbox = null
	if(href_list["redtoolbox"])
		if(myredtoolbox)
			user.put_in_hands(myredtoolbox)
			to_chat(user, "<span class='notice'>You take [myredtoolbox] from [src].</span>")
			myredtoolbox = null
	if(href_list["yellowtoolbox"])
		if(myyellowtoolbox)
			user.put_in_hands(myyellowtoolbox)
			to_chat(user, "<span class='notice'>You take [myyellowtoolbox] from [src].</span>")
			myyellowtoolbox = null
	if(href_list["engitape"])
		if(myengitape)
			user.put_in_hands(myengitape)
			to_chat(user, "<span class='notice'>You take [myengitape] from [src].</span>")
			myengitape = null

	update_icon()
	updateUsrDialog()
/obj/structure/engineeringcart/update_icon()
	overlays = null
	if(myglass)
		overlays += "cart_glass"
	if(mymetal)
		overlays += "cart_metal"
	if(myplasteel)
		overlays += "cart_plasteel"
	if(myflashlight)
		overlays += "cart_flashlight"
	if(mybluetoolbox)
		overlays += "cart_bluetoolbox"
	if(myredtoolbox)
		overlays += "cart_redtoolbox"
	if(myyellowtoolbox)
		overlays += "cart_yellowtoolbox"
	if(myengitape)
		overlays += "cart_engitape"
