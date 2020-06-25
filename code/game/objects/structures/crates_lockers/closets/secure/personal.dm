/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	req_access = list(ACCESS_ALL_PERSONAL_LOCKERS)
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/New()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/duffel(src)
	if(prob(50))
		new /obj/item/storage/backpack(src)
	else
		new /obj/item/storage/backpack/satchel_norm(src)
	new /obj/item/radio/headset( src )


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
	resistance_flags = FLAMMABLE
	max_integrity = 70

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
	new /obj/item/storage/backpack/satchel/withwallet( src )
	new /obj/item/radio/headset( src )

/obj/structure/closet/secure_closet/personal/attackby(obj/item/W, mob/user, params)
	if(opened || !istype(W, /obj/item/card/id))
		return ..()

	if(broken)
		to_chat(user, "<span class='warning'>It appears to be broken.</span>")
		return

	var/obj/item/card/id/I = W
	if(!I || !I.registered_name)
		return

	if(src == user.loc)
		to_chat(user, "<span class='notice'>You can't reach the lock from inside.</span>")

	else if(allowed(user) || !registered_name || (istype(I) && (registered_name == I.registered_name)))
		//they can open all lockers, or nobody owns this, or they own this locker
		locked = !locked
		if(locked)
			icon_state = icon_locked
		else
			icon_state = icon_closed
			registered_name = null
			desc = initial(desc)

		if(!registered_name && locked)
			registered_name = I.registered_name
			desc = "Owned by [I.registered_name]."
	else
		to_chat(user, "<span class='warning'>Access Denied</span>")
