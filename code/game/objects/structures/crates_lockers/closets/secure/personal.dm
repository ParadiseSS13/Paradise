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
	new /obj/item/radio/headset( src )


/obj/structure/closet/secure_closet/personal/patient
	name = "patient's closet"

/obj/structure/closet/secure_closet/personal/patient/populate_contents()
	new /obj/item/clothing/under/color/white( src )
	new /obj/item/clothing/shoes/white( src )

/obj/structure/closet/secure_closet/personal/cabinet
	icon_state = "cabinet"
	door_anim_time = 0
	resistance_flags = FLAMMABLE
	max_integrity = 70
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50

/obj/structure/closet/secure_closet/personal/cabinet/populate_contents()
	new /obj/item/storage/backpack/satchel/withwallet( src )
	new /obj/item/radio/headset( src )

/obj/structure/closet/secure_closet/personal/attackby(obj/item/W, mob/user, params)
	if(opened || !istype(W, /obj/item/card/id))
		return ..()

	if(istype(W, /obj/item/card/id/guest))
		to_chat(user, "<span class='warning'>Invalid identification card.</span>")
		return

	var/obj/item/card/id/I = W
	if(!I || !I.registered_name)
		return

	else if(allowed(user) || !registered_name || (istype(I) && (registered_name == I.registered_name)))
		//they can open all lockers, or nobody owns this, or they own this locker
		togglelock(user)
		if(!locked)
			registered_name = null
			desc = initial(desc)

		if(!registered_name && locked)
			registered_name = I.registered_name
			desc = "Owned by [I.registered_name]." 

	else
		to_chat(user, "<span class='warning'>Access denied.</span>")
