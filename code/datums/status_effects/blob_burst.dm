/datum/status_effect/blob_burst
	alert_type = /obj/screen/alert/status_effect/blob_burst
	var/datum/callback/blob_burst_callback
	var/font_size = 7

/datum/status_effect/blob_burst/on_creation(mob/living/new_owner, duration = 120 SECONDS, datum/callback/burst_callback)
	. = ..()
	if(!.)
		return
	src.duration = duration
	blob_burst_callback = burst_callback

/datum/status_effect/blob_burst/tick()
	var/time_left = (duration - world.time) / 10
	linked_alert.maptext = "<div style=\"font-size:7pt;color:#FFFFFF;font:'Small Fonts';text-align:center;\" valign=\"bottom\">[round(time_left)]</div>"

/datum/status_effect/blob_burst/on_timeout()
	blob_burst_callback.Invoke()

/obj/screen/alert/status_effect/blob_burst
	name = "Blob burst"
	desc = "You're about to burst into a blob! Be sure to find a safe place before that."
	icon = 'icons/mob/blob.dmi'
	icon_state = "ui_tocore"
