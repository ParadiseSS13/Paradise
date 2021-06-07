/obj/spacepod/sec/update_icons()
	. = ..()
	var/image/security_badge = image(icon,"security_badge")
	overlays += security_badge
