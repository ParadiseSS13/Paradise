/obj/item/ashtray
	icon = 'icons/ashtray.dmi'
	var/max_butts = 0
	var/icon_half = ""
	var/icon_full = ""

/obj/item/ashtray/Initialize(mapload)
	. = ..()
	pixel_y = rand(-5, 5)
	pixel_x = rand(-6, 6)

/obj/item/ashtray/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/cigbutt) || istype(I, /obj/item/clothing/mask/cigarette) || istype(I, /obj/item/match))
		if(contents.len >= max_butts)
			to_chat(user, "This ashtray is full.")
			return
		if(!user.unEquip(I))
			return
		I.forceMove(src)

		if(istype(I, /obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/cig = I
			if(cig.lit == 1)
				visible_message("[user] crushes [cig] in [src], putting it out.")
				var/obj/item/butt = new cig.type_butt(src)
				cig.transfer_fingerprints_to(butt)
				qdel(cig)
			else if(cig.lit == 0)
				to_chat(user, "You place [cig] in [src] without even smoking it. Why would you do that?")

		visible_message("[user] places [I] in [src].")
		add_fingerprint(user)
		update_icon()
	else
		return ..()

/obj/item/ashtray/update_icon()
	if(contents.len == max_butts)
		icon_state = icon_full
		desc = initial(desc) + " It's stuffed full."
	if(contents.len > max_butts * 0.5)
		icon_state = icon_half
		desc = initial(desc) + " It's half-filled."
	else
		icon_state = initial(icon_state)
		desc = initial(desc)

/obj/item/ashtray/deconstruct()
	empty_tray()
	qdel(src)

/obj/item/ashtray/proc/empty_tray()
	for(var/obj/item/I in contents)
		I.forceMove(loc)
	update_icon()

/obj/item/ashtray/throw_impact(atom/hit_atom)
	if(contents.len)
		visible_message("<span class='warning'>[src] slams into [hit_atom] spilling its contents!</span>")
	empty_tray()
	return ..()

/obj/item/ashtray/plastic
	name = "plastic ashtray"
	desc = "Cheap plastic ashtray."
	icon_state = "ashtray_bl"
	icon_half  = "ashtray_half_bl"
	icon_full  = "ashtray_full_bl"
	max_butts = 8
	max_integrity = 8
	materials = list(MAT_METAL=30, MAT_GLASS=30)
	throwforce = 3

/obj/item/ashtray/bronze
	name = "bronze ashtray"
	desc = "Massive bronze ashtray."
	icon_state = "ashtray_br"
	icon_half  = "ashtray_half_br"
	icon_full  = "ashtray_full_br"
	max_butts = 16
	max_integrity = 16
	materials = list(MAT_METAL=80)
	throwforce = 10

/obj/item/ashtray/glass
	name = "glass ashtray"
	desc = "Glass ashtray. Looks fragile."
	icon_state = "ashtray_gl"
	icon_half  = "ashtray_half_gl"
	icon_full  = "ashtray_full_gl"
	max_butts = 12
	max_integrity = 12
	materials = list(MAT_GLASS=60)
	throwforce = 6