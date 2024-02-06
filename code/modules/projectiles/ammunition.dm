/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	throwforce = 1
	w_class = WEIGHT_CLASS_TINY
	var/fire_sound = null						//What sound should play when this ammo is fired
	var/casing_drop_sound = "casingdrop"               //What sound should play when this ammo hits the ground
	var/caliber = null							//Which kind of guns it can be loaded into
	var/projectile_type = null					//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null 			//The loaded bullet
	var/pellets = 1								//Pellets for spreadshot
	var/variance = 0							//Variance for inaccuracy fundamental to the casing
	var/delay = 0								//Delay for energy weapons
	var/randomspread = 0						//Randomspread for automatics
	var/click_cooldown_override = 0				//Override this to make your gun have a faster fire rate, in tenths of a second. 4 is the default gun cooldown.
	var/harmful = TRUE //pacifism check for boolet, set to FALSE if bullet is non-lethal

	/// What type of muzzle flash effect will be shown. If null then no effect and flash of light will be shown
	var/muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	/// What color the flash has. If null then the flash won't cause lighting
	var/muzzle_flash_color = LIGHT_COLOR_TUNGSTEN
	/// What range the muzzle flash has
	var/muzzle_flash_range = MUZZLE_FLASH_RANGE_WEAK
	/// How strong the flash is
	var/muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_WEAK

/obj/item/ammo_casing/New()
	..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	dir = pick(GLOB.alldirs)
	update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)

/obj/item/ammo_casing/update_desc()
	. = ..()
	desc = "[initial(desc)][BB ? "" : " This one is spent."]"

/obj/item/ammo_casing/update_icon_state()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"

/obj/item/ammo_casing/proc/newshot(params) //For energy weapons, shotgun shells and wands (!).
	if(!BB)
		BB = new projectile_type(src, params)
	return

/obj/item/ammo_casing/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/ammo_box))
		var/obj/item/ammo_box/box = I
		if(box.slow_loading)
			return
		if(isturf(loc))
			var/boolets = 0
			for(var/obj/item/ammo_casing/bullet in loc)
				if(length(box.stored_ammo) >= box.max_ammo)
					break
				if(bullet.BB)
					if(box.give_round(bullet, 0))
						boolets++
				else
					continue
			if(boolets > 0)
				box.update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
				to_chat(user, "<span class='notice'>You collect [boolets] shell\s. [box] now contains [length(box.stored_ammo)] shell\s.</span>")
				playsound(src, 'sound/weapons/gun_interactions/bulletinsert.ogg', 50, 1)
			else
				to_chat(user, "<span class='warning'>You fail to collect anything!</span>")
	else
		..()

/obj/item/ammo_casing/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!BB)
		to_chat(user, "<span class='notice'>There is no bullet in the casing to inscribe anything into.</span>")
		return
	if(!initial(BB.name) == "bullet")
		to_chat(user, "<span class='notice'>You can only inscribe a metal bullet.</span>")//because inscribing beanbags is silly
		return

	var/tmp_label = ""
	var/label_text = sanitize(input(user, "Inscribe some text into \the [initial(BB.name)]", "Inscription", tmp_label))

	if(length(label_text) > 20)
		to_chat(user, "<span class='warning'>The inscription can be at most 20 characters long.</span>")
		return

	if(label_text == "")
		to_chat(user, "<span class='notice'>You scratch the inscription off of [initial(BB)].</span>")
		BB.name = initial(BB.name)
	else
		to_chat(user, "<span class='notice'>You inscribe \"[label_text]\" into \the [initial(BB.name)].</span>")
		BB.name = "[initial(BB.name)] \"[label_text]\""




/obj/item/ammo_casing/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user) && !BB)
		C.stored_comms["metal"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/ammo_casing/emp_act(severity)
	BB?.emp_act(severity)

#define AMMO_MULTI_SPRITE_STEP_NONE null
#define AMMO_MULTI_SPRITE_STEP_ON_OFF -1

//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (generic)"
	desc = "A box of ammo?"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "10mmbox" // placeholder icon
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	item_state = "syringe_kit"
	materials = list(MAT_METAL = 30000)
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	var/list/stored_ammo = list()
	var/ammo_type = /obj/item/ammo_casing
	var/max_ammo = 7
	var/multi_sprite_step = AMMO_MULTI_SPRITE_STEP_NONE // see update_icon_state() for details
	var/caliber
	var/multiload = 1
	var/slow_loading = FALSE
	var/list/initial_mats //For calculating refund values.

/obj/item/ammo_box/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_ammo)
		stored_ammo += new ammo_type(src)
	update_appearance(UPDATE_DESC|UPDATE_ICON)

/obj/item/ammo_box/Destroy()
	QDEL_LIST_CONTENTS(stored_ammo)
	stored_ammo = null
	return ..()

/obj/item/ammo_box/proc/get_round(keep = 0)
	if(!length(stored_ammo))
		return null
	else
		var/b = stored_ammo[length(stored_ammo)]
		stored_ammo -= b
		if(keep)
			stored_ammo.Insert(1,b)
		if(!initial_mats)
			initial_mats = materials.Copy()
		update_mat_value()
		update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
		return b

/obj/item/ammo_box/emp_act(severity)
	for(var/obj/item/ammo_casing/A in stored_ammo)
		A.emp_act(severity)

/obj/item/ammo_box/proc/give_round(obj/item/ammo_casing/R, replace_spent = 0)
	// Boxes don't have a caliber type, magazines do. Not sure if it's intended or not, but if we fail to find a caliber, then we fall back to ammo_type.
	if(!R || (caliber && R.caliber != caliber) || (!caliber && R.type != ammo_type))
		return 0

	if(length(stored_ammo) < max_ammo)
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
		A.update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
		update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)

	return num_loaded

/obj/item/ammo_box/attack_self(mob/user as mob)
	var/obj/item/ammo_casing/A = get_round()
	if(A)
		user.put_in_hands(A)
		playsound(src, 'sound/weapons/gun_interactions/remove_bullet.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You remove a round from \the [src]!</span>")
		update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)

// `multi_sprite_step` governs whether there are different sprites for different degrees of being loaded.
// AMMO_MULTI_SPRITE_STEP_NONE - just a single `icon_state`, no shenanigans
// AMMO_MULTI_SPRITE_STEP_ON_OFF - empty sprite `[icon_state]-0`, full sprite `[icon_state]`, no inbetween
// (positive integer) - sprites for intermediate degrees of being loaded are present in the .dmi
//   and are named `[icon_state]-[ammo_count]`, with `ammo_count` being incremented in steps of `multi_sprite_step`
//   ... except the very final full mag sprite with is just `[icon_state]`
/obj/item/ammo_box/update_icon_state()
	var/icon_base = initial(icon_state)
	switch(multi_sprite_step)
		if(AMMO_MULTI_SPRITE_STEP_NONE)
			icon_state = icon_base
		if(AMMO_MULTI_SPRITE_STEP_ON_OFF)
			icon_state = "[icon_base][length(stored_ammo) ? "" : "-0"]"
		else
			var/shown_ammo = CEILING(length(stored_ammo), multi_sprite_step)
			if(shown_ammo == CEILING(max_ammo, multi_sprite_step))
				icon_state = icon_base
			else
				icon_state = "[icon_base]-[shown_ammo]"

/obj/item/ammo_box/update_desc()
	. = ..()
	desc = "[initial(desc)] There are [length(stored_ammo)] shell\s left!"

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
	return length(stored_ammo)

/obj/item/ammo_box/magazine/proc/empty_magazine()
	var/turf_mag = get_turf(src)
	for(var/obj/item/ammo in stored_ammo)
		ammo.forceMove(turf_mag)
		stored_ammo -= ammo
