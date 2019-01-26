/obj/item/stamp
	name = "\improper rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-ok"
	item_state = "stamp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=60)
	item_color = "cargo"
	pressure_resistance = 2
	attack_verb = list("stamped")

/obj/item/stamp/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead.</span>")
	return (OXYLOSS)

/obj/item/stamp/qm
	name = "Quartermaster's rubber stamp"
	icon_state = "stamp-qm"
	item_color = "qm"

/obj/item/stamp/law
	name = "Law office's rubber stamp"
	icon_state = "stamp-law"
	item_color = "cargo"

/obj/item/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	item_color = "captain"

/obj/item/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	item_color = "hop"

/obj/item/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	item_color = "hosred"

/obj/item/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	item_color = "chief"

/obj/item/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	item_color = "director"

/obj/item/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	item_color = "medical"

/obj/item/stamp/granted
	name = "\improper GRANTED rubber stamp"
	icon_state = "stamp-ok"
	item_color = "qm"

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	item_color = "redcoat"

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	item_color = "clown"

/obj/item/stamp/rep
	name = "Nanotrasen Representative's rubber stamp"
	icon_state = "stamp-rep"
	item_color = "rep"

/obj/item/stamp/magistrate
	name = "Magistrate's rubber stamp"
	icon_state = "stamp-magistrate"
	item_color = "rep"

/obj/item/stamp/centcom
	name = "Central Command rubber stamp"
	icon_state = "stamp-cent"
	item_color = "centcom"

/obj/item/stamp/syndicate
	name = "suspicious rubber stamp"
	icon_state = "stamp-syndicate"
	item_color = "syndicate"

// Syndicate stamp to forge documents.

/obj/item/stamp/chameleon/attack_self(mob/user as mob)

	var/list/stamp_types = typesof(/obj/item/stamp) - src.type // Get all stamp types except our own
	var/list/stamps = list()

	// Generate them into a list
	for(var/stamp_type in stamp_types)
		var/obj/item/stamp/S = new stamp_type
		stamps[capitalize(S.name)] = S

	var/list/show_stamps = list("EXIT" = null) + sortList(stamps) // the list that will be shown to the user to pick from

	var/input_stamp = input(user, "Choose a stamp to disguise as.", "Choose a stamp.") in show_stamps

	if(user && src in user.contents)

		var/obj/item/stamp/chosen_stamp = stamps[capitalize(input_stamp)]

		if(chosen_stamp)
			name = chosen_stamp.name
			icon_state = chosen_stamp.icon_state
			item_color = chosen_stamp.item_color
