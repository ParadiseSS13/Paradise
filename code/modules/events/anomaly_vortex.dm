/datum/event/anomaly/anomaly_vortex
	name = "Vortex Anomaly"
	role_weights = list(ASSIGNMENT_ENGINEERING = 25)
	startWhen = 10
	announceWhen = 3
	anomaly_path = /obj/effect/anomaly/bhole
	prefix_message = "Localized high-intensity vortex anomaly detected on long range scanners."
	announce_sound = 'sound/AI/anomaly_vortex.ogg'
