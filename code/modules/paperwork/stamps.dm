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
	var/stamp_color = "#FFFFFF"

/obj/item/stamp/attack(mob/living/M, mob/living/user, proximity)
	. = ..()
	var/mob/living/carbon/human/H
	if(!istype(M, /mob/living/carbon/human))
		message_admins("EXITED")
		return
	H = M
	var/xoffset = 0
	var/yoffset = 0
	var/attackedDir = get_cardinal_dir(H, user)
	var/attackedSide
	switch(attackedDir)
		if(NORTH)
			switch(H.dir)
				if(NORTH)
					attackedSide = NORTH
				if(SOUTH)
					attackedSide = SOUTH
				if(EAST)
					attackedSide = WEST
				if(WEST)
					attackedSide = EAST
		if(SOUTH)
			switch(H.dir)
				if(NORTH)
					attackedSide = SOUTH
				if(SOUTH)
					attackedSide = NORTH
				if(EAST)
					attackedSide = EAST
				if(WEST)
					attackedSide = WEST
		if(EAST)
			switch(H.dir)
				if(NORTH)
					attackedSide = EAST
				if(SOUTH)
					attackedSide = WEST
				if(EAST)
					attackedSide = NORTH
				if(WEST)
					attackedSide = SOUTH
		if(WEST)
			switch(H.dir)
				if(NORTH)
					attackedSide = WEST
				if(SOUTH)
					attackedSide = EAST
				if(EAST)
					attackedSide = SOUTH
				if(WEST)
					attackedSide = NORTH
		else
			message_admins("NO SIDE ATTACKED ????")
			switch(H.dir)
				if(NORTH)
					attackedSide = SOUTH
				if(SOUTH)
					attackedSide = NORTH
				if(EAST)
					attackedSide = EAST
				if(WEST)
					attackedSide = WEST

	switch(user.zone_selected)
		if("head")
			yoffset = rand(7, 12)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(-3, 2)
				if(SOUTH)
					xoffset = rand(-3, 2)
				if(EAST)
					xoffset = rand(-2, 2)
				if(WEST)
					xoffset = rand(-2, 2)
		if("chest")
			yoffset = rand(-1, 5)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(-3, 2)
				if(SOUTH)
					xoffset = rand(-3, 2)
				if(EAST)
					xoffset = rand(1, 2)
				if(WEST)
					xoffset = rand(-1, -2)
		if("groin")
			yoffset = rand(-3, -6)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(-3, 2)
				if(SOUTH)
					xoffset = rand(-3, 2)
				if(EAST)
					xoffset = 2
				if(WEST)
					xoffset = -2
		if("r_arm")
			xoffset =0
			yoffset = 0
		if("r_hand")
			xoffset =0
			yoffset = 0
		if("l_arm")
			xoffset =0
			yoffset = 0
		if("l_hand")
			xoffset =0
			yoffset = 0
		if("r_leg")
			xoffset =0
			yoffset = 0
		if("r_foot")
			xoffset =0
			yoffset = 0
		if("l_leg")
			xoffset =0
			yoffset = 0
		if("l_foot")
			xoffset =0
			yoffset = 0

	var/icon/bingus = icon('icons/effects/stamp_marks.dmi', "stamp[rand(1,2)]_[attackedSide]")
	message_admins("[attackedSide]")
	bingus.Shift(EAST, xoffset)
	bingus.Shift(NORTH, yoffset)
	bingus.Blend(getFlatIcon(H), BLEND_MULTIPLY)
	var/image/stamp_image = image(bingus)
	stamp_image.color = stamp_color
	H.ink_marks += stamp_image
	H.update_ink()

/obj/item/stamp/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead.</span>")
	return OXYLOSS

/obj/item/stamp/qm
	name = "Quartermaster's rubber stamp"
	icon_state = "stamp-qm"
	item_color = "qm"
	stamp_color = "#A13E3E"

/obj/item/stamp/law
	name = "Law office's rubber stamp"
	icon_state = "stamp-law"
	item_color = "cargo"
	stamp_color = "#A01F1F"

/obj/item/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	item_color = "captain"
	stamp_color = "#1F66A0"

/obj/item/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	item_color = "hop"
	stamp_color = "#1F66A0"

/obj/item/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	item_color = "hosred"
	stamp_color = "#1F66A0"

/obj/item/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	item_color = "chief"
	stamp_color = "#1F66A0"

/obj/item/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	item_color = "director"
	stamp_color = "#1F66A0"

/obj/item/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	item_color = "medical"
	stamp_color = "#1F66A0"

/obj/item/stamp/granted
	name = "\improper GRANTED rubber stamp"
	icon_state = "stamp-ok"
	item_color = "qm"
	stamp_color = "#00BF00"

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	item_color = "redcoat"
	stamp_color = "#BF0000"

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	item_color = "clown"
	stamp_color = "#FF66CC"

/obj/item/stamp/rep
	name = "Nanotrasen Representative's rubber stamp"
	icon_state = "stamp-rep"
	item_color = "rep"
	stamp_color = "#C1B640"

/obj/item/stamp/magistrate
	name = "Magistrate's rubber stamp"
	icon_state = "stamp-magistrate"
	item_color = "rep"
	stamp_color = "#C1B640"

/obj/item/stamp/centcom
	name = "Central Command rubber stamp"
	icon_state = "stamp-cent"
	item_color = "centcom"
	stamp_color = "#2D7D06"

/obj/item/stamp/syndicate
	name = "suspicious rubber stamp"
	icon_state = "stamp-syndicate"
	item_color = "syndicate"
	stamp_color = "#A01F1F"

