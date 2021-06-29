/obj/item/grenade/bsa_beacon
	name = "bluespace artillery targeting beacon"
	desc = "Summons forth the might of the nanotrasen military."
	icon_state = "emp"
	item_state = "emp"
	det_time = 10
	display_timer = FALSE
	var/count_down_seconds = 10

/obj/item/grenade/bsa_beacon/prime()
	atom_say("BSA Targeting Network Connection Established.")
	sleep(10)
	atom_say("Artillery Ready To Fire In...")
	sleep(10)
	for(var/second in count_down_seconds to 1 step -1)
		playsound(loc, 'sound/items/timer.ogg', 30, 0)
		atom_say("[second]...") // Runechat requires strings or it won't work
		sleep(10)

	update_mob()
	explosion(src, 3, 6, 12)
	qdel(src)
