SUBSYSTEM_DEF(ipintel)
	name = "XKeyScore"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_XKEYSCORE // 10
	var/enabled = FALSE //disable at round start to avoid checking reconnects
	var/throttle = 0
	var/errors = 0

	var/list/cache = list()

/datum/controller/subsystem/ipintel/Initialize(start_timeofday)
	enabled = TRUE
	return ..()

