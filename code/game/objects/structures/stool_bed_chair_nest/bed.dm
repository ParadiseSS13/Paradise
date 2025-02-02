/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 *		Dog Beds
 */

/*
 * Beds
 */

/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bed"
	dir = SOUTH
	can_buckle = TRUE
	anchored = TRUE
	buckle_lying = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 30
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 2
	buckle_offset = -6
	var/comfort = 2 // default comfort

/obj/structure/bed/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Click dragging someone to a bed will buckle them in. Functions just like a chair except you can walk over them.</span>"

/obj/structure/bed/attack_hand(mob/user)
	if(user.Move_Pulled(src))
		return
	return ..()

/obj/structure/bed/psych
	name = "psych bed"
	desc = "For prime comfort during psychiatric evaluations."
	icon_state = "psychbed"
	buildstackamount = 5

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from Earth. Could aliens be stealing our technology?"
	icon_state = "abed"
	comfort = 0.3

/obj/structure/bed/proc/handle_rotation()
	return

/obj/structure/bed/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(flags & NODECONSTRUCT)
		to_chat(user, "<span class='warning'>You can't figure out how to deconstruct [src]!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct(TRUE)

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(buildstacktype)
			new buildstacktype(loc, buildstackamount)
	..()

/obj/structure/bed/post_buckle_mob(mob/living/M)
	M.pixel_y = M.get_standard_pixel_y_offset()

/obj/structure/bed/post_unbuckle_mob(mob/living/M)
	M.pixel_y = M.get_standard_pixel_y_offset()

/obj/structure/bed/shove_impact(mob/living/target, mob/living/attacker)
	. = ..()
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target

	// only if you're wearing PJs
	if(!istype(H.w_uniform, /obj/item/clothing/under/misc/pj))
		return

	// and there's a sheet on the bed
	if(!locate(/obj/item/bedsheet) in loc)
		return

	var/sleep_ratio = 1

	if(istype(H.shoes, /obj/item/clothing/shoes/slippers))
		sleep_ratio *= 2
		// take your shoes off first, you filthy animal
		H.drop_item_to_ground(H.shoes)

	var/extinguished_candle = FALSE
	for(var/obj/item/candle/C in range(2, src))
		if(C.lit)
			C.unlight()
			extinguished_candle = TRUE

	if(extinguished_candle)
		sleep_ratio *= 2

	// nighty night
	target.visible_message(
		"<span class='danger'>[attacker] puts [target] to bed!</span>",
		"<span class='userdanger'>[attacker] shoves you under the covers, and you're out like a light!</span>",
		"<span class='notice'>You hear someone getting into bed.</span>"
	)

	if(sleep_ratio > 1)
		target.visible_message(
			"<span class='notice'>[target] seems especially cozy...[target.p_they()] probably won't be up for a while.</span>",
			"<span class='notice'>You feel so cozy, you could probably stay here for a while...</span>"
		)

	target.forceMove(loc)
	buckle_mob(target, TRUE)
	if(!H.IsSleeping())
		H.Sleeping(15 SECONDS * sleep_ratio)
		add_attack_logs(attacker, target, "put to bed for [15 * sleep_ratio] seconds.")
	H.emote("snore")

	for(var/mob/living/carbon/human/viewer in viewers())
		if(prob(50))
			viewer.emote("yawn")

	return TRUE

/*
 * Roller beds
 */

/obj/structure/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	buckle_offset = 0
	face_while_pulling = FALSE
	resistance_flags = NONE
	anchored = FALSE
	comfort = 1
	var/icon_up = "up"
	var/icon_down = "down"
	var/folded = /obj/item/roller

/obj/structure/bed/roller/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/roller_holder))
		if(has_buckled_mobs())
			if(length(buckled_mobs) > 1)
				unbuckle_all_mobs()
				user.visible_message("<span class='notice'>[user] unbuckles all creatures from [src].</span>")
			else
				user_unbuckle_mob(buckled_mobs[1], user)
		else
			user.visible_message("<span class='notice'>[user] collapses \the [name].</span>", "<span class='notice'>You collapse \the [name].</span>")
			new folded(get_turf(src))
			qdel(src)
	else
		return ..()

/obj/structure/bed/roller/post_buckle_mob(mob/living/M)
	density = TRUE
	icon_state = icon_up
	..()

/obj/structure/bed/roller/post_unbuckle_mob(mob/living/M)
	density = FALSE
	icon_state = icon_down
	..()

/obj/structure/bed/roller/holo
	name = "holo stretcher"
	icon_state = "holo_extended"
	icon_up = "holo_extended"
	icon_down = "holo_extended"
	folded = /obj/item/roller/holo

/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	w_class = WEIGHT_CLASS_BULKY
	var/extended = /obj/structure/bed/roller

/obj/item/roller/attack_self__legacy__attackchain(mob/user)
	var/obj/structure/bed/roller/R = new extended(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller/afterattack__legacy__attackchain(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(isturf(target))
		var/turf/T = target
		if(!T.density)
			var/obj/structure/bed/roller/R = new extended(T)
			R.add_fingerprint(user)
			qdel(src)

/obj/item/roller/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/roller_holder))
		var/obj/item/roller_holder/RH = W
		if(!RH.held)
			user.visible_message("<span class='notice'>[user] collects \the [name].</span>", "<span class='notice'>You collect \the [name].</span>")
			forceMove(RH)
			RH.held = src

/obj/item/roller/holo
	name = "holo stretcher"
	desc = "A retracted hardlight stretcher that can be carried around."
	icon_state = "holo_retracted"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "magnets=3;biotech=4;powerstorage=3"
	extended = /obj/structure/bed/roller/holo

/obj/item/roller/holo/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	return

/obj/structure/bed/roller/MouseDrop(over_object, src_location, over_location)
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr) || usr.incapacitated())
			return
		if(has_buckled_mobs())
			return 0
		usr.visible_message("<span class='notice'>[usr] collapses \the [name].</span>", "<span class='notice'>You collapse \the [name].</span>")
		new folded(get_turf(src))
		qdel(src)
		return
	..()

/obj/item/roller_holder
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	var/obj/item/roller/held

/obj/item/roller_holder/New()
	..()
	held = new /obj/item/roller(src)

/obj/item/roller_holder/attack_self__legacy__attackchain(mob/user as mob)
	if(!held)
		to_chat(user, "<span class='notice'>The rack is empty.</span>")
		return

	to_chat(user, "<span class='notice'>You deploy the roller bed.</span>")
	var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(user.loc)
	R.add_fingerprint(user)
	QDEL_NULL(held)

/*
 * Dog beds
 */

/obj/structure/bed/dogbed
	name = "dog bed"
	icon_state = "dogbed"
	desc = "A comfy-looking dog bed. You can even strap your pet in, just in case the gravity turns off."
	anchored = FALSE
	buildstackamount = 10
	buildstacktype = /obj/item/stack/sheet/wood
	buckle_offset = 0
	comfort = 0.5

/obj/structure/bed/dogbed/ian
	name = "Ian's bed"
	desc = "Ian's bed! Looks comfy."
	anchored = TRUE

/obj/structure/bed/dogbed/renault
	desc = "Renault's bed! Looks comfy. A foxy person needs a foxy pet."
	name = "Renault's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/runtime
	desc = "A comfy-looking cat bed. You can even strap your pet in, in case the gravity turns off."
	name = "Runtime's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/brad
	name = "Brad's bed"
	desc = "Brad's bed! Why does a cockroach get this amount of love?"
	anchored = TRUE
