/obj/item/assembly/shock_kit
	name = "electrohelmet assembly"
	desc = "This appears to be made from both an electropack and a helmet."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/part1 = null
	var/obj/item/radio/electropack/part2 = null
	var/status = 0
	w_class = WEIGHT_CLASS_HUGE
	flags = CONDUCT

/obj/item/assembly/shock_kit/Destroy()
	QDEL_NULL(part1)
	QDEL_NULL(part2)
	return ..()

/obj/item/assembly/shock_kit/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/wrench) && !status)
		var/turf/T = loc
		if(ismob(T))
			T = T.loc
		part1.loc = T
		part2.loc = T
		part1.master = null
		part2.master = null
		part1 = null
		part2 = null
		qdel(src)
		return
	if(istype(W, /obj/item/screwdriver))
		status = !status
		to_chat(user, "<span class='notice'>[src] is now [status ? "secured" : "unsecured"]!</span>")
	add_fingerprint(user)
	return

/obj/item/assembly/shock_kit/attack_self(mob/user as mob)
	part1.attack_self(user, status)
	part2.attack_self(user, status)
	add_fingerprint(user)
	return

/obj/item/assembly/shock_kit/receive_signal()
	if(istype(loc, /obj/structure/chair/e_chair))
		var/obj/structure/chair/e_chair/C = loc
		C.shock()
	return
