//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/stool/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	var/health = 100
	var/image/nest_overlay

/obj/structure/stool/bed/nest/New()
	nest_overlay = image('icons/mob/alien.dmi', "nestoverlay", layer=MOB_LAYER - 0.2)
	return ..()

/obj/structure/stool/bed/nest/user_unbuckle_mob(mob/living/user)
	if(buckled_mob && buckled_mob.buckled == src)
		var/mob/living/M = buckled_mob

		if(user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
			unbuckle_mob()
			add_fingerprint(user)
			return

		if(M != user)
			M.visible_message(\
				"<span class='notice'>[user.name] pulls [M.name] free from the sticky nest!</span>",\
				"<span class='notice'>[user.name] pulls you free from the gelatinous resin.</span>",\
				"<span class='notice'>You hear squelching...</span>")

		else
			buckled_mob.visible_message(\
				"<span class='warning'>[buckled_mob.name] struggles to break free of the gelatinous resin...</span>",\
				"<span class='warning'>You struggle to break free from the gelatinous resin... (This will take around 2 minutes and you need to stay still)</span>",\
				"<span class='notice'>You hear squelching...</span>")
			if(!do_after(M, 1200, target = src))
				if(M && M.buckled)
					to_chat(M, "<span class='warning'>You fail to escape \the [src]!</span>")
				return
			if(!M.buckled)
				return
			M.visible_message(\
			"<span class='warning'>[M.name] breaks free from the gelatinous resin!</span>",\
			"<span class='notice'>You break free from the gelatinous resin!</span>",\
			"<span class='italics'>You hear squelching...</span>")
		unbuckle_mob()
		add_fingerprint(user)


/obj/structure/stool/bed/nest/user_buckle_mob(mob/living/M, mob/living/user)
	if( !ismob(M) || (get_dist(src, user) > 1) || (M.loc != src.loc) || user.restrained() || usr.stat || M.buckled || istype(user, /mob/living/silicon/pai) )
		return

	if(M.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		return
	if(!user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		return

	unbuckle_mob()

	if(buckle_mob(M))
		M.visible_message(\
			"[user.name] secretes a thick vile goo, securing [M.name] into [src]!",\
			"<span class='danger'>[user.name] drenches you in a foul-smelling resin, trapping you in [src]!</span>",\
			"<span class='italics'>You hear squelching...</span>")


/obj/structure/stool/bed/nest/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		M.pixel_y = 0
		M.pixel_x = initial(M.pixel_x) + 2
		M.layer = MOB_LAYER - 0.3
		overlays += nest_overlay
	else
		M.pixel_x = M.get_standard_pixel_x_offset(M.lying)
		M.pixel_y = M.get_standard_pixel_y_offset(M.lying)
		M.layer = initial(M.layer)
		overlays -= nest_overlay

/obj/structure/stool/bed/nest/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
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
