/obj/structure/closet/secure_closet/guncabinet
	name = "gun cabinet"
	req_access = list(ACCESS_ARMORY)
	icon = 'icons/obj/guncabinet.dmi'
	door_anim_time = 0
	icon_state = "base"
	anchored = TRUE

/obj/structure/closet/secure_closet/guncabinet/toggle()
	..()
	update_icon()

/obj/structure/closet/secure_closet/guncabinet/take_contents()
	..()
	update_icon()

/obj/structure/closet/secure_closet/guncabinet/emag_act(mob/user)
	if(!broken)
		broken = TRUE
		locked = FALSE
		to_chat(user, "<span class='notice'>You break the lock on [src].</span>")
		update_icon()
		return TRUE

/obj/structure/closet/secure_closet/guncabinet/update_overlays()
	. = list()
	if(!opened)
		var/lasers = 0
		var/ballistics = 0
		for(var/obj/item/gun/G in contents)
			if(istype(G, /obj/item/gun/energy))
				lasers++
			if(istype(G, /obj/item/gun/projectile))
				ballistics++
		if(lasers || ballistics)
			for(var/i = 0 to 2)
				if(!lasers && !ballistics) //This may seem redundant but needed here to prevent adding the gun overlay without guns
					continue
				var/image/gun = image(icon(icon))
				if(lasers && (!ballistics || prob(50)))
					lasers--
					gun.icon_state = "laser"
				else if(ballistics)
					ballistics--
					gun.icon_state = "projectile"

				gun.pixel_x = i*4
				. += gun
		if(broken)
			. += "off"
	. += ..() // Parent call at the end instead of the beginning because we need the gun overlays to be drawn first, then the door.

/obj/structure/closet/secure_closet/guncabinet/cc
	req_access = list(ACCESS_CENT_SPECOPS_COMMANDER)
