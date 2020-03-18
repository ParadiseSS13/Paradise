/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 1
	w_class = WEIGHT_CLASS_TINY
	var/fire_sound = null						//What sound should play when this ammo is fired
	var/drop_sound = "casingdrop"               //What sound should play when this ammo hits the ground
	var/caliber = null							//Which kind of guns it can be loaded into
	var/projectile_type = null					//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null 			//The loaded bullet
	var/pellets = 1								//Pellets for spreadshot
	var/variance = 0							//Variance for inaccuracy fundamental to the casing
	var/delay = 0								//Delay for energy weapons
	var/randomspread = 0						//Randomspread for automatics
	var/click_cooldown_override = 0				//Override this to make your gun have a faster fire rate, in tenths of a second. 4 is the default gun cooldown.
	var/harmful = TRUE //pacifism check for boolet, set to FALSE if bullet is non-lethal

/obj/item/ammo_casing/New()
	..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	dir = pick(alldirs)
	update_icon()

/obj/item/ammo_casing/update_icon()
	..()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"
	desc = "[initial(desc)][BB ? "" : " This one is spent."]"

/obj/item/ammo_casing/proc/newshot(params) //For energy weapons, shotgun shells and wands (!).
	if(!BB)
		BB = new projectile_type(src, params)
	return

/obj/item/ammo_casing/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/ammo_box))
		var/obj/item/ammo_box/box = I
		if(isturf(loc))
			var/boolets = 0
			for(var/obj/item/ammo_casing/bullet in loc)
				if(box.stored_ammo.len >= box.max_ammo)
					break
				if(bullet.BB)
					if(box.give_round(bullet, 0))
						boolets++
				else
					continue
			if(boolets > 0)
				box.update_icon()
				to_chat(user, "<span class='notice'>You collect [boolets] shell\s. [box] now contains [box.stored_ammo.len] shell\s.</span>")
				playsound(src, 'sound/weapons/gun_interactions/bulletinsert.ogg', 50, 1)
			else
				to_chat(user, "<span class='warning'>You fail to collect anything!</span>")
	else
		if(istype(I, /obj/item/screwdriver))
			if(BB)
				if(initial(BB.name) == "bullet")
					var/tmp_label = ""
					var/label_text = sanitize(input(user, "Inscribe some text into \the [initial(BB.name)]","Inscription",tmp_label))
					if(length(label_text) > 20)
						to_chat(user, "<span class='warning''>The inscription can be at most 20 characters long.</span>")
					else
						if(label_text == "")
							to_chat(user, "<span class='notice'>You scratch the inscription off of [initial(BB)].</span>")
							BB.name = initial(BB.name)
						else
							to_chat(user, "<span class='notice'>You inscribe \"[label_text]\" into \the [initial(BB.name)].</span>")
							BB.name = "[initial(BB.name)] \"[label_text]\""
				else
					to_chat(user, "<span class='notice'>You can only inscribe a metal bullet.</span>")//because inscribing beanbags is silly

			else
				to_chat(user, "<span class='notice'>There is no bullet in the casing to inscribe anything into.</span>")
		..()

//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (generic)"
	desc = "A box of ammo?"
	icon_state = "357"
	icon = 'icons/obj/ammo.dmi'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "syringe_kit"
	materials = list(MAT_METAL = 30000)
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	var/list/stored_ammo = list()
	var/ammo_type = /obj/item/ammo_casing
	var/max_ammo = 7
	var/multiple_sprites = 0
	var/caliber
	var/multiload = 1
	var/list/initial_mats //For calculating refund values.

/obj/item/ammo_box/New()
	..()
	for(var/i in 1 to max_ammo)
		stored_ammo += new ammo_type(src)
	update_icon()
	initial_mats = materials.Copy()
	update_mat_value()

/obj/item/ammo_box/Destroy()
	QDEL_LIST(stored_ammo)
	stored_ammo = null
	return ..()

/obj/item/ammo_box/proc/get_round(keep = 0)
	if(!stored_ammo.len)
		return null
	else
		var/b = stored_ammo[stored_ammo.len]
		stored_ammo -= b
		if(keep)
			stored_ammo.Insert(1,b)
		update_mat_value()
		return b

/obj/item/ammo_box/proc/give_round(obj/item/ammo_casing/R, replace_spent = 0)
	// Boxes don't have a caliber type, magazines do. Not sure if it's intended or not, but if we fail to find a caliber, then we fall back to ammo_type.
	if(!R || (caliber && R.caliber != caliber) || (!caliber && R.type != ammo_type))
		return 0

	if(stored_ammo.len < max_ammo)
		stored_ammo += R
		R.loc = src
		playsound(src, 'sound/weapons/gun_interactions/bulletinsert.ogg', 50, 1)
		update_mat_value()
		return 1
	//for accessibles magazines (e.g internal ones) when full, start replacing spent ammo
	else if(replace_spent)
		for(var/obj/item/ammo_casing/AC in stored_ammo)
			if(!AC.BB)//found a spent ammo
				stored_ammo -= AC
				AC.loc = get_turf(loc)

				stored_ammo += R
				R.loc = src
				playsound(src, 'sound/weapons/gun_interactions/shotguninsert.ogg', 50, 1)
				update_mat_value()
				return 1

	return 0

/obj/item/ammo_box/proc/can_load(mob/user)
	return 1

/obj/item/ammo_box/attackby(obj/item/A, mob/user, params, silent = 0, replace_spent = 0)
	var/num_loaded = 0
	if(!can_load(user))
		return
	if(istype(A, /obj/item/ammo_box))
		var/obj/item/ammo_box/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			var/did_load = give_round(AC, replace_spent)
			if(did_load)
				AM.stored_ammo -= AC
				num_loaded++
			if(!multiload || !did_load)
				break
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(give_round(AC, replace_spent))
			user.drop_item()
			AC.loc = src
			num_loaded++
	if(num_loaded)
		if(!silent)
			to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		playsound(src, 'sound/weapons/gun_interactions/shotguninsert.ogg', 50, 1)
		A.update_icon()
		update_icon()

	return num_loaded

/obj/item/ammo_box/attack_self(mob/user as mob)
	var/obj/item/ammo_casing/A = get_round()
	if(A)
		user.put_in_hands(A)
		playsound(src, 'sound/weapons/gun_interactions/remove_bullet.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You remove a round from \the [src]!</span>")
		update_icon()

/obj/item/ammo_box/update_icon()
	switch(multiple_sprites)
		if(1)
			icon_state = "[initial(icon_state)]-[stored_ammo.len]"
		if(2)
			icon_state = "[initial(icon_state)]-[stored_ammo.len ? "[max_ammo]" : "0"]"
	desc = "[initial(desc)] There are [stored_ammo.len] shell\s left!"

/obj/item/ammo_box/proc/update_mat_value()
	var/num_ammo = 0
	for(var/B in stored_ammo)
		var/obj/item/ammo_casing/AC = B
		if(!AC.BB) //Skip any casing which are empty
			continue
		num_ammo++
	for(var/M in initial_mats) //In case we have multiple types of materials
		var/materials_per = initial_mats[M] / max_ammo

		var/value = max(materials_per * num_ammo, 500) //Enforce a minimum of 500 units even if empty.
		materials[M] = value

//Behavior for magazines
/obj/item/ammo_box/magazine/proc/ammo_count()
	return stored_ammo.len

/obj/item/ammo_box/magazine/proc/empty_magazine()
	var/turf_mag = get_turf(src)
	for(var/obj/item/ammo in stored_ammo)
		ammo.forceMove(turf_mag)
		stored_ammo -= ammo
