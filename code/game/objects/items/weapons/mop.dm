#define MOP_SOUND_CD 2 SECONDS // How many seconds before the mopping sound triggers again

/obj/item/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	resistance_flags = FLAMMABLE
	var/mopcap = 6
	var/mopspeed = 30
	/// The cooldown between each mopping sound effect
	var/mop_sound_cooldown

/obj/item/mop/New()
	..()
	create_reagents(mopcap)
	GLOB.janitorial_equipment += src

/obj/item/mop/Destroy()
	GLOB.janitorial_equipment -= src
	return ..()

/obj/item/mop/proc/wet_mop(obj/O, mob/user)
	if(O.reagents.total_volume < 1)
		to_chat(user, "<span class='notice'>[O] is empty!</span>")
		if(istype(O, /obj/structure/mopbucket))
			var/obj/structure/mopbucket/mopbucket = O
			mopbucket.mopbucket_insert(user, O)
		if(istype(O, /obj/structure/janitorialcart))
			var/obj/structure/janitorialcart/janicart = O
			if(!janicart.mymop)
				janicart.mymop = src
				janicart.put_in_cart(user, src)
		return

	O.reagents.trans_to(src, 6)
	to_chat(user, "<span class='notice'>You wet [src] in [O].</span>")
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)

/obj/item/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(istype(A, /obj/item/reagent_containers/glass/bucket) || istype(A, /obj/structure/janitorialcart) || istype(A, /obj/structure/mopbucket))
		return
	if(reagents.total_volume < 1)
		to_chat(user, "<span class='warning'>Your mop is dry!</span>")
		return
	if(world.time > mop_sound_cooldown)
		playsound(loc, pick('sound/weapons/mopping1.ogg', 'sound/weapons/mopping2.ogg'), 30, TRUE, -1)
		mop_sound_cooldown = world.time + MOP_SOUND_CD
	A.cleaning_act(user, src, mopspeed, text_verb = "mop", text_description = ".")

/obj/item/mop/can_clean()
	if(reagents.has_reagent("water", 1) || reagents.has_reagent("cleaner", 1) || reagents.has_reagent("holywater", 1))
		return TRUE
	else
		return FALSE

/obj/item/mop/post_clean(atom/target, mob/user)
	var/turf/T = get_turf(target)
	if(issimulatedturf(T))
		reagents.reaction(T, REAGENT_TOUCH, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents

/obj/effect/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		return
	else
		return ..()

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
	START_PROCESSING(SSobj, src)

/obj/item/mop/advanced/attack_self(mob/user)
	refill_enabled = !refill_enabled
	if(refill_enabled)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	to_chat(user, "<span class='notice'>You set the condenser switch to the '[refill_enabled ? "ON" : "OFF"]' position.</span>")
	playsound(user, 'sound/machines/click.ogg', 30, 1)

/obj/item/mop/advanced/process()

	if(reagents.total_volume < mopcap)
		reagents.add_reagent(refill_reagent, refill_rate)

/obj/item/mop/advanced/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The condenser switch is set to <b>[refill_enabled ? "ON" : "OFF"]</b>.</span>"

/obj/item/mop/advanced/Destroy()
	if(refill_enabled)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mop/advanced/cyborg

#undef MOP_SOUND_CD
