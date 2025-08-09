/datum/event/anomaly/anomaly_pyro
	name = "Pyro Anomaly"
	role_weights =  list(ASSIGNMENT_ENGINEERING = 60)
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/pyro
	prefix_message = "Pyroclastic anomaly detected on long range scanners."
	announce_sound = 'sound/AI/anomaly_pyro.ogg'
