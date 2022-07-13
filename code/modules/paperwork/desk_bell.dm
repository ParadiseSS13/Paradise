// A receptionist's bell

/obj/structure/desk_bell
	name = "desk bell"
	desc = "The cornerstone of any customer service job. You feel an unending urge to ring it."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "desk_bell"
	layer = OBJ_LAYER
	anchored = FALSE
	pass_flags = PASSTABLE // Able to place on tables
	max_integrity = 5000 // To make attacking it not instantly break it
	/// The amount of times this bell has been rang, used to check the chance it breaks
	var/times_rang = 0
	/// Is this bell broken?
	var/broken_ringer = FALSE
	/// Last time the bell was rung, needed for paradise port.
	var/last_ring = 0
	/// The length of the cooldown. Setting it to 0 will skip all cooldowns alltogether.
	var/ring_cooldown_length = 0.3 SECONDS // This is here to protect against tinnitus.
	/// The sound the bell makes
	var/ring_sound = 'sound/machines/bell.ogg'

/obj/structure/desk_bell/Initialize(mapload)
	. = ..()

/obj/structure/desk_bell/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(last_ring + ring_cooldown_length > world.time)
		return TRUE
	if(!ring_bell(user))
		to_chat(user, "<span class='notice'>[src] is silent. Some idiot broke it.</span>")
	if(ring_cooldown_length)
		last_ring = world.time
	return TRUE

/obj/structure/desk_bell/attackby(obj/item/weapon, mob/living/user, params)
	. = ..()
	times_rang += weapon.force
	ring_bell(user)

// Fix the clapper
/obj/structure/desk_bell/screwdriver_act(mob/living/user, obj/item/tool)
	if(broken_ringer)
		to_chat(user, "<span class='notice'>You begin repairing the bell...</span>")
		tool.play_tool_sound(src)
		if(tool.use_tool(src, user, 5 SECONDS))
			user.visible_message("<span class='notice'>[user] repairs the bell.</span>", "<span class='notice'>You repair the bell.</span>")
			playsound(user, 'sound/items/change_drill.ogg', 50, vary = TRUE)
			broken_ringer = FALSE
			times_rang = 0
			return TRUE
		return FALSE
	return ..()

// Deconstruct
/obj/structure/desk_bell/wrench_act(mob/living/user, obj/item/tool)
	to_chat(user, "<span class='notice'>You begin taking apart the bell...</span>")
	if(tool.use_tool(src, user, 5 SECONDS))
		to_chat(user, "<span class='notice'>You disassemble the bell...</span>")
		playsound(user, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		if(!broken_ringer) // Drop 2 if it's not broken.
			new /obj/item/stack/sheet/metal(drop_location())
		new /obj/item/stack/sheet/metal(drop_location())
		qdel(src)
		return TRUE
	return ..()

/// Check if the clapper breaks, and if it does, break it
/obj/structure/desk_bell/proc/check_clapper(mob/living/user)
	if(((times_rang >= 10000) || prob(times_rang/100)) && ring_cooldown_length)
		to_chat(user, "<span class='notice'>You hear [src]'s clapper fall off of its hinge. Nice job, you broke it.")
		broken_ringer = TRUE

/// Ring the bell
/obj/structure/desk_bell/proc/ring_bell(mob/living/user)
	if(broken_ringer)
		return FALSE
	check_clapper(user)
	// The lack of varying is intentional. The only variance occurs on the strike the bell breaks.
	playsound(src, ring_sound, 70, vary = broken_ringer, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	flick("desk_bell_ring", src)
	times_rang++
	return TRUE
