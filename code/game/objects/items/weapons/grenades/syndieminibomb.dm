/obj/item/weapon/grenade/syndieminibomb
	desc = "A syndicate manufactured explosive used to sow destruction and chaos"
	name = "syndicate minibomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/weapon/grenade/syndieminibomb/prime()
	update_mob()
	explosion(src.loc,1,2,4,flame_range = 2)
	qdel(src)


//Chameleon Bomb//

/obj/item/weapon/grenade/syndieminibomb/chameleon
	name = "syndicate chameleon bomb"
	desc = "An odd looking device that combines the technology of a syndicate minibomb and chameleon projector into one."
	icon_state = "chambomb"
	item_state = null // Stealthy
	display_timer = 0 //Let's not give it away
	var/mob/prankster = null	// So the original owner can pick it back up

/obj/item/weapon/grenade/syndieminibomb/chameleon/Destroy()
	prankster = null
	return ..()

/obj/item/weapon/grenade/syndieminibomb/chameleon/equipped(mob/living/user, slot)
	..()
	if(prankster)
		if(user != prankster)
			prime()

/obj/item/weapon/grenade/syndieminibomb/chameleon/attack_self(mob/user)
	if(!prankster)
		to_chat(user, "<span class='notice'>You mark the device with your finger.</span>")
		prankster = user
	else
		if(user == prankster)
			to_chat(user, "<span class='notice'>You reset the device's saved appearance.</span>")
			playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
			overlays.Cut()
			underlays.Cut()
			name = initial(name)
			desc = initial(desc)
			icon = initial(icon)
			icon_state = initial(icon_state)
			color = initial(color)

/obj/item/weapon/grenade/syndieminibomb/chameleon/afterattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(!prankster)
		to_chat(user, "<span class='warning'>Mark the device first!</span>")
		return
	if(istype(target, /obj/item))
		name = target.name
		desc = target.desc
		icon = target.icon
		icon_state = target.icon_state
		color = target.color
		overlays = target.overlays.Copy()
		underlays = target.underlays.Copy()
		playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
		to_chat(user, "<span class='notice'>Scanned [target].</span>")
