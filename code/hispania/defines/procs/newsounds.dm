GLOBAL_DATUM_INIT(request_announcement, /datum/announcement/request, new())
//Sonido en request console de heads by Sauronato
/datum/announcement/request/New(do_log = 0, new_sound = sound('sound/hispania/misc/announce1.ogg'), do_newscast = 0)
	..(do_log, new_sound, do_newscast)
