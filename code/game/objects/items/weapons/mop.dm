/obj/item/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	burn_state = FLAMMABLE
	var/mopping = 0
	var/mopcount = 0
	var/mopcap = 5
	var/mopspeed = 30

/obj/item/mop/New()
	..()
	create_reagents(mopcap)
	GLOB.janitorial_equipment += src

/obj/item/mop/Destroy()
	GLOB.janitorial_equipment -= src
	return ..()

/obj/item/mop/proc/clean(turf/simulated/A)
	if(reagents.has_reagent("water", 1) || reagents.has_reagent("cleaner", 1) || reagents.has_reagent("holywater", 1))
		A.clean_blood()
		A.dirt = 0
		for(var/obj/effect/O in A)
			if(is_cleanable(O))
				qdel(O)
	reagents.reaction(A, TOUCH, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents

/obj/item/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return

	if(reagents.total_volume < 1)
		to_chat(user, "<span class='warning'>Your mop is dry!</span>")
		return

	var/turf/simulated/T = get_turf(A)

	if(istype(A, /obj/item/reagent_containers/glass/bucket) || istype(A, /obj/structure/janitorialcart))
		return

	if(istype(T))
		user.visible_message("[user] begins to clean [T] with [src].", "<span class='notice'>You begin to clean [T] with [src]...</span>")

		if(do_after(user, src.mopspeed, target = T))
			to_chat(user, "<span class='notice'>You finish mopping.</span>")
			clean(T)


/obj/effect/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		return
	else
		return ..()


/obj/item/mop/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	J.put_in_cart(src, user)
	J.mymop=src
	J.update_icon()

/obj/item/mop/wash(mob/user, atom/source)
	reagents.add_reagent("water", 5)
	to_chat(user, "<span class='notice'>You wet [src] in [source].</span>")
	playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
	return 1

/obj/item/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal. Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	mopcap = 10
	icon_state = "advmop"
	item_state = "mop"
	origin_tech = "materials=3;engineering=3"
	force = 6
	throwforce = 8
	throw_range = 4
	mopspeed = 20
	var/refill_enabled = TRUE //Self-refill toggle for when a janitor decides to mop with something other than water.
	var/refill_rate = 1 //Rate per process() tick mop refills itself
	var/refill_reagent = "water" //Determins what reagent to use for refilling, just in case someone wanted to make a HOLY MOP OF PURGING

/obj/item/mop/advanced/New()
	..()
	processing_objects.Add(src)

/obj/item/mop/advanced/attack_self(mob/user)
	refill_enabled = !refill_enabled
	if(refill_enabled)
		processing_objects.Add(src)
	else
		processing_objects.Remove(src)
	to_chat(user, "<span class='notice'>You set the condenser switch to the '[refill_enabled ? "ON" : "OFF"]' position.</span>")
	playsound(user, 'sound/machines/click.ogg', 30, 1)

/obj/item/mop/advanced/process()

	if(reagents.total_volume < mopcap)
		reagents.add_reagent(refill_reagent, refill_rate)

/obj/item/mop/advanced/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The condenser switch is set to <b>[refill_enabled ? "ON" : "OFF"]</b>.</span>")

/obj/item/mop/advanced/Destroy()
	if(refill_enabled)
		processing_objects.Remove(src)
	return ..()


/obj/item/mop/advanced/cyborg

/obj/item/mop/advanced/cyborg/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	return