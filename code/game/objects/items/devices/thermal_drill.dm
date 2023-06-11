/obj/item/thermal_drill
	name = "thermal safe drill"
	desc = "A tungsten carbide thermal drill with magnetic clamps for the purpose of drilling hardened objects. Guaranteed 100% jam proof."
	icon = 'icons/obj/items.dmi'
	icon_state = "hardened_drill"
	w_class = WEIGHT_CLASS_GIGANTIC
	force = 15.0
	var/time_multiplier = 1
	var/payday = FALSE
	var/spotted = FALSE
	var/datum/looping_sound/thermal_drill/soundloop
	var/datum/effect_system/spark_spread/spark_system

/obj/item/thermal_drill/New()
	..()
	soundloop = new(list(src), FALSE)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(1, 0, src)
	spark_system.attach(src)

/obj/item/thermal_drill/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(spark_system)
	return ..()

/obj/item/thermal_drill/syndicate
	name = "bullshitified thermal safe drill"
	desc = "A tungsten carbide thermal drill with magnetic clamps for the purpose of drilling hardened objects. Comes with an inbuilt moral booster and security detector, to assist in drilling."
	payday = TRUE

/obj/item/thermal_drill/diamond_drill
	name = "diamond tipped thermal safe drill"
	desc = "A diamond tipped thermal drill with magnetic clamps for the purpose of quickly drilling hardened objects. Guaranteed 100% jam proof."
	icon_state = "diamond_drill"
	time_multiplier = 0.5

/obj/item/thermal_drill/diamond_drill/syndicate
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "payback0"
	pixel_x = -120
	pixel_y = -120
	name = "bullshitified diamond tipped thermal safe drill"
	desc = "A diamond tipped thermal drill with magnetic clamps for the purpose of quickly drilling hardened objects. Comes with an inbuilt moral booster and security detector, to assist in drilling."
	payday = TRUE


/obj/item/thermal_drill/syndicate/attack_hand(mob/user, pickupfireoverride)
	. = ..()
	user.overlay_fullscreen("payback", /obj/screen/fullscreen/payback, 0)
