/obj/item/golden_record
	name = "Golden Record"
	desc = "A relic of the past, you don't know what lies inside, but you remember someone talking about it arriving in 250356 years"
	icon = 'icons/obj/space/voyager.dmi'
	icon_state = "golden_record_new" //credits to mcramon for brand new sprite
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound =  'sound/items/handling/disk_pickup.ogg'
	throw_speed = 1
	throw_range = 3
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF | ACID_PROOF
	origin_tech = "programming=6;biotech=6"

/obj/item/golden_record/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/turf/simulated/satellite
	name = "satellite components storage"
	desc = "There is plate covering inside storage, its wide and it have engraved 'Voyager' on it."
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"
	smoothing_flags = NONE
	base_icon_state = "plastitanium_wall"
	explosion_block = 4
