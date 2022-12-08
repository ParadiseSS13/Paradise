/obj/effect/spawner/detgun
	name = "detective's gun spawner"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "questionmark"

/obj/effect/spawner/detgun/Initialize(mapload)
	. = ..()
	var/obj/item/gun/energy/detective/detgun = new /obj/item/gun/energy/detective(get_turf(src))
	var/obj/item/pinpointer/crew/pointer = new /obj/item/pinpointer/crew(get_turf(src))
	detgun.link_pinpointer(pointer.UID())
	pointer.link_gun(detgun.UID())
	qdel(src)
