/obj/item/implantpad
	name = "implantpad"
	desc = "Used to modify implants."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantpad-0"
	item_state = "electronic"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/implantcase/case = null

/obj/item/implantpad/Destroy()
	if(case)
		dropcase()
	return ..()

/obj/item/implantpad/update_icon()
	if(case)
		src.icon_state = "implantpad-1"
	else
		src.icon_state = "implantpad-0"
	return

/obj/item/implantpad/proc/addcase(mob/user as mob, obj/item/implantcase/C as obj)
	if(!user || !C)
		return
	if(case)
		to_chat(user, "<span class='warning'>There's already an implant in the pad!</span>")
		return
	user.unEquip(C)
	C.forceMove(src)
	case = C
	update_icon()

/obj/item/implantpad/proc/dropcase(mob/user as mob)
	if(!case)
		to_chat(user, "<span class='warning'>There's no implant in the pad!</span>")
		return
	if(user)
		if(user.put_in_hands(case))
			add_fingerprint(user)
			case.add_fingerprint(user)
			case = null
			update_icon()
			return

	case.forceMove(get_turf(src))
	case = null
	update_icon()

/obj/item/implantpad/verb/remove_implant()
	set category = "Object"
	set name = "Remove Implant"
	set src in usr

	if(usr.stat || usr.restrained())
		return

	dropcase(usr)

/obj/item/implantpad/attackby(obj/item/implantcase/C as obj, mob/user as mob, params)
	if(istype(C, /obj/item/implantcase))
		addcase(user, C)
	else
		return ..()

/obj/item/implantpad/attack_self(mob/user as mob)
	add_fingerprint(user)
	user.set_machine(src)
	var/dat = {"<meta charset="UTF-8"><B>Implant Mini-Computer:</B><HR>"}
	if(case)
		if(case.imp)
			if(istype(case.imp, /obj/item/implant))
				dat += "<A href='byond://?src=[UID()];removecase=1'>Remove Case</A><HR>"
				dat += case.imp.get_data()
				if(istype(case.imp, /obj/item/implant/tracking))
					var/obj/item/implant/tracking/T = case.imp
					dat += {"ID (1-100):
					<A href='byond://?src=[UID()];tracking_id=-10'>-</A>
					<A href='byond://?src=[UID()];tracking_id=-1'>-</A> [T.id]
					<A href='byond://?src=[UID()];tracking_id=1'>+</A>
					<A href='byond://?src=[UID()];tracking_id=10'>+</A><BR>"}
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"
	user << browse(dat, "window=implantpad")
	onclose(user, "implantpad")
	return


/obj/item/implantpad/Topic(href, href_list)
	if(..())
		return 1

	var/mob/living/user = usr
	if(href_list["tracking_id"])
		if(case && case.imp)
			var/obj/item/implant/tracking/T = case.imp
			T.id += text2num(href_list["tracking_id"])
			T.id = min(100, T.id)
			T.id = max(1, T.id)
	else if(href_list["removecase"])
		dropcase(user)

	attack_self(user)
	return 1
