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
	/// The remote signaller that we're gonna activate to this bell
	var/obj/item/assembly/signaler/attached_signaler

/obj/item/desk_bell/examine(mob/user)
	. = ..()
	if(!isnull(attached_signaler))
		. += SPAN_NOTICE("There seems to be an antenna sticking out of the base.")

/obj/item/desk_bell/Destroy()
	if(!isnull(attached_signaler))
		var/turf/cur_turf = get_turf(src)
		if(cur_turf)
			forceMove(attached_signaler, get_turf(src))
		else
			qdel(attached_signaler)
		UnregisterSignal(attached_signaler, COMSIG_ASSEMBLY_PULSED)
		attached_signaler = null
	return ..()

/obj/item/desk_bell/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	// can only attach its on your person
	if(istype(I, /obj/item/assembly/signaler))
		if(!in_inventory)
			to_chat(user, SPAN_WARNING("[src] needs to be in your inventory if you want to attach [I] to it!"))
			return
		if(!isnull(attached_signaler))
			to_chat(user, SPAN_NOTICE("There's already a signaller attached!"))
			return
		var/obj/item/assembly/signaler/signal = I
		user.transfer_item_to(signal, src)
		attached_signaler = signal
		if(signal.receiving)
			RegisterSignal(attached_signaler, COMSIG_ASSEMBLY_PULSED, PROC_REF(on_signal))
		user.visible_message(
			SPAN_NOTICE("[user] attaches [signal] to [src]."),
			SPAN_NOTICE("You attach [signal] to [src].")
		)
	return ..()

/obj/item/desk_bell/proc/on_signal()
	SIGNAL_HANDLER  // COMSIG_ASSEMBLY_PULSED
	INVOKE_ASYNC(src, PROC_REF(try_ring), null, TRUE)

/obj/item/desk_bell/proc/try_ring(mob/user, from_signaler = FALSE)
	if(ring_cooldown > world.time || !anchored)
		return TRUE
	if(!ring_bell(user, from_signaler) && user)
		to_chat(user, SPAN_NOTICE("[src] is silent. Some idiot broke it."))
	ring_cooldown = world.time + ring_cooldown_length
	return TRUE

/obj/item/desk_bell/attack_hand(mob/living/user)
	if(in_inventory && ishuman(user))
		if(!user.get_active_hand())
			user.put_in_hands(src)
			return TRUE
	return try_ring(user)

/obj/item/desk_bell/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(HAS_TRAIT(M, TRAIT_HANDS_BLOCKED) || !Adjacent(M) || anchored)
		return
	if(!ishuman(M))
		return

	if(over_object == M)
		if(!remove_item_from_storage(M))
			M.unequip(src)
		M.put_in_hands(src)
		anchored = FALSE

	add_fingerprint(M)

// Fix the clapper
/obj/item/desk_bell/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(broken_ringer)
		visible_message(SPAN_NOTICE("[user] begins repairing [src]..."), SPAN_NOTICE("You begin repairing [src]..."))
		tool.play_tool_sound(src)
		if(tool.use_tool(src, user, 5 SECONDS))
			user.visible_message(SPAN_NOTICE("[user] repairs [src]."), SPAN_NOTICE("You repair [src]."))
			playsound(user, 'sound/items/change_drill.ogg', 50, vary = TRUE)
			broken_ringer = FALSE
			times_rang = 0
			return TRUE
		return FALSE

// Deconstruct and Anchor
/obj/item/desk_bell/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(user.a_intent == INTENT_HARM && !in_inventory)
		visible_message(SPAN_NOTICE("[user] begins taking apart [src]..."), SPAN_NOTICE("You begin taking apart [src]..."))
		if(tool.use_tool(src, user, 5 SECONDS, volume = tool.tool_volume))
			visible_message(SPAN_NOTICE("[user] takes apart [src]."), SPAN_NOTICE("You take apart [src]."))
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
		return

	if(attached_signaler)  // in inventory
		if(!tool.use_tool(src, user, 0.5 SECONDS, volume = tool.tool_volume))
			return TRUE
		to_chat(user, SPAN_NOTICE("You remove [attached_signaler]."))
		user.put_in_hands(attached_signaler)
		UnregisterSignal(attached_signaler, COMSIG_ASSEMBLY_PULSED)
		attached_signaler = null

/// Check if the clapper breaks, and if it does, break it
/obj/item/desk_bell/proc/check_clapper(mob/living/user)
	if(prob(times_rang / 50) && ring_cooldown_length)
		audible_message(SPAN_NOTICE("You hear [src]'s clapper fall off its hinge."))
		if(user)
			to_chat(user, SPAN_WARNING("Nice job, you broke it."))
		broken_ringer = TRUE

/// Ring the bell
/obj/item/desk_bell/proc/ring_bell(mob/living/user, from_signaler = FALSE)
	if(broken_ringer)
		return FALSE
	check_clapper(user)
	// The lack of varying is intentional. The only variance occurs on the strike the bell breaks.
	playsound(src, ring_sound, 70, vary = broken_ringer, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	flick("desk_bell_ring", src)
	if(attached_signaler && !from_signaler)
		attached_signaler.signal()
	times_rang++
	return TRUE

/obj/item/desk_bell/get_spooked()
	if(broken_ringer)
		return
	playsound(src, ring_sound, 70, vary = broken_ringer, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	flick("desk_bell_ring", src)
	return TRUE
