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

/obj/structure/closet/secure_closet/personal/cabinet/populate_contents()
	new /obj/item/storage/backpack/satchel/withwallet( src )
	new /obj/item/radio/headset( src )

/obj/structure/closet/secure_closet/personal/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(opened || !istype(W, /obj/item/card/id))
		return ..()

	if(broken)
		to_chat(user, "<span class='warning'>The locker appears to be broken.</span>")
		return ITEM_INTERACT_COMPLETE

	if(user.loc == src)
		to_chat(user, "<span class='notice'>You can't reach the lock from inside.</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(W, /obj/item/card/id/guest))
		to_chat(user, "<span class='warning'>Invalid identification card.</span>")
		return ITEM_INTERACT_COMPLETE

	var/obj/item/card/id/I = W
	if(!I || !I.registered_name)
		return ITEM_INTERACT_COMPLETE

	if(allowed(user) || !registered_name || (istype(I) && (registered_name == I.registered_name)))
		//they can open all lockers, or nobody owns this, or they own this locker
		locked = !locked
		update_icon()
		if(!locked)
			registered_name = null
			desc = initial(desc)

		if(!registered_name && locked)
			registered_name = I.registered_name
			desc = "Owned by [I.registered_name]."

	else
		to_chat(user, "<span class='warning'>Access denied.</span>")

	return ITEM_INTERACT_COMPLETE
