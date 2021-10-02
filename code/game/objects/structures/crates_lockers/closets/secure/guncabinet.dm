/obj/structure/closet/secure_closet/guncabinet
	name = "gun cabinet"
	req_access = list(ACCESS_ARMORY)
	icon = 'icons/obj/guncabinet.dmi'
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

/obj/structure/closet/secure_closet/guncabinet/update_overlays()
	cut_overlays()
	if(!opened)
		var/lazors = 0
		var/shottas = 0
		for(var/obj/item/gun/G in contents)
			if(istype(G, /obj/item/gun/energy))
				lazors++
			if(istype(G, /obj/item/gun/projectile/))
				shottas++
		if(lazors || shottas)
			for(var/i = 0 to 2)
				var/image/gun = image(icon(icon))

				if(lazors > 0 && (shottas <= 0 || prob(50)))
					lazors--
					gun.icon_state = "laser"
				else if(shottas > 0)
					shottas--
					gun.icon_state = "projectile"

				gun.pixel_x = i*4
				overlays += gun

		add_overlay("door")
		if(broken)
			add_overlay("off")
		else if(locked)
			add_overlay("locked")
