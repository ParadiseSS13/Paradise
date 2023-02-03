/**
 * # Energy Net
 * Energy net which ensnares prey until it is destroyed.  Used by space ninjas.
 */
/obj/structure/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'icons/mob/actions/actions_ninja.dmi'
	icon_state = "energynet"

	density = TRUE//Can't pass through.
	opacity = FALSE //Can see through.
	mouse_opacity = MOUSE_OPACITY_ICON //So you can hit it with stuff.
	anchored = TRUE //Can't drag/grab the net.
	layer = ABOVE_ALL_MOB_LAYER
	plane = GAME_PLANE
	max_integrity = 200 //How much health it has.
	can_buckle = 1
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	///The creature currently caught in the net
	var/mob/living/affected_mob
	var/destroy_after = 20 SECONDS
	var/self_destroy = TRUE

/obj/structure/energy_net/noselfdestroy
	self_destroy = FALSE

/obj/structure/energy_net/Initialize(mapload)
	. = ..()
	if(self_destroy)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, src), destroy_after)

/obj/structure/energy_net/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BRUTE || damage_type == BURN)
		playsound(src, 'sound/weapons/slash.ogg', 80, TRUE)

/obj/structure/energy_net/Destroy()
	if(!QDELETED(affected_mob))
		affected_mob.visible_message(span_notice("[affected_mob.name] is recovered from the energy net!"), span_notice("You are recovered from the energy net!"), span_hear("You hear a grunt."))
	affected_mob = null
	return ..()

/obj/structure/energy_net/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	return//We only want our target to be buckled

/obj/structure/energy_net/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	return//The net must be destroyed to free the target
