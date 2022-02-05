#define XBOW_TENSION_20 "20%"
#define XBOW_TENSION_40 "40%"
#define XBOW_TENSION_60 "60%"
#define XBOW_TENSION_80 "80%"
#define XBOW_TENSION_FULL "100%"

/obj/item/gun/throw/crossbow
	name = "powered crossbow"
	desc = "A modern twist on an old classic. Pick up that can."
	icon_state = "crossbow"
	item_state = "crossbow-solid"
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	fire_delay = 25

	valid_projectile_type = /obj/item/arrow

	var/tension = 0
	var/drawtension = 5
	var/maxtension = 5
	var/speed_multiplier = 5
	var/range_multiplier = 3
	var/obj/item/stock_parts/cell/cell = null    // Used for firing superheated rods.
	var/list/possible_tensions = list(XBOW_TENSION_20, XBOW_TENSION_40, XBOW_TENSION_60, XBOW_TENSION_80, XBOW_TENSION_FULL)

/obj/item/gun/throw/crossbow/get_cell()
	return cell

/obj/item/gun/throw/crossbow/emp_act(severity)
	if(cell && severity)
		emp_act(severity)

/obj/item/gun/throw/crossbow/update_icon()
	if(!tension)
		if(!to_launch)
			icon_state = "[initial(icon_state)]"
		else
			icon_state = "[initial(icon_state)]-nocked"
	else
		icon_state = "[initial(icon_state)]-drawn"

/obj/item/gun/throw/crossbow/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>\A [cell] is mounted onto [src]. Battery cell charge: [cell.charge]/[cell.maxcharge]"
	else
		. += "<span class='notice'>It has an empty mount for a battery cell.</span>"

/obj/item/gun/throw/crossbow/modify_projectile(obj/item/I, on_chamber = 0)
	if(cell && on_chamber && istype(I, /obj/item/arrow/rod))
		var/obj/item/arrow/rod/R = I
		visible_message("<span class='danger'>[R] is ready!</span>")
		R.throwforce = 33
		R.superheated = 1 //guess this useless now...
		armour_penetration = 15

/obj/item/gun/throw/crossbow/get_throwspeed()
	return tension * speed_multiplier

/obj/item/gun/throw/crossbow/get_throwrange()
	return tension * range_multiplier

/obj/item/gun/throw/crossbow/process_chamber()
	..()
	if(to_launch)
		modify_projectile(to_launch, 1)
	update_icon()

/obj/item/gun/throw/crossbow/attack_self(mob/living/user)
	if(tension)
		if(to_launch)
			user.visible_message("<span class='notice'>[user] relaxes the tension on [src]'s string and removes [to_launch].</span>","<span class='notice'>You relax the tension on [src]'s string and remove [to_launch].</span>")
			to_launch.forceMove(get_turf(src))
			var/obj/item/arrow/A = to_launch
			to_launch = null
			A.removed()
			process_chamber()
		else
			user.visible_message("<span class='notice'>[user] relaxes the tension on [src]'s string.</span>","<span class='notice'>You relax the tension on [src]'s string.</span>")
		tension = 0
		update_icon()
	else
		draw(user)

/obj/item/gun/throw/crossbow/proc/draw(mob/living/user)
	if(user.incapacitated())
		return
	if(!to_launch)
		to_chat(user, "<span class='warning'>You can't draw [src] without a bolt nocked.</span>")
		return

	user.visible_message("[user] begins to draw back the string of [src].","You begin to draw back the string of [src].")
	if(cell && cell.charge > 499) //I really hope there is no way to get 499.5 charge or something
		if(do_after(user, 5 * drawtension, target = user))
			tension = drawtension
			cell.use(500)
			user.visible_message("[src] mechanism draws back the string!","[src] clunks as its mechanism draw the string to its maximum tension!!")
			update_icon()
	else
		user.visible_message("[usr] struggles to draws back the string of [src]!","[src] string is too tense to draw manually!")

/obj/item/gun/throw/crossbow/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/stock_parts/cell))
		return ..()

	if(cell)
		to_chat(user, "<span class='notice'>[src] already has a cell installed.</span>")
		return

	user.drop_item()
	I.forceMove(src)
	cell = I
	to_chat(user, "<span class='notice'>You jam [cell] into [src] and wire it to the firing coil.</span>")
	process_chamber()

/obj/item/gun/throw/crossbow/screwdriver_act(mob/user, obj/item/I)
	. = ..()
	if(!cell)
		to_chat(user, "<span class='notice'>[src] doesn't have a cell installed.</span>")
		return

	cell.forceMove(get_turf(src))
	to_chat(user, "<span class='notice'>You jimmy [cell] out of [src] with [I].</span>")
	cell = null

/obj/item/gun/throw/crossbow/verb/set_tension()
	set name = "Adjust Tension"
	set category = "Object"
	set src in range(0)

	var/mob/user = usr
	if(user.incapacitated())
		return
	var/choice = input("Select tension to draw to:", "[src]", XBOW_TENSION_FULL) as null|anything in possible_tensions
	if(!choice)
		return

	switch(choice)
		if(XBOW_TENSION_20)
			drawtension = CEILING(0.2 * maxtension, 1)
		if(XBOW_TENSION_40)
			drawtension = CEILING(0.4 * maxtension, 1)
		if(XBOW_TENSION_60)
			drawtension = CEILING(0.6 * maxtension, 1)
		if(XBOW_TENSION_80)
			drawtension = CEILING(0.8 * maxtension, 1)
		if(XBOW_TENSION_FULL)
			drawtension = maxtension

/obj/item/gun/throw/crossbow/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	..()
	tension = 0
	update_icon()
/obj/item/gun/throw/crossbow/french
	name = "french powered crossbow"
	icon_state = "fcrossbow"
	valid_projectile_type = /obj/item/reagent_containers/food/snacks/baguette

/obj/item/gun/throw/crossbow/french/modify_projectile(obj/item/I, on_chamber = 0)
	return

/obj/item/arrow
	name = "bolt"
	desc = "It's got a tip for you - get the point?"
	icon_state = "bolt"
	item_state = "bolt"
	throwforce = 20
	w_class = WEIGHT_CLASS_NORMAL
	sharp = 1

/obj/item/arrow/proc/removed() //Helper for metal rods falling apart.
	return

/obj/item/arrow/rod
	name = "makeshift bolt"
	desc = "A sharpened metal rod that can be fired out of a crossbow."
	icon_state = "metal-rod"
	throwforce = 10
	var/superheated = 0

/obj/item/arrow/rod/removed()
	if(superheated) // The rod has been superheated - we don't want it to be useable when removed from the bow.
		visible_message("[src] shatters into a scattering of overstressed metal shards as it leaves the crossbow.")
		qdel(src)

#undef XBOW_TENSION_20
#undef XBOW_TENSION_40
#undef XBOW_TENSION_60
#undef XBOW_TENSION_80
#undef XBOW_TENSION_FULL
