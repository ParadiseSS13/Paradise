/obj/structure/equestria_portal
	name = "Portal to Equestria"
	desc = "A portal to the magical pony world of Equestria."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1new"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/structure/equestria_portal/Bumped(atom/movable/A)
	if(istype(A, /mob/living))
		var/mob/living/M = A
		if(istype(M, /mob/living/simple_animal/pet/pony))
			to_chat(M, "<span class='notice'>You feel like staying here for now. So much to explore, so many friends to make!</span>")
			return
		else
			to_chat(M, "<span class='userdanger'>The portal rejects you as you hear a soft voice inside your head : 'You all want to come here, but why would we want you?'</span>")
			var/atom/throwtarget
			throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(M, src)))
			M.Weaken(2)
			M.throw_at(throwtarget, 5, 1, src)
			return
	..()