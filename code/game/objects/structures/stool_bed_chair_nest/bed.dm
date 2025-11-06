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

/obj/structure/bed/wood
	name = "wooden slab"
	desc = "It looks even less comfortable than the floor it's built on..."
	icon_state = "bed_wood"
	buildstacktype = /obj/item/stack/sheet/wood
	buildstackamount = 5

/obj/structure/bed/dirty
	name = "dirty mattress"
	desc = "An old, filthy mattress covered in strange and unidentifiable stains. It looks quite uncomfortable."
	icon_state = "dirty_mattress"
	comfort = 0.5
	buildstackamount = 5

/obj/structure/bed/dirty/double
	name = "large dirty mattress"
	desc = "An old, filthy king-sized mattress covered in strange and unidentifiable stains. It looks quite uncomfortable."
	icon_state = "dirty_mattress_large"
	buildstackamount = 10

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

/obj/structure/bed/roller/item_interaction(mob/living/user, obj/item/W, list/modifiers)
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

		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/obj/structure/bed/roller/Move(NewLoc, direct)
	. = ..()
	if(!.)
		return
	playsound(loc, pick('sound/items/cartwheel1.ogg', 'sound/items/cartwheel2.ogg'), 75, TRUE, ignore_walls = FALSE)

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
	materials = list(MAT_METAL = 5000)
	new_attack_chain = TRUE
	var/extended = /obj/structure/bed/roller

/obj/item/roller/activate_self(mob/user)
	if(..())
		return

	var/obj/structure/bed/roller/R = new extended(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!isturf(target))
		return ..()

	var/turf/T = target
	if(!T.density)
		var/obj/structure/bed/roller/R = new extended(T)
		R.add_fingerprint(user)
		qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/roller/holo
	name = "holo stretcher"
	desc = "A retracted hardlight stretcher that can be carried around."
	icon_state = "holo_retracted"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 1000)
	origin_tech = "magnets=3;biotech=4;powerstorage=3"
	extended = /obj/structure/bed/roller/holo

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
	new_attack_chain = TRUE
	var/obj/item/roller/held
	var/obj/carry_holo = FALSE

/obj/item/roller_holder/New()
	..()
	held = new /obj/item/roller(src)

/obj/item/roller_holder/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!istype(target, /obj/item/roller))
		return ..()

	if(istype(target, /obj/item/roller/holo) && !carry_holo)
		return ITEM_INTERACT_COMPLETE

	if(held)
		to_chat(user, "<span class='warning'>[src] is already full!</span>")
		return ITEM_INTERACT_COMPLETE

	var/obj/item/roller/bed = target
	user.visible_message(
		"<span class='notice'>[user] collects [target].</span>",
		"<span class='notice'>You collect [target].</span>"
	)
	bed.forceMove(src)
	held = target
	return ITEM_INTERACT_COMPLETE

/obj/item/roller_holder/activate_self(mob/user)
	if(..())
		return

	if(!held)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	to_chat(user, "<span class='notice'>You deploy [held].</span>")
	var/obj/structure/bed/roller/R = new held.extended(user.loc)
	R.add_fingerprint(user)
	QDEL_NULL(held)

/obj/item/roller_holder/holo
	name = "holo stretcher rack"
	desc = "A rack for carrying an undeployed holo stretcher. It can also support a basic roller bed in a pinch."
	icon_state = "holo_retracted"
	carry_holo = TRUE

/obj/item/roller_holder/holo/New()
	..()
	held = new /obj/item/roller/holo(src)

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
