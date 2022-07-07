
//////Kitchen Spike

/obj/structure/kitchenspike_frame
	name = "meatspike frame"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spikeframe"
	desc = "The frame of a meat spike."
	density = 1
	anchored = 0
	max_integrity = 200

/obj/structure/kitchenspike_frame/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(istype(I, /obj/item/wrench))
		if(anchored)
			to_chat(user, span_notice("You unwrench [src] from the floor."))
			anchored = 0
		else
			to_chat(user, span_notice("You wrench [src] into place."))
			anchored = 1
	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(R.get_amount() >= 4)
			R.use(4)
			to_chat(user, span_notice("You add spikes to the frame."))
			new /obj/structure/kitchenspike(loc)
			add_fingerprint(user)
			qdel(src)
		return
	else
		return ..()


/obj/structure/kitchenspike
	name = "meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals."
	density = 1
	anchored = 1
	buckle_lying = FALSE
	can_buckle = TRUE
	max_integrity = 250

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/kitchenspike/attack_hand(mob/user)
	if(has_buckled_mobs())
		for(var/mob/living/L in buckled_mobs)
			user_unbuckle_mob(L, user)
	else
		..()

/obj/structure/kitchenspike/attackby(obj/item/grab/G, mob/user)
	if(istype(G, /obj/item/crowbar))
		if(!has_buckled_mobs())
			playsound(loc, G.usesound, 100, 1)
			if(do_after(user, 20 * G.toolspeed, target = src))
				to_chat(user, span_notice("You pry the spikes out of the frame."))
				deconstruct(TRUE)
		else
			to_chat(user, span_notice("You can't do that while something's on the spike!"))
		return
	if(!istype(G, /obj/item/grab) || !G.affecting)
		return
	if(has_buckled_mobs())
		to_chat(user, "<span class = 'danger'>The spike already has something on it, finish collecting its meat first!</span>")
		return
	if(isliving(G.affecting))
		if(!has_buckled_mobs())
			if(do_mob(user, src, 120))
				var/mob/living/affected = G.affecting
				if(spike(affected))
					affected.visible_message(span_danger("[user] slams [affected] onto the meat spike!"), span_userdanger("[user] slams you onto the meat spike!"), "<span class='italics'>You hear a squishy wet noise.</span>")
		return
	return ..()

/obj/structure/kitchenspike/proc/spike(mob/living/victim)

	if(!istype(victim))
		return FALSE

	if(has_buckled_mobs()) //to prevent spam/queing up attacks
		return FALSE
	if(victim.buckled)
		return FALSE
	playsound(loc, 'sound/effects/splat.ogg', 25, 1)
	victim.forceMove(drop_location())
	victim.emote("scream")
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		H.add_splatter_floor()
	victim.adjustBruteLoss(30)
	victim.setDir(2)
	buckle_mob(victim, force = TRUE)
	var/matrix/m180 = matrix(victim.transform)
	m180.Turn(180)
	animate(victim, transform = m180, time = 3)
	victim.pixel_y = victim.get_standard_pixel_y_offset(180)
	return TRUE


/obj/structure/kitchenspike/user_buckle_mob(mob/living/M, mob/living/user) //Don't want them getting put on the rack other than by spiking
	return

/obj/structure/kitchenspike/user_unbuckle_mob(mob/living/buckled_mob, mob/living/carbon/human/user)
	if(buckled_mob)
		var/mob/living/M = buckled_mob
		if(M != user)
			M.visible_message(span_notice("[user] tries to pull [M] free of [src]!"),\
				span_notice("[user] is trying to pull you off [src], opening up fresh wounds!"),\
				"<span class='italics'>You hear a squishy wet noise.</span>")
			if(!do_after(user, 300, target = src))
				if(M && M.buckled)
					M.visible_message(span_notice("[user] fails to free [M]!"),\
					span_notice("[user] fails to pull you off of [src]."))
				return

		else
			M.visible_message(span_warning("[M] struggles to break free from [src]!"),\
			span_notice("You struggle to break free from [src], exacerbating your wounds! (Stay still for two minutes.)"),\
			"<span class='italics'>You hear a wet squishing noise..</span>")
			M.adjustBruteLoss(30)
			if(!do_after(M, 1200, target = src))
				if(M && M.buckled)
					to_chat(M, span_warning("You fail to free yourself!"))
				return
		if(!M.buckled)
			return
		release_mob(M)

/obj/structure/kitchenspike/proc/release_mob(mob/living/M)
	M.adjustBruteLoss(30)
	src.visible_message(text(span_danger("[M] falls free of [src]!")))
	unbuckle_mob(M, force = TRUE)
	M.emote("scream")
	M.AdjustWeakened(20 SECONDS)

/obj/structure/kitchenspike/post_unbuckle_mob(mob/living/M)
	M.pixel_y = M.get_standard_pixel_y_offset(0)
	var/matrix/m180 = matrix(M.transform)
	m180.Turn(180)
	animate(M, transform = m180, time = 3)

/obj/structure/kitchenspike/Destroy()
	if(has_buckled_mobs())
		for(var/mob/living/L in buckled_mobs)
			release_mob(L)
	return ..()

/obj/structure/kitchenspike/deconstruct(disassembled = TRUE)
	if(disassembled)
		var/obj/F = new /obj/structure/kitchenspike_frame(loc)
		transfer_fingerprints_to(F)
	else
		new /obj/item/stack/sheet/metal(loc, 4)
	new /obj/item/stack/rods(loc, 4)
	qdel(src)
