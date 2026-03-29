/obj/item/grenade/smokebomb
	name = "smoke bomb"
	desc = "A grenade filled with chemical agents that will turn into a dense smoke when detonated, making it impossible to see through without specialised optics."
	icon_state = "smoke"
	inhand_icon_state = "smoke"
	det_time = 2 SECONDS
	modifiable_timer = FALSE
	var/datum/effect_system/smoke_spread/bad/smoke

/obj/item/grenade/smokebomb/Initialize(mapload)
	. = ..()
	smoke = new /datum/effect_system/smoke_spread/bad
	smoke.attach(src)

/obj/item/grenade/smokebomb/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/grenade/smokebomb/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	smoke.set_up(10, FALSE)
	spawn(0)
		src.smoke.start()
		sleep(10)
		src.smoke.start()
		sleep(10)
		src.smoke.start()
		sleep(10)
		src.smoke.start()
	sleep(80)
	qdel(src)
