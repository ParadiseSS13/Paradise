/obj/item/weapon/gun/projectile/automatic
	w_class = 3.0
	automatic = 1
	var/alarmed = 0
	var/select = 1
	can_suppress = 1
	burst_size = 3
	fire_delay = 2
	action_button_name = "Toggle Firemode"	
	
/obj/item/weapon/gun/projectile/automatic/isHandgun()
	return 0
	
/obj/item/weapon/gun/projectile/automatic/proto
	name = "\improper Nanotrasen Saber SMG"
	desc = "A prototype three-round burst 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	mag_type = "/obj/item/ammo_box/magazine/smgm9mm"
	origin_tech = "combat=4;materials=2"

/obj/item/weapon/gun/projectile/automatic/update_icon()
	..()
	overlays.Cut()
	if(!select)
		overlays += "[initial(icon_state)]semi"
	if(select == 1)
		overlays += "[initial(icon_state)]burst"
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][silenced ? "-suppressed" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/attackby(var/obj/item/A as obj, mob/user as mob, params)
	. = ..()
	if(.)
		return
	if(istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if(istype(AM, text2path(mag_type)))
			if(magazine)
				user << "<span class='notice'>You perform a tactical reload on \the [src], replacing the magazine.</span>"
				magazine.forceMove(get_turf(src.loc))
				magazine.update_icon()
				magazine = null
			else
				user << "<span class='notice'>You insert the magazine into \the [src].</span>"
			user.remove_from_mob(AM)
			magazine = AM
			magazine.forceMove(src)
			chamber_round()
			A.update_icon()
			update_icon()
			return 1
	
/obj/item/weapon/gun/projectile/automatic/ui_action_click()
	burst_select()
	
/obj/item/weapon/gun/projectile/automatic/verb/burst_select()
	var/mob/living/carbon/human/user = usr
	select = !select
	if(!select)
		burst_size = 1
		fire_delay = 0
		user << "<span class='notice'>You switch to semi-automatic.</span>"
	else
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		user << "<span class='notice'>You switch to [burst_size] round burst.</span>"

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/proc/empty_alarm()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(src.loc, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/projectile/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A two-round burst .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	origin_tech = "combat=5;materials=2;syndicate=8"
	mag_type = "/obj/item/ammo_box/magazine/smgm45"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	fire_delay = 2
	burst_size = 2

/obj/item/weapon/gun/projectile/automatic/c20r/New()
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/c20r/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	empty_alarm()
	return

/obj/item/weapon/gun/projectile/automatic/c20r/update_icon()
	..()
	icon_state = "c20r[magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""][chambered ? "" : "-e"][silenced ? "-suppressed" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "\improper 'Type U3' Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon_state = "mini-uzi"
	origin_tech = "combat=5;materials=2;syndicate=8"
	mag_type = "/obj/item/ammo_box/magazine/uzim9mm"
	burst_size = 2	
	
/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A heavily modified 7.62 light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the reciever below the designation."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = 5
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = "/obj/item/ammo_box/magazine/m762"
	fire_sound = 'sound/weapons/Gunshot3.ogg'

	var/cover_open = 0
	can_suppress = 0
	burst_size = 5
	fire_delay = 3
	
/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user as mob)
	cover_open = !cover_open
	user << "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>"
	update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? round(magazine.ammo_count() * 2, 25) : "-empty"]"

/obj/item/weapon/gun/projectile/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		user << "<span class='notice'>[src]'s cover is open! Close it before firing!</span>"
	else
		..()
		update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_hand(mob/user as mob)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open || (cover_open && !magazine))
		..()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_icon()
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		user << "<span class='notice'>You remove the magazine from [src].</span>"


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(var/obj/item/A as obj, mob/user as mob, params)
	if(!cover_open && istype(A, mag_type))
		user << "<span class='notice'>[src]'s cover is closed! You can't insert a new mag!</span>"
		return
	..()

/obj/item/weapon/gun/projectile/automatic/m90
	name = "\improper M-90gl Carbine"
	desc = "A three-round burst 5.56 toploading carbine, designated 'M-90gl'. Has an attached underbarrel grenade launcher which can be toggled on and off."
	icon_state = "m90"
	item_state = "m90"
	origin_tech = "combat=5;materials=2;syndicate=8"
	mag_type = "/obj/item/ammo_box/magazine/m556"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	action_button_name = "Toggle Grenade Launcher"
	can_suppress = 0
	var/obj/item/weapon/gun/projectile/revolver/grenadelauncher/underbarrel
	burst_size = 3
	fire_delay = 2

/obj/item/weapon/gun/projectile/automatic/m90/New()
	..()
	underbarrel = new /obj/item/weapon/gun/projectile/revolver/grenadelauncher(src)
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/m90/afterattack(var/atom/target, var/mob/living/user, flag, params)
	if(select == 2)
		underbarrel.afterattack(target, user, flag, params)
	else
		..()
		empty_alarm()
		return
		
/obj/item/weapon/gun/projectile/automatic/m90/attackby(var/obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_casing))
		if(istype(A, text2path(underbarrel.magazine.ammo_type)))
			underbarrel.attack_self()
			underbarrel.attackby(A, user, params)
	else
		..()

/obj/item/weapon/gun/projectile/automatic/m90/update_icon()
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
	return

/obj/item/weapon/gun/projectile/automatic/m90/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select = 1
			burst_size = initial(burst_size)
			fire_delay = initial(fire_delay)
			user << "<span class='notice'>You switch to [burst_size] round burst.</span>"
		if(1)
			select = 2
			user << "<span class='notice'>You switch to grenades.</span>"
		if(2)
			select = 0
			burst_size = 1
			fire_delay = 0
			user << "<span class='notice'>You switch to semi-auto.</span>"
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/tommygun
	name = "\improper Thompson SMG"
	desc = "A genuine 'Chicago Typewriter'."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = 5
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = "/obj/item/ammo_box/magazine/tommygunm45"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	can_suppress = 0
	fire_delay = 1
	burst_size = 4

/obj/item/weapon/gun/projectile/automatic/ar
	name = "ARG"
	desc = "A robust assault rile used by Nanotrasen fighting forces."
	icon_state = "arg"
	item_state = "arg"
	slot_flags = 0
	origin_tech = "combat=5;materials=1"
	mag_type = "/obj/item/ammo_box/magazine/m556"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	can_suppress = 0
	burst_size = 3
	fire_delay = 1
	