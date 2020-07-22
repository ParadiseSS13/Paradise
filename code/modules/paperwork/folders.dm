/obj/item/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = WEIGHT_CLASS_SMALL
	pressure_resistance = 2
	resistance_flags = FLAMMABLE

/obj/item/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"

/obj/item/folder/red
	desc = "A red folder."
	icon_state = "folder_red"

/obj/item/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"

/obj/item/folder/white
	desc = "A white folder."
	icon_state = "folder_white"

/obj/item/folder/update_icon()
	overlays.Cut()
	if(contents.len)
		overlays += "folder_paper"
	..()

/obj/item/folder/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/paper) || istype(W, /obj/item/photo) || istype(W, /obj/item/paper_bundle) || istype(W, /obj/item/documents))
		user.drop_item()
		W.loc = src
		to_chat(user, "<span class='notice'>You put the [W] into \the [src].</span>")
		update_icon()
	else if(istype(W, /obj/item/pen))
		var/n_name = clean_input("What would you like to label the folder?", "Folder Labelling", null)
		if(!n_name)
			return
		n_name = sanitize(copytext(n_name, 1, MAX_NAME_LEN))

		if((loc == usr || Adjacent(usr)) && usr.stat == 0)
			name = "folder[(n_name ? text("- '[n_name]'") : null)]"
	else
		return ..()

/obj/item/folder/attack_self(mob/user as mob)
	var/dat = "<title>[name]</title>"

	for(var/obj/item/paper/P in src)
		dat += "<A href='?src=[UID()];remove=\ref[P]'>Remove</A> - <A href='?src=[UID()];read=\ref[P]'>[P.name]</A><BR>"
	for(var/obj/item/photo/Ph in src)
		dat += "<A href='?src=[UID()];remove=\ref[Ph]'>Remove</A> - <A href='?src=[UID()];look=\ref[Ph]'>[Ph.name]</A><BR>"
	for(var/obj/item/paper_bundle/Pa in src)
		dat += "<A href='?src=[UID()];remove=\ref[Pa]'>Remove</A> - <A href='?src=[UID()];look=\ref[Pa]'>[Pa.name]</A><BR>"
	for(var/obj/item/documents/doc in src)
		dat += "<A href='?src=[UID()];remove=\ref[doc]'>Remove</A> - <A href='?src=[UID()];look=\ref[doc]'>[doc.name]</A><BR>"
	user << browse(dat, "window=folder")
	onclose(user, "folder")
	add_fingerprint(usr)
	return

/obj/item/folder/Topic(href, href_list)
	..()
	if((usr.stat || usr.restrained()))
		return

	if(src.loc == usr)

		if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if(P && (P.loc == src) && istype(P))
				P.loc = usr.loc
				usr.put_in_hands(P)

		else if(href_list["read"])
			var/obj/item/paper/P = locate(href_list["read"])
			if(P && (P.loc == src) && istype(P))
				P.show_content(usr)
		else if(href_list["look"])
			var/obj/item/photo/P = locate(href_list["look"])
			if(P && (P.loc == src) && istype(P))
				P.show(usr)
		else if(href_list["browse"])
			var/obj/item/paper_bundle/P = locate(href_list["browse"])
			if(P && (P.loc == src) && istype(P))
				P.attack_self(usr)
				onclose(usr, "[P.name]")

		//Update everything
		attack_self(usr)
		update_icon()
	return

/obj/item/folder/documents
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of Nanotrasen Corporation. Unauthorized distribution is punishable by death.\""

/obj/item/folder/documents/New()
	..()
	new /obj/item/documents/nanotrasen(src)
	update_icon()

/obj/item/folder/syndicate
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of The Syndicate.\""

/obj/item/folder/syndicate/red
	icon_state = "folder_sred"

/obj/item/folder/syndicate/red/New()
	..()
	new /obj/item/documents/syndicate/red(src)
	update_icon()

/obj/item/folder/syndicate/blue
	icon_state = "folder_sblue"

/obj/item/folder/syndicate/blue/New()
	..()
	new /obj/item/documents/syndicate/blue(src)
	update_icon()

/obj/item/folder/syndicate/yellow
	icon_state = "folder_syellow"

/obj/item/folder/syndicate/yellow/full/New()
	..()
	new /obj/item/documents/syndicate/yellow(src)
	update_icon()

/obj/item/folder/syndicate/mining/New()
	. = ..()
	new /obj/item/documents/syndicate/mining(src)
	update_icon()


