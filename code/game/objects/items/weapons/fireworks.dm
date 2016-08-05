obj/item/weapon/firework
	name = "fireworks"
	icon = 'icons/obj/fireworks.dmi'
	icon_state = "rocket_0"
	var/litzor = 0
	var/datum/effect/system/sparkle_spread/S
obj/item/weapon/firework/attackby(obj/item/weapon/W,mob/user, params)
	if(litzor)
		return
	if(istype(W, /obj/item/weapon/weldingtool) && W:welding || istype(W,/obj/item/weapon/lighter) && W:lit)
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

obj/item/weapon/sparkler
	name = "sparkler"
	icon = 'icons/obj/fireworks.dmi'
	icon_state = "sparkler_0"
	var/litzor = 0
	var/datum/effect/system/spark_spread/S
obj/item/weapon/sparkler/attackby(obj/item/weapon/W,mob/user, params)
	if(litzor)
		return
	if(istype(W, /obj/item/weapon/weldingtool) && W:welding || istype(W,/obj/item/weapon/lighter) && W:lit)
		for(var/mob/M in viewers(user))
			to_chat(M, "[user] lits \the [src]")
		litzor = 1
		icon_state = "sparkler_1"
		var/b = rand(5,9)
		for(var/xy, xy<=b, xy++)
			S = new()
			S.set_up(1,0,src.loc)
			if(ismob(src.loc) || isobj(src.loc))
				S.attach(src.loc)
			S.start()
			sleep(10)
		qdel(src)
/obj/crate/fireworks
	name = "Fireworks!"
/obj/crate/fireworks/New()
	new /obj/item/weapon/sparkler(src)
	new /obj/item/weapon/sparkler(src)
	new /obj/item/weapon/sparkler(src)
	new /obj/item/weapon/sparkler(src)
	new /obj/item/weapon/sparkler(src)
	new /obj/item/weapon/sparkler(src)
	new /obj/item/weapon/sparkler(src)
	new /obj/item/weapon/sparkler(src)
	new /obj/item/weapon/firework(src)
	new /obj/item/weapon/firework(src)
	new /obj/item/weapon/firework(src)
	new /obj/item/weapon/firework(src)
	new /obj/item/weapon/firework(src)
	new /obj/item/weapon/firework(src)
	new /obj/item/weapon/firework(src)
	new /obj/item/weapon/firework(src)
	new /obj/item/weapon/firework(src)
	new /obj/item/weapon/firework(src)