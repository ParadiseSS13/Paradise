//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/implantpad
	name = "implantpad"
	desc = "Used to modify implants."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantpad-0"
	item_state = "electronic"
	throw_speed = 3
	throw_range = 5
	w_class = 2
	var/obj/item/weapon/implantcase/case = null

/obj/item/weapon/implantpad/Destroy()
	if(case)
		dropcase()
	return ..()

/obj/item/weapon/implantpad/update_icon()
	if(case)
		src.icon_state = "implantpad-1"
	else
		src.icon_state = "implantpad-0"
	return

/obj/item/weapon/implantpad/proc/addcase(mob/user as mob, obj/item/weapon/implantcase/C as obj)
	if(!user || !C)
		return
	if(case)
		to_chat(user, "<span class='warning'>There's already an implant in the pad!</span>")
		return
	user.unEquip(C)
	C.forceMove(src)
	case = C
	update_icon()

/obj/item/weapon/implantpad/proc/dropcase(mob/user as mob)
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

/obj/item/weapon/implantpad/verb/remove_implant()
	set category = "Object"
	set name = "Remove Implant"
	set src in usr

	if(usr.stat || usr.restrained())
		return

	dropcase(usr)

/obj/item/weapon/implantpad/attackby(obj/item/weapon/implantcase/C as obj, mob/user as mob, params)
	if(istype(C, /obj/item/weapon/implantcase))
		addcase(user, C)
	else
		return ..()

/obj/item/weapon/implantpad/attack_self(mob/user as mob)
	add_fingerprint(user)
	user.set_machine(src)
	var/dat = "<B>Implant Mini-Computer:</B><HR>"
	if(case)
		if(case.imp)
			if(istype(case.imp, /obj/item/weapon/implant))
				dat += "<A href='byond://?src=[UID()];removecase=1'>Remove Case</A><HR>"
				dat += case.imp.get_data()
				if(istype(case.imp, /obj/item/weapon/implant/tracking))
					var/obj/item/weapon/implant/tracking/T = case.imp
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


/obj/item/weapon/implantpad/Topic(href, href_list)
	if(..())
		return 1

	var/mob/living/user = usr
	if(href_list["tracking_id"])
		if(case && case.imp)
			var/obj/item/weapon/implant/tracking/T = case.imp
			T.id += text2num(href_list["tracking_id"])
			T.id = min(100, T.id)
			T.id = max(1, T.id)
	else if(href_list["removecase"])
		dropcase(user)

	attack_self(user)
	return 1
