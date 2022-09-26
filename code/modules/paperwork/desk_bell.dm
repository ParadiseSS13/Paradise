// A receptionist's bell

/obj/item/desk_bell
	name = "desk bell"
	desc = "The cornerstone of any customer service job. You feel an unending urge to ring it. It looks like it can be wrenched or screwdrivered."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "desk_bell"
	/// The amount of times this bell has been rang, used to check the chance it breaks
	var/times_rang = 0
	/// Is this bell broken?
	var/broken_ringer = FALSE
	/// Holds the time that the bell can next be rang.
	var/ring_cooldown = 0
	/// The length of the cooldown. Setting it to 0 will skip all cooldowns alltogether.
	var/ring_cooldown_length = 0.5 SECONDS // This is here to protect against tinnitus.
	/// The sound the bell makes
	var/ring_sound = 'sound/machines/bell.ogg'

/obj/item/desk_bell/attack_hand(mob/living/user)
	if(in_inventory && ishuman(user))
		if(!user.get_active_hand())
			user.put_in_hands(src)
			return TRUE
	if(ring_cooldown > world.time || !anchored)
		return TRUE
	if(!ring_bell(user))
		to_chat(user, "<span class='notice'>[src] is silent. Some idiot broke it.</span>")
	ring_cooldown = world.time + ring_cooldown_length
	return TRUE

/obj/item/desk_bell/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(!ishuman(M))
		return

	if(over_object == M)
		if(!remove_item_from_storage(M))
			M.unEquip(src)
		M.put_in_hands(src)
		anchored = FALSE

	add_fingerprint(M)

// Fix the clapper
/obj/item/desk_bell/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(broken_ringer)
		visible_message("<span class='notice'>[user] begins repairing [src]...</span>", "<span class='notice'>You begin repairing [src]...</span>")
		tool.play_tool_sound(src)
		if(tool.use_tool(src, user, 5 SECONDS))
			user.visible_message("<span class='notice'>[user] repairs [src].</span>", "<span class='notice'>You repair [src].</span>")
			playsound(user, 'sound/items/change_drill.ogg', 50, vary = TRUE)
			broken_ringer = FALSE
			times_rang = 0
			return TRUE
		return FALSE

// Deconstruct and Anchor
/obj/item/desk_bell/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(user.a_intent == INTENT_HARM && !in_inventory)
		visible_message("<span class='notice'>[user] begins taking apart [src]...</span>", "<span class='notice'>You begin taking apart [src]...</span>")
		if(tool.use_tool(src, user, 5 SECONDS, volume = tool.tool_volume))
			visible_message("<span class='notice'>[user] takes apart [src].</span>", "<span class='notice'>You take apart [src].</span>")
			playsound(user, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
			new /obj/item/stack/sheet/metal(drop_location(), 2)
			qdel(src)
			return TRUE
	if(!in_inventory)
		if(!anchored)
			user.visible_message("[user] begins securing [src]...", "You begin securing [src]...")
			if(!tool.use_tool(src, user, 3 SECONDS, volume = tool.tool_volume))
				return
			anchored = TRUE
		else
			user.visible_message("[user] begins unsecuring [src]...", "You begin unsecuring [src]...")
			if(!tool.use_tool(src, user, 3 SECONDS, volume = tool.tool_volume))
				return
			anchored = FALSE


/// Check if the clapper breaks, and if it does, break it
/obj/item/desk_bell/proc/check_clapper(mob/living/user)
	if(prob(times_rang / 50) && ring_cooldown_length)
		to_chat(user, "<span class='notice'>You hear [src]'s clapper fall off of its hinge. Nice job, you broke it.</span>")
		broken_ringer = TRUE

/// Ring the bell
/obj/item/desk_bell/proc/ring_bell(mob/living/user)
	if(broken_ringer)
		return FALSE
	check_clapper(user)
	// The lack of varying is intentional. The only variance occurs on the strike the bell breaks.
	playsound(src, ring_sound, 70, vary = broken_ringer, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	flick("desk_bell_ring", src)
	times_rang++
	return TRUE
