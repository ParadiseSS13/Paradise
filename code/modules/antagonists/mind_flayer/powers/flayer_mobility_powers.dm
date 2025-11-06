//Basically shadow anchor, but the entry and exit point must be computers. I'm not in your walls I'm in your PC
/datum/spell/flayer/computer_recall
	name = "Traceroute"
	desc = "Allows us to cast a mark to a computer. To recall us to this computer, cast this next to a different computer. To check your current mark: Alt click."
	base_cooldown = 60 SECONDS
	action_icon_state = "pd_cablehop"
	upgrade_info = "Halve the time it takes to recharge."
	power_type = FLAYER_PURCHASABLE_POWER
	category = FLAYER_CATEGORY_INTRUDER
	centcom_cancast = FALSE
	stage = 2
	base_cost = 125
	static_upgrade_increase = 25
	max_level = 2
	should_recharge_after_cast = FALSE
	/// The console we currently have a mark on
	var/obj/marked_computer
	/// The typecache of things we are allowed to teleport to and from
	var/static/list/machine_typecache = list()

/datum/spell/flayer/computer_recall/New()
	. = ..()
	if(length(machine_typecache))
		return
	machine_typecache = typecacheof(list(
									/obj/machinery/computer,
									/obj/machinery/power/apc,
									/obj/machinery/alarm,
									/obj/machinery/autolathe,
									/obj/machinery/newscaster,
									/obj/machinery/mecha_part_fabricator,
									/obj/machinery/status_display,
									/obj/machinery/requests_console,
									/obj/item/radio/intercom,
									/obj/machinery/economy/vending,
									/obj/machinery/economy/atm,
									/obj/machinery/chem_dispenser,
									/obj/machinery/chem_master,
									/obj/machinery/reagentgrinder,
									/obj/machinery/sleeper,
									/obj/machinery/bodyscanner,
									/obj/machinery/photocopier, // HI YES ONE FLAYER FAXED TO MY OFFICE PLEASE
									/obj/machinery/barsign
								))

/datum/spell/flayer/computer_recall/Destroy(force, ...)
	marked_computer = null
	return ..()

/datum/spell/flayer/computer_recall/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /obj
	T.try_auto_target = TRUE
	T.range = 1
	return T

/datum/spell/flayer/computer_recall/cast(list/targets, mob/living/user)
	var/obj/target
	for(var/obj/thing as anything in targets)
		if(is_type_in_typecache(thing, machine_typecache))
			target = thing
			break

	if(!target)
		flayer.send_swarm_message("That is not a valid target!")
		return

	if(!marked_computer)
		marked_computer = target
		flayer.send_swarm_message("You discreetly tap [targets[1]] and mark it as your home computer.")
		return

	if(SEND_SIGNAL(user, COMSIG_MOVABLE_TELEPORTING, get_turf(user)) & COMPONENT_BLOCK_TELEPORT)
		return FALSE

	var/turf/start_turf = get_turf(target)
	var/turf/end_turf = get_turf(marked_computer)
	if(end_turf.z != start_turf.z)
		flayer.send_swarm_message("The connection between [target] and [marked_computer] is too unstable!")
	if(!is_teleport_allowed(start_turf.z) || !is_teleport_allowed(end_turf.z))
		return
	user.visible_message(
		"<span class='danger'>[user] de-materializes and jumps through the screen of [target]!</span>",
		"<span class='warning'>You de-materialize and jump into [target]!")

	user.set_body_position(STANDING_UP)
	var/matrix/previous = user.transform
	var/matrix/shrank = user.transform.Scale(0.25)
	var/direction = get_dir(user, target)
	var/list/direction_signs = get_signs_from_direction(direction)
	animate(user, 0.5 SECONDS, 0, transform = shrank, pixel_x = 32 * direction_signs[1], pixel_y = 32 * direction_signs[2], dir = direction, easing = BACK_EASING|EASE_IN) //Blue skadoo, we can too!
	user.Immobilize(0.5 SECONDS)
	sleep(0.5 SECONDS)
	target.Beam(marked_computer, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 3 SECONDS, maxdistance = INFINITY)
	playsound(start_turf, 'sound/items/pshoom.ogg', 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	playsound(end_turf, 'sound/items/pshoom.ogg', 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	user.forceMove(end_turf)
	user.pixel_x = 0 //Snap back to the center, then animate the un-shrinking
	user.pixel_y = 0
	user.set_body_position(STANDING_UP)
	animate(user, 0.5 SECONDS, 0, transform = previous)
	user.visible_message(
		"<span class='warning'>[user] suddenly crawls through the monitor of [marked_computer]!</span>",
		"<span class='notice'>As you reform yourself at [marked_computer] you feel the mark you left on it fade.</span>")
	marked_computer = null
	cooldown_handler.start_recharge()

/datum/spell/flayer/computer_recall/AltClick(mob/user)
	if(!marked_computer)
		flayer.send_swarm_message("You do not current have a marked computer.")
		return
	flayer.send_swarm_message("Your current mark is [marked_computer].")

/datum/spell/flayer/computer_recall/on_apply()
	..()
	cooldown_handler.recharge_duration -= 30 SECONDS

/*
 * Ok so this is slightly a stretch, but it hinders enemy mobility while not hindering the flayer
 * It works like the hemomancer wall, creating up to 3 temporary walls
 * Obtained for free in the Destroyer tree when reaching stage 3
 */
/datum/spell/flayer/techno_wall
	name = "Crystalized Firewall"
	desc = "Allows us to create a wall between two points. The wall is fragile and allows only ourselves to pass through."
	base_cooldown = 60 SECONDS
	action_icon_state = "pd_cablehop"
	upgrade_info = "Double the health of the barrier by reinforcing it with ICE."
	category = FLAYER_CATEGORY_DESTROYER
	base_cost = 100
	current_cost = 100
	max_level = 2
	should_recharge_after_cast = FALSE
	/// How big can we make our wall
	var/max_walls = 3
	/// Starting turf for the wall. Should be nulled after each cast or the cancelling of a cast
	var/turf/start_turf

/datum/spell/flayer/techno_wall/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.allowed_type = /atom
	T.try_auto_target = FALSE
	return T

/datum/spell/flayer/techno_wall/remove_ranged_ability(mob/user, msg)
	. = ..()
	if(msg) // this is only true if the user intentionally turned off the spell
		start_turf = null
		should_recharge_after_cast = FALSE

/datum/spell/flayer/techno_wall/should_remove_click_intercept()
	return start_turf

/datum/spell/flayer/techno_wall/cast(list/targets, mob/user)
	var/turf/target_turf = get_turf(targets[1])
	if(target_turf == start_turf)
		flayer.send_swarm_message("<span class='notice'>You deselect the targeted turf.</span>")
		start_turf = null
		should_recharge_after_cast = FALSE
		return
	if(!start_turf)
		start_turf = target_turf
		should_recharge_after_cast = TRUE
		return
	var/wall_count
	for(var/turf/T as anything in get_line(target_turf, start_turf))
		if(wall_count >= max_walls)
			break
		new /obj/structure/tech_barrier(T, 100 * level)
		wall_count++

	start_turf = null
	should_recharge_after_cast = FALSE

/obj/structure/tech_barrier
	name = "crystalized firewall"
	desc = "a strange structure of crystalised ... firewall? It's slowly melting away..."
	max_integrity = 100
	icon_state = "blood_barrier"
	icon = 'icons/effects/vampire_effects.dmi'
	density = TRUE
	anchored = TRUE
	alpha = 200
	var/upgraded_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, RAD = 50, FIRE = 50, ACID = 50)

/obj/structure/tech_barrier/Initialize(mapload, health)
	. = ..()
	if(health)
		max_integrity = health
		obj_integrity = health
	START_PROCESSING(SSobj, src)
	var/icon/our_icon = icon('icons/effects/vampire_effects.dmi', "blood_barrier")
	var/icon/alpha_mask
	alpha_mask = new('icons/effects/effects.dmi', "scanline") //Scanline effect.
	our_icon.AddAlphaMask(alpha_mask) //Finally, let's mix in a distortion effect.
	icon = our_icon
	if(health > 100)
		name = "frozen ICE-firewall"
		desc = "a crystalized... ICE-9-Firewall? It's slowly melting away..."
		color = list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 1,1,1,1, 0,0,0,0)
		armor = armor.setRating(50, 50, 50, 50, 50, 50, 50, 50, 0)
	else
		color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0)
	var/mutable_appearance/theme_icon = mutable_appearance('icons/misc/pic_in_pic.dmi', "room_background", FLOAT_LAYER - 1, appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon

/obj/structure/tech_barrier/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/tech_barrier/process()
	take_damage(20, sound_effect = FALSE)

/obj/structure/tech_barrier/CanPass(atom/movable/mover, turf/target)
	return IS_MINDFLAYER(mover)
