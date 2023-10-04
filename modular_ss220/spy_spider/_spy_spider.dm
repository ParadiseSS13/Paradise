/datum/modpack/spy_spider
	name = "Шпионские жучки"
	desc = "Шпионские жучки для детектива."
	author = "dj-34, Vallat"

#define SPY_SPIDER_FREQ 1251

/datum/modpack/spy_spider/initialize()
	SSradio.radiochannels |= list("Spy Spider" = SPY_SPIDER_FREQ)
