#define MOP_SOUND_CD 2 SECONDS // How many seconds before the mopping sound triggers again

/obj/item/mop
	name = "mop"
	desc = "The world of janitalia wouldn't be complete without a mop."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 3
	throwforce = 5
	throw_speed = 3
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	resistance_flags = FLAMMABLE
	new_attack_chain = TRUE
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

/obj/item/mop/proc/wet_mop(obj/O, mob/user, robot_mop)
	if(O.reagents.total_volume < 1)
		to_chat(user, "<span class='warning'>[O] is empty!</span>")
		if(robot_mop)
			return

		if(istype(O, /obj/structure/mopbucket))
			var/obj/structure/mopbucket/mopbucket = O
			if(!mopbucket.stored_mop)
				mopbucket.stored_mop = src
				mopbucket.put_in_cart(user, src)
			return

		if(istype(O, /obj/structure/janitorialcart))
			var/obj/structure/janitorialcart/janicart = O
			if(!janicart.my_mop)
				janicart.my_mop = src
				janicart.put_in_cart(user, src)
			return

	O.reagents.trans_to(src, 6)
	to_chat(user, "<span class='notice'>You wet [src] in [O].</span>")
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)

/obj/item/mop/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	// Use the mop as a weapon.
	if(user.a_intent != INTENT_HELP)
		return ..()

	if(istype(target, /obj/item/reagent_containers/glass/bucket/))
		return ..()

	if(istype(target, /obj/structure/janitorialcart/) || istype(target, /obj/structure/mopbucket))
		return ITEM_INTERACT_COMPLETE

	if(reagents.total_volume < 1)
		to_chat(user, "<span class='warning'>Your mop is dry!</span>")
		return ITEM_INTERACT_COMPLETE

	if(world.time > mop_sound_cooldown)
		playsound(loc, pick('sound/weapons/mopping1.ogg', 'sound/weapons/mopping2.ogg'), 30, TRUE, -1)
		mop_sound_cooldown = world.time + MOP_SOUND_CD
	if(user.mind && HAS_TRAIT(user, TRAIT_JANITOR))
		target.cleaning_act(user, src, mopspeed / 2, text_verb = "mop", text_description = ".")
	else
		target.cleaning_act(user, src, mopspeed, text_verb = "mop", text_description = ".")
	return ITEM_INTERACT_COMPLETE

/obj/item/mop/can_clean()
	. = FALSE
	if(reagents.has_reagent("water", 1) || reagents.has_reagent("cleaner", 1) || reagents.has_reagent("holywater", 1))
		return TRUE

/obj/item/mop/post_clean(atom/target, mob/user)
	var/turf/T = get_turf(target)
	if(issimulatedturf(T))
		reagents.reaction(T, REAGENT_TOUCH, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents

/obj/item/mop/wash(mob/user, atom/source)
	reagents.add_reagent("water", 5)
	to_chat(user, "<span class='notice'>You wet [src] in [source].</span>")
	playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
	return TRUE

/obj/item/mop/advanced
	name = "advanced mop"
	desc = "The most advanced tool in a custodian's arsenal. Just think of all the viscera you will clean up with this!"
	mopcap = 10
	icon_state = "advmop"
	origin_tech = "materials=3;engineering=3"
	force = 6
	throwforce = 8
	throw_range = 4
	mopspeed = 20
	/// Self-refill toggle for when a janitor decides to mop with something other than water.
	var/refill_enabled = TRUE
	/// Rate per process() tick mop refills itself
	var/refill_rate = 1
	/// Determins what reagent to use for refilling, just in case someone wanted to make a HOLY MOP OF PURGING
	var/refill_reagent = "water"

/obj/item/mop/advanced/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/mop/advanced/activate_self(mob/user)
	if(..())
		return

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
