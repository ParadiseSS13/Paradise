/obj/item/gun/projectile/automatic
	w_class = WEIGHT_CLASS_NORMAL
	var/alarmed = 0
	var/select = 1
	can_tactical = TRUE
	can_suppress = 1
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/gun/projectile/automatic/isHandgun()
	return 0

/obj/item/gun/projectile/automatic/update_icon()
	..()
	overlays.Cut()
	if(!select)
		overlays += "[initial(icon_state)]semi"
	if(select == 1)
		overlays += "[initial(icon_state)]burst"
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"

/obj/item/gun/projectile/automatic/attackby(var/obj/item/A as obj, mob/user as mob, params)
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
/obj/item/gun/projectile/automatic/proto
	name = "\improper Nanotrasen Saber SMG"
	desc = "A prototype three-round burst 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	origin_tech = "combat=4;materials=2"
	fire_sound = 'sound/weapons/gunshots/gunshot_pistol.ogg'

//C-20r SMG//
/obj/item/gun/projectile/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A two-round burst .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	fire_delay = 2
	burst_size = 2

/obj/item/gun/projectile/automatic/c20r/New()
	..()
	update_icon()

/obj/item/gun/projectile/automatic/c20r/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	empty_alarm()

/obj/item/gun/projectile/automatic/c20r/update_icon()
	..()
	icon_state = "c20r[magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"

//WT550//
/obj/item/gun/projectile/automatic/wt550
	name = "security auto rifle"
	desc = "An outdated personal defense weapon utilized by law enforcement. The WT-550 Automatic Rifle fires 4.6x30mm rounds."
	icon_state = "wt550"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	fire_sound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	fire_delay = 2
	can_suppress = 0
	burst_size = 1
	actions_types = list()

/obj/item/gun/projectile/automatic/wt550/update_icon()
	..()
	icon_state = "wt550[magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""]"

//Type-U3 Uzi//
/obj/item/gun/projectile/automatic/mini_uzi
	name = "\improper 'Type U3' Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon_state = "mini-uzi"
	origin_tech = "combat=4;materials=2;syndicate=4"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	fire_sound = 'sound/weapons/gunshots/gunshot_pistol.ogg'
	burst_size = 2

//M-90gl Carbine//
/obj/item/gun/projectile/automatic/m90
	name = "\improper M-90gl Carbine"
	desc = "A three-round burst 5.56 toploading carbine, designated 'M-90gl'. Has an attached underbarrel grenade launcher which can be toggled on and off."
	icon_state = "m90"
	item_state = "m90-4"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = 0
	var/obj/item/gun/projectile/revolver/grenadelauncher/underbarrel
	burst_size = 3
	fire_delay = 2

/obj/item/gun/projectile/automatic/m90/New()
	..()
	underbarrel = new /obj/item/gun/projectile/revolver/grenadelauncher(src)
	update_icon()

/obj/item/gun/projectile/automatic/m90/afterattack(var/atom/target, var/mob/living/user, flag, params)
	if(select == 2)
		underbarrel.afterattack(target, user, flag, params)
	else
		..()
		return

/obj/item/gun/projectile/automatic/m90/attackby(var/obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_casing))
		if(istype(A, underbarrel.magazine.ammo_type))
			underbarrel.attack_self()
			underbarrel.attackby(A, user, params)
	else
		..()

/obj/item/gun/projectile/automatic/m90/update_icon()
	..()
	overlays.Cut()
	switch(select)
		if(0)
			overlays += "[initial(icon_state)]semi"
		if(1)
			overlays += "[initial(icon_state)]burst"
		if(2)
			overlays += "[initial(icon_state)]gren"
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"
	if(magazine)
		overlays += image(icon = icon, icon_state = "m90-[Ceiling(get_ammo(0)/6)*6]")
		item_state = "m90-[Ceiling(get_ammo(0)/7.5)]"
	else
		item_state = "m90-0"
	return

/obj/item/gun/projectile/automatic/m90/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select = 1
			burst_size = initial(burst_size)
			fire_delay = initial(fire_delay)
			to_chat(user, "<span class='notice'>You switch to [burst_size] round burst.</span>")
		if(1)
			select = 2
			to_chat(user, "<span class='notice'>You switch to grenades.</span>")
		if(2)
			select = 0
			burst_size = 1
			fire_delay = 0
			to_chat(user, "<span class='notice'>You switch to semi-auto.</span>")
	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, 1)
	update_icon()

//Tommy Gun//
/obj/item/gun/projectile/automatic/tommygun
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
	burst_size = 4
	fire_delay = 1

//ARG Assault Rifle//
/obj/item/gun/projectile/automatic/ar
	name = "ARG"
	desc = "A robust assault rile used by Nanotrasen fighting forces."
	icon_state = "arg"
	item_state = "arg"
	slot_flags = 0
	origin_tech = "combat=6;engineering=4"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = 0
	burst_size = 3
	fire_delay = 1

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
		return

/obj/item/gun/projectile/automatic/shotgun/bulldog/update_icon()
	overlays.Cut()
	update_magazine()
	icon_state = "bulldog[chambered ? "" : "-e"]"

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
	icon_state = "lasercarbine[magazine ? "-[Ceiling(get_ammo(0)/5)*5]" : ""]"
