/datum/status_effect/blob_burst
	alert_type = /obj/screen/alert/status_effect/blob_burst
	var/datum/callback/blob_burst_callback

/datum/status_effect/blob_burst/on_creation(mob/living/new_owner, duration = 120 SECONDS, datum/callback/burst_callback)
	src.duration = duration
	. = ..()
	if(!.)
		return
	blob_burst_callback = burst_callback

/datum/status_effect/blob_burst/Destroy()
	blob_burst_callback = null
	return ..()

/datum/status_effect/blob_burst/tick()
	var/time_left = (duration - world.time) / 10
	linked_alert.maptext = MAPTEXT_CENTER(round(time_left))

/datum/status_effect/blob_burst/on_timeout()
	blob_burst_callback.Invoke()

/obj/screen/alert/status_effect/blob_burst
	name = "Blob burst"
	desc = "You're about to burst into a blob, be sure to find a safe place before that you burst!"
	icon = 'icons/mob/blob.dmi'
	icon_state = "ui_tocore"
