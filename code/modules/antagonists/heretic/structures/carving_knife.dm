// The rune carver, a heretic knife that can draw rune traps.
/obj/item/melee/rune_carver
	name = "carving knife"
	desc = "A small knife made of cold steel, pure and perfect. Its sharpness can carve into titanium itself - \
		but only few can evoke the dangers that lurk beneath reality."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "rune_carver"
	sharp = TRUE
	w_class = WEIGHT_CLASS_SMALL
	force = 10
	throwforce = 20
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "rends")
	actions_types = list(/datum/action/item_action/rune_shatter)
	throw_speed = 4
	embedded_pain_multiplier = 5
	w_class = WEIGHT_CLASS_SMALL
	embed_chance = 75
	embedded_fall_chance = 2
	new_attack_chain = TRUE

	/// Whether we're currently drawing a rune
	var/drawing = FALSE
	/// Max amount of runes that can be drawn
	var/max_rune_amt = 3
	/// A list of uid's to all of ourc urrent runes
	var/list/current_runes = list()


/obj/item/melee/rune_carver/examine(mob/user)
	. = ..()
	for(var/rune_ref as anything in current_runes)
		if(!locateUID(rune_ref))
			current_runes -= rune_ref
	if(!IS_HERETIC_OR_MONSTER(user) && !isobserver(user))
		return

	. += SPAN_NOTICE("<b>[length(current_runes)] / [max_rune_amt]</b> total carvings have been drawn.")
	. += SPAN_INFO("The following runes can be carved:")
	for(var/obj/structure/trap/eldritch/trap as anything in subtypesof(/obj/structure/trap/eldritch))
		var/potion_string = SPAN_NOTICE("\tThe " + initial(trap.name) + " - " + initial(trap.carver_tip) + "")
		. += potion_string

/obj/item/melee/rune_carver/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!IS_HERETIC_OR_MONSTER(user))
		return NONE
	if(!isfloorturf(interacting_with))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(try_carve_rune), interacting_with, user)
	return ITEM_INTERACT_COMPLETE

/*
 * Begin trying to carve a rune. Go through a few checks, then call do_carve_rune if successful.
 */
/obj/item/melee/rune_carver/proc/try_carve_rune(turf/target_turf, mob/user)
	if(drawing)
		to_chat(user, SPAN_HIEROPHANT_WARNING("You are already carving."))
		return

	if(locate(/obj/structure/trap/eldritch) in range(1, target_turf))
		to_chat(user, SPAN_HIEROPHANT_WARNING("You are too close to another carving!"))
		return

	for(var/rune_ref as anything in current_runes)
		if(!locateUID(rune_ref))
			current_runes -= rune_ref

	if(length(current_runes) >= max_rune_amt)
		to_chat(user, SPAN_HIEROPHANT_WARNING("This knife has too many active carvings!"))
		return

	drawing = TRUE
	do_carve_rune(target_turf, user)
	drawing = FALSE

/*
 * The actual proc that handles selecting the rune to draw and creating it.
 */
/obj/item/melee/rune_carver/proc/do_carve_rune(turf/target_turf, mob/user)
	// Assoc list of [name] to [image] for the radial (to show tooltips)
	var/static/list/choices = list()
	// Assoc list of [name] to [path] for after the radial
	var/static/list/names_to_path = list()
	if(!choices.len || !names_to_path.len)
		for(var/obj/structure/trap/eldritch/trap as anything in subtypesof(/obj/structure/trap/eldritch))
			names_to_path[initial(trap.name)] = trap
			choices[initial(trap.name)] = image(icon = initial(trap.icon), icon_state = initial(trap.icon_state))

	var/picked_choice = show_radial_menu(
		user,
		user,
		choices,
		require_near = TRUE,
		)

	if(isnull(picked_choice))
		return

	var/to_make = names_to_path[picked_choice]
	if(!ispath(to_make, /obj/structure/trap/eldritch))
		CRASH("[type] attempted to create a rune of incorrect type! (got: [to_make])")
	to_chat(user, SPAN_HIEROPHANT("Carving [picked_choice]..."))
	user.playsound_local(target_turf, 'sound/weapons/blade_sheath.ogg', 50, TRUE)
	if(!do_after(user, 5 SECONDS, target = target_turf))
		return
	var/obj/structure/trap/eldritch/new_rune = new to_make(target_turf, user)
	current_runes += new_rune.UID()

/datum/action/item_action/rune_shatter
	name = "Rune Break"
	desc = "Destroys all runes carved by this blade."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	background_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "rune_break"
	background_icon_state = "bg_heretic"

/datum/action/item_action/rune_shatter/New(Target)
	. = ..()
	if(!istype(Target, /obj/item/melee/rune_carver))
		qdel(src)
		return

/datum/action/item_action/rune_shatter/Grant(mob/granted)
	if(!IS_HERETIC_OR_MONSTER(granted))
		return

	return ..()

/datum/action/item_action/rune_shatter/IsAvailable(show_message = FALSE)
	. = ..()
	if(!.)
		return
	if(!IS_HERETIC_OR_MONSTER(owner))
		return FALSE
	var/obj/item/melee/rune_carver/target_sword = target
	if(!length(target_sword.current_runes))
		return FALSE

/datum/action/item_action/rune_shatter/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	owner.playsound_local(get_turf(owner), 'sound/magic/blind.ogg', 50, TRUE)
	var/obj/item/melee/rune_carver/target_sword = target
	for(var/rune_ref as anything in target_sword.current_runes)
		if(locateUID(rune_ref))
			var/rune_to_kill = locateUID(rune_ref)
			qdel(rune_to_kill)
	target_sword.current_runes = list()
	target_sword.SpinAnimation(5, 1)
	return TRUE

//General trap
/obj/structure/trap
	name = "IT'S A TRAP"
	desc = "Stepping on me is a guaranteed bad day."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "trap"
	anchored = TRUE
	alpha = 30 //initially quite hidden when not "recharging"
	flags = NO_SCREENTIPS //fuck you
	var/flare_message = "The trap flares brightly!"
	var/last_trigger = 0
	var/time_between_triggers = 1 MINUTES
	var/charges = INFINITY
	var/antimagic_flags = MAGIC_RESISTANCE

	var/static/list/ignore_typecache
	var/list/mob/immune_minds = list()

	var/sparks = TRUE
	var/datum/effect_system/spark_spread/spark_system

/obj/structure/trap/Initialize(mapload)
	. = ..()
	flare_message = "[src] flares brightly!"
	spark_system = new
	spark_system.set_up(4,1,src)
	spark_system.attach(src)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	if(isnull(ignore_typecache))
		ignore_typecache = typecacheof(list(
			/obj/effect,
			/mob/dead,
		))

/obj/structure/trap/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/structure/trap/examine(mob/user)
	. = ..()
	if(!isliving(user))
		return
	if(user.mind && (user.mind in immune_minds))
		return
	if(get_dist(user, src) <= 1)
		. += SPAN_WARNING("You reveal [src]!")
		flare()

/obj/structure/trap/proc/flare()
	// Makes the trap visible, and starts the cooldown until it's
	// able to be triggered again.
	visible_message(SPAN_WARNING("[flare_message]"))
	if(sparks)
		spark_system.start()
	alpha = 200
	last_trigger = world.time
	charges--
	if(charges <= 0)
		animate(src, alpha = 0, time = 1 SECONDS)
		QDEL_IN(src, 1 SECONDS)
	else
		animate(src, alpha = initial(alpha), time = time_between_triggers)

/obj/structure/trap/proc/on_entered(datum/source, atom/movable/victim)
	SIGNAL_HANDLER
	if(last_trigger + time_between_triggers > world.time)
		return
	// Don't want the traps triggered by sparks, ghosts or projectiles.
	if(is_type_in_typecache(victim, ignore_typecache))
		return
	if(ismob(victim))
		var/mob/mob_victim = victim
		if(mob_victim.mind in immune_minds)
			return
		if(mob_victim.can_block_magic(antimagic_flags))
			flare()
			return
	if(charges <= 0)
		return
	flare()
	if(isliving(victim))
		trap_effect(victim)

/obj/structure/trap/proc/trap_effect(mob/living/victim)
	return


// The actual rune traps the knife draws.
/obj/structure/trap/eldritch
	name = "elder carving"
	desc = "Collection of unknown symbols, they remind you of days long gone..."
	max_integrity = 60
	/// A tip displayed to heretics who examine the rune carver. Explains what the rune does.
	var/carver_tip
	/// UID of trap owner mob
	var/owner

/obj/structure/trap/eldritch/Initialize(mapload, atom/new_owner)
	. = ..()
	if(new_owner)
		owner = new_owner.UID()

/obj/structure/trap/eldritch/on_entered(datum/source, atom/movable/entering_atom)
	if(!isliving(entering_atom))
		return
	var/mob/living/living_mob = entering_atom
	if(living_mob.UID() == owner)
		return
	if(IS_HERETIC_OR_MONSTER(living_mob))
		return
	return ..()

/obj/structure/trap/eldritch/attacked_by(obj/item/weapon, mob/living/user)
	if(istype(weapon, /obj/item/melee/rune_carver) || istype(weapon, /obj/item/nullrod))
		playsound(src, 'sound/weapons/blade_sheath.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
		qdel(src)

	return ..()

/obj/structure/trap/eldritch/alert
	name = "alert carving"
	icon_state = "alert_rune"
	alpha = 10
	time_between_triggers = 5 SECONDS
	sparks = FALSE
	carver_tip = "A nearly invisible rune that, when stepped on, alerts the carver who triggered it and where."

/obj/structure/trap/eldritch/alert/trap_effect(mob/living/victim)
	var/mob/living/real_owner = locateUID(owner)
	if(real_owner)
		to_chat(real_owner, SPAN_WARNING("[victim.real_name] has stepped foot on the alert rune in [get_area(src)]!"))
		real_owner.playsound_local(get_turf(real_owner), 'sound/effects/curse.ogg', 50, TRUE)

/obj/structure/trap/eldritch/tentacle
	name = "grasping carving"
	icon_state = "tentacle_rune"
	time_between_triggers = 45 SECONDS
	charges = 1
	carver_tip = "When stepped on, causes heavy damage leg damage and immobilizes the victim for 5 seconds. Has 1 charge."

/obj/structure/trap/eldritch/tentacle/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.Immobilize(5 SECONDS)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_R_LEG)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_L_LEG)
	playsound(src, 'sound/misc/demon_attack1.ogg', 75, TRUE)

/obj/structure/trap/eldritch/mad
	name = "mad carving"
	icon_state = "madness_rune"
	time_between_triggers = 20 SECONDS
	charges = 2
	carver_tip = "When stepped on, causes heavy stamina damage, blindness, and a variety of ailments to the victim. Has 2 charges."

/obj/structure/trap/eldritch/mad/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.apply_damage(80, STAMINA)
	carbon_victim.Silence(20 SECONDS)
	carbon_victim.HereticSlur(1 MINUTES)
	carbon_victim.Confused(5 SECONDS)
	carbon_victim.Jitter(20 SECONDS)
	carbon_victim.Dizzy(40 SECONDS)
	carbon_victim.EyeBlind(4 SECONDS)
	playsound(src, 'sound/magic/blind.ogg', 75, TRUE)
