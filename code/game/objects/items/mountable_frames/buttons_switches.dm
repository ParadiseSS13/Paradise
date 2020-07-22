/obj/item/mounted/frame/driver_button
	name = "mass driver button frame"
	desc = "Used for repairing or building mass driver buttons"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt_frame"
	mount_reqs = list("simfloor")
	sheets_refunded = 1

/obj/item/mounted/frame/driver_button/do_build(turf/on_wall, mob/user)
	new /obj/machinery/driver_button(get_turf(user), get_dir(user, on_wall))
	qdel(src)

/obj/item/mounted/frame/light_switch
	name = "light switch frame"
	desc = "Used for repairing or building light switches"
	icon = 'icons/obj/power.dmi'
	icon_state = "light-p"
	mount_reqs = list("simfloor", "nospace")
	sheets_refunded = 1

/obj/item/mounted/frame/light_switch/do_build(turf/on_wall, mob/user)
	new /obj/machinery/light_switch(get_turf(user), get_dir(user, on_wall))
	qdel(src)