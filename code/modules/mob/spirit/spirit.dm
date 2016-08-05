/*
This mob type is used for entities that exist within the Cult's spirit world. They share the same visibility network and are intangible.
*/

mob/spirit
	name = "spirit"
	desc = "A spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = 4
	stat = CONSCIOUS
	status_flags = GODMODE // spirits cannot be killed
	density = 0
	canmove = 0
	blinded = 0
	anchored = 1
	mouse_opacity = 0
	invisibility = INVISIBILITY_SPIRIT
	universal_speak = 1

	// pseudo-movement values
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/follow_target = null


mob/spirit/proc/is_active()
	if(client && client.inactivity <= 10 * 60 * 10)
		return TRUE
	return FALSE


mob/spirit/New()
	sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = SEE_SPIRITS
	see_in_dark = 100

	loc = pick(latejoin)

	// no nameless spirits
	if(!name)
		name = "Boogyman"

	spirits+=src

	..()

mob/spirit/Destroy()
	spirits-=src
	return ..()


mob/spirit/Topic(href, href_list)

	if(usr != src)
		return
	..()

	to_chat(usr, "Spirit Href = [href]")
	for(var/tempref in href_list)
		to_chat(usr, "Spirit href list [tempref] = [href_list[tempref]]")

	if(href_list["track"])
		to_chat(usr, "Got to tracking.")
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/spirit/A = locate(href_list["track2"]) in spirits
		if(A && target)
			A.follow_cultist(target)
		return