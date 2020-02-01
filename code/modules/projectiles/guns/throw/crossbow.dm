/obj/item/gun/throw/crossbow
	name = "Makeshift crossbow"
	desc = "A Woody badly made ,Cell-Powered kind of Crossbow."
	icon_state = "Mcrossbow"
	item_state = "Mcrossbow-solid"
	fire_sound_text = "a solid thunk"
	fire_delay = 10
	slot_flags = SLOT_BELT|SLOT_BACK
	valid_projectile_type = /obj/item/arrow

	var/tension = 0
	var/drawtension = 7
	var/speed_multiplier = 10
	var/range_multiplier = 10
	var/obj/item/stock_parts/cell/cell = null    // Used for firing superheated rods.

/obj/item/gun/throw/crossbow/get_cell()
	return cell

/obj/item/gun/throw/crossbow/emp_act(severity)
	if(cell && severity)
		emp_act(severity)

obj/item/gun/throw/crossbow/update_icon()
	icon_state = "[initial(icon_state)]"
	if(cell)
		icon_state += "-Cell"
	if(to_launch)
		icon_state += "-Loaded"
	if(tension)
		icon_state += "-Charged"
	if(cell.charge >= 500 && tension)
		icon_state +="-Hot"

/obj/item/gun/throw/crossbow/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>\A [cell] is mounted onto [src]. Battery cell charge: [cell.charge]/[cell.maxcharge]"
		update_icon()
	else
		. += "<span class='notice'>It has an empty mount for a battery cell.</span>"

/obj/item/gun/throw/crossbow/modify_projectile(obj/I)
	if(tension && cell.use(2000)
		var/obj/item/arrow/rod/R = I
		visible_message("<span class='danger'>[R] plinks and crackles as it begins to glow red-hot.</span>")
		R.throwforce = 14.5
		R.superheated = 1
		R.embed_chance = 100
		R.embedded_fall_chance = 0
		R.embedded_pain_multiplier = 3
		R.sharp = 1
		cell.use(2000)

/obj/item/gun/throw/crossbow/get_throwspeed()
	return 5 * speed_multiplier

/obj/item/gun/throw/crossbow/get_throwrange()
	return 5 * range_multiplier

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
	if(!cell)
		to_chat(user, "<span class='warning'> Battery Cell is missing.</span>")
		return

	user.visible_message("[user] begins to draw back the string of [src].","You begin to draw back the string of [src].")
	if(do_after(user, 7 , target = user))
		tension = drawtension
		user.visible_message("[usr] draws back the string of [src]!","[src] clunks as you draw the string to its maximum tension!!")
		update_icon()

/obj/item/gun/throw/crossbow/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/stock_parts/cell))
		if(!cell)
			user.drop_item()
			W.loc = src
			cell = W
			to_chat(user, "<span class='notice'>You jam [cell] into [src] and wire it to the firing coil.</span>")
			process_chamber()
		else
			to_chat(user, "<span class='notice'>[src] already has a cell installed.</span>")
	else if(istype(W, /obj/item/screwdriver))
		if(cell)
			cell.loc = get_turf(src)
			to_chat(user, "<span class='notice'>You jimmy [cell] out of [src] with [W].</span>")
			cell = null
		else
			to_chat(user, "<span class='notice'>[src] doesn't have a cell installed.</span>")
	else
		..()

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
	throw_speed = 4
	throw_range = 0
	embed_chance = 100
	embedded_fall_chance = 5
	embedded_pain_chance = 33
	embedded_pain_multiplier = 2
	embedded_unsafe_removal_pain_multiplier = 5
	embedded_impact_pain_multiplier = 3
	embedded_unsafe_removal_time = 20
	embedded_ignore_throwspeed_threshold = 1
	sharp = 1
	var/superheated = 0

/obj/item/arrow/rod/removed()
	if(superheated) // The rod has been superheated - we don't want it to be useable when removed from the bow.
		visible_message("[src] shatters into a scattering of overstressed metal shards as it leaves the crossbow.")
		qdel(src)
