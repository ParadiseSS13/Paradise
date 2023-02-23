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
	var/critical_success = "high-five EPICALLY!"
	var/success = "high-five!"
	var/request = "requests a high-five."
	var/obj/item/item_path = /obj/item/latexballon
	var/sound_effect = 'sound/effects/snap.ogg'

/// So we don't leave folks with god-mode
/datum/status_effect/high_five/proc/wiz_cleanup(mob/user, mob/highfived)
	user.status_flags &= ~GODMODE
	highfived.status_flags &= ~GODMODE

/datum/status_effect/high_five/on_apply()
	if(!istype(owner, /mob/living/carbon))
		return FALSE
	. = ..()

	var/mob/living/carbon/user = owner
	for(var/mob/living/carbon/C in orange(1))
		if(C.has_status_effect(type) && C != user)
			if(iswizard(user) && iswizard(C))
				user.visible_message("<span class='biggerdanger'><b>[user.name]</b> and <b>[C.name]</b> [critical_success]</span>")
				user.status_flags |= GODMODE
				C.status_flags |= GODMODE
				explosion(get_turf(user), 5, 2, 1, 3)
				// explosions have a spawn so this makes sure that we don't get gibbed
				addtimer(CALLBACK(src, PROC_REF(wiz_cleanup), user, C), 1)
				user.remove_status_effect(type)
				C.remove_status_effect(type)

			user.do_attack_animation(C, no_effect = TRUE)
			C.do_attack_animation(user, no_effect = TRUE)
			user.visible_message("<b>[user.name]</b> and <b>[C.name]</b> [success]")
			playsound(user, sound_effect, 80)
			user.remove_status_effect(type)
			C.remove_status_effect(type)
			return FALSE

	owner.custom_emote(EMOTE_VISIBLE, request)
	// this can only go well
	var/obj/item/bloon = new item_path()
	owner.create_point_bubble(bloon)
	QDEL_IN(bloon, 10)

/datum/status_effect/high_five/on_timeout()
	owner.visible_message("[owner] [get_missed_message()]")

/datum/status_effect/high_five/proc/get_missed_message()
	var/list/missed_highfive_messages = list(
		"lowers [owner.p_their()] hand, it looks like [owner.p_they()] [owner.p_were()] left hanging...",
		"seems to awkwardly wave at nobody in particular.",
		"moves [owner.p_their()] hand directly to [owner.p_their()] forehead in shame.",
		"fully commit[owner.p_s()] and high-fives empty space.",
		"high-fives [owner.p_their()] other hand shamefully before wiping away a tear.",
		"goes for a handshake, then a fistbump, before pulling [owner.p_their()] hand back...? <i>What [owner.p_are()] [owner.p_they()] doing?</i>"
	)

	return pick(missed_highfive_messages)

/datum/status_effect/high_five/dap
	id = "dap"
	critical_success = "dap each other up EPICALLY!"
	success = "dap each other up!"
	request = "requests someone to dap them up!"

/datum/status_effect/high_five/dap/get_missed_message()
	return "sadly can't find anybody to give daps to, and daps themself. Shameful."

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
