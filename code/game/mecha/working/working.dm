/obj/mecha/working
	internal_damage_threshold = 60

/obj/mecha/working/New()
	..()
	if(!ruin_mecha)
		trackers += new /obj/item/mecha_parts/mecha_tracking(src)
