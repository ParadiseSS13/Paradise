/obj/item/weapon/gun/projectile/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	item_state = "shotgun"
	w_class = 4.0
	force = 10
	flags = CONDUCT
	slot_flags = SLOT_BACK
	origin_tech = "combat=4;materials=2"
	var/recentpump = 0 // to prevent spammage
	mag_type = "/obj/item/ammo_box/magazine/internal/shot"

/obj/item/weapon/gun/projectile/shotgun/attackby(var/obj/item/A as obj, mob/user as mob, params)
	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_box))
		var/obj/item/ammo_box/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			var/didload = magazine.give_round(AC)
			if(didload)
				AM.stored_ammo -= AC
				num_loaded++
			if(!didload || !magazine.multiload)
				break
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(magazine && magazine.give_round(AC))
			user.drop_item()
			AC.loc = src
			num_loaded++
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		A.update_icon()
		update_icon()


/obj/item/weapon/gun/projectile/shotgun/process_chambered()
	return ..(0, 0)

/obj/item/weapon/gun/projectile/shotgun/chamber_round()
	return

/obj/item/weapon/gun/projectile/shotgun/attack_self(mob/living/user as mob)
	if(recentpump)	return
	pump(user)
	recentpump = 1
	spawn(10)
		recentpump = 0
	return


/obj/item/weapon/gun/projectile/shotgun/proc/pump(mob/M as mob)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	pump_unload(M)
	pump_reload(M)
	update_icon() //I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/shotgun/proc/pump_unload(mob/M)
	if(chambered)//We have a shell in the chamber
		chambered.loc = get_turf(src)//Eject casing
		chambered.SpinAnimation(5, 1)
		chambered = null
		if(in_chamber)
			in_chamber = null

/obj/item/weapon/gun/projectile/shotgun/proc/pump_reload(mob/M)
	if(!magazine.ammo_count())	return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC

/obj/item/weapon/gun/projectile/shotgun/examine(mob/user)
	..(user)
	if (chambered)
		to_chat(user, "A [chambered.BB ? "live" : "spent"] one is in the chamber.")

/obj/item/weapon/gun/projectile/shotgun/isHandgun() //You cannot, in fact, holster a shotgun.
	return 0

// RIOT SHOTGUN //

/obj/item/weapon/gun/projectile/shotgun/riot //for spawn in the armory
	name = "riot shotgun"
	desc = "A sturdy shotgun with a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	mag_type = "/obj/item/ammo_box/magazine/internal/shotriot"
	sawn_desc = "Come with me if you want to live."

/obj/item/weapon/gun/projectile/shotgun/riot/attackby(var/obj/item/A as obj, mob/user as mob, params)
	..()
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/gun/energy/plasmacutter))
		sawoff(user)


///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

/obj/item/weapon/gun/projectile/shotgun/boltaction
	name = "\improper Mosin Nagant"
	desc = "This piece of junk looks like something that could have been used 700 years ago."
	icon_state = "moistnugget"
	item_state = "moistnugget"
	slot_flags = 0 //no SLOT_BACK sprite, alas
	mag_type = "/obj/item/ammo_box/magazine/internal/boltaction"
	var/bolt_open = 0

/obj/item/weapon/gun/projectile/shotgun/boltaction/pump(mob/M)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	if(bolt_open)
		pump_reload(M)
	else
		pump_unload(M)
	bolt_open = !bolt_open
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/shotgun/boltaction/attackby(var/obj/item/A as obj, mob/user as mob)
	if(!bolt_open)
		to_chat(user, "<span class='notice'>The bolt is closed!</span>")
		return
	. = ..()

/obj/item/weapon/gun/projectile/shotgun/boltaction/examine(mob/user)
	..(user)
	to_chat(user, "The bolt is [bolt_open ? "open" : "closed"].")

/obj/item/weapon/gun/projectile/shotgun/boltaction/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	var/guns_left = 30
	mag_type = "/obj/item/ammo_box/magazine/internal/boltaction/enchanted"

/obj/item/weapon/gun/projectile/shotgun/boltaction/enchanted/New()
	..()
	bolt_open = 1
	pump()

/obj/item/weapon/gun/projectile/shotgun/boltaction/enchanted/dropped()
	guns_left = 0

/obj/item/weapon/gun/projectile/shotgun/boltaction/enchanted/Fire(atom/target as mob|obj|turf|area, mob/living/carbon/user as mob|obj, params, reflex = 0)
	..()
	if(guns_left)
		var/obj/item/weapon/gun/projectile/shotgun/boltaction/enchanted/GUN = new
		GUN.guns_left = src.guns_left - 1
		user.drop_item()
		user.swap_hand()
		user.put_in_hands(GUN)
	else
		user.drop_item()
	spawn(0)
		throw_at(pick(oview(7,get_turf(user))),1,1)
	user.visible_message("<span class='warning'>[user] tosses aside the spent rifle!</span>")


/obj/item/ammo_box/magazine/internal/boltaction/enchanted
	max_ammo =1

/////////////////////////////
// DOUBLE BARRELED SHOTGUN //
/////////////////////////////

/obj/item/weapon/gun/projectile/revolver/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	w_class = 4.0
	force = 10
	flags = CONDUCT
	slot_flags = SLOT_BACK
	origin_tech = "combat=3;materials=1"
	mag_type = "/obj/item/ammo_box/magazine/internal/cylinder/dualshot"
	sawn_desc = "Omar's coming!"

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attackby(var/obj/item/A as obj, mob/user as mob, params)
	..()
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/gun/energy/plasmacutter))
		sawoff(user)

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attack_self(mob/living/user as mob)
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		to_chat(user, "<span class = 'notice'>You break open \the [src] and unload [num_unloaded] shell\s.</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")

/obj/item/weapon/gun/projectile/revolver/doublebarrel/isHandgun() //contrary to popular opinion, double barrels are not, shockingly, handguns
	return 0

// IMPROVISED SHOTGUN //

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Essentially a tube that aims shotgun shells."
	icon_state = "ishotgun"
	item_state = "shotgun"
	w_class = 4.0
	force = 10
	slot_flags = null
	origin_tech = "combat=2;materials=2"
	mag_type = "/obj/item/ammo_box/magazine/internal/cylinder/improvised"
	sawn_desc = "I'm just here for the gasoline."

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/attackby(var/obj/item/A as obj, mob/user as mob, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_state)
		var/obj/item/stack/cable_coil/C = A
		if(C.use(10))
			slot_flags = SLOT_BACK
			icon_state = "ishotgunsling"
			to_chat(user, "<span class='notice'>You tie the lengths of cable to the shotgun, making a sling.</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>You need at least ten lengths of cable if you want to make a sling.</span>")
			return

// Sawing guns related procs //

/obj/item/weapon/gun/projectile/proc/blow_up(mob/user as mob)
	if(get_ammo())
		afterattack(user, user)
		playsound(user, fire_sound, 50, 1)
		user.visible_message("<span class='danger'>The [src] goes off!</span>", "<span class='danger'>The [src] goes off in your face!</span>")
		return

/obj/item/weapon/gun/projectile/proc/sawoff(mob/user as mob)
	if(sawn_state == SAWN_OFF)
		to_chat(user, "<span class='notice'>\The [src] is already shortened.</span>")
		return

	if(sawn_state == SAWN_SAWING)
		return

	user.visible_message("<span class='notice'>[user] begins to shorten \the [src].</span>", "<span class='notice'>You begin to shorten \the [src].</span>")

	//if there's any live ammo inside the gun, makes it go off
	if(blow_up(user))
		user.visible_message("<span class='danger'>\The [src] goes off!</span>", "<span class='danger'>\The [src] goes off in your face!</span>")
		return

	sawn_state = SAWN_SAWING

	if(do_after(user, 30, target = src))
		user.visible_message("<span class='warning'>[user] shortens \the [src]!</span>", "<span class='warning'>You shorten \the [src]!</span>")
		name = "sawn-off [src.name]"
		desc = sawn_desc
		icon_state = "[icon_state]-sawn"
		w_class = 3.0
		item_state = "gun"
		slot_flags &= ~SLOT_BACK	//you can't sling it on your back
		slot_flags |= SLOT_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
		sawn_state = SAWN_OFF
		update_icon()
		return
	else
		sawn_state = SAWN_INTACT

/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog
	name = "\improper 'Bulldog' Shotgun"
	desc = "A compact, mag-fed semi-automatic shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 8-round drum magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = 3.0
	origin_tech = "combat=5;materials=4;syndicate=6"
	mag_type = "/obj/item/ammo_box/magazine/m12g"
	fire_sound = 'sound/weapons/Gunshot4.ogg'
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	action_button_name = null

/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/New()
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/proc/update_magazine()
	if(magazine)
		overlays.Cut()
		overlays += "[magazine.icon_state]"
		return

/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/update_icon()
	overlays.Cut()
	update_magazine()
	icon_state = "bulldog[chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	empty_alarm()
	return

/obj/item/weapon/gun/projectile/shotgun/automatic/Fire(mob/living/user as mob|obj)
	..()
	pump(user)

// COMBAT SHOTGUN //

/obj/item/weapon/gun/projectile/shotgun/automatic/combat
	name = "combat shotgun"
	desc = "A semi automatic shotgun with tactical furniture and a six-shell capacity underneath."
	icon_state = "cshotgun"
	origin_tech = "combat=5;materials=2"
	mag_type = "/obj/item/ammo_box/magazine/internal/shotcom"
	w_class = 5

//caneshotgun

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cane"
	item_state = "stick"
	sawn_state = SAWN_OFF
	w_class = 2
	force = 10
	can_unsuppress = 0
	slot_flags = null
	origin_tech = "" // NO GIVAWAYS
	mag_type = "/obj/item/ammo_box/magazine/internal/cylinder/improvised"
	sawn_desc = "I'm sorry, but why did you saw your cane in the first place?"
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")
	fire_sound = 'sound/weapons/Gunshot_silenced.ogg'
	silenced = 1
	needs_permit = 0 //its just a cane beepsky.....

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/cane/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil))
		return

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/cane/examine(mob/user) // HAD TO REPEAT EXAMINE CODE BECAUSE GUN CODE DOESNT STEALTH
	var/f_name = "\a [src]."
	if(src.blood_DNA && !istype(src, /obj/effect/decal))
		if(gender == PLURAL)
			f_name = "some "
		else
			f_name = "a "
		f_name += "<span class='danger'>blood-stained</span> [name]!"

	to_chat(user, "\icon[src] That's [f_name]")

	if(desc)
		to_chat(user, desc)