/obj/item/storage/part_replacer/afterattack(obj/machinery/power/apc/T as obj, mob/living/carbon/human/user as mob, flag, params)
	..()
	if(flag)
		return
	else if(works_from_distance)
		if(istype(T))
			T.exchange_parts(user, src)
			user.Beam(T,icon_state="rped_upgrade",icon='icons/effects/effects.dmi',time=5)
			return

/obj/item/storage/part_replacer/can_be_inserted(obj/item/W, stop_messages = 0, mob/user)
	return ..() && W.get_part_rating()

/obj/item/stock_parts/get_part_rating()
	return rating
