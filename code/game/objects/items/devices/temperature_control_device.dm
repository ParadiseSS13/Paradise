/obj/item/tcd
	name = "temperature control device"
	desc = "A handheld device that can cool or heat a container."
	icon = 'icons/obj/device.dmi'
	icon_state = "tcd-hot"
	item_state = "tcd-hot"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=200, MAT_GLASS=200)
	force = 2
	throwforce = 0
	var/actingtemp = 500
	var/hot_temp = 500
	var/cold_temp = 250

/obj/item/tcd/attack_self(mob/user as mob)
	if(actingtemp == hot_temp)
		to_chat(user, "<span class='notice'>You toggle [src] to cooling mode.</span>")
		icon_state = "tcd-cold"
		item_state = "tcd-cold"
		actingtemp = cold_temp
	else if(actingtemp == cold_temp)
		to_chat(user, "<span class='notice'>You toggle [src] to heating mode.</span>")
		icon_state = "tcd-hot"
		item_state = "tcd-hot"
		actingtemp = hot_temp