/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	anchored = 1
	var/id = null
	var/height = 0							//the 'height' of the ladder. higher numbers are considered physically higher
	var/obj/structure/ladder/down = null	//the ladder below this one
	var/obj/structure/ladder/up = null		//the ladder above this one
	var/use_verb = "climbs"

/obj/structure/ladder/New()
	spawn(8)
		for(var/obj/structure/ladder/L in world)
			if(L.id == id)
				if(L.height == (height - 1))
					down = L
					if(isnull(L.up))
						L.up = src
					continue
				if(L.height == (height + 1))
					up = L
					if(isnull(L.down))
						L.down = src
					continue

			if(up && down)	//if both our connections are filled
				break
		update_icon()

/obj/structure/ladder/update_icon()
	if(up && down)
		icon_state = "ladder11"

	else if(up)
		icon_state = "ladder10"

	else if(down)
		icon_state = "ladder01"

	else	//wtf make your ladders properly assholes
		icon_state = "ladder00"

/obj/structure/ladder/attack_hand(mob/user as mob)
	if(up && down)
		switch( alert("Go up or down the ladder?", "Ladder", "Up", "Down", "Cancel") )
			if("Up")
				user.visible_message("<span class='notice'>[user] climbs up \the [src]!</span>", \
									 "<span class='notice'>You climb up \the [src]!</span>")
				user.forceMove(get_turf(up))
				up.add_fingerprint(user)
			if("Down")
				user.visible_message("<span class='notice'>[user] climbs down \the [src]!</span>", \
									 "<span class='notice'>You climb down \the [src]!</span>")
				user.forceMove(get_turf(down))
				down.add_fingerprint(user)
			if("Cancel")
				return

	else if(up)
		user.visible_message("<span class='notice'>[user] climbs up \the [src]!</span>", \
							 "<span class='notice'>You climb up \the [src]!</span>")
		user.forceMove(get_turf(up))
		up.add_fingerprint(user)

	else if(down)
		user.visible_message("<span class='notice'>[user] climbs down \the [src]!</span>", \
							 "<span class='notice'>You climb down \the [src]!</span>")
		user.forceMove(get_turf(down))
		down.add_fingerprint(user)

	add_fingerprint(user)

/obj/structure/ladder/attackby(obj/item/weapon/W, mob/user as mob, params)
	return attack_hand(user)

/obj/structure/ladder/dive_point/buoy
	name = "diving point bouy"
	desc = "A buoy marking the location of an underwater dive area."
	icon = 'icons/misc/beach.dmi'
	icon_state = "buoy"
	id = "dive"
	height = 2
	use_verb = "dives"
	layer = MOB_LAYER + 0.2		//0.1 higher than the water overlay, this also means people can "swim" behind/under it

/obj/structure/ladder/dive_point/anchor
	name = "diving point anchor"
	desc = "An anchor tethered to the buoy at the surface, to keep the dive area marked."
	icon = 'icons/misc/beach.dmi'
	icon_state = "anchor"
	id = "dive"
	height = 1
	use_verb = "ascends"
	light_range = 5

/obj/structure/ladder/dive_point/New()
	..()
	set_light(light_range, light_power)		//magical glowing anchor

/obj/structure/ladder/dive_point/update_icon()
	return