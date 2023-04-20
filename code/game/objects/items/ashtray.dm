/obj/item/storage/ashtray
	name = "plastic ashtray"
	desc = "Cheap plastic ashtray."
	icon = 'icons/obj/ashtray.dmi'
	icon_state = "ashtray_bl"
	var/icon_half  = "ashtray_half_bl"
	var/icon_full  = "ashtray_full_bl"
	var/icon_broken = "ashtray_bork_bl"
	storage_slots = 6
	max_integrity = 12
	materials = list(MAT_METAL=30, MAT_GLASS=30)
	throwforce = 3
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	use_to_pickup = TRUE
	use_sound = ""
	can_hold = list(
		/obj/item/cigbutt,
		/obj/item/clothing/mask/cigarette,
		/obj/item/match,
		/obj/item/rollingpaper)
	cant_hold = list(
		/obj/item/clothing/mask/cigarette/pipe)

/obj/item/storage/ashtray/bronze
	name = "bronze ashtray"
	desc = "Massive bronze ashtray."
	icon_state = "ashtray_br"
	icon_half  = "ashtray_half_br"
	icon_full  = "ashtray_full_br"
	icon_broken = "ashtray_bork_br"
	max_integrity = 16
	materials = list(MAT_METAL=80)
	throwforce = 10

/obj/item/storage/ashtray/glass
	name = "glass ashtray"
	desc = "Glass ashtray. Looks fragile."
	icon_state = "ashtray_gl"
	icon_half  = "ashtray_half_gl"
	icon_full  = "ashtray_full_gl"
	icon_broken = "ashtray_bork_gl"
	max_integrity = 8
	materials = list(MAT_GLASS=60)
	throwforce = 6

/obj/item/storage/ashtray/Initialize(mapload)
	. = ..()
	pixel_y = rand(-5, 5)
	pixel_x = rand(-6, 6)

/obj/item/storage/ashtray/attackby(obj/item/I, mob/user, params)
	if(!can_be_inserted(I))
		return
	handle_item_insertion(I)
	if(istype(I, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/cig = I
		if(cig.lit == TRUE)
			visible_message("[user] crushes [cig] in [src], putting it out.")
			var/obj/item/butt = new cig.type_butt(src)
			cig.transfer_fingerprints_to(butt)
			qdel(cig)
		if(cig.lit == FALSE)
			visible_message("[user] places [cig] in [src] without even smoking it. Why did [user.p_they()] do that?")
		return
	visible_message("[user] places [I] in [src].")

/obj/item/storage/ashtray/update_icon()
	if(contents.len == storage_slots)
		icon_state = icon_full
		desc = initial(desc) + " It's stuffed full."
		return
	if(contents.len >= storage_slots * 0.5)
		icon_state = icon_half
		desc = initial(desc) + " It's half-filled."
		return
	if(contents.len < storage_slots * 0.5)
		icon_state = initial(icon_state)
		desc = initial(desc)

/obj/item/storage/ashtray/deconstruct()
	var/obj/item/trash/broken_ashtray/shards = new(get_turf(src))
	shards.icon_state = src.icon_broken
	visible_message("<span class='warning'>Oops, [src] broke into a lot of pieces!</span>")
	return ..()

/obj/item/storage/ashtray/throw_impact(atom/hit_atom)
	if(contents.len)
		for(var/obj/item/I in contents)
			I.forceMove(loc)
		update_icon()
		visible_message("<span class='warning'>[src] slams into [hit_atom] spilling its contents!</span>")
	if(rand(1,20) > max_integrity)
		deconstruct()
	return ..()
