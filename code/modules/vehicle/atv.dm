/obj/vehicle/atv
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-earth technologies that are still relevant on most planet-bound outposts."
	icon = 'icons/vehicles/4wheeler.dmi'
	icon_state = "fourwheel"
	var/static/image/atvcover = null

/obj/vehicle/atv/buckle_mob()
	. = ..()
	riding_datum = new/datum/riding/atv

/obj/vehicle/atv/New()
	..()
	if(!atvcover)
		atvcover = image("icons/vehicles/4wheeler.dmi", "4wheeler_north")
		atvcover.layer = MOB_LAYER + 0.1

/obj/vehicle/atv/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		overlays += atvcover
	else
		overlays -= atvcover

//TURRETS!
/obj/vehicle/atv/turret
	var/obj/machinery/porta_turret/syndicate/vehicle_turret/turret = null

/obj/machinery/porta_turret/syndicate/vehicle_turret
	name = "mounted turret"
	scan_range = 7
	emp_vulnerable = 1
	density = 0

/obj/vehicle/atv/turret/New()
	. = ..()
	turret = new(loc)
	//turret.base = src

/obj/vehicle/atv/turret/buckle_mob()
	..()
	riding_datum = new/datum/riding/atv/turret