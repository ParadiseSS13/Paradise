/obj/item/restraints/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 5
	materials = list(MAT_METAL=500)
	origin_tech = "engineering=3;combat=3"
	breakouttime = 600 //Deciseconds = 60s = 1 minutes
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	var/cuffsound = 'sound/weapons/handcuffs.ogg'
	var/trashtype = null //For disposable cuffs
	var/ignoresClumsy = FALSE

/obj/item/restraints/handcuffs/attack(mob/living/carbon/C, mob/user)
	if(!user.IsAdvancedToolUser())
		return

	if(!istype(C))
		return

	if(flags & NODROP)
		to_chat(user, "<span class='warning'>[src] is stuck to your hand!</span>")
		return

	if((CLUMSY in user.mutations) && prob(50) && (!ignoresClumsy))
		to_chat(user, "<span class='warning'>Uh... how do those things work?!</span>")
		apply_cuffs(user, user)
		return

	cuff(C, user)

/obj/item/restraints/handcuffs/proc/cuff(mob/living/carbon/C, mob/user, remove_src = TRUE)
	if(!istype(C)) // Shouldn't be able to cuff anything but carbons.
		return

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!(H.has_left_hand() || H.has_right_hand()))
			to_chat(user, "<span class='warning'>How do you suggest handcuffing someone with no hands?</span>")
			return

	if(!C.handcuffed)
		C.visible_message("<span class='danger'>[user] is trying to put [src.name] on [C]!</span>", \
							"<span class='userdanger'>[user] is trying to put [src.name] on [C]!</span>")

		playsound(loc, cuffsound, 30, 1, -2)
		if(do_mob(user, C, 50))
			apply_cuffs(C, user, remove_src)
			to_chat(user, "<span class='notice'>You handcuff [C].</span>")
			SSblackbox.record_feedback("tally", "handcuffs", 1, type)

			add_attack_logs(user, C, "Handcuffed ([src])")
		else
			to_chat(user, "<span class='warning'>You fail to handcuff [C].</span>")

/obj/item/restraints/handcuffs/proc/apply_cuffs(mob/living/carbon/target, mob/user, remove_src = TRUE)
	if(!target.handcuffed)
		if(remove_src)
			user.drop_item()
		if(trashtype)
			target.handcuffed = new trashtype(target)
			if(remove_src)
				qdel(src)
		else
			if(remove_src)
				loc = target
				target.handcuffed =  src
			else
				target.handcuffed = new type(loc)
		target.update_handcuffed()
		return

/obj/item/restraints/handcuffs/sinew
	name = "sinew restraints"
	desc = "A pair of restraints fashioned from long strands of flesh."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sinewcuff"
	item_state = "sinewcuff"
	breakouttime = 300 //Deciseconds = 30s
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/restraints/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_white"
	origin_tech = "engineering=2"
	materials = list(MAT_METAL=150, MAT_GLASS=75)
	breakouttime = 300 //Deciseconds = 30s
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/restraints/handcuffs/cable/red
	color = COLOR_RED

/obj/item/restraints/handcuffs/cable/yellow
	color = COLOR_YELLOW

/obj/item/restraints/handcuffs/cable/blue
	color = COLOR_BLUE

/obj/item/restraints/handcuffs/cable/green
	color = COLOR_GREEN

/obj/item/restraints/handcuffs/cable/pink
	color = COLOR_PINK

/obj/item/restraints/handcuffs/cable/orange
	color = COLOR_ORANGE

/obj/item/restraints/handcuffs/cable/cyan
	color = COLOR_CYAN

/obj/item/restraints/handcuffs/cable/white
	color = COLOR_WHITE

/obj/item/restraints/handcuffs/cable/random/New()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	..()

/obj/item/restraints/handcuffs/cable/proc/cable_color(colorC)
	if(!colorC)
		color = COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = COLOR_ORANGE
	else
		color = colorC

/obj/item/restraints/handcuffs/cable/proc/color_rainbow()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	return color

/obj/item/restraints/handcuffs/alien
	icon_state = "handcuffAlien"

/obj/item/restraints/handcuffs/pinkcuffs
	name = "fluffy pink handcuffs"
	desc = "Use this to keep prisoners in line. Or you know, your significant other."
	icon_state = "pinkcuffs"

/obj/item/restraints/handcuffs/cable/attackby(var/obj/item/I, mob/user as mob, params)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(R.use(1))
			var/obj/item/wirerod/W = new /obj/item/wirerod
			if(!remove_item_from_storage(user))
				user.unEquip(src)
			user.put_in_hands(W)
			to_chat(user, "<span class='notice'>You wrap the cable restraint around the top of the rod.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You need one rod to make a wired rod!</span>")
	else if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.get_amount() < 6)
			to_chat(user, "<span class='warning'>You need at least six metal sheets to make good enough weights!</span>")
			return
		to_chat(user, "<span class='notice'>You begin to apply [I] to [src]...</span>")
		if(do_after(user, 35 * M.toolspeed, target = src) && M.use(6))
			var/obj/item/restraints/legcuffs/bola/S = new /obj/item/restraints/legcuffs/bola
			user.put_in_hands(S)
			to_chat(user, "<span class='notice'>You make some weights out of [I] and tie them to [src].</span>")
			if(!remove_item_from_storage(user))
				user.unEquip(src)
			qdel(src)
	else if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		cable_color(C.colourName)

/obj/item/restraints/handcuffs/cable/zipties
	name = "zipties"
	desc = "Plastic, disposable zipties that can be used to restrain temporarily but are destroyed after use."
	icon_state = "cuff_white"
	breakouttime = 450 //Deciseconds = 45s
	materials = list()
	trashtype = /obj/item/restraints/handcuffs/cable/zipties/used

/obj/item/restraints/handcuffs/cable/zipties/cyborg/attack(mob/living/carbon/C, mob/user)
	if(isrobot(user))
		cuff(C, user, FALSE)

/obj/item/restraints/handcuffs/cable/zipties/used
	desc = "A pair of broken zipties."
	icon_state = "cuff_white_used"

/obj/item/restraints/handcuffs/cable/zipties/used/attack()
	return
