#define SPEEDLOADER 0
#define FROM_BOX 1
#define MAGAZINE 2

/obj/item/weapon/gun/projectile
	desc = "Now comes in flavors like GUN. Uses 10mm ammo, for some reason"
	name = "projectile gun"
	icon_state = "pistol"
	origin_tech = "combat=2;materials=2"
	w_class = 3.0
	m_amt = 1000
//	recoil = 1
	var/mag_type = "/obj/item/ammo_box/magazine/m10mm" //Removes the need for max_ammo and caliber info
	var/obj/item/ammo_box/magazine/magazine
//	var/obj/item/ammo_casing/chambered = null // The round (not bullet) that is in the chamber.



/obj/item/weapon/gun/projectile/New()
	..()
	magazine = new mag_type(src)
	chamber_round()
	update_icon()
	return


/obj/item/weapon/gun/projectile/process_chambered(var/eject_casing = 1, var/empty_chamber = 1)
//	if(in_chamber)
//		return 1

	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		return 0
	if(eject_casing)
		AC.loc = get_turf(src) //Eject casing onto ground.
		AC.SpinAnimation(10, 1) //next gen special effects
	if(empty_chamber)
		chambered = null
	chamber_round()
	if(AC.BB)
		if(AC.reagents && AC.BB.reagents)
			var/datum/reagents/casting_reagents = AC.reagents
			casting_reagents.trans_to(AC.BB, casting_reagents.total_volume) //For chemical darts/bullets
			qdel(casting_reagents)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.loc = src //Set projectile loc to gun.
		AC.update_icon()
		return 1
	return 0


/obj/item/weapon/gun/projectile/proc/chamber_round()
	if (chambered || !magazine)
		return
	else if (magazine.ammo_count())
		chambered = magazine.get_round()
		chambered.loc = src
	return


/obj/item/weapon/gun/projectile/attackby(var/obj/item/A as obj, mob/user as mob, params)
	..()
	if (istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if (!magazine && istype(AM, text2path(mag_type)))
			user.remove_from_mob(AM)
			magazine = AM
			magazine.loc = src
			user << "<span class='notice'>You load a new magazine into \the [src].</span>"
			chamber_round()
			A.update_icon()
			update_icon()
			return 1
		else if (magazine)
			user << "<span class='notice'>There's already a magazine in \the [src].</span>"
	if(istype(A, /obj/item/weapon/suppressor))
		var/obj/item/weapon/suppressor/S = A
		if(can_suppress)
			if(!silenced)
				if(user.l_hand != src && user.r_hand != src)
					user << "<span class='notice'>You'll need [src] in your hands to do that.</span>"
					return
				user.drop_item()
				user << "<span class='notice'>You screw [S] onto [src].</span>"
				silenced = A
				S.oldsound = fire_sound
				S.initial_w_class = w_class
				fire_sound = 'sound/weapons/Gunshot_silenced.ogg'
				w_class = 3 //so pistols do not fit in pockets when suppressed
				A.loc = src
				update_icon()
				return
			else
				user << "<span class='warning'>[src] already has a suppressor.</span>"
				return
		else
			user << "<span class='warning'>You can't seem to figure out how to fit [S] on [src].</span>"
			return
	return 0

/obj/item/weapon/gun/projectile/attack_hand(mob/user as mob)
	if(loc == user)
		if(silenced)
			var/obj/item/weapon/suppressor/S = silenced
			if(user.l_hand != src && user.r_hand != src)
				..()
				return
			user << "<span class='notice'>You unscrew [silenced] from [src].</span>"
			user.put_in_hands(silenced)
			fire_sound = S.oldsound
			w_class = S.initial_w_class
			silenced = 0
			update_icon()
			return
	..()

/obj/item/weapon/gun/projectile/attack_self(mob/living/user as mob)
	if(magazine)
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		user << "<span class='notice'>You pull the magazine out of \the [src]!</span>"
	else
		user << "<span class='notice'>There's no magazine in \the [src].</span>"
	update_icon()
	return

/obj/item/weapon/gun/projectile/examine()
	..()
	usr << "Has [get_ammo()] round\s remaining."
	return

/obj/item/weapon/gun/projectile/proc/get_ammo(var/countchambered = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count()
	return boolets

/obj/item/weapon/suppressor
	name = "suppressor"
	desc = "A universal syndicate small-arms suppressor for maximum espionage."
	icon = 'icons/obj/gun.dmi'
	icon_state = "suppressor"
	w_class = 2
	var/oldsound = null
	var/initial_w_class = null