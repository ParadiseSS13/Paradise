/obj/item/thermal_drill
	name = "thermal safe drill"
	desc = "A tungsten carbide thermal drill with magnetic clamps for the purpose of drilling hardened objects. Guaranteed 100% jam proof."
	icon = 'icons/obj/items.dmi'
	icon_state = "hardened_drill"
	w_class = WEIGHT_CLASS_GIGANTIC
	force = 15.0
	var/time_multiplier = 1
	var/payback = FALSE
	var/spotted = FALSE
	var/datum/looping_sound/thermal_drill/soundloop
	var/datum/effect_system/spark_spread/spark_system
	var/datum/song/song

/obj/item/thermal_drill/New()
	..()
	soundloop = new(list(src), FALSE)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(1, 0, src)
	spark_system.attach(src)
	song = new(src, SSinstruments.synthesizer_instrument_ids)

/obj/item/thermal_drill/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(spark_system)
	QDEL_NULL(song)
	return ..()

/obj/item/thermal_drill/attack_self(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/item/thermal_drill/ui_data(mob/user)
	return song.ui_data(user)

/obj/item/thermal_drill/ui_interact(mob/user)
	if(!payback)
		return
	song.ui_interact(user)

/obj/item/thermal_drill/ui_act(action, params)
	if(..())
		return
	return song.ui_act(action, params)

/**
  * Whether the instrument should stop playing
  *
  * Arguments:
  * * user - The user
  */
/obj/item/thermal_drill/proc/should_stop_playing(mob/user)
	if(!payback && spotted)
		return TRUE
	return FALSE

/obj/item/thermal_drill/syndicate
	name = "amplified thermal safe drill"
	desc = "A tungsten carbide thermal drill with magnetic clamps for the purpose of drilling hardened objects. Comes with an inbuilt morale booster and security detector, to assist in drilling."
	payback = TRUE

/obj/item/thermal_drill/diamond_drill
	name = "diamond tipped thermal safe drill"
	desc = "A diamond tipped thermal drill with magnetic clamps for the purpose of quickly drilling hardened objects. Guaranteed 100% jam proof."
	icon_state = "diamond_drill"
	time_multiplier = 0.5

/obj/item/thermal_drill/diamond_drill/syndicate
	name = "amplified diamond tipped thermal safe drill"
	desc = "A diamond tipped thermal drill with magnetic clamps for the purpose of quickly drilling hardened objects. Comes with an inbuilt morale booster and security detector, to assist in drilling."
	payback = TRUE
