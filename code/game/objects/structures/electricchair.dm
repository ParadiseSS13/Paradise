/obj/structure/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair0"
	item_chair = null
	var/obj/item/assembly/shock_kit/part = null
	var/last_time = 1.0
	var/delay_time = 50

/obj/structure/chair/e_chair/New()
	..()
	overlays += image('icons/obj/chairs.dmi', src, "echair_over", MOB_LAYER + 1, dir)
	spawn(2)
		if(isnull(part)) //This e-chair was not custom built
			part = new(src)
			var/obj/item/clothing/head/helmet/part1 = new(part)
			var/obj/item/radio/electropack/part2 = new(part)
			part2.frequency = 1445
			part2.code = 6
			part2.master = part
			part.part1 = part1
			part.part2 = part2

/obj/structure/chair/e_chair/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/wrench))
		var/obj/structure/chair/C = new /obj/structure/chair(loc)
		playsound(loc, W.usesound, 50, 1)
		C.dir = dir
		part.loc = loc
		part.master = null
		part = null
		qdel(src)
		return
	return ..()

/obj/structure/chair/e_chair/verb/activate_e_chair()
	set name = "Activate Electric Chair"
	set category = "Object"
	set src in oview(1)
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if(last_time + delay_time > world.time)
		to_chat(usr, "<span class='warning'>\The [src] is not ready yet!</span>")
		return
	to_chat(usr, "<span class='notice'>You activate \the [src].</span>")
	shock()

/obj/structure/chair/e_chair/rotate()
	..()
	overlays.Cut()
	overlays += image('icons/obj/chairs.dmi', src, "echair_over", MOB_LAYER + 1, dir)	//there's probably a better way of handling this, but eh. -Pete

/obj/structure/chair/e_chair/proc/shock()
	if(last_time + delay_time > world.time)
		return
	last_time = world.time

	icon_state = "echair1"
	spawn(delay_time)
		icon_state = "echair0"

	// special power handling
	var/area/A = get_area(src)
	if(!isarea(A))
		return
	if(!A.powered(EQUIP))
		return
	A.use_power(5000, EQUIP)
	var/light = A.power_light
	A.updateicon()

	flick("echair_shock", src)
	do_sparks(12, 1, src)
	visible_message("<span class='danger'>The electric chair went off!</span>", "<span class='danger'>You hear a deep sharp shock!</span>")
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.electrocute_act(110, src, 1)
			to_chat(buckled_mob, "<span class='danger'>You feel a deep shock course through your body!</span>")
			spawn(1)
				buckled_mob.electrocute_act(110, src, 1)
	A.power_light = light
	A.updateicon()
