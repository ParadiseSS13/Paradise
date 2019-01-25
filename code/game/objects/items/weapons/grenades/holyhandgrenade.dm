/obj/item/grenade/holy
	name = "Holy Hand Grenade"
	desc = "You feel a divine urge to throw it."
	icon_state = "holyhandgrenade"

/obj/item/grenade/holy/prime()
	update_mob()
	playsound(loc, 'sound/weapons/holyhandgrenade.ogg', 100)
	addtimer(CALLBACK(src, .proc/holy_boom), 20)

/obj/item/grenade/holy/proc/holy_boom()
	explosion(loc, 5, 10, 20)
	qdel(src)

/obj/item/grenade/holy/fake
	desc = "It's just a plastic toy with a speaker."
	var/used = FALSE

/obj/item/grenade/holy/fake/attack_self(mob/user as mob)
	if(used)
		to_chat(user, "<span class='notice'>You try to prime [src], but it's already been used.</span>")
	else
		..()

/obj/item/grenade/holy/fake/holy_boom()
	playsound(loc, 'sound/items/bikehorn.ogg', 50)
	used = TRUE
	active = FALSE
	icon_state = initial(icon_state)