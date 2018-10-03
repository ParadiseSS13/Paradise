//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/stool/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	var/health = 100
	var/image/nest_overlay
	comfort = 0

/obj/structure/stool/bed/nest/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	if(has_buckled_mobs())
		var/mob/living/M = buckled_mobs[1]

		if(user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
			unbuckle_mob(M)
			add_fingerprint(user)
			return

		if(M != user)
			M.visible_message("[user] pulls [M] free from the sticky nest!",\
				"<span class='notice'>[user] pulls you free from the gelatinous resin.</span>",\
				"<span class='italics'>You hear squelching...</span>")
		else
			M.visible_message("<span class='warning'>[M] struggles to break free from the gelatinous resin!</span>",\
				"<span class='notice'>You struggle to break free from the gelatinous resin... (Stay still for two minutes.)</span>",\
				"<span class='italics'>You hear squelching...</span>")
			if(!do_after(M, 1200, target = src))
				if(M && M.buckled)
					to_chat(M, "<span class='warning'>You fail to unbuckle yourself!</span>")
				return
			if(!M.buckled)
				return
			M.visible_message("<span class='warning'>[M] breaks free from the gelatinous resin!</span>",\
				"<span class='notice'>You break free from the gelatinous resin!</span>",\
				"<span class='italics'>You hear squelching...</span>")

		unbuckle_mob(M)
		add_fingerprint(user)

/obj/structure/stool/bed/nest/user_buckle_mob(mob/living/M, mob/living/user)
	if(!ismob(M) || (get_dist(src, user) > 1) || (M.loc != loc) || user.incapacitated() || M.buckled )
		return

	if(M.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		return
	if(!user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		return

	if(has_buckled_mobs())
		unbuckle_all_mobs()

	if(buckle_mob(M))
		M.visible_message(\
			"[user.name] secretes a thick vile goo, securing [M.name] into [src]!",\
			"<span class='danger'>[user.name] drenches you in a foul-smelling resin, trapping you in [src]!</span>",\
			"<span class='italics'>You hear squelching...</span>")


/obj/structure/stool/bed/nest/post_buckle_mob(mob/living/M)
	if(M in buckled_mobs)
		M.pixel_y = 0
		M.pixel_x = initial(M.pixel_x) + 2
		M.layer = MOB_LAYER - 0.3
		overlays += nest_overlay
	else
		M.pixel_x = M.get_standard_pixel_x_offset(M.lying)
		M.pixel_y = M.get_standard_pixel_y_offset(M.lying)
		M.layer = initial(M.layer)
		overlays -= nest_overlay

/obj/structure/stool/bed/nest/attackby(obj/item/W as obj, mob/user as mob, params)
	user.changeNext_move(CLICK_CD_MELEE)
	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	visible_message("<span class='warning'>[user] hits [src] with [W]!</span>", 1)
	healthcheck()

/obj/structure/stool/bed/nest/proc/healthcheck()
	if(health <=0)
		density = 0
		qdel(src)
	return
