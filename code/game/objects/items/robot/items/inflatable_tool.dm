/obj/item/inflatable/cyborg
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	var/power_use = 400
	var/structure_type = /obj/structure/inflatable
	/// How long it takes to inflate
	var/delay = 1 SECONDS

/obj/item/inflatable/cyborg/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon_state = "folded_door"
	power_use = 600
	structure_type = /obj/structure/inflatable/door

/obj/item/inflatable/cyborg/examine(mob/user)
	. = ..()
	. += "<span class='notice'>As a synthetic, you can restore them at a <b>cyborg recharger</b>.</span>"

/obj/item/inflatable/cyborg/attack_self(mob/user)
	if(locate(/obj/structure/inflatable) in get_turf(user))
		to_chat(user, "<span class='warning'>There's already an inflatable structure!</span>")
		return FALSE

	if(!do_after(user, delay, FALSE, user))
		return FALSE

	if(!useResource(user))
		return FALSE

	playsound(loc, 'sound/items/zip.ogg', 75, TRUE)
	to_chat(user, "<span class='notice'>You inflate [src].</span>")
	var/obj/structure/inflatable/R = new structure_type(user.loc)
	transfer_fingerprints_to(R)
	R.add_fingerprint(user)

/obj/item/inflatable/cyborg/proc/useResource(mob/user)
	if(!isrobot(user))
		return FALSE
	var/mob/living/silicon/robot/R = user
	if(R.cell.charge < power_use)
		to_chat(user, "<span class='warning'>Not enough power!</span>")
		return FALSE
	return R.cell.use(power_use)
