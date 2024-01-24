/obj/item/gun/projectile/revolver/doublebarrel/attack_self(mob/living/user)
	var/num_unloaded = 0
	while(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(FALSE)
		chambered = null
		CB.forceMove(get_turf(loc))
		CB.SpinAnimation(10, 1)
		CB.update_icon()
		playsound(get_turf(CB), 'sound/weapons/gun_interactions/shotgun_fall.ogg', 70, TRUE)
		num_unloaded++

	var/obj/item/storage/belt/bandolier/bando = user.find_in_storage(/obj/item/storage/belt/bandolier)
	if(bando && HAS_TRAIT(user, TRAIT_SLEIGHT_OF_HAND))
		var/shells_to_load = 2 - num_unloaded
		for(var/i in 1 to shells_to_load)
			var/obj/item/ammo_casing/shotgun/shell = bando.retrieve_item_of_type(/obj/item/ammo_casing/shotgun)
			if(shell)
				magazine.store_ammo(shell, user)
				to_chat(user, "<span class='notice'>You quickly load a shell from your bandolier into [src].</span>")

	if(num_unloaded)
		to_chat(user, "<span class='notice'>You break open [src] and unload [num_unloaded] shell\s.</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")

