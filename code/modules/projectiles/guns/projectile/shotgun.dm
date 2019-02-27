/obj/item/gun/projectile/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags = CONDUCT
	slot_flags = SLOT_BACK
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	fire_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	var/recentpump = 0 // to prevent spammage

/obj/item/gun/projectile/shotgun/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		A.update_icon()
		update_icon()


/obj/item/gun/projectile/shotgun/process_chamber()
	return ..(0, 0)

/obj/item/gun/projectile/shotgun/chamber_round()
	return

/obj/item/gun/projectile/shotgun/can_shoot()
	if(!chambered)
		return 0
	return (chambered.BB ? 1 : 0)

/obj/item/gun/projectile/shotgun/attack_self(mob/living/user)
	if(recentpump)
		return
	pump(user)
	recentpump = 1
	spawn(10)
		recentpump = 0
	return


/obj/item/gun/projectile/shotgun/proc/pump(mob/M)
	playsound(M, 'sound/weapons/gun_interactions/shotgunpump.ogg', 60, 1)
	pump_unload(M)
	pump_reload(M)
	update_icon() //I.E. fix the desc
	return 1

/obj/item/gun/projectile/shotgun/proc/pump_unload(mob/M)
	if(chambered)//We have a shell in the chamber
		chambered.loc = get_turf(src)//Eject casing
		chambered.SpinAnimation(5, 1)
		playsound(src, chambered.drop_sound, 60, 1)
		chambered = null

/obj/item/gun/projectile/shotgun/proc/pump_reload(mob/M)
	if(!magazine.ammo_count())
		return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC

/obj/item/gun/projectile/shotgun/examine(mob/user)
	..()
	if(chambered)
		to_chat(user, "A [chambered.BB ? "live" : "spent"] one is in the chamber.")

/obj/item/gun/projectile/shotgun/isHandgun() //You cannot, in fact, holster a shotgun.
	return 0

/obj/item/gun/projectile/shotgun/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// RIOT SHOTGUN //

/obj/item/gun/projectile/shotgun/riot //for spawn in the armory
	name = "riot shotgun"
	desc = "A sturdy shotgun with a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot
	sawn_desc = "Come with me if you want to live."
	sawn_state = SAWN_INTACT

/obj/item/gun/projectile/shotgun/riot/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/circular_saw) || istype(A, /obj/item/gun/energy/plasmacutter))
		sawoff(user)
	if(istype(A, /obj/item/melee/energy))
		var/obj/item/melee/energy/W = A
		if(W.active)
			sawoff(user)
	if(istype(A, /obj/item/pipe))
		unsaw(A, user)

/obj/item/gun/projectile/shotgun/riot/sawoff(mob/user)
	if(sawn_state == SAWN_OFF)
		to_chat(user, "<span class='warning'>[src] has already been shortened!</span>")
		return
	if(istype(loc, /obj/item/storage))	//To prevent inventory exploits
		to_chat(user, "<span class='info'>How do you plan to modify [src] while it's in a bag.</span>")
		return
	if(chambered)	//if the gun is chambering live ammo, shoot self, if chambering empty ammo, 'click'
		if(chambered.BB)
			afterattack(user, user)
			user.visible_message("<span class='danger'>\The [src] goes off!</span>", "<span class='danger'>\The [src] goes off in your face!</span>")
			return
		else
			afterattack(user, user)
			user.visible_message("The [src] goes click!", "<span class='notice'>The [src] you are holding goes click.</span>")
	if(magazine.ammo_count())	//Spill the mag onto the floor
		user.visible_message("<span class='danger'>[user.name] opens [src] up and the shells go goes flying around!</span>", "<span class='userdanger'>You open [src] up and the shells go goes flying everywhere!!</span>")
		while(get_ammo(0) > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			if(CB)
				CB.loc = get_turf(loc)
				CB.update_icon()

	if(do_after(user, 30, target = src))
		user.visible_message("[user] shortens \the [src]!", "<span class='notice'>You shorten \the [src].</span>")
		post_sawoff()
		return 1


/obj/item/gun/projectile/shotgun/riot/proc/post_sawoff()
	name = "assault shotgun"
	desc = sawn_desc
	w_class = WEIGHT_CLASS_NORMAL
	current_skin = "riotshotgun-short"
	item_state = "gun"			//phil235 is it different with different skin?
	slot_flags &= ~SLOT_BACK    //you can't sling it on your back
	slot_flags |= SLOT_BELT     //but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
	sawn_state = SAWN_OFF
	magazine.max_ammo = 3
	update_icon()


/obj/item/gun/projectile/shotgun/riot/proc/unsaw(obj/item/A, mob/user)
	if(sawn_state == SAWN_INTACT)
		to_chat(user, "<span class='warning'>[src] has not been shortened!</span>")
		return
	if(istype(loc, /obj/item/storage))	//To prevent inventory exploits
		to_chat(user, "<span class='info'>How do you plan to modify [src] while it's in a bag.</span>")
		return
	if(chambered)	//if the gun is chambering live ammo, shoot self, if chambering empty ammo, 'click'
		if(chambered.BB)
			afterattack(user, user)
			user.visible_message("<span class='danger'>\The [src] goes off!</span>", "<span class='danger'>\The [src] goes off in your face!</span>")
			return
		else
			afterattack(user, user)
			user.visible_message("The [src] goes click!", "<span class='notice'>The [src] you are holding goes click.</span>")
	if(magazine.ammo_count())	//Spill the mag onto the floor
		user.visible_message("<span class='danger'>[user.name] opens [src] up and the shells go goes flying around!</span>", "<span class='userdanger'>You open [src] up and the shells go goes flying everywhere!!</span>")
		while(get_ammo() > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			if(CB)
				CB.loc = get_turf(loc)
				CB.update_icon()

	if(do_after(user, 30, target = src))
		qdel(A)
		user.visible_message("<span class='notice'>[user] lengthens [src]!</span>", "<span class='notice'>You lengthen [src].</span>")
		post_unsaw(user)
		return 1

/obj/item/gun/projectile/shotgun/riot/proc/post_unsaw()
	name = initial(name)
	desc = initial(desc)
	w_class = initial(w_class)
	current_skin = "riotshotgun"
	item_state = initial(item_state)
	slot_flags &= ~SLOT_BELT
	slot_flags |= SLOT_BACK
	sawn_state = SAWN_INTACT
	magazine.max_ammo = 6
	update_icon()

/obj/item/gun/projectile/shotgun/riot/update_icon() //Can't use the old proc as it makes it go to riotshotgun-short_sawn
	..()
	if(current_skin)
		icon_state = "[current_skin]"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun/projectile/shotgun/riot/short
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot/short

/obj/item/gun/projectile/shotgun/riot/short/New()
	..()
	post_sawoff()



///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

/obj/item/gun/projectile/shotgun/boltaction
	name = "\improper Mosin Nagant"
	desc = "This piece of junk looks like something that could have been used 700 years ago."
	icon_state = "moistnugget"
	item_state = "moistnugget"
	slot_flags = 0 //no SLOT_BACK sprite, alas
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction
	fire_sound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	var/bolt_open = 0

/obj/item/gun/projectile/shotgun/boltaction/pump(mob/M)
	playsound(M, 'sound/weapons/gun_interactions/rifle_load.ogg', 60, 1)
	if(bolt_open)
		pump_reload(M)
	else
		pump_unload(M)
	bolt_open = !bolt_open
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/gun/projectile/shotgun/blow_up(mob/user)
	. = 0
	if(chambered && chambered.BB)
		process_fire(user, user,0)
		. = 1

/obj/item/gun/projectile/shotgun/boltaction/attackby(obj/item/A, mob/user, params)
	if(!bolt_open)
		to_chat(user, "<span class='notice'>The bolt is closed!</span>")
		return
	. = ..()

/obj/item/gun/projectile/shotgun/boltaction/examine(mob/user)
	..()
	to_chat(user, "The bolt is [bolt_open ? "open" : "closed"].")

/obj/item/gun/projectile/shotgun/boltaction/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	var/guns_left = 30
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted

/obj/item/gun/projectile/shotgun/boltaction/enchanted/New()
	..()
	bolt_open = 1
	pump()

/obj/item/gun/projectile/shotgun/boltaction/enchanted/dropped()
	..()
	guns_left = 0

/obj/item/gun/projectile/shotgun/boltaction/enchanted/shoot_live_shot(mob/living/user as mob|obj, pointblank = 0, mob/pbtarget = null, message = 1)
	..()
	if(guns_left)
		var/obj/item/gun/projectile/shotgun/boltaction/enchanted/GUN = new
		GUN.guns_left = guns_left - 1
		user.drop_item()
		user.swap_hand()
		user.put_in_hands(GUN)
	else
		user.drop_item()
	spawn(0)
		throw_at(pick(oview(7,get_turf(user))),1,1)
	user.visible_message("<span class='warning'>[user] tosses aside the spent rifle!</span>")

// Automatic Shotguns//

/obj/item/gun/projectile/shotgun/automatic

/obj/item/gun/projectile/shotgun/automatic/shoot_live_shot(mob/living/user as mob|obj)
	..()
	pump(user)

/obj/item/gun/projectile/shotgun/automatic/combat
	name = "combat shotgun"
	desc = "A semi automatic shotgun with tactical furniture and a six-shell capacity underneath."
	icon_state = "cshotgun"
	origin_tech = "combat=6"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	w_class = WEIGHT_CLASS_HUGE

//Dual Feed Shotgun

/obj/item/gun/projectile/shotgun/automatic/dual_tube
	name = "cycler shotgun"
	desc = "An advanced shotgun with two separate magazine tubes, allowing you to quickly toggle between ammo types."
	icon_state = "cycler"
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube
	w_class = WEIGHT_CLASS_HUGE
	var/toggled = 0
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine

/obj/item/gun/projectile/shotgun/automatic/dual_tube/New()
	..()
	if(!alternate_magazine)
		alternate_magazine = new mag_type(src)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/attack_self(mob/living/user)
	if(!chambered && magazine.contents.len)
		pump()
	else
		toggle_tube(user)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/proc/toggle_tube(mob/living/user)
	var/current_mag = magazine
	var/alt_mag = alternate_magazine
	magazine = alt_mag
	alternate_magazine = current_mag
	toggled = !toggled
	if(toggled)
		to_chat(user, "You switch to tube B.")
	else
		to_chat(user, "You switch to tube A.")
	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, 1)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/AltClick(mob/living/user)
	if(user.incapacitated() || !Adjacent(user) || !istype(user))
		return
	pump()

// DOUBLE BARRELED SHOTGUN, IMPROVISED SHOTGUN, and CANE SHOTGUN are in revolver.dm
