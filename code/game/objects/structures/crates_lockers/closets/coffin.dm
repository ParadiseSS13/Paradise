/obj/structure/closet/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"
	burn_state = FLAMMABLE
	burntime = 20

/obj/structure/closet/coffin/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened

/obj/structure/closet/coffin/sarcophagus
	name = "sarcophagus"
	icon_state = "sarc"
	icon_closed = "sarc"
	icon_opened = "sarc_open"
	sound = 'sound/effects/stonedoor_openclose.ogg'