/obj/item/weapon/restraints/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	w_class = 2.0
	throw_speed = 2
	throw_range = 5
	materials = list(MAT_METAL=500)
	origin_tech = "materials=1"
	breakouttime = 600 //Deciseconds = 60s = 1 minutes
	var/cuffsound = 'sound/weapons/handcuffs.ogg'
	var/trashtype = null //For disposable cuffs

/obj/item/weapon/restraints/handcuffs/attack(mob/living/carbon/C, mob/user)
	if(!user.IsAdvancedToolUser())
		return

	if(CLUMSY in user.mutations && prob(50))
		to_chat(user, "<span class='warning'>Uh... how do those things work?!</span>")
		apply_cuffs(user,user)

	if(!C.handcuffed)
		C.visible_message("<span class='danger'>[user] is trying to put [src.name] on [C]!</span>", \
							"<span class='userdanger'>[user] is trying to put [src.name] on [C]!</span>")

		playsound(loc, cuffsound, 30, 1, -2)
		if(do_mob(user, C, 30))
			apply_cuffs(C,user)
			to_chat(user, "<span class='notice'>You handcuff [C].</span>")
			if(istype(src, /obj/item/weapon/restraints/handcuffs/cable))
				feedback_add_details("handcuffs","C")
			else
				feedback_add_details("handcuffs","H")

			add_logs(C, user, "handcuffed", src)
		else
			to_chat(user, "<span class='warning'>You fail to handcuff [C].</span>")

/obj/item/weapon/restraints/handcuffs/proc/apply_cuffs(mob/living/carbon/target, mob/user)
	if(!target.handcuffed)
		user.drop_item()
		if(trashtype)
			target.handcuffed = new trashtype(target)
			qdel(src)
		else
			loc = target
			target.handcuffed = src
		target.update_handcuffed()
		return

/obj/item/weapon/restraints/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_white"
	item_state = "coil_red"
	breakouttime = 300 //Deciseconds = 30s
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/weapon/restraints/handcuffs/cable/red
	color = COLOR_RED

/obj/item/weapon/restraints/handcuffs/cable/yellow
	color = COLOR_YELLOW

/obj/item/weapon/restraints/handcuffs/cable/blue
	color = COLOR_BLUE

/obj/item/weapon/restraints/handcuffs/cable/green
	color = COLOR_GREEN

/obj/item/weapon/restraints/handcuffs/cable/pink
	color = COLOR_PINK

/obj/item/weapon/restraints/handcuffs/cable/orange
	color = COLOR_ORANGE

/obj/item/weapon/restraints/handcuffs/cable/cyan
	color = COLOR_CYAN

/obj/item/weapon/restraints/handcuffs/cable/white
	color = COLOR_WHITE

/obj/item/weapon/restraints/handcuffs/pinkcuffs
	name = "fluffy pink handcuffs"
	desc = "Use this to keep prisoners in line. Or you know, your significant other."
	icon_state = "pinkcuffs"

/obj/item/weapon/restraints/handcuffs/cable/attackby(var/obj/item/I, mob/user as mob, params)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if (R.use(1))
			var/obj/item/weapon/wirerod/W = new /obj/item/weapon/wirerod
			if(!remove_item_from_storage(user))
				user.unEquip(src)
			user.put_in_hands(W)
			to_chat(user, "<span class='notice'>You wrap the cable restraint around the top of the rod.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You need one rod to make a wired rod.</span>")
			return

/obj/item/weapon/restraints/handcuffs/cable/zipties
	name = "zipties"
	desc = "Plastic, disposable zipties that can be used to restrain temporarily but are destroyed after use."
	icon_state = "cuff_white"
	breakouttime = 450 //Deciseconds = 45s
	trashtype = /obj/item/weapon/restraints/handcuffs/cable/zipties/used

/obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg/attack(mob/living/carbon/C, mob/user)
	if(isrobot(user))
		if(!C.handcuffed)
			playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
			C.visible_message("<span class='danger'>[user] is trying to put zipties on [C]!</span>", \
								"<span class='userdanger'>[user] is trying to put zipties on [C]!</span>")
			if(do_mob(user, C, 30))
				if(!C.handcuffed)
					C.handcuffed = new /obj/item/weapon/restraints/handcuffs/cable/zipties/used(C)
					C.update_handcuffed()
					to_chat(user, "<span class='notice'>You handcuff [C].</span>")
					add_logs(C, user, "ziptie-cuffed")
			else
				to_chat(user, "<span class='warning'>You fail to handcuff [C].</span>")

/obj/item/weapon/restraints/handcuffs/cable/zipties/used
	desc = "A pair of broken zipties."
	icon_state = "cuff_white_used"

/obj/item/weapon/restraints/handcuffs/cable/zipties/used/attack()
	return
