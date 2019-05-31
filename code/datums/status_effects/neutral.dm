//entirely neutral or internal status effects go here

/datum/status_effect/high_five
	id = "high_five"
	duration = 40
	alert_type = null

/datum/status_effect/high_five/on_timeout()
	owner.visible_message("[owner] was left hanging....")

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0