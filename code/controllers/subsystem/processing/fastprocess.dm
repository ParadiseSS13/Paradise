//Fires five times every second.

PROCESSING_SUBSYSTEM_DEF(fastprocess)
	name = "Fast Processing"
	wait = 2
	stat_tag = "FP"
	offline_implications = "Objects using the 'Fast Processing' processor will no longer process. Shuttle call recommended."
