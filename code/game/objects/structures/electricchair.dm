/obj/structure/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair0"
	item_chair = null
	var/obj/item/assembly/shock_kit/part = null
	var/last_time = 1.0
	var/delay_time = 50
	var/shocking = FALSE

/obj/structure/chair/e_chair/Initialize(mapload, obj/item/assembly/shock_kit/sk)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

	if(sk)
		part = sk

	if(isnull(part)) //This e-chair was not custom built
		part = new(src)
		var/obj/item/clothing/head/helmet/part1 = new(part)
		var/obj/item/electropack/part2 = new(part)
		part2.integrated_signaler.frequency = 1445
		part2.integrated_signaler.code = 6
		part2.master = part
		part.part1 = part1
		part.part2 = part2

/obj/structure/chair/e_chair/examine(mob/user)
	. = ..()
	. += "<span class='warning'>You can <b>Alt-Click</b> [src] to activate it.</span>"

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

/obj/structure/chair/e_chair/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(last_time + delay_time > world.time)
		to_chat(user, "<span class='warning'>[src] is not ready yet!</span>")
		return
	to_chat(user, "<span class='notice'>You activate [src].</span>")
	shock()

/obj/structure/chair/e_chair/rotate()
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/chair/e_chair/update_icon_state()
	icon_state = "echair[shocking]"

/obj/structure/chair/e_chair/update_overlays()
	. = ..()
	. += image('icons/obj/chairs.dmi', src, "echair_over", MOB_LAYER + 1, dir)

/obj/structure/chair/e_chair/proc/shock()
	if(last_time + delay_time > world.time)
		return
	last_time = world.time

	shocking = TRUE
	update_icon(UPDATE_ICON_STATE)
	spawn(delay_time)
		shocking = FALSE
		update_icon(UPDATE_ICON_STATE)

	// special power handling
	var/area/A = get_area(src)
	if(!isarea(A))
		return
	if(!A.powernet.has_power(PW_CHANNEL_EQUIPMENT))
		return
	A.powernet.use_active_power(PW_CHANNEL_EQUIPMENT, 5000)
	A.update_icon(UPDATE_ICON_STATE)

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
