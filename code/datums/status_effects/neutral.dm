//entirely neutral or internal status effects go here

/datum/status_effect/high_five
	id = "high_five"
	duration = 40
	alert_type = null

/datum/status_effect/high_five/on_timeout()
	owner.visible_message("[owner] was left hanging....")
