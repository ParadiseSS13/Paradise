//entirely neutral or internal status effects go here

/// tracks the damage dealt to this mob by kinetic crushers
/datum/status_effect/crusher_damage
	id = "crusher_damage"
	alert_type = null
	var/total_damage = 0

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target

/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target

/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)

/datum/status_effect/syphon_mark/tick()
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)

/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/datum/status_effect/adaptive_learning
	id = "adaptive_learning"
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	var/bonus_damage = 0

/datum/status_effect/high_five
	id = "high_five"
	duration = 10 SECONDS
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	/// Message displayed when wizards perform this together
	var/critical_success = "high-five EPICALLY!"
	/// Message displayed when normal people perform this together
	var/success = "high-five!"
	/// Message displayed when this status effect is applied.
	var/request = "requests a high-five."
	/// Item to be shown in the pop-up balloon.
	var/obj/item/item_path = /obj/item/latexballon
	/// Sound effect played when this emote is completed.
	var/sound_effect = 'sound/weapons/slap.ogg'

/// So we don't leave folks with god-mode
/datum/status_effect/high_five/proc/wiz_cleanup(mob/living/carbon/user, mob/living/carbon/highfived)
	user.status_flags &= ~GODMODE
	highfived.status_flags &= ~GODMODE
	user.remove_status_effect(type)
	highfived.remove_status_effect(type)

/datum/status_effect/high_five/proc/wiz_effect(mob/living/carbon/user, mob/living/carbon/highfived)
	user.status_flags |= GODMODE
	highfived.status_flags |= GODMODE
	explosion(get_turf(user), 5, 2, 1, 3, cause = "Wizard high-five")
	// explosions have a spawn so this makes sure that we don't get gibbed
	addtimer(CALLBACK(src, PROC_REF(wiz_cleanup), user, highfived), 0.3 SECONDS) // I want to be sure this lasts long enough, with lag.
	add_attack_logs(user, highfived, "caused a wizard [id] explosion")

/datum/status_effect/high_five/proc/post_start()
	return

/datum/status_effect/high_five/proc/regular_effect(mob/living/carbon/user, mob/living/carbon/highfived)
	user.visible_message("<span class='notice'><b>[user.name]</b> and <b>[highfived.name]</b> [success]</span>")

/datum/status_effect/high_five/on_apply()
	if(!iscarbon(owner))
		return FALSE
	. = ..()

	var/mob/living/carbon/user = owner
	var/is_wiz = iswizard(user)
	var/both_wiz = FALSE
	for(var/mob/living/carbon/C in orange(1, user))
		if(!C.has_status_effect(type) || C == user)
			continue
		if(is_wiz && iswizard(C))
			user.visible_message("<span class='biggerdanger'><b>[user.name]</b> and <b>[C.name]</b> [critical_success]</span>")
			wiz_effect(user, C)
			both_wiz = TRUE
		user.do_attack_animation(C, no_effect = TRUE)
		C.do_attack_animation(user, no_effect = TRUE)
		playsound(user, sound_effect, 80)
		if(!both_wiz)
			regular_effect(user, C)
			user.remove_status_effect(type)
			C.remove_status_effect(type)
			return FALSE
		// We can return to break out of the loop here so we don't auto-remove (which causes the timer on the wizard highfive to break)
		// This is safe because we only pass the continue if we don't have the status effect
		return TRUE // DO NOT AUTOREMOVE

	owner.custom_emote(EMOTE_VISIBLE, request)
	owner.create_point_bubble_from_path(item_path, FALSE)
	post_start()

/datum/status_effect/high_five/on_timeout()
	owner.visible_message("[owner] [get_missed_message()]")

/datum/status_effect/high_five/proc/get_missed_message()
	var/list/missed_highfive_messages = list(
		"lowers [owner.p_their()] hand, it looks like [owner.p_they()] [owner.p_were()] left hanging...",
		"seems to awkwardly wave at nobody in particular.",
		"moves [owner.p_their()] hand directly to [owner.p_their()] forehead in shame.",
		"fully commits and high-fives empty space.",
		"high-fives [owner.p_their()] other hand shamefully before wiping away a tear.",
		"goes for a handshake, then a fistbump, before pulling [owner.p_their()] hand back...? <i>What [owner.p_are()] [owner.p_they()] doing?</i>"
	)

	return pick(missed_highfive_messages)

/datum/status_effect/high_five/dap
	id = "dap"
	critical_success = "dap each other up EPICALLY!"
	success = "dap each other up!"
	request = "requests someone to dap them up!"
	sound_effect = 'sound/effects/snap.ogg'
	item_path = /obj/item/melee/touch_attack/fake_disintegrate  // EI-NATH!

/datum/status_effect/high_five/dap/get_missed_message()
	return "sadly can't find anybody to give daps to, and daps [owner.p_themselves()]. Shameful."

/datum/status_effect/high_five/offering_eftpos
	id = "offering_eftpos"
	request = "holds out an EFTPOS device."
	item_path = /obj/item/eftpos

/datum/status_effect/high_five/offering_eftpos/get_missed_message()
	return "pulls back the EFTPOS device."

/datum/status_effect/high_five/offering_eftpos/on_apply()
	owner.custom_emote(EMOTE_VISIBLE, request)
	owner.create_point_bubble_from_path(item_path, FALSE)
	RegisterSignal(owner, COMSIG_ATOM_RANGED_ATTACKED, PROC_REF(on_ranged_attack))
	return TRUE

/datum/status_effect/high_five/offering_eftpos/on_remove()
	UnregisterSignal(owner, COMSIG_ATOM_RANGED_ATTACKED)

/datum/status_effect/high_five/offering_eftpos/proc/on_ranged_attack(mob/living/me, mob/living/carbon/human/attacker)
	SIGNAL_HANDLER  // COMSIG_ATOM_RANGED_ATTACKED
	if(get_dist(me, attacker) <= 2)
		to_chat(attacker, "<span class='warning'>You need to have your ID in hand to scan it!</span>")
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/status_effect/high_five/handshake
	id = "handshake"
	critical_success = "give each other an EPIC handshake!"
	success = "give each other a handshake!"
	request = "requests a handshake!"
	sound_effect = "sound/weapons/thudswoosh.ogg"

/datum/status_effect/high_five/handshake/get_missed_message()
	var/list/missed_messages = list(
		"drops [owner.p_their()] hand, shamefully.",
		"grabs [owner.p_their()] outstretched hand with [owner.p_their()] other hand and gives [owner.p_themselves()] a handshake.",
		"balls [owner.p_their()] hand into a fist, slowly bringing it back in."
	)

	return pick(missed_messages)

/datum/status_effect/high_five/rps
	id = "rps"
	critical_success = "both play rock -- THEY'RE GOING IN FOR THE FISTBUMP!"
	success = "play rock-paper-scissors!"
	sound_effect = 'sound/effects/glassknock.ogg'
	request = "wants to play rock-paper-scissors!"
	item_path = /obj/item/claymore  // it's time to d-d-d-d-d-d-d-duel!
	/// The move that you'll be making.
	var/move

/datum/status_effect/high_five/rps/get_missed_message()
	var/list/missed_messages = list(
		"just seems to be practicing against [owner.p_themselves()]. [owner.p_are(TRUE)] [owner.p_they()] losing?",
		"seems more interested in a thumb war."
	)

	return pick(missed_messages)

/datum/status_effect/high_five/rps/proc/get_move_status(my_move, their_move)
	if(my_move == their_move)
		return RPS_EMOTE_TIE
	switch(my_move)
		if(RPS_EMOTE_ROCK)
			return their_move == RPS_EMOTE_SCISSORS ? RPS_EMOTE_WE_WIN : RPS_EMOTE_THEY_WIN

		if(RPS_EMOTE_PAPER)
			return their_move == RPS_EMOTE_ROCK ? RPS_EMOTE_WE_WIN : RPS_EMOTE_THEY_WIN

		if(RPS_EMOTE_SCISSORS)
			return their_move == RPS_EMOTE_PAPER ? RPS_EMOTE_WE_WIN : RPS_EMOTE_THEY_WIN

		else
			CRASH("Unknown emote rock type")

/datum/status_effect/high_five/rps/post_start()
	playsound(owner, 'sound/effects/glassknock.ogg', 50, FALSE)

/datum/status_effect/high_five/rps/regular_effect(mob/living/carbon/user, mob/living/carbon/highfived)
	var/datum/status_effect/high_five/rps/their_status_effect = highfived.has_status_effect(type)
	var/outcome = get_move_status(move, their_status_effect.move)
	var/outcome_msg
	switch(outcome)
		if(RPS_EMOTE_TIE)
			outcome_msg = "It's a tie!"
		if(RPS_EMOTE_WE_WIN)
			outcome_msg = "[user] wins!"
		if(RPS_EMOTE_THEY_WIN)
			outcome_msg = "[highfived] wins!"

	user.visible_message(
		"<span class='notice'>[user] plays <b>[move]</b>, and [highfived] plays <b>[their_status_effect.move]</b>.</span>",
		"<span class='notice'>[highfived] plays <b>[their_status_effect.move]</b>.</span>",
		"<span class='notice'>It sounds like rock-paper-scissors.</span>"
	)

	user.visible_message(
		"<span class='warning'>[outcome_msg]</span>",
		blind_message = "<span class='notice'>It sounds like [pick(user, highfived)] won!</span>"  // you're blind how are you supposed to know
	)

/datum/status_effect/high_five/rps/on_creation(mob/living/new_owner, made_move)
	if(made_move)
		if(!(made_move in list(RPS_EMOTE_ROCK, RPS_EMOTE_PAPER, RPS_EMOTE_SCISSORS)))
			stack_trace("RPS emote was given an invalid move type on creation.")
		else
			move = made_move

	return ..()

/datum/status_effect/high_five/rps/on_apply()
	if(!isnull(move))
		to_chat(owner, "<span class='notice'>You prepare to play <b>[move]</b>.</span>")
		return ..()  // we already have the move, probably from the emote passing it in

	move = get_rock_paper_scissors_move(owner)
	if(move == null)
		return FALSE  // make it auto-remove itself

	to_chat(owner, "<span class='notice'>You prepare to play <b>[move]</b>.</span>")
	return ..()


/proc/get_rock_paper_scissors_move(mob/living/carbon/user)
	var/list/move_icons = list(
		RPS_EMOTE_SCISSORS = image(icon = 'icons/obj/items.dmi', icon_state = "bscissor"),
		RPS_EMOTE_PAPER = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paper"),
		RPS_EMOTE_ROCK = image(icon = 'icons/obj/toy.dmi', icon_state = "pet_rock")
	)
	return show_radial_menu(user, user, move_icons)

/// A status effect that can have a certain amount of "bonus" duration added, which extends the duration every tick,
/// although there is a maximum amount of bonus time that can be active at any given time.
/datum/status_effect/limited_bonus
	id = "limited_bonus"
	/// How much extra time has been added
	var/bonus_time = 0
	/// How much extra time to apply per tick
	var/bonus_time_per_tick = 1 SECONDS
	/// How much maximum bonus time can be active at once
	var/max_bonus_time = 1 MINUTES

/datum/status_effect/limited_bonus/tick()
	. = ..()
	// Sure, we could do some fancy stuff with clamping, and it'd probably be a little cleaner.
	// This keeps the math simple and easier to use later
	if(bonus_time > bonus_time_per_tick)
		duration += bonus_time_per_tick
		bonus_time -= bonus_time_per_tick

/datum/status_effect/limited_bonus/proc/extend(extra_time)
	bonus_time = clamp(bonus_time + extra_time, 0, max_bonus_time)

/datum/status_effect/limited_bonus/revivable
	id = "revivable"
	alert_type = null
	duration = BASE_DEFIB_TIME_LIMIT

/datum/status_effect/limited_bonus/revivable/on_apply()
	. = ..()
	if(!iscarbon(owner))
		return FALSE

	RegisterSignal(owner, COMSIG_HUMAN_RECEIVE_CPR, PROC_REF(on_cpr))
	RegisterSignal(owner, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	owner.med_hud_set_status()  // update revivability after adding the status effect


/datum/status_effect/limited_bonus/revivable/proc/on_cpr(mob/living/carbon/human/H, new_seconds)
	SIGNAL_HANDLER  // COMSIG_HUMAN_RECEIVE_CPR
	extend(new_seconds)

/datum/status_effect/limited_bonus/revivable/proc/on_revive()
	SIGNAL_HANDLER  // COMSIG_LIVING_REVIVE
	qdel(src)

/datum/status_effect/limited_bonus/revivable/on_remove()
	// Update HUDs once the status effect is deleted to show non-revivability
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living, med_hud_set_status))
	. = ..()


/datum/status_effect/charging
	id = "charging"
	alert_type = null

/datum/status_effect/impact_immune
	id = "impact_immune"
	alert_type = null

/datum/status_effect/recently_succumbed
	id = "recently_succumbed"
	alert_type = null
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REFRESH

#define LWAP_LOCK_CAP 10

/datum/status_effect/lwap_scope
	id = "lwap_scope"
	alert_type = null
	tick_interval = 4
	/// The number of people the gun has locked on to. Caps at 10 for sanity.
	var/locks = 0

/datum/status_effect/lwap_scope/tick()
	locks = 0
	for(var/atom/movable/screen/fullscreen/stretch/cursor_catcher/scope/our_scope in owner.client.screen)
		for(var/mob/living/L in range(10, our_scope.given_turf))
			if(locks >= LWAP_LOCK_CAP)
				return
			if(L == owner || L.stat == DEAD || isslime(L) || ismonkeybasic(L) || L.invisibility > owner.see_invisible || isLivingSSD(L)) //xenobio moment
				continue
			new /obj/effect/temp_visual/single_user/lwap_ping(owner.loc, owner, L)
			locks++

#undef LWAP_LOCK_CAP

/datum/status_effect/hivelord_tracking
	id = "hivelord_tracking"
	alert_type = null
	duration = 10 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	var/list/list_of_uids = list()

/datum/status_effect/delayed
	id = "delayed_status_effect"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	var/prevent_signal = null
	var/datum/callback/expire_proc = null

/datum/status_effect/delayed/on_creation(mob/living/new_owner, new_duration, datum/callback/new_expire_proc, new_prevent_signal = null)
	if(isnull(new_duration) || !istype(new_expire_proc))
		qdel(src)
		return
	if(new_duration == 0)
		new_expire_proc.Invoke()
		return

	duration = new_duration
	expire_proc = new_expire_proc
	. = ..()
	if(new_prevent_signal)
		RegisterSignal(owner, new_prevent_signal, PROC_REF(prevent_action))
		prevent_signal = new_prevent_signal

/datum/status_effect/proc/prevent_action()
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/delayed/on_remove()
	if(prevent_signal)
		UnregisterSignal(owner, prevent_signal)
	. = ..()

/datum/status_effect/delayed/on_timeout()
	. = ..()
	expire_proc.Invoke()

/datum/status_effect/action_status_effect
	id = "action_status_effect"
	alert_type = null
	tick_interval = -1

/datum/status_effect/action_status_effect/remove_handcuffs
	id = "remove_handcuffs"

/datum/status_effect/action_status_effect/remove_muzzle
	id = "remove_muzzle"

/datum/status_effect/action_status_effect/unbuckle
	id = "unbuckle"

/datum/status_effect/action_status_effect/exit_cryocell
	id = "exit_cryocell"
