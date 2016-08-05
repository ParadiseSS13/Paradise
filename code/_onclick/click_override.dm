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

/obj/item/weapon/badminBook/
	name = "old book"
	desc = "An old, leather bound tome."
	icon = 'icons/obj/library.dmi'
	icon_state = "book"
	var/datum/middleClickOverride/clickBehavior = new /datum/middleClickOverride/badminClicker

/obj/item/weapon/badminBook/attack_self(mob/living/user as mob)
	if(user.middleClickOverride)
		to_chat(user, "<span class='warning'>You try to draw power from the [src], but you cannot hold the power at this time!</span>")
		return
	user.middleClickOverride = clickBehavior
	to_chat(user, "<span class='notice'>You draw a bit of power from the [src], you can use <b>middle click</b> or <b>alt click</b> to release the power!</span>")

/datum/middleClickOverride/badminClicker
	var/summon_path = /obj/item/weapon/reagent_containers/food/snacks/cookie

/datum/middleClickOverride/badminClicker/onClick(var/atom/A, var/mob/living/user)
	var/atom/movable/newObject = new summon_path
	newObject.loc = get_turf(A)
	to_chat(user, "<span class='notice'>You release the power you had stored up, summoning \a [newObject.name]! </span>")
	usr.loc.visible_message("<span class='notice'>[user] waves \his hand and summons \a [newObject.name]</span>")
	..()

/datum/middleClickOverride/power_gloves
	var/last_shocked = 0
	var/shock_delay = 120

/datum/middleClickOverride/power_gloves/onClick(var/atom/A, var/mob/living/user)
	if(user.incapacitated())
		return
	if(world.time < last_shocked + shock_delay)
		to_chat(user, "<span class='warning'>The gloves are still recharging.</span>")
		return
	if(!isliving(A))
		to_chat(user, "<span class='warning'>Shocking an inanimate object would be pointless.</span>")
		return
	var/mob/living/L = A
	var/turf/T = get_turf(user)
	var/obj/structure/cable/C = locate() in T
	if(!C || !istype(C))
		to_chat(user, "<span class='warning'>There is no cable here to power the gloves.</span>")
		return
	user.visible_message("<span class='warning'>[user.name] fires an arc of electricity at [L]!</span>", "<span class='warning'>You fire an arc of electricity at [L]!</span>", "You hear the loud crackle of electricity!")
	var/datum/powernet/PN = C.get_powernet()
	user.Beam(L,icon_state="lightning[rand(1,12)]",icon='icons/effects/effects.dmi',time=5)
	electrocute_mob(L, PN, user)
	last_shocked = world.time
