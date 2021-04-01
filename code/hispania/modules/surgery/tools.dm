/obj/item/scalpel/advanced
	name = "laser scalpel"
	desc = "An advanced scalpel which uses laser technology to cut. It's set to scalpel."
	icon = 'icons/hispania/obj/surgery.dmi'
	icon_state = "scalpel_a"
	hitsound = 'sound/weapons/blade1.ogg'
	toolspeed = 0.4

/obj/item/scalpel/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, TRUE)
	var/obj/item/circular_saw/advanced/sawtool = new /obj/item/circular_saw/advanced
	to_chat(user, "<span class='notice'>You increase the power of [src], now it can cut bones.</span>")
	qdel(src)
	user.put_in_active_hand(sawtool)

/obj/item/circular_saw/advanced
	name = "laser scalpel"
	desc = "An advanced scalpel which uses laser technology to cut. It's set to saw mode."
	icon = 'icons/hispania/obj/surgery.dmi'
	icon_state = "saw_a"
	hitsound = 'sound/weapons/blade1.ogg'
	toolspeed = 0.7

/obj/item/circular_saw/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, TRUE)
	var/obj/item/scalpel/advanced/scalpeltool = new /obj/item/scalpel/advanced
	to_chat(user, "<span class='notice'>You lower the power of [src], it can no longer cut bones.</span>")
	qdel(src)
	user.put_in_active_hand(scalpeltool)

/obj/item/retractor/advanced
	name = "mechanical pinches"
	desc = "An agglomerate of rods and gears. It resembles a retractor."
	icon = 'icons/hispania/obj/surgery.dmi'
	icon_state = "retractor_a"
	toolspeed = 0.4

/obj/item/retractor/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, TRUE)
	var/obj/item/hemostat/advanced/hermotool = new /obj/item/hemostat/advanced
	to_chat(user, "<span class='notice'>You configure the gears of [src], they are now in hemostat mode.</span>")
	qdel(src)
	user.put_in_active_hand(hermotool)

/obj/item/hemostat/advanced
	name = "mechanical pinches"
	desc = "An agglomerate of rods and gears. It resembles a hemostat."
	icon = 'icons/hispania/obj/surgery.dmi'
	icon_state = "hemostat_a"
	toolspeed = 0.4

/obj/item/hemostat/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, TRUE)
	var/obj/item/retractor/advanced/retractool = new /obj/item/retractor/advanced
	to_chat(user, "<span class='notice'>You configure the gears of [src], they are now in retractor mode.</span>")
	qdel(src)
	user.put_in_active_hand(retractool)

/obj/item/surgicaldrill/advanced
	name = "searing tool"
	desc = "It projects a high power laser used for medical application. It's set to drilling mode"
	icon = 'icons/hispania/obj/surgery.dmi'
	icon_state = "surgicaldrill_a"
	hitsound = 'sound/items/welder.ogg'
	toolspeed = 0.4

/obj/item/surgicaldrill/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/effects/pop.ogg', 50, TRUE)
	var/obj/item/cautery/advanced/cautool = new /obj/item/cautery/advanced
	to_chat(user, "<span class='notice'>You focus the lenses of [src], it is now in mending mode.</span>")
	qdel(src)
	user.put_in_active_hand(cautool)

/obj/item/cautery/advanced
	name = "searing tool"
	desc = "It projects a high power laser used for medical application. It's set to mending mode"
	icon = 'icons/hispania/obj/surgery.dmi'
	icon_state = "cautery_a"
	hitsound = 'sound/items/welder.ogg'
	toolspeed = 0.4

/obj/item/cautery/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/effects/pop.ogg', 50, TRUE)
	var/obj/item/surgicaldrill/advanced/drilltool = new /obj/item/surgicaldrill/advanced
	to_chat(user, "<span class='notice'>You dilate the lenses of [src], it is now in drilling mode.</span>")
	qdel(src)
	user.put_in_active_hand(drilltool)
