/obj/item/assembly/shock_kit
	name = "electrohelmet assembly"
	desc = "This appears to be made from both an electropack and a helmet."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/part1 = null
	var/obj/item/electropack/part2 = null
	var/status = FALSE
	w_class = WEIGHT_CLASS_HUGE

/obj/item/assembly/shock_kit/Destroy()
	QDEL_NULL(part1)
	QDEL_NULL(part2)
	return ..()

/obj/item/assembly/shock_kit/wrench_act(mob/living/user, obj/item/I)
	if(status)
		return
	. = TRUE
	var/turf/T = get_turf(src)
	part1?.forceMove(T)
	part2?.forceMove(T)
	part1?.master = null
	part2?.master = null
	part1 = null
	part2 = null
	visible_message("<span class='notice'>[user] disassembles [src].</span>")
	qdel(src)
	return TRUE

/obj/item/assembly/shock_kit/screwdriver_act(mob/user, obj/item/I)
	status = !status
	to_chat(user, "<span class='notice'>[src] is now [status ? "secured" : "unsecured"]!</span>")
	add_fingerprint(user)
	return TRUE

/obj/item/assembly/shock_kit/attack_self__legacy__attackchain(mob/user as mob)
	part1.attack_self__legacy__attackchain(user, status)
	part2.attack_self__legacy__attackchain(user, status)
	add_fingerprint(user)
	return

/obj/item/assembly/shock_kit/proc/shock_invoke()
	if(istype(loc, /obj/structure/chair/e_chair))
		var/obj/structure/chair/e_chair/C = loc
		C.shock()
