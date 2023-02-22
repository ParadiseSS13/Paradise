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
	duration = 5 SECONDS
	alert_type = null

/datum/status_effect/high_five/on_apply()
	if(!istype(owner, /mob/living))
		return FALSE
	. = ..()
	// this can only go well
	var/obj/item/latexballon/bloon = new()
	owner.create_point_bubble(bloon)
	QDEL_IN(bloon, 10)

/datum/status_effect/high_five/proc/get_missed_message()
	var/list/missed_highfive_messages = list(
		"it looks like [owner.p_they()] [owner.p_were()] left hanging...",
		"seeming to wave at nobody in particular.",
		"moving [owner.p_their()] hand directly to [owner.p_their()] forehead in shame.",
		"fully committing and high-fiving empty space.",
		"high-fiving [owner.p_their()] other hand shamefully before wiping away a tear.",
		"going for a handshake, then a fistbump, before pulling [owner.p_their()] hand back...? What [owner.p_are()] [owner.p_they()] doing?"
	)

	return pick(missed_highfive_messages)

/datum/status_effect/high_five/on_timeout()
	// show some emotionally damaging failure messages
	// high risk, high reward
	owner.visible_message("[owner] awkwardly lowers [owner.p_their()] hand, [get_missed_message()]")

/datum/status_effect/charging
	id = "charging"
	alert_type = null
