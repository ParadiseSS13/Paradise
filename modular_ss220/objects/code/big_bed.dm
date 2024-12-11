// Double Beds, for luxurious sleeping, i.e. the captain and maybe heads- if people use this for ERP, send them to skyrat
/obj/structure/bed/double
	name = "double bed"
	desc = "A luxurious double bed, for those too important for small dreams."
	icon = 'modular_ss220/objects/icons/bed.dmi'
	icon_state = "bed_double"
	buildstackamount = 4
	max_buckled_mobs = 2
	/// The mob who buckled to this bed second, to avoid other mobs getting pixel-shifted before he unbuckles.
	var/mob/living/goldilocks

/obj/structure/bed/double/post_buckle_mob(mob/living/target)
	if(buckled_mobs.len > 1 && !goldilocks) // Push the second buckled mob a bit higher from the normal lying position
		target.pixel_y = target.pixel_y + 12
		goldilocks = target

/obj/structure/bed/double/post_unbuckle_mob(mob/living/target)
	target.pixel_y = target.pixel_y + target.get_standard_pixel_y_offset()
	if(target == goldilocks)
		goldilocks = null
