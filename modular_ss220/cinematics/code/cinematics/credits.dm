/datum/cinematic/credits
	cleanup_time = 40 SECONDS
	is_global = TRUE
	backdrop_type = /obj/screen/fullscreen/cinematic_backdrop/credits

/datum/cinematic/credits/New(watcher, datum/callback/special_callback)
	. = ..()
	screen = new/obj/screen/cinematic/credits(src)

/datum/cinematic/credits/start_cinematic(list/watchers)
	watching = watchers
	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PLAY_CINEMATIC, src) & COMPONENT_GLOB_BLOCK_CINEMATIC)
		RegisterSignal(SSdcs, COMSIG_GLOB_CINEMATIC_STOPPED_PLAYING, PROC_REF(queue_gone))
		return
	. = ..()

/datum/cinematic/credits/proc/queue_gone(datum/source, datum/cinematic/other)
	SIGNAL_HANDLER

	start_cinematic(src.watching)

/datum/cinematic/credits/play_cinematic()
	play_cinematic_sound(sound(SScredits.title_music))
	SScredits.roll_credits_for_clients(watching)

	special_callback?.Invoke()

/obj/screen/cinematic/credits
	icon_state = "blank"

/obj/screen/fullscreen/cinematic_backdrop/credits
	alpha = 0

/obj/screen/fullscreen/cinematic_backdrop/credits/Initialize(mapload)
	. = ..()

	animate(src, alpha = 220, time = 3 SECONDS)
