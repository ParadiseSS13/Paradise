//TG style Janicart

/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "This is the alpha and omega of sanitation."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = 0
	density = 1
	flags = OPENCONTAINER
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null
	var/obj/item/weapon/mop/mymop = null
	var/obj/item/weapon/reagent_containers/spray/cleaner/myspray = null
	var/obj/item/device/lightreplacer/myreplacer = null
	var/signs = 0
	var/const/max_signs = 4


/obj/structure/janitorialcart/New()
	create_reagents(100)
	janitorial_equipment += src


/obj/structure/janitorialcart/Destroy()
	janitorial_equipment -= src
	return ..()

/obj/structure/janitorialcart/proc/wet_mop(obj/item/weapon/mop, mob/user)
	if(reagents.total_volume < 1)
		to_chat(user, "[src] is out of water!</span>")
	else
		reagents.trans_to(mop, 5)	//
		to_chat(user, "<span class='notice'>You wet [mop] in [src].</span>")
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

/obj/structure/janitorialcart/proc/put_in_cart(obj/item/I, mob/user)
	user.drop_item()
	I.loc = src
	updateUsrDialog()
	to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
	return


/obj/structure/janitorialcart/attackby(obj/item/I, mob/user, params)
	var/fail_msg = "<span class='notice'>There is already one of those in [src].</span>"

	if(!I.is_robot_module())
		if(istype(I, /obj/item/weapon/mop))
			var/obj/item/weapon/mop/m=I
			if(m.reagents.total_volume < m.reagents.maximum_volume)
				wet_mop(m, user)
				return
			if(!mymop)
				m.janicart_insert(user, src)
			else
				to_chat(user, fail_msg)

		else if(istype(I, /obj/item/weapon/storage/bag/trash))
			if(!mybag)
				var/obj/item/weapon/storage/bag/trash/t=I
				t.janicart_insert(user, src)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/weapon/reagent_containers/spray/cleaner))
			if(!myspray)
				put_in_cart(I, user)
				myspray=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/device/lightreplacer))
			if(!myreplacer)
				var/obj/item/device/lightreplacer/l=I
				l.janicart_insert(user,src)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/weapon/caution))
			if(signs < max_signs)
				put_in_cart(I, user)
				signs++
				update_icon()
			else
				to_chat(user, "<span class='notice'>[src] can't hold any more signs.</span>")
		else if(istype(I, /obj/item/weapon/crowbar))
			user.visible_message("<span class='warning'>[user] begins to empty the contents of [src].</span>")
			if(do_after(user, 30, target = src))
				to_chat(usr, "<span class='notice'>You empty the contents of [src]'s bucket onto the floor.</span>")
				reagents.reaction(src.loc)
				src.reagents.clear_reagents()
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
		else if(mybag)
			mybag.attackby(I, user, params)
	else
		to_chat(usr, "<span class='warning'>You cannot interface your modules [src]!</span>")

/obj/structure/janitorialcart/attack_hand(mob/user)
	user.set_machine(src)
	var/dat
	if(mybag)
		dat += "<a href='?src=\ref[src];garbage=1'>[mybag.name]</a><br>"
	if(mymop)
		dat += "<a href='?src=\ref[src];mop=1'>[mymop.name]</a><br>"
	if(myspray)
		dat += "<a href='?src=\ref[src];spray=1'>[myspray.name]</a><br>"
	if(myreplacer)
		dat += "<a href='?src=\ref[src];replacer=1'>[myreplacer.name]</a><br>"
	if(signs)
		dat += "<a href='?src=\ref[src];sign=1'>[signs] sign\s</a><br>"
	var/datum/browser/popup = new(user, "janicart", name, 240, 160)
	popup.set_content(dat)
	popup.open()


/obj/structure/janitorialcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["garbage"])
		if(mybag)
			user.put_in_hands(mybag)
			to_chat(user, "<span class='notice'>You take [mybag] from [src].</span>")
			mybag = null
	if(href_list["mop"])
		if(mymop)
			user.put_in_hands(mymop)
			to_chat(user, "<span class='notice'>You take [mymop] from [src].</span>")
			mymop = null
	if(href_list["spray"])
		if(myspray)
			user.put_in_hands(myspray)
			to_chat(user, "<span class='notice'>You take [myspray] from [src].</span>")
			myspray = null
	if(href_list["replacer"])
		if(myreplacer)
			user.put_in_hands(myreplacer)
			to_chat(user, "<span class='notice'>You take [myreplacer] from [src].</span>")
			myreplacer = null
	if(href_list["sign"])
		if(signs)
			var/obj/item/weapon/caution/Sign = locate() in src
			if(Sign)
				user.put_in_hands(Sign)
				to_chat(user, "<span class='notice'>You take \a [Sign] from [src].</span>")
				signs--
			else
				WARNING("Signs ([signs]) didn't match contents")
				signs = 0

	update_icon()
	updateUsrDialog()


/obj/structure/janitorialcart/update_icon()
	overlays = null
	if(mybag)
		overlays += "cart_garbage"
	if(mymop)
		overlays += "cart_mop"
	if(myspray)
		overlays += "cart_spray"
	if(myreplacer)
		overlays += "cart_replacer"
	if(signs)
		overlays += "cart_sign[signs]"