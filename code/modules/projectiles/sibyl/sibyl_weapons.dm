/obj/item/gun/energy/proc/install_sibyl()
	var/obj/item/sibyl_system_mod/M = new /obj/item/sibyl_system_mod
	M.install(src)

/obj/item/gun/energy/dominator/sibyl/New()
	. = ..()
	install_sibyl()

/obj/item/gun/energy/gun/advtaser/sibyl/New()
	. = ..()
	install_sibyl()

/obj/item/gun/energy/disabler/sibyl/New()
	. = ..()
	install_sibyl()

/obj/item/gun/energy/gun/sibyl/New()
	. = ..()
	install_sibyl()

/obj/item/gun/energy/gun/mini/sibyl/New()
	. = ..()
	install_sibyl()

/obj/item/gun/energy/gun/pdw9/sibyl/New()
	. = ..()
	install_sibyl()

/obj/item/gun/energy/gun/nuclear/sibyl/New()
	. = ..()
	install_sibyl()

/obj/item/gun/energy/laser/sibyl/New()
	. = ..()
	install_sibyl()

/obj/item/gun/energy/immolator/multi/sibyl/New()
	. = ..()
	install_sibyl()
