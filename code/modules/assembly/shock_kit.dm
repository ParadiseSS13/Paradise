/obj/item/assembly/shock_kit
	name = "electrohelmet assembly"
	desc = "This appears to be made from both an electropack and a helmet."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/attached_helmet = null
	var/obj/item/electropack/attached_electropack = null
	var/status = FALSE
	w_class = WEIGHT_CLASS_HUGE

/obj/item/assembly/shock_kit/Destroy()
	QDEL_NULL(attached_helmet)
	QDEL_NULL(attached_electropack)
	return ..()

/obj/item/assembly/shock_kit/wrench_act(mob/living/user, obj/item/I)
	if(status)
		return
	. = TRUE
	var/turf/T = get_turf(src)
	attached_helmet?.forceMove(T)
	attached_electropack?.forceMove(T)
	attached_helmet?.master = null
	attached_electropack?.master = null
	attached_helmet = null
	attached_electropack = null
	visible_message(SPAN_NOTICE("[user] disassembles [src]."))
	qdel(src)
	return TRUE

/obj/item/assembly/shock_kit/screwdriver_act(mob/user, obj/item/I)
	status = !status
	if(status)
		to_chat(user, SPAN_NOTICE("You ready and secure [src]!"))
	else
		to_chat(user, SPAN_NOTICE("You unsecure [src] with [I] so it can be attached!"))
	add_fingerprint(user)
	return TRUE

/obj/item/assembly/shock_kit/activate_self(mob/user)
	if(!user)
		return ..()
	if(!attached_helmet || !attached_electropack)
		return NONE
	attached_helmet.activate_self(user)
	attached_electropack.activate_self(user)
	add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/assembly/shock_kit/proc/shock_invoke()
	if(istype(loc, /obj/structure/chair/e_chair))
		var/obj/structure/chair/e_chair/C = loc
		C.shock()
