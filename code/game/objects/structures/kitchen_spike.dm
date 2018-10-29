
//////Kitchen Spike

/obj/structure/kitchenspike_frame
	name = "meatspike frame"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spikeframe"
	desc = "The frame of a meat spike."
	density = 1
	anchored = 0

/obj/structure/kitchenspike_frame/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(istype(I, /obj/item/wrench))
		if(anchored)
			to_chat(user, "<span class='notice'>You unwrench [src] from the floor.</span>")
			anchored = 0
		else
			to_chat(user, "<span class='notice'>You wrench [src] into place.</span>")
			anchored = 1
	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(R.get_amount() >= 4)
			R.use(4)
			to_chat(user, "<span class='notice'>You add spikes to the frame.</span>")
			new /obj/structure/kitchenspike(loc)
			add_fingerprint(user)
			qdel(src)


/obj/structure/kitchenspike
	name = "meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals."
	density = 1
	anchored = 1
	buckle_lying = 0
	can_buckle = 1



/obj/structure/kitchenspike/attackby(obj/item/grab/G as obj, mob/user as mob)
	if(istype(G, /obj/item/crowbar))
		if(!buckled_mob)
			playsound(loc, G.usesound, 100, 1)
			if(do_after(user, 20 * G.toolspeed, target = src))
				to_chat(user, "<span class='notice'>You pry the spikes out of the frame.</span>")
				new /obj/item/stack/rods(loc, 4)
				new /obj/structure/kitchenspike_frame(loc)
				add_fingerprint(user)
				qdel(src)
		else
			to_chat(user, "<span class='notice'>You can't do that while something's on the spike!</span>")
		return
	if(!istype(G, /obj/item/grab) || !G.affecting)
		return
	if(buckled_mob)
		to_chat(user, "<span class = 'danger'>The spike already has something on it, finish collecting its meat first!</span>")
	else
		if(isliving(G.affecting))
			if(!buckled_mob)
				if(do_mob(user, src, 120))
					if(spike(G.affecting))
						G.affecting.visible_message("<span class='danger'>[user] slams [G.affecting] onto the meat spike!</span>", "<span class='userdanger'>[user] slams you onto the meat spike!</span>", "<span class='italics'>You hear a squishy wet noise.</span>")
						qdel(G)
						return
		to_chat(user, "<span class='danger'>You can't use that on the spike!</span>")
		return

/obj/structure/kitchenspike/proc/spike(var/mob/living/victim)

	if(!istype(victim))
		return


	if(buckled_mob) //to prevent spam/queing up attacks
		return 0
	if(victim.buckled)
		return 0
	var/mob/living/H = victim
	playsound(loc, 'sound/effects/splat.ogg', 25, 1)
	H.forceMove(loc)
	H.emote("scream")
	if(ishuman(H))
		H.add_splatter_floor()
	H.adjustBruteLoss(30)
	H.buckled = src
	H.dir = 2
	buckled_mob = H
	var/matrix/m180 = matrix()
	m180.Turn(180)
	animate(H, transform = m180, time = 3)
	H.pixel_y = H.get_standard_pixel_y_offset(180)
	return 1



/obj/structure/kitchenspike/user_buckle_mob(mob/living/M, mob/living/user) //Don't want them getting put on the rack other than by spiking
	return

/obj/structure/kitchenspike/user_unbuckle_mob(mob/living/carbon/human/user)
	if(buckled_mob && buckled_mob.buckled == src)
		var/mob/living/M = buckled_mob
		if(M != user)
			M.visible_message(\
				"[user.name] tries to pull [M.name] free of the [src]!",\
				"<span class='notice'>[user.name] is trying to pull you off of [src], opening up fresh wounds!</span>",\
				"<span class='italics'>You hear a squishy wet noise.</span>")
			if(!do_after(user, 300, target = src))
				if(M && M.buckled)
					M.visible_message(\
					"[user.name] fails to free [M.name]!",\
					"<span class='notice'>[user.name] fails to pull you off of [src].</span>")
				return

		else
			M.visible_message(\
			"<span class='warning'>[M.name] struggles to break free from the [src]!</span>",\
			"<span class='notice'>You struggle to break free from the [src], exacerbating your wounds! (Stay still for two minutes.)</span>",\
			"<span class='italics'>You hear a wet squishing noise..</span>")
			M.adjustBruteLoss(30)
			if(!do_after(M, 1200, target = src))
				if(M && M.buckled)
					to_chat(M, "<span class='warning'>You fail to free yourself!</span>")
				return
		if(!M.buckled)
			return
		var/matrix/m180 = matrix(M.transform)
		m180.Turn(180)
		animate(M, transform = m180, time = 3)
		M.pixel_y = M.get_standard_pixel_y_offset(180)
		M.adjustBruteLoss(30)
		visible_message("<span class='danger'>[M] falls free of the [src]!</span>")
		unbuckle_mob()
		M.emote("scream")
		M.AdjustWeakened(10)

