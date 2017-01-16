/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	req_access = list(access_all_personal_lockers)
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/New()
	..()
	if(prob(50))
		new /obj/item/weapon/storage/backpack/duffel(src)
	if(prob(50))
		new /obj/item/weapon/storage/backpack(src)
	else
		new /obj/item/weapon/storage/backpack/satchel_norm(src)
	new /obj/item/device/radio/headset( src )


/obj/structure/closet/secure_closet/personal/patient
	name = "patient's closet"

/obj/structure/closet/secure_closet/personal/patient/New()
	..()
	contents.Cut()
	new /obj/item/clothing/under/color/white( src )
	new /obj/item/clothing/shoes/white( src )



/obj/structure/closet/secure_closet/personal/cabinet
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"
	burn_state = FLAMMABLE
	burntime = 20

/obj/structure/closet/secure_closet/personal/cabinet/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/personal/cabinet/New()
	..()
	contents.Cut()
	new /obj/item/weapon/storage/backpack/satchel/withwallet( src )
	new /obj/item/device/radio/headset( src )

/obj/structure/closet/secure_closet/personal/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(src.opened)
		if(istype(W, /obj/item/weapon/grab))
			src.MouseDrop_T(W:affecting, user)      //act like they were dragged onto the closet
		user.drop_item()
		if(W) W.forceMove(loc)
	else if(istype(W, /obj/item/weapon/card/id))
		if(src.broken)
			to_chat(user, "\red It appears to be broken.")
			return
		var/obj/item/weapon/card/id/I = W
		if(!I || !I.registered_name)	return
		if(src == user.loc)
			to_chat(user, "<span class='notice'>You can't reach the lock from inside.</span>")
		else if(src.allowed(user) || !src.registered_name || (istype(I) && (src.registered_name == I.registered_name)))
			//they can open all lockers, or nobody owns this, or they own this locker
			src.locked = !( src.locked )
			if(src.locked)
				src.icon_state = src.icon_locked
			else
				src.icon_state = src.icon_closed
				registered_name = null
				desc = initial(desc)

			if(!src.registered_name && src.locked)
				src.registered_name = I.registered_name
				src.desc = "Owned by [I.registered_name]."
		else
			to_chat(user, "\red Access Denied")
	else if((istype(W, /obj/item/weapon/card/emag) || istype(W, /obj/item/weapon/melee/energy/blade)) && !broken)
		emag_act(user)
	else
		to_chat(user, "\red Access Denied")
