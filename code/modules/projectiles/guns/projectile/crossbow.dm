//AMMUNITION

/obj/item/weapon/arrow

	name = "bolt"
	desc = "It's got a tip for you - get the point?"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bolt"
	item_state = "bolt"
	flags =  FPRINT | TABLEPASS
	throwforce = 8
	w_class = 3.0
	sharp = 1
	edge = 0

/obj/item/weapon/arrow/proc/removed() //Helper for metal rods falling apart.
	return

/obj/item/weapon/spike
	name = "alloy spike"
	desc = "It's about a foot of weird silver metal with a wicked point."
	sharp = 1
	edge = 0
	throwforce = 5
	w_class = 2
	icon = 'icons/obj/weapons.dmi'
	icon_state = "metal-rod"
	item_state = "bolt"

/obj/item/weapon/arrow/quill

	name = "vox quill"
	desc = "A wickedly barbed quill from some bizarre animal."
	icon_state = "quill"
	item_state = "quill"
	throwforce = 5

/obj/item/weapon/arrow/rod

	name = "metal rod"
	desc = "Don't cry for me, Orithena."
	icon_state = "metal-rod"

/obj/item/weapon/arrow/rod/removed(mob/user)
	if(throwforce == 15) // The rod has been superheated - we don't want it to be useable when removed from the bow.
		user  << "[src] shatters into a scattering of overstressed metal shards as it leaves the crossbow."
		var/obj/item/weapon/shard/shrapnel/S = new()
		S.loc = get_turf(src)
		src.Destroy()

/obj/item/weapon/arrow/baguette
	name = "baguette"
	desc = "Still warm from the oven!"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baguette"
	item_state = "baguette"
	throwforce = 3
	sharp = 0

/obj/item/weapon/gun/launcher/crossbow

	name = "powered crossbow"
	desc = "A 2557AD twist on an old classic. Pick up that can."
	icon_state = "crossbow"
	item_state = "crossbow-solid"
	fire_sound = 'sound/weapons/punchmiss.ogg' // TODO: Decent THWOK noise.
//	ejectshell = 0                          // No spent shells.
	mouthshoot = 1                          // No suiciding with this weapon, causes runtimes.
	fire_sound_text = "a solid thunk"
	fire_delay = 25

	var/tension = 0                         // Current draw on the bow.
	var/max_tension = 5                     // Highest possible tension.
	var/release_speed = 5                   // Speed per unit of tension.
	var/obj/item/weapon/cell/cell = null    // Used for firing superheated rods.
	var/current_user                        // Used to check if the crossbow has changed hands since being drawn.

/obj/item/weapon/gun/launcher/crossbow/emp_act(severity)
	if(cell && severity)
		cell.use(100*severity)

/obj/item/weapon/gun/launcher/crossbow/special_check(user)
	if(tension <= 0)
		user << "\red \The [src] is not drawn back!"
		return 0
	return 1

/obj/item/weapon/gun/launcher/crossbow/update_release_force()
	release_force = tension*release_speed

/obj/item/weapon/gun/launcher/crossbow/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)

	if(!..()) return //Only do this on a successful shot.
	icon_state = "crossbow"
	tension = 0

/obj/item/weapon/gun/launcher/crossbow/attack_self(mob/living/user as mob)
	if(tension)
		if(in_chamber && in_chamber.loc == src) //Just in case they click it the tick after firing.
			user.visible_message("[user] relaxes the tension on [src]'s string and removes [in_chamber].","You relax the tension on [src]'s string and remove [in_chamber].")
			in_chamber.loc = get_turf(src)
			var/obj/item/weapon/arrow/A = in_chamber
			in_chamber = null
			A.removed(user)
		else
			user.visible_message("[user] relaxes the tension on [src]'s string.","You relax the tension on [src]'s string.")
		tension = 0
		icon_state = "crossbow"
	else
		draw(user)

/obj/item/weapon/gun/launcher/crossbow/proc/draw(var/mob/user as mob)

	if(!in_chamber)
		user << "You don't have anything nocked to [src]."
		return

	if(user.restrained())
		return

	current_user = user
	user.visible_message("[user] begins to draw back the string of [src].","You begin to draw back the string of [src].")
	tension = 1
	spawn(25) increase_tension(user) //TODO: This needs to be changed to something less shit.

/obj/item/weapon/gun/launcher/crossbow/proc/increase_tension(var/mob/user as mob)

	if(!in_chamber || !tension || current_user != user) //Arrow has been fired, bow has been relaxed or user has changed.
		return

	tension++
	icon_state = "crossbow-drawn"

	if(tension>=max_tension)
		tension = max_tension
		usr << "[src] clunks as you draw the string to its maximum tension!"
	else
		user.visible_message("[usr] draws back the string of [src]!","You continue drawing back the string of [src]!")
		spawn(25) increase_tension(user)

/obj/item/weapon/gun/launcher/crossbow/attackby(obj/item/W as obj, mob/user as mob)
	if(!in_chamber)
		if (istype(W,/obj/item/weapon/arrow))
			user.drop_item()
			in_chamber = W
			in_chamber.loc = src
			user.visible_message("[user] slides [in_chamber] into [src].","You slide [in_chamber] into [src].")
			icon_state = "crossbow-nocked"
			return
		else if(istype(W,/obj/item/stack/rods))
			var/obj/item/stack/rods/R = W
			R.use(1)
			in_chamber = new /obj/item/weapon/arrow/rod(src)
			in_chamber.fingerprintslast = src.fingerprintslast
			in_chamber.loc = src
			icon_state = "crossbow-nocked"
			user.visible_message("[user] jams [in_chamber] into [src].","You jam [in_chamber] into [src].")
			superheat_rod(user)
			return

	if(istype(W, /obj/item/weapon/cell))
		if(!cell)
			user.drop_item()
			W.loc = src
			cell = W
			user << "<span class='notice'>You jam [cell] into [src] and wire it to the firing coil.</span>"
			superheat_rod(user)
		else
			user << "<span class='notice'>[src] already has a cell installed.</span>"

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(cell)
			var/obj/item/C = cell
			C.loc = get_turf(user)
			user << "<span class='notice'>You jimmy [cell] out of [src] with [W].</span>"
			cell = null
		else
			user << "<span class='notice'>[src] doesn't have a cell installed.</span>"

	else
		..()

/obj/item/weapon/gun/launcher/crossbow/proc/superheat_rod(var/mob/user)

	if(!user || !cell || !in_chamber) return
	if(cell.charge < 500) return
	if(in_chamber.throwforce >= 15) return
	if(!istype(in_chamber,/obj/item/weapon/arrow/rod)) return

	user << "<span class='notice'>[in_chamber] plinks and crackles as it begins to glow red-hot.</span>"
	in_chamber.throwforce = 15
	in_chamber.icon_state = "metal-rod-superheated"
	cell.use(500)


/obj/item/weapon/gun/launcher/crossbow/french
	name = "french powered crossbow"

/obj/item/weapon/gun/launcher/crossbow/french/attackby(obj/item/W as obj, mob/user as mob)
	if(!in_chamber)
		if (istype(W,/obj/item/weapon/reagent_containers/food/snacks/baguette))
			user.drop_item()
			in_chamber = W
			in_chamber.loc = src
			user.visible_message("[user] slides [in_chamber] into [src].","You slide [in_chamber] into [src].")
			icon_state = "crossbow-nocked"
			return

		else if (istype(W,/obj/item/weapon/arrow))
			user.visible_message("\The [src] only takes baguettes.")
			return
		else if(istype(W,/obj/item/stack/rods))
			user.visible_message("\The [src] only takes baguettes.")
			return

	if(istype(W, /obj/item/weapon/cell))
		user.visible_message("The [src] is too simple be adapted with a cell.")
		return

	else
		..()

/obj/item/weapon/gun/launcher/crossbow/french/increase_tension(var/mob/user as mob)

	if(!in_chamber || !tension || current_user != user) //Arrow has been fired, bow has been relaxed or user has changed.
		return

	tension++
	icon_state = "fcrossbow-drawn"

	if(tension>=max_tension)
		tension = max_tension
		usr << "[src] clunks as you draw the string to its maximum tension!"
	else
		user.visible_message("[usr] draws back the string of [src]!","You continue drawing back the string of [src]!")
		spawn(25) increase_tension(user)

// Crossbow construction.
/obj/item/weapon/crossbowframe
	name = "crossbow frame"
	desc = "A half-finished crossbow."
	icon_state = "crossbowframe0"
	item_state = "crossbow-solid"

	var/buildstate = 0

/obj/item/weapon/crossbowframe/update_icon()
	icon_state = "crossbowframe[buildstate]"

/obj/item/weapon/crossbowframe/examine()
	..()
	switch(buildstate)
		if(1) usr << "It has a loose rod frame in place."
		if(2) usr << "It has a steel backbone welded in place."
		if(3) usr << "It has a steel backbone and a cell mount installed."
		if(4) usr << "It has a steel backbone, plastic lath and a cell mount installed."
		if(5) usr << "It has a steel cable loosely strung across the lath."

/obj/item/weapon/crossbowframe/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/rods))
		if(buildstate == 0)
			var/obj/item/stack/rods/R = W
			if(R.amount >= 3)
				R.use(3)
				user << "\blue You assemble a backbone of rods around the wooden stock."
				buildstate++
				update_icon()
			else
				user << "\blue You need at least three rods to complete this task."
			return
	else if(istype(W,/obj/item/weapon/weldingtool))
		if(buildstate == 1)
			var/obj/item/weapon/weldingtool/T = W
			if(T.remove_fuel(0,user))
				if(!src || !T.isOn()) return
				playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
				user << "\blue You weld the rods into place."
			buildstate++
			update_icon()
		return
	else if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(buildstate == 2)
			if(C.amount >= 5)
				C.use(5)
				user << "\blue You wire a crude cell mount into the top of the crossbow."
				buildstate++
				update_icon()
			else
				user << "\blue You need at least five segments of cable coil to complete this task."
			return
		else if(buildstate == 4)
			if(C.amount >= 5)
				C.use(5)
				user << "\blue You string a steel cable across the crossbow's lath."
				buildstate++
				update_icon()
			else
				user << "\blue You need at least five segments of cable coil to complete this task."
			return
	else if(istype(W,/obj/item/stack/sheet/mineral/plastic))
		if(buildstate == 3)
			var/obj/item/stack/sheet/mineral/plastic/P = W
			if(P.amount >= 3)
				P.use(3)
				user << "\blue You assemble and install a heavy plastic lath onto the crossbow."
				buildstate++
				update_icon()
			else
				user << "\blue You need at least three plastic sheets to complete this task."
			return
	else if(istype(W,/obj/item/weapon/screwdriver))
		if(buildstate == 5)
			user << "\blue You secure the crossbow's various parts."
			new /obj/item/weapon/gun/launcher/crossbow(get_turf(src))
			del(src)
		return
	else
		..()
