/obj/item/stamp
	name = "rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-ok"
	inhand_icon_state = "stamp"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	materials = list(MAT_METAL=60)
	pressure_resistance = 2
	attack_verb = list("stamped")
	/// What color will this crayon dye clothes, cables, etc? used for for updateIcon purposes on other objs
	var/dye_color = DYE_GREEN

/obj/item/stamp/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead.</span>")
	playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
	return OXYLOSS

/obj/item/stamp/qm
	name = "Quartermaster's rubber stamp"
	icon_state = "stamp-qm"
	dye_color = DYE_QM

/obj/item/stamp/law
	name = "Law office's rubber stamp"
	icon_state = "stamp-law"
	dye_color = DYE_LAW

/obj/item/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	dye_color = DYE_CAPTAIN

/obj/item/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	dye_color = DYE_HOP

/obj/item/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	dye_color = DYE_HOS

/obj/item/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	dye_color = DYE_CE

/obj/item/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	dye_color = DYE_RD

/obj/item/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	dye_color = DYE_CMO

/obj/item/stamp/granted
	name = "\improper GRANTED rubber stamp"

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	dye_color = DYE_RED

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	dye_color = DYE_CLOWN

/obj/item/stamp/rep
	name = "Nanotrasen Representative's rubber stamp"
	icon_state = "stamp-rep"
	dye_color = DYE_NTREP

/obj/item/stamp/magistrate
	name = "Magistrate's rubber stamp"
	icon_state = "stamp-magistrate"
	dye_color = DYE_LAW

/obj/item/stamp/centcom
	name = "Central Command rubber stamp"
	icon_state = "stamp-cent"
	dye_color = DYE_CENTCOM

/obj/item/stamp/syndicate
	name = "suspicious rubber stamp"
	icon_state = "stamp-syndicate"
	dye_color = DYE_SYNDICATE

