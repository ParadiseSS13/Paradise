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
	/// Silicon activation message
	var/silicon_message = "activates its high-five modules."

/// So we don't leave folks with god-mode
/datum/status_effect/high_five/proc/wiz_cleanup(mob/user, mob/highfived)
	user.status_flags &= ~GODMODE
	highfived.status_flags &= ~GODMODE

/datum/status_effect/high_five/on_apply()
	if(!isliving(owner))
		return FALSE
	. = ..()

	var/mob/living/user = owner
	var/is_wiz = iswizard(user)
	for(var/mob/living/C in orange(1, user))
		if(!C.has_status_effect(type) || C == user)
			continue
		if(is_wiz && iswizard(C))
			user.visible_message("<span class='biggerdanger'><b>[user.name]</b> and <b>[C.name]</b> [critical_success]</span>")
			user.status_flags |= GODMODE
			C.status_flags |= GODMODE
			explosion(get_turf(user), 5, 2, 1, 3, cause = id)
			// explosions have a spawn so this makes sure that we don't get gibbed
			addtimer(CALLBACK(src, PROC_REF(wiz_cleanup), user, C), 1)
			add_attack_logs(user, C, "caused a wizard [id] explosion")
			user.remove_status_effect(type)
			C.remove_status_effect(type)

		user.do_attack_animation(C, no_effect = TRUE)
		C.do_attack_animation(user, no_effect = TRUE)
		user.visible_message("<span class='notice'><b>[user.name]</b> and <b>[C.name]</b> [success]</span>")
		playsound(user, sound_effect, 80)
		user.remove_status_effect(type)
		C.remove_status_effect(type)
		return FALSE

	owner.custom_emote(EMOTE_VISIBLE, isrobot(owner) ? silicon_message : request)
	owner.create_point_bubble_from_path(item_path, FALSE)

/datum/status_effect/high_five/on_timeout()
	owner.visible_message("[owner] [get_missed_message()]")

/datum/status_effect/high_five/proc/get_missed_message()
	if(isrobot(owner))
		return "sadly activates [owner.p_their()] high-five inhibitors."
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
	silicon_message = "activates its dapping subroutines."

/datum/status_effect/high_five/dap/get_missed_message()
	if(issilicon(owner))
		return "catastrophically fails to dap, displaying a flashing error message."
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

/datum/status_effect/charging
	id = "charging"
	alert_type = null
