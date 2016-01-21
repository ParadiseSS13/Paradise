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
		user<< "<span class='warning'>You try to draw power from the [src], but you cannot hold the power at this time!</span>"
		return
	user.middleClickOverride = clickBehavior
	user << "<span class='notice'>You draw a bit of power from the [src], you can use <b>middle click</b> or <b>alt click</b> to release the power!</span>"

/datum/middleClickOverride/badminClicker
	var/summon_path = /obj/item/weapon/reagent_containers/food/snacks/cookie

/datum/middleClickOverride/badminClicker/onClick(var/atom/A, var/mob/living/user)
	var/atom/movable/newObject = new summon_path
	newObject.loc = get_turf(A)
	user << "<span class='notice'>You release the power you had stored up, summoning \a [newObject.name]! </span>"
	usr.loc.visible_message("<span class='notice'>[user] waves \his hand and summons \a [newObject.name]</span>")
	..()