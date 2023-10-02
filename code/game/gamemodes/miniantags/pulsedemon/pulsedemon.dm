// original implementation: https://ss13.moe/wiki/index.php/Pulse_Demon

#define PULSEDEMON_PLATING_SPARK_CHANCE 20
#define PULSEDEMON_APC_CHARGE_MULTIPLIER 2
#define PULSEDEMON_SMES_DRAIN_MULTIPLIER 10
#define ALERT_CATEGORY_NOPOWER "pulse_nopower"
#define ALERT_CATEGORY_NOREGEN "pulse_noregen"

#define PULSEDEMON_SOURCE_DRAIN_INVALID (-1)

/mob/living/simple_animal/demon/pulse_demon
	name = "pulse demon"
	real_name = "pulse demon"
	desc = "A strange electrical apparition that lives in wires."
	gender = NEUTER
	speak_chance = 20

	damage_coeff = list(BRUTE = 0, BURN = 0, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0) // Pulse demons take damage from nothing

	emote_hear = list("vibrates", "sizzles")
	speak_emote = list("modulates")

	icon = 'icons/mob/animal.dmi'
	icon_state = "pulsedem"
	icon_living = "pulsedem"
	icon_dead = "pulsedem"
	response_help = "reaches their hand into"
	response_disarm = "pushes their hand through"
	response_harm = "punches their fist through"
	deathmessage = "fizzles out into faint sparks, leaving only a slight trail of smoke..."
	level = 1
	plane = FLOOR_PLANE
	layer = ABOVE_PLATING_LAYER

	maxHealth = 50
	health = 50
	speed = -0.5
	flying = TRUE
	mob_size = MOB_SIZE_TINY
	density = FALSE
	del_on_death = TRUE

	attacktext = "electrocutes"
	attack_sound = "sparks"
	a_intent = INTENT_HARM
	harm_intent_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	pass_flags = PASSDOOR
	stop_automated_movement = TRUE
	has_unlimited_silicon_privilege = TRUE
	// this makes the demon able to speak through holopads, due to the overriden say, PD cannot speak normally regardless
	universal_speak = TRUE

	/// List of sounds that is picked from when the demon speaks.
	var/list/speech_sounds = list("sound/voice/pdvoice1.ogg", "sound/voice/pdvoice2.ogg", "sound/voice/pdvoice3.ogg")
	/// List of sounds that is picked from when the demon dies or is EMP'd.
	var/list/hurt_sounds = list("sound/voice/pdwail1.ogg", "sound/voice/pdwail2.ogg", "sound/voice/pdwail3.ogg")

	/// Current quantity of power the demon currently holds, spent while purchasing, upgrading or using spells or upgrades. Use adjust_charge to modify this.
	var/charge = 1000
	/// Maximum quantity of power the demon can hold at once.
	var/maxcharge = 1000
	/// Book keeping for objective win conditions.
	var/charge_drained = 0
	/// Controls whether the demon will drain power from sources. Toggled by a spell.
	var/do_drain = TRUE
	/// Amount of power (in watts) to drain from power sources every Life tick.
	var/power_drain_rate = 1000
	/// Maximum value for power_drain_rate based on upgrades.
	var/max_drain_rate = 1000

	/// Amount of power (in watts) required to regenerate health.
	var/power_per_regen = 1000
	/// Amount of health lost per Life tick when the power requirement was not met.
	var/health_loss_rate = 5
	/// Amount of health regenerated per Life tick when the power requirement was met.
	var/health_regen_rate = 3
	/// Lock health regeneration while this is not 0, decreases by 1 every Life tick.
	var/regen_lock = 0
	/// Tracking to prevent multiple EMPs in the same tick from instakilling a demon.
	var/emp_debounce = FALSE

	/// Controls whether the demon can move outside of cables. Toggled by a spell.
	var/can_exit_cable = FALSE
	/// Speed used while moving inside cables.
	var/inside_cable_speed = -0.5
	/// Speed used while moving outside cables. Can be upgraded.
	var/outside_cable_speed = 5

	/// The time it takes to hijack APCs and cyborgs.
	var/hijack_time = 30 SECONDS

	/// The color of light the demon emits. The range of the light is proportional to charge.
	var/glow_color = "#bbbb00"

	/// Area being controlled, should be maintained as long as the demon does not move outside a container (APC, object, robot, bot).
	var/area/controlling_area
	/// Inhabited cable, only maintained while on top of the cable.
	var/obj/structure/cable/current_cable
	/// Inhabited power source, maintained while inside, or while inside its area if it is an APC.
	var/obj/machinery/power/current_power
	/// Inhabited item, only items which can be used in rechargers can be hijacked. Only maintained while inside the item.
	var/obj/item/current_weapon
	/// Inhabited cyborg, only maintained while inside the cyborg.
	var/mob/living/silicon/robot/current_robot
	/// Inhabited bot, only maintained while inside the bot.
	var/mob/living/simple_animal/bot/current_bot

	/// Delay tracker for movement inside bots.
	var/bot_movedelay = 0
	/// A cyborg that has already been hijacked can be re-entered instantly.
	var/list/hijacked_robots = list()

	/// Images of cables currently being shown on the client.
	var/list/cable_images = list()
	/// Images of APCs currently being shown on the client.
	var/list/apc_images = list()
	/// List of all previously hijacked APCs.
	var/list/hijacked_apcs = list()
	/// Reference to the APC currently being hijacked.
	var/obj/machinery/power/apc/apc_being_hijacked

/mob/living/simple_animal/demon/pulse_demon/Initialize(mapload)
	. = ..()
	if(!mapload)
		name += " ([rand(100, 999)])"
		real_name = name

	remove_from_all_data_huds()
	ADD_TRAIT(src, TRAIT_AI_UNTRACKABLE, PULSEDEMON_TRAIT)
	flags_2 |= RAD_NO_CONTAMINATE_2

	// don't step on me
	RegisterSignal(src, COMSIG_CROSSED_MOVABLE, PROC_REF(try_cross_shock))
	RegisterSignal(src, COMSIG_MOVABLE_CROSSED, PROC_REF(try_cross_shock))

	// drop demon onto ground if its loc is a non-turf and gets deleted
	RegisterSignal(src, COMSIG_PARENT_PREQDELETED, PROC_REF(deleted_handler))

	RegisterSignal(SSdcs, COMSIG_GLOB_CABLE_UPDATED, PROC_REF(cable_updated_handler))

	RegisterSignal(src, COMSIG_BODY_TRANSFER_TO, PROC_REF(make_pulse_antagonist))

	current_power = locate(/obj/machinery/power) in loc
	// in the case that both current_power and current_cable are null, the pulsedemon will die the next tick
	if(!current_power)
		current_cable = locate(/obj/structure/cable) in loc
	else
		forceMove(current_power)
	update_glow()
	playsound(get_turf(src), 'sound/effects/eleczap.ogg', 30, TRUE)
	give_spells()
	whisper_action.button_icon_state = "pulse_whisper"
	whisper_action.background_icon_state = "bg_pulsedemon"

/mob/living/simple_animal/demon/pulse_demon/proc/deleted_handler(our_demon, force)
	SIGNAL_HANDLER
	// assume normal deletion if we're on a turf, otherwise deletion could be inherited from loc
	if(force || isnull(loc) || isturf(loc))
		return FALSE
	// if we did actually die, simple_animal/death will set del_on_death to FALSE before calling qdel
	if(!del_on_death)
		return FALSE
	exit_to_turf()
	return TRUE

/mob/living/simple_animal/demon/pulse_demon/proc/cable_updated_handler(SSdcs, turf/T)
	SIGNAL_HANDLER
	if(cable_images[T])
		var/list/turf_images = cable_images[T]
		for(var/image/current_image in turf_images)
			client?.images -= current_image
		turf_images.Cut()
	else
		cable_images[T] = list()

	for(var/obj/structure/cable/C in T)
		var/image/cable_image = image(C, C, layer = ABOVE_LIGHTING_LAYER, dir = C.dir)
		cable_image.plane = ABOVE_LIGHTING_PLANE
		cable_images[T] += cable_image
		client?.images += cable_image

/mob/living/simple_animal/demon/pulse_demon/proc/apc_deleted_handler(obj/machinery/power/apc/A, force)
	SIGNAL_HANDLER
	hijacked_apcs -= A

/mob/living/simple_animal/demon/pulse_demon/Destroy()
	cable_images.Cut()
	apc_images.Cut()

	controlling_area = null
	current_bot = null
	current_cable = null
	current_power = null
	current_robot = null
	current_weapon = null
	apc_being_hijacked = null
	hijacked_apcs = null
	hijacked_robots = null

	return ..()

/mob/living/simple_animal/demon/pulse_demon/Login()
	. = ..()
	update_cableview()

/mob/living/simple_animal/demon/pulse_demon/proc/make_pulse_antagonist(demon)
	SIGNAL_HANDLER
	mind.assigned_role = SPECIAL_ROLE_DEMON
	mind.special_role = SPECIAL_ROLE_DEMON
	give_objectives()

/mob/living/simple_animal/demon/pulse_demon/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("glow_color")
			update_glow()
		if("charge")
			// automatically adjusts maxcharge to allow the new value
			adjust_charge(var_value - charge, TRUE)
			return TRUE
	return ..()

/mob/living/simple_animal/demon/pulse_demon/forceMove(atom/destination)
	var/old_location = loc
	. = ..()
	current_weapon = null
	current_robot = null
	if(current_bot)
		current_bot.hijacked = FALSE
	current_bot = null
	if(istype(old_location, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = old_location
		// only set rigged if there are no remaining demons in the cell
		C.rigged = !(locate(/mob/living/simple_animal/demon/pulse_demon) in old_location)
	if(istype(loc, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = loc
		C.rigged = FALSE

/mob/living/simple_animal/demon/pulse_demon/proc/give_objectives()
	if(!mind)
		return
	mind.wipe_memory()
	var/list/greeting = list(src, "<br>")
	greeting.Add("<span class='warning'><font size=3><b>You are a pulse demon.</b></font></span>")
	greeting.Add("<b>A being made of pure electrical energy, you travel through the station's wires and infest machinery.</b>")
	greeting.Add("<b>Navigate the station's power cables to find power sources to steal from, and hijack APCs to interact with their connected machines.</b>")
	greeting.Add("<b>If the wire or power source you're connected to runs out of power you'll start losing health and eventually die, but you are otherwise immune to damage.</b>")
	greeting.Add("<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Pulse_Demon)</span>")
	to_chat(src, greeting.Join("<br>"))
	for(var/datum/objective/new_obj in list(/datum/objective/pulse_demon/infest, /datum/objective/pulse_demon/drain, /datum/objective/pulse_demon/tamper))
		mind.add_mind_objective(new_obj)
	mind.announce_objectives(title = FALSE)
	SSticker.mode.traitors |= mind
	return

/mob/living/simple_animal/demon/pulse_demon/proc/give_spells()
	AddSpell(new /obj/effect/proc_holder/spell/pulse_demon/cycle_camera)
	AddSpell(new /obj/effect/proc_holder/spell/pulse_demon/toggle/do_drain(do_drain))
	AddSpell(new /obj/effect/proc_holder/spell/pulse_demon/toggle/can_exit_cable(can_exit_cable))
	AddSpell(new /obj/effect/proc_holder/spell/pulse_demon/cablehop)
	AddSpell(new /obj/effect/proc_holder/spell/pulse_demon/emagtamper)
	AddSpell(new /obj/effect/proc_holder/spell/pulse_demon/emp)
	AddSpell(new /obj/effect/proc_holder/spell/pulse_demon/overload)
	AddSpell(new /obj/effect/proc_holder/spell/pulse_demon/remotehijack)
	AddSpell(new /obj/effect/proc_holder/spell/pulse_demon/remotedrain)
	AddSpell(new /obj/effect/proc_holder/spell/pulse_demon/open_upgrades)

/mob/living/simple_animal/demon/pulse_demon/Stat()
	. = ..()
	if(statpanel("Status"))
		stat(null, "Charge: [format_si_suffix(charge)]W")
		stat(null, "Maximum Charge: [format_si_suffix(maxcharge)]W")
		stat(null, "Drained Charge: [format_si_suffix(charge_drained)]W")
		stat(null, "Hijacked APCs: [length(hijacked_apcs)]")
		stat(null, "Drain Rate: [format_si_suffix(power_drain_rate)]W")
		stat(null, "Hijack Time: [hijack_time / 10] seconds")

/mob/living/simple_animal/demon/pulse_demon/dust()
	return death()

/mob/living/simple_animal/demon/pulse_demon/gib()
	return death()

/mob/living/simple_animal/demon/pulse_demon/death()
	var/turf/T = get_turf(src)
	do_sparks(rand(2, 4), FALSE, src)
	. = ..()

	var/heavy_radius = min(charge / 50000, 20)
	var/light_radius = min(charge / 25000, 25)
	empulse(T, heavy_radius, light_radius)
	playsound(T, pick(hurt_sounds), 30, TRUE)

/mob/living/simple_animal/demon/pulse_demon/proc/exit_to_turf()
	var/turf/T = get_turf(src)
	current_power = null
	update_controlling_area()
	current_cable = null
	forceMove(T)
	Move(T)
	if(!current_cable && !current_power)
		var/obj/effect/proc_holder/spell/pulse_demon/toggle/can_exit_cable/S = locate() in mob_spell_list
		if(!S.locked && !can_exit_cable)
			can_exit_cable = TRUE
			S.do_toggle(can_exit_cable)
			to_chat(src, "<span class='danger'>Your self-sustaining ability has automatically enabled itself to prevent death from having no connection!</span>")

/mob/living/simple_animal/demon/pulse_demon/proc/update_controlling_area(reset = FALSE)
	var/area/prev = controlling_area
	if(reset || current_power == null)
		controlling_area = null
	else if(isapc(current_power))
		var/obj/machinery/power/apc/A = current_power
		if(A in hijacked_apcs)
			controlling_area = A.apc_area
		else
			controlling_area = null

	if((!prev && !controlling_area) || (prev && controlling_area))
		return // only update icons when we get or no longer have ANY area
	for(var/obj/effect/proc_holder/spell/pulse_demon/S in mob_spell_list)
		if(!S.action || S.locked)
			continue
		if(S.requires_area)
			S.action.UpdateButtonIcon()

// can enter an apc at all?
/mob/living/simple_animal/demon/pulse_demon/proc/is_valid_apc(obj/machinery/power/apc/A)
	return istype(A) && !(A.stat & BROKEN) && !A.shorted

/mob/living/simple_animal/demon/pulse_demon/Move(newloc)
	var/obj/machinery/power/new_power = locate(/obj/machinery/power) in newloc
	var/obj/structure/cable/new_cable = locate(/obj/structure/cable) in newloc

	if(QDELETED(new_power))
		new_power = null
	if(QDELETED(new_cable))
		new_cable = null

	if(istype(new_power, /obj/machinery/power/terminal))
		// entering a terminal is kinda useless and any working terminal will have a cable under it
		new_power = null

	if(isapc(new_power))
		var/obj/machinery/power/apc/A = new_power
		if(!is_valid_apc(new_power) || !A.terminal)
			new_power = null // don't enter an APC without a terminal or a broken APC, etc.

	// there's no electricity in space
	if(!new_cable && !new_power && (!can_exit_cable || isspaceturf(newloc)))
		return

	var/moved = ..()

	if(!new_cable && !new_power)
		if(can_exit_cable && moved)
			speed = outside_cable_speed
	else
		speed = inside_cable_speed

	if(moved)
		if(!is_under_tile() && prob(PULSEDEMON_PLATING_SPARK_CHANCE))
			do_sparks(rand(2, 4), FALSE, src)

	current_weapon = null
	current_robot = null
	if(current_bot)
		current_bot.hijacked = FALSE
	current_bot = null

	/*
	A few notes about this terrible proc, If you're wondering, I didn't write it but man I do NOT want to touch it
	1. A lot of this 100% shouldn't be on move, that's just waiting for something bad to happen
	2. Never, EVER directly call a do_after here, it will cause move to sleep which is awful
	*/
	if(new_power)
		current_power = new_power
		current_cable = null
		forceMove(current_power) // we go inside the machine
		playsound(src, 'sound/effects/eleczap.ogg', 15, TRUE)
		do_sparks(rand(2, 4), FALSE, src)
		if(isapc(current_power))
			if(current_power in hijacked_apcs)
				update_controlling_area()
			else
				INVOKE_ASYNC(src, PROC_REF(try_hijack_apc), current_power)
	else if(new_cable)
		current_cable = new_cable
		current_power = null
		update_controlling_area()
		if(!isturf(loc))
			loc = get_turf(newloc)
		if(!moved)
			forceMove(newloc)
	else if(moved)
		current_cable = null
		current_power = null
		update_controlling_area()

// signal to replace relaymove where or when? // Never, actually just manage your code instead
/obj/machinery/power/relaymove(mob/user, dir)
	if(!ispulsedemon(user))
		return ..()

	var/mob/living/simple_animal/demon/pulse_demon/demon = user
	var/turf/T = get_turf(src)
	var/turf/T2 = get_step(T, dir)
	if(demon.can_exit_cable || locate(/obj/structure/cable) in T2)
		playsound(src, 'sound/effects/eleczap.ogg', 15, TRUE)
		do_sparks(rand(2, 4), FALSE, src)
		user.forceMove(T)
		if(isapc(src))
			demon.update_controlling_area(TRUE)

/mob/living/simple_animal/demon/pulse_demon/proc/adjust_charge(amount, adjust_max = FALSE)
	if(!amount)
		return FALSE
	if(adjust_max)
		maxcharge = max(maxcharge, charge + amount)
	var/orig = charge
	charge = min(maxcharge, charge + amount)
	var/realdelta = charge - orig
	if(!realdelta)
		return FALSE
	if(realdelta > 0)
		charge_drained += realdelta

	update_glow()
	for(var/obj/effect/proc_holder/spell/pulse_demon/S in mob_spell_list)
		if(!S.action || S.locked || !S.cast_cost)
			continue
		var/dist = S.cast_cost - orig
		// only update icon if the amount is actually enough to change a spell's availability
		if(dist == 0 || (dist > 0 && realdelta >= dist) || (dist < 0 && realdelta <= dist))
			S.action.UpdateButtonIcon()
	return realdelta

// logarithmic scale for glow strength, see table:
	// 1.5 <= 25k
	// 2   at 50k
	// 2.5 at 100k
	// 3   at 200k
	// 3.5 at 400k, etc
/mob/living/simple_animal/demon/pulse_demon/proc/update_glow()
	var/range = 2 + (log(2, charge + 1) - log(2, 50000)) / 2
	range = max(range, 1.5)
	set_light(range, 2, glow_color)

/mob/living/simple_animal/demon/pulse_demon/proc/drain_APC(obj/machinery/power/apc/A, multiplier = 1)
	if(A.being_hijacked)
		return PULSEDEMON_SOURCE_DRAIN_INVALID
	var/amount_to_drain = clamp(A.cell.charge, 0, power_drain_rate * multiplier)
	A.cell.use(min(amount_to_drain, maxcharge - charge)) // calculated seperately because the apc charge multiplier shouldn't affect the actual consumption
	return adjust_charge(amount_to_drain * PULSEDEMON_APC_CHARGE_MULTIPLIER)

/mob/living/simple_animal/demon/pulse_demon/proc/drain_SMES(obj/machinery/power/smes/S, multiplier = 1)
	var/amount_to_drain = clamp(S.charge, 0, power_drain_rate * multiplier * PULSEDEMON_SMES_DRAIN_MULTIPLIER)
	var/drained = adjust_charge(amount_to_drain)
	S.charge -= drained
	return drained

/mob/living/simple_animal/demon/pulse_demon/Life(seconds, times_fired)
	. = ..()

	var/got_power = FALSE
	if(current_cable)
		if(current_cable.get_available_power() >= power_per_regen)
			current_cable.add_power_demand(power_per_regen)
			got_power = TRUE

			var/excess = initial(power_per_regen) - power_per_regen
			if(excess > 0 && current_cable.get_available_power() >= excess && do_drain)
				adjust_charge(excess)
				current_cable.add_power_demand(excess)
	else if(current_power)
		if(isapc(current_power) && loc == current_power && do_drain)
			if(drain_APC(current_power) > power_per_regen)
				got_power = TRUE
		else if(istype(current_power, /obj/machinery/power/smes) && do_drain)
			if(drain_SMES(current_power) > power_per_regen)
				got_power = TRUE
		// try to take power from the powernet if the APC or SMES is empty (or we're not /really/ in the APC)
		if(!got_power && current_power.get_available_power() >= power_per_regen)
			current_power.consume_direct_power(power_per_regen)
			got_power = TRUE
	else if(!can_exit_cable)
		death()
		return

	if(got_power)
		if(regen_lock <= 0)
			adjustHealth(-health_regen_rate)
		clear_alert(ALERT_CATEGORY_NOPOWER)
	else
		var/rate = health_loss_rate
		if(!current_cable && !current_power && can_exit_cable)
			// 2 * initial_rate - upgrade_level
			rate += initial(health_loss_rate)
		adjustHealth(rate)
		throw_alert(ALERT_CATEGORY_NOPOWER, /obj/screen/alert/pulse_nopower)

	if(regen_lock > 0)
		if(--regen_lock == 0)
			clear_alert(ALERT_CATEGORY_NOREGEN)

/mob/living/simple_animal/demon/pulse_demon/proc/gen_speech_name()
	. = ""
	for(var/i = 1 to 10)
		. += pick("!", "@", "#", "$", "%", "^", "&", "*")

/mob/living/simple_animal/demon/pulse_demon/say(message, verb, sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE)
	if(client && check_mute(client.ckey, MUTE_IC))
		to_chat(src, "<span class='danger'>You cannot speak in IC (Muted).</span>")
		return FALSE

	if(sanitize)
		message = trim_strip_html_properly(message)

	if(stat)
		if(stat == DEAD)
			return say_dead(message)
		return FALSE

	if(current_robot)
		var/turf/T = get_turf(src)
		log_say("[key_name_admin(src)] (@[T.x], [T.y], [T.z]) made [current_robot]([key_name_admin(current_robot)]) say: [message]")
		log_admin("[key_name_admin(src)] made [key_name_admin(current_robot)] say: [message]")
		message_admins("<span class='notice'>[key_name_admin(src)] made [key_name_admin(current_robot)] say: [message]</span>")
		// don't sanitize again
		current_robot.say(message, null, FALSE, ignore_speech_problems, ignore_atmospherics, ignore_languages)
		return TRUE

	var/message_mode = parse_message_mode(message, "headset")

	if(message_mode)
		if(message_mode == "headset")
			message = copytext(message, 2)
		else
			message = copytext(message, 3)

	message = trim_left(message)

	var/list/message_pieces = list()
	if(ignore_languages)
		message_pieces = message_to_multilingual(message)
	else
		message_pieces = parse_languages(message)

	// hivemind languages
	if(istype(message_pieces, /datum/multilingual_say_piece))
		var/datum/multilingual_say_piece/S = message_pieces
		S.speaking.broadcast(src, S.message)
		return TRUE

	if(!LAZYLEN(message_pieces))
		. = FALSE
		CRASH("Message failed to generate pieces. [message] - [json_encode(message_pieces)]")

	create_log(SAY_LOG, "[message_mode ? "([message_mode])" : ""] '[message]'")

	playsound(get_turf(src), pick(speech_sounds), 30, TRUE)
	if(istype(loc, /obj/item/radio))
		var/obj/item/radio/R = loc
		name = gen_speech_name()
		R.talk_into(src, message_pieces, message_mode, verbage = verb)
		name = real_name
		return TRUE
	else if(istype(loc, /obj/machinery/hologram/holopad))
		var/obj/machinery/hologram/holopad/H = loc
		name = "[H]"
		for(var/mob/M in get_mobs_in_view(7, H))
			M.hear_say(message_pieces, verb, FALSE, src)
		name = real_name
		return TRUE

	emote("me", message = "[pick(emote_hear)]")
	return TRUE

/mob/living/simple_animal/demon/pulse_demon/update_runechat_msg_location()
	if(istype(loc, /obj/machinery/hologram/holopad))
		runechat_msg_location = loc.UID()
	else
		return ..()

/mob/living/simple_animal/demon/pulse_demon/visible_message(message, self_message, blind_message)
	// overriden because pulse demon is quite often in non-turf locs, and /mob/visible_message acts differently there
	for(var/mob/M in get_mobs_in_view(7, src))
		if(M.see_invisible < invisibility)
			continue //can't view the invisible
		var/msg = message
		if(self_message && M == src)
			msg = self_message
		M.show_message(msg, EMOTE_VISIBLE, blind_message, EMOTE_AUDIBLE)

/mob/living/simple_animal/demon/pulse_demon/has_internal_radio_channel_access(mob/user, list/req_one_accesses)
	return has_access(list(), req_one_accesses, get_all_accesses())

/mob/living/simple_animal/demon/pulse_demon/proc/try_hijack_apc(obj/machinery/power/apc/A, remote = FALSE)
	// one APC per pulse demon, one pulse demon per APC, no duplicate APCs
	if(!is_valid_apc(A) || (A in hijacked_apcs) || apc_being_hijacked || A.being_hijacked)
		return FALSE

	to_chat(src, "<span class='notice'>You are now attempting to hijack [A], this will take approximately [hijack_time / 10] seconds.</span>")
	apc_being_hijacked = A
	A.being_hijacked = TRUE
	A.update_icon()
	if(do_after(src, hijack_time, target = A))
		if(is_valid_apc(A))
			finish_hijack_apc(A, remote)
		else
			to_chat(src, "<span class='warning'>Failed to hijack [src].</span>")
	apc_being_hijacked = null
	A.being_hijacked = FALSE
	A.update_icon()

// Basically this proc gives you more max charge per apc you have hijacked
// Looks weird but it gets the job done
/mob/living/simple_animal/demon/pulse_demon/proc/calc_maxcharge(hijacked_apcs)
	if(!hijacked_apcs) // No APCs hijacked? No extra charge
		return 1000
	return 20000 * clamp(hijacked_apcs, 0, 20) + 500000 * clamp(hijacked_apcs - 20, 0, 30) + 1000000 * clamp(hijacked_apcs - 50, 0, 50) + 500000000 * max(0, hijacked_apcs - 100)

/mob/living/simple_animal/demon/pulse_demon/proc/finish_hijack_apc(obj/machinery/power/apc/A, remote = FALSE)
	var/image/apc_image = image('icons/obj/power.dmi', A, "apcemag", ABOVE_LIGHTING_LAYER, A.dir)
	apc_image.plane = ABOVE_LIGHTING_PLANE
	LAZYADD(apc_images[get_turf(A)], apc_image)
	client.images += apc_image

	hijacked_apcs += A
	RegisterSignal(A, COMSIG_PARENT_QDELETING, PROC_REF(apc_deleted_handler))
	if(!remote)
		update_controlling_area()
	maxcharge = calc_maxcharge(length(hijacked_apcs)) + (maxcharge - calc_maxcharge(length(hijacked_apcs) - 1))
	to_chat(src, "<span class='notice'>Hijacking complete! You now control [length(hijacked_apcs)] APCs.</span>")

/mob/living/simple_animal/demon/pulse_demon/proc/try_cross_shock(src, atom/A)
	SIGNAL_HANDLER
	if(!isliving(A) || is_under_tile())
		return
	var/mob/living/L = A
	try_shock_mob(L)

/mob/living/simple_animal/demon/pulse_demon/proc/try_shock_mob(mob/living/L, siemens_coeff = 1)
	var/dealt = 0
	if(current_cable && current_cable.powernet && current_cable.powernet.available_power)
		// returns used energy, not damage dealt, but ez conversion with /20
		dealt = electrocute_mob(L, current_cable.powernet, src, siemens_coeff) / 20
	else if(charge >= 1000)
		dealt = L.electrocute_act(30, src, siemens_coeff)
		adjust_charge(-1000)
	if(dealt > 0)
		do_sparks(rand(2, 4), FALSE, src)
	add_attack_logs(src, L, "shocked ([dealt] damage)")

/mob/living/simple_animal/demon/pulse_demon/proc/is_under_tile()
	var/turf/T = get_turf(src)
	return T.transparent_floor || T.intact || HAS_TRAIT(T, TRAIT_TURF_COVERED)

// cable (and hijacked APC) view helper
/mob/living/simple_animal/demon/pulse_demon/proc/update_cableview()
	if(!client)
		return

	// clear out old images
	for(var/image/current_image in cable_images + apc_images)
		client.images -= current_image

	var/turf/T = get_turf(src)

	// regenerate for all cables on our (or our holder's) z-level
	cable_images.Cut()
	for(var/datum/regional_powernet/P in SSmachines.powernets)
		for(var/obj/structure/cable/C in P.cables)
			var/turf/cable_turf = get_turf(C)
			if(T.z != cable_turf.z)
				break // skip entire powernet if it's off z-level

			var/image/cable_image = image(C, C, layer = ABOVE_LIGHTING_LAYER, dir = C.dir)
			// good visibility here
			cable_image.plane = ABOVE_LIGHTING_PLANE
			LAZYADD(cable_images[cable_turf], cable_image)
			client.images += cable_image

	// same for hijacked APCs
	apc_images.Cut()
	for(var/obj/machinery/power/apc/A in hijacked_apcs)
		var/turf/apc_turf = get_turf(A)
		if(T.z != apc_turf.z)
			continue
		// parent of image is the APC, not the turf because of how clicking on images works
		var/image/apc_image = image('icons/obj/power.dmi', A, "apcemag", ABOVE_LIGHTING_LAYER, A.dir)
		apc_image.plane = ABOVE_LIGHTING_PLANE
		LAZYADD(apc_images[apc_turf], apc_image)
		client.images += apc_image

/mob/living/simple_animal/demon/pulse_demon/emp_act(severity)
	if(emp_debounce)
		return

	. = ..()
	visible_message("<span class='danger'>[src] [pick("fizzles", "wails", "flails")] in anguish!</span>")
	playsound(get_turf(src), pick(hurt_sounds), 30, TRUE)
	throw_alert(ALERT_CATEGORY_NOREGEN, /obj/screen/alert/pulse_noregen)
	switch(severity)
		if(EMP_LIGHT)
			adjustHealth(round(max(initial(health) / 4, round(maxHealth / 8))))
			regen_lock = 3
		if(EMP_HEAVY)
			adjustHealth(round(max(initial(health) / 3, round(maxHealth / 6))))
			regen_lock = 5
	emp_debounce = TRUE
	addtimer(VARSET_CALLBACK(src, emp_debounce, FALSE), 0.1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/mob/living/simple_animal/demon/pulse_demon/proc/try_attack_mob(mob/living/L)
	if(!is_under_tile() && L != src)
		do_attack_animation(L)
		try_shock_mob(L)

/mob/living/simple_animal/demon/pulse_demon/UnarmedAttack(atom/A)
	if(isliving(A))
		try_attack_mob(A)
	else if(isitem(A) && !is_under_tile())
		var/obj/item/O = A
		var/obj/item/stock_parts/cell/C = O.get_cell()
		if(C?.charge)
			C.use(min(C.charge, power_drain_rate))
			adjust_charge(min(C.charge, power_drain_rate))
			visible_message("<span class='notice'>[src] touches [O] and drains its power!</span>", "<span class='notice'>You touch [O] and drain it's power!</span>")

/mob/living/simple_animal/demon/pulse_demon/attack_hand(mob/living/carbon/human/M)
	if(is_under_tile())
		to_chat(M, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	switch(M.intent)
		if(INTENT_HELP)
			visible_message("<span class='notice'>[M] [response_help] [src].</span>")
		if(INTENT_DISARM, INTENT_GRAB)
			visible_message("<span class='notice'>[M] [response_disarm] [src].</span>")
		if(INTENT_HELP)
			visible_message("<span class='warning'>[M] [response_harm] [src].</span>")
	try_attack_mob(M)

/mob/living/simple_animal/demon/pulse_demon/attackby(obj/item/O, mob/living/user)
	if(is_under_tile())
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	var/obj/item/stock_parts/cell/C = O.get_cell()
	if(C && C.charge)
		C.use(min(C.charge, power_drain_rate))
		adjust_charge(min(C.charge, power_drain_rate))
		to_chat(user, "<span class='warning'>You touch [src] with [O] and [src] drains it!</span>")
		to_chat(src, "<span class='notice'>[user] touches you with [O] and you drain its power!</span>")
	visible_message("<span class='notice'>[O] goes right through [src].</span>")
	try_shock_mob(user, O.siemens_coefficient)

/mob/living/simple_animal/demon/pulse_demon/ex_act()
	return

/mob/living/simple_animal/demon/pulse_demon/CanPass(atom/movable/mover, turf/target, height)
	. = ..()
	if(istype(mover, /obj/item/projectile/ion))
		return FALSE

/mob/living/simple_animal/demon/pulse_demon/bullet_act(obj/item/projectile/proj)
	if(istype(proj, /obj/item/projectile/ion))
		return ..()
	visible_message("<span class='warning'>[proj] goes right through [src]!</span>")

/mob/living/simple_animal/demon/pulse_demon/electrocute_act(shock_damage, source, siemens_coeff, flags)
	return

/mob/living/simple_animal/demon/pulse_demon/blob_act(obj/structure/blob/B)
	return // will likely end up dying if the blob cuts its wires anyway

/mob/living/simple_animal/demon/pulse_demon/narsie_act()
	return // you can't turn electricity into a harvester

/mob/living/simple_animal/demon/pulse_demon/get_access()
	return get_all_accesses()

/mob/living/simple_animal/demon/pulse_demon/IsAdvancedToolUser()
	return TRUE // interacting with machines

/mob/living/simple_animal/demon/pulse_demon/can_be_pulled()
	return FALSE

/mob/living/simple_animal/demon/pulse_demon/can_buckle()
	return FALSE

/mob/living/simple_animal/demon/pulse_demon/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	return

/mob/living/simple_animal/demon/pulse_demon/experience_pressure_difference()
	return // no thanks

/mob/living/simple_animal/demon/pulse_demon/singularity_pull()
	return

/mob/living/simple_animal/demon/pulse_demon/mob_negates_gravity()
	return TRUE

/mob/living/simple_animal/demon/pulse_demon/mob_has_gravity()
	return TRUE

/obj/screen/alert/pulse_nopower
	name = "No Power"
	desc = "You are not connected to a cable or machine and are losing health!"
	icon_state = "pd_nopower"

/obj/screen/alert/pulse_noregen
	name = "Regeneration Stalled"
	desc = "You've been EMP'd and cannot regenerate health!"
	icon_state = "pd_noregen"

#undef ALERT_CATEGORY_NOPOWER
#undef ALERT_CATEGORY_NOREGEN
