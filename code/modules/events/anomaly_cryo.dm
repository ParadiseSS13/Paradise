/datum/event/anomaly/anomaly_cryo
	name = "Cryo Anomaly"
	role_weights = list(ASSIGNMENT_ENGINEERING = 60)
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/cryo
	prefix_message = "Cryogenic anomaly detected on long range scanners."
	announce_sound = 'sound/AI/anomaly_pyro.ogg'
