
//////Kitchen Spike

/obj/structure/kitchenspike_frame
	name = "meatspike frame"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spikeframe"
	desc = "The frame of a meat spike."
	density = TRUE
	anchored = TRUE
	max_integrity = 200

/obj/structure/kitchenspike_frame/wrench_act(mob/living/user, obj/item/I)
	if(!I.tool_use_check(user, 0))
		return FALSE
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume))
		return TRUE
	TOOL_DISMANTLE_SUCCESS_MESSAGE
	deconstruct(TRUE)
	return TRUE

/obj/structure/kitchenspike_frame/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	add_fingerprint(user)
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(R.get_amount() >= 4)
			R.use(4)
			to_chat(user, "<span class='notice'>You add spikes to the frame.</span>")
			new /obj/structure/kitchenspike(loc)
			add_fingerprint(user)
			qdel(src)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/structure/kitchenspike_frame/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Add metal rods to complete construction, or use a wrench to deconstruct it.</span>"

/obj/structure/kitchenspike_frame/deconstruct(disassembled = TRUE)
	if(disassembled)
		new /obj/item/stack/sheet/metal(loc, 5)
	else
		new /obj/item/stack/sheet/metal(loc, 4)
	..()


/obj/structure/kitchenspike
	name = "meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals."
	density = TRUE
	anchored = TRUE
	buckle_lying = FALSE
	can_buckle = TRUE
	max_integrity = 250
	var/impale_time = 6 SECONDS

/obj/structure/kitchenspike/examine(mob/user)
	. = ..()
	. += "<span class='notice'>To deconstruct, pry out the spikes with a crowbar, then deconstruct the frame with a wrench.</span>"

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/kitchenspike/attack_hand(mob/user)
	if(has_buckled_mobs())
		for(var/mob/living/L in buckled_mobs)
			user_unbuckle_mob(L, user)
	else
		..()

/obj/structure/kitchenspike/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(G.affecting && isliving(G.affecting))
			start_spike(G.affecting, user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/structure/kitchenspike/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(has_buckled_mobs())
		to_chat(user, "<span class='notice'>You can't do that while something's on the spike!</span>")
		return
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You pry the spikes out of the frame.</span>")
	deconstruct(TRUE)

/obj/structure/kitchenspike/MouseDrop_T(mob/living/victim, mob/living/user)
	if(!user.Adjacent(src) || !user.Adjacent(victim) || is_ai(user) || !ismob(victim))
		return
	if(isanimal_or_basicmob(user) && victim != user)
		return // animals cannot put mobs other than themselves onto spikes
	add_fingerprint(user)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/structure/kitchenspike, start_spike), victim, user)
	return TRUE

/obj/structure/kitchenspike/proc/start_spike(mob/living/victim, mob/user)
	if(has_buckled_mobs())
		to_chat(user, "<span class='danger'>The spike already has something on it, finish collecting its meat first!</span>")
		return
	victim.visible_message(
		"<span class='danger'>[user] tries to slam [victim] onto the meat spike!</span>",
		"<span class='userdanger'>[user] tries to slam you onto the meat spike!</span>"
	)
	if(do_mob(user, victim, impale_time))
		end_spike(victim, user)

/obj/structure/kitchenspike/proc/end_spike(mob/living/victim, mob/user)

	if(!istype(victim))
		return FALSE

	if(has_buckled_mobs()) //to prevent spam/queing up attacks
		return FALSE
	if(victim.buckled)
		return FALSE
	playsound(loc, 'sound/effects/splat.ogg', 25, 1)
	victim.forceMove(drop_location())
	victim.emote("scream")
	victim.visible_message(
		"<span class='danger'>[user] slams [victim] onto the meat spike!</span>",
		"<span class='userdanger'>[user] slams you onto the meat spike!</span>",
		"<span class='italics'>You hear a squishy wet noise.</span>"
	)
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		H.add_splatter_floor()
	victim.adjustBruteLoss(30)
	victim.setDir(2)
	buckle_mob(victim, force = TRUE)
	victim.set_lying_angle(180)
	victim.update_transform()
	victim.pixel_y = victim.get_standard_pixel_y_offset(180)
	if(victim.mind)
		add_attack_logs(user, victim, "Hooked onto [src]")
	return TRUE

/obj/structure/kitchenspike/user_unbuckle_mob(mob/living/buckled_mob, mob/living/carbon/human/user)
	if(buckled_mob)
		var/mob/living/M = buckled_mob
		if(M != user)
			M.visible_message("<span class='notice'>[user] tries to pull [M] free of [src]!</span>",\
				"<span class='notice'>[user] is trying to pull you off [src], opening up fresh wounds!</span>",\
				"<span class='italics'>You hear a squishy wet noise.</span>")
			if(!do_after(user, 15 SECONDS, target = src))
				if(M && M.buckled)
					M.visible_message("<span class='notice'>[user] fails to free [M]!</span>",\
					"<span class='notice'>[user] fails to pull you off of [src].</span>")
				return

		else
			M.visible_message("<span class='warning'>[M] struggles to break free from [src]!</span>",\
			"<span class='notice'>You struggle to break free from [src], exacerbating your wounds! (Stay still for two minutes.)</span>",\
			"<span class='italics'>You hear a wet squishing noise..</span>")
			M.adjustBruteLoss(30)
			if(!do_after(M, 2 MINUTES, target = src, hidden = TRUE))
				if(M && M.buckled)
					to_chat(M, "<span class='warning'>You fail to free yourself!</span>")
				return
		if(!M.buckled)
			return
		release_mob(M)

/obj/structure/kitchenspike/proc/release_mob(mob/living/M)
	M.adjustBruteLoss(30)
	visible_message(text("<span class='danger'>[M] falls free of [src]!</span>"))
	unbuckle_mob(M, force = TRUE)
	M.emote("scream")
	M.AdjustWeakened(20 SECONDS)

/obj/structure/kitchenspike/post_unbuckle_mob(mob/living/M)
	M.pixel_y = M.get_standard_pixel_y_offset(0)
	M.update_transform()

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
	..()
