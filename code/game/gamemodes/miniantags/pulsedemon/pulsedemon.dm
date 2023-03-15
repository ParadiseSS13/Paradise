// original implementation: https://ss13.moe/wiki/index.php/Pulse_Demon

#define PULSEDEMON_PLATING_SPARK_CHANCE 20
#define PULSEDEMON_APC_CHARGE_MULTIPLIER 2
#define PULSEDEMON_SMES_DRAIN_MULTIPLIER 10
#define ALERT_CATEGORY_NOPOWER "pulse_nopower"
#define ALERT_CATEGORY_NOREGEN "pulse_noregen"

// used a lot here, undef'd after
#define isapc(A) (istype(A, /obj/machinery/power/apc))

/mob/living/simple_animal/pulse_demon
	name = "pulse demon"
	real_name = "pulse demon"
	desc = "A strange electrical apparition that lives in wires."
	gender = NEUTER
	speak_chance = 20

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

	see_in_dark = 8
	minbodytemp = 0
	maxbodytemp = 4000
	maxHealth = 50
	health = 50
	speed = -1
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
	// so we can see in maints better
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	stop_automated_movement = TRUE
	wander = FALSE
	can_have_ai = FALSE
	can_be_on_fire = FALSE
	has_unlimited_silicon_privilege = TRUE

	var/charge = 1000
	var/maxcharge = 1000
	var/do_drain = TRUE
	var/power_drain_rate = 1000 // amount of power taken per tick

	var/power_per_regen = 100
	var/health_loss_rate = 5
	var/health_regen_rate = 3
	var/regen_lock = 0 // health regen locked for a time after being EMP'd

	var/can_exit_cable = FALSE
	var/inside_cable_speed = -1
	var/outside_cable_speed = 4

	var/hijack_time = 30 SECONDS

	var/glow_color = "#bbbb00" // for varedit funsies

	var/area/controlling_area // maintain this while doing area machinery actions
	var/obj/structure/cable/current_cable // inhabited wire
	var/obj/machinery/power/current_power // inhabited machine
	var/obj/item/current_weapon // inhabited (energy) gun
	var/mob/living/silicon/robot/current_robot // inhabited cyborg
	var/mob/living/simple_animal/bot/current_bot // inhabited bot

	var/bot_movedelay = 0
	var/list/mob/living/silicon/robot/hijacked_robots

	var/list/image/images_shown
	var/list/obj/machinery/power/apc/hijacked_apcs
	var/obj/machinery/power/apc/apc_being_hijacked
	var/datum/progressbar_helper/pb_helper

// TODO: setting name to be unambigious (incase of multiple pulse demons)? numbering/namefile?
/mob/living/simple_animal/pulse_demon/Initialize(mapload)
	. = ..()
	remove_from_all_data_huds()
	flags_2 |= RAD_NO_CONTAMINATE_2

	// don't step on me
	RegisterSignal(src, COMSIG_CROSSED_MOVABLE, PROC_REF(try_cross_shock))
	RegisterSignal(src, COMSIG_MOVABLE_CROSSED, PROC_REF(try_cross_shock))

	pb_helper = new()

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 0, BURN = 0, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)

	emote_hear = list("vibrates", "sizzles")
	speak_emote = list("modulates")

	hijacked_apcs = list()
	hijacked_robots = list()
	images_shown = list()

	current_power = locate(/obj/machinery/power) in loc
	// in the case that both current_power and current_cable are null, the pulsedemon will die the next tick
	if(!current_power)
		current_cable = locate(/obj/structure/cable) in loc
	else
		forceMove(current_power)
	update_glow()
	playsound(get_turf(src), 'sound/effects/eleczap.ogg', 50, 1)
	give_spells()

/mob/living/simple_animal/pulse_demon/proc/give_spells()
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

/mob/living/simple_animal/pulse_demon/Stat()
	. = ..()
	if(statpanel("Status"))
		stat(null, "Charge: [format_si_suffix(charge)]W")
		stat(null, "Maximum Charge: [format_si_suffix(maxcharge)]W")
		stat(null, "Hijacked APCs: [length(hijacked_apcs)]")

/mob/living/simple_animal/pulse_demon/dust()
	return death()

/mob/living/simple_animal/pulse_demon/gib()
	return death()

/mob/living/simple_animal/pulse_demon/death()
	pb_helper.cancel() // clean up any actions we were doing
	var/turf/T = get_turf(src)
	do_sparks(rand(2, 4), FALSE, src)
	. = ..()

	var/heavy_radius = min(charge / 50000, 20)
	var/light_radius = min(charge / 25000, 25)
	empulse(T, heavy_radius, light_radius)

/mob/living/simple_animal/pulse_demon/proc/exit_to_turf(atom/oldloc)
	if(loc != oldloc)
		return
	var/turf/T = get_turf(oldloc)
	current_power = null
	update_controlling_area()
	current_cable = null
	current_weapon = null
	current_robot = null
	if(current_bot)
		current_bot.hijacked = FALSE
	current_bot = null
	forceMove(T)
	Move(T)
	if(!current_cable && !current_power)
		var/obj/effect/proc_holder/spell/pulse_demon/toggle/can_exit_cable/S = locate() in mob_spell_list
		if(!S.locked && !can_exit_cable)
			can_exit_cable = TRUE
			S.do_toggle(can_exit_cable)

/mob/living/simple_animal/pulse_demon/proc/update_controlling_area(reset = FALSE)
	var/area/prev = controlling_area
	if(reset || current_power == null)
		controlling_area = null
	else
		var/obj/machinery/power/apc/A = current_power
		if(istype(A) && (A in hijacked_apcs))
			controlling_area = A.apc_area
		else
			controlling_area = null

	if((prev == null && controlling_area == null) || (prev != null && controlling_area != null))
		return // only update icons when we get or no longer have ANY area
	for(var/obj/effect/proc_holder/spell/pulse_demon/S in mob_spell_list)
		if(!S.action || S.locked)
			continue
		if(S.requires_area)
			S.action.UpdateButtonIcon()

// can enter an apc at all?
/mob/living/simple_animal/pulse_demon/proc/is_valid_apc(obj/machinery/power/apc/A)
	return istype(A) && !(A.stat & BROKEN) && !A.shorted

/mob/living/simple_animal/pulse_demon/Move(newloc)
	var/obj/machinery/power/new_power = locate(/obj/machinery/power) in newloc
	var/obj/structure/cable/new_cable = locate(/obj/structure/cable) in newloc

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
	current_bot = null

	if(new_power)
		current_power = new_power
		current_cable = null
		forceMove(current_power) // we go inside the machine
		playsound(src, 'sound/effects/eleczap.ogg', 50, 1)
		do_sparks(rand(2, 4), FALSE, src)
		if(isapc(current_power))
			if(current_power in hijacked_apcs)
				update_controlling_area()
			else
				try_hijack_apc(current_power)
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

// signal to replace relaymove where or when?
/obj/machinery/power/relaymove(mob/user, dir)
	if(!ispulsedemon(user))
		return ..()

	var/mob/living/simple_animal/pulse_demon/demon = user
	var/turf/T = get_turf(src)
	var/turf/T2 = get_step(T, dir)
	if(demon.can_exit_cable || locate(/obj/structure/cable) in T2)
		playsound(src, 'sound/effects/eleczap.ogg', 50, 1)
		do_sparks(rand(2, 4), FALSE, src)
		user.forceMove(T)
		if(isapc(src))
			if(src == demon.apc_being_hijacked)
				demon.pb_helper.cancel()
			demon.update_controlling_area(TRUE)

// TODO: decide how maxcharge should increase, it's kinda weird for now (see also: SMES draining code in drainSMES())
//       I'd say have maxcharge be a multiple of the number of controlled APCs (with upgrade to increase)
// adjust_max is TRUE when draining APCs
/mob/living/simple_animal/pulse_demon/proc/adjustCharge(amount, adjust_max = FALSE)
	if(amount == 0)
		return
	if(adjust_max)
		maxcharge = max(maxcharge, charge + amount)
	var/orig = charge
	charge = min(maxcharge, charge + amount)
	var/realdelta = charge - orig
	if(realdelta == 0)
		return

	update_glow()
	for(var/obj/effect/proc_holder/spell/pulse_demon/S in mob_spell_list)
		if(!S.action || S.locked || S.cast_cost == 0)
			continue
		var/dist = S.cast_cost - orig
		// only update icon if the amount is actually enough to change a spell's availability
		if(dist == 0 || (dist > 0 && realdelta >= dist) || (dist < 0 && realdelta <= dist))
			S.action.UpdateButtonIcon()

// TODO: does equation need adjustment? see original table:
	// 1.5 <= 25k
	// 2   at 50k
	// 2.5 at 100k
	// 3   at 200k
	// 3.5 at 400k, etc
/mob/living/simple_animal/pulse_demon/proc/update_glow()
	var/range = 2 + (log(2, charge + 1) - log(2, 50000)) / 2
	range = max(range, 1.5)
	set_light(range, 2, glow_color)

/mob/living/simple_animal/pulse_demon/proc/drainAPC(obj/machinery/power/apc/A, multiplier = 1)
	if(A.being_hijacked)
		return -1
	var/amount_to_drain = clamp(A.cell.charge, 0, power_drain_rate * multiplier)
	A.cell.use(amount_to_drain)
	adjustCharge(amount_to_drain * PULSEDEMON_APC_CHARGE_MULTIPLIER, TRUE)
	return amount_to_drain * PULSEDEMON_APC_CHARGE_MULTIPLIER

/mob/living/simple_animal/pulse_demon/proc/drainSMES(obj/machinery/power/smes/S, multiplier = 1)
	var/amount_to_drain = clamp(S.charge, 0, power_drain_rate * multiplier * PULSEDEMON_SMES_DRAIN_MULTIPLIER)
	S.charge -= amount_to_drain
	maxcharge = max(maxcharge, S.output_level)
	adjustCharge(amount_to_drain)
	return amount_to_drain

/mob/living/simple_animal/pulse_demon/Life(seconds, times_fired)
	. = ..()

	var/got_power = FALSE
	if(current_cable)
		// TODO: small passive charge gain from cables when draining?
		if(current_cable.avail() >= power_per_regen)
			current_cable.add_load(power_per_regen)
			got_power = TRUE
	else if(current_power)
		if(isapc(current_power) && loc == current_power && do_drain)
			if(drainAPC(current_power) > power_per_regen)
				got_power = TRUE
		else if(istype(current_power, /obj/machinery/power/smes) && do_drain)
			if(drainSMES(current_power) > power_per_regen)
				got_power = TRUE
		// try to take power from the powernet if the APC or SMES is empty (or we're not /really/ in the APC)
		if(!got_power && current_power.avail() >= power_per_regen)
			current_power.add_load(power_per_regen)
			got_power = TRUE
	else if(!can_exit_cable)
		death()
		return

	if(got_power)
		if(regen_lock <= 0)
			adjustHealth(-health_regen_rate)
		clear_alert(ALERT_CATEGORY_NOPOWER)
	else
		adjustHealth(health_loss_rate)
		throw_alert(ALERT_CATEGORY_NOPOWER, /obj/screen/alert/pulse_nopower)

	if(regen_lock > 0)
		if(--regen_lock == 0)
			clear_alert(ALERT_CATEGORY_NOREGEN)

/mob/living/simple_animal/pulse_demon/proc/gen_speech_name()
	. = ""
	for(var/i = 1 to 10)
		. += pick("!", "@", "#", "$", "%", "^", "&", "*")

/mob/living/simple_animal/pulse_demon/say(message, verb, sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE)
	if(client)
		if(check_mute(client.ckey, MUTE_IC))
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

	if(istype(loc, /obj/item/radio))
		var/obj/item/radio/R = loc
		name = gen_speech_name()
		R.talk_into(src, message_pieces, message_mode, verbage = verb)
		name = real_name
		return TRUE
	else if(istype(loc, /obj/machinery/hologram/holopad))
		var/obj/machinery/hologram/holopad/H = loc
		var/turf/T = get_turf(H)
		name = "[H]"
		for(var/mob/M in hearers(T.loc) + src)
			M.hear_say(message_pieces, verb, FALSE, src)
		name = real_name
		return TRUE

	emote("me", message = "[pick(emote_hear)]")
	return TRUE

/mob/living/simple_animal/pulse_demon/update_runechat_msg_location()
	if(istype(loc, /obj/machinery/hologram/holopad))
		runechat_msg_location = loc.UID()
	else
		return ..()

/mob/living/simple_animal/pulse_demon/has_internal_radio_channel_access(mob/user, list/req_one_accesses)
	var/list/access = get_all_accesses()
	return has_access(list(), req_one_accesses, access)

/mob/living/simple_animal/pulse_demon/proc/try_hijack_apc(obj/machinery/power/apc/A, remote = FALSE)
	// one APC per pulse demon, one pulse demon per APC, no duplicate APCs
	if(check_valid_apc(A, loc) && !(A in hijacked_apcs) && !apc_being_hijacked && !A.being_hijacked)
		to_chat(src, "<span class='notice'>You are now attempting to hijack [A], this will take approximately [hijack_time / 10] seconds.</span>")
		if(pb_helper.start(src, A, hijack_time, TRUE, \
		  CALLBACK(src, PROC_REF(check_valid_apc), A), \
		  CALLBACK(src, PROC_REF(finish_hijack_apc), A, remote), \
		  CALLBACK(src, PROC_REF(fail_hijack)), \
		  CALLBACK(src, PROC_REF(cleanup_hijack_apc), A)))
			apc_being_hijacked = A
			A.being_hijacked = TRUE
			A.update_icon()
			return TRUE
		else
			to_chat(src, "<span class='warning'>You are already performing an action!</span>")
	return FALSE

// TODO: which checks here? maybe aidisabled or constructed?
/mob/living/simple_animal/pulse_demon/proc/check_valid_apc(obj/machinery/power/apc/A, atom/startloc)
	return is_valid_apc(A)

/mob/living/simple_animal/pulse_demon/proc/finish_hijack_apc(obj/machinery/power/apc/A, remote = FALSE)
	var/image/apc_image = image('icons/obj/power.dmi', A, "apcemag", ABOVE_LIGHTING_LAYER, A.dir)
	apc_image.plane = ABOVE_LIGHTING_PLANE
	images_shown += apc_image
	client.images += apc_image
	hijacked_apcs += A
	if(!remote)
		update_controlling_area()
	to_chat(src, "<span class='notice'>Hijacking complete! You now control [length(hijacked_apcs)] APCs.</span>")

/mob/living/simple_animal/pulse_demon/proc/cleanup_hijack_apc(obj/machinery/power/apc/A)
	apc_being_hijacked = null
	A.being_hijacked = FALSE
	A.update_icon()

/mob/living/simple_animal/pulse_demon/proc/fail_hijack()
	to_chat(src, "<span class='warning'>Hijacking failed!</span>")

/mob/living/simple_animal/pulse_demon/proc/try_cross_shock(src, atom/A)
	SIGNAL_HANDLER
	if(!isliving(A) || is_under_tile())
		return
	var/mob/living/L = A
	try_shock_mob(L)

/mob/living/simple_animal/pulse_demon/proc/try_shock_mob(mob/living/L, siemens_coeff = 1)
	var/dealt = 0
	if(current_cable && current_cable.powernet && current_cable.powernet.avail)
		// returns used energy, not damage dealt, but ez conversion with /20
		dealt = electrocute_mob(L, current_cable.powernet, src, siemens_coeff) / 20
	else if(charge >= 1000)
		dealt = L.electrocute_act(30, src, siemens_coeff)
		adjustCharge(-1000)
	if(dealt > 0)
		do_sparks(rand(2, 4), FALSE, src)
	add_attack_logs(src, L, "shocked ([dealt] damage)")

/mob/living/simple_animal/pulse_demon/proc/is_under_tile()
	var/turf/T = get_turf(src)
	return T.transparent_floor || T.intact

/mob/living/simple_animal/pulse_demon/proc/do_hijack_notice(atom/A)
	to_chat(src, "<span class='notice'>You are now attempting to hijack [A], this will take approximately [hijack_time / 10] seconds.</span>")

// cable (and hijacked APC) view helper
/mob/living/simple_animal/pulse_demon/proc/update_cableview()
	if(!client)
		return

	// clear out old images
	for(var/image/current_image in images_shown)
		client.images -= current_image
	images_shown.Cut()

	var/turf/T = get_turf(src)
	// regenerate for all cables on our (or our holder's) z-level
	for(var/obj/structure/cable/C in GLOB.cable_list)
		var/turf/cable_turf = get_turf(C)
		if(T.z != cable_turf.z)
			continue
		var/image/cable_image = image(C, C, layer = ABOVE_LIGHTING_LAYER, dir = C.dir)
		// good visibility here
		cable_image.plane = ABOVE_LIGHTING_PLANE
		images_shown += cable_image
		client.images += cable_image

	// same for hijacked APCs
	for(var/obj/machinery/power/apc/A in hijacked_apcs)
		var/turf/apc_turf = get_turf(A)
		if(T.z != apc_turf.z)
			continue
		// parent of image is the APC, not the turf because of how clicking on images works
		// TODO: maybe a custom sprite to make it clearer to the pulse demon
		var/image/apc_image = image('icons/obj/power.dmi', A, "apcemag", ABOVE_LIGHTING_LAYER, A.dir)
		apc_image.plane = ABOVE_LIGHTING_PLANE
		images_shown += apc_image
		client.images += apc_image
	// TODO: spell that cycles you through the cameras in your area, necessitated by maps like Farragus

/mob/living/simple_animal/pulse_demon/reset_perspective(atom/A)
	. = ..()
	update_cableview()

// TODO: EMP_HEAVY, EMP_LIGHT distinction
/mob/living/simple_animal/pulse_demon/emp_act(severity)
	. = ..()
	visible_message("<span class ='danger'>[src] [pick("fizzles", "wails", "flails")] in anguish!</span>")
	throw_alert(ALERT_CATEGORY_NOREGEN, /obj/screen/alert/pulse_noregen)
	adjustHealth(round(max(initial(health) / 2, round(maxHealth / 4))))
	regen_lock = 5

/mob/living/simple_animal/pulse_demon/proc/try_attack_mob(mob/living/L)
	if(!is_under_tile() && L != src)
		do_attack_animation(L)
		try_shock_mob(L)

/mob/living/simple_animal/pulse_demon/UnarmedAttack(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		try_attack_mob(L)

/mob/living/simple_animal/pulse_demon/attack_hand(mob/living/carbon/human/M)
	if(is_under_tile())
		to_chat(M, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	switch (M.intent)
		if(INTENT_HELP)
			visible_message("<span class='notice'>[M] [response_help] [src].</span>")
		if(INTENT_DISARM, INTENT_GRAB)
			visible_message("<span class='notice'>[M] [response_disarm] [src].</span>")
		if(INTENT_HELP)
			visible_message("<span class='warning'>[M] [response_harm] [src].</span>")
	try_attack_mob(M)

/mob/living/simple_animal/pulse_demon/attackby(obj/item/O, mob/living/user)
	if(is_under_tile())
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	var/obj/item/stock_parts/cell/C = O.get_cell()
	if(C && C.charge)
		C.use(min(C.charge, power_drain_rate))
		adjustCharge(min(C.charge, power_drain_rate))
		to_chat(user, "<span class='warning'>You touch [src] with [O] and [src] drains it!</span>")
		to_chat(src, "<span class='notice'>[user] touches you with [O] and you drain its power!</span>")
	visible_message("<span class='notice'>[O] goes right through [src].</span>")
	try_shock_mob(user, O.siemens_coefficient)

/mob/living/simple_animal/pulse_demon/ex_act()
	return

/mob/living/simple_animal/pulse_demon/bullet_act(obj/item/projectile/Proj)
	visible_message("<span class='warning'>[Proj] goes right through [src]!</span>")

/mob/living/simple_animal/pulse_demon/electrocute_act(shock_damage, source, siemens_coeff, flags)
	return // TODO: potiential for gaining charge or a boost of some kind?

/mob/living/simple_animal/pulse_demon/blob_act(obj/structure/blob/B)
	return // will likely end up dying if the blob cuts its wires anyway

/mob/living/simple_animal/pulse_demon/narsie_act()
	return // you can't turn electricity into a harvester

/mob/living/simple_animal/pulse_demon/get_access()
	return get_all_accesses()

/mob/living/simple_animal/pulse_demon/IsAdvancedToolUser()
	return TRUE // interacting with machines

/mob/living/simple_animal/pulse_demon/can_be_pulled()
	return FALSE

/mob/living/simple_animal/pulse_demon/can_buckle()
	return FALSE

/mob/living/simple_animal/pulse_demon/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	return

/mob/living/simple_animal/pulse_demon/experience_pressure_difference()
	return // no thanks

/mob/living/simple_animal/pulse_demon/singularity_pull()
	return

/mob/living/simple_animal/pulse_demon/mob_negates_gravity()
	return TRUE

/mob/living/simple_animal/pulse_demon/mob_has_gravity()
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

#undef isapc
