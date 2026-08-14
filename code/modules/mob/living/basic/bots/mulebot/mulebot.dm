/mob/living/basic/bot/mulebot
	name = "\improper MULEbot"
	desc = "A Multiple Utility Load Effector bot."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mulebot0"
	base_icon_state = "mulebot"

	light_color = "#ffcc99"
	light_power = 0.8

	health = 50
	maxHealth = 50

	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, STAMINA = 0, OXY = 0)
	density = TRUE
	mob_size = MOB_SIZE_LARGE
	move_resist = MOVE_FORCE_STRONG
	animate_movement = SLIDE_STEPS
	speed = 3

	a_intent = INTENT_HARM

	buckle_lying = 0
	buckle_prevents_pull = TRUE // No pulling loaded shit

	bot_mode_flags = ~BOT_MODE_ROUNDSTART_POSSESSION
	req_one_access = list(ACCESS_ROBOTICS, ACCESS_CARGO)
	radio_channel = "Supply"
	pass_flags = NONE
	bot_type = MULE_BOT

	path_image_color = "#7F5200"
	hud_type = /datum/hud/living/mulebot

	hackables = "obstacle detection circuits"
	possessed_message = "You are a MULEbot! Do your best to make sure that packages get to their destination!"
	ai_controller = /datum/ai_controller/basic_controller/bot/mulebot

	/// unique identifier in case there are multiple mulebots.
	var/id

	/// what we're transporting
	var/atom/movable/load
	/// who's riding us
	var/mob/living/passenger

	/// flags of mulebot mode
	var/mulebot_delivery_flags = MULEBOT_RETURN_MODE | MULEBOT_AUTO_PICKUP_MODE | MULEBOT_REPORT_DELIVERY_MODE

	///Internal Powercell
	var/obj/item/stock_parts/cell/cell
	/// How much power we use when we move.
	var/cell_move_power_usage = 0.0005 * 2500
	/// The amount of steps we should take until we rest for a time.
	var/num_steps = 0

	/// home destination, only used by mappers.
	var/home_destination = ""
	/// The mulebot's wires
	var/datum/wires/wires

	/// TODO: Replace this with all of tg's forensics and /datum/component/blood_walk
	var/bloodiness = 0
	var/currentBloodColor = "#A10808"
	var/currentDNA = null

/mob/living/basic/bot/mulebot/Initialize(mapload)
	. = ..()

	// TODO: port paranormal mulebots?

	wires = new /datum/wires/mulebot(src)
	var/obj/item/stock_parts/cell/new_cell = new(src)
	assign_cell(new_cell)
	ai_controller.set_blackboard_key(BB_MULEBOT_HOME_BEACON, "")
	#warn add /datum/component/riding/creature/mulebot
	AddElement(/datum/element/ridable)
	#warn maybe add TRAIT_NOMOBSWAP and TRAIT_COMBAT_MODE_LOCK-equivalent for intents
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))

	set_id(suffix)
	suffix = null
	if(name == "\improper MULEbot")
		name = "\improper MULEbot [id]"
	set_home(get_turf(src))
	ai_controller.update_able_to_run()
	update_appearance()

/mob/living/basic/bot/mulebot/Destroy()
	UnregisterSignal(src, COMSIG_MOVABLE_PRE_MOVE)
	unload()
	QDEL_NULL(cell)
	return ..()

/mob/living/basic/bot/mulebot/proc/assign_cell(atom/new_cell)
	cell = new_cell
	var/atom/movable/screen/mob_charge/charge_hud = hud_used?.screen_objects[HUD_MULEBOT_CHARGE]
	charge_hud?.update_battery_overlay(new_cell)
	charge_hud?.calculate_charge()


/mob/living/basic/bot/mulebot/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(bot_access_flags & BOT_COVER_MAINTS_OPEN && !is_ai_eye(user))
		wires.Interact(user)
		return
	if(wires.is_cut(WIRE_REMOTE_RX) && is_ai_eye(user))
		return

	return ..()

/mob/living/basic/bot/mulebot/examine(mob/user)
	. = ..()
	if(bot_access_flags & BOT_COVER_MAINTS_OPEN)
		if(cell)
			. += SPAN_NOTICE("It has \a [cell] installed.")
			. += SPAN_INFO("You can use a <b>crowbar</b> to remove it.")
		else
			. += SPAN_NOTICE("It has an empty compartment where a <b>power cell</b> can be installed.")
	if(load) //observer check is so we don't show the name of the ghost that's sitting on it to prevent metagaming who's ded.
		. += SPAN_NOTICE("\A [isobserver(load) ? "ghostly figure" : load] is on its load platform.")

/mob/living/basic/bot/mulebot/get_cell()
	return cell

/mob/living/basic/bot/mulebot/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(isturf(target) && isturf(loc) && loc.Adjacent(target) && load)
		unload(get_dir(loc, target))
	else
		return ..()

/mob/living/basic/bot/mulebot/turn_on(mob/user)
	if(bot_access_flags & BOT_COVER_MAINTS_OPEN)
		if(user)
			to_chat(user, SPAN_WARNING("[src]'s maintenance panel is open!"))
		return FALSE
	if(!has_power())
		if(user)
			to_chat(user, SPAN_WARNING("[src] has no power!"))
		return FALSE
	return ..()

/mob/living/basic/bot/mulebot/update_icon_state() //if you change the icon_state names, please make sure to update /datum/wires/mulebot/on_pulse() as well. <3
	. = ..()
	icon_state = "[base_icon_state][(bot_mode_flags & BOT_MODE_ON) ? wires?.is_cut(WIRE_MOB_AVOIDANCE) : "0"]"

/mob/living/basic/bot/mulebot/update_overlays()
	. = ..()
	if(bot_access_flags & BOT_COVER_MAINTS_OPEN)
		. += "[base_icon_state]-hatch"
	if(isnull(load) || ismob(load)) //mob offsets and such are handled by the riding component / buckling
		return
	var/mutable_appearance/load_overlay = mutable_appearance(load.icon, load.icon_state, layer + 0.01)
	load_overlay.pixel_y = initial(load.pixel_y) + 11
	. += load_overlay

/mob/living/basic/bot/mulebot/proc/handle_buzzing(datum/move_loop/has_target/jps/frustrations/source, frustration_counter)
	SIGNAL_HANDLER

	update_bot_mode(new_mode = BOT_BLOCKED)
	var/buzz_mode = frustration_counter >= source.maximum_frustrations ? MULEBOT_MOOD_ANNOYED : MULEBOT_MOOD_SIGH
	buzz(buzz_mode)

/mob/living/basic/bot/mulebot/handle_loop_movement(atom/movable/source, atom/oldloc, dir, forced) //incase we start moving again after being previously blocked, update our mode
	. = ..()
	if(mode != BOT_BLOCKED)
		return
	var/obj/machinery/navbeacon/beacon = ai_controller.current_movement_target
	if(!istype(beacon))
		return
	var/intended_mode = beacon.location == ai_controller.blackboard[BB_MULEBOT_HOME_BEACON] ? BOT_GO_HOME : BOT_DELIVER
	update_bot_mode(new_mode = intended_mode)

///Noises that mulebots make
/mob/living/basic/bot/mulebot/proc/buzz(type)
	switch(type)
		if(MULEBOT_MOOD_SIGH)
			audible_message(SPAN_HEAR("[src] makes a sighing buzz."))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		if(MULEBOT_MOOD_ANNOYED)
			audible_message(SPAN_HEAR("[src] makes an annoyed buzzing sound."))
			playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
		if(MULEBOT_MOOD_DELIGHT)
			audible_message(SPAN_HEAR("[src] makes a delighted ping!"))
			playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
		if(MULEBOT_MOOD_CHIME)
			audible_message(SPAN_HEAR("[src] makes a chiming sound!"))
			playsound(src, 'sound/machines/chime.ogg', 50, FALSE)
	flick("[base_icon_state]1", src)

/// returns true if the bot is fully powered.
/mob/living/basic/bot/mulebot/proc/has_power()
	return cell && cell.charge > 0 && (!wires.is_cut(WIRE_MAIN_POWER1) && !wires.is_cut(WIRE_MAIN_POWER2))

/mob/living/basic/bot/mulebot/get_bot_data()
	. = list(
	"name" = name, // name is the actual bot name. PAI may change it. Mulebot suffix system uses bot_name // WHY, WHO MADE THIS
	"model" = "MULE", //
	"status" = mode, // BOT_IDLE is 0, using mode_name will bsod tgui
	"location" = get_area(src),
	"on" = bot_mode_flags & BOT_MODE_ON,
	"UID" = UID(),
	)
