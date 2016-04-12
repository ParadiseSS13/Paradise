/obj/item/weapon/gun/projectile/revolver
	name = "\improper .357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo."
	icon_state = "revolver"
	mag_type = "/obj/item/ammo_box/magazine/internal/cylinder"

/obj/item/weapon/gun/projectile/revolver/chamber_round()
	if (chambered || !magazine)
		return
	else if (magazine.ammo_count())
		chambered = magazine.get_round(1)
	return

/obj/item/weapon/gun/projectile/revolver/process_chambered()
	return ..(0, 1)

/obj/item/weapon/gun/projectile/revolver/attackby(var/obj/item/A as obj, mob/user as mob, params)
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
		if(magazine.give_round(AC))
			user.drop_item()
			AC.loc = src
			num_loaded++
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		A.update_icon()
		update_icon()
		chamber_round()

/obj/item/weapon/gun/projectile/revolver/attack_self(mob/living/user as mob)
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.SpinAnimation(10, 1)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		to_chat(user, "<span class = 'notice'>You unload [num_unloaded] shell\s from [src]!</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")

/obj/item/weapon/gun/projectile/revolver/get_ammo(var/countchambered = 0, var/countempties = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/weapon/gun/projectile/revolver/examine(mob/user)
	..(user)
	to_chat(user, "[get_ammo(0,0)] of those are live rounds.")

/obj/item/weapon/gun/projectile/revolver/verb/spin_revolver()
	set name = "Spin cylinder"
	set desc = "Fun when you're bored out of your skull."
	set category = "Object"

	usr.visible_message("<span class='warning'>[usr] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
	playsound(src.loc, 'sound/weapons/revolver_spin.ogg', 100, 1)
	Spin()

/obj/item/weapon/gun/projectile/revolver/proc/Spin()
	chambered = null
	var/random = rand(1, magazine.max_ammo)
	if(random <= get_ammo(0,0))
		chamber_round()
	update_icon()

/obj/item/weapon/gun/projectile/revolver/capgun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up."
	origin_tech = "combat=1;materials=1"
	mag_type = "/obj/item/ammo_box/magazine/internal/cylinder/cap"

/obj/item/weapon/gun/projectile/revolver/detective
	desc = "A cheap Martian knock-off of a classic law enforcement firearm. Uses .38-special rounds."
	name = "\improper .38 Mars Special"
	icon_state = "detective"
	origin_tech = "combat=2;materials=2"
	mag_type = "/obj/item/ammo_box/magazine/internal/cylinder/rev38"


/obj/item/weapon/gun/projectile/revolver/detective/special_check(var/mob/living/carbon/human/M)
	if(!ghettomodded)
		return 1
	if(prob(70 - (magazine.ammo_count() * 10)))	//minimum probability of 10, maximum of 60
		to_chat(M, "<span class='danger'>[src] blows up in your face!</span>")
		M.take_organ_damage(0,20)
		M.drop_item()
		qdel(src)
		return 0
	return 1

/obj/item/weapon/gun/projectile/revolver/detective/verb/rename_gun()
	set name = "Name Gun"
	set category = "Object"
	set desc = "Click to rename your gun."

	var/mob/M = usr
	var/input = stripped_input(M,"What do you want to name the gun?", ,"", MAX_NAME_LEN)

	if(src && input && !M.stat && in_range(M,src))
		name = input
		to_chat(M, "You name the gun [input]. Say hello to your new friend.")
		return 1

/obj/item/weapon/gun/projectile/revolver/detective/verb/reskin_gun()
	set name = "Reskin gun"
	set category = "Object"
	set desc = "Click to reskin your gun."

	var/mob/M = usr
	var/list/options = list()
	options["The Original"] = "detective"
	options["Leopard Spots"] = "detective_leopard"
	options["Black Panther"] = "detective_panther"
	options["Gold Trim"] = "detective_gold"
	options["The Peacemaker"] = "detective_peacemaker"
	var/choice = input(M,"What do you want to skin the gun to?","Reskin Gun") in options

	if(src && choice && !M.stat && in_range(M,src))
		icon_state = options[choice]
		to_chat(M, "Your gun is now skinned as [choice]. Say hello to your new friend.")
		return 1

/obj/item/weapon/gun/projectile/revolver/detective/attackby(var/obj/item/A as obj, mob/user as mob, params)
	..()
	if(istype(A, /obj/item/weapon/screwdriver) || istype(A, /obj/item/weapon/conversion_kit))
		if(magazine.caliber == "38")
			to_chat(user, "<span class='notice'>You begin to reinforce the barrel of [src].</span>")
			if(magazine.ammo_count())
				afterattack(user, user)	//you know the drill
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
				return
			if(do_after(user, 30, target = src))
				if(magazine.ammo_count())
					to_chat(user, "<span class='notice'>You can't modify it!</span>")
					return
				if (istype(A, /obj/item/weapon/conversion_kit))
					ghettomodded = 0
				else
					ghettomodded = 1
				magazine.caliber = "357"
				desc = "[initial(desc)] The barrel and chamber assembly seems to have been modified."
				to_chat(user, "<span class='warning'>You reinforce the barrel of [src]! Now it will fire .357 rounds.</span>")
		else
			to_chat(user, "<span class='notice'>You begin to revert the modifications to [src].</span>")
			if(magazine.ammo_count())
				afterattack(user, user)	//and again
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
				return
			if(do_after(user, 30, target = src))
				if(magazine.ammo_count())
					to_chat(user, "<span class='notice'>You can't modify it!</span>")
					return
				ghettomodded = 0
				magazine.caliber = "38"
				desc = initial(desc)
				to_chat(user, "<span class='warning'>You remove the modifications on [src]! Now it will fire .38 rounds.</span>")




/obj/item/weapon/gun/projectile/revolver/mateba
	name = "\improper Unica 6 auto-revolver"
	desc = "A retro high-powered autorevolver typically used by officers of the New Russia military. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"
	origin_tech = "combat=2;materials=2"

// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/weapon/gun/projectile/revolver/russian
	name = "\improper Russian Revolver"
	desc = "A Russian-made revolver for drinking games. Uses .357 ammo, and has a mechanism that spins the chamber before each trigger pull."
	origin_tech = "combat=2;materials=2"
	mag_type = "/obj/item/ammo_box/magazine/internal/cylinder/rus357"


/obj/item/weapon/gun/projectile/revolver/russian/New()
	..()
	Spin()

/obj/item/weapon/gun/projectile/revolver/russian/attack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj)

	if(!chambered && target == user)
		user.visible_message("\red *click*", "\red *click*")
		return

	if(isliving(target) && isliving(user))
		if(target == user)
			var/obj/item/organ/external/affecting = user.zone_sel.selecting
			if(affecting == "head")
				var/obj/item/ammo_casing/AC = chambered
				if(!process_chambered())
					user.visible_message("\red *click*", "\red *click*")
					return
				if(!in_chamber)
					return
				var/obj/item/projectile/P = new AC.projectile_type
				playsound(user, fire_sound, 50, 1)
				user.visible_message("<span class='danger'>[user.name] fires [src] at \his head!</span>", "<span class='danger'>You fire [src] at your head!</span>", "You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
				if(!P.nodamage)
					user.apply_damage(300, BRUTE, affecting, sharp=1) // You are dead, dead, dead.
				return

	..()

