obj/item/firework
	name = "fireworks"
	icon = 'icons/obj/fireworks.dmi'
	icon_state = "rocket_0"
	var/litzor = 0
	var/datum/effect_system/sparkle_spread/S
obj/item/firework/attackby(obj/item/W,mob/user, params)
	if(litzor)
		return
	if(istype(W, /obj/item/weldingtool) && W:welding || istype(W,/obj/item/lighter) && W:lit)
		for(var/mob/M in viewers(user))
			to_chat(M, "[user] lits \the [src]")
		litzor = 1
		icon_state = "rocket_1"
		S = new()
		S.set_up(5,0,src.loc)
		sleep(30)
		if(ismob(src.loc) || isobj(src.loc))
			S.attach(src.loc)
		S.start()
		qdel(src)

obj/item/sparkler
	name = "sparkler"
	icon = 'icons/obj/fireworks.dmi'
	icon_state = "sparkler_0"
	var/litzor = 0

obj/item/sparkler/attackby(obj/item/W,mob/user, params)
	if(litzor)
		return
	if(istype(W, /obj/item/weldingtool) && W:welding || istype(W,/obj/item/lighter) && W:lit)
		for(var/mob/M in viewers(user))
			to_chat(M, "[user] lits \the [src]")
		litzor = 1
		icon_state = "sparkler_1"
		var/b = rand(5,9)
		for(var/xy, xy<=b, xy++)
			do_sparks(1, 0, loc)
			sleep(10)
		qdel(src)
/obj/crate/fireworks
	name = "Fireworks!"
/obj/crate/fireworks/New()
	new /obj/item/sparkler(src)
	new /obj/item/sparkler(src)
	new /obj/item/sparkler(src)
	new /obj/item/sparkler(src)
	new /obj/item/sparkler(src)
	new /obj/item/sparkler(src)
	new /obj/item/sparkler(src)
	new /obj/item/sparkler(src)
	new /obj/item/firework(src)
	new /obj/item/firework(src)
	new /obj/item/firework(src)
	new /obj/item/firework(src)
	new /obj/item/firework(src)
	new /obj/item/firework(src)
	new /obj/item/firework(src)
	new /obj/item/firework(src)
	new /obj/item/firework(src)
	new /obj/item/firework(src)