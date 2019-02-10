/obj/item/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, used to incapacitate unruly patients from a distance."
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=2;biotech=3"
	throw_speed = 3
	throw_range = 7
	force = 4
	materials = list(MAT_METAL=2000)
	clumsy_check = 0
	fire_sound = 'sound/items/syringeproj.ogg'
	var/list/syringes = list()
	var/max_syringes = 1

/obj/item/gun/syringe/New()
	..()
	chambered = new /obj/item/ammo_casing/syringegun(src)

/obj/item/gun/syringe/newshot()
	if(!syringes.len)
		return

	var/obj/item/reagent_containers/syringe/S = syringes[1]

	if(!S)
		return

	chambered.BB = new S.projectile_type (src)

	S.reagents.trans_to(chambered.BB, S.reagents.total_volume)
	chambered.BB.name = S.name
	syringes.Remove(S)

	qdel(S)
	return

/obj/item/gun/syringe/process_chamber()
	return

/obj/item/gun/syringe/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, params)
	if(target == loc)
		return
	newshot()
	..()

/obj/item/gun/syringe/examine(mob/user)
	..()
	to_chat(user, "Can hold [max_syringes] syringe\s. Has [syringes.len] syringe\s remaining.")

/obj/item/gun/syringe/attack_self(mob/living/user as mob)
	if(!syringes.len)
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		return 0

	var/obj/item/reagent_containers/syringe/S = syringes[syringes.len]

	if(!S)
		return 0
	S.loc = user.loc

	syringes.Remove(S)
	to_chat(user, "<span class='notice'>You unload [S] from \the [src]!</span>")

	return 1

/obj/item/gun/syringe/attackby(obj/item/A, mob/user, params, show_msg = 1)
	if(istype(A, /obj/item/reagent_containers/syringe))
		if(syringes.len < max_syringes)
			if(!user.unEquip(A))
				return
			to_chat(user, "<span class='notice'>You load [A] into [src]!</span>")
			syringes.Add(A)
			A.loc = src
			return TRUE
		else
			to_chat(user, "<span class='notice'>[src] cannot hold more syringes.</span>")
	else if(istype(A, /obj/item/ammo_box/syringe))
		if(syringes.len < max_syringes)
			var/obj/item/ammo_box/syringe/L = A
			var/obj/item/reagent_containers/syringe/S = L.get_round()
			if(!S)
				to_chat(user, "<span class='notice'>[A] is out of syringes.</span>")
				return FALSE
			to_chat(user, "<span class='notice'>You load a syringe into [src]!</span>")
			syringes.Add(S)
			S.loc = src
			return TRUE
		else
			to_chat(user, "<span class='notice'>[src] cannot hold more syringes.</span>")
	return FALSE

/obj/item/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to six syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 6

/obj/item/gun/syringe/combat
	name = "combat syringe gun"
	desc = "A combat syringe gun that can hold up to twelve syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 12

/obj/item/gun/syringe/cyborg
	name = "cyborg syringe gun"
	desc = "A syringe gun that fires ether syringes in order to put unruly patients to sleep. Slowly reloads overtime, can be accelerated at a charging station."
	icon_state = "rapidsyringegun"
	max_syringes = 6
	var/syringe_type = /obj/item/reagent_containers/syringe/ether

/obj/item/gun/syringe/cyborg/New()
	..()
	recharge_syringe(max_syringes)

/obj/item/gun/syringe/cyborg/attack_self(mob/living/user as mob)

/obj/item/gun/syringe/cyborg/proc/recharge_syringe(var/amount = 1)
	for(var/i = 0, i < amount, i++)
		if(syringes.len < max_syringes)
			var/S = new syringe_type(src)
			syringes.Add(S)
		else
			return

/obj/item/gun/syringe/cyborg/syndicate
	desc = "A combat syringe gun that fires non-lethal bioterror syringes. Confuses, mutes, and knocks out the target. Slowly reloads overtime, can be accelerated at a charging station."
	max_syringes = 12
	syringe_type = /obj/item/reagent_containers/syringe/bioterror

/obj/item/gun/syringe/syndicate
	name = "dart pistol"
	desc = "A small spring-loaded sidearm that functions identically to a syringe gun."
	icon_state = "syringe_pistol"
	item_state = "gun" //Smaller inhand
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=2;syndicate=2;biotech=3"
	force = 2 //Also very weak because it's smaller
	suppressed = 1 //Softer fire sound
	can_unsuppress = 0 //Permanently silenced