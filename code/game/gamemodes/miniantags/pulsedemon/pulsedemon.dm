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
	emote_hear = list("vibrates", "sizzles")
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

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

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

	var/apc_hijack_time = 30 SECONDS

	var/obj/structure/cable/current_cable // inhabited wire
	var/obj/machinery/power/current_power // inhabited machine

	var/list/image/cables_shown = list()
	var/list/obj/machinery/power/apc/hijacked_apcs = list()
	var/obj/machinery/power/apc/apc_being_hijacked
	var/hijack_timer_id = TIMER_ID_NULL
	// do_after doesn't work with relaymove so we do our own progressbar
	var/datum/progressbar/progbar
	var/progbar_timer_id = TIMER_ID_NULL

/mob/living/simple_animal/pulse_demon/Initialize(mapload)
	. = ..()
	remove_from_all_data_huds()
	flags_2 |= RAD_NO_CONTAMINATE_2

	// don't step on me
	RegisterSignal(src, COMSIG_CROSSED_MOVABLE, PROC_REF(try_cross_shock))
	RegisterSignal(src, COMSIG_MOVABLE_CROSSED, PROC_REF(try_cross_shock))

	current_power = locate(/obj/machinery/power) in loc
	// in the case that both current_power and current_cable are null, the pulsedemon will die the next tick
	if (!current_power)
		current_cable = locate(/obj/structure/cable) in loc
	else
		forceMove(current_power)
	set_light(1.5, 2, "#bbbb00")
	playsound(get_turf(src), 'sound/effects/eleczap.ogg', 50, 1)

/mob/living/simple_animal/pulse_demon/Stat()
	. = ..()
	if (statpanel("Status"))
		stat(null, "Charge: [charge]")
		stat(null, "Maximum Charge: [maxcharge]")

/mob/living/simple_animal/pulse_demon/dust()
	return death()

/mob/living/simple_animal/pulse_demon/gib()
	return death()

/mob/living/simple_animal/pulse_demon/death()
	cancel_hijack_apc(apc_being_hijacked)
	var/turf/T = get_turf(src)
	do_sparks(rand(2, 4), FALSE, src)
	var/heavy_radius = min(charge / 50000, 20)
	var/light_radius = min(charge / 25000, 25)
	empulse(T, heavy_radius, light_radius)
	return ..()

/mob/living/simple_animal/pulse_demon/Move(newloc)
	var/obj/machinery/power/new_power = locate(/obj/machinery/power) in newloc
	var/obj/structure/cable/new_cable = locate(/obj/structure/cable) in newloc

	if (istype(new_power, /obj/machinery/power/terminal))
		new_power = null // entering a terminal is kinda useless

	if (isapc(new_power) && !is_valid_apc(new_power))
		new_power = null // don't enter an APC without a terminal or a broken APC, etc.

	if (!new_cable && !new_power)
		if (!can_exit_cable)
			return
		speed = outside_cable_speed
	else
		speed = inside_cable_speed

	var/moved = ..()

	if (!is_under_tile() && prob(PULSEDEMON_PLATING_SPARK_CHANCE))
		do_sparks(rand(2, 4), FALSE, src)

	if (new_power)
		current_power = new_power
		current_cable = null
		forceMove(current_power) // we go inside the machine
		playsound(src, 'sound/effects/eleczap.ogg', 50, 1)
		do_sparks(rand(2, 4), FALSE, src)
		if (isapc(current_power))
			try_hijack_apc(current_power)
	else if (new_cable)
		current_cable = new_cable
		current_power = null
		if (!isturf(loc))
			loc = get_turf(newloc)
		if (!moved)
			forceMove(newloc)
	else
		current_cable = null
		current_power = null

// signal to replace relaymove where or when?
/obj/machinery/power/relaymove(mob/user, dir)
	if (!istype(user, /mob/living/simple_animal/pulse_demon))
		return ..()

	var/mob/living/simple_animal/pulse_demon/PD = user
	var/turf/T = get_turf(src)
	var/turf/T2 = get_step(T, dir)
	if (PD.can_exit_cable || locate(/obj/structure/cable) in T2)
		playsound(src, 'sound/effects/eleczap.ogg', 50, 1)
		do_sparks(rand(2, 4), FALSE, src)
		user.forceMove(T)
		if (isapc(src))
			PD.cancel_hijack_apc(src)

// TODO: decide how maxcharge should increase, it's kinda weird for now (see also: SMES draining code in Life())
//       I'd say have maxcharge be a multiple of the number of controlled APCs (with upgrade to increase)
// adjust_max is TRUE when draining APCs
/mob/living/simple_animal/pulse_demon/proc/adjustCharge(amount, adjust_max = FALSE)
	if (adjust_max)
		maxcharge = max(maxcharge, charge + amount)
	charge = min(maxcharge, charge + amount)

/mob/living/simple_animal/pulse_demon/Life(seconds, times_fired)
	. = ..()

	var/got_power = FALSE
	if (current_cable)
		// TODO: small passive charge gain from cables when draining?
		if (current_cable.avail() >= power_per_regen)
			current_cable.add_load(power_per_regen)
			got_power = TRUE
	else if (current_power)
		if (isapc(current_power) && do_drain)
			var/obj/machinery/power/apc/this_apc = current_power
			// no draining and hijacking in one
			if (!this_apc.being_hijacked)
				var/amount_to_drain = min(this_apc.cell.charge, power_drain_rate)
				this_apc.cell.use(amount_to_drain)
				// gain more charge than we drain (TODO: consult on numbers with balance team)
				adjustCharge(amount_to_drain * PULSEDEMON_APC_CHARGE_MULTIPLIER, TRUE)
				if (amount_to_drain > power_per_regen)
					got_power = TRUE
		else if (istype(current_power, /obj/machinery/power/smes) && do_drain)
			var/obj/machinery/power/smes/this_smes = current_power
			// drain SMESes faster than APCs (TODO: consult on numbers with balance team)
			var/amount_to_drain = min(this_smes.charge, power_drain_rate * PULSEDEMON_SMES_DRAIN_MULTIPLIER)
			this_smes.charge -= amount_to_drain
			maxcharge = max(maxcharge, this_smes.output_level)
			adjustCharge(amount_to_drain)
			if (amount_to_drain > power_per_regen)
				got_power = TRUE
		// try to take power from the powernet if the APC or SMES is empty
		if (!got_power && current_power.avail() >= power_per_regen)
			current_power.add_load(power_per_regen)
			got_power = TRUE
	else if (!can_exit_cable)
		death()
		return

	if (got_power)
		if (regen_lock <= 0)
			adjustHealth(-health_regen_rate)
		clear_alert(ALERT_CATEGORY_NOPOWER)
	else
		adjustHealth(health_loss_rate)
		throw_alert(ALERT_CATEGORY_NOPOWER, /obj/screen/alert/pulse_nopower)

	if (regen_lock > 0)
		if (--regen_lock == 0)
			clear_alert(ALERT_CATEGORY_NOREGEN)

// TODO: maybe add APCs (bluescreen state?) to the demon's overlay if successful?
/mob/living/simple_animal/pulse_demon/proc/try_hijack_apc(obj/machinery/power/apc/A)
	// one APC per pulse demon, one pulse demon per APC, no duplicate APCs
	if (is_valid_hijack(A) && !(A in hijacked_apcs) && !apc_being_hijacked && !A.being_hijacked)
		progbar = new(src, apc_hijack_time, A)
		progbar.update(0)
		progbar_timer_id = addtimer(CALLBACK(src, PROC_REF(update_progressbar), world.time), apc_hijack_time / 20, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_STOPPABLE | TIMER_LOOP)
		apc_being_hijacked = A
		A.being_hijacked = TRUE
		A.update_icon()
		hijack_timer_id = addtimer(CALLBACK(src, PROC_REF(finish_hijack_apc), A), apc_hijack_time, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_STOPPABLE)

/mob/living/simple_animal/pulse_demon/proc/update_progressbar(start)
	progbar.update(world.time - start)

/mob/living/simple_animal/pulse_demon/proc/cleanup_hijack(obj/machinery/power/apc/A)
	deltimer(progbar_timer_id)
	progbar_timer_id = null
	QDEL_NULL(progbar)
	hijack_timer_id = null
	apc_being_hijacked = null
	A.being_hijacked = FALSE
	A.update_icon()

/mob/living/simple_animal/pulse_demon/proc/finish_hijack_apc(obj/machinery/power/apc/A)
	if (is_valid_hijack(A) && A == apc_being_hijacked)
		hijacked_apcs += A
		cleanup_hijack(A)

/mob/living/simple_animal/pulse_demon/proc/cancel_hijack_apc(obj/machinery/power/apc/A)
	if (A && A == apc_being_hijacked)
		deltimer(hijack_timer_id)
		cleanup_hijack(A)

// can enter an apc at all?
/mob/living/simple_animal/pulse_demon/proc/is_valid_apc(obj/machinery/power/apc/A)
	return A && A.terminal && !(A.stat & BROKEN) && !A.shorted

// TODO: which checks here? maybe aidisabled or constructed?
/mob/living/simple_animal/pulse_demon/proc/is_valid_hijack(obj/machinery/power/apc/A)
	return is_valid_apc(A)

/mob/living/simple_animal/pulse_demon/proc/try_cross_shock(src, atom/A)
	if (!isliving(A) || is_under_tile())
		return
	var/mob/living/L = A
	try_shock_mob(L)

/mob/living/simple_animal/pulse_demon/proc/try_shock_mob(mob/living/L, siemens_coeff = 1)
	var/dealt = 0
	if (current_cable && current_cable.powernet && current_cable.powernet.avail)
		// returns used energy, not damage dealt, but ez conversion with /20
		dealt = electrocute_mob(L, current_cable.powernet, src, siemens_coeff) / 20
	else if (charge >= 1000)
		dealt = L.electrocute_act(30, src, siemens_coeff)
		adjustCharge(-1000)
	add_attack_logs(src, L, "shocked ([dealt] damage)")

// TODO: spells that can effect machines IN YOUR AREA (see /vg/station wiki)
/mob/living/simple_animal/pulse_demon/proc/controlling_area()
	if (isapc(current_power))
		var/obj/machinery/power/apc/this_apc = current_power
		return this_apc.apc_area

/mob/living/simple_animal/pulse_demon/proc/is_under_tile()
	var/turf/T = get_turf(src)
	return T.transparent_floor || T.intact

// cable view helper
/mob/living/simple_animal/pulse_demon/proc/update_cableview()
	if (!client)
		return

	// clear out old images
	for (var/image/current_image in cables_shown)
		client.images -= current_image
	cables_shown.Cut()

	// regenerate for all cables on our (or our holder's) z-level
	for (var/obj/structure/cable/C in GLOB.cable_list)
		if (C.z != z && !(loc && C.z == loc.z)) continue;
		var/image/CI = image(C, get_turf(C), layer = ABOVE_LIGHTING_LAYER, dir = C.dir)
		// good visibility here
		CI.plane = ABOVE_LIGHTING_PLANE
		cables_shown += CI
		client.images += CI

/mob/living/simple_animal/pulse_demon/reset_perspective(atom/A)
	. = ..()
	update_cableview()

/mob/living/simple_animal/pulse_demon/emp_act(severity)
	. = ..()
	visible_message("<span class ='danger'>[src] [pick("fizzles", "wails", "flails")] in anguish!</span>")
	throw_alert(ALERT_CATEGORY_NOREGEN, /obj/screen/alert/pulse_noregen)
	adjustHealth(round(max(initial(health) / 2, round(maxHealth / 4))))
	regen_lock = 5

/mob/living/simple_animal/pulse_demon/proc/try_attack_mob(mob/living/L)
	if (!is_under_tile() && L != src)
		do_attack_animation(L)
		try_shock_mob(L)

/mob/living/simple_animal/pulse_demon/UnarmedAttack(atom/A)
	if (isliving(A))
		var/mob/living/L = A
		try_attack_mob(L)

/mob/living/simple_animal/pulse_demon/attack_hand(mob/living/carbon/human/M)
	if (is_under_tile())
		to_chat(M, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	switch (M.intent)
		if (INTENT_HELP)
			visible_message("<span class='notice'>[M] [response_help] [src].</span>")
		if (INTENT_DISARM, INTENT_GRAB)
			visible_message("<span class='notice'>[M] [response_disarm] [src].</span>")
		if (INTENT_HELP)
			visible_message("<span class='warning'>[M] [response_harm] [src].</span>")
	try_attack_mob(M)

/mob/living/simple_animal/pulse_demon/attackby(obj/item/O, mob/living/user)
	if (is_under_tile())
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	var/obj/item/stock_parts/cell/C = O.get_cell()
	if (C && C.charge)
		C.use(min(C.charge, power_drain_rate))
		adjustCharge(min(C.charge, power_drain_rate))
		to_chat(user, "<span class='warning'>You touch \the [src] with \the [O] and \the [src] drains it!</span>")
		to_chat(src, "<span class='notice'>[user] touches you with \the [O] and you drain its power!</span>")
	visible_message("<span class='notice'>The [O] goes right through \the [src].</span>")
	try_shock_mob(user, O.siemens_coefficient)

/mob/living/simple_animal/pulse_demon/ex_act()
	return

/mob/living/simple_animal/pulse_demon/bullet_act(obj/item/projectile/Proj)
	visible_message("<span class='warning'>The [Proj] goes right through \the [src]!</span>")

/mob/living/simple_animal/pulse_demon/electrocute_act(shock_damage, source, siemens_coeff, flags)
	return // TODO: potiential for gaining charge or a boost of some kind?

/mob/living/simple_animal/pulse_demon/blob_act(obj/structure/blob/B)
	return // will likely end up dying if the blob cuts its wires anyway

/mob/living/simple_animal/pulse_demon/narsie_act()
	return // you can't turn electricity into a harvester

/mob/living/simple_animal/pulse_demon/get_access()
	return IGNORE_ACCESS

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

// TODO: convert to spell
/mob/living/simple_animal/pulse_demon/verb/toggle_do_drain()
	set category = "Pulse Demon"
	set name = "Toggle Draining"
	set desc = "Toggle whether to drain power supplies."
	do_drain = !do_drain
	to_chat(src, "You will [do_drain ? "now" : "no longer"] drain power sources.")

// TODO: convert to spell
/mob/living/simple_animal/pulse_demon/verb/toggle_can_exit()
	set category = "Pulse Demon"
	set name = "Toggle Exit Cable"
	set desc = "Toggle whether you can move off of cables or power sources."
	can_exit_cable = !can_exit_cable
	to_chat(src, "You will [can_exit_cable ? "now" : "no longer"] move outside cable connections.")

/obj/screen/alert/pulse_nopower
	name = "No Power"
	desc = "You are not connected to a cable or machine and are losing health!"
	icon_state = "nocell" // TODO: sprite

/obj/screen/alert/pulse_noregen
	name = "Regeneration Stalled"
	desc = "You've been EMP'd and cannot regenerate health!"
	icon_state = "locked" // TODO: sprite

#undef ALERT_CATEGORY_NOPOWER
#undef ALERT_CATEGORY_NOREGEN

#undef isapc
