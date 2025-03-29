// It's just works :skull:
/obj/item/paper/stamp(obj/item/stamp/stamp)
	if(stamp.stampoverlay_custom_icon)
		stamps += (!stamps || stamps == "" ? "<HR>" : "") + "<img src=large_[stamp.icon_state].png>"
		var/image/stampoverlay = image(stamp.stampoverlay_custom_icon)
		var/x = rand(-2, 0)
		var/y = rand(-1, 2)
		offset_x += x
		offset_y += y
		stampoverlay.pixel_x = x
		stampoverlay.pixel_y = y
		stampoverlay.icon_state = "paper_[stamp.icon_state]"
		stamp_overlays += stampoverlay

		if(!ico)
			ico = new
		ico += "paper_[stamp.icon_state]"
		if(!stamped)
			stamped = new
		stamped += stamp.type

		update_icon(UPDATE_OVERLAYS)
	else
		. = ..()

// TODO: Paperplane overlays code. Now there's no overlays at all on paperplanes because of /obj/item/paperplane/update_overlays()

/obj/item/stamp
	var/stampoverlay_custom_icon

/obj/item/stamp/warden
	name = "warden's rubber stamp"
	icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'
	icon_state = "stamp-ward"
	item_color = "hosred"
	stampoverlay_custom_icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'

/obj/item/stamp/ploho
	name = "'Very Bad, Redo' rubber stamp"
	icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'
	icon_state = "stamp-ploho"
	item_color = "hop"
	stampoverlay_custom_icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'

/obj/item/stamp/bigdeny
	name = "\improper BIG DENY rubber stamp"
	icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'
	icon_state = "stamp-BIGdeny"
	item_color = "redcoat"
	stampoverlay_custom_icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'

/obj/item/stamp/navcom
	name = "Nanotrasen Naval Command rubber stamp"
	icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'
	icon_state = "stamp-navcom"
	item_color = "captain"
	stampoverlay_custom_icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'

/obj/item/stamp/mime
	name = "mime's rubber stamp"
	icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'
	icon_state = "stamp-mime"
	item_color = "mime"
	stampoverlay_custom_icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'

/obj/item/stamp/ussp
	name = "old USSP rubber stamp"
	icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'
	icon_state = "stamp-ussp"
	item_color = "redcoat"
	stampoverlay_custom_icon = 'modular_ss220/aesthetics/stamps/icons/stamps.dmi'
