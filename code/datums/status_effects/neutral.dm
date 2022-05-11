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

/datum/status_effect/high_five
	id = "high_five"
	duration = 40
	alert_type = null

/datum/status_effect/high_five/on_remove()
	owner.visible_message("[owner] was left hanging....")

/datum/status_effect/charging
	id = "charging"
	alert_type = null

/datum/status_effect/reaper_lighter
	id = "reaper_lighter"
	duration = -1
	alert_type = null
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/reaper_lighter/on_apply()
	ADD_TRAIT(owner, TRAIT_RESISTHEAT, REAPER_LIGHTER)
	ADD_TRAIT(owner, TRAIT_RESISTCOLD, REAPER_LIGHTER)
	ADD_TRAIT(owner, TRAIT_RESISTHIGHPRESSURE, REAPER_LIGHTER)
	ADD_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, REAPER_LIGHTER)
	ADD_TRAIT(owner, TRAIT_NOBREATH, REAPER_LIGHTER)
	ADD_TRAIT(owner, TRAIT_BYPASS_WELDED_VENTS, REAPER_LIGHTER)
	owner.throw_alert("reaper_lighter", /obj/screen/alert/countdown/reaper_lighter)
	return TRUE

/datum/status_effect/reaper_lighter/on_remove()
	REMOVE_TRAIT(owner, TRAIT_RESISTHEAT, REAPER_LIGHTER)
	REMOVE_TRAIT(owner, TRAIT_RESISTCOLD, REAPER_LIGHTER)
	REMOVE_TRAIT(owner, TRAIT_RESISTHIGHPRESSURE, REAPER_LIGHTER)
	REMOVE_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, REAPER_LIGHTER)
	REMOVE_TRAIT(owner, TRAIT_NOBREATH, REAPER_LIGHTER)
	REMOVE_TRAIT(owner, TRAIT_BYPASS_WELDED_VENTS, REAPER_LIGHTER)
	owner.clear_alert("reaper_lighter")
	return TRUE
