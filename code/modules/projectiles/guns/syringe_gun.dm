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

/obj/item/gun/syringe/process_chamber()
	if(!length(syringes) || chambered.BB)
		return

	var/obj/item/reagent_containers/syringe/S = syringes[1]
	if(!S)
		return

	chambered.BB = new S.projectile_type(src)
	S.reagents.trans_to(chambered.BB, S.reagents.total_volume)
	chambered.BB.name = S.name

	syringes.Remove(S)
	qdel(S)

/obj/item/gun/syringe/afterattack(atom/target, mob/living/user, flag, params)
	if(target == loc)
		return
	..()

/obj/item/gun/syringe/examine(mob/user)
	. = ..()
	var/num_syringes = syringes.len + (chambered.BB ? 1 : 0)
	. += "<span class='notice'>Can hold [max_syringes] syringe\s. Has [num_syringes] syringe\s remaining.</span>"

/obj/item/gun/syringe/attack_self(mob/living/user)
	if(!length(syringes) && !chambered.BB)
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		return FALSE

	var/obj/item/reagent_containers/syringe/S
	if(chambered.BB) // Remove the chambered syringe first
		S = new()
		chambered.BB.reagents.trans_to(S, chambered.BB.reagents.total_volume)
		qdel(chambered.BB)
		chambered.BB = null
	else
		S = syringes[length(syringes)]

	user.put_in_hands(S)
	syringes.Remove(S)
	process_chamber()
	to_chat(user, "<span class='notice'>You unload [S] from \the [src]!</span>")
	return TRUE

/obj/item/gun/syringe/attackby(obj/item/A, mob/user, params, show_msg = TRUE)
	if(istype(A, /obj/item/reagent_containers/syringe))
		var/in_clip = length(syringes) + (chambered.BB ? 1 : 0)
		if(in_clip < max_syringes)
			if(!user.unEquip(A))
				return
			to_chat(user, "<span class='notice'>You load [A] into \the [src]!</span>")
			syringes.Add(A)
			A.loc = src
			process_chamber() // Chamber the syringe if none is already
			return TRUE
		else
			to_chat(user, "<span class='notice'>[src] cannot hold more syringes.</span>")
	else
		return ..()

/obj/item/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to six syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 6

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

/obj/item/gun/syringe/blowgun
	name = "blowgun"
	desc = "Fire syringes at a short distance."
	icon_state = "blowgun"
	item_state = "blowgun"
	fire_sound = 'sound/items/blowgunproj.ogg'

/obj/item/gun/syringe/blowgun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	visible_message("<span class='danger'>[user] starts aiming with a blowgun!</span>")
	if(do_after(user, 15, target = src))
		user.adjustStaminaLoss(20)
		user.adjustOxyLoss(20)
		..()

