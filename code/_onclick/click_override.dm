/*
 Click Overrides

 These are overrides for a living mob's middle and alt clicks.
 If the mob in question has their middleClickOverride var set to one of these datums, when they middle or alt click the onClick proc for the datum their clickOverride var is
 set equal to will be called.
 See click.dm 251 and 196.

 If you have any questions, contact me on the Paradise forums.
 - DaveTheHeacrab
 */

/datum/middleClickOverride/

/datum/middleClickOverride/proc/onClick(var/atom/A, var/mob/living/user)
	user.middleClickOverride = null
	return 1
	/* Note, when making a new click override it is ABSOLUTELY VITAL that you set the source's clickOverride to null at some point if you don't want them to be stuck with it forever.
	Calling the super will do this for you automatically, but if you want a click override to NOT clear itself after the first click, you must do it at some other point in the code*/

/obj/item/badminBook/
	name = "old book"
	desc = "An old, leather bound tome."
	icon = 'icons/obj/library.dmi'
	icon_state = "book"
	var/datum/middleClickOverride/clickBehavior = new /datum/middleClickOverride/badminClicker

/obj/item/badminBook/attack_self(mob/living/user as mob)
	if(user.middleClickOverride)
		to_chat(user, "<span class='warning'>You try to draw power from the [src], but you cannot hold the power at this time!</span>")
		return
	user.middleClickOverride = clickBehavior
	to_chat(user, "<span class='notice'>You draw a bit of power from the [src], you can use <b>middle click</b> or <b>alt click</b> to release the power!</span>")

/datum/middleClickOverride/badminClicker
	var/summon_path = /obj/item/reagent_containers/food/snacks/cookie

/datum/middleClickOverride/badminClicker/onClick(var/atom/A, var/mob/living/user)
	var/atom/movable/newObject = new summon_path
	newObject.loc = get_turf(A)
	to_chat(user, "<span class='notice'>You release the power you had stored up, summoning \a [newObject.name]! </span>")
	usr.loc.visible_message("<span class='notice'>[user] waves [user.p_their()] hand and summons \a [newObject.name]</span>")
	..()

/datum/middleClickOverride/power_gloves

/datum/middleClickOverride/power_gloves/onClick(atom/A, mob/living/carbon/human/user)
	if(A == user || user.a_intent == INTENT_HELP || user.a_intent == INTENT_GRAB)
		return
	if(user.incapacitated())
		return
	var/obj/item/clothing/gloves/color/yellow/power/P = user.gloves
	if(world.time < P.last_shocked + P.shock_delay)
		to_chat(user, "<span class='warning'>The gloves are still recharging.</span>")
		return
	var/turf/T = get_turf(user)
	var/obj/structure/cable/C = locate() in T
	if(!P.unlimited_power)
		if(!C || !istype(C))
			to_chat(user, "<span class='warning'>There is no cable here to power the gloves.</span>")
			return
	var/turf/target_turf = get_turf(A)
	target_turf.hotspot_expose(2000, 400)
	playsound(user.loc, 'sound/effects/eleczap.ogg', 40, 1)

	var/atom/beam_from = user
	var/atom/target_atom = A

	for(var/i in 0 to 3)
		beam_from.Beam(target_atom, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 6)
		if(isliving(target_atom))
			var/mob/living/L = target_atom
			if(user.a_intent == INTENT_DISARM)
				L.Weaken(3)
			else
				if(P.unlimited_power)
					L.electrocute_act(1000, P, 0) //Just kill them
				else
					electrocute_mob(L, C, P)
			break
		var/list/next_shocked = list()
		for(var/atom/movable/AM in orange(3, target_atom))
			if(AM == user || istype(AM, /obj/effect) || isobserver(AM))
				continue
			next_shocked.Add(AM)

		beam_from = target_atom
		target_atom = pick(next_shocked)
		A = target_atom
		next_shocked.Cut()

	P.last_shocked = world.time