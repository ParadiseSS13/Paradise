/obj/vehicle/space/speedbike
	name = "Speedbike"
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedbike_blue"
	layer = MOB_LAYER - 0.1
	var/overlay_state = "cover_blue"
	var/image/overlay = null

/obj/vehicle/space/speedbike/buckle_mob()
	. = ..()
	riding_datum = new/datum/riding/space/speedbike


/obj/vehicle/space/speedbike/New()
	. = ..()
	overlay = image("icons/obj/bike.dmi", overlay_state)
	overlay.layer = MOB_LAYER + 0.1
	overlays += overlay
	riding_datum = new/datum/riding/space/speedbike

/obj/effect/overlay/temp/speedbike_trail
	name = "speedbike trails"
	icon = 'icons/effects/effects.dmi'
	icon_state = "ion_fade"
	duration = 10
	randomdir = 0
	layer = MOB_LAYER - 0.2

/obj/effect/overlay/temp/speedbike_trail/New(loc,move_dir)
	..()
	dir = move_dir

/obj/vehicle/space/speedbike/Move(newloc,move_dir)
	if(buckled_mob)
		new /obj/effect/overlay/temp/speedbike_trail(loc)
	. = ..()


/obj/vehicle/space/speedbike/red
	icon_state = "speedbike_red"
	overlay_state = "cover_red"