/*
 Click Overrides

 These are overrides for a living mob's middle and alt clicks.
 If the mob in question has their middleClickOverride var set to one of these datums, when they middle or alt click the onClick proc for the datum their clickOverride var is
 set equal to will be called.
 See click.dm 251 and 196.

 If you have any questions, contact me on the Paradise forums.
 - DaveTheHeacrab
 */

/datum/middle_click_override/

/datum/middle_click_override/proc/onClick(atom/A, mob/living/user)
	user.middleClickOverride = null
	return TRUE
	/* Note, when making a new click override it is ABSOLUTELY VITAL that you set the source's clickOverride to null at some point if you don't want them to be stuck with it forever.
	Calling the super will do this for you automatically, but if you want a click override to NOT clear itself after the first click, you must do it at some other point in the code*/

/obj/item/badmin_book/
	name = "old book"
	desc = "An old, leather bound tome."
	icon = 'icons/obj/library.dmi'
	icon_state = "book"
	var/datum/middle_click_override/clickBehavior = new /datum/middle_click_override/badmin_clicker

/obj/item/badmin_book/attack_self__legacy__attackchain(mob/living/user as mob)
	if(user.middleClickOverride)
		to_chat(user, "<span class='warning'>You try to draw power from [src], but you cannot hold the power at this time!</span>")
		return
	user.middleClickOverride = clickBehavior
	to_chat(user, "<span class='notice'>You draw a bit of power from [src], you can use <b>middle click</b> or <b>alt click</b> to release the power!</span>")

/datum/middle_click_override/badmin_clicker
	var/summon_path = /obj/item/food/cookie

/datum/middle_click_override/badmin_clicker/onClick(atom/A, mob/living/user)
	var/atom/movable/newObject = new summon_path
	newObject.loc = get_turf(A)
	to_chat(user, "<span class='notice'>You release the power you had stored up, summoning \a [newObject.name]!</span>")
	usr.loc.visible_message("<span class='notice'>[user] waves [user.p_their()] hand and summons \a [newObject.name]!</span>")
	..()

/datum/middle_click_override/shock_implant

/datum/middle_click_override/shock_implant/onClick(atom/A, mob/living/carbon/human/user)
	if(user.incapacitated() || A == user)
		return FALSE
	var/obj/item/bio_chip/shock/P = locate() in user
	if(!P)
		return
	if(!COOLDOWN_FINISHED(P, last_shocked))
		to_chat(user, "<span class='warning'>The powerchip is still recharging.</span>")
		return FALSE
	var/turf/T = get_turf(user)
	var/obj/structure/cable/C = locate() in T
	if(!P.unlimited_power)
		if(!C || !istype(C))
			to_chat(user, "<span class='warning'>There is no cable here to power the bio-chip.</span>")
			return FALSE
	var/turf/target_turf = get_turf(A)
	if(get_dist(T, target_turf) > P.shock_range)
		to_chat(user, "<span class='warning'>The target is too far away.</span>")
		return FALSE
	target_turf.hotspot_expose(2000, 1)
	playsound(user.loc, 'sound/effects/eleczap.ogg', 40, 1)

	var/atom/beam_from = user
	var/atom/target_atom = A

	for(var/i in 0 to 2) //3 attempts. Shocks at the clicked source, tries to find a mob in 1 tile, then choses a random tile 1 away to try again. As such, can only hit a mob 2 tiles away from the click
		beam_from.Beam(target_atom, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 6)
		if(isliving(target_atom))
			var/mob/living/L = target_atom
			var/powergrid = C.get_available_power() //We want available power, so the station being conservative doesn't mess with the power biochip / dark bundle users
			if(user.a_intent == INTENT_DISARM || user.a_intent == INTENT_HELP)
				add_attack_logs(user, L, "shocked with power bio-chip.")
				L.apply_damage(60, STAMINA)
				L.Jitter(10 SECONDS)
				var/atom/throw_target = get_edge_target_turf(user, get_dir(user, get_step_away(L, user)))
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					if(H.gloves && H.gloves.siemens_coefficient == 0) //No throwing with insulated gloves (you still get stamina however)
						break
				L.throw_at(throw_target, powergrid / (150 KW), powergrid / (300 KW)) //150 kW in grid throws 1 tile, 300 throws 2, etc.

			else
				add_attack_logs(user, L, "electrocuted with[P.unlimited_power ? " unlimited" : null] power bio-chip")
				if(P.unlimited_power)
					L.electrocute_act(1000, P, flags = SHOCK_NOGLOVES) //Just kill them
				else
					electrocute_mob(L, C.powernet, P)
			break
		var/list/next_shocked = list()
		for(var/mob/M in range(1, target_atom)) //Try to jump to a mob first
			if(M == user || isobserver(M))
				continue
			next_shocked.Add(M)
			break //Break this so it gets the closest, thank you
		if(!length(next_shocked)) //No mob? Random bullshit go, try to get closer to a mob with luck
			for(var/atom/movable/AM in orange(1, target_atom))
				if(AM == user || iseffect(AM) || isobserver(AM))
					continue
				next_shocked.Add(AM)
		beam_from = target_atom
		target_atom = pick(next_shocked)
		A = target_atom
		next_shocked.Cut()

	COOLDOWN_START(P, last_shocked, P.shock_delay)
	return TRUE

/**
 * # Callback invoker middle click override datum
 *
 * Middle click override which accepts a callback as an arugment in the `New()` proc.
 * When the living mob that has this datum middle-clicks or alt-clicks on something, the callback will be invoked.
 */
/datum/middle_click_override/callback_invoker
	var/datum/callback/callback

/datum/middle_click_override/callback_invoker/New(datum/callback/_callback)
	. = ..()
	callback = _callback

/datum/middle_click_override/callback_invoker/onClick(atom/A, mob/living/user)
	if(callback.Invoke(user, A))
		return TRUE
