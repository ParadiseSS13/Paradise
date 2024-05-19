/obj/item/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "grenade"
	throw_speed = 4
	throw_range = 20
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	///Is this grenade currently armed?
	var/active = FALSE
	///Is it a cluster grenade? We dont wanna spam admin logs with these.
	var/type_cluster = FALSE
	///How long it takes for a grenade to explode after being armed
	var/det_time = 5 SECONDS
	///Will this state what it's det_time is when examined?
	var/display_timer = TRUE
	///Used in botch_check to determine how a user's clumsiness affects that user's ability to prime a grenade correctly.
	var/clumsy_check = GRENADE_CLUMSY_FUMBLE
	///Was sticky tape used to make this sticky?
	var/sticky = FALSE
	// I moved the explosion vars and behavior to base grenades because we want all grenades to call [/obj/item/grenade/proc/detonate] so we can send COMSIG_GRENADE_DETONATE
	///how big of a devastation explosion radius on prime
	var/ex_dev = 0
	///how big of a heavy explosion radius on prime
	var/ex_heavy = 0
	///how big of a light explosion radius on prime
	var/ex_light = 0
	///how big of a flame explosion radius on prime
	var/ex_flame = 0

	// dealing with creating a [/datum/component/pellet_cloud] on detonate
	/// if set, will spew out projectiles of this type
	var/shrapnel_type
	/// the higher this number, the more projectiles are created as shrapnel
	var/shrapnel_radius
	///Did we add the component responsible for spawning sharpnel to this?
	var/shrapnel_initialized

/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		detonate()
	if(!QDELETED(src))
		qdel(src)

// /obj/item/grenade/proc/clown_check(mob/living/user)
// 	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
// 		to_chat(user, "<span class='warning'>Huh? How does this thing work?</span>")
// 		active = TRUE
// 		icon_state = initial(icon_state) + "_active"
// 		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
// 		spawn(5)
// 			if(user)
// 				user.drop_item()
// 			prine()
// 		return FALSE
// 	return TRUE

/**
 * Checks for various ways to botch priming a grenade.
 *
 * Arguments:
 * * mob/living/carbon/human/user - who is priming our grenade?
 */
/obj/item/grenade/proc/botch_check(mob/living/carbon/human/user)
	if(sticky && prob(50)) // to add risk to sticky tape grenade cheese, no return cause we still prime as normal after.
		to_chat(user, span_warning("What the... [src] is stuck to your hand!"))
		flags |= NODROP

	var/clumsy = HAS_TRAIT(user, TRAIT_CLUMSY)
	if(clumsy && (clumsy_check == GRENADE_CLUMSY_FUMBLE) && prob(50))
		to_chat(user, span_warning("Huh? How does this thing work?"))
		arm_grenade(user, 5, FALSE)
		return TRUE
	else if(!clumsy && (clumsy_check == GRENADE_NONCLUMSY_FUMBLE))
		to_chat(user, span_warning("You pull the pin on [src]. Attached to it is a pink ribbon that says, \"[span_clown("HONK")]\""))
		arm_grenade(user, 5, FALSE)
		return TRUE


/obj/item/grenade/examine(mob/user)
	. = ..()
	if(display_timer)
		if(det_time > 1)
			. += "The timer is set to [DisplayTimeText(det_time)] second\s."
		else
			. += "\The [src] is set for instant detonation."

/obj/item/grenade/attack_self(mob/user)
	if(flags & NODROP)
		to_chat(user, span_notice("You try prying [src] off your hand..."))
		if(do_after(user, 7 SECONDS, target = src))
			to_chat(user, span_notice("You manage to remove [src] from your hand."))
			flags ^= NODROP
		return

	if (active)
		return
	if(!botch_check(user)) // if they botch the prime, it'll be handled in botch_check
		arm_grenade(user)

/**
 * arm_grenade refers to when a grenade with a standard time fuze is activated, making it go beepbeepbeep and then detonate a few seconds later.
 * Grenades with other triggers like remote igniters probably skip this step and go straight to [/obj/item/grenade/proc/detonate]
 */
/obj/item/grenade/proc/arm_grenade(mob/user, delayoverride, msg = TRUE, volume = 60)
	if(user)
		add_fingerprint(user)
		if(msg)
			to_chat(user, span_warning("You prime [src]! [capitalize(DisplayTimeText(det_time))]!"))
	if(shrapnel_type && shrapnel_radius)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type = shrapnel_type, magnitude = shrapnel_radius)
	playsound(src, 'sound/weapons/armbomb.ogg', volume, TRUE)
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	SEND_SIGNAL(src, COMSIG_GRENADE_ARMED, det_time, delayoverride)
	addtimer(CALLBACK(src, PROC_REF(detonate)), isnull(delayoverride) ? det_time : delayoverride)

/**
 * detonate (formerly prime) refers to when the grenade actually delivers its payload (whether or not a boom/bang/detonation is involved)
 *
 * Arguments:
 * * lanced_by- If this grenade was detonated by an elance, we need to pass that along with the COMSIG_GRENADE_DETONATE signal for pellet clouds
 */
/obj/item/grenade/proc/detonate(mob/living/lanced_by)
	if(shrapnel_type && shrapnel_radius && !shrapnel_initialized) // add a second check for adding the component in case whatever triggered the grenade went straight to prime (badminnery for example)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type = shrapnel_type, magnitude = shrapnel_radius)

	SEND_SIGNAL(src, COMSIG_GRENADE_DETONATE, lanced_by)
	if(ex_dev || ex_heavy || ex_light || ex_flame)
		explosion(src, ex_dev, ex_heavy, ex_light, flame_range = ex_flame)

	return TRUE

/obj/item/grenade/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.unEquip(src)

/obj/item/grenade/screwdriver_act(mob/living/user, obj/item/I)
	switch(det_time)
		if(1)
			det_time = 10
			to_chat(user, "<span class='notice'>You set [src] for 1 second detonation time.</span>")
		if(10)
			det_time = 30
			to_chat(user, "<span class='notice'>You set [src] for 3 second detonation time.</span>")
		if(30)
			det_time = 50
			to_chat(user, "<span class='notice'>You set [src] for 5 second detonation time.</span>")
		if(50)
			det_time = 1
			to_chat(user, "<span class='notice'>You set [src] for instant detonation.</span>")
	add_fingerprint(user)
	return TRUE

/obj/item/grenade/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	if(active)
		return FALSE
	. = TRUE

	var/newtime = tgui_input_list(user, "Please enter a new detonation time", "Detonation Timer", list("Instant", 3, 4, 5))
	if (isnull(newtime))
		return
	if(newtime == "Instant" && change_det_time(0))
		to_chat(user, span_notice("You modify the time delay. It's set to be instantaneous."))
		return
	newtime = round(newtime)
	if(change_det_time(newtime))
		to_chat(user, span_notice("You modify the time delay. It's set for [DisplayTimeText(det_time)]."))

/obj/item/grenade/proc/change_det_time(time) //Time uses real time.
	. = TRUE
	if(!isnull(time))
		det_time = round(clamp(time * 10, 0, 5 SECONDS))
	else
		var/previous_time = det_time
		switch(det_time)
			if (0)
				det_time = 3 SECONDS
			if (3 SECONDS)
				det_time = 5 SECONDS
			if (5 SECONDS)
				det_time = 0
		if(det_time == previous_time)
			det_time = 5 SECONDS

/obj/item/grenade/attack_hand()
	///We need to clear the walk_to on grabbing a moving grenade to have it not leap straight out of your hand
	walk(src, null, null)
	..()

/obj/item/grenade/Destroy()
	///We need to clear the walk_to on destroy to allow a grenade which uses walk_to or related to properly GC
	walk_to(src, 0)
	return ..()
