/obj/item/ashtray
	icon = 'icons/ashtray.dmi'
	var/max_butts = 0
	var/icon_half = ""
	var/icon_full = ""
	var/material = /obj/item/stack/sheet/metal

/obj/item/ashtray/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/cigbutt) || istype(I, /obj/item/clothing/mask/cigarette) || istype(I, /obj/item/match))
		if(length(contents) >= max_butts)
			to_chat(user, "This ashtray is full.")
			return
		if(!user.unequip(I))
			return
		I.forceMove(src)

		if(istype(I, /obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/cig = I
			if(cig.lit)
				visible_message("[user] crushes [cig] in [src], putting it out.")
				var/obj/item/butt = new cig.butt_type(src)
				cig.transfer_fingerprints_to(butt)
				qdel(cig)
			else
				to_chat(user, "You place [cig] in [src] without even smoking it. Why would you do that?")

		visible_message("[user] places [I] in [src].")
		add_fingerprint(user)
		update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
	else
		return ..()

/obj/item/ashtray/update_icon_state()
	if(length(contents) == max_butts)
		icon_state = icon_full
	else if(length(contents) > max_butts * 0.5)
		icon_state = icon_half
	else
		icon_state = initial(icon_state)

/obj/item/ashtray/update_desc()
	. = ..()
	if(length(contents) == max_butts)
		desc = initial(desc) + " It's stuffed full."
	else if(length(contents) > max_butts * 0.5)
		desc = initial(desc) + " It's half-filled."
	else
		desc = initial(desc)

/obj/item/ashtray/proc/empty_tray()
	for(var/obj/item/I in contents)
		I.forceMove(loc)
	update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)

/obj/item/ashtray/throw_impact(atom/hit_atom)
	if(length(contents))
		visible_message("<span class='warning'>[src] slams into [hit_atom] spilling its contents!</span>")
	empty_tray()
	return ..()

/obj/item/ashtray/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	empty_tray()
	new material(drop_location(), 1)
	deconstruct()

/obj/item/ashtray/plastic
	name = "plastic ashtray"
	desc = "Cheap plastic ashtray."
	icon_state = "ashtray_bl"
	icon_half  = "ashtray_half_bl"
	icon_full  = "ashtray_full_bl"
	max_butts = 8
	max_integrity = 8
	material = /obj/item/stack/sheet/plastic
	throwforce = 3

/obj/item/ashtray/bronze
	name = "bronze ashtray"
	desc = "Massive bronze ashtray."
	icon_state = "ashtray_br"
	icon_half  = "ashtray_half_br"
	icon_full  = "ashtray_full_br"
	max_butts = 16
	max_integrity = 16
	throwforce = 10

/obj/item/ashtray/glass
	name = "glass ashtray"
	desc = "Glass ashtray. Looks fragile."
	icon_state = "ashtray_gl"
	icon_half  = "ashtray_half_gl"
	icon_full  = "ashtray_full_gl"
	max_butts = 12
	max_integrity = 12
	material = /obj/item/stack/sheet/glass
	throwforce = 6
