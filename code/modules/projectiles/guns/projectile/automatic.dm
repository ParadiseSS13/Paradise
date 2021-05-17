/obj/item/gun/projectile/automatic
	w_class = WEIGHT_CLASS_NORMAL
	var/alarmed = 0
	var/select = 1
	can_tactical = TRUE
	can_suppress = 1
	can_holster = FALSE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/gun/projectile/automatic/update_icon()
	..()
	overlays.Cut()
	if(!select)
		overlays += "[initial(icon_state)]semi"
	if(select == 1)
		overlays += "[initial(icon_state)]burst"
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	if(bayonet && can_bayonet)
		overlays += knife_overlay

/obj/item/gun/projectile/automatic/attackby(obj/item/A as obj, mob/user as mob, params)
	. = ..()
	if(.)
		if(alarmed) // Did the empty clip alarm go off already?
			alarmed = 0 // Reset the alarm once a magazine is loaded
		return
	if(istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if(istype(AM, mag_type))
			if(magazine)
				to_chat(user, "<span class='notice'>You perform a tactical reload on \the [src], replacing the magazine.</span>")
				magazine.loc = get_turf(loc)
				magazine.update_icon()
				magazine = null
			else
				to_chat(user, "<span class='notice'>You insert the magazine into \the [src].</span>")
			if(alarmed)
				alarmed = 0
			user.remove_from_mob(AM)
			magazine = AM
			magazine.loc = src
			chamber_round()
			A.update_icon()
			update_icon()
			return 1

/obj/item/gun/projectile/automatic/ui_action_click()
	burst_select()

/obj/item/gun/projectile/automatic/proc/burst_select()
	var/mob/living/carbon/human/user = usr
	select = !select
	if(!select)
		burst_size = 1
		fire_delay = 0
		to_chat(user, "<span class='notice'>You switch to semi-automatic.</span>")
	else
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		to_chat(user, "<span class='notice'>You switch to [burst_size] round burst.</span>")

	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, 1)
	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/gun/projectile/automatic/can_shoot()
	return get_ammo()

/obj/item/gun/projectile/automatic/proc/empty_alarm()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1

//Saber SMG//
/obj/item/gun/projectile/automatic/fullauto/twomode/proto
	name = "\improper Nanotrasen Saber SMG"
	desc = "A prototype three-round burst and full-auto 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	origin_tech = "combat=4;materials=2"
	fire_sound = 'sound/weapons/gunshots/gunshot_pistol.ogg'
	burst_burst_size = 3
	burst_fire_delay = 2

//C-20r SMG//
/obj/item/gun/projectile/automatic/fullauto/twomode/c20r
	name = "\improper C-20r SMG"
	desc = "A two-round burst and full-auto .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	fire_delay = 2.5
	burst_burst_size = 2
	burst_fire_delay = 2
	can_bayonet = TRUE
	knife_x_offset = 26
	knife_y_offset = 12

/obj/item/gun/projectile/automatic/fullauto/twomode/c20r/New()
	..()
	update_icon()

/obj/item/gun/projectile/automatic/fullauto/twomode/c20r/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	empty_alarm()

/obj/item/gun/projectile/automatic/fullauto/twomode/c20r/update_icon()
	..()
	icon_state = "c20r[magazine ? "-[CEILING(get_ammo(0)/4, 1)*4]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"

//WT550//
/obj/item/gun/projectile/automatic/fullauto/wt550
	name = "security auto rifle"
	desc = "An outdated personal defense weapon utilized by law enforcement. The WT-550 Automatic Rifle fires 4.6x30mm rounds."
	icon_state = "wt550"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	fire_sound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	fire_delay = 3.5
	can_suppress = 0
	can_bayonet = TRUE
	knife_x_offset = 25
	knife_y_offset = 12

/obj/item/gun/projectile/automatic/fullauto/wt550/update_icon()
	..()
	icon_state = "wt550[magazine ? "-[CEILING(get_ammo(0)/4, 1)*4]" : ""]"

//Type-U3 Uzi//
/obj/item/gun/projectile/automatic/fullauto/mini_uzi
	name = "\improper 'Type U3' Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon_state = "mini-uzi"
	origin_tech = "combat=4;materials=2;syndicate=4"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	fire_sound = 'sound/weapons/gunshots/gunshot_pistol.ogg'
	fire_delay = 2.35

//M-90gl Carbine//
/obj/item/gun/projectile/automatic/fullauto/twomode/m90
	name = "\improper M-90gl Carbine"
	desc = "A three-round burst and full-auto 5.56 toploading carbine, designated 'M-90gl'. Has an attached underbarrel grenade launcher which can be toggled on and off."
	icon_state = "m90"
	item_state = "m90-4"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = 0
	var/obj/item/gun/projectile/revolver/grenadelauncher/underbarrel
	burst_burst_size = 3
	burst_fire_delay = 2

/obj/item/gun/projectile/automatic/fullauto/twomode/m90/New()
	..()
	underbarrel = new /obj/item/gun/projectile/revolver/grenadelauncher(src)
	update_icon()

/obj/item/gun/projectile/automatic/fullauto/twomode/m90/afterattack(atom/target, mob/living/user, flag, params)
	if(select == 2)
		underbarrel.afterattack(target, user, flag, params)
	else
		..()
		return

/obj/item/gun/projectile/automatic/fullauto/twomode/m90/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_casing))
		if(istype(A, underbarrel.magazine.ammo_type))
			underbarrel.attack_self()
			underbarrel.attackby(A, user, params)
	else
		return ..()

/obj/item/gun/projectile/automatic/fullauto/twomode/m90/update_icon()
	..()
	overlays.Cut()
	switch(select)
		if(0)
			overlays += "[initial(icon_state)]auto"
		if(1)
			overlays += "[initial(icon_state)]burst"
		if(2)
			overlays += "[initial(icon_state)]gren"
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"
	if(magazine)
		overlays += image(icon = icon, icon_state = "m90-[CEILING(get_ammo(0)/6, 1)*6]")
		item_state = "m90-[CEILING(get_ammo(0)/7.5, 1)]"
	else
		item_state = "m90-0"
	return

/obj/item/gun/projectile/automatic/fullauto/twomode/m90/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select = 1
			burst_size = burst_burst_size
			fire_delay = burst_fire_delay
			to_chat(user, "<span class='notice'>You switch to [burst_size] round burst.</span>")
			modeupdate(user,FALSE)
		if(1)
			select = 2
			to_chat(user, "<span class='notice'>You switch to grenades.</span>")
			modeupdate(user,FALSE)
		if(2)
			select = 0
			burst_size = initial(burst_size)
			fire_delay = initial(fire_delay)
			to_chat(user, "<span class='notice'>You switch to full-automatic.</span>")
			modeupdate(user,TRUE)
	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, 1)
	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

//Tommy Gun//
/obj/item/gun/projectile/automatic/fullauto/tommygun
	name = "\improper Thompson SMG"
	desc = "A genuine 'Chicago Typewriter'."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	can_suppress = 0

//ARG Assault Rifle//
/obj/item/gun/projectile/automatic/fullauto/ar
	name = "ARG"
	desc = "A robust assault rile used by Nanotrasen fighting forces."
	icon_state = "arg"
	item_state = "arg"
	slot_flags = 0
	origin_tech = "combat=6;engineering=4"
	mag_type = /obj/item/ammo_box/magazine/m556/arg
	fire_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = 0

// Bulldog shotgun //
/obj/item/gun/projectile/automatic/shotgun/bulldog
	name = "\improper 'Bulldog' Shotgun"
	desc = "A compact, mag-fed semi-automatic shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 8-round drum magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=6;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	actions_types = list()

/obj/item/gun/projectile/automatic/shotgun/bulldog/New()
	..()
	update_icon()

/obj/item/gun/projectile/automatic/shotgun/bulldog/proc/update_magazine()
	if(magazine)
		overlays.Cut()
		overlays += "[magazine.icon_state]"
		if(istype(magazine, /obj/item/ammo_box/magazine/m12g/XtrLrg))
			w_class = WEIGHT_CLASS_BULKY
		else
			w_class = WEIGHT_CLASS_NORMAL
	else
		w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/projectile/automatic/shotgun/bulldog/update_icon()
	overlays.Cut()
	update_magazine()
	icon_state = "bulldog[chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/shotgun/bulldog/attackby(obj/item/A as obj, mob/user as mob, params)
	if(istype(A, /obj/item/ammo_box/magazine/m12g/XtrLrg))
		if(istype(loc, /obj/item/storage))	// To prevent inventory exploits
			var/obj/item/storage/Strg = loc
			if(Strg.max_w_class < WEIGHT_CLASS_BULKY)
				to_chat(user, "<span class='warning'>You can't reload [src], with a XL mag, while it's in a normal bag.</span>")
				return
	return ..()

/obj/item/gun/projectile/automatic/shotgun/bulldog/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	empty_alarm()

//Laser carbine//
/obj/item/gun/projectile/automatic/lasercarbine
	name = "\improper IK-60 Laser Carbine"
	desc = "A short, compact carbine like rifle, relying more on battery cartridges rather than a built in power cell. Utilized by the Nanotrasen Navy for combat operations."
	icon_state = "lasercarbine"
	item_state = "laser"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/laser
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = 0
	burst_size = 2

/obj/item/gun/projectile/automatic/lasercarbine/update_icon()
	..()
	icon_state = "lasercarbine[magazine ? "-[CEILING(get_ammo(0)/5, 1)*5]" : ""]"
