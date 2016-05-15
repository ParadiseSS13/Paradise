/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 1
	w_class = 1.0
	var/caliber = ""							//Which kind of guns it can be loaded into
	var/projectile_type = ""//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null 			//The loaded bullet
	var/pellets = 1
	var/deviation = 0
	var/spread = 0


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
	desc = "[initial(desc)][BB ? "" : " This one is spent"]"



/obj/item/ammo_casing/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/screwdriver))
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

/obj/item/ammo_casing/attackby(obj/item/ammo_box/box as obj, mob/user as mob, params)
	if(!istype(box, /obj/item/ammo_box))
		return
	if(isturf(loc))
		var/boolets = 0
		for(var/obj/item/ammo_casing/pew in loc)
			if(box.stored_ammo.len >= box.max_ammo)
				break
			if(pew.BB)
				if(box.give_round(pew))
					boolets++
			else
				continue
		if(boolets > 0)
			box.update_icon()
			to_chat(user, "<span class='notice'>You collect [boolets] shell\s. [box] now contains [box.stored_ammo.len] shell\s.</span>")
		else
			to_chat(user, "<span class='notice'>You fail to collect anything.</span>")

/obj/item/ammo_casing/proc/newshot() //For energy weapons, shotgun shells and wands (!).
	if(!BB)
		BB = new projectile_type(src)
	return



//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (generic)"
	desc = "A box of ammo?"
	icon_state = "357"
	icon = 'icons/obj/ammo.dmi'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "syringe_kit"
	materials = list(MAT_METAL=30000)
	throwforce = 2
	w_class = 1.0
	throw_speed = 4
	throw_range = 10
	var/list/stored_ammo = list()
	var/obj/item/ammo_casing/ammo_type
	var/max_ammo = 7
	var/multiple_sprites = 0
	var/caliber = ""
	var/multiload = 1
/obj/item/ammo_box/New()
	for(var/i = 1, i <= max_ammo, i++)
		stored_ammo += new ammo_type(src)
	update_icon()

/obj/item/ammo_box/proc/get_round(var/keep = 0)
	if(!stored_ammo.len)
		return null
	else
		var/b = stored_ammo[stored_ammo.len]
		stored_ammo -= b
		if(keep)
			stored_ammo.Insert(1,b)
		return b

/obj/item/ammo_box/proc/give_round(var/obj/item/ammo_casing/r)
	var/obj/item/ammo_casing/rb = r
	if(rb)
		if(stored_ammo.len < max_ammo && rb.caliber == caliber)
			stored_ammo += rb
			rb.loc = src
			return 1
	return 0

/obj/item/ammo_box/attackby(var/obj/item/A as obj, mob/user as mob, var/silent = 0, params)
	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_box))
		var/obj/item/ammo_box/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			var/didload = give_round(AC)
			if(didload)
				AM.stored_ammo -= AC
				num_loaded++
			if(!multiload || !didload)
				break
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(give_round(AC))
			user.drop_item()
			AC.loc = src
			num_loaded++
	if(num_loaded)
		if(!silent)
			to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		A.update_icon()
		update_icon()

/obj/item/ammo_box/attack_self(mob/user as mob)
	var/obj/item/ammo_casing/A = get_round()
	if(A)
		user.put_in_hands(A)
		to_chat(user, "<span class='notice'>You remove a round from \the [src]!</span>")
		update_icon()

/obj/item/ammo_box/update_icon()
	switch(multiple_sprites)
		if(1)
			icon_state = "[initial(icon_state)]-[stored_ammo.len]"
		if(2)
			icon_state = "[initial(icon_state)]-[stored_ammo.len ? "[max_ammo]" : "0"]"
	desc = "[initial(desc)] There are [stored_ammo.len] shell\s left!"

//Behavior for magazines
/obj/item/ammo_box/magazine/proc/ammo_count()
	return stored_ammo.len
