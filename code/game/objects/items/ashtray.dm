/obj/item/storage/ashtray
	icon = 'icons/ashtray.dmi'
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(/obj/item/cigbutt, /obj/item/clothing/mask/cigarette)
	allow_quick_empty = TRUE
	allow_quick_gather = FALSE

	// No generic container insertion messages/sounds.
	silent = TRUE
	use_sound = null

	var/icon_half = ""
	var/icon_full = ""

/obj/item/storage/ashtray/Initialize(mapload)
	. = ..()
	pixel_y = rand(-5, 5)
	pixel_x = rand(-6, 6)

/obj/item/storage/ashtray/attack_self(mob/user)
	// We want allow_quick_empty to enable disposal dumping
	// but don't want to accidentally dump ashtray contents
	// on the floor.
	return

/obj/item/storage/ashtray/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/cigbutt) || istype(I, /obj/item/clothing/mask/cigarette) || istype(I, /obj/item/match))
		if(contents.len >= storage_slots)
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

/obj/item/storage/ashtray/examine(mob/user)
	. = ..()
	if(contents.len == storage_slots)
		. += " It's stuffed full."
	else if(contents.len > storage_slots * 0.5)
		. += " It's half-filled."

/obj/item/storage/ashtray/update_icon()
	if(contents.len == storage_slots)
		icon_state = icon_full
	else if(contents.len > storage_slots * 0.5)
		icon_state = icon_half
	else
		icon_state = initial(icon_state)

/obj/item/storage/ashtray/deconstruct()
	empty_tray()
	qdel(src)

/obj/item/storage/ashtray/proc/empty_tray()
	for(var/obj/item/I in contents)
		I.forceMove(loc)
	update_icon()

/obj/item/storage/ashtray/throw_impact(atom/hit_atom)
	if(contents.len)
		visible_message("<span class='warning'>[src] slams into [hit_atom] spilling its contents!</span>")
	empty_tray()
	return ..()

/obj/item/storage/ashtray/plastic
	name = "plastic ashtray"
	desc = "Cheap plastic ashtray."
	icon_state = "ashtray_bl"
	icon_half  = "ashtray_half_bl"
	icon_full  = "ashtray_full_bl"
	storage_slots = 8
	max_integrity = 8
	materials = list(MAT_METAL=30, MAT_GLASS=30)
	throwforce = 3

/obj/item/storage/ashtray/bronze
	name = "bronze ashtray"
	desc = "Massive bronze ashtray."
	icon_state = "ashtray_br"
	icon_half  = "ashtray_half_br"
	icon_full  = "ashtray_full_br"
	storage_slots = 16
	max_integrity = 16
	materials = list(MAT_METAL=80)
	throwforce = 10

/obj/item/storage/ashtray/glass
	name = "glass ashtray"
	desc = "Glass ashtray. Looks fragile."
	icon_state = "ashtray_gl"
	icon_half  = "ashtray_half_gl"
	icon_full  = "ashtray_full_gl"
	storage_slots = 12
	max_integrity = 12
	materials = list(MAT_GLASS=60)
	throwforce = 6
