/obj/item/gun/projectile/automatic/fullauto
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	burst_size = 1
	var/datum/click_handler/fullauto/CH = null
	fire_delay = 2.25
	mag_type = /obj/item/ammo_box/magazine/smgm45/v100

/obj/item/gun/projectile/automatic/fullauto/he
	fire_delay = 1
	mag_type = /obj/item/ammo_box/magazine/smgm45/v100/funny

/obj/item/gun/projectile/automatic/fullauto/hefunny
	fire_delay = 1

/obj/item/gun/projectile/automatic/fullauto/hehe
	fire_delay = 0.5

/obj/item/gun/projectile/automatic/fullauto/pickup(mob/living/L)
	.=..()
	to_chat(L, "<span class='notice'>TRUE.</span>")
	modeupdate(L,TRUE)

/obj/item/gun/projectile/automatic/fullauto/dropped(mob/living/L)
	.=..()
	to_chat(L, "<span class='notice'>FALSE.</span>")
	modeupdate(L,FALSE)

/obj/item/gun/projectile/automatic/fullauto/swappedto(mob/living/L)
	to_chat(L, "<span class='notice'>TRUE.</span>")
	modeupdate(L,TRUE)
	return

/obj/item/gun/projectile/automatic/fullauto/swapped(mob/living/L)
	to_chat(L, "<span class='notice'>FALSE.</span>")
	modeupdate(L,FALSE)
	return

/obj/item/gun/projectile/automatic/fullauto/on_exit_storage(obj,mob/living/L)
	if(L)
		if(L.get_active_hand() == src)
			to_chat(L, "<span class='notice'>TRUE.</span>")
			modeupdate(L,TRUE)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/gun/projectile/automatic/fullauto/on_enter_storage(obj,mob/living/L)
	if(L)
		to_chat(L, "<span class='notice'>FALSE.</span>")
		modeupdate(L,FALSE)
	return

// called when the giver gives it to the receiver
/obj/item/gun/projectile/automatic/fullauto/on_give(mob/living/carbon/giver, mob/living/carbon/receiver)
	modeupdate(giver,FALSE)
	return

/obj/item/gun/projectile/automatic/fullauto/proc/modeupdate(mob/living/L,enable)
	if (!enable)
		if (!CH)
			//If we're turning it off, but the click handler doesn't exist, then we have nothing to do
			return
		if (CH.owner) //Remove our handler from the client
			CH.owner.CH = null //wew
		QDEL_NULL(CH) //And delete it
		to_chat(L, "<span class='notice'>CH BORRADO.</span>")
		return

	else
		CH = new /datum/click_handler/fullauto()
		CH.reciever = src //Reciever is the gun that gets the fire events
		L.client.CH = CH //Put it on the client
		CH.owner = L.client //And tell it where it is
		to_chat(L, "<span class='notice'>CH ARMADO.</span>")

/obj/item/ammo_box/magazine/smgm45/v100
	max_ammo = 100

/obj/item/ammo_box/magazine/smgm45/v100/funny
	max_ammo = 100