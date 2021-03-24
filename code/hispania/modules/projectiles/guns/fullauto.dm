/obj/item/gun/projectile/automatic/fullauto
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	burst_size = 1
	var/datum/click_handler/fullauto/CH
	select = 0
	fullauto = TRUE
	fire_delay = 2.25
	actions_types = null

/obj/item/gun/projectile/automatic/fullauto/pickup(mob/living/L)
	.=..()
	modeupdate(L,TRUE)

/obj/item/gun/projectile/automatic/fullauto/dropped(mob/living/L)
	.=..()
	modeupdate(L,FALSE)

/obj/item/gun/projectile/automatic/fullauto/swappedto(mob/living/L)
	modeupdate(L,TRUE)

/obj/item/gun/projectile/automatic/fullauto/swapped(mob/living/L)
	modeupdate(L,FALSE)

/obj/item/gun/projectile/automatic/fullauto/hotkeyequip(mob/living/L)
	modeupdate(L,FALSE)

/obj/item/gun/projectile/automatic/fullauto/after_throw(datum/callback/callback, mob/living/L)
	..()
	modeupdate(L,FALSE)

/obj/item/gun/projectile/automatic/fullauto/on_exit_storage(obj,mob/living/L)
	if(L)
		if(L.get_active_hand() == src)
			modeupdate(L,TRUE)

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/gun/projectile/automatic/fullauto/on_enter_storage(obj,mob/living/L)
	if(L)
		modeupdate(L,FALSE)

// called when the giver gives it to the receiver
/obj/item/gun/projectile/automatic/fullauto/on_give(mob/living/carbon/giver, mob/living/carbon/receiver)
	modeupdate(giver,FALSE)

/obj/item/gun/projectile/automatic/fullauto/proc/modeupdate(mob/living/L,enable)
	if (!enable)
		if (!CH)
			//If we're turning it off, but the click handler doesn't exist, then we have nothing to do
			return
		if (CH.owner) //Remove our handler from the client
			CH.owner.CH = null //wew
		QDEL_NULL(CH) //And delete it
		return
	else if(!select)
		CH = new /datum/click_handler/fullauto()
		CH.reciever = src //Reciever is the gun that gets the fire events
		L.client.CH = CH //Put it on the client
		CH.owner = L.client //And tell it where it is

///////////////////////////////////////////////////////////////////

/obj/item/gun/projectile/automatic/fullauto/twomode
	actions_types = list(/datum/action/item_action/toggle_firemode)
	var/burst_burst_size = 0
	var/burst_fire_delay = 0

/obj/item/gun/projectile/automatic/fullauto/twomode/update_icon()
	..()
	overlays.Cut()
	if(!select)
		overlays += "[initial(icon_state)]auto"
	else
		overlays += "[initial(icon_state)]burst"
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	if(bayonet && can_bayonet)
		overlays += knife_overlay

/obj/item/gun/projectile/automatic/fullauto/twomode/burst_select()
	var/mob/living/carbon/human/user = usr
	select = !select
	if(!select)
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		to_chat(user, "<span class='notice'>You switch to full-automatic.</span>")
		modeupdate(user,TRUE)
	else
		burst_size = burst_burst_size
		fire_delay = burst_fire_delay
		to_chat(user, "<span class='notice'>You switch to [burst_size] round burst.</span>")
		modeupdate(user,FALSE)

	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, 1)
	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
