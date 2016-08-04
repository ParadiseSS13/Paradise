/obj/structure/stool/bed/chair	//YES, chairs are a type of bed, which are a type of stool. This works, believe me.	-Pete
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair"
	buckle_lying = 0 //you sit in a chair, not lay
	burn_state = FIRE_PROOF

	var/propelled = 0 // Check for fire-extinguisher-driven chairs

/obj/structure/stool/bed/chair/New()
	..()
	spawn(3)	//sorry. i don't think there's a better way to do this.
		handle_rotation()
	return

/obj/structure/stool/bed/chair/Move(atom/newloc, direct)
	..()
	handle_rotation()

/obj/structure/stool/bed/chair/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		if(!SK.status)
			to_chat(user, "<span class='notice'>[SK] is not ready to be attached!</span>")
			return
		user.drop_item()
		var/obj/structure/stool/bed/chair/e_chair/E = new /obj/structure/stool/bed/chair/e_chair(src.loc)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		E.dir = dir
		E.part = SK
		SK.loc = E
		SK.master = E
		qdel(src)

/obj/structure/stool/bed/chair/attack_tk(mob/user as mob)
	if(buckled_mob)
		..()
	else
		rotate()
	return

/obj/structure/stool/bed/chair/handle_rotation()	//making this into a seperate proc so office chairs can call it on Move()
	if(src.dir == NORTH)
		src.layer = FLY_LAYER
	else
		src.layer = OBJ_LAYER
	if(buckled_mob)
		buckled_mob.dir = dir

/obj/structure/stool/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(config.ghost_interaction)
		src.dir = turn(src.dir, 90)
		handle_rotation()
		return
	else
		if(!usr || !isturf(usr.loc))
			return
		if(usr.stat || usr.restrained())
			return

		src.dir = turn(src.dir, 90)
		handle_rotation()
		return

/obj/structure/stool/bed/chair/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	rotate()

// Chair types
/obj/structure/stool/bed/chair/wood
	burn_state = FLAMMABLE
	burntime = 20
	// TODO:  Special ash subtype that looks like charred chair legs

/obj/structure/stool/bed/chair/wood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/stool/bed/chair/wood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/stool/bed/chair/wood/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/wood(get_turf(src))
		new /obj/item/stack/sheet/wood(get_turf(src))
		new /obj/item/stack/sheet/wood(get_turf(src))
		qdel(src)
	else
		..()

/obj/structure/stool/bed/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair"
	color = rgb(255,255,255)
	burn_state = FLAMMABLE
	burntime = 30
	var/image/armrest = null

/obj/structure/stool/bed/chair/comfy/New()
	armrest = image("icons/obj/objects.dmi", "comfychair_armrest")
	armrest.layer = MOB_LAYER + 0.1

	return ..()

/obj/structure/stool/bed/chair/comfy/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		overlays += armrest
	else
		overlays -= armrest

/obj/structure/stool/bed/chair/comfy/brown
	color = rgb(141,70,0)

/obj/structure/stool/bed/chair/comfy/red
	color = rgb(218,2,10)

/obj/structure/stool/bed/chair/comfy/teal
	color = rgb(0,234,250)

/obj/structure/stool/bed/chair/comfy/black
	color = rgb(60,60,60)

/obj/structure/stool/bed/chair/comfy/green
	color = rgb(1,196,8)

/obj/structure/stool/bed/chair/comfy/purp
	color = rgb(112,2,176)

/obj/structure/stool/bed/chair/comfy/blue
	color = rgb(2,9,210)

/obj/structure/stool/bed/chair/comfy/beige
	color = rgb(255,253,195)

/obj/structure/stool/bed/chair/comfy/lime
	color = rgb(255,251,0)

/obj/structure/stool/bed/chair/office
	anchored = 0
	movable = 1

/obj/structure/stool/bed/chair/comfy/attackby(obj/item/weapon/W, mob/user, params)
	if(iswrench(W))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal(get_turf(src))
		new /obj/item/stack/sheet/metal(get_turf(src))
		qdel(src)
	else
		..()

/obj/structure/stool/bed/chair/office/Bump(atom/A)
	..()
	if(!buckled_mob)	return

	if(propelled)
		var/mob/living/occupant = buckled_mob
		unbuckle_mob()
		occupant.throw_at(A, 3, propelled)
		occupant.apply_effect(6, STUN, 0)
		occupant.apply_effect(6, WEAKEN, 0)
		occupant.apply_effect(6, STUTTER, 0)
		playsound(src.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
		if(istype(A, /mob/living))
			var/mob/living/victim = A
			victim.apply_effect(6, STUN, 0)
			victim.apply_effect(6, WEAKEN, 0)
			victim.apply_effect(6, STUTTER, 0)
			victim.take_organ_damage(10)
		occupant.visible_message("<span class='danger'>[occupant] crashed into \the [A]!</span>")

/obj/structure/stool/bed/chair/office/light
	icon_state = "officechair_white"

/obj/structure/stool/bed/chair/office/dark
	icon_state = "officechair_dark"

/obj/structure/stool/bed/chair/barber
	icon_state = "barber_chair"

/obj/structure/stool/bed/chair/sofa
	name = "old ratty sofa"
	icon_state = "sofamiddle"
	anchored = 1

/obj/structure/stool/bed/chair/sofa/left
	icon_state = "sofaend_left"
/obj/structure/stool/bed/chair/sofa/right
	icon_state = "sofaend_right"
/obj/structure/stool/bed/chair/sofa/corner
	icon_state = "sofacorner"
