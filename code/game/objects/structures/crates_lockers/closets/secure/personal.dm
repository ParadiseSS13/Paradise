/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	req_access = list(ACCESS_ALL_PERSONAL_LOCKERS)
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/duffel(src)
	if(prob(50))
		new /obj/item/storage/backpack(src)
	else
		new /obj/item/storage/backpack/satchel_norm(src)
	new /obj/item/radio/headset(src)

/obj/structure/closet/secure_closet/personal/patient
	name = "patient's closet"

/obj/structure/closet/secure_closet/personal/patient/populate_contents()
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/shoes/white(src)

/obj/structure/closet/secure_closet/personal/mining
	name = "personal miner's locker"

/obj/structure/closet/secure_closet/personal/mining/populate_contents()
	new /obj/item/stack/sheet/cardboard(src)

/obj/structure/closet/secure_closet/personal/cabinet
	icon_state = "cabinetdetective"
	overlay_locked = "c_locked"
	overlay_locker = "c_locker"
	overlay_unlocked = "c_unlocked"
	resistance_flags = FLAMMABLE
	max_integrity = 70

/obj/structure/closet/secure_closet/personal/cabinet/populate_contents()
	new /obj/item/storage/backpack/satchel/withwallet(src)
	new /obj/item/radio/headset(src)

/obj/structure/closet/secure_closet/personal/attackby(obj/item/W, mob/user, params)
	if(opened || !W.GetID())
		return ..()

	if(broken)
		to_chat(user, "<span class='warning'>It appears to be broken.</span>")
		return

	var/obj/item/card/id/I = W.GetID()
	if(!I || !I.registered_name)
		return

	if(src == user.loc)
		to_chat(user, "<span class='notice'>You can't reach the lock from inside.</span>")

	else if(allowed(user) || !registered_name || (istype(I) && (registered_name == I.registered_name)))
		//they can open all lockers, or nobody owns this, or they own this locker
		locked = !locked
		if(!locked)
			registered_name = null
			desc = initial(desc)

		update_icon()
		if(!registered_name && locked)
			registered_name = I.registered_name
			desc = "Owned by [I.registered_name]."
	else
		to_chat(user, "<span class='warning'>Access Denied</span>")
