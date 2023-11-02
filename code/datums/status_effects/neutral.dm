//entirely neutral or internal status effects go here

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
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
			user.status_flags |= GODMODE
			C.status_flags |= GODMODE
			explosion(get_turf(user), 5, 2, 1, 3, cause = id)
			// explosions have a spawn so this makes sure that we don't get gibbed
			addtimer(CALLBACK(src, PROC_REF(wiz_cleanup), user, C), 0.3 SECONDS) //I want to be sure this lasts long enough, with lag.
			add_attack_logs(user, C, "caused a wizard [id] explosion")
			both_wiz = TRUE
		user.do_attack_animation(C, no_effect = TRUE)
		C.do_attack_animation(user, no_effect = TRUE)
		playsound(user, sound_effect, 80)
		if(!both_wiz)
			user.visible_message("<span class='notice'><b>[user.name]</b> and <b>[C.name]</b> [success]</span>")
			user.remove_status_effect(type)
			C.remove_status_effect(type)
			return FALSE
		return TRUE // DO NOT AUTOREMOVE

	owner.custom_emote(EMOTE_VISIBLE, request)
	owner.create_point_bubble_from_path(item_path, FALSE)

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

/// A status effect that can have a certain amount of "bonus" duration added, which extends the duration every tick,
/// although there is a maximum amount of bonus time that can be active at any given time.
/datum/status_effect/limited_bonus
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
	status_type = STATUS_EFFECT_UNIQUE
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

#define LWAP_LOCK_CAP 10

/datum/status_effect/lwap_scope
	id = "lwap_scope"
	alert_type = null
	duration = -1
	tick_interval = 4
	/// The number of people the gun has locked on to. Caps at 10 for sanity.
	var/locks = 0
	/// What direction the owner was in when using the scope.
	var/owner_dir = 0

/datum/status_effect/lwap_scope/on_creation(mob/living/new_owner, stored_dir = 0)
	owner_dir = stored_dir
	return ..()

/datum/status_effect/lwap_scope/tick()
	locks = 0
	var/turf/owner_turf = get_turf(owner)
	var/scope_turf
	for(var/turf/T in RANGE_EDGE_TURFS(7, owner_turf))
		if(get_dir(owner, T) != owner_dir)
			continue
		if(T in range(owner, 6))
			continue
		scope_turf = T
		break
	if(scope_turf)
		for(var/mob/living/L in range(10, scope_turf))
			if(locks >= LWAP_LOCK_CAP)
				return
			if(L == owner || L.stat == DEAD || isslime(L) || ismonkeybasic(L)) //xenobio moment
				continue
			new /obj/effect/temp_visual/single_user/lwap_ping(owner.loc, owner, L)
			locks++

#undef LWAP_LOCK_CAP

/datum/status_effect/delayed
	id = "delayed_status_effect"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	var/prevent_signal = null
	var/datum/callback/expire_proc = null

/datum/status_effect/delayed/on_creation(mob/living/new_owner, new_duration, datum/callback/new_expire_proc, new_prevent_signal = null)
	if(!new_duration || !istype(new_expire_proc))
		qdel(src)
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
